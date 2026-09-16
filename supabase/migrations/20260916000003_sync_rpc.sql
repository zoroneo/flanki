-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 003 - SYNC RPC PROCEDURES
-- Description: High-performance transactional batch sync functions with HLC LWW
-- Created At: 2026-09-16
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. BATCH PUSH MUTATIONS (Transactional Upsert with HLC Last-Write-Wins)
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
                id, user_id, exam_paper_id, started_at, submitted_at, score,
                total_correct, answers_json, wrong_answers_json, updated_at_hlc,
                is_deleted, created_at
            ) VALUES (
                payload->>'id',
                current_user_id,
                payload->>'exam_paper_id',
                (payload->>'started_at')::TIMESTAMPTZ,
                (payload->>'submitted_at')::TIMESTAMPTZ,
                COALESCE((payload->>'score')::REAL, 0.0),
                COALESCE((payload->>'total_correct')::INT, 0),
                COALESCE(payload->'answers_json', '{}'::JSONB),
                COALESCE(payload->'wrong_answers_json', '[]'::JSONB),
                item_hlc,
                COALESCE((mutation->>'is_deleted')::BOOLEAN, FALSE),
                NOW()
            )
            ON CONFLICT (id, user_id) DO UPDATE SET
                score = EXCLUDED.score,
                total_correct = EXCLUDED.total_correct,
                answers_json = EXCLUDED.answers_json,
                wrong_answers_json = EXCLUDED.wrong_answers_json,
                updated_at_hlc = EXCLUDED.updated_at_hlc,
                is_deleted = EXCLUDED.is_deleted
            WHERE EXCLUDED.updated_at_hlc > public.exam_submissions.updated_at_hlc;

        ELSE
            rejected_count := rejected_count + 1;
            CONTINUE;
        END IF;

        processed_count := processed_count + 1;
        ack_ids := ack_ids || jsonb_build_array(mutation->>'id');
    END LOOP;

    RETURN jsonb_build_object(
        'status', 'success',
        'processed_count', processed_count,
        'rejected_count', rejected_count,
        'ack_ids', ack_ids,
        'server_timestamp', NOW()
    );
END;
$$;

-- ------------------------------------------------------------------------------
-- 2. BATCH PULL DELTAS (Fetch items newer than client cursors)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sync_pull_deltas(
    cursors JSONB,
    batch_limit INT DEFAULT 500
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    current_user_id UUID := auth.uid();
    deck_cursor VARCHAR(64) := COALESCE(cursors->>'deck', '');
    card_cursor VARCHAR(64) := COALESCE(cursors->>'card', '');
    grammar_cursor VARCHAR(64) := COALESCE(cursors->>'grammar_progress', '');
    revlog_cursor TIMESTAMPTZ := COALESCE((cursors->>'review_log')::TIMESTAMPTZ, '1970-01-01'::TIMESTAMPTZ);
    exam_cursor VARCHAR(64) := COALESCE(cursors->>'exam_submission', '');

    decks_data JSONB;
    cards_data JSONB;
    grammar_data JSONB;
    revlogs_data JSONB;
    exams_data JSONB;
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to pull deltas' USING ERRCODE = '42501';
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

    -- Review logs delta (new review logs since last review_time)
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

    RETURN jsonb_build_object(
        'decks', decks_data,
        'cards', cards_data,
        'grammar_progress', grammar_data,
        'review_logs', revlogs_data,
        'exam_submissions', exams_data,
        'server_timestamp', NOW()
    );
END;
$$;
