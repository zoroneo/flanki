-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 004 - STORAGE BUCKETS
-- Description: Media storage bucket setup for flashcards and exam audio/images
-- Created At: 2026-09-16
-- ==============================================================================

-- 1. Create the 'flanki_media' bucket (if it doesn't already exist)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'flanki_media',
    'flanki_media',
    TRUE,                 -- Public read via Supabase CDN for instant audio/image loading
    52428800,             -- 50MB per file limit (covers large IELTS listening passages)
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml', 'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/ogg', 'audio/m4a']
)
ON CONFLICT (id) DO UPDATE SET
    public = TRUE,
    file_size_limit = 52428800;

-- 2. Enable RLS on storage.objects (if not already enabled)
-- Note: Supabase enables RLS on storage.objects by default

-- 3. Storage Policies:
-- Allow anyone to view media files via public CDN URL
CREATE POLICY "Public Read Media"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'flanki_media');

-- Allow authenticated users to upload media files into their user-partitioned path or content-addressed path
CREATE POLICY "Authenticated Users Upload Media"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );

-- Allow authenticated users to update their own media files
CREATE POLICY "Users Update Own Media"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );

-- Allow authenticated users to delete their own media files
CREATE POLICY "Users Delete Own Media"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'flanki_media' AND
        (storage.foldername(name))[1] = (select auth.uid())::TEXT
    );
