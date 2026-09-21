-- ==============================================================================
-- Migration: 20260920000003_selective_sync_and_backups.sql
-- Description: Adds is_sync_enabled to decks, creates flanki_backups storage bucket,
--              and adds get_cloud_storage_stats RPC function.
-- ==============================================================================

-- 1. Add is_sync_enabled column to public.decks
ALTER TABLE public.decks
ADD COLUMN IF NOT EXISTS is_sync_enabled BOOLEAN DEFAULT true;

-- 2. Update sync_pull_deltas to include is_sync_enabled
CREATE OR REPLACE FUNCTION public.sync_pull_deltas(
  cursors JSONB,
  batch_limit INT DEFAULT 500
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_deck_cursor TEXT := COALESCE(cursors->>'deck', '');
  v_card_cursor TEXT := COALESCE(cursors->>'card', '');
  v_revlog_cursor TEXT := COALESCE(cursors->>'review_log', '1970-01-01T00:00:00.000Z');
  v_grammar_cursor TEXT := COALESCE(cursors->>'grammar_progress', '');
  v_exam_cursor TEXT := COALESCE(cursors->>'exam_submission', '');
  v_wrong_cursor TEXT := COALESCE(cursors->>'wrong_question', '');
  v_media_cursor TEXT := COALESCE(cursors->>'user_media', '');

  v_decks JSONB;
  v_cards JSONB;
  v_revlogs JSONB;
  v_grammar JSONB;
  v_exams JSONB;
  v_wrongs JSONB;
  v_media JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- 1. Pull Decks
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_decks
  FROM (
    SELECT id, title, description, due_count, new_count, total_count,
           last_studied, updated_at_hlc, is_deleted, is_sync_enabled
    FROM public.decks
    WHERE user_id = v_user_id
      AND updated_at_hlc > v_deck_cursor
    ORDER BY updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  -- 2. Pull Cards (only for decks with sync enabled or tombstones)
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_cards
  FROM (
    SELECT c.id, c.deck_id, c.front, c.back, c.hint, c.note_type, c.flag,
           c.is_suspended, c.is_buried, c.tags, c.interval_days, c.stability,
           c.difficulty, c.lapses, c.reps, c.due, c.last_reviewed,
           c.updated_at_hlc, c.is_deleted
    FROM public.cards c
    LEFT JOIN public.decks d ON d.id = c.deck_id AND d.user_id = v_user_id
    WHERE c.user_id = v_user_id
      AND c.updated_at_hlc > v_card_cursor
      AND (c.is_deleted = true OR d.is_sync_enabled IS NULL OR d.is_sync_enabled = true)
    ORDER BY c.updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  -- 3. Pull Review Logs
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_revlogs
  FROM (
    SELECT id, client_log_id, card_id, rating, review_time,
           interval_days, last_interval, elapsed_days, time_spent_ms
    FROM public.review_logs
    WHERE user_id = v_user_id
      AND review_time > v_revlog_cursor::timestamptz
    ORDER BY review_time ASC
    LIMIT batch_limit
  ) t;

  -- 4. Pull Grammar Progress
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_grammar
  FROM (
    SELECT id, unit_id, is_completed, score, mastery_level,
           completed_at, updated_at_hlc, is_deleted
    FROM public.grammar_progress
    WHERE user_id = v_user_id
      AND updated_at_hlc > v_grammar_cursor
    ORDER BY updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  -- 5. Pull Exam Submissions
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_exams
  FROM (
    SELECT id, exam_id, score, raw_score, total_questions, time_spent_seconds,
           submitted_at, answers, section_scores, updated_at_hlc, is_deleted
    FROM public.exam_submissions
    WHERE user_id = v_user_id
      AND updated_at_hlc > v_exam_cursor
    ORDER BY updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  -- 6. Pull Wrong Question Notebook
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_wrongs
  FROM (
    SELECT id, question_id, exam_id, user_answer, correct_answer, notes,
           mastered, review_count, updated_at_hlc, is_deleted
    FROM public.wrong_question_notebook
    WHERE user_id = v_user_id
      AND updated_at_hlc > v_wrong_cursor
    ORDER BY updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  -- 7. Pull User Media
  SELECT COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  INTO v_media
  FROM (
    SELECT id, filename, hash_sha256, size_bytes, mime_type,
           updated_at_hlc, is_deleted
    FROM public.user_media
    WHERE user_id = v_user_id
      AND updated_at_hlc > v_media_cursor
    ORDER BY updated_at_hlc ASC
    LIMIT batch_limit
  ) t;

  RETURN jsonb_build_object(
    'decks', v_decks,
    'cards', v_cards,
    'review_logs', v_revlogs,
    'grammar_progress', v_grammar,
    'exam_submissions', v_exams,
    'wrong_questions', v_wrongs,
    'user_media', v_media,
    'server_timestamp', now()
  );
END;
$$;

-- 3. Update sync_push_mutations to handle is_sync_enabled on decks
CREATE OR REPLACE FUNCTION public.sync_push_mutations(
  mutations JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_item JSONB;
  v_ack_ids JSONB := '[]'::jsonb;
  v_processed_count INT := 0;
  v_entity_type TEXT;
  v_op TEXT;
  v_payload JSONB;
  v_hlc TEXT;
  v_is_deleted BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  FOR v_item IN SELECT * FROM jsonb_array_elements(mutations)
  LOOP
    v_entity_type := v_item->>'entity_type';
    v_op := v_item->>'op';
    v_payload := v_item->'payload';
    v_hlc := v_item->>'hlc';
    v_is_deleted := COALESCE((v_item->>'is_deleted')::boolean, false);

    IF v_entity_type = 'deck' THEN
      INSERT INTO public.decks (
        id, user_id, title, description, due_count, new_count, total_count,
        last_studied, updated_at_hlc, is_deleted, is_sync_enabled
      ) VALUES (
        v_payload->>'id',
        v_user_id,
        COALESCE(v_payload->>'title', 'Untitled Deck'),
        COALESCE(v_payload->>'description', ''),
        COALESCE((v_payload->>'due_count')::int, 0),
        COALESCE((v_payload->>'new_count')::int, 0),
        COALESCE((v_payload->>'total_count')::int, 0),
        (v_payload->>'last_studied')::timestamptz,
        v_hlc,
        v_is_deleted,
        COALESCE((v_payload->>'is_sync_enabled')::boolean, true)
      )
      ON CONFLICT (id) DO UPDATE
      SET title = EXCLUDED.title,
          description = EXCLUDED.description,
          due_count = EXCLUDED.due_count,
          new_count = EXCLUDED.new_count,
          total_count = EXCLUDED.total_count,
          last_studied = EXCLUDED.last_studied,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted,
          is_sync_enabled = EXCLUDED.is_sync_enabled
      WHERE public.decks.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.decks.updated_at_hlc;

    ELSIF v_entity_type = 'card' THEN
      INSERT INTO public.cards (
        id, user_id, deck_id, front, back, hint, note_type, flag,
        is_suspended, is_buried, tags, interval_days, stability, difficulty,
        lapses, reps, due, last_reviewed, updated_at_hlc, is_deleted
      ) VALUES (
        v_payload->>'id',
        v_user_id,
        v_payload->>'deck_id',
        COALESCE(v_payload->>'front', ''),
        COALESCE(v_payload->>'back', ''),
        v_payload->>'hint',
        COALESCE(v_payload->>'note_type', 'basic'),
        COALESCE((v_payload->>'flag')::int, 0),
        COALESCE((v_payload->>'is_suspended')::boolean, false),
        COALESCE((v_payload->>'is_buried')::boolean, false),
        COALESCE(v_payload->>'tags', ''),
        COALESCE((v_payload->>'interval_days')::int, 0),
        COALESCE((v_payload->>'stability')::double precision, 0.0),
        COALESCE((v_payload->>'difficulty')::double precision, 0.0),
        COALESCE((v_payload->>'lapses')::int, 0),
        COALESCE((v_payload->>'reps')::int, 0),
        (v_payload->>'due')::timestamptz,
        (v_payload->>'last_reviewed')::timestamptz,
        v_hlc,
        v_is_deleted
      )
      ON CONFLICT (id) DO UPDATE
      SET deck_id = EXCLUDED.deck_id,
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
          lapses = EXCLUDED.lapses,
          reps = EXCLUDED.reps,
          due = EXCLUDED.due,
          last_reviewed = EXCLUDED.last_reviewed,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted
      WHERE public.cards.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.cards.updated_at_hlc;

    ELSIF v_entity_type = 'review_log' THEN
      INSERT INTO public.review_logs (
        id, user_id, client_log_id, card_id, rating, review_time,
        interval_days, last_interval, elapsed_days, time_spent_ms
      ) VALUES (
        COALESCE(v_payload->>'id', gen_random_uuid()::text),
        v_user_id,
        v_payload->>'client_log_id',
        v_payload->>'card_id',
        COALESCE((v_payload->>'rating')::int, 1),
        COALESCE((v_payload->>'review_time')::timestamptz, now()),
        COALESCE((v_payload->>'interval_days')::int, 0),
        COALESCE((v_payload->>'last_interval')::int, 0),
        COALESCE((v_payload->>'elapsed_days')::int, 0),
        COALESCE((v_payload->>'time_spent_ms')::int, 0)
      )
      ON CONFLICT (id) DO NOTHING;

    ELSIF v_entity_type = 'grammar_progress' THEN
      INSERT INTO public.grammar_progress (
        id, user_id, unit_id, is_completed, score, mastery_level,
        completed_at, updated_at_hlc, is_deleted
      ) VALUES (
        v_payload->>'id',
        v_user_id,
        v_payload->>'unit_id',
        COALESCE((v_payload->>'is_completed')::boolean, false),
        COALESCE((v_payload->>'score')::double precision, 0.0),
        COALESCE((v_payload->>'mastery_level')::int, 0),
        (v_payload->>'completed_at')::timestamptz,
        v_hlc,
        v_is_deleted
      )
      ON CONFLICT (id) DO UPDATE
      SET is_completed = EXCLUDED.is_completed,
          score = EXCLUDED.score,
          mastery_level = EXCLUDED.mastery_level,
          completed_at = EXCLUDED.completed_at,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted
      WHERE public.grammar_progress.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.grammar_progress.updated_at_hlc;

    ELSIF v_entity_type = 'exam_submission' THEN
      INSERT INTO public.exam_submissions (
        id, user_id, exam_id, score, raw_score, total_questions,
        time_spent_seconds, submitted_at, answers, section_scores,
        updated_at_hlc, is_deleted
      ) VALUES (
        v_payload->>'id',
        v_user_id,
        v_payload->>'exam_id',
        COALESCE((v_payload->>'score')::double precision, 0.0),
        COALESCE((v_payload->>'raw_score')::int, 0),
        COALESCE((v_payload->>'total_questions')::int, 0),
        COALESCE((v_payload->>'time_spent_seconds')::int, 0),
        (v_payload->>'submitted_at')::timestamptz,
        COALESCE(v_payload->'answers', '{}'::jsonb),
        COALESCE(v_payload->'section_scores', '{}'::jsonb),
        v_hlc,
        v_is_deleted
      )
      ON CONFLICT (id) DO UPDATE
      SET score = EXCLUDED.score,
          raw_score = EXCLUDED.raw_score,
          total_questions = EXCLUDED.total_questions,
          time_spent_seconds = EXCLUDED.time_spent_seconds,
          submitted_at = EXCLUDED.submitted_at,
          answers = EXCLUDED.answers,
          section_scores = EXCLUDED.section_scores,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted
      WHERE public.exam_submissions.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.exam_submissions.updated_at_hlc;

    ELSIF v_entity_type = 'wrong_question' THEN
      INSERT INTO public.wrong_question_notebook (
        id, user_id, question_id, exam_id, user_answer, correct_answer,
        notes, mastered, review_count, updated_at_hlc, is_deleted
      ) VALUES (
        v_payload->>'id',
        v_user_id,
        v_payload->>'question_id',
        v_payload->>'exam_id',
        COALESCE(v_payload->>'user_answer', ''),
        COALESCE(v_payload->>'correct_answer', ''),
        COALESCE(v_payload->>'notes', ''),
        COALESCE((v_payload->>'mastered')::boolean, false),
        COALESCE((v_payload->>'review_count')::int, 0),
        v_hlc,
        v_is_deleted
      )
      ON CONFLICT (id) DO UPDATE
      SET user_answer = EXCLUDED.user_answer,
          correct_answer = EXCLUDED.correct_answer,
          notes = EXCLUDED.notes,
          mastered = EXCLUDED.mastered,
          review_count = EXCLUDED.review_count,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted
      WHERE public.wrong_question_notebook.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.wrong_question_notebook.updated_at_hlc;

    ELSIF v_entity_type = 'user_media' THEN
      INSERT INTO public.user_media (
        id, user_id, filename, hash_sha256, size_bytes, mime_type,
        updated_at_hlc, is_deleted
      ) VALUES (
        COALESCE(v_payload->>'id', gen_random_uuid()::text),
        v_user_id,
        v_payload->>'filename',
        v_payload->>'hash_sha256',
        COALESCE((v_payload->>'size_bytes')::bigint, 0),
        COALESCE(v_payload->>'mime_type', 'application/octet-stream'),
        v_hlc,
        v_is_deleted
      )
      ON CONFLICT (user_id, filename) DO UPDATE
      SET hash_sha256 = EXCLUDED.hash_sha256,
          size_bytes = EXCLUDED.size_bytes,
          mime_type = EXCLUDED.mime_type,
          updated_at_hlc = EXCLUDED.updated_at_hlc,
          is_deleted = EXCLUDED.is_deleted
      WHERE public.user_media.user_id = v_user_id
        AND EXCLUDED.updated_at_hlc > public.user_media.updated_at_hlc;

    END IF;

    v_ack_ids := v_ack_ids || to_jsonb(v_item->>'id');
    v_processed_count := v_processed_count + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'ack_ids', v_ack_ids,
    'processed_count', v_processed_count,
    'server_timestamp', now()
  );
END;
$$;

-- 4. Create flanki_backups storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'flanki_backups',
  'flanki_backups',
  false,
  104857600, -- 100MB maximum snapshot size
  ARRAY['application/zip', 'application/octet-stream', 'application/x-zip-compressed']
)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for flanki_backups bucket
CREATE POLICY "Users can upload their own backups"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'flanki_backups'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view and download their own backups"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'flanki_backups'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete their own backups"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'flanki_backups'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. RPC function: get_cloud_storage_stats
CREATE OR REPLACE FUNCTION public.get_cloud_storage_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_deck_count INT := 0;
  v_card_count INT := 0;
  v_revlog_count INT := 0;
  v_grammar_count INT := 0;
  v_media_count INT := 0;
  v_media_bytes BIGINT := 0;
  v_backup_count INT := 0;
  v_backup_bytes BIGINT := 0;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT COUNT(*) INTO v_deck_count FROM public.decks WHERE user_id = v_user_id AND is_deleted = false;
  SELECT COUNT(*) INTO v_card_count FROM public.cards WHERE user_id = v_user_id AND is_deleted = false;
  SELECT COUNT(*) INTO v_revlog_count FROM public.review_logs WHERE user_id = v_user_id;
  SELECT COUNT(*) INTO v_grammar_count FROM public.grammar_progress WHERE user_id = v_user_id AND is_deleted = false;

  SELECT COUNT(*), COALESCE(SUM(size_bytes), 0)
  INTO v_media_count, v_media_bytes
  FROM public.user_media
  WHERE user_id = v_user_id AND is_deleted = false;

  -- Count backup files in storage
  SELECT COUNT(*), COALESCE(SUM(COALESCE((metadata->>'size')::bigint, 0)), 0)
  INTO v_backup_count, v_backup_bytes
  FROM storage.objects
  WHERE bucket_id = 'flanki_backups'
    AND (storage.foldername(name))[1] = v_user_id::text;

  RETURN jsonb_build_object(
    'deck_count', v_deck_count,
    'card_count', v_card_count,
    'review_log_count', v_revlog_count,
    'grammar_progress_count', v_grammar_count,
    'media_count', v_media_count,
    'media_bytes', v_media_bytes,
    'backup_count', v_backup_count,
    'backup_bytes', v_backup_bytes
  );
END;
$$;
