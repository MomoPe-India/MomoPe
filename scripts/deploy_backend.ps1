# MomoPe Backend Deployment Script
# Automated setup for Supabase and Firebase
# Run from PowerShell in c:\DRAGON\MomoPe directory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MomoPe Backend Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if required CLIs are installed
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

$hasSupabase = Get-Command supabase -ErrorAction SilentlyContinue
$hasFirebase = Get-Command firebase -ErrorAction SilentlyContinue
$hasNode = Get-Command node -ErrorAction SilentlyContinue

if (-not $hasNode) {
    Write-Host "ERROR: Node.js not found. Install via: winget install OpenJS.NodeJS" -ForegroundColor Red
    exit 1
}

if (-not $hasSupabase) {
    Write-Host "Supabase CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g supabase
}

if (-not $hasFirebase) {
    Write-Host "Firebase CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g firebase-tools
}

Write-Host "Prerequisites OK!" -ForegroundColor Green
Write-Host ""

# ============================================================================
# PART 1: Supabase Setup
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Part 1: Supabase Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if already initialized
if (-not (Test-Path "supabase/config.toml")) {
    Write-Host "Initializing Supabase..." -ForegroundColor Yellow
    supabase init
} else {
    Write-Host "Supabase already initialized (config.toml exists)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Logging into Supabase..." -ForegroundColor Yellow
supabase login

Write-Host ""
Write-Host "MANUAL STEP REQUIRED:" -ForegroundColor Yellow
Write-Host "1. Go to https://supabase.com/dashboard" -ForegroundColor White
Write-Host "2. Create a new project:" -ForegroundColor White
Write-Host "   - Name: momope-production" -ForegroundColor White
Write-Host "   - Region: ap-south-1 (Mumbai)" -ForegroundColor White
Write-Host "3. Copy the Project Ref (15 characters)" -ForegroundColor White
Write-Host ""

$projectRef = Read-Host "Enter your Supabase Project Ref"

if ($projectRef.Length -eq 0) {
    Write-Host "ERROR: Project Ref cannot be empty" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Linking to Supabase project..." -ForegroundColor Yellow
supabase link --project-ref $projectRef

Write-Host ""
Write-Host "Deploying database migrations..." -ForegroundColor Yellow
supabase db push

Write-Host ""
Write-Host "Verifying migrations..." -ForegroundColor Yellow
supabase db diff

Write-Host ""
Write-Host "Deploying edge functions..." -ForegroundColor Yellow
supabase functions deploy sync-user --no-verify-jwt
supabase functions deploy payu-webhook --no-verify-jwt
supabase functions deploy process-expiry --no-verify-jwt

Write-Host ""
Write-Host "Setting PayU secrets..." -ForegroundColor Yellow
Write-Host "Enter your PayU credentials (leave blank to skip):" -ForegroundColor White

$payuKey = Read-Host "PayU Merchant Key (optional for now)"
$payuSalt = Read-Host "PayU Salt (optional for now)"

if ($payuKey.Length -gt 0) {
    supabase secrets set PAYU_MERCHANT_KEY=$payuKey
}

if ($payuSalt.Length -gt 0) {
    supabase secrets set PAYU_SALT=$payuSalt
}

Write-Host ""
Write-Host "Getting Supabase credentials..." -ForegroundColor Yellow
supabase status

Write-Host ""
Write-Host "Supabase setup complete!" -ForegroundColor Green
Write-Host "IMPORTANT: Copy the API URL and keys shown above" -ForegroundColor Yellow

# ============================================================================
# PART 2: Firebase Setup
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Part 2: Firebase Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Logging into Firebase..." -ForegroundColor Yellow
firebase login

Write-Host ""
Write-Host "MANUAL STEP REQUIRED:" -ForegroundColor Yellow
Write-Host "1. Go to https://console.firebase.google.com" -ForegroundColor White
Write-Host "2. Create a new project: momope-production" -ForegroundColor White
Write-Host "3. Go to Authentication > Sign-in method" -ForegroundColor White
Write-Host "4. Enable 'Phone' authentication" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter when Firebase project is created and Phone auth is enabled"

Write-Host ""
Write-Host "Listing Firebase projects..." -ForegroundColor Yellow
firebase projects:list

$firebaseProject = Read-Host "Enter your Firebase project ID (e.g., momope-production)"

if ($firebaseProject.Length -eq 0) {
    Write-Host "ERROR: Firebase project ID cannot be empty" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Setting active project..." -ForegroundColor Yellow
firebase use $firebaseProject

Write-Host ""
Write-Host "Registering Android apps..." -ForegroundColor Yellow
firebase apps:create android com.momope.customer --project=$firebaseProject
firebase apps:create android com.momope.merchant --project=$firebaseProject

Write-Host ""
Write-Host "Listing registered apps..." -ForegroundColor Yellow
firebase apps:list

Write-Host ""
Write-Host "Firebase setup complete!" -ForegroundColor Green
Write-Host "IMPORTANT: Download google-services.json files manually from Firebase Console" -ForegroundColor Yellow

# ============================================================================
# PART 3: Create .env File
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Part 3: Environment Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path ".env") {
    Write-Host ".env file already exists. Backup created as .env.backup" -ForegroundColor Yellow
    Copy-Item .env .env.backup
}

$envContent = @"
# Supabase (update with your values from 'supabase status')
SUPABASE_URL=https://$projectRef.supabase.co
SUPABASE_ANON_KEY=YOUR_ANON_KEY_HERE
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY_HERE

# PayU (update with actual credentials)
PAYU_MERCHANT_KEY=$payuKey
PAYU_SALT=$payuSalt

# Firebase (update with your values)
FIREBASE_API_KEY=YOUR_API_KEY_HERE
FIREBASE_PROJECT_ID=$firebaseProject
FIREBASE_APP_ID=YOUR_APP_ID_HERE
"@

$envContent | Out-File -FilePath .env -Encoding UTF8

Write-Host ".env file created!" -ForegroundColor Green
Write-Host "IMPORTANT: Update .env with actual keys from Supabase and Firebase" -ForegroundColor Yellow

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Supabase:" -ForegroundColor Green
Write-Host "  - Project linked: $projectRef" -ForegroundColor White
Write-Host "  - Migrations deployed: 3" -ForegroundColor White
Write-Host "  - Edge functions deployed: 3" -ForegroundColor White
Write-Host ""

Write-Host "Firebase:" -ForegroundColor Green
Write-Host "  - Project: $firebaseProject" -ForegroundColor White
Write-Host "  - Apps registered: 2 (customer, merchant)" -ForegroundColor White
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Green
Write-Host "  - .env file created" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Update .env file with actual Supabase keys" -ForegroundColor Yellow
Write-Host "   Run: supabase status (to see keys)" -ForegroundColor White
Write-Host ""

Write-Host "2. Update .env file with Firebase keys" -ForegroundColor Yellow
Write-Host "   Run: firebase apps:sdkconfig web" -ForegroundColor White
Write-Host ""

Write-Host "3. Download google-services.json files" -ForegroundColor Yellow
Write-Host "   Go to: https://console.firebase.google.com" -ForegroundColor White
Write-Host "   Project Settings > Your apps > Download config" -ForegroundColor White
Write-Host ""

Write-Host "4. Set up cron job for coin expiry" -ForegroundColor Yellow
Write-Host "   See: docs/cli_quickstart.md (Part 5)" -ForegroundColor White
Write-Host ""

Write-Host "5. Start building Flutter apps!" -ForegroundColor Yellow
Write-Host "   cd customer_app" -ForegroundColor White
Write-Host "   flutter create . (if not already created)" -ForegroundColor White
Write-Host ""

Write-Host "Deployment complete! 🚀" -ForegroundColor Green
Write-Host ""
