-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 005 - EXAM BANK & SPARSE SYNC
-- Description: Public Exam catalog, Exam sections & questions, User exam submissions,
--              Wrong questions notebook, Sparse download RPC, Catalog RPC,
--              and full HLC batch synchronization.
-- Created At: 2026-09-16
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. PUBLIC EXAM PAPERS CATALOG UPDATE
-- ------------------------------------------------------------------------------
ALTER TABLE public.exam_papers ADD COLUMN IF NOT EXISTS passing_score INT NOT NULL DEFAULT 60;
ALTER TABLE public.exam_papers ADD COLUMN IF NOT EXISTS icon_name TEXT NOT NULL DEFAULT 'file-text';
ALTER TABLE public.exam_papers DROP COLUMN IF EXISTS sections_json;

-- ------------------------------------------------------------------------------
-- 2. PUBLIC EXAM SECTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.exam_sections (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL REFERENCES public.exam_papers(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    section_type TEXT NOT NULL DEFAULT 'general', -- 'general', 'language_knowledge', 'reading', 'listening'
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
CREATE INDEX IF NOT EXISTS idx_exam_questions_section_fk ON public.exam_questions (section_id);

-- ------------------------------------------------------------------------------
-- 4. USER EXAM SUBMISSIONS (Standardized to Match Drift SQLite Schema)
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.exam_submissions CASCADE;

CREATE TABLE public.exam_submissions (
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
CREATE INDEX IF NOT EXISTS idx_exam_submissions_exam_fk ON public.exam_submissions (exam_id);

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
CREATE INDEX IF NOT EXISTS idx_wrong_notebook_exam_fk ON public.wrong_question_notebook (exam_id);
CREATE INDEX IF NOT EXISTS idx_wrong_notebook_question_fk ON public.wrong_question_notebook (question_id);

-- ------------------------------------------------------------------------------
-- 6. COVERING INDEX FOR CARDS FOREIGN KEY
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_cards_deck_user_fk ON public.cards (deck_id, user_id);

-- ------------------------------------------------------------------------------
-- 7. ROW-LEVEL SECURITY (RLS) POLICIES
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

-- User Isolation for Exam Submissions (InitPlan optimized)
DROP POLICY IF EXISTS "User Isolation for Exam Submissions" ON public.exam_submissions;
CREATE POLICY "User Isolation for Exam Submissions" ON public.exam_submissions
    FOR ALL TO authenticated
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

-- User Isolation for Wrong Notebook (InitPlan optimized)
DROP POLICY IF EXISTS "User Isolation for Wrong Notebook" ON public.wrong_question_notebook;
CREATE POLICY "User Isolation for Wrong Notebook" ON public.wrong_question_notebook
    FOR ALL TO authenticated
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 8. CATALOG RPC: FETCH EXAM PAPERS CATALOG
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fetch_exam_catalog(
    p_category TEXT DEFAULT NULL,
    p_level TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(to_jsonb(p) ORDER BY p.created_at DESC), '[]'::jsonb)
    INTO v_result
    FROM public.exam_papers p
    WHERE p.is_published = TRUE
      AND (p_category IS NULL OR p.category = p_category)
      AND (p_level IS NULL OR p.level = p_level);

    RETURN v_result;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.fetch_exam_catalog(TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fetch_exam_catalog(TEXT, TEXT) TO anon, authenticated;

-- ------------------------------------------------------------------------------
-- 9. SPARSE SYNC RPC: DOWNLOAD FULL EXAM PAPER WITH SECTIONS AND QUESTIONS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.download_exam_paper(p_exam_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
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
        RAISE EXCEPTION 'Exam paper not found or unpublished: %', p_exam_id USING ERRCODE = 'P0002';
    END IF;

    SELECT COALESCE(jsonb_agg(to_jsonb(s) ORDER BY s.order_index ASC), '[]'::jsonb)
    INTO v_sections
    FROM public.exam_sections s
    WHERE s.exam_id = p_exam_id;

    SELECT COALESCE(jsonb_agg(to_jsonb(q) ORDER BY q.question_number ASC), '[]'::jsonb)
    INTO v_questions
    FROM public.exam_questions q
    WHERE q.exam_id = p_exam_id;

    RETURN jsonb_build_object(
        'paper', v_paper,
        'sections', v_sections,
        'questions', v_questions
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.download_exam_paper(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.download_exam_paper(TEXT) TO anon, authenticated;

-- ------------------------------------------------------------------------------
-- 10. UPDATED BATCH PUSH MUTATIONS (Adds wrong_question & matches exam_submission)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_push_mutations(mutations JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    mutation JSONB;
    entity_type TEXT;
    op TEXT;
    payload JSONB;
    item_hlc VARCHAR(64);
    processed_count INT := 0;
    rejected_count INT := 0;
    ack_ids JSONB := '[]'::JSONB;
BEGIN
    -- Verify caller authentication
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to push mutations' USING ERRCODE = '42501';
    END IF;

    -- Process each mutation in the batch within the ambient transaction
    FOR mutation IN SELECT * FROM jsonb_array_elements(mutations)
    LOOP
        entity_type := mutation->>'entity_type';
        op := mutation->>'op';
        payload := mutation->'payload';
        item_hlc := mutation->>'hlc';

        IF entity_type IS NULL OR payload IS NULL OR item_hlc IS NULL THEN
            rejected_count := rejected_count + 1;
            CONTINUE;
        END IF;

        -- 1. DECKS
        IF entity_type = 'deck' THEN
            INSERT INTO public.decks (
                id, user_id, title, description, due_count, new_count, total_count,
                last_studied, updated_at_hlc, is_deleted, created_at, updated_at
            ) VALUES (
                payload->>'id',
                current_user_id,
                COALESCE(payload->>'title', 'Untitled Deck'),
                COALESCE(payload->>'description', ''),
                COALESCE((payload->>'due_count')::INT, 0),
                COALESCE((payload->>'new_count')::INT, 0),
                COALESCE((payload->>'total_count')::INT, 0),
                (payload->>'last_studied')::TIMESTAMPTZ,
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW()),
                NOW()
            )
            ON CONFLICT (id, user_id) DO UPDATE SET
                title = EXCLUDED.title,
                description = EXCLUDED.description,
                due_count = EXCLUDED.due_count,
                new_count = EXCLUDED.new_count,
                total_count = EXCLUDED.total_count,
                last_studied = EXCLUDED.last_studied,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted,
                updated_at = NOW()
            WHERE EXCLUDED.updated_at_hlc > public.decks.updated_at_hlc;

        -- 2. CARDS
        ELSIF entity_type = 'card' THEN
            INSERT INTO public.cards (
                id, user_id, deck_id, front, back, hint, note_type, flag,
                is_suspended, is_buried, tags, interval_days, stability, difficulty,
                reps, lapses, due, last_studied, updated_at_hlc, is_deleted,
                created_at, updated_at
            ) VALUES (
                payload->>'id',
                current_user_id,
                payload->>'deck_id',
                COALESCE(payload->>'front', ''),
                COALESCE(payload->>'back', ''),
                payload->>'hint',
                COALESCE(payload->>'note_type', 'basic'),
                COALESCE((payload->>'flag')::INT, 0),
                COALESCE((payload->>'is_suspended')::BOOLEAN, FALSE),
                COALESCE((payload->>'is_buried')::BOOLEAN, FALSE),
                COALESCE(payload->>'tags', ''),
                COALESCE((payload->>'interval_days')::INT, 0),
                COALESCE((payload->>'stability')::REAL, 0.0),
                COALESCE((payload->>'difficulty')::REAL, 0.0),
                COALESCE((payload->>'reps')::INT, 0),
                COALESCE((payload->>'lapses')::INT, 0),
                (payload->>'due')::TIMESTAMPTZ,
                (payload->>'last_studied')::TIMESTAMPTZ,
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW()),
                NOW()
            )
            ON CONFLICT (id, user_id) DO UPDATE SET
                deck_id = EXCLUDED.deck_id,
                front = EXCLUDED.front,
                back = EXCLUDED.back,
                hint = EXCLUDED.hint,
                note_type = EXCLUDED.note_type,
                flag = EXCLUDED.flag,
                is_suspended = EXCLUDED.is_suspended,
                is_buried = EXCLUDED.is_buried,
                tags = EXCLUDED.tags,
                interval_days = EXCLUDED.interval_days,
                stability = EXCLUDED.stability,
                difficulty = EXCLUDED.difficulty,
                reps = EXCLUDED.reps,
                lapses = EXCLUDED.lapses,
                due = EXCLUDED.due,
                last_studied = EXCLUDED.last_studied,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted,
                updated_at = NOW()
            WHERE EXCLUDED.updated_at_hlc > public.cards.updated_at_hlc;

        -- 3. REVIEW LOGS (Append-Only Event Stream)
        ELSIF entity_type = 'review_log' THEN
            INSERT INTO public.review_logs (
                user_id, card_id, rating, review_time, scheduled_days,
                elapsed_days, client_log_id, created_at
            ) VALUES (
                current_user_id,
                payload->>'card_id',
                (payload->>'rating')::INT,
                (payload->>'review_time')::TIMESTAMPTZ,
                COALESCE((payload->>'scheduled_days')::INT, 0),
                COALESCE((payload->>'elapsed_days')::INT, 0),
                mutation->>'id', -- Client log id for idempotency
                NOW()
            )
            ON CONFLICT (user_id, client_log_id) DO NOTHING;

        -- 4. GRAMMAR PROGRESS ENTRIES
        ELSIF entity_type = 'grammar_progress' THEN
            INSERT INTO public.grammar_progress_entries (
                user_id, unit_id, exercise_id, stability, difficulty, due,
                last_studied, reps, lapses, state, is_ghost, is_completed,
                last_user_answer, updated_at_hlc, is_deleted, updated_at
            ) VALUES (
                current_user_id,
                payload->>'unit_id',
                payload->>'exercise_id',
                COALESCE((payload->>'stability')::REAL, 0.0),
                COALESCE((payload->>'difficulty')::REAL, 0.0),
                (payload->>'due')::TIMESTAMPTZ,
                (payload->>'last_studied')::TIMESTAMPTZ,
                COALESCE((payload->>'reps')::INT, 0),
                COALESCE((payload->>'lapses')::INT, 0),
                COALESCE((payload->>'state')::INT, 0),
                COALESCE((payload->>'is_ghost')::BOOLEAN, FALSE),
                COALESCE((payload->>'is_completed')::BOOLEAN, FALSE),
                payload->>'last_user_answer',
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                NOW()
            )
            ON CONFLICT (user_id, unit_id, exercise_id) DO UPDATE SET
                stability = EXCLUDED.stability,
                difficulty = EXCLUDED.difficulty,
                due = EXCLUDED.due,
                last_studied = EXCLUDED.last_studied,
                reps = EXCLUDED.reps,
                lapses = EXCLUDED.lapses,
                state = EXCLUDED.state,
                is_ghost = EXCLUDED.is_ghost,
                is_completed = EXCLUDED.is_completed,
                last_user_answer = EXCLUDED.last_user_answer,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted,
                updated_at = NOW()
            WHERE EXCLUDED.updated_at_hlc > public.grammar_progress_entries.updated_at_hlc;

        -- 5. EXAM SUBMISSIONS
        ELSIF entity_type = 'exam_submission' THEN
            INSERT INTO public.exam_submissions (
                id, user_id, exam_id, score, total_correct, total_questions,
                duration_seconds, answers_json, submitted_at, updated_at_hlc,
                is_deleted, created_at
            ) VALUES (
                payload->>'id',
                current_user_id,
                payload->>'exam_id',
                COALESCE((payload->>'score')::INT, 0),
                COALESCE((payload->>'total_correct')::INT, 0),
                COALESCE((payload->>'total_questions')::INT, 0),
                COALESCE((payload->>'duration_seconds')::INT, 0),
                COALESCE(payload->'answers_json', '{}'::JSONB),
                COALESCE((payload->>'submitted_at')::TIMESTAMPTZ, NOW()),
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                NOW()
            )
            ON CONFLICT (id, user_id) DO UPDATE SET
                score = EXCLUDED.score,
                total_correct = EXCLUDED.total_correct,
                total_questions = EXCLUDED.total_questions,
                duration_seconds = EXCLUDED.duration_seconds,
                answers_json = EXCLUDED.answers_json,
                submitted_at = EXCLUDED.submitted_at,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted
            WHERE EXCLUDED.updated_at_hlc > public.exam_submissions.updated_at_hlc;

        -- 6. WRONG QUESTION NOTEBOOK
        ELSIF entity_type = 'wrong_question' THEN
            IF EXISTS (SELECT 1 FROM public.wrong_question_notebook WHERE id = payload->>'id' AND user_id = current_user_id) THEN
                UPDATE public.wrong_question_notebook SET
                    status = COALESCE(payload->>'status', status),
                    notes = COALESCE(payload->>'notes', notes),
                    user_answer = COALESCE(payload->>'user_answer', user_answer),
                    explanation = COALESCE(payload->>'explanation', explanation),
                    updated_at_hlc = item_hlc,
                    is_deleted = COALESCE((mutation->>'is_deleted')::BOOLEAN, is_deleted),
                    updated_at = NOW()
                WHERE id = payload->>'id' AND user_id = current_user_id
                  AND item_hlc > updated_at_hlc;
            ELSE
                IF payload->>'exam_id' IS NOT NULL AND payload->>'question_id' IS NOT NULL THEN
                    INSERT INTO public.wrong_question_notebook (
                        id, user_id, exam_id, question_id, user_answer, explanation,
                        notes, status, updated_at_hlc, is_deleted, created_at, updated_at
                    ) VALUES (
                        payload->>'id',
                        current_user_id,
                        payload->>'exam_id',
                        payload->>'question_id',
                        COALESCE(payload->>'user_answer', ''),
                        COALESCE(payload->>'explanation', ''),
                        COALESCE(payload->>'notes', ''),
                        COALESCE(payload->>'status', 'new'),
                        item_hlc,
                        COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                        COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW()),
                        NOW()
                    )
                    ON CONFLICT (id, user_id) DO UPDATE SET
                        status = EXCLUDED.status,
                        notes = EXCLUDED.notes,
                        user_answer = EXCLUDED.user_answer,
                        explanation = EXCLUDED.explanation,
                        updated_at_hlc = EXCLUDED.updated_at_hlc,
                        is_deleted = EXCLUDED.is_deleted,
                        updated_at = NOW()
                    WHERE EXCLUDED.updated_at_hlc > public.wrong_question_notebook.updated_at_hlc;
                ELSE
                    rejected_count := rejected_count + 1;
                    CONTINUE;
                END IF;
            END IF;

        ELSE
            rejected_count := rejected_count + 1;
            CONTINUE;
        END IF;

        processed_count := processed_count + 1;
        ack_ids := ack_ids || jsonb_build_array(mutation->>'id');
    END LOOP;

    RETURN jsonb_build_object(
        'processed_count', processed_count,
        'rejected_count', rejected_count,
        'ack_ids', ack_ids,
        'server_timestamp', NOW()
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.sync_push_mutations(JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_push_mutations(JSONB) TO authenticated;

-- ------------------------------------------------------------------------------
-- 11. UPDATED BATCH PULL DELTAS (Adds wrong_questions)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_pull_deltas(
    cursors JSONB,
    batch_limit INT DEFAULT 500
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    deck_cursor TEXT := COALESCE(cursors->>'deck', '');
    card_cursor TEXT := COALESCE(cursors->>'card', '');
    grammar_cursor TEXT := COALESCE(cursors->>'grammar_progress', '');
    revlog_cursor TIMESTAMPTZ := COALESCE((cursors->>'review_log')::TIMESTAMPTZ, '1970-01-01 00:00:00+00'::TIMESTAMPTZ);
    exam_cursor TEXT := COALESCE(cursors->>'exam_submission', '');
    wrong_cursor TEXT := COALESCE(cursors->>'wrong_question', '');
    
    decks_data JSONB := '[]'::JSONB;
    cards_data JSONB := '[]'::JSONB;
    grammar_data JSONB := '[]'::JSONB;
    revlogs_data JSONB := '[]'::JSONB;
    exams_data JSONB := '[]'::JSONB;
    wrongs_data JSONB := '[]'::JSONB;
BEGIN
    -- Verify caller authentication
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to pull deltas' USING ERRCODE = '42501';
    END IF;

    -- Clamp batch limit to prevent resource exhaustion
    IF batch_limit > 1000 THEN
        batch_limit := 1000;
    ELSIF batch_limit < 1 THEN
        batch_limit := 100;
    END IF;

    -- Decks delta
    SELECT COALESCE(jsonb_agg(to_jsonb(d)), '[]'::JSONB)
    INTO decks_data
    FROM (
        SELECT * FROM public.decks
        WHERE user_id = current_user_id AND updated_at_hlc > deck_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) d;

    -- Cards delta
    SELECT COALESCE(jsonb_agg(to_jsonb(c)), '[]'::JSONB)
    INTO cards_data
    FROM (
        SELECT * FROM public.cards
        WHERE user_id = current_user_id AND updated_at_hlc > card_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) c;

    -- Grammar progress delta
    SELECT COALESCE(jsonb_agg(to_jsonb(g)), '[]'::JSONB)
    INTO grammar_data
    FROM (
        SELECT * FROM public.grammar_progress_entries
        WHERE user_id = current_user_id AND updated_at_hlc > grammar_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) g;

    -- Review logs delta
    SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::JSONB)
    INTO revlogs_data
    FROM (
        SELECT * FROM public.review_logs
        WHERE user_id = current_user_id AND review_time > revlog_cursor
        ORDER BY review_time ASC
        LIMIT batch_limit
    ) r;

    -- Exam submissions delta
    SELECT COALESCE(jsonb_agg(to_jsonb(e)), '[]'::JSONB)
    INTO exams_data
    FROM (
        SELECT * FROM public.exam_submissions
        WHERE user_id = current_user_id AND updated_at_hlc > exam_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) e;

    -- Wrong questions notebook delta
    SELECT COALESCE(jsonb_agg(to_jsonb(w)), '[]'::JSONB)
    INTO wrongs_data
    FROM (
        SELECT * FROM public.wrong_question_notebook
        WHERE user_id = current_user_id AND updated_at_hlc > wrong_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) w;

    RETURN jsonb_build_object(
        'decks', decks_data,
        'cards', cards_data,
        'grammar_progress', grammar_data,
        'review_logs', revlogs_data,
        'exam_submissions', exams_data,
        'wrong_questions', wrongs_data,
        'server_timestamp', NOW()
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.sync_pull_deltas(JSONB, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_pull_deltas(JSONB, INT) TO authenticated;
