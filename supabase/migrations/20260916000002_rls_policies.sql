-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 002 - RLS POLICIES
-- Description: Row-Level Security policies for multi-tenant user data isolation
-- Created At: 2026-09-16
-- ==============================================================================

-- Enable RLS on all user tables
ALTER TABLE public.decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grammar_progress_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_papers ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 1. DECKS RLS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own decks"
    ON public.decks FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own decks"
    ON public.decks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own decks"
    ON public.decks FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own decks"
    ON public.decks FOR DELETE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 2. CARDS RLS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own cards"
    ON public.cards FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cards"
    ON public.cards FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cards"
    ON public.cards FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cards"
    ON public.cards FOR DELETE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 3. REVIEW LOGS RLS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own review logs"
    ON public.review_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own review logs"
    ON public.review_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Review logs are immutable event logs: no UPDATE policy needed

-- ------------------------------------------------------------------------------
-- 4. GRAMMAR PROGRESS ENTRIES RLS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own grammar progress"
    ON public.grammar_progress_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own grammar progress"
    ON public.grammar_progress_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own grammar progress"
    ON public.grammar_progress_entries FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own grammar progress"
    ON public.grammar_progress_entries FOR DELETE
    USING (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 5. EXAM SUBMISSIONS RLS
-- ------------------------------------------------------------------------------
CREATE POLICY "Users can view their own exam submissions"
    ON public.exam_submissions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own exam submissions"
    ON public.exam_submissions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exam submissions"
    ON public.exam_submissions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 6. EXAM PAPERS RLS (Public Catalog)
-- ------------------------------------------------------------------------------
CREATE POLICY "Anyone authenticated can view published exam papers"
    ON public.exam_papers FOR SELECT
    TO authenticated
    USING (is_published = TRUE);
