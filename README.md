# MomoPe - Loyalty Rewards Platform

**Version**: 1.0.0  
**Status**: Development  
**Started**: February 15, 2026

## Project Overview

MomoPe is a commission-based loyalty rewards platform that connects customers with local merchants through a sustainable coin economy.

- **Not a wallet** - No stored value, no fund custody
- **Not a PSP** - PayU handles all payment processing
- **Commission-based** - Sustainable business model from Day 1

## Repository Structure

```
MomoPe/
├── customer_app/       # Flutter app for customers
├── merchant_app/       # Flutter app for merchants
├── supabase/          # Backend (database, edge functions)
│   ├── migrations/    # Database schema
│   └── functions/     # Edge functions (Deno)
├── docs/              # Technical documentation
└── README.md
```

## Technology Stack

- **Mobile**: Flutter 3.x (Dart)
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **Auth**: Firebase (Phone OTP) + Supabase (RLS)
- **Payments**: PayU Gateway
- **Web** (Future): Next.js 14

## Quick Start

### Prerequisites
- Flutter SDK 3.x
- Node.js 18+
- Supabase CLI
- Git

### Setup
```bash
# Clone repository
git clone <repo-url>
cd MomoPe

# Initialize Supabase
cd supabase
supabase init
supabase link --project-ref <your-project-ref>

# Run migrations
supabase db push

# Set up customer app
cd ../customer_app
flutter pub get
flutter run
```

## Development Timeline

- **Week 1-3**: Backend infrastructure (Supabase, database, edge functions)
- **Week 4-8**: Customer app MVP
- **Week 9-11**: Merchant app MVP
- **Week 12**: Integration testing
- **Week 13-16**: Admin dashboard (Q2 2026)

## Key Features

### Customer App
- QR code scanning
- Coin redemption (80/20 rule)
- Transaction history
- Coin balance tracking

### Merchant App
- QR code display
- Transaction monitoring
- Settlement tracking

### Backend
- Row-level security (RLS)
- FIFO coin expiry (90 days)
- Commission calculation
- PayU webhook processing

## Business Model

- **Revenue**: Commission on transactions (15-40%)
- **User Rewards**: 10% of fiat paid (merchant-funded)
- **Reserve**: 60% coverage of coin liability

## Documentation

- **Implementation Plan**: `docs/implementation_plan.md`
- **Architecture**: `docs/architecture_blueprint.md`
- **Strategic Brief**: `docs/cto_strategic_brief.md`
- **Ecosystem Guide**: See `MOMOPE_ECOSYSTEM.md`

## Team

- **Founder/CEO**: Damerla Mohan
- **Co-Founder**: Damerla Mounika

## Legal

- **Company**: MOMO PE DIGITAL HUB PRIVATE LIMITED
- **CIN**: U63120AP2025PTC118821
- **Incorporated**: April 12, 2025

## License

Proprietary - All Rights Reserved

---

**Status**: Building the future of local commerce 🚀
