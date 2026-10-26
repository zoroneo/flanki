-- ==============================================================================
-- FLANKI SUPABASE DATABASE MIGRATION: 20261026000001 - APP ERROR LOGS
-- Description: Production Error Logging, Crash Monitoring, and Diagnostic Summary
-- Created At: 2026-10-26
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. APP ERROR LOGS TABLE
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    fingerprint TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'error' CHECK (severity IN ('debug', 'info', 'warning', 'error', 'fatal')),
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    platform TEXT NOT NULL,
    app_version TEXT NOT NULL,
    device_info JSONB NOT NULL DEFAULT '{}'::jsonb,
    breadcrumbs JSONB NOT NULL DEFAULT '[]'::jsonb,
    occurrences INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 2. INDEXES FOR FAST FILTERING & MONITORING
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_app_error_logs_created_at 
    ON public.app_error_logs (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_app_error_logs_fingerprint 
    ON public.app_error_logs (fingerprint);

CREATE INDEX IF NOT EXISTS idx_app_error_logs_severity 
    ON public.app_error_logs (severity);

CREATE INDEX IF NOT EXISTS idx_app_error_logs_user_id 
    ON public.app_error_logs (user_id) 
    WHERE user_id IS NOT NULL;

-- ------------------------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.app_error_logs ENABLE ROW LEVEL SECURITY;

-- Allow any client (anonymous or authenticated) to submit error reports
CREATE POLICY "Allow public insert error logs"
    ON public.app_error_logs FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Allow users to view their own reported error logs; admins/service_role can view all
CREATE POLICY "Users can view their own reported errors"
    ON public.app_error_logs FOR SELECT
    TO authenticated
    USING (
        (SELECT auth.uid()) = user_id 
        OR ((SELECT auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin'
    );

-- ------------------------------------------------------------------------------
-- 4. AGGREGATED SUMMARY VIEW
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.app_error_summary AS
SELECT
    fingerprint,
    severity,
    error_type,
    error_message,
    platform,
    app_version,
    SUM(occurrences)::BIGINT AS total_occurrences,
    COUNT(*)::BIGINT AS total_reports,
    MIN(created_at) AS first_seen,
    MAX(created_at) AS last_seen
FROM public.app_error_logs
GROUP BY fingerprint, severity, error_type, error_message, platform, app_version
ORDER BY last_seen DESC;

-- ------------------------------------------------------------------------------
-- 5. LOG RETENTION CLEANUP FUNCTION
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.cleanup_old_error_logs(retention_days INT DEFAULT 30)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM public.app_error_logs
    WHERE created_at < NOW() - (retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

