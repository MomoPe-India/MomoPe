-- Migration: 005_pgcron_expiry_job.sql
-- Date: 2026-02-26
-- Author: MomoPe Team
-- Purpose: Schedule daily coin expiry job via pg_cron
-- Rollback: SELECT cron.unschedule('expire-coins-daily');

-- Schedule at 20:30 UTC = 02:00 AM IST (daily)
SELECT cron.schedule(
  'expire-coins-daily',
  '30 20 * * *',
  $$
    SELECT net.http_post(
      url     := 'https://jgpoxmjpgryxinjbuvhb.supabase.co/functions/v1/process-expiry',
      headers := '{"Content-Type": "application/json"}'::jsonb,
      body    := '{}'::jsonb
    )
  $$
);
