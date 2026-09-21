-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 008 - REALTIME PUBLICATION
-- Description: Enable Postgres Realtime CDC on user sync tables
-- Created At: 2026-09-20
-- ==============================================================================

-- 1. Ensure REPLICA IDENTITY FULL for detailed change payloads
ALTER TABLE IF EXISTS public.decks REPLICA IDENTITY FULL;
ALTER TABLE IF EXISTS public.cards REPLICA IDENTITY FULL;
ALTER TABLE IF EXISTS public.review_logs REPLICA IDENTITY FULL;
ALTER TABLE IF EXISTS public.grammar_progress REPLICA IDENTITY FULL;
ALTER TABLE IF EXISTS public.user_media REPLICA IDENTITY FULL;

-- 2. Add business sync tables to supabase_realtime publication
DO $$
BEGIN
    -- Check and add public.decks
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'decks'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.decks;
    END IF;

    -- Check and add public.cards
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'cards'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.cards;
    END IF;

    -- Check and add public.review_logs
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'review_logs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.review_logs;
    END IF;

    -- Check and add public.grammar_progress
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'grammar_progress'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.grammar_progress;
    END IF;

    -- Check and add public.user_media
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'user_media'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.user_media;
    END IF;
END $$;
