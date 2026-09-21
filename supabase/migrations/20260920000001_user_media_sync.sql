-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 007 - USER MEDIA SYNC
-- Description: User media manifest table, RLS policies, and sync RPC updates
-- Created At: 2026-09-20
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. USER MEDIA TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_media (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    filename TEXT NOT NULL,
    hash_sha256 VARCHAR(64) NOT NULL DEFAULT '',
    size_bytes BIGINT NOT NULL DEFAULT 0,
    mime_type TEXT NOT NULL DEFAULT 'application/octet-stream',
    
    -- Sync Metadata Columns
    updated_at_hlc VARCHAR(64) NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_user_media PRIMARY KEY (user_id, filename)
);

CREATE INDEX IF NOT EXISTS idx_user_media_user_hlc ON public.user_media (user_id, updated_at_hlc);
CREATE INDEX IF NOT EXISTS idx_user_media_active ON public.user_media (user_id) WHERE is_deleted = FALSE;

-- ------------------------------------------------------------------------------
-- 2. ROW LEVEL SECURITY
-- ------------------------------------------------------------------------------
ALTER TABLE public.user_media ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own media records" ON public.user_media;
CREATE POLICY "Users can view own media records"
    ON public.user_media FOR SELECT
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert own media records" ON public.user_media;
CREATE POLICY "Users can insert own media records"
    ON public.user_media FOR INSERT
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update own media records" ON public.user_media;
CREATE POLICY "Users can update own media records"
    ON public.user_media FOR UPDATE
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete own media records" ON public.user_media;
CREATE POLICY "Users can delete own media records"
    ON public.user_media FOR DELETE
    USING ((select auth.uid()) = user_id);

-- ------------------------------------------------------------------------------
-- 3. UPDATE SYNC_PUSH_MUTATIONS (Add user_media)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_push_mutations(mutations JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    mutation JSONB;
    entity_type TEXT;
    payload JSONB;
    item_hlc VARCHAR(64);
    processed_count INT := 0;
    rejected_count INT := 0;
    ack_ids JSONB := '[]'::JSONB;
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to push mutations' USING ERRCODE = '42501';
    END IF;

    FOR mutation IN SELECT * FROM jsonb_array_elements(mutations)
    LOOP
        entity_type := mutation->>'entity_type';
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

        -- 3. REVIEW LOGS
        ELSIF entity_type = 'review_log' THEN
            INSERT INTO public.review_logs (
                user_id, card_id, rating, review_time, scheduled_days,
                elapsed_days, client_log_id, created_at
            ) VALUES (
                current_user_id,
                payload->>'card_id',
                COALESCE((payload->>'rating')::INT, 1),
                COALESCE((payload->>'review_time')::TIMESTAMPTZ, NOW()),
                COALESCE((payload->>'scheduled_days')::INT, 0),
                COALESCE((payload->>'elapsed_days')::INT, 0),
                payload->>'client_log_id',
                COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW())
            )
            ON CONFLICT (user_id, client_log_id) DO NOTHING;

        -- 4. GRAMMAR PROGRESS ENTRIES
        ELSIF entity_type = 'grammar_progress' THEN
            INSERT INTO public.grammar_progress_entries (
                user_id, unit_id, exercise_id, stability, difficulty,
                reps, lapses, last_studied, next_review, updated_at_hlc,
                is_deleted, created_at, updated_at
            ) VALUES (
                current_user_id,
                payload->>'unit_id',
                payload->>'exercise_id',
                COALESCE((payload->>'stability')::REAL, 0.0),
                COALESCE((payload->>'difficulty')::REAL, 0.0),
                COALESCE((payload->>'reps')::INT, 0),
                COALESCE((payload->>'lapses')::INT, 0),
                (payload->>'last_studied')::TIMESTAMPTZ,
                (payload->>'next_review')::TIMESTAMPTZ,
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW()),
                NOW()
            )
            ON CONFLICT (user_id, unit_id, exercise_id) DO UPDATE SET
                stability = EXCLUDED.stability,
                difficulty = EXCLUDED.difficulty,
                reps = EXCLUDED.reps,
                lapses = EXCLUDED.lapses,
                last_studied = EXCLUDED.last_studied,
                next_review = EXCLUDED.next_review,
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

        -- 7. USER MEDIA MANIFEST
        ELSIF entity_type = 'user_media' THEN
            INSERT INTO public.user_media (
                user_id, filename, hash_sha256, size_bytes, mime_type,
                updated_at_hlc, is_deleted, created_at, updated_at
            ) VALUES (
                current_user_id,
                payload->>'filename',
                COALESCE(payload->>'hash_sha256', ''),
                COALESCE((payload->>'size_bytes')::BIGINT, 0),
                COALESCE(payload->>'mime_type', 'application/octet-stream'),
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                COALESCE((payload->>'created_at')::TIMESTAMPTZ, NOW()),
                NOW()
            )
            ON CONFLICT (user_id, filename) DO UPDATE SET
                hash_sha256 = EXCLUDED.hash_sha256,
                size_bytes = EXCLUDED.size_bytes,
                mime_type = EXCLUDED.mime_type,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted,
                updated_at = NOW()
            WHERE EXCLUDED.updated_at_hlc > public.user_media.updated_at_hlc;

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
-- 4. UPDATE SYNC_PULL_DELTAS (Add user_media)
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
    media_cursor TEXT := COALESCE(cursors->>'user_media', '');
    
    decks_data JSONB := '[]'::JSONB;
    cards_data JSONB := '[]'::JSONB;
    grammar_data JSONB := '[]'::JSONB;
    revlogs_data JSONB := '[]'::JSONB;
    exams_data JSONB := '[]'::JSONB;
    wrongs_data JSONB := '[]'::JSONB;
    media_data JSONB := '[]'::JSONB;
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to pull deltas' USING ERRCODE = '42501';
    END IF;

    IF batch_limit > 1000 THEN
        batch_limit := 1000;
    ELSIF batch_limit < 1 THEN
        batch_limit := 100;
    END IF;

    -- 1. Decks delta
    SELECT COALESCE(jsonb_agg(to_jsonb(d)), '[]'::JSONB)
    INTO decks_data
    FROM (
        SELECT * FROM public.decks
        WHERE user_id = current_user_id AND updated_at_hlc > deck_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) d;

    -- 2. Cards delta
    SELECT COALESCE(jsonb_agg(to_jsonb(c)), '[]'::JSONB)
    INTO cards_data
    FROM (
        SELECT * FROM public.cards
        WHERE user_id = current_user_id AND updated_at_hlc > card_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) c;

    -- 3. Review Logs delta
    SELECT COALESCE(jsonb_agg(to_jsonb(r)), '[]'::JSONB)
    INTO revlogs_data
    FROM (
        SELECT * FROM public.review_logs
        WHERE user_id = current_user_id AND review_time > revlog_cursor
        ORDER BY review_time ASC
        LIMIT batch_limit
    ) r;

    -- 4. Grammar Progress delta
    SELECT COALESCE(jsonb_agg(to_jsonb(g)), '[]'::JSONB)
    INTO grammar_data
    FROM (
        SELECT * FROM public.grammar_progress_entries
        WHERE user_id = current_user_id AND updated_at_hlc > grammar_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) g;

    -- 5. Exam Submissions delta
    SELECT COALESCE(jsonb_agg(to_jsonb(e)), '[]'::JSONB)
    INTO exams_data
    FROM (
        SELECT * FROM public.exam_submissions
        WHERE user_id = current_user_id AND updated_at_hlc > exam_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) e;

    -- 6. Wrong Questions delta
    SELECT COALESCE(jsonb_agg(to_jsonb(w)), '[]'::JSONB)
    INTO wrongs_data
    FROM (
        SELECT * FROM public.wrong_question_notebook
        WHERE user_id = current_user_id AND updated_at_hlc > wrong_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) w;

    -- 7. User Media delta
    SELECT COALESCE(jsonb_agg(to_jsonb(m)), '[]'::JSONB)
    INTO media_data
    FROM (
        SELECT * FROM public.user_media
        WHERE user_id = current_user_id AND updated_at_hlc > media_cursor
        ORDER BY updated_at_hlc ASC
        LIMIT batch_limit
    ) m;

    RETURN jsonb_build_object(
        'decks', decks_data,
        'cards', cards_data,
        'review_logs', revlogs_data,
        'grammar_progress', grammar_data,
        'exam_submissions', exams_data,
        'wrong_questions', wrongs_data,
        'user_media', media_data,
        'server_timestamp', NOW()
    );
END;
$$;

REVOKE EXECUTE ON FUNCTION public.sync_pull_deltas(JSONB, INT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_pull_deltas(JSONB, INT) TO authenticated;
