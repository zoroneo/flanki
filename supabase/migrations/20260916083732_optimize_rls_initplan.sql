-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: OPTIMIZE RLS INITPLAN
-- Description: Replace per-row auth.uid() calls with (select auth.uid()) in RLS policies
-- Created At: 2026-09-16
-- ==============================================================================

-- 1. DECKS RLS
DROP POLICY IF EXISTS "Users can view their own decks" ON public.decks;
CREATE POLICY "Users can view their own decks"
    ON public.decks FOR SELECT
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own decks" ON public.decks;
CREATE POLICY "Users can insert their own decks"
    ON public.decks FOR INSERT
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own decks" ON public.decks;
CREATE POLICY "Users can update their own decks"
    ON public.decks FOR UPDATE
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete their own decks" ON public.decks;
CREATE POLICY "Users can delete their own decks"
    ON public.decks FOR DELETE
    USING ((select auth.uid()) = user_id);

-- 2. CARDS RLS
DROP POLICY IF EXISTS "Users can view their own cards" ON public.cards;
CREATE POLICY "Users can view their own cards"
    ON public.cards FOR SELECT
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own cards" ON public.cards;
CREATE POLICY "Users can insert their own cards"
    ON public.cards FOR INSERT
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own cards" ON public.cards;
CREATE POLICY "Users can update their own cards"
    ON public.cards FOR UPDATE
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete their own cards" ON public.cards;
CREATE POLICY "Users can delete their own cards"
    ON public.cards FOR DELETE
    USING ((select auth.uid()) = user_id);

-- 3. REVIEW LOGS RLS
DROP POLICY IF EXISTS "Users can view their own review logs" ON public.review_logs;
CREATE POLICY "Users can view their own review logs"
    ON public.review_logs FOR SELECT
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own review logs" ON public.review_logs;
CREATE POLICY "Users can insert their own review logs"
    ON public.review_logs FOR INSERT
    WITH CHECK ((select auth.uid()) = user_id);

-- 4. GRAMMAR PROGRESS ENTRIES RLS
DROP POLICY IF EXISTS "Users can view their own grammar progress" ON public.grammar_progress_entries;
CREATE POLICY "Users can view their own grammar progress"
    ON public.grammar_progress_entries FOR SELECT
    USING ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can insert their own grammar progress" ON public.grammar_progress_entries;
CREATE POLICY "Users can insert their own grammar progress"
    ON public.grammar_progress_entries FOR INSERT
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can update their own grammar progress" ON public.grammar_progress_entries;
CREATE POLICY "Users can update their own grammar progress"
    ON public.grammar_progress_entries FOR UPDATE
    USING ((select auth.uid()) = user_id)
    WITH CHECK ((select auth.uid()) = user_id);

DROP POLICY IF EXISTS "Users can delete their own grammar progress" ON public.grammar_progress_entries;
CREATE POLICY "Users can delete their own grammar progress"
    ON public.grammar_progress_entries FOR DELETE
    USING ((select auth.uid()) = user_id);

-- 5. STORAGE POLICIES
DROP POLICY IF EXISTS "Authenticated Users Upload Media" ON storage.objects;
CREATE POLICY "Authenticated Users Upload Media"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );

DROP POLICY IF EXISTS "Users Update Own Media" ON storage.objects;
CREATE POLICY "Users Update Own Media"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );

DROP POLICY IF EXISTS "Users Delete Own Media" ON storage.objects;
CREATE POLICY "Users Delete Own Media"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );
