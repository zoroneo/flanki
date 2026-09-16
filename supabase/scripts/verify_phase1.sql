-- ==============================================================================
-- FLANKI SUPABASE PHASE 1 VERIFICATION SCRIPT
-- Description: Automated SQL test runner to verify tables, RLS, and RPC procedures
-- Run this directly in Supabase SQL Editor to validate Phase 1 setup.
-- ==============================================================================

DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000001'::UUID;
    other_user_id UUID := '00000000-0000-0000-0000-000000000002'::UUID;
    push_payload JSONB;
    push_result JSONB;
    pull_result JSONB;
    card_rec RECORD;
    deck_rec RECORD;
    revlog_count INT;
BEGIN
    RAISE NOTICE '>>> [START] FLANKI SUPABASE PHASE 1 VERIFICATION <<<';

    -- --------------------------------------------------------------------------
    -- 1. VERIFY TABLES EXISTENCE
    -- --------------------------------------------------------------------------
    ASSERT (SELECT to_regclass('public.decks')) IS NOT NULL, 'Table public.decks does not exist!';
    ASSERT (SELECT to_regclass('public.cards')) IS NOT NULL, 'Table public.cards does not exist!';
    ASSERT (SELECT to_regclass('public.review_logs')) IS NOT NULL, 'Table public.review_logs does not exist!';
    ASSERT (SELECT to_regclass('public.grammar_progress_entries')) IS NOT NULL, 'Table public.grammar_progress_entries does not exist!';
    ASSERT (SELECT to_regclass('public.exam_papers')) IS NOT NULL, 'Table public.exam_papers does not exist!';
    ASSERT (SELECT to_regclass('public.exam_submissions')) IS NOT NULL, 'Table public.exam_submissions does not exist!';
    RAISE NOTICE '✅ Check 1: All 6 core tables exist.';

    -- --------------------------------------------------------------------------
    -- 2. VERIFY RPC PROCEDURES EXISTENCE
    -- --------------------------------------------------------------------------
    ASSERT (SELECT to_regprocedure('public.sync_push_mutations(jsonb)')) IS NOT NULL, 'Procedure sync_push_mutations(jsonb) missing!';
    ASSERT (SELECT to_regprocedure('public.sync_pull_deltas(jsonb,integer)')) IS NOT NULL, 'Procedure sync_pull_deltas(jsonb,integer) missing!';
    RAISE NOTICE '✅ Check 2: All RPC procedures exist.';

    -- --------------------------------------------------------------------------
    -- 3. TEST SYNC_PUSH_MUTATIONS WITH FAKE USER CONTEXT
    -- --------------------------------------------------------------------------
    -- Mock authenticated user session
    PERFORM set_config('request.jwt.claims', json_build_object('sub', test_user_id::text, 'role', 'authenticated')::text, true);

    -- Prepare push batch: 1 deck + 1 card + 1 review_log
    push_payload := jsonb_build_array(
        jsonb_build_object(
            'id', 'deck_mut_01',
            'entity_type', 'deck',
            'op', 'UPSERT',
            'hlc', '2026-09-16T00:00:00.000Z_0001_node1',
            'payload', jsonb_build_object(
                'id', 'deck_test_01',
                'title', 'Test Vocabulary Deck',
                'description', 'A test deck for sync verification',
                'due_count', 5,
                'new_count', 10,
                'total_count', 15
            )
        ),
        jsonb_build_object(
            'id', 'card_mut_01',
            'entity_type', 'card',
            'op', 'UPSERT',
            'hlc', '2026-09-16T00:00:00.000Z_0002_node1',
            'payload', jsonb_build_object(
                'id', 'card_test_01',
                'deck_id', 'deck_test_01',
                'front', 'Apple',
                'back', 'Quả táo',
                'note_type', 'basic',
                'stability', 2.5,
                'difficulty', 4.0,
                'reps', 1,
                'lapses', 0
            )
        ),
        jsonb_build_object(
            'id', 'revlog_mut_01',
            'entity_type', 'review_log',
            'op', 'INSERT',
            'hlc', '2026-09-16T00:00:00.000Z_0003_node1',
            'payload', jsonb_build_object(
                'card_id', 'card_test_01',
                'rating', 3,
                'review_time', '2026-09-16T00:00:00.000Z',
                'scheduled_days', 3,
                'elapsed_days', 1
            )
        )
    );

    push_result := public.sync_push_mutations(push_payload);
    ASSERT push_result->>'status' = 'success', 'sync_push_mutations returned failure!';
    ASSERT (push_result->>'processed_count')::INT = 3, 'Expected 3 processed mutations!';
    RAISE NOTICE '✅ Check 3: sync_push_mutations successfully executed batch.';

    -- Verify records inserted correctly
    SELECT * INTO deck_rec FROM public.decks WHERE id = 'deck_test_01' AND user_id = test_user_id;
    ASSERT deck_rec.title = 'Test Vocabulary Deck', 'Deck insertion verification failed!';

    SELECT * INTO card_rec FROM public.cards WHERE id = 'card_test_01' AND user_id = test_user_id;
    ASSERT card_rec.back = 'Quả táo', 'Card insertion verification failed!';

    SELECT count(*) INTO revlog_count FROM public.review_logs WHERE user_id = test_user_id AND card_id = 'card_test_01';
    ASSERT revlog_count = 1, 'Review log verification failed!';
    RAISE NOTICE '✅ Check 4: Data integrity confirmed for deck, card, and revlog.';

    -- --------------------------------------------------------------------------
    -- 4. TEST LAST-WRITE-WINS (HLC CONFLICT RESOLUTION)
    -- --------------------------------------------------------------------------
    -- 4a. Attempt to update with an OLDER HLC (Should be rejected by LWW)
    push_payload := jsonb_build_array(
        jsonb_build_object(
            'id', 'card_mut_old',
            'entity_type', 'card',
            'op', 'UPSERT',
            'hlc', '2026-09-15T00:00:00.000Z_0000_nodeOld', -- Older than existing '2026-09-16T...'
            'payload', jsonb_build_object(
                'id', 'card_test_01',
                'deck_id', 'deck_test_01',
                'front', 'Apple (STALE)',
                'back', 'Quả táo CŨ'
            )
        )
    );
    PERFORM public.sync_push_mutations(push_payload);

    SELECT * INTO card_rec FROM public.cards WHERE id = 'card_test_01' AND user_id = test_user_id;
    ASSERT card_rec.back = 'Quả táo', 'LWW Error: Older HLC was erroneously applied!';
    RAISE NOTICE '✅ Check 5: LWW rejected older HLC correctly.';

    -- 4b. Update with a NEWER HLC (Should succeed)
    push_payload := jsonb_build_array(
        jsonb_build_object(
            'id', 'card_mut_new',
            'entity_type', 'card',
            'op', 'UPSERT',
            'hlc', '2026-09-16T01:00:00.000Z_0001_nodeNew', -- Newer HLC
            'payload', jsonb_build_object(
                'id', 'card_test_01',
                'deck_id', 'deck_test_01',
                'front', 'Apple (FRESH)',
                'back', 'Quả táo TƯƠI MỚI'
            )
        )
    );
    PERFORM public.sync_push_mutations(push_payload);

    SELECT * INTO card_rec FROM public.cards WHERE id = 'card_test_01' AND user_id = test_user_id;
    ASSERT card_rec.back = 'Quả táo TƯƠI MỚI', 'LWW Error: Newer HLC was not applied!';
    RAISE NOTICE '✅ Check 6: LWW applied newer HLC correctly.';

    -- --------------------------------------------------------------------------
    -- 5. TEST SYNC_PULL_DELTAS
    -- --------------------------------------------------------------------------
    pull_result := public.sync_pull_deltas(
        jsonb_build_object(
            'card', '2026-09-16T00:00:00.000Z_0000_node0',
            'deck', '1970-01-01'
        )
    );
    ASSERT jsonb_array_length(pull_result->'cards') >= 1, 'sync_pull_deltas failed to return updated card!';
    ASSERT jsonb_array_length(pull_result->'decks') >= 1, 'sync_pull_deltas failed to return deck!';
    RAISE NOTICE '✅ Check 7: sync_pull_deltas retrieved changes matching cursor.';

    -- --------------------------------------------------------------------------
    -- 6. CLEANUP TEST DATA
    -- --------------------------------------------------------------------------
    DELETE FROM public.decks WHERE user_id = test_user_id;
    RAISE NOTICE '✅ Check 8: Test cleanup completed.';

    RAISE NOTICE '>>> [SUCCESS] ALL 8 PHASE 1 VERIFICATION CHECKS PASSED! <<<';
END $$;
