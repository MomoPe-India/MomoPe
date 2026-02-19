# MomoPe Supabase Setup Guide

## Prerequisites

- Supabase account (https://supabase.com)
- Supabase CLI installed
- Node.js 18+ (for CLI)

## Step 1: Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Fill in details:
   - **Name**: momope-production
   - **Database Password**: (generate strong password, save securely)
   - **Region**: Mumbai (ap-south-1) - closest to India
4. Click "Create new project" (takes ~2 minutes)

## Step 2: Note Project Credentials

From Project Settings → API:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
Anon Public Key: eyJhbGc...
Service Role Key: eyJhbGc... (KEEP SECRET)
```

Save these in a secure location (password manager).

## Step 3: Install Supabase CLI

```bash
npm install -g supabase
```

Verify installation:
```bash
supabase --version
```

## Step 4: Link Local Project to Remote

```bash
cd c:\DRAGON\MomoPe\supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

Find `YOUR_PROJECT_REF` in Supabase dashboard URL:
`https://app.supabase.com/project/YOUR_PROJECT_REF`

## Step 5: Run Database Migrations

```bash
# Push all migrations to remote database
supabase db push

# Verify tables created
supabase db diff
```

Expected tables:
- users
- user_mappings
- momo_coin_balances
- merchants
- transactions
- commissions
- coin_batches
- coin_transactions

## Step 6: Configure Environment Variables

Create `.env` file in project root:

```env
# Supabase
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...

# PayU (update with actual credentials)
PAYU_MERCHANT_KEY=your_merchant_key
PAYU_SALT=your_salt_key

# Firebase (update after Firebase setup)
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

**IMPORTANT**: Add `.env` to `.gitignore` (already done)

## Step 7: Deploy Edge Functions

```bash
# Deploy sync-user function
supabase functions deploy sync-user --no-verify-jwt

# Deploy payu-webhook function
supabase functions deploy payu-webhook --no-verify-jwt

# Deploy process-expiry function
supabase functions deploy process-expiry --no-verify-jwt
```

Set environment variables for edge functions:
```bash
supabase secrets set PAYU_SALT=your_salt_key
```

## Step 8: Configure Cron Job for Expiry

In Supabase Dashboard → Database → Extensions:
1. Enable `pg_cron` extension
2. Run SQL:

```sql
SELECT cron.schedule(
  'expire-old-coins',
  '0 2 * * *', -- Daily 2 AM IST
  $$
  SELECT net.http_post(
    url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/process-expiry',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
    body := '{}'::jsonb
  ) AS request_id;
  $$
);
```

## Step 9: Verify Setup

### Test Database Access
```bash
supabase db reset
```

Should show no errors.

### Test Edge Functions
```bash
# Test sync-user (with mock data)
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/sync-user \
  -H "Content-Type: application/json" \
  -d '{"firebase_token": "test", "phone_number": "+919999999999"}'
```

### Check RLS Policies
In Supabase Dashboard → Authentication → Policies:
- Verify all tables have RLS enabled
- Test policies with SQL Editor

## Step 10: Upgrade to Supabase Pro (Production)

Before launching:
1. Go to Settings → Billing
2. Upgrade to Pro plan ($25/month)

**Pro Features You Need**:
- Automatic daily backups
- Point-in-time recovery
- Increased database size
- Higher API limits

## Troubleshooting

### Migration Errors
If migration fails:
```bash
supabase db reset --db-url postgresql://...
```

### Edge Function Errors
View logs:
```bash
supabase functions logs sync-user
supabase functions logs payu-webhook
```

### RLS Policy Testing
Disable RLS temporarily for testing:
```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

**Remember to re-enable before production!**

## Security Checklist

- [ ] Service Role Key stored securely (never in git)
- [ ] RLS enabled on all tables
- [ ] Edge functions use SERVICE_ROLE_KEY (not ANON_KEY)
- [ ] PayU signature verification implemented
- [ ] Database backups enabled
- [ ] Separate staging/production projects

## Next Steps

1. Set up Firebase Authentication (see `firebase_setup.md`)
2. Configure PayU merchant account
3. Build Flutter customer app
4. Test end-to-end transaction flow

---

**Support**: If issues occur, check Supabase Discord or docs.supabase.com
