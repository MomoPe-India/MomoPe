# MomoPe

**Merchant-funded loyalty rewards platform.**  
Customers earn Momo Coins on every purchase. 1 Momo Coin = ₹1. No wallets, no pre-loading.

**Company**: MOMO PE DIGITAL HUB PRIVATE LIMITED  
**Auth**: Firebase Phone OTP + PhonePe-style 4-digit PIN  
**Backend**: Supabase (PostgreSQL + Edge Functions) + PayU payments

---

## Repository Structure

```
MomoPe/
├── customer_app/    # Flutter — End consumer Android app
├── merchant_app/    # Flutter — Business owner Android app
├── admin/           # Next.js 15 — Super Admin Dashboard
├── supabase/
│   ├── functions/   # Deno Edge Functions (5 functions)
│   └── migrations/  # SQL migration files (sequential)
├── docs/            # Product and technical documentation
├── .env.example     # Copy → .env and fill secrets
├── .gitignore
└── README.md
```

## Quick Start

See [docs/05_DEV_SETUP_AND_CONVENTIONS.md](docs/05_DEV_SETUP_AND_CONVENTIONS.md) for full setup instructions.

```bash
# 1. Clone and setup env
cp .env.example .env   # fill in real values

# 2. Link Supabase and apply migrations
supabase login
supabase link --project-ref jgpoxmjpgryxinjbuvhb
supabase db push

# 3. Customer App
cd customer_app && flutter pub get
flutter run --dart-define=PAYU_KEY=U1Zax8 --dart-define=PAYU_SALT=<salt> --dart-define=PAYU_ENV=0

# 4. Merchant App
cd merchant_app && flutter pub get
flutter run

# 5. Admin Dashboard
cd admin && npm install && npm run dev   # http://localhost:3001
```

## Test Accounts

| Role | Phone | OTP |
|------|-------|-----|
| Customer | `+91 9999999999` | `123456` |
| Merchant | `+91 8888888888` | `654321` |
| Admin | `+91 7777777777` | `000000` |

> Register test numbers in Firebase Console → Authentication → Phone → Test phone numbers.

## Docs

| Doc | Purpose |
|-----|---------|
| [01_PRD.md](docs/01_PRD.md) | Product Requirements |
| [02_TECHNICAL_ARCHITECTURE.md](docs/02_TECHNICAL_ARCHITECTURE.md) | Architecture & Auth |
| [03_DATABASE_SCHEMA.md](docs/03_DATABASE_SCHEMA.md) | Database schema & RLS |
| [04_API_CONTRACTS.md](docs/04_API_CONTRACTS.md) | Edge Functions & RPCs |
| [05_DEV_SETUP_AND_CONVENTIONS.md](docs/05_DEV_SETUP_AND_CONVENTIONS.md) | Dev setup & conventions |
