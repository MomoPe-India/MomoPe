# MomoPe CLI Commands Cheatsheet

Quick reference for common Supabase and Firebase CLI commands.

---

## Supabase CLI

### Project Management
```powershell
supabase login                    # Login to Supabase
supabase init                     # Initialize local project
supabase link --project-ref REF   # Link to remote project
supabase status                   # Show project info & credentials
supabase projects list            # List all your projects
```

### Database
```powershell
supabase db push                  # Deploy migrations
supabase db diff                  # Show pending changes
supabase db reset                 # Reset local database (WARNING: destroys data)
supabase db execute "SQL QUERY"   # Run SQL query
supabase db dump                  # Export database
```

### Edge Functions
```powershell
supabase functions deploy FUNCTION_NAME          # Deploy function
supabase functions deploy FUNCTION_NAME --no-verify-jwt  # Deploy without JWT verification
supabase functions logs FUNCTION_NAME            # View function logs
supabase functions delete FUNCTION_NAME          # Delete function
supabase functions list                          # List all functions
```

### Secrets
```powershell
supabase secrets set KEY=value    # Set environment variable
supabase secrets list             # List all secrets
supabase secrets unset KEY        # Delete secret
```

### Local Development
```powershell
supabase start                    # Start local Supabase (Docker required)
supabase stop                     # Stop local Supabase
supabase db reset                 # Reset local database
```

---

## Firebase CLI

### Project Management
```powershell
firebase login                    # Login to Firebase
firebase logout                   # Logout
firebase projects:list            # List all projects
firebase use PROJECT_ID           # Set active project
firebase init                     # Initialize Firebase in project
```

### Apps
```powershell
firebase apps:list                # List registered apps
firebase apps:create android PACKAGE_NAME    # Register Android app
firebase apps:create ios BUNDLE_ID           # Register iOS app
firebase apps:sdkconfig android APP_ID       # Get Android config
firebase apps:sdkconfig web                  # Get Web config
```

### Authentication
```powershell
firebase auth:export FILE.json    # Export users
firebase auth:import FILE.json    # Import users
```

### Hosting (for future web dashboard)
```powershell
firebase deploy --only hosting    # Deploy to Firebase Hosting
firebase serve                    # Test locally
```

---

## MomoPe-Specific Commands

### Complete Backend Deployment
```powershell
# From c:\DRAGON\MomoPe
.\scripts\deploy_backend.ps1
```

### Deploy Only Database Changes
```powershell
cd c:\DRAGON\MomoPe
supabase db push
```

### Deploy Only Edge Functions
```powershell
supabase functions deploy sync-user --no-verify-jwt
supabase functions deploy payu-webhook --no-verify-jwt
supabase functions deploy process-expiry --no-verify-jwt
```

### View Logs (Real-time)
```powershell
# Webhook logs (important for debugging payments)
supabase functions logs payu-webhook

# User sync logs
supabase functions logs sync-user

# Coin expiry logs
supabase functions logs process-expiry
```

### Test Database Functions
```powershell
# Test 80/20 calculation
supabase db execute "SELECT calculate_max_redeemable('user-uuid', 1000);"

# Test coverage ratio
supabase db execute "SELECT get_coverage_ratio();"

# Count users
supabase db execute "SELECT COUNT(*) FROM users;"
```

### Update Environment Variables
```powershell
# Update PayU credentials
supabase secrets set PAYU_MERCHANT_KEY=new_key
supabase secrets set PAYU_SALT=new_salt

# Verify updated
supabase secrets list
```

---

## Troubleshooting Commands

### Supabase Issues
```powershell
# Check project status
supabase status

# View all logs
supabase logs

# Reset and re-deploy (WARNING: destroys data)
supabase db reset
supabase db push
```

### Firebase Issues
```powershell
# Check current project
firebase use

# Re-login
firebase logout
firebase login
```

### Migration Errors
```powershell
# Show what would be deployed
supabase db diff

# Force push (use with caution)
supabase db push --include-all

# Rollback last migration (manual)
# Edit migration files and re-push
```

---

## Daily Development Workflow

### Making Database Changes
```powershell
# 1. Create new migration file
# Manually create: supabase/migrations/004_my_changes.sql

# 2. Deploy to remote
supabase db push

# 3. Verify
supabase db diff
```

### Updating Edge Functions
```powershell
# 1. Edit function code
# Edit: supabase/functions/FUNCTION_NAME/index.ts

# 2. Deploy
supabase functions deploy FUNCTION_NAME --no-verify-jwt

# 3. Test & view logs
supabase functions logs FUNCTION_NAME
```

---

## Production Checklist

Before deploying to production:

```powershell
# 1. Verify all migrations
supabase db diff  # Should show: No schema changes detected

# 2. Test all edge functions locally (if using supabase start)
supabase start
curl http://localhost:54321/functions/v1/sync-user ...

# 3. Deploy to production
supabase db push
supabase functions deploy sync-user --no-verify-jwt
supabase functions deploy payu-webhook --no-verify-jwt
supabase functions deploy process-expiry --no-verify-jwt

# 4. Verify logs
supabase functions logs sync-user
supabase functions logs payu-webhook

# 5. Test RLS policies
supabase db execute "SELECT * FROM users WHERE id = auth.uid();"
```

---

## Emergency Procedures

### Rollback Edge Function
```powershell
# Deploy previous version (git checkout old version first)
git checkout HEAD~1
supabase functions deploy FUNCTION_NAME --no-verify-jwt
```

### Emergency Database Restore
```powershell
# From Supabase Dashboard:
# Settings > Database > Backups > Restore
# (CLI doesn't support restore yet)
```

---

## Quick Links

- **Supabase Dashboard**: `https://app.supabase.com/project/YOUR_PROJECT_REF`
- **Firebase Console**: `https://console.firebase.google.com/project/YOUR_PROJECT_ID`
- **Supabase Docs**: https://supabase.com/docs/reference/cli
- **Firebase Docs**: https://firebase.google.com/docs/cli

---

**Save this file for quick reference during development!**
