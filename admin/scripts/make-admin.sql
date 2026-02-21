-- ============================================================
-- Make a user an admin in MomoPe
-- Run this in Supabase SQL Editor or via the MCP tool
-- ============================================================

-- Replace 'admin@example.com' with the actual admin email
UPDATE public.users
SET role = 'admin'
WHERE email = 'admin@example.com';

-- Verify
SELECT id, email, role FROM public.users WHERE role = 'admin';
