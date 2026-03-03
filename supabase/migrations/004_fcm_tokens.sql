-- Migration: 004_fcm_tokens.sql
-- Date: 2026-02-26
-- Author: MomoPe Team
-- Purpose: Device push notification token storage for FCM
-- Rollback: DROP TABLE fcm_tokens CASCADE;

CREATE TABLE IF NOT EXISTS fcm_tokens (
  id           UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      VARCHAR(128)  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_token TEXT          NOT NULL,
  platform     VARCHAR(10)   NOT NULL DEFAULT 'android',

  created_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  CONSTRAINT valid_platform CHECK (platform IN ('android', 'ios')),
  CONSTRAINT unique_device_token UNIQUE (device_token)   -- one token per device
);

CREATE INDEX IF NOT EXISTS idx_fcm_user ON fcm_tokens(user_id);

-- RLS
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "fcm_self_manage" ON fcm_tokens
  FOR ALL USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY "fcm_admin_all" ON fcm_tokens
  FOR ALL USING (is_admin());

-- Auto-update updated_at
DROP TRIGGER IF EXISTS trg_fcm_updated_at ON fcm_tokens;
CREATE TRIGGER trg_fcm_updated_at
  BEFORE UPDATE ON fcm_tokens
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
