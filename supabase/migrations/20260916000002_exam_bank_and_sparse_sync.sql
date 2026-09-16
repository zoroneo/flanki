-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 002 - EXAM BANK & SPARSE SYNC
-- Description: Public Exam catalog, User exam submissions, Wrong questions notebook,
--              Sparse download RPC, and extended Batch Sync RPCs.
-- Created At: 2026-09-16
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. PUBLIC EXAM PAPERS CATALOG (Shared Read-Only Data)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_papers (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    category TEXT NOT NULL DEFAULT 'JLPT', -- 'JLPT', 'TOEIC', 'THPTQG', etc.
    level TEXT NOT NULL DEFAULT 'N3',
    duration_minutes INT NOT NULL DEFAULT 60,
    total_questions INT NOT NULL DEFAULT 40,
    passing_score INT NOT NULL DEFAULT 60,
    icon_name TEXT NOT NULL DEFAULT 'file-text',
    version INT NOT NULL DEFAULT 1,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_papers_category ON public.exam_papers (category, level);
CREATE INDEX IF NOT EXISTS idx_exam_papers_published ON public.exam_papers (is_published);

-- ------------------------------------------------------------------------------
-- 2. PUBLIC EXAM SECTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_sections (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    section_type TEXT NOT NULL DEFAULT 'general', -- 'language_knowledge', 'reading', 'listening'
    order_index INT NOT NULL DEFAULT 0,
    instruction TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_sections_exam ON public.exam_sections (exam_id, order_index);

-- ------------------------------------------------------------------------------
-- 3. PUBLIC EXAM QUESTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_questions (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    section_id TEXT NOT NULL REFERENCES public.exam_sections(id) ON DELETE CASCADE,
    question_number INT NOT NULL DEFAULT 1,
    question_text TEXT NOT NULL,
    context_passage TEXT,
    audio_url TEXT,
    options_json JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of {"id": "A", "text": "..."}
    correct_answer TEXT NOT NULL, -- e.g. "A", "B", "C", "D"
    explanation TEXT NOT NULL DEFAULT '',
    points INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_questions_exam_sec ON public.exam_questions (exam_id, section_id, question_number);

-- ------------------------------------------------------------------------------
-- 4. USER EXAM SUBMISSIONS (User Personal Replicated Data)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_submissions (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exam_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    score INT NOT NULL DEFAULT 0,
    total_correct INT NOT NULL DEFAULT 0,
    total_questions INT NOT NULL DEFAULT 0,
    duration_seconds INT NOT NULL DEFAULT 0,
    answers_json JSONB NOT NULL DEFAULT '{}'::jsonb, -- {"q1": "A", "q2": "C"}
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_exam_submissions PRIMARY KEY (id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_exam_submissions_user_hlc ON public.exam_submissions (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_exam_submissions_user_exam ON public.exam_submissions (user_id, exam_id);

-- ------------------------------------------------------------------------------
-- 5. WRONG QUESTION NOTEBOOK (Sổ Tay Câu Sai Cá Nhân)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.wrong_question_notebook (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exam_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL REFERENCES public.exam_questions(id) ON DELETE CASCADE,
    user_answer TEXT NOT NULL,
    explanation TEXT NOT NULL DEFAULT '',
    notes TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'new', -- 'new', 'reviewing', 'mastered'
    
    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_wrong_question_notebook PRIMARY KEY (id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_wrong_notebook_user_hlc ON public.wrong_question_notebook (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_wrong_notebook_user_status ON public.wrong_question_notebook (user_id, status);

-- ------------------------------------------------------------------------------
-- 6. ROW-LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.exam_papers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wrong_question_notebook ENABLE ROW LEVEL SECURITY;

-- Public Catalog: Anyone (anon or authenticated) can read published exams
DROP POLICY IF EXISTS "Allow Public Read Exam Papers" ON public.exam_papers;
CREATE POLICY "Allow Public Read Exam Papers" ON public.exam_papers
    FOR SELECT TO public USING (is_published = TRUE);

DROP POLICY IF EXISTS "Allow Public Read Exam Sections" ON public.exam_sections;
CREATE POLICY "Allow Public Read Exam Sections" ON public.exam_sections
    FOR SELECT TO public USING (TRUE);

DROP POLICY IF EXISTS "Allow Public Read Exam Questions" ON public.exam_questions;
CREATE POLICY "Allow Public Read Exam Questions" ON public.exam_questions
    FOR SELECT TO public USING (TRUE);

-- User Personal Data Isolation
DROP POLICY IF EXISTS "User Isolation for Exam Submissions" ON public.exam_submissions;
CREATE POLICY "User Isolation for Exam Submissions" ON public.exam_submissions
    FOR ALL TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "User Isolation for Wrong Notebook" ON public.wrong_question_notebook;
CREATE POLICY "User Isolation for Wrong Notebook" ON public.wrong_question_notebook
    FOR ALL TO authenticated USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 7. SPARSE SYNC RPC: DOWNLOAD FULL EXAM PAPER WITH QUESTIONS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.download_exam_paper(p_exam_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_paper JSONB;
    v_sections JSONB;
    v_questions JSONB;
BEGIN
    SELECT to_jsonb(p) INTO v_paper
    FROM public.exam_papers p
    WHERE p.id = p_exam_id AND p.is_published = TRUE;

    IF v_paper IS NULL THEN
        RAISE EXCEPTION 'Exam paper not found or unpublished: %', p_exam_id;
    END IF;

    SELECT jsonb_agg(to_jsonb(s) ORDER BY s.order_index ASC) INTO v_sections
    FROM public.exam_sections s
    WHERE s.exam_id = p_exam_id;

    SELECT jsonb_agg(to_jsonb(q) ORDER BY q.question_number ASC) INTO v_questions
    FROM public.exam_questions q
    WHERE q.exam_id = p_exam_id;

    RETURN jsonb_build_object(
        'paper', v_paper,
        'sections', COALESCE(v_sections, '[]'::jsonb),
        'questions', COALESCE(v_questions, '[]'::jsonb)
    );
END;
$$;
