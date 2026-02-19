# MomoPe Backend Setup - CLI Quickstart

**Automated deployment using Supabase and Firebase CLI tools**

---

## Prerequisites

Install required CLI tools:

```powershell
# Install Node.js (if not already installed)
winget install OpenJS.NodeJS

# Install Supabase CLI
npm install -g supabase

# Install Firebase CLI
npm install -g firebase-tools

# Verify installations
supabase --version
firebase --version
```

---

## Part 1: Supabase Setup (5 minutes)

### Step 1: Initialize Supabase Project

```powershell
cd c:\DRAGON\MomoPe

# Initialize Supabase (creates config files)
supabase init
```

### Step 2: Login to Supabase

```powershell
# Login via browser
supabase login
```

Browser will open → Login with your Supabase account

### Step 3: Create Remote Project (Web Dashboard)

**Option A: Via Web Dashboard** (Recommended for first project):
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Fill in:
   - **Name**: `momope-production`
   - **Database Password**: Generate strong password (save it!)
   - **Region**: `ap-south-1` (Mumbai, India)
4. Click "Create new project" (takes ~2 minutes)

**Option B: Via CLI** (if you have org already):
```powershell
# Create project
supabase projects create momope-production --org-id YOUR_ORG_ID --db-password YOUR_STRONG_PASSWORD --region ap-south-1
```

### Step 4: Link Local Project to Remote

From your dashboard, copy the **Project Ref** (looks like `abcdefghijklmno`)

```powershell
# Link to remote project
supabase link --project-ref YOUR_PROJECT_REF
```

Enter your database password when prompted.

### Step 5: Deploy Database Migrations

```powershell
# Push all migrations to remote database
supabase db push

# Verify migrations applied
supabase db diff
```

Expected output: `No schema changes detected` (means all migrations deployed)

### Step 6: Get Project Credentials

```powershell
# Print project credentials
supabase status
```

**Save these values** (you'll need them for `.env` file):
- `API URL`
- `Anon key`
- `Service Role key` (SECRET - never commit!)

---

## Part 2: Deploy Edge Functions

### Deploy All Functions

```powershell
# Deploy sync-user function
supabase functions deploy sync-user --no-verify-jwt

# Deploy payu-webhook function
supabase functions deploy payu-webhook --no-verify-jwt

# Deploy process-expiry function
supabase functions deploy process-expiry --no-verify-jwt
```

### Set Environment Variables for Functions

```powershell
# Set PayU credentials (update with your actual values)
supabase secrets set PAYU_MERCHANT_KEY=your_merchant_key
supabase secrets set PAYU_SALT=your_salt_key

# Verify secrets set
supabase secrets list
```

---

## Part 3: Firebase Setup (3 minutes)

### Step 1: Login to Firebase

```powershell
# Login via browser
firebase login
```

Browser will open → Login with your Google account

### Step 2: Create Firebase Project

**Option A: Via Web Console** (Recommended):
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: `momope-production`
4. Disable Google Analytics (unless you want it)
5. Click "Create project"

**Option B: Via CLI**:
```powershell
# Create project
firebase projects:create momope-production --display-name "MomoPe Production"
```

### Step 3: Initialize Firebase in Project

```powershell
cd c:\DRAGON\MomoPe

# Initialize Firebase
firebase init
```

Select:
- **Authentication** (Spacebar to select)
- Use existing project → Select `momope-production`
- Default settings for everything else

### Step 4: Enable Phone Authentication

**Via Firebase Console** (easier):
1. Go to https://console.firebase.google.com
2. Select your project → Authentication → Sign-in method
3. Click "Phone" → Enable → Save

**Via CLI** (if available in your Firebase version):
```powershell
firebase auth:import enable --provider phone
```

### Step 5: Register Apps

```powershell
# Register Android app (customer app)
firebase apps:create android com.momope.customer --project=momope-production

# Register Android app (merchant app)
firebase apps:create android com.momope.merchant --project=momope-production
```

### Step 6: Download Config Files

```powershell
# List registered apps to get App IDs
firebase apps:list

# Download google-services.json for each app
firebase apps:sdkconfig android APP_ID_HERE
```

Save the `google-services.json` files:
- Customer app: `c:\DRAGON\MomoPe\customer_app\android\app\google-services.json`
- Merchant app: `c:\DRAGON\MomoPe\merchant_app\android\app\google-services.json`

---

## Part 4: Configure Environment Variables

### Create `.env` File

```powershell
cd c:\DRAGON\MomoPe

# Create .env file
New-Item -Path .env -ItemType File
```

**Edit `.env` file** with your values:

```env
# Supabase
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...

# PayU (update with actual credentials)
PAYU_MERCHANT_KEY=your_merchant_key
PAYU_SALT=your_salt_key

# Firebase
FIREBASE_API_KEY=AIzaSy...
FIREBASE_PROJECT_ID=momope-production
FIREBASE_APP_ID=1:12345...
```

Get Firebase config values:
```powershell
firebase apps:sdkconfig web
```

---

## Part 5: Setup Cron Job for Coin Expiry

### Enable pg_cron in Supabase Dashboard

1. Go to Supabase Dashboard → Database → Extensions
2. Search for `pg_cron` → Enable

### Create Cron Job via SQL Editor

In Supabase Dashboard → SQL Editor:

```sql
SELECT cron.schedule(
  'expire-old-coins-daily',
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

Replace `YOUR_PROJECT_REF` and `YOUR_SERVICE_ROLE_KEY` with your actual values.

### Verify Cron Job

```sql
SELECT * FROM cron.job;
```

Should show your `expire-old-coins-daily` job.

---

## Part 6: Test Deployment

### Test Database Connection

```powershell
# Run SQL query via CLI
supabase db execute "SELECT COUNT(*) FROM users;"
```

Expected: `0` (no users yet)

### Test Edge Functions

```powershell
# Test sync-user (will fail without valid Firebase token, but should return 400 not 500)
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/sync-user `
  -H "Content-Type: application/json" `
  -d '{\"firebase_token\": \"test\", \"phone_number\": \"+919999999999\"}'
```

Expected: 40X error (not 500) - function is deployed

### Test RLS Policies

In Supabase Dashboard → SQL Editor:

```sql
-- This should fail (RLS prevents viewing other users' data)
SET ROLE authenticated;
SELECT * FROM momo_coin_balances; -- Should return 0 rows (no auth context)
```

---

## Part 7: Monitor Deployment

### View Edge Function Logs

```powershell
# View sync-user logs (real-time)
supabase functions logs sync-user

# View payu-webhook logs
supabase functions logs payu-webhook
```

### View Database Metrics

```powershell
# Check database status
supabase db status
```

---

## Troubleshooting

### Migration Errors

If migrations fail:

```powershell
# Reset database (WARNING: destroys all data)
supabase db reset

# Re-push migrations
supabase db push
```

### Edge Function Deployment Errors

```powershell
# Delete function
supabase functions delete sync-user

# Re-deploy
supabase functions deploy sync-user --no-verify-jwt
```

### Check Supabase Logs

```powershell
# View all logs
supabase logs
```

---

## Quick Commands Reference

```powershell
# Supabase
supabase status                  # Show project info
supabase db push                 # Deploy migrations
supabase db diff                 # Show pending migrations
supabase functions deploy <name> # Deploy edge function
supabase functions logs <name>   # View function logs
supabase secrets set KEY=value   # Set environment variable

# Firebase
firebase login                   # Login
firebase projects:list           # List projects
firebase apps:list               # List registered apps
firebase apps:sdkconfig android  # Get Android config
```

---

## Success Checklist

After completing all steps, verify:

- [ ] Supabase project created and linked
- [ ] All 3 migrations deployed (7 tables created)
- [ ] All 3 edge functions deployed
- [ ] PayU secrets set in Supabase
- [ ] Firebase project created
- [ ] Phone authentication enabled
- [ ] Apps registered in Firebase
- [ ] `google-services.json` downloaded
- [ ] `.env` file created with all credentials
- [ ] Cron job scheduled for coin expiry
- [ ] Edge function logs accessible

---

## Next Steps

1. **Flutter Setup**: Now that backend is deployed, initialize Flutter apps
2. **Test Integration**: Build a simple test app to verify authentication flow
3. **PayU Integration**: Test webhook with PayU sandbox

**Estimated Time**: 15-20 minutes total (if no errors)

---

**Need Help?**
- Supabase CLI Docs: https://supabase.com/docs/reference/cli
- Firebase CLI Docs: https://firebase.google.com/docs/cli
- MomoPe Setup Issues: Check `supabase_setup.md` for detailed troubleshooting
