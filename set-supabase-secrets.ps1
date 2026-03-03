# set-supabase-secrets.ps1
# Run this once after doing: npx supabase@latest login
# Then: .\set-supabase-secrets.ps1

$PROJECT_REF = "jgpoxmjpgryxinjbuvhb"

$secrets = @(
  "PAYU_MERCHANT_KEY=U1Zax8",
  "PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt",
  "PAYU_CLIENT_ID=300bf75e2b1447c1a3da46a1d1e18b0f9c9a0710e39de85dfdc49e11c43df7e2",
  "PAYU_CLIENT_SECRET=883027729623a6b8ec3e4a3a70dc710d297a59f0f96fda3f55e00f33800d0a77"
  # Add these after you get them:
  # "FIREBASE_PROJECT_ID=momope-5f8e2",
  # "FIREBASE_SERVICE_ACCOUNT_JSON=<paste full JSON here on one line>"
)

Write-Host "Setting Supabase Edge Function secrets for project: $PROJECT_REF" -ForegroundColor Cyan
npx supabase@latest secrets set @secrets --project-ref $PROJECT_REF
Write-Host "Done! Secrets are now available in all Edge Functions via Deno.env.get()" -ForegroundColor Green
