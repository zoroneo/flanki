-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 001 - INITIAL SCHEMA
-- Description: Core business tables matching Drift SQLite with sync system columns
-- Created At: 2026-09-16
-- ==============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ------------------------------------------------------------------------------
-- 1. DECKS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.decks (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    due_count INT NOT NULL DEFAULT 0,
    new_count INT NOT NULL DEFAULT 0,
    total_count INT NOT NULL DEFAULT 0,
    last_studied TIMESTAMPTZ,
    
    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_decks PRIMARY KEY (id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_decks_user_hlc ON public.decks (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_decks_user_active ON public.decks (user_id) WHERE is_deleted = FALSE;

-- ------------------------------------------------------------------------------
-- 2. CARDS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cards (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    deck_id TEXT NOT NULL,
    front TEXT NOT NULL,
    back TEXT NOT NULL,
    hint TEXT,
    note_type TEXT NOT NULL DEFAULT 'basic',
    flag INT NOT NULL DEFAULT 0,
    is_suspended BOOLEAN NOT NULL DEFAULT FALSE,
    is_buried BOOLEAN NOT NULL DEFAULT FALSE,
    tags TEXT NOT NULL DEFAULT '',
    interval_days INT NOT NULL DEFAULT 0,
    stability REAL NOT NULL DEFAULT 0.0,
    difficulty REAL NOT NULL DEFAULT 0.0,
    reps INT NOT NULL DEFAULT 0,
    lapses INT NOT NULL DEFAULT 0,
    due TIMESTAMPTZ,
    last_studied TIMESTAMPTZ,

    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_cards PRIMARY KEY (id, user_id),
    CONSTRAINT fk_cards_deck FOREIGN KEY (deck_id, user_id) REFERENCES public.decks(id, user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_cards_user_hlc ON public.cards (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_cards_user_deck ON public.cards (user_id, deck_id) WHERE is_deleted = FALSE;
CREATE INDEX IF NOT EXISTS idx_cards_user_due ON public.cards (user_id, due) WHERE is_deleted = FALSE;

-- ------------------------------------------------------------------------------
-- 3. REVIEW LOGS TABLE (Append-Only Event Stream)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.review_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    card_id TEXT NOT NULL,
    rating INT NOT NULL,
    review_time TIMESTAMPTZ NOT NULL,
    scheduled_days INT NOT NULL DEFAULT 0,
    elapsed_days INT NOT NULL DEFAULT 0,
    client_log_id TEXT, -- Unique client review ID to guarantee idempotency on retry
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_review_logs_client_id UNIQUE (user_id, client_log_id)
);

CREATE INDEX IF NOT EXISTS idx_review_logs_user_time ON public.review_logs (user_id, review_time DESC);
CREATE INDEX IF NOT EXISTS idx_review_logs_user_card ON public.review_logs (user_id, card_id);

-- ------------------------------------------------------------------------------
-- 4. GRAMMAR PROGRESS ENTRIES TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.grammar_progress_entries (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    unit_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    stability REAL NOT NULL DEFAULT 0.0,
    difficulty REAL NOT NULL DEFAULT 0.0,
    due TIMESTAMPTZ,
    last_studied TIMESTAMPTZ,
    reps INT NOT NULL DEFAULT 0,
    lapses INT NOT NULL DEFAULT 0,
    state INT NOT NULL DEFAULT 0, -- 0: new, 1: learning, 2: review, 3: relearning
    is_ghost BOOLEAN NOT NULL DEFAULT FALSE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    last_user_answer TEXT,

    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_grammar_progress PRIMARY KEY (user_id, unit_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_grammar_user_hlc ON public.grammar_progress_entries (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_grammar_user_unit ON public.grammar_progress_entries (user_id, unit_id);

-- ------------------------------------------------------------------------------
-- 5. EXAM PAPERS & SUBMISSIONS (Future Extensibility)
-- ------------------------------------------------------------------------------
-- Catalog Table (Public curriculum / official exam banks)
CREATE TABLE IF NOT EXISTS public.exam_papers (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    category TEXT NOT NULL, -- e.g. 'IELTS', 'TOEIC', 'JLPT', 'THPT'
    level TEXT NOT NULL,    -- e.g. 'B2', 'C1', 'N2'
    duration_minutes INT NOT NULL DEFAULT 60,
    total_questions INT NOT NULL DEFAULT 0,
    sections_json JSONB NOT NULL DEFAULT '[]'::JSONB,
    version INT NOT NULL DEFAULT 1,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_papers_category ON public.exam_papers (category, level) WHERE is_published = TRUE;

-- User Submissions (Personal test attempts & results)
CREATE TABLE IF NOT EXISTS public.exam_submissions (
    id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exam_paper_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL,
    score REAL NOT NULL DEFAULT 0.0,
    total_correct INT NOT NULL DEFAULT 0,
    answers_json JSONB NOT NULL DEFAULT '{}'::JSONB,
    wrong_answers_json JSONB NOT NULL DEFAULT '[]'::JSONB,

    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_exam_submissions PRIMARY KEY (id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_exam_submissions_user_hlc ON public.exam_submissions (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_exam_submissions_user_exam ON public.exam_submissions (user_id, exam_paper_id);
