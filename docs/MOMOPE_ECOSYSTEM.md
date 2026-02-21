# MomoPe Ecosystem: The Complete Reference

**The Definitive Source of Truth for the MomoPe Rewards Platform**

> "Empowering merchants. Rewarding customers. Building the future of local commerce."

---

**Version**: 2.0  
**Last Updated**: February 20, 2026  
**Status**: Living Document (Continuously Updated)  
**Classification**: Internal - Founder Reference Guide

---

## Document Purpose

This is the **single source of truth** for everything MomoPe. Every decision, implementation, feature, strategy, and vision is documented here. This document will evolve into a physical book post-launch, serving as the complete history and blueprint of the MomoPe ecosystem.

**Use this document when**:
- Making strategic decisions
- Resolving confusion about business logic
- Planning new features
- Explaining MomoPe to investors, partners, or team members
- Onboarding new team members
- Ensuring consistency across all products

---

# Table of Contents

## Part I: Vision & Strategy
1. [The MomoPe Vision](#1-the-momope-vision)
2. [Mission & Core Values](#2-mission--core-values)
3. [Market Positioning](#3-market-positioning)
4. [Business Model](#4-business-model)
5. [Revenue Strategy](#5-revenue-strategy)

## Part II: Product Principles
6. [Product Philosophy](#6-product-philosophy)
7. [The Coin Economy](#7-the-coin-economy)
8. [The 80/20 Rule](#8-the-8020-rule)
9. [User Experience Principles](#9-user-experience-principles)
10. [Merchant Value Proposition](#10-merchant-value-proposition)

## Part III: Technical Architecture
11. [System Overview](#11-system-overview)
12. [Technology Stack](#12-technology-stack)
13. [Database Architecture](#13-database-architecture)
14. [Authentication System](#14-authentication-system)
15. [Security Model (RLS)](#15-security-model-rls)
16. [Edge Functions](#16-edge-functions)
17. [Payment Integration](#17-payment-integration)

## Part IV: Financial Framework
18. [Treasury Management](#18-treasury-management)
19. [Liability Model](#19-liability-model)
20. [Merchant Settlement](#20-merchant-settlement)
21. [Reserve Strategy](#21-reserve-strategy)
22. [Risk Management](#22-risk-management)

## Part V: Product Features
23. [Customer App](#23-customer-app)
24. [Merchant App](#24-merchant-app)
25. [Super Admin Dashboard](#25-super-admin-dashboard)
26. [Public Website](#26-public-website)

## Part VI: Operations & Compliance
27. [Compliance Strategy](#27-compliance-strategy)
28. [KYC Requirements](#28-kyc-requirements)
29. [Data Privacy](#29-data-privacy)
30. [Operational Workflows](#30-operational-workflows)

## Part VII: Growth & Marketing
31. [Go-to-Market Strategy](#31-go-to-market-strategy)
32. [Customer Acquisition](#32-customer-acquisition)
33. [Merchant Onboarding](#33-merchant-onboarding)
34. [Branding Guidelines](#34-branding-guidelines)

## Part VIII: Future Roadmap
35. [Product Roadmap](#35-product-roadmap)
36. [Technical Roadmap](#36-technical-roadmap)
37. [Expansion Plans](#37-expansion-plans)

---

# Part I: Vision & Strategy

## 1. The MomoPe Vision

### Company Information ⭐

**Legal Name**: MOMO PE DIGITAL HUB PRIVATE LIMITED  
**Brand Name**: MomoPe  
**CIN**: U63120AP2025PTC118821  
**Status**: Active (Incorporated April 12, 2025)

**Primary Bank**: HDFC Bank  
**Account**: 50200112238728  
**IFSC**: HDFC0008279

**Registered Office**: Cuddapah, Andhra Pradesh  
**Directors**: Damerla Mohan, Damerla Mounika

**Full company details**: `c:\MomoPe\.company\company_details.json`

---

### The 10-Year Roadmap

MomoPe exists to **revolutionize local commerce** by creating a win-win-win ecosystem where:
- **Customers** earn real rewards for everyday purchases
- **Merchants** acquire and retain customers cost-effectively
- **MomoPe** builds a sustainable, profitable fintech platform

### The Problem We Solve

**For Customers**:
- Traditional cashback programs: complex, delayed, minimum thresholds
- Digital wallets: require pre-loading money, create friction
- Credit cards: high barriers to entry, debt traps

**For Merchants**:
- Customer acquisition costs: ₹500-2,000 per customer (digital ads)
- Customer retention: no effective loyalty programs for small businesses
- Payment acceptance: UPI is free but offers no engagement layer

**MomoPe's Solution**:
- Instant rewards (no delayed cashback)
- No pre-loading (not a wallet)
- Easy redemption (at point of purchase)
- Merchant-funded (sustainable economics)
- Commission-based (no hidden fees)

### 10-Year Vision

**Year 1-2**: Establish in Bangalore (10,000 users, 150 merchants)  
**Year 3-5**: Expand to Tier-1 cities (1M users, 5,000 merchants)  
**Year 5-7**: Pan-India presence (10M users, 50,000 merchants)  
**Year 7-10**: Category leader, potential international expansion

**North Star Metric**: Gross Merchandise Value (GMV) processed through MomoPe

---

## 2. Mission & Core Values

### Mission Statement

> "To empower local businesses with technology-driven customer engagement tools while rewarding customers for supporting their community."

### Core Values

**1. Customer Trust**
- Transparent coin mechanics (no hidden conditions)
- Fair expiry policies (90 days with clear communication)
- Privacy-first data practices

**2. Merchant Partnership**
- Fair commission rates (15-40%, negotiable)
- Fast settlements (T+3 standard, T+1 premium)
- No predatory contracts

**3. Financial Integrity**
- Never hold customer funds (not a wallet)
- Maintain 60%+ reserve coverage always
- Auditable ledgers, transparent accounting

**4. Regulatory Compliance**
- Proactive compliance (not reactive)
- Avoid gray areas (clear PSP delegation to PayU)
- Investor-grade governance

**5. Long-Term Sustainability**
- Unit economics matter (no growth-at-all-costs)
- Liability management (expiry, caps, reserves)
- Profitable from Day 1 (commission-first model)

---

## 3. Market Positioning

### What MomoPe IS

✅ **Loyalty Rewards Platform**
- Merchant-funded customer rewards
- Engagement layer for local commerce
- Technology provider, not financial intermediary

✅ **Commission-Based Business**
- Revenue from merchant commissions only
- No customer fees, no subscription fees
- Transparent pricing

✅ **Technology Layer on PayU**
- PayU handles payment processing (PCI-DSS, fund custody)
- MomoPe handles rewards logic
- Clear regulatory boundaries

### What MomoPe IS NOT

❌ **Not a Wallet**
- No "Add Money" feature
- No stored value
- No fund custody

❌ **Not a PSP (Payment Service Provider)**
- Does not process card/UPI transactions
- Does not settle merchant payouts from customer funds
- All payments via licensed PSP (PayU)

❌ **Not a Prepaid Instrument**
- Coins cannot be withdrawn as cash
- Coins cannot be transferred peer-to-peer
- Coins expire in 90 days

❌ **Not a Coin-Settlement System**
- Merchants ALWAYS receive fiat (₹)
- Coins NEVER flow to merchants
- Coin redemption is MomoPe's internal ledger

**Why This Matters**: Avoids RBI wallet/PPI licensing, minimizes compliance burden, enables capital-efficient scaling.

---

## 4. Business Model

### Revenue Source

**100% Commission-Based**

```
Revenue = Σ (Transaction GMV × Merchant Commission Rate)
```

**No Other Revenue Streams** (intentionally simple):
- No customer fees
- No subscription fees
- No advertisement revenue
- No data monetization

### Unit Economics

**Example Transaction**:
```
Bill Amount: ₹1,000
Merchant Commission: 20%
Merchant Rewards: 10%
Customer Coins Applied: 800 coins (₹800)
PayU Fiat Payment: ₹200

Revenue Calculation:
─────────────────────
Gross Commission = ₹1,000 × 20% = ₹200
User Reward (10% of fiat) = ₹200 × 10% = 20 coins (₹20 cost)
Net Revenue = ₹200 - ₹20 = ₹180

Margin = ₹180 / ₹1,000 = 18% of GMV

**Note**: If merchant sets 5% rewards instead:
User Reward = ₹200 × 5% = 10 coins (₹10 cost)
Net Revenue = ₹200 - ₹10 = ₹190 (higher margin)
```

**Key Principle**: Commission calculated on **gross amount**, not fiat paid. This ensures profitability even with high coin redemption.

### Commission Structure

| Merchant Category | Default Rate | Typical Range |
|-------------------|--------------|---------------|
| **Grocery** | 20% | 17-25% |
| **Food & Beverage** | 25% | 20-30% |
| **Retail/Lifestyle** | 30% | 25-35% |
| **Services** | 35% | 30-40% |

**Policy Update (Feb 2026)**: Minimum commission rate increased from 10% to **15%** to ensure sustainable unit economics.

**Negotiation**: Rates negotiable based on volume, exclusivity, brand value.

---

## 5. Revenue Strategy

### Phase 1: Commission Revenue (Current)

**Focus**: Maximize transaction volume
**Metric**: GMV growth
**Target**: ₹10 Cr GMV by Month 12 = ₹2 Cr commission = ₹1.8 Cr net revenue

### Phase 2: Premium Services (Year 2)

**Merchant Premium Tier**:
- T+1 settlements (0.5% fee)
- Priority support
- Advanced analytics dashboard

**Estimated Revenue**: +15% on top of base commission

### Phase 3: B2B SaaS (Year 3+)

**White-Label Rewards Platform**:
- License MomoPe technology to other platforms
- Recurring SaaS revenue
- Non-competing verticals (e.g., corporate cafeterias, housing societies)

**Estimated Revenue**: ₹50L-1 Cr ARR

---

# Part II: Product Principles

## 6. Product Philosophy

### Design Principles

**1. Simplicity Over Features**
- Every feature must pass the "grandmother test" (can a non-tech user understand it?)
- No jargon, no complex financial terms
- Coins, not "reward points" or "cashback units"

**2. Transparency Over Growth Hacks**
- No hidden expiry (90 days clearly stated)
- No complex redemption rules (simple 80/20 formula)
- No bait-and-switch (commission rates locked per merchant)

**3. Trust Over Virality**
- No forced referrals
- No social media spam incentives
- Organic growth via merchant quality and user experience

**4. Sustainable Over Viral**
- Unit economics matter from Day 1
- No VC-funded cashback burns
- Reserve coverage always > 60%

### User-Centric Decisions

**Every Product Decision Asks**:
1. Does this benefit customers AND merchants?
2. Is this financially sustainable?
3. Does this align with our "not a wallet" positioning?
4. Can we explain this in one sentence?

---

## 7. The Coin Economy

### Coin Fundamentals

**Definition**: Momo Coins are promotional loyalty units with fixed redemption value.

| Property | Value | Rationale |
|----------|-------|-----------|
| **Redemption Value** | 1 Coin = ₹1 | Simple 1:1 mapping |
| **Earning Rate** | 2-10% of fiat paid (MomoPe algorithm) | Dynamically calculated based on sustainability framework |
| **Transferability** | Non-transferable | Prevents secondary markets |
| **Withdrawability** | Cannot withdraw | Avoids PSP classification |
| **Expiry** | 90 days | Liability protection |
| **Max Redemption** | 80% (bill/balance) | Cash flow sustainability |

### Earning Coins

**User Guarantee**: MomoPe guarantees up to **10% rewards** on all eligible transactions.

**Dynamic Calculation**: Actual reward percentage is calculated within a **2% to 10% range**, determined entirely by MomoPe's internal reward logic and long-term sustainability framework.

**Formula**:
```
Coins Earned = Fiat Amount Paid × MomoPe Reward Algorithm %

Where:
- MomoPe Reward % = Dynamically calculated (2% to 10%)
- Based on: User patterns, platform sustainability, ecosystem balance
- NOT merchant-specific
```

**Reward Calculation Factors** (MomoPe Internal):
- User transaction history and behavior
- Platform liability levels
- Long-term financial sustainability
- Strategic promotional initiatives
- Ecosystem balance requirements
- Real-time platform health metrics

**Critical: Rewards Are NOT Merchant-Specific**

> Reward percentages are **never merchant-controlled**. Merchants cannot decide, influence, or request specific customer reward percentages under any circumstances. All reward calculations and final determinations rest exclusively with MomoPe to maintain ecosystem balance, financial discipline, and a consistent user experience.

**Merchant Independence**:
- All merchants subject to same reward algorithm
- Merchants have ZERO control over customer rewards
- Merchant A and Merchant B → Same user gets algorithmically determined %
- No merchant negotiation on rewards (not a merchant variable)

**Commission vs. Rewards** (Critical Distinction):

| Aspect | Commission % | Reward % |
|--------|-------------|----------|
| **Merchant-Specific** | ✅ Yes | ❌ No |
| **Set During** | Onboarding agreement | Algorithm (real-time) |
| **Merchant Control** | Can request changes | Zero control |
| **MomoPe Authority** | Approves changes | Exclusive authority |
| **Variability** | Fixed per merchant | Dynamic per transaction |

**Commission Model**:
- Commission percentage is the **only merchant-variable component**
- Fixed through formal agreement at onboarding
- Merchant may request revision
- MomoPe exclusively approves/rejects
- All decisions finalized by MomoPe in alignment with business viability

**Customer Experience**:
- Users see: "Earn up to 10% coins"
- Actual % shown at payment preview
- Not advertised as merchant-specific
- Consistent messaging across all merchants

**Algorithm Implementation Details**:

The MomoPe reward algorithm calculates the optimal reward percentage (2-10%) by analyzing multiple factors in real-time:

1. **User Tier Analysis** (Transaction History)
   - NEW USER (0-1 transactions): 10% reward (acquisition incentive)
   - ENGAGED USER (2-5 transactions): 9% reward (habit formation)
   - REGULAR USER (6-20 transactions): 8% reward (sustained engagement)
   - LOYAL USER (21+ transactions): 7% reward (already retained)

2. **Platform Sustainability** (Liability Management)
   - Monitors total unexpired coin liability
   - If liability > ₹1,00,000: Reduces rewards by 2%
   - Protects long-term financial health

3. **Transaction Value Tiers** (GMV Optimization)
   - High-value (≥₹5,000): +1% bonus
   - Micro-transaction (<₹100): -2% adjustment
   - Encourages meaningful purchases

4. **Time-Based Factors** (Demand Smoothing)
   - Weekend boost (Sat/Sun): +0.5%
   - Off-peak hours (10 AM-4 PM): +0.5%
   - Balances platform load

**Example Calculations**:

```
Scenario 1: New user, ₹6,000 transaction, Saturday 2 PM
├─ Base: 10% (new user)
├─ High-value: +1%
├─ Weekend + Off-peak: +1%
└─ Result: 12% → Capped at 10% = 600 coins

Scenario 2: Loyal user, ₹80 transaction, high platform liability
├─ Base: 7% (loyal user)
├─ Liability reduction: -2%
├─ Micro-transaction: -2%
└─ Result: 3% = 2 coins

Scenario 3: Engaged user, ₹1,000 transaction, Wednesday 12 PM
├─ Base: 9% (engaged user)
├─ Off-peak: +0.5%
└─ Result: 9.5% = 95 coins
```

**Key Benefits**:
- **Customer Acquisition**: New users get maximum rewards (10%)
- **Retention**: Engaged users maintain high rewards (9%)
- **Sustainability**: Automatic liability management prevents over-rewarding
- **GMV Growth**: High-value transactions incentivized
- **Operational Efficiency**: Off-peak purchasing encouraged

### Redeeming Coins

**Redemption Caps** (Dual Cap Rule):
```
Max Redeemable = min(
  Bill Amount × 80%,
  User Balance × 80%
)
```

**Example 1** (High Balance):
```
Bill: ₹1,000
Balance: 2,000 coins
Max: min(800, 1,600) = 800 coins
```

**Example 2** (Low Balance):
```
Bill: ₹1,000
Balance: 300 coins
Max: min(800, 240) = 240 coins
```

### Coin Expiry

**Policy**: 90 days from earn date

**Batch Tracking**: FIFO (First In, First Out)
- Oldest coins expire first
- Redemption deducts from oldest batches first

**User Communication**:
- In-app notification 15 days before expiry
- Email reminder 7 days before expiry
- Expiry clearly shown in transaction history

**Purpose**: Reduces long-term liability, encourages circulation

---

## 8. The 80/20 Rule

### Why 80/20?

**The Problem**: If users can redeem 100% coins:
- No cash flow for MomoPe (no PayU transaction)
- No new commission generated
- Liability drains without replenishment
- **Business model breaks**

**The Solution**: Mandatory 20% fiat payment

### Benefits

**For MomoPe**:
- Guaranteed cash inflow
- Commission generation on every transaction
- Sustainable liability coverage

**For Merchants**:
- Consistent fiat revenue (even with high redemption)
- Predictable settlement amounts

**For Users**:
- Forces coin circulation (can't hoard indefinitely)
- Always earning new coins (10% of fiat portion)
- Simple rule (easy to understand)

### Mathematical Protection

**Worst-Case Scenario**:
- User has 10,000 coins
- User tries to redeem 100%

**System Enforcement**:
```
Max Redemption = 10,000 × 80% = 8,000 coins
Forced Retention = 2,000 coins (20%)

User can NEVER drain entire balance.
```

**Effective Liability** = 80% of reported liability

---

## 9. User Experience Principles

### UI/UX Commandments

**1. Never Call It a "Wallet"**
- ✅ Coin Balance
- ❌ Wallet Balance
- ❌ MomoPe Balance

**2. Never Show ₹ Symbol for Coins**
- ✅ "Balance: 1,250 Coins"
- ❌ "Balance: ₹1,250"

**3. No Wallet-Like Actions**
- ❌ "Add Money"
- ❌ "Send to Friend"
- ❌ "Withdraw to Bank"

**4. Redemption at Point of Payment Only**
- ❌ Standalone "Redeem Coins" screen
- ✅ Coin application during transaction flow

**5. Transparency in Every Transaction**
- Show: Bill, Coins Applied, Fiat to Pay, Coins to Earn
- Use visual breakdown (progress bars, charts)

### User Journey Map

**First-Time User**:
1. Download app → Simple onboarding (Google Sign-In)
2. Browse merchants → See "Earn X% Coins" labels (merchant-specific)
3. Scan QR → Enter amount → See coin preview
4. Pay → Instant coin credit notification
5. Check balance → See transaction history

**Returning User**:
1. Open app → See coin balance, nearby merchants
2. Scan QR → Auto-suggest coin redemption
3. Slide to select coins → Pay remaining fiat
4. Earn more coins → Repeat

**Delightful Moments**:
- Coin credit animation (confetti, sound)
- Milestone celebrations (1,000 coins earned!)
- Merchant recommendations based on coin balance

---

## 10. Merchant Value Proposition

### What Merchants Get

**1. Customer Acquisition**
- Listed in MomoPe app (discovery by nearby users)
- QR code for instant payment
- No upfront marketing cost

**2. Customer Retention**
- Loyalty loop (users return to earn/redeem coins)
- Higher transaction frequency
- Competitive advantage (only merchant in area with MomoPe)

**3. Performance Marketing**
- Pay-per-transaction (not per-impression)
- Commission only on successful sales
- Measurable ROI (commission vs revenue)

**4. Zero Integration Effort**
- No POS integration required
- QR code printout (physical or digital)
- Instant onboarding

### Merchant Concerns & Answers

**"20% commission is too high"**
→ Compare to: Google Ads (upfront cost, no guaranteed conversion), Zomato/Swiggy (25-30% + no loyalty), traditional advertising (₹50,000+ with no tracking)

**"Settlement takes 3 days"**
→ Standard in fintech (Swiggy: T+7, Zomato: T+5). Premium T+1 available for high-volume merchants.

**"What if users only redeem coins?"**
→ 20% fiat always required (you always receive cash). Plus, you keep 80% of bill even after commission (net 60% fiat + full brand visibility).

**"How do I track my earnings?"**
→ Merchant app shows real-time transaction history, commission breakdown, settlement schedule. Web dashboard (coming Q2 2026) for advanced analytics.

---

# Part III: Technical Architecture

## 11. System Overview

### Ecosystem Components

```
┌─────────────────────────────────────────────────────┐
│                  MomoPe Ecosystem                    │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────────────────┐      ┌─────────────────┐      │
│  │  Customer App   │      │  Merchant App   │      │
│  │   (Flutter)     │      │   (Flutter)     │      │
│  └────────┬────────┘      └────────┬────────┘      │
│           │                        │               │
│           └────────┬───────────────┘               │
│                    │                               │
│           ┌────────▼────────┐                      │
│           │  Firebase Auth  │ (Phone OTP)          │
│           └────────┬────────┘                      │
│                    │                               │
│           ┌────────▼────────┐                      │
│           │   sync-user     │ (Edge Function)      │
│           └────────┬────────┘                      │
│                    │                               │
│           ┌────────▼────────┐                      │
│           │ Supabase Auth   │ (Session/RLS)        │
│           └────────┬────────┘                      │
│                    │                               │
│           ┌────────▼────────┐                      │
│           │   Supabase DB   │ (PostgreSQL)         │
│           │   7 Tables      │                      │
│           └────────┬────────┘                      │
│                    │                               │
│           ┌────────▼────────┐                      │
│           │ Edge Functions  │                      │
│           │ - payu-webhook  │                      │
│           │ - process-expiry│                      │
│           └─────────────────┘                      │
│                                                     │
│  ┌────────────────────────────────────────┐        │
│  │      PayU Payment Gateway              │        │
│  │  - Payment Processing                  │        │
│  │  - Fund Custody                        │        │
│  │  - Settlement                          │        │
│  └────────────────────────────────────────┘        │
│                                                     │
│  ┌────────────────────────────────────────┐        │
│  │   Web Platform (Q2 2026)               │        │
│  │  - www.momope.com (Public)             │        │
│  │  - admin.momope.com (Dashboard)        │        │
│  │  - merchant.momope.com (Portal)        │        │
│  └────────────────────────────────────────┘        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 12. Technology Stack

### Production Environment (Updated February 20, 2026)

**Project References**:
- **Supabase**: Project `wpnngcuoqtvgwhizkrwt` (Mumbai region)
- **Firebase**: Project `momope-production` (kept for Google OAuth configuration only)
- **PayU**: Merchant ID `U1Zax8` (Test Mode)

---

### Mobile Apps (Flutter) - ✅ **RUNNING ON DEVICE** (Updated February 20, 2026)

| Component | Technology | Version | Status |
|-----------|-----------|---------|--------|
| **Framework** | Flutter | **3.41.1** | ✅ **DEPLOYED** |
| **Language** | Dart | **3.11.0** | ✅ **DEPLOYED** |
| **State Management** | flutter_riverpod | **2.6.1** | ✅ **DEPLOYED** |
| **Auth SDK** | Google Sign-In + Supabase Auth | Latest | ✅ **DEPLOYED** |
| **Database SDK** | supabase_flutter | Latest | ✅ **DEPLOYED** |
| **QR Scanner** | mobile_scanner | **5.2.3** | ✅ **DEPLOYED** |
| **Charts** | fl_chart | **0.66.2** | ✅ **DEPLOYED** |
| **Internationalization** | intl | **0.18.1** | ✅ **DEPLOYED** |
| **UI Fonts** | google_fonts | **6.3.3** | ✅ **DEPLOYED** |
| **Sharing** | share_plus | Latest | ✅ **DEPLOYED** (Referral) |

**Android Build Configuration** (Stable):
```
Gradle: 8.12 (latest stable)
Android Gradle Plugin (AGP): 8.10.0  
Kotlin: 2.1.0
Java/JDK: 21.0.10 LTS (Temurin)
Min SDK: 21 (Android 5.0)
Target SDK: 36 (Android 16 API 36)
Compile SDK: 36
```

**Package Structure**:
```
customer_app/
├── com.momope.customer_app (Android)
├── google-services.json ✅ Configured
├── Authentication ✅ Google Sign-In Live
├── Home Screen ✅ Live (Coin Balance + Referral Stats Card)
├── Transaction History ✅ Live
├── QR Scanner ✅ Live
├── Coin Balance ✅ Live
├── Payment Flow ✅ Live
└── Referral System ✅ Live (End-to-End)

merchant_app/
├── com.momope.merchant (Android)
├── google-services.json ✅ Configured
├── Authentication ✅ Google Sign-In Live
├── Dashboard with Analytics ✅ Live
├── Static QR Code Display ✅ Live
└── Transaction Management ✅ Live
```

**Build Status** (February 20, 2026):
- ✅ Customer App: **Running on device** - Full payment + referral flow operational
- ✅ Merchant App: **Running on device** - Dashboard and QR display functional
- ✅ Google OAuth: Fully integrated for both apps (Supabase Native, no Firebase Auth)
- ✅ Supabase RLS: Complete security model deployed
- ✅ Build Environment: Stable, production-ready configuration
- ✅ Referral System: End-to-end implemented and deployed

---

### Backend Infrastructure (Production)

| Component | Technology | Version | Status |
|-----------|-----------|---------|--------|
| **Database** | Supabase PostgreSQL | 15.x | ✅ **DEPLOYED** |
| **Schema Migrations** | SQL Files | **10 migrations** | ✅ **DEPLOYED** |
| **Authentication** | Supabase Native Auth | Latest | ✅ **LIVE** |
| **OAuth Providers** | Google Sign-In (Web + Android) | Latest | ✅ **ENABLED (Cross-Platform)** |
| **Session Management** | Supabase Auth + RLS | Latest | ✅ **DEPLOYED** |
| **Edge Functions** | Deno 1.x (TypeScript) | **3 functions** | ✅ **DEPLOYED** |
| **Payments** | PayU Gateway | Test Mode | 🚧 **IN PROGRESS** |
| **Cron Jobs** | pg_cron Extension | v1.6.4 | ✅ **ENABLED** |
| **Hosting** | Supabase Cloud (Mumbai) | Managed | ✅ **LIVE** |
| **Referral System** | PostgreSQL + Edge Function | v1.0 | ✅ **DEPLOYED** |

**Recent Updates (February 2026)**:
- ✅ Migrated from Firebase Phone Auth → Supabase Native Auth (Google Sign-In)
- ✅ Removed Firebase Auth dependencies entirely (Firebase kept for `google-services.json` config only)
- 🚧 Payment integration UI complete, PayU SDK API integration in progress
- ✅ Commission rate policy updated (15%-50%)
- ✅ **Referral System fully implemented** — `referral_code` on users, `referrals` table, `referral_stats` view, `process_referral_reward()` atomic function, `process-referral` edge function
- ✅ **Supabase MCP Server** integrated for AI-assisted development

**Production URLs**:
```
Supabase API: https://wpnngcuoqtvgwhizkrwt.supabase.co
Edge Functions: https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/{function-name}
Dashboard: https://app.supabase.com/project/wpnngcuoqtvgwhizkrwt
```

---

### CLI Tools & Development Workflow

| Tool | Purpose | Version | Usage |
|------|---------|---------|-------|
| **Supabase CLI** | Database migrations, edge function deployment | Latest | `supabase db push`, `supabase functions deploy` |
| **Firebase CLI** | App registration, auth configuration | Latest | `firebase apps:create`, `firebase deploy` |
| **Flutter CLI** | Mobile app development | 3.x | `flutter run`, `flutter build` |
| **Git** | Version control | Latest | GitHub repository |
| **PowerShell** | Automation scripts | 7.x | `deploy_backend.ps1` |

**Deployment Commands**:
```powershell
# Link Supabase project
supabase link --project-ref wpnngcuoqtvgwhizkrwt

# Deploy database
supabase db push

# Deploy edge functions
supabase functions deploy sync-user --no-verify-jwt
supabase functions deploy payu-webhook --no-verify-jwt
supabase functions deploy process-expiry --no-verify-jwt

# Set secrets
supabase secrets set PAYU_MERCHANT_KEY=U1Zax8
supabase secrets set PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
```

---

### Web Platform (Deployed February 19, 2026)

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Framework** | Next.js 15 (App Router) | Public website & future admin dashboard |
| **Styling** | Tailwind CSS + Framer Motion | "Financial OS" design system |
| **Hosting** | Vercel | Global edge network & CI/CD |
| **Domain** | momope.com | Custom domain (SSL via Vercel) |
| **Analytics** | Vercel Analytics | Real-time traffic insights |

---

### Environment Management

**Configuration Files**:
```
MomoPe/
├── .env (local development)
│   ├── SUPABASE_URL
│   ├── SUPABASE_ANON_KEY
│   ├── SUPABASE_SERVICE_ROLE_KEY
│   ├── PAYU_MERCHANT_KEY
│   ├── PAYU_SALT
│   ├── FIREBASE_PROJECT_ID
│   └── FIREBASE_API_KEY
├── customer_app/android/app/google-services.json
└── merchant_app/android/app/google-services.json
```

**Security**: `.env` file is gitignored, secrets managed via Supabase CLI

---

### Technology Decisions & Rationale

**Why Supabase over custom PostgreSQL?**
- Managed infrastructure (no DevOps overhead)
- Built-in Row-Level Security (database-level access control)
- Realtime subscriptions (future features)
- Edge Functions (serverless Deno runtime)
- Auto-generated REST API (PostgREST)
- Cost-effective for MVP ($25/month Pro tier)

**Why Firebase Auth over Supabase Auth alone?**
- Phone OTP delivery (Supabase requires Twilio integration)
- Familiar mobile SDK
- Proven reliability for Indian phone numbers
- Dual-auth: Firebase for UX, Supabase for RLS

**Why PayU over Razorpay/Stripe?**
- Market leader in India (40%+ market share)
- Lower MDR compared to Razorpay
- Better settlement terms
- Existing test credentials ready
- PCI-DSS compliant (regulatory requirement)

**Why Flutter over React Native?**
- Superior performance (compiled to native)
- Consistent UI across Android/iOS
- Rich ecosystem for QR scanning, payments
- Easier state management (Riverpod)
- Planned: Single codebase for mobile + web (future)

**Why Deno for Edge Functions over Node.js?**
- TypeScript-native (no build step)
- Secure by default (explicit permissions)
- Supabase-managed (no separate hosting)
- Modern standard library
- Faster cold starts

---

## 13. Database Architecture

### Production Schema (Deployed)

**Supabase Project**: `wpnngcuoqtvgwhizkrwt`  
**Database**: PostgreSQL 15.x  
**Deployment Status**: ✅ **LIVE** (February 15, 2026)  
**Migrations**: 10 SQL files applied (including referral system — `010_referral_system.sql`)

---

### Schema Overview (9 Core Tables + 1 View)

| Table | Purpose | Status |
|-------|---------|--------|
| **users** | Customer/Merchant/Admin profiles + `referral_code` + `referred_by` | ✅ Deployed |
| **user_mappings** | Legacy Firebase ↔ Supabase bridge (deprecated) | ✅ Deployed |
| **momo_coin_balances** | User coin balances (aggregate) | ✅ Deployed |
| **merchants** | Business info, commission rates | ✅ Deployed |
| **transactions** | Payment records (PayU integration) | ✅ Deployed |
| **commissions** | Revenue ledger, settlement tracking | ✅ Deployed |
| **coin_batches** | FIFO expiry tracking (90 days) | ✅ Deployed |
| **coin_transactions** | Complete audit trail | ✅ Deployed |
| **referrals** | Referrer→Referee relationships, status, reward tracking | ✅ Deployed |
| **referral_stats** (view) | Aggregated referral metrics per user for home screen | ✅ Deployed |

---

### Table Relationships

```
users (1) ──────→ (1) momo_coin_balances
users (1) ──────→ (many) transactions
users (1) ──────→ (many) coin_batches
users (1) ──────→ (many) coin_transactions
users (1) ──────→ (1) merchants [if merchant role]

merchants (1) ───→ (many) transactions
transactions (1) → (1) commissions
transactions (1) → (many) coin_transactions
coin_batches (1) → (many) coin_transactions
```

---

### Detailed Schema

#### 1. `users` Table (Identity Management)

**Purpose**: Store all

 user profiles (customers, merchants, admins)

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  phone_number VARCHAR(20) UNIQUE NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_role CHECK (role IN ('customer', 'merchant', 'admin'))
);
```

**Indexes**:
- `idx_users_firebase_uid` on `firebase_uid`
- `idx_users_phone` on `phone_number`

---

#### 2. `user_mappings` Table (Auth Bridge)

**Purpose**: Map Firebase UID to Supabase user_id (dual auth)

```sql
CREATE TABLE user_mappings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR(255) UNIQUE NOT NULL,
  supabase_user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Critical for**: `sync-user` edge function to link Firebase authentication to Supabase RLS

---

#### 3. `momo_coin_balances` Table (Balance Integrity)

**Purpose**: Store aggregate coin balances with strict integrity checks

```sql
CREATE TABLE momo_coin_balances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id),
  total_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  available_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  locked_coins DECIMAL(10,2) NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Integrity constraints
  CONSTRAINT positive_total CHECK (total_coins >= 0),
  CONSTRAINT positive_available CHECK (available_coins >= 0),
  CONSTRAINT positive_locked CHECK (locked_coins >= 0),
  CONSTRAINT balance_integrity CHECK (total_coins = available_coins + locked_coins)
);
```

**Why `locked_coins`?**: For pending transactions (prevents double-spend during PayU processing)

---

#### 4. `merchants` Table (Business Profiles)

**Purpose**: Store merchant business information and commission rates

```sql
CREATE TABLE merchants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id),
  business_name VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL,
  commission_rate DECIMAL(5,4) NOT NULL DEFAULT 0.20,
  
  -- Business details
  gstin VARCHAR(15),
  pan VARCHAR(10),
  business_address TEXT,
  
  -- Banking details
  bank_account_number VARCHAR(20),
  ifsc_code VARCHAR(11),
  bank_account_holder_name VARCHAR(100),
  
  -- Location
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  is_operational BOOLEAN DEFAULT true,
  kyc_status VARCHAR(20) DEFAULT 'pending',
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_commission_rate CHECK (commission_rate >= 0.15 AND commission_rate <= 0.50),
  CONSTRAINT valid_category CHECK (category IN ('grocery', 'food_beverage', 'retail', 'services', 'other')),
  CONSTRAINT valid_kyc_status CHECK (kyc_status IN ('pending', 'approved', 'rejected'))
);
```

**Indexes**:
- `idx_merchants_active` on `(is_active, is_operational) WHERE is_active = true`
- `idx_merchants_location` on `(latitude, longitude) WHERE is_active = true`

---

#### 5. `transactions` Table (Payment Records)

**Purpose**: Store all payment transactions with PayU integration

```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  
  -- Transaction amounts
  gross_amount DECIMAL(10,2) NOT NULL,
  fiat_amount DECIMAL(10,2) NOT NULL,
  coins_applied DECIMAL(10,2) NOT NULL DEFAULT 0,
  
  -- PayU details
  payu_txnid VARCHAR(100) UNIQUE,
  payu_mihpayid VARCHAR(100),
  status VARCHAR(20) NOT NULL DEFAULT 'initiated',
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  settled_at TIMESTAMPTZ,
  
  -- Integrity constraints
  CONSTRAINT positive_gross CHECK (gross_amount > 0),
  CONSTRAINT positive_fiat CHECK (fiat_amount >= 0),
  CONSTRAINT positive_coins_applied CHECK (coins_applied >= 0),
  CONSTRAINT amount_integrity CHECK (gross_amount = fiat_amount + coins_applied),
  CONSTRAINT valid_status CHECK (status IN ('initiated', 'pending', 'success', 'failed', 'refunded'))
);
```

**Indexes**:
- `idx_transactions_user` on `(user_id, created_at DESC)`
- `idx_transactions_merchant` on `(merchant_id, created_at DESC)`
- `idx_transactions_status` on `(status, created_at DESC)`

**Critical Rule**: `gross_amount = fiat_amount + coins_applied` (enforced at database level)

---

#### 6. `commissions` Table (Revenue Ledger)

**Purpose**: Track commission breakdown for each transaction

```sql
CREATE TABLE commissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID UNIQUE NOT NULL REFERENCES transactions(id),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  
  -- Commission breakdown
  total_commission DECIMAL(10,2) NOT NULL,
  reward_cost DECIMAL(10,2) NOT NULL,
  net_revenue DECIMAL(10,2) NOT NULL,
  
  -- Settlement tracking
  is_settled BOOLEAN DEFAULT false,
  settlement_batch_id UUID,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_commission_math CHECK (net_revenue = total_commission - reward_cost)
);
```

**Key Formula**: `net_revenue = total_commission - reward_cost` (database-enforced)

---

#### 7. `coin_batches` Table (FIFO Expiry)

**Purpose**: Track coin batches for First-In-First-Out 90-day expiry

```sql
CREATE TABLE coin_batches (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  original_amount DECIMAL(10,2) NOT NULL,
  source VARCHAR(50) NOT NULL,
  transaction_id UUID REFERENCES transactions(id),
  
  -- Expiry tracking
  expiry_date DATE NOT NULL,
  is_expired BOOLEAN DEFAULT false,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT positive_amount CHECK (amount >= 0),
  CONSTRAINT valid_source CHECK (source IN ('earn', 'bonus', 'refund', 'admin_adjustment'))
);
```

**Index**: `idx_coin_batches_expiry` on `(user_id, expiry_date, is_expired) WHERE is_expired = false`

**Batch Logic**: 
- New coins create a new batch (expiry = created_at + 90 days)
- Redemption deducts from oldest batch first (FIFO)
- `process-expiry` cron marks old batches as expired

---

#### 8. `coin_transactions` Table (Audit Trail)

**Purpose**: Complete immutable audit trail of all coin movements

```sql
CREATE TABLE coin_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id),
  transaction_id UUID REFERENCES transactions(id),
  batch_id UUID REFERENCES coin_batches(id),
  
  type VARCHAR(20) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_type CHECK (type IN ('earn', 'redeem', 'expire', 'bonus', 'refund', 'admin_adjustment'))
);
```

**Index**: `idx_coin_transactions_user` on `(user_id, created_at DESC)`

**Audit Examples**:
- User earns coins: `type='earn', amount=+20`
- User redeems coins: `type='redeem', amount=-800`
- Batch expires: `type='expire', amount=-50`

---

### Database Functions (Business Logic)

**Deployed Functions** (in PostgreSQL):

1. **`calculate_max_redeemable(user_id, bill_amount)`**
   - Calculates max coins user can redeem (80/20 rule)
   - Returns: `min(bill × 0.80, balance × 0.80)`

2. **`redeem_coins_fifo(user_id, amount, transaction_id)`**
   - Deducts coins from oldest batches first
   - Atomically updates `coin_batches` and `momo_coin_balances`

3. **`award_coins(user_id, amount, transaction_id)`**
   - Creates new coin batch with 90-day expiry
   - Inserts `coin_transactions` record

4. **`process_transaction_success(transaction_id, ...)`**
   - **CRITICAL ATOMIC FUNCTION**
   - Redeems coins (FIFO)
   - Awards new coins
   - Inserts commission record
   - Updates transaction status
   - All-or-nothing (transaction rollback on error)

5. **`get_coverage_ratio()`**
   - Returns: `(Total Reserve) / (Total Coin Liability) × 100`

6. **`expire_old_coins()`**
   - Marks batches with `expiry_date < NOW()` as expired
   - Updates balances
   - Called by `process-expiry` edge function

---

### Database-Level Security (RLS)

All tables have Row-Level Security enabled. See [Section 15: Security Model](#15-security-model-rls) for complete RLS policies.

---

## 14. Authentication System

### Supabase Native Auth (Current Implementation)

**Migration Date**: February 2026  
**Previous System**: Firebase Phone Auth  
**Current System**: Supabase Native Auth with Google Sign-In

**Supported Auth Methods**:
- ✅ **Google Sign-In** (Web + Android)
- 🚧 **Email/Password** (Planned for MVP)
- ❌ **Phone OTP** (Removed - Firebase dependency eliminated)

### Auth Flow (Google Sign-In)

**Web Platform**:
```
1. User clicks "Sign in with Google"
2. Google OAuth flow opens in popup
3. User authorizes → Google returns tokens
4. Supabase exchanges Google token for session
5. App receives Supabase JWT
6. Public profile + coin balance created automatically
```

**Android Platform**:
```
1. User clicks "Sign in with Google"
2. Native Google Sign-In sheet appears
3. User selects Google account
4. App receives Google ID token
5. Supabase verifies token with Google
6. Supabase creates/updates user session
7. Public profile + coin balance created automatically
```

### Session Management

**Session Duration**: 1 hour (auto-refresh)  
**Logout**: `supabase.auth.signOut()` (clears session, JWT)  
**RLS Enforcement**: All DB queries automatically authenticated via Supabase JWT

### User Profile Setup

**Automatic Profile Creation** (`AuthService._ensurePublicUserProfile`):
```dart
await supabase.from('users').upsert({
  'id': user.id,
  'email': user.email,
  'name': displayName, // From Google metadata
  'role': 'customer',
});

await supabase.from('momo_coin_balances').insert({
  'user_id': user.id,
  'total_coins': 0,
  'available_coins': 0,
  'locked_coins': 0,
});
```

### Configuration

**Supabase Dashboard Setup**:
1. Enable Google provider in Authentication > Providers
2. Add Google Client ID and Secret from Google Cloud Console
3. Configure redirect URLs for web and Android
4. Set up Android SHA-1 fingerprints

**Google Cloud Console Setup**:
- OAuth 2.0 Client IDs created for Web and Android
- Authorized redirect URIs configured
- Android package name + SHA-1 fingerprints registered

**See Also**: `google_oauth_setup.md` and `android_google_setup.md` artifacts

---

## 15. Security Model (RLS)

### Row-Level Security Policies

**Core Principle**: Database-level access control (not app-level)

**Example Policies**:

```sql
-- Users can view own wallet only
CREATE POLICY "Users view own wallet"
ON momo_coin_balances FOR SELECT
USING (user_id = get_current_user_id());

-- Users can insert own transactions only
CREATE POLICY "Users insert own transactions"
ON transactions FOR INSERT
WITH CHECK (user_id = get_current_user_id());

-- Anyone can view active merchants (discovery)
CREATE POLICY "Public merchant discovery"
ON merchants FOR SELECT
USING (status = 'active' AND is_operational = true);

-- Admins can view all data
CREATE POLICY "Admin full access"
ON transactions FOR ALL
USING (is_admin());
```

### Helper Functions

**get_current_user_id()**:
```sql
CREATE FUNCTION get_current_user_id() RETURNS UUID AS $$
BEGIN
  RETURN auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**is_admin()**:
```sql
CREATE FUNCTION is_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 16. Edge Functions

### Production Deployment (Supabase Functions)

**Runtime**: Deno 1.x (TypeScript)  
**Deployment Status**: ✅ **3 Functions LIVE** (February 2026)  
**Base URL**: `https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1`

---

### Deployed Functions Overview

| Function | Purpose | Trigger | Status |
|----------|---------|---------|--------|
| **payu-webhook** | Process payment callbacks from PayU; fires referral check on qualifying payments (≥₹100) | PayU POST webhook | ✅ **ACTIVE** |
| **process-referral** | Awards 50 coins each to referrer+referee after first qualifying fiat payment (≥₹100); idempotent | Called by `payu-webhook` (fire-and-forget) | ✅ **ACTIVE** |
| **process-expiry** | Expires 90-day old coin batches, updates balances, records expiry transactions | pg_cron (daily 2 AM IST) | ✅ **ACTIVE** |

**Removed Functions** (February 2026):
- ~~sync-user~~ (No longer needed after Firebase removal; Google OAuth handled natively by Supabase)

**Deployment Commands**:
```powershell
# From c:\DRAGON\MomoPe\supabase directory:
supabase functions deploy payu-webhook --no-verify-jwt
supabase functions deploy process-referral   # verify-jwt default (uses service role internally)
supabase functions deploy process-expiry --no-verify-jwt
```

**Secrets Configured**:
```
SUPABASE_URL               ✅ Set
SUPABASE_SERVICE_ROLE_KEY  ✅ Set  
SUPABASE_ANON_KEY          ✅ Set
SUPABASE_DB_URL            ✅ Set
PAYU_MERCHANT_KEY          ✅ Set (U1Zax8)
PAYU_SALT                  ✅ Set
```

---

### ~~1. sync-user~~ (REMOVED — February 2026)

**Reason for Removal**: Authentication migrated from Firebase Phone OTP → Supabase Native Auth (Google Sign-In). The `sync-user` function created Supabase users from Firebase tokens, which is no longer needed. Google Sign-In now creates Supabase auth users natively, and `public.users` profiles are created via database trigger on `auth.users` insert.

**Migration**: The `user_mappings` table is preserved for historical reference but no longer written to.

---

### 1. process-referral (Referral Reward Processing)

**Purpose**: Award 50 coins each to referrer and referee after the referee's first qualifying fiat payment (≥₹100). Idempotent — safe to call multiple times.

**Endpoint**: `POST https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/process-referral`

**When Called**: Called internally by `payu-webhook` (fire-and-forget) after every successful payment ≥₹100

**Request Body**:
```json
{
  "customer_id": "uuid-of-paying-customer"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "message": "Referral reward processed",
  "coins_awarded": 50
}
```

**Logic**:
1. Look up `referrals` table for this user as referee (`referee_id = customer_id`, status = `pending`)
2. If no referral record found → skip (not a referred user) → `{ success: true, message: "No referral found" }`
3. Check: has this user made a previous qualifying payment? If yes → skip (already processed)
4. Call DB function `process_referral_reward(referral_id)` which atomically:
   - Adds 50 coins to referrer's balance (`momo_coin_balances` + `coin_transactions`)
   - Adds 50 coins to referee's balance
   - Updates `referrals.status = 'completed'`
   - Uses `FOR UPDATE` row lock to prevent double-reward races
5. Return success

**Idempotency**: If called multiple times for same `customer_id`, the `UNIQUE(referee_id)` + status check ensures coins are only awarded once.

**Security**: JWT verification enabled (called with service-role internally, not exposed to clients).

**File**: `supabase/functions/process-referral/index.ts`

### 2. payu-webhook (Payment Processing)

**Purpose**: Process payment confirmation from PayU, calculate commission, award/redeem coins

**Endpoint**: `POST https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook`

**When Called**: PayU sends POST request after payment completion (success/failure)

**PayU Webhook URL Configuration**:
```
Success URL: https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook
Failure URL: https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/payu-webhook
```

**Request** (form-urlencoded from PayU):
```
key=U1Zax8
txnid=transaction-uuid
amount=200.00
productinfo=MomoPe Payment
firstname=Mohan
email=user@example.com
mihpayid=123456789
status=success
hash=abc123...
```

---

#### Implementation Logic

```typescript
// supabase/functions/payu-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createHmac } from "https://deno.land/std@0.168.0/node/crypto.ts"

serve(async (req) => {
  const formData = await req.formData()
  const params = Object.fromEntries(formData)
  
  // 1. CRITICAL: Verify PayU signature (prevent fraud)
  const { key, txnid, amount, productinfo, firstname, email, 
          mihpayid, status, hash: receivedHash } = params
  
  const salt = Deno.env.get('PAYU_SALT')!
  const data = `${salt}|${status}||||||||||${email}|${firstname}|${productinfo}|${amount}|${txnid}|${key}`
  const expectedHash = createHmac('sha512', salt).update(data).digest('hex')
  
  if (expectedHash !== receivedHash) {
    console.error('⚠️ Invalid PayU signature')
    return new Response('Unauthorized', { status: 401 })
  }
  
  // 2. Handle failure status
  if (status !== 'success') {
    await updateTransactionStatus(txnid, 'failed')
    return new Response('OK', { status: 200 })
  }
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )
  
  // 3. Fetch transaction and merchant details
  const { data: txn } = await supabase
    .from('transactions')
    .select('*, merchants(commission_rate)')
    .eq('id', txnid)
    .single()
  
  if (!txn || txn.status !== 'initiated') {
    return new Response('Transaction not found', { status: 404 })
  }
  
  // 4. Calculate commission breakdown
  const commissionRate = txn.merchants.commission_rate
  const totalCommission = txn.gross_amount * commissionRate
  const coinsEarned = Math.floor(txn.fiat_amount * 0.10)
  const rewardCost = coinsEarned * 1.0
  const netRevenue = totalCommission - rewardCost
  
  // 5. Call atomic database function (ALL or NOTHING)
  const { error } = await supabase.rpc('process_transaction_success', {
    p_transaction_id: txnid,
    p_user_id: txn.user_id,
    p_total_commission: totalCommission,
    p_reward_cost: rewardCost,
    p_net_revenue: netRevenue,
    p_coins_to_redeem: txn.coins_applied,
    p_coins_to_earn: coinsEarned,
    p_payu_txnid: mihpayid
  })
  
  if (error) {
    console.error('❌ Transaction processing failed:', error)
    return new Response('Internal error', { status: 500 })
  }
  
  console.log(`✅ Transaction ${txnid} processed successfully`)
  return new Response('OK', { status: 200 })
})
```

**Database Function Called**:
```sql
CREATE FUNCTION process_transaction_success(...) RETURNS VOID AS $$
BEGIN
  -- 1. Redeem coins (FIFO from oldest batches)
  PERFORM redeem_coins_fifo(p_user_id, p_coins_to_redeem, p_transaction_id);
  
  -- 2. Award new coins (create new batch, expiry = NOW() + 90 days)
  PERFORM award_coins(p_user_id, p_coins_to_earn, p_transaction_id);
  
  -- 3. Insert commission record
  INSERT INTO commissions (transaction_id, merchant_id, total_commission, reward_cost, net_revenue)
  VALUES (p_transaction_id, ..., p_total_commission, p_reward_cost, p_net_revenue);
  
  -- 4. Update transaction status
  UPDATE transactions
  SET status = 'success', completed_at = NOW(), payu_mihpayid = p_payu_txnid
  WHERE id = p_transaction_id;
END;
$$ LANGUAGE

 plpgsql;
```

**CRITICAL**: Entire operation is atomic (PostgreSQL transaction). If ANY step fails, ALL changes rollback.

---

### 3. process-expiry (Coin Expiry Cron)

**Purpose**: Mark 90-day old coin batches as expired, reduce user balances

**Endpoint**: `POST https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/process-expiry`

**Trigger**: Supabase Cron Schedule

**Cron Configuration**:
```sql
-- Run daily at 2:00 AM IST (20:30 UTC previous day)
SELECT cron.schedule(
  'expire-old-coins',
  '30 20 * * *',  -- 8:30 PM UTC = 2:00 AM IST next day
  $$
  SELECT net.http_post(
    url := 'https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/process-expiry',
    headers := '{"Authorization": "Bearer SERVICE_ROLE_KEY"}'::jsonb
  )
  $$
);
```

**Status**: ⏳ Cron job configuration pending (scheduled for post-MVP)

---

#### Implementation Logic

```typescript
// supabase/functions/process-expiry/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )
  
  // 1. Fetch expired batches (batch size: 1000 to prevent timeout)
  const { data: batches } = await supabase
    .from('coin_batches')
    .select('id, user_id, amount')
    .lt('expiry_date', new Date().toISOString())
    .eq('is_expired', false)
    .limit(1000)
  
  if (!batches || batches.length === 0) {
    console.log('✅ No batches to expire')
    return new Response(JSON.stringify({ expired: 0 }), { 
      headers: { "Content-Type": "application/json" } 
    })
  }
  
  let expiredCount = 0
  
  for (const batch of batches) {
    // 2. Mark batch as expired
    await supabase
      .from('coin_batches')
      .update({ is_expired: true, amount: 0 })
      .eq('id', batch.id)
    
    // 3. Record expiry transaction
    await supabase
      .from('coin_transactions')
      .insert({
        user_id: batch.user_id,
        batch_id: batch.id,
        type: 'expire',
        amount: -batch.amount,
        description: '90-day expiry'
      })
    
    // 4. Update user balance
    await supabase.rpc('subtract_coins', {
      p_user_id: batch.user_id,
      p_amount: batch.amount
    })
    
    expiredCount++
  }
  
  console.log(`✅ Expired ${expiredCount} coin batches`)
  return new Response(JSON.stringify({ expired: expiredCount }), { 
    headers: { "Content-Type": "application/json" } 
  })
})
```

**Batch Processing**: Processes 1,000 batches per run to prevent Lambda timeout. If \u003e1,000 expired batches exist, next day's cron will process remaining.

**Notifications** (Future): Send push notification to users 15 days before expiry

---

### Edge Function Monitoring

**Logs Access**:
```powershell
# View real-time logs
supabase functions logs payu-webhook --tail

# View specific function logs
supabase functions logs sync-user
```

**Metrics to Track**:
- Invocation count (requests/day)
- Error rate (% failed)
- Execution time (p50, p95, p99)
- PayU webhook signature failures (security alert)

**Alerts** (Future - Supabase Dashboard):
- Alert if `payu-webhook` error rate > 5%
- Alert if `sync-user` latency > 2 seconds
- Alert if `process-expiry` expires > 10,000 coins in single run (fraud detection)

---

## 17. Deployment Architecture

### Production Environment Setup (Current State)

**Backend Deployment**: February 15, 2026  
**Mobile Apps**: February 20, 2026  
**Status**: ✅ **Fully Deployed — Backend, Web Platform & Mobile Apps**

---

### Environment Structure

```
MomoPe Production Stack
├── Backend (Supabase Cloud - Mumbai)
│   ├── Database: PostgreSQL 15.x ✅ (10 migrations applied)
│   ├── Edge Functions: 3 deployed ✅ (payu-webhook, process-referral, process-expiry)
│   ├── Authentication: Google Sign-In via Supabase Native Auth ✅
│   ├── Referral System: End-to-end (DB + Edge Function) ✅
│   └── Storage: Not configured yet
│
├── Authentication (Supabase Native — NOT Firebase Auth)
│   ├── Google Sign-In: Enabled ✅
│   ├── Customer App: OAuth Configured ✅
│   └── Merchant App: OAuth Configured ✅
│   (Firebase project kept ONLY for google-services.json SHA-1 config)
│
├── Payments (PayU)
│   ├── Mode: Test ✅
│   ├── Merchant Key: U1Zax8 ✅
│   └── Webhook: Configured ✅
│
├── Web Platform (Vercel)
│   ├── URL: https://momope.com ✅
│   ├── Framework: Next.js 15 ✅
│   └── Repo: GitHub Connected ✅
│
└── Mobile Apps (Flutter)
    ├── Customer App: ✅ RUNNING ON DEVICE (Full referral system live)
    └── Merchant App: ✅ RUNNING ON DEVICE (Dashboard + QR live)
```

---

### Environment Variables (.env Configuration)

**Production .env File** (Located: `c:\DRAGON\MomoPe\.env`):

```bash
# ============================================================================
# SUPABASE (PRODUCTION)
# ============================================================================
SUPABASE_URL=https://wpnngcuoqtvgwhizkrwt.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_DB_PASSWORD=j7z8dY9KKMG9rodC

# ============================================================================
# FIREBASE (PRODUCTION)
# ============================================================================
FIREBASE_PROJECT_ID=momope-production
FIREBASE_API_KEY=<from Firebase console>

# ============================================================================
# PAYU (TEST MODE)
# ============================================================================
PAYU_MERCHANT_KEY=U1Zax8
PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
PAYU_MODE=test
PAYU_CLIENT_ID=300bf75e2b1447c1a3da46a1d1e18b0f9c9a0710e39de85dfdc49e11c43df7e2
PAYU_CLIENT_SECRET=883027729623a6b8ec3e4a3a70dc710d297a59f0f96fda3f55e00f33800d0a77
```

**Security Notes**:
- ✅ `.env` file is gitignored
- ✅ Secrets stored in Supabase via CLI (`supabase secrets set`)
- ⚠️ Never commit `.env` to version control
- ⚠️ SERVICE_ROLE_KEY has full database access (use carefully)

---

### Google Services Configuration Files

**Customer App**: `customer_app/android/app/google-services.json` ✅  
**Merchant App**: `merchant_app/android/app/google-services.json` ✅

**Package Names**:
- Customer: `com.momope.customer_app`
- Merchant: `com.momope.merchant`

**Configuration**: Both apps registered in Firebase console for Google OAuth SHA-1 fingerprint configuration only.  
**Authentication Provider**: Supabase Native Auth (Google Sign-In) — NOT Firebase Phone Auth.  
Firebase project is kept alive solely to provide the `google-services.json` that Android requires for Google Sign-In.

---

### Deployment Checklist

#### Backend Deployment (✅ COMPLETED)

```powershell
# 1. Link Supabase project
☑ supabase link --project-ref wpnngcuoqtvgwhizkrwt

# 2. Deploy database migrations
☑ supabase db push  # 10 migrations applied

# 3. Deploy edge functions
☑ supabase functions deploy payu-webhook --no-verify-jwt
☑ supabase functions deploy process-referral   # (verify-jwt enabled by default)
☑ supabase functions deploy process-expiry --no-verify-jwt
# Note: sync-user was removed (Firebase Auth removed; Google OAuth native to Supabase)

# 4. Set environment secrets
☑ supabase secrets set PAYU_MERCHANT_KEY=U1Zax8
☑ supabase secrets set PAYU_SALT=BaYKhBYXBAmIJ9w9XUb3KZ8gQsj9SHWt
☑ supabase secrets set SUPABASE_URL=...
☑ supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
☑ supabase secrets set SUPABASE_ANON_KEY=...
☑ supabase secrets set SUPABASE_DB_URL=...

# 5. Verify deployment
☑ supabase functions list  # 3 functions ACTIVE
☑ supabase secrets list    # 6 secrets configured
```

**Status**: ✅ All backend infrastructure deployed and operational

---

#### Mobile App Deployment (✅ COMPLETED — Running on Device)

**Customer App** (`c:\DRAGON\MomoPe\customer_app`):
```powershell
# All steps complete — app running on physical Android device
☑ google-services.json configured (customer_app/android/app/)
☑ flutter pub get
☑ Supabase + Google Sign-In initialized
☑ Referral system end-to-end tested
☑ flutter run (physical device)

# Next: Production build
☐ flutter build apk --release
☐ Upload to Google Play Internal Testing
```

**Merchant App** (`c:\DRAGON\MomoPe\merchant_app`):
```powershell
# All steps complete — app running on physical Android device
☑ google-services.json configured (merchant_app/android/app/)
☑ flutter pub get
☑ Supabase + Google Sign-In initialized
☑ Dashboard + QR code display tested
☑ flutter run (physical device)

# Next: Production build
☐ flutter build apk --release
☐ Upload to Google Play Internal Testing
```

---

### Production URLs & Access

| Service | URL | Access |
|---------|-----|--------|
| **Supabase Dashboard** | https://app.supabase.com/project/wpnngcuoqtvgwhizkrwt | Login with Google |
| **Supabase API** | https://wpnngcuoqtvgwhizkrwt.supabase.co | Public |
| **Edge Functions** | https://wpnngcuoqtvgwhizkrwt.supabase.co/functions/v1/{name} | Public |
| **Firebase Console** | https://console.firebase.google.com/project/momope-production | Login with Google |
| **PayU Dashboard** | https://dashboard.payu.in | Test credentials |

---

### Monitoring & Observability

#### Supabase Monitoring

**Database Metrics** (View in Dashboard → Database):
- Active connections
- Query performance (slow queries)
- Table sizes
- Index usage

**Edge Function Metrics** (View in Dashboard → Edge Functions):
- Invocation count (last 24h, 7d, 30d)
- Error rate
- Execution time (p50, p95, p99)
- Logs (real-time streaming)

**CLI Monitoring**:
```powershell
# View function logs
supabase functions logs payu-webhook --tail

# Check database status
supabase db status

# View all secrets
supabase secrets list
```

---

#### Firebase Monitoring

**Authentication Metrics** (Firebase Console → Authentication):
- Daily active users
- Sign-in success rate
- OTP delivery rate

**Crash Reporting** (Future - Firebase Crashlytics):
- App crashes (customer_app, merchant_app)
- ANRs (Application Not Responding)
- Fatal errors

---

### Rollback Procedures

#### Database Rollback

```powershell
# View migration history
supabase migrations list

# Rollback last migration (if needed)
supabase db reset

# Re-apply specific migration
supabase migrations up 001_initial_schema.sql
```

**WARNING**: Database rollbacks can cause data loss. Always backup before rollback.

---

#### Edge Function Rollback

```powershell
# Deploy previous version
supabase functions deploy payu-webhook --no-verify-jwt

# Or manually revert code and redeploy
git checkout <previous-commit>
supabase functions deploy payu-webhook --no-verify-jwt
```

---

### Operational Procedures

#### Daily Operations

**Morning Checklist** (9 AM IST):
- [ ] Check Supabase Dashboard for errors (last 24h)
- [ ] Review `process-expiry` cron logs (ran at 2 AM)
- [ ] Check coverage ratio (should be >75%)
- [ ] Review PayU settlement report (if any)

**Evening Checklist** (6 PM IST):
- [ ] Review transaction count (should match customer reports)
- [ ] Check edge function error rates (<5%)
- [ ] Backup database manually (weekly on Fridays)

---

#### Weekly Operations

**Every Monday**:
- [ ] Review merchant payables (prepare settlement batch)
- [ ] Check for pending KYC approvals
- [ ] Review coverage ratio trend (weekly chart)

**Every Friday**:
- [ ] Manual database backup (Supabase Dashboard → Database → Backup)
- [ ] Export transaction report (CSV for accounting)
- [ ] Process merchant settlements (if any)

---

### Disaster Recovery

#### Backup Strategy

**Automated Backups** (Supabase):
- Frequency: Daily (2 AM IST)
- Retention: 7 days (free tier)
- Location: Supabase Cloud (Mumbai region)

**Manual Backups**:
```powershell
# Export entire database
supabase db dump -f backup_$(date +%Y%m%d).sql

# Store in Google Drive (weekly)
# Location: MomoPe → Backups → database_backups/
```

---

#### Recovery Procedures

**Scenario 1: Database Corruption**
1. Identify corruption (specific table or entire DB)
2. Restore from latest Supabase backup (Dashboard → Database → Backups)
3. Verify data integrity (run SELECT queries)
4. Reconcile with PayU settlement reports (if transactions affected)
5. Notify affected users (if applicable)

**Scenario 2: Edge Function Failure**
1. Check function logs (`supabase functions logs`)
2. Identify error (code bug, secret misconfiguration, etc.)
3. Fix code or secret
4. Redeploy function
5. Verify with test request

**Scenario 3: Complete Supabase Outage**
1. Check Supabase status page (https://status.supabase.com)
2. If prolonged, switch to fallback (NOT CONFIGURED YET)
3. Communicate with users (app banner, email)
4. Monitor Supabase updates
5. Post-recovery: Reconcile all transactions

---

### Cost Management

**Current Costs** (February 2026):

| Service | Plan | Monthly Cost |
|---------|------|--------------|
| **Supabase** | Pro | $25/month |
| **Firebase** | Spark (Free) | $0 ⚠️ (upgrade if >10K users) |
| **PayU** | Per-transaction | 2-3% MDR |
| **Google Play** | One-time | $25 (already paid) |
| **Domain** (future) | momope.com | ~$12/year |

**Total Monthly**: ~$25 + transaction fees

**Scaling Costs** (Projected):

| Users | Supabase | Firebase | Total/Month |
|-------|----------|----------|-------------|
| 0-1K | Pro ($25) | Free | $25 |
| 1K-10K | Pro ($25) | Free | $25 |
| 10K-50K | Pro ($25) | Blaze Pay-as-go (~$50) | $75 |
| 50K-100K | Team ($599) | Blaze (~$200) | $799 |

---

### Security Hardening

**Production Security Checklist**:

- [x] RLS enabled on all tables
- [x] SERVICE_ROLE_KEY not exposed in client code
- [x] PayU webhook signature verification
- [x] Firebase token validation in sync-user
- [ ] Rate limiting on edge functions (TODO)
- [ ] IP whitelisting for admin dashboard (TODO)
- [ ] 2FA for Supabase/Firebase console access (RECOMMENDED)
- [ ] Regular security audits (quarterly)

---

### Next Steps (Post-MVP)

1. **Setup Cron Job** for `process-expiry` (pg_cron + HTTP trigger)
2. **Add Monitoring Alerts** (Supabase webhooks → Slack/Email)
3. **Implement Rate Limiting** on edge functions (prevent abuse)
4. **Setup Staging Environment** (separate Supabase project)
5. **Add Firebase Cloud Messaging** for push notifications
6. **Configure Supabase Storage** (for merchant KYC documents)
7. **Setup CI/CD Pipeline** (GitHub Actions → Auto-deploy)

---

## 18. Payment Integration

**Trigger**: POST from PayU after payment

**Logic**:
1. Validate PayU signature (CRITICAL)
2. Fetch merchant commission_rate
3. Calculate:
   - total_commission = gross × rate
   - coins_earned = floor(fiat × 0.10)
   - reward_cost = coins_earned × 1.0
   - net_revenue = total_commission - reward_cost
4. Insert into commissions table
5. Insert coin transactions (redeem/earn)
6. Update transaction status = 'success'

**Security**: HMAC-SHA512 signature validation required

### 3. process-expiry

**Purpose**: Daily cron job to expire 90-day old coins

**Trigger**: Scheduled (daily 2 AM IST)

**Logic**:
1. Query coin_batches where expiry_date < NOW()
2. Mark as expired
3. Insert coin_transactions (type='expire', negative amount)
4. Update momo_coin_balances (reduce total_coins)

**Batch Size**: 1,000 batches per run (prevents timeout)

---

## 17. Payment Integration

### PayU Integration (To Be Implemented)

**SDK**: PayU Flutter SDK

**Hash Gencration**:
```dart
String generateHash(String txnid, String amount, String productinfo) {
  String data = "$merchantKey|$txnid|$amount|$productinfo|$firstName|$email|||||||||||$salt";
  return sha512(data);
}
```

**Payment Flow**:
1. User confirms payment in MomoPe
2. Insert transaction (status='initiated')
3. Generate PayU hash
4. Redirect to PayU SDK/Web Checkout
5. User completes payment (UPI/Card/etc)
6. PayU sends webhook to MomoPe backend
7. Webhook validates, updates transaction status
8. Returns success to app

**Webhook URL**: `https://<project>.supabase.co/functions/v1/payu-webhook`

---

# Part IV: Financial Framework

## 18. Treasury Management

### Reserve Pool Strategy

**Objective**: Maintain liquidity to honor all coin redemptions

**Required Reserve**: **60% of Total Coin Liability**

**Formula**:
```
Reserve Amount (₹) = Total Outstanding Coins × 0.60
```

**Example**:
```
Total Coins: 5,000,000 (₹50,00,000)
Required Reserve: ₹50,00,000 × 0.60 = ₹30,00,000
```

### Rolling Reserve Model

**Per Transaction**:
```
Commission Earned = Gross × Commission_Rate
User Reward Cost = Fiat × 0.10
Net Commission = Commission Earned - User Reward Cost

Reserve (60%) = Net Commission × 0.60 → Coin Reserve Account
Operating Revenue (40%) = Net Commission × 0.40 → Operating Account
```

**Bank Account Structure**:
```
MomoPe Accounts:
├─ Operating Account (primary)
│  └─ 40% of net commission
├─ Coin Reserve Account (restricted) ⭐
│  └─ 60% of net commission
└─ Merchant Payout Account (if T+1 settlements)
   └─ Working capital float
```

---

## 19. Liability Model

### Coverage Ratio

**Definition**: Measure of liquidity health

**Formula**:
```
Coverage Ratio = (Unsettled Commission Pool) / (Total Coin Liability)
```

**SQL Query**:
```sql
WITH liability AS (
  SELECT SUM(total_coins) AS total
  FROM momo_coin_balances
),
pool AS (
  SELECT SUM(momope_revenue) AS reserve
  FROM commissions
  WHERE NOT is_settled
)
SELECT 
  ROUND((pool.reserve / liability.total) * 100, 2) AS coverage_percent
FROM liability, pool;
```

**Thresholds**:
| Ratio | Status | Action |
|-------|--------|--------|
| ≥100% | Excellent | No action |
| 75-99% | Adequate | Monitor |
| 60-74% | Caution | Reduce rewards temporarily |
| <60% | Critical | Freeze coin issuance |

---

## 20. Merchant Settlement

### The Settlement Challenge

**Example Transaction**:
```
Bill Amount: ₹1,000
Merchant Commission: 20%
Customer Coins Applied: 800 coins (₹800)
Fiat Payment via PayU: ₹200

Financial Breakdown:
├─ Commission Earned: ₹200
├─ Merchant Net Due: ₹800 (₹1,000 - ₹200)
├─ PayU Processes: ₹200 (fiat only)
└─ Gap to Fund: ₹600 (₹800 - ₹200)
```

**Critical Question**: PayU only collects ₹200, but merchant is owed ₹800. Where does the ₹600 come from?

**Answer**: MomoPe's **Commission Pool** (accumulated from previous transactions).

### Settlement Architecture: MomoPe as Aggregator

**Model**: MomoPe settles merchants directly via bank transfer, funded by commission pool.

**Complete Flow**:
```
┌──────────────────────────────────────────┐
│ Day 0: Transaction Occurs                │
│ Customer: 800 coins + ₹200 → Merchant    │
└─────────────┬────────────────────────────┘
              │
    ┌─────────▼─────────┐
    │ PayU Processes    │
    │ ₹200 (fiat only)  │
    └─────────┬─────────┘
              │ T+2 Settlement
              ▼
    ┌───────────────────────────────┐
    │ MomoPe Settlement Account     │
    │ Receives: ₹200 (from PayU)    │
    │ + ₹600 (from Commission Pool) │
    │ = ₹800 total                  │
    └─────────┬─────────────────────┘
              │ T+3 Settlement
              ▼
    ┌───────────────────────────────┐
    │ Merchant Bank Account         │
    │ Receives: ₹800 (NEFT)         │
    └───────────────────────────────┘
```

### Three-Account Bank Structure

**Required Bank Accounts**:
```
MomoPe Banking Structure:
├─ 1. Operating Account (Primary)
│  └─ Day-to-day expenses, salaries
│
├─ 2. Coin Reserve Account (Liability Coverage)
│  └─ 60% of net commission retained
│  └─ ONLY for coin redemption coverage
│
└─ 3. Merchant Settlement Account (Payout Float)
   └─ Receives PayU settlements (T+2)
   └─ Funds merchant payouts (T+3)
   └─ Working capital: ₹2-5L buffer
```

### Technical Implementation

**New Table: `merchant_payables`**:
```sql
CREATE TABLE merchant_payables (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  merchant_id UUID NOT NULL REFERENCES merchants(id),
  transaction_ids UUID[] NOT NULL,
  gross_amount DECIMAL(10,2) NOT NULL,
  commission_amount DECIMAL(10,2) NOT NULL,
  net_amount DECIMAL(10,2) NOT NULL,
  fiat_received DECIMAL(10,2) NOT NULL, -- From PayU
  coin_portion DECIMAL(10,2) NOT NULL,  -- From pool
  settlement_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  bank_transfer_ref VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  settled_at TIMESTAMPTZ
);
```

**Settlement Cron Job** (Tuesday/Friday 10 AM):
1. Aggregate all T+3 transactions per merchant
2. Calculate net payout (gross - commission)
3. Calculate funding split (PayU fiat + Pool contribution)
4. Create `merchant_payables` record
5. Initiate NEFT/IMPS transfer (via Razorpay Payout API)
6. Update `transactions.settled_at`
7. Mark `commissions.is_settled = true`
8. Send settlement email to merchant

### Settlement Timing Options

**T+3 (Recommended)** ⭐:
- ✅ Zero working capital (PayU settles before merchant payout)
- ✅ Industry standard (Swiggy: T+7, Zomato: T+5)
- ✅ Time for fraud detection and refunds
- ⚠️ Merchant may prefer faster

**T+1 (Premium Tier)**:
- ✅ Better merchant experience
- ❌ Requires ₹10L working capital
- 💰 Fee: 0.5% of settlement amount
- Eligibility: >₹5L monthly GMV, 90-day track record

**T+0 (Not Recommended)**:
- ❌ Requires ₹24L working capital (3-day float)
- ❌ High fraud risk (chargebacks after payout)
- ❌ High transaction fees (IMPS per transfer)

### Liquidity Management

**Working Capital Calculation**:
```
Daily Settlement Float = Avg Daily GMV × (1 - Avg Fiat %) × (1 - Avg Commission %)

Example (High Redemption Day):
- 100 txns @ ₹1,000 avg
- 70% coin redemption avg
- 20% commission avg

Float = ₹1,00,000 × (1 - 0.30) × (1 - 0.20)
      = ₹1,00,000 × 0.70 × 0.80
      = ₹56,000 per day

Safety Buffer: 3 days × ₹56,000 = ₹1,68,000

Recommended Reserve: ₹2,00,000 in Settlement Account
```

**Automated Pool Transfer** (Daily):
```
IF (Settlement Account Balance < ₹2,00,000) THEN
  Transfer shortfall from Coin Reserve Account
  Alert CFO if reserve also depleting
END IF
```

### Merchant Communication

**Settlement Email Template**:
```
Subject: MomoPe Settlement - ₹40,000 Processed

Dear Fresh Mart Supermarket,

Your settlement for 25 transactions is now processed.

Settlement Summary:
─────────────────────
Period: Feb 10-13, 2026
Gross GMV: ₹50,000
Commission (20%): ₹10,000
Net Settlement: ₹40,000

Payment Details:
─────────────────────
Bank Account: XXXX1234
NEFT Reference: NEFT12345678
Transfer Date: Feb 14, 2026

Breakdown:
─────────────────────
Customer Fiat Paid: ₹15,000
Coins Redeemed: ₹35,000 (funded by MomoPe)

Download detailed statement: [PDF Link]

Questions? Reply to this email or call support.
```

### Reconciliation & Compliance

**Daily Reconciliation Check**:
```sql
-- Verify PayU settlements = Expected fiat
SELECT 
  DATE(completed_at) AS date,
  SUM(fiat_amount) AS expected_from_payu,
  -- Compare with PayU settlement report
FROM transactions
WHERE status = 'success'
  AND completed_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(completed_at);

-- Verify merchant payouts = Net amounts
SELECT 
  settlement_date,
  SUM(net_amount) AS merchant_payouts,
  -- Compare with bank statement debits
FROM merchant_payables
WHERE status = 'completed'
  AND settlement_date >= NOW() - INTERVAL '7 days'
GROUP BY settlement_date;
```

**Audit Trail Requirements**:
1. PayU transaction ID → MomoPe transaction ID (1:1 mapping)
2. Merchant payables → Bank transfer UTR (proof of payment)
3. Commission pool balance vs coin liability (coverage ratio)

### Risk Mitigation

**Risk 1: Insufficient Liquidity**
- Alert: Settlement Account < ₹1,00,000
- Action: Auto-transfer from Coin Reserve, notify CFO

**Risk 2: High Redemption Spike**
- Alert: Daily coin redemption > 2× rolling average
- Action: Investigate fraud, temporarily reduce rewards

**Risk 3: Payout Failure**
- Scenario: NEFT fails (wrong account, bank down)
- Action: Mark as 'failed', retry next cycle, notify merchant

### Integration: Manual NEFT via HDFC Net Banking (FREE)

**Approach**: Manual bulk upload (NO Razorpay) - ₹0 cost

**Settlement Flow**:
1. **Automated**: Settlement cron runs bi-weekly (Tuesday/Friday)
2. **Automated**: Creates `merchant_payables` records (status='pending')
3. **Automated**: Generates CSV with merchant bank details
4. **Manual**: Download CSV from settlement API
5. **Manual**: Login to HDFC Net Banking → Bulk Upload → NEFT
6. **Manual**: Upload CSV, approve with OTP
7. **Manual**: Mark payables as 'completed' in admin dashboard

**CSV Format**:
```csv
Beneficiary Name,Account Number,IFSC Code,Amount,Purpose,Email,Payable ID
Fresh Mart,1234567890,HDFC0001234,40000.00,MomoPe Settlement 25 txns,[email protected],uuid-123
```

**Time Investment**: 10-30 minutes per settlement (depending on merchant count)

**Cost**: **₹0** (HDFC doesn't charge for NEFT)

**Alternative (Future)**: Razorpay Payout API (₹3-5 per transfer, upgrade when 100+ merchants)

```typescript
// Manual CSV generation (already implemented)
async function generateSettlementCSV(payables) {
  const csvRows = ["Beneficiary Name,Account Number,IFSC Code,Amount,Purpose,Email,Payable ID"];
  
  payables.forEach(p => {
    csvRows.push([
      p.merchant_name,
      p.account_number,
      p.ifsc_code,
      p.net_amount.toFixed(2),
      `MomoPe Settlement ${p.txn_count} txns`,
      p.email,
      p.id
    ].join(","));
  });
  
  return csvRows.join("\n");
}
```

**Manual NEFT Process**: See `c:\MomoPe\.company\manual_neft_guide.md`

### Key Takeaways

**How Settlement Works**:
1. PayU processes fiat portion only (₹200)
2. PayU settles to MomoPe Settlement Account (T+2)
3. MomoPe adds commission pool funds (₹600)
4. MomoPe transfers full net amount to merchant (₹800, T+3)
5. Merchant receives fiat only (never coins)

**Why This Model Works**:
- Commission pool accumulates from all transactions
- High-fiat transactions fund high-coin transactions
- 60% reserve ensures liquidity coverage
- T+3 timing eliminates working capital need

**Compliance**: Clear separation of coin ledger (liability) vs bank transfers (settlement). MomoPe acts as technology aggregator, not PSP.

---

## 21. Reserve Strategy

### Reserve Release Mechanism

**Condition**: Coverage Ratio > 150%

**Formula**:
```
IF (Coverage Ratio > 150%) THEN:
  Target Reserve = Coin Liability × 1.5
  Excess = Commission Pool - Target Reserve
  Monthly Release Cap = Commission Pool × 0.10
  
  Releasable Amount = min(Excess, Monthly Release Cap)
END IF
```

**Example**:
```
Coin Liability: ₹50L
Commission Pool: ₹80L
Coverage: 160%

Target: ₹50L × 1.5 = ₹75L
Excess: ₹80L - ₹75L = ₹5L
Monthly Cap: ₹80L × 0.10 = ₹8L

Release: min(₹5L, ₹8L) = ₹5L to Operating Account
```

**Release Schedule**: First week of each month (via CFO approval)

---

## 22. Risk Management

### Stress Testing

**Scenario: 70% Bank Run**

**Assumptions**:
- 70% of users redeem simultaneously
- Average 80% of balance (max allowed)
- No new transactions

**Calculation** (for ₹50L liability):
```
Stressed Users: 70% × 10,000 = 7,000
Avg Balance: 500 coins
Avg Redemption: 400 coins (80%)
Total Demand: 7,000 × 400 = 28,00,000 coins (₹28L)

Required Pool: ₹28L
Actual Pool (70% coverage): ₹35L
Surplus: ₹7L ✅ (System survives)
```

### Risk Alerts (Automated)

**Alert 1: Coverage < 75%**
- Severity: High
- Notification: CFO Email
- Action: Review reserve strategy

**Alert 2: Redemption Spike**
- Trigger: Today > 2× 30-day average
- Severity: Medium
- Action: Investigate fraud/abuse

**Alert 3: Systemic Risks**
- Coverage down for 60+ days
- Merchant churn >25% quarterly
- Net coin growth >20% MoM for 3 months
- Action: Board escalation

---

# Part V: Product Features

## 23. Customer App

### Core Features (✅ Live as of February 20, 2026)

**Home Screen** (`home_screen.dart`):
- Premium coin balance card (large, prominent — teal gradient)
- Live **Referral Stats Card** — shows "X friends invited · Y coins earned" from Supabase `referral_stats` view in real-time (replaces static banner)
- Transaction history preview (real data from Supabase)
- Quick actions row (Pay, Scan, Rewards, Invite)
- QR scan card

**Scan & Pay**:
- QR scanner (camera integration via `mobile_scanner`)
- Manual amount entry
- Coin application slider (draft — PayU redirect pending final integration)
- Payment breakdown preview
- PayU integration (redirect)

**Transaction History**:
- Filterable (date, merchant, amount)
- Coin earned/redeemed tags
- Real-time Supabase data

**Profile**:
- Google account name & email
- Notification settings
- Logout

**Referral System** (`lib/features/referral/`) — ✅ **FULLY IMPLEMENTED**:
- **ReferralScreen** — Premium redesign:
  - `SliverAppBar` gradient hero section
  - Live stats tiles (friends invited, coins earned) from `referral_stats` Supabase view
  - 4-step visual explainer with dotted step connectors
  - Large animated referral code card with copy-to-clipboard feedback
  - "Share & Invite Friends" button with rich pre-formatted message via `share_plus`
- **Reward Logic** (per the referral rules):
  - Referrer gets **50 coins** after referee's first qualifying fiat payment (≥₹100)
  - Referee gets **50 coins** at same time
  - Processed atomically by `process_referral_reward()` DB function
  - Triggered by `payu-webhook` → `process-referral` (fire-and-forget, non-blocking)
  - Duplicate prevention: `UNIQUE(referee_id)` + status check before awarding

### Upcoming Features (Q2 2026)

- Onboarding referral code entry field (new users enter referral code at signup)
- Push notifications (coin expiry alerts, referral rewards)
- Merchant favorites
- Transaction search
- Receipt download (PDF)

---

## 24. Merchant App

### Core Features

**Home Screen**:
- Today's transactions count/value
- Pending settlement amount
- QR code (prominent, printable)

**Transaction List**:
- Real-time updates
- Filter by date/status
- Transaction details (gross, commission, fiat, coins)

**Settlement**:
- Upcoming settlement schedule
- Past settlements list
- Download statements (CSV/PDF)

**Profile**:
- Business info
- Commission rate (view-only)
- Bank details
- Support contact

### Upcoming Features (Q2 2026)

- Analytics dashboard (peak hours, customer demographics)
- Promotional offers (temporary cashback boost)
- Multi-outlet management

---

## 25. Super Admin Dashboard

### Launch: Q2 2026 (13-week development)

**Module 1: Treasury Control**
- Real-time coin liability counter
- Coverage ratio gauge (color-coded)
- Expiry calendar (30/60/90 days)
- Commission pool balance
- Redemption velocity chart
- Manual reserve release (with approval)
- Emergency freeze button

**Module 2: Merchant Management**
- Merchant approval workflow
- KYC document viewer
- Commission rate editor (with audit log)
- Settlement schedule manager
- Merchant suspend/reactivate

**Module 3: Transaction Oversight**
- Transaction explorer (search/filter)
- Fraud marking
- Refund initiation (with coin reversal)
- Export to CSV

**Module 4: User Administration**
- User search (phone/email/ID)
- View coin balance, transaction history
- Manual balance adjustment (logged)
- Account suspension
- Audit trail viewer

**Module 5: Analytics & Reports**
- Daily revenue summary
- Monthly commission report
- Coin liability trend (90 days)
- Redemption heatmap
- User cohort analysis
- SQL query builder (advanced users)

---

## 26. Public Website (Deployed)

### Overview: www.momope.com

**Live Date**: February 19, 2026
**Framework**: Next.js 15 (App Router)
**Hosting**: Vercel

**Design Philosophy**: "The Financial OS for Local Commerce"
- **Glassmorphism**: Premium, translucent UI elements
- **Animations**: Framer Motion for scroll-reveals and interactions
- **Typography**: Manrope (Headings) + Inter (Body)
- **Palette**: Deep Navy (#0B0F19) + Teal (#00C4A7) + Orange (#FF9F40)

### Key Page Components

#### 1. Homepage (The "Financial OS" Experience)
- **Hero Section**: 
  - **Headline**: "Scan. Pay. & Earn."
  - **Visual**: 3D Animated Phone Composition (CSS-only construction) showing live transactions and charts.
  - **Floating Elements**: Trust badges (PayU, Secure) and ecosystem coins.
  
- **Ecosystem Explainer**:
  - **Interactive Pillars**: "For You", "For Business", "For Community".
  - **Orbiting Nodes**: Visualizes how money flows within the local economy.
  
- **Social Proof**:
  - **Live Marquee**: Real merchant names from Kadapa (Fresh Mart, Chai Point, etc.).
  - **Testimonials**: Using aesthetic Unsplash imagery for relatable user stories.

#### 2. Merchant Page (/merchant)
- **Value Prop**: "Zero Customer Acquisition Cost"
- **Calculator**: Interactive commission vs. revenue slider.
- **Onboarding**: Integrated lead capture form.

#### 3. Download Strategy
- **Smart Detection**: `MobileDownloadPrompt` detects device OS.
- **Deep Linking**:
  - iOS/Android -> WhatsApp Business (MVP flow)
  - Desktop -> QR Code to scan
- **Sticky CTA**: "Get App" button follows user scroll.

#### 4. Legal & Trust
- **Footer**: Full transparency (CIN, Registered Office, Contact).
- **Compliance**: Terms of Service, Privacy Policy, and Refund Policy pages live.


---

# Part VI: Operations & Compliance

## 27. Compliance Strategy

### Critical Question: Do We Need RBI Licenses?

**Question**: If MomoPe settles merchants via bank transfers (from commission pool), is this Payment Aggregation?

**Answer**: **NO** - MomoPe is a loyalty platform, not a Payment Aggregator.

### Why MomoPe is NOT a Payment Aggregator

**RBI PA Definition**: Entity that collects customer payments and settles to merchants.

**MomoPe Reality**:
```
Payment Aggregator (PA):
├─ Collects customer funds → ✅ (PayU does this)
├─ Holds customer funds → ✅ (PayU does this)
├─ Routes funds to merchants → ✅ (PayU does this)
└─ MomoPe? → ❌ Does NONE of the above

MomoPe Settlement Model:
├─ Customer pays PayU (fiat) → PayU processes
├─ MomoPe records coins (ledger) → Internal accounting
├─ PayU settles to MomoPe → Commission revenue
└─ MomoPe pays merchant → Business expense (own funds)
```

**Critical Distinction**: Settling merchants from **your own revenue** ≠ Payment aggregation

### Regulatory Classification

**MomoPe is**: Technology Service Provider / Loyalty Rewards Platform

**Similar to**:
- CRED (rewards platform, not PA)
- CashKaro (cashback platform, not PA)
- Airline miles programs (not PPI)

**NOT Similar to**:
- Razorpay, PayU (Payment Aggregators - licensed)
- Paytm Wallet (PPI - licensed)

### RBI Payment Aggregator (PA) License

**Required IF**:
- ✅ You collect customer payments
- ✅ You hold customer funds
- ✅ You route payments to merchants

**MomoPe Status**: ❌ Does NOT do any of above → **License NOT Required**

**Requirements** (if ever needed):
- Net worth: ₹15 Cr (₹25 Cr within 3 years)
- Escrow account maintenance
- RBI authorization (6-12 month process)

### RBI Prepaid Payment Instrument (PPI) License

**Required IF** coins are:
- ✅ Loadable with customer money
- ✅ Withdrawable as cash
- ✅ Transferable peer-to-peer
- ✅ Perpetual validity

**MomoPe Coins**: ❌ None of the above → **License NOT Required**

**Why Coins are NOT a PPI**:
1. Cannot load money (earned only via transactions)
2. Cannot withdraw (non-withdrawable)
3. Cannot transfer (non-transferable)
4. 90-day expiry (not perpetual)
5. Merchants receive fiat, not coins

**Classification**: **Promotional Loyalty Units** (like airline miles)

### Legal Structuring to Avoid PA Classification

**Design Principles**:

1. **Never Touch Customer Funds**
   - ✅ PayU processes 100% of customer fiat
   - ❌ Never create "MomoPe Wallet" or "Add Money"

2. **Never Onboard Merchants as Payment Recipients**
   - ✅ Merchants join "MomoPe Rewards Program"
   - ✅ Agreements are "Commission-Based Partnership"
   - ❌ Never position as "Accept Payments via MomoPe"

3. **Settlement is Business Expense**
   - ✅ "Net Settlement" = Gross - Commission (from MomoPe revenue)
   - ❌ Not "Payment routing" from customer to merchant

4. **Clear Positioning**
   - ✅ "MomoPe is a rewards platform"
   - ✅ "Payments via PayU (licensed gateway)"
   - ❌ "Accept payments via MomoPe"

### Required Registrations & Licenses

**1. Company Registration** ✅ **REQUIRED**
- Private Limited Company (or LLP)
- MCA registration
- Cost: ₹20K, 1-2 weeks

**2. GST Registration** ✅ **REQUIRED**
- 18% GST on commission revenue
- Monthly/quarterly returns
- Cost: ₹5K, 1 week

**3. RBI License** ❌ **NOT REQUIRED**
- Not a PA (PayU handles payments)
- Not a PPI (coins are promotional)

**4. Legal Opinion** ⭐ **MANDATORY BEFORE LAUNCH**
- Engage fintech regulatory counsel
- Confirm PA/PPI non-applicability
- Draft merchant agreements
- Cost: ₹3-5L, 3-4 weeks

### Mandatory Legal Opinion (Pre-Launch)

**Scope**:
1. Confirm MomoPe activities do NOT require PA license
2. Confirm Momo Coins are NOT PPI
3. Draft merchant agreement template
4. Review Terms of Service, Privacy Policy
5. GST treatment advice

**Recommended Law Firms**:
- **Tier 1**: Khaitan & Co, Cyril Amarchand Mangaldas, AZB & Partners
- **Tier 2**: IndusLaw, Ikigai Law, Trilegal
- **Boutique**: Artha Law, Agama Law, finserv legal

**Timeline**: 3-4 weeks  
**Cost**: ₹3-5 Lakh

### Merchant Agreement Language (Sample)

**Critical Clause** (to avoid PA classification):

> **5. Payment Processing**  
> 5.1 Merchant acknowledges all customer payments are processed by PayU (licensed PA), not MomoPe.  
> 5.2 MomoPe operates a commission-based rewards program and does NOT collect, hold, or route customer funds.  
> 5.3 Merchant settlements are derived from MomoPe's commission revenue, not customer funds.  
> 5.4 This is NOT a payment processing or payment aggregation arrangement.

### Compliance Checklist (Non-Regulatory)

**Data Privacy (DPDP Act 2023)** ✅ **MANDATORY**:
- [ ] Privacy Policy drafted
- [ ] User consent flow in apps
- [ ] Data minimization (collect only necessary)
- [ ] User rights APIs (data export, deletion)
- [ ] Breach notification (72-hour rule)

**Consumer Protection** ✅ **RECOMMENDED**:
- [ ] Terms of Service (transparent)
- [ ] Coin expiry clearly stated
- [ ] Refund policy
- [ ] Grievance redressal (email/phone)

**KYC/AML (Merchant Onboarding)** ✅ **RECOMMENDED**:
- [ ] Basic merchant KYC (PAN, GST, bank proof)
- [ ] Identity verification (Aadhaar)
- [ ] Bank account verification (penny drop)

**Accounting & Tax** ✅ **MANDATORY**:
- [ ] GST returns (monthly/quarterly)
- [ ] Income tax returns (annual)
- [ ] Audited financials (if turnover >₹1 Cr)

### Escalation Triggers (When License Becomes Required)

**IF MomoPe Starts**:
1. Collecting customer payments directly (bypassing PayU)
2. Holding customer funds in escrow
3. Processing refunds from customer funds
4. Operating "MomoPe Wallet" (load money)

**THEN**: PA License Required

**IF Momo Coins Become**:
1. Loadable with customer money
2. Withdrawable as cash
3. Transferable peer-to-peer
4. Perpetual (no expiry)

**THEN**: PPI License Required

### Pre-Launch Checklist

**Legal** (4-6 weeks):
- [ ] Engage fintech counsel (₹3-5L)
- [ ] Obtain legal opinion (PA/PPI non-applicability)
- [ ] Register Private Limited Company
- [ ] Trademark "MomoPe" (Class 9, 36, 42)

**Contracts** (2-3 weeks):
- [ ] Merchant agreement template (reviewed by counsel)
- [ ] Terms of Service (user-facing)
- [ ] Privacy Policy (DPDP Act compliant)

**Banking** (1-2 weeks):
- [ ] Open 3 business current accounts
- [ ] Set up Razorpay Payout account (NEFT automation)

**Compliance** (1-2 weeks):
- [ ] GST registration
- [ ] Merchant KYC flow
- [ ] Data consent mechanism (apps)

### Total Pre-Launch Investment

**Legal & Compliance**: ₹3.5-6 Lakh
- Legal opinion: ₹3-5L
- Company registration: ₹20K
- GST registration: ₹5K
- Trademark: ₹15K
- Privacy/ToS drafting: ₹1-2L (if outsourced)

**Timeline**: 6-8 weeks

### Risk Assessment

**Regulatory Risk**: **LOW** (if structured correctly)

**Mitigation**:
- Clear separation: PayU = Payments, MomoPe = Rewards
- Legal opinion obtained before launch
- Quarterly compliance review

**Investor Due Diligence**:
- Legal opinion satisfies Series A requirements
- Demonstrates regulatory awareness
- Reduces investment risk

### Key Takeaway

**MomoPe does NOT require RBI license** because:
1. PayU handles payment processing (customer funds)
2. MomoPe settles merchants from own revenue (commission pool)
3. Coins are promotional, not stored value

**BUT**: Formal legal opinion is **MANDATORY** before launch to confirm this classification.

---

## 28. KYC Requirements

### Customer KYC

**Current**: Phone OTP only (Firebase)

**Future** (if coin liability >₹1 Cr):
- Full name, DOB, address
- Aadhaar eKYC (via DigiLocker)
- PAN verification (optional, for high-value users)

### Merchant KYC

**Required Documents**:
- Business registration (GST/PAN)
- Bank account proof (cancelled cheque)
- Identity proof (Aadhaar/PAN of owner)
- Business address proof

**Verification**:
- Manual review by Merchant Manager
- Approval within 48 hours
- Rejection with reason (resubmission allowed)

**Compliance**: Managed by PayU (as settlement partner)

---

## 29. Data Privacy

### DPDP Act Compliance

**Data Minimization**:
- Collect only necessary data
- No unnecessary device metadata

**User Consent**:
- Explicit consent during onboarding
- Privacy policy linked clearly

**User Rights**:
- Right to access (export data)
- Right to deletion (implement in Q2 2026)
- Right to correction (profile editing)

**Data Storage**:
- Encrypted at rest (Supabase default)
- Encrypted in transit (HTTPS/TLS)
- No third-party data sharing (except PayU for payments)

**Retention**:
- Transaction data: 7 years (regulatory requirement)
- User profiles: Until account deletion request
- Coin history: Indefinite (audit trail)

---

## 30. Operational Workflows

### Daily Operations

**Morning (9 AM)**:
- Review overnight transactions
- Check coverage ratio (alert if <75%)
- Verify expiry cron job ran successfully

**Afternoon (2 PM)**:
- Process merchant approvals
- Respond to support tickets

**Evening (6 PM)**:
- Prepare next-day settlement batch (if T+1)
- Review fraud alerts

### Weekly Operations

**Monday**:
- CFO treasury report review
- Coverage ratio trend analysis

**Tuesday/Friday** (if T+3 settlements):
- Execute merchant settlement batch (NEFT)
- Send settlement emails to merchants

**Friday**:
- Weekly revenue report
- User growth metrics update

### Monthly Operations

**First Week**:
- Reserve release evaluation (if coverage >150%)
- Board report preparation

**Third Week**:
- Merchant retention outreach (churned merchants)
- User engagement analysis (inactive users)

---

# Part VII: Growth & Marketing

## 31. Go-to-Market Strategy

### Phase 1: Bangalore Pilot (Months 1-6)

**Target**: 10 merchants, 500 users

**Merchant Acquisition**:
- Direct outreach (founder-led)
- Focus: High-footfall grocery stores, popular cafes
- Value prop: "Get 100 free customers in 30 days"

**User Acquisition**:
- Merchant word-of-mouth
- In-store posters, QR standees
- Initial bonus (100 coins for first transaction)

### Phase 2: Bangalore Expansion (Months 7-12)

**Target**: 100 merchants, 5,000 users

**Merchant Acquisition**:
- Sales team (2 people)
- Category exclusivity (one grocery store per 2km radius)
- Referral program (merchants refer others for bonus)

**User Acquisition**:
- Google Ads (local search)
- Influencer partnerships (micro-influencers)
- Merchant-funded promotions (bonus coin days)

### Phase 3: Tier-1 Expansion (Year 2)

**Cities**: Mumbai, Delhi, Hyderabad, Chennai

**Merchant Acquisition**:
- Franchise model (local MomoPe reps)
- Commission split (70% MomoPe, 30% local rep)

**User Acquisition**:
- City-specific campaigns
- Partnerships (apartment societies, corporate cafeterias)

---

## 32. Customer Acquisition

### Acquisition Channels

**Organic**:
- App Store Optimization (ASO)
- Merchant word-of-mouth
- **Referral Program** (Live):
    - **Mechanic**: Reffer gets 50 coins, Referee gets 50 coins.
    - **Trigger**: Referee makes first payment >₹100 to any merchant.
    - **Tracking**: Unique referral code (User ID hash) applied at signup.

**Paid**:
- Google Ads (local search: "cashback app Bangalore")
- Facebook/Instagram Ads (lookalike audiences)
- Merchant-funded promotions

### Acquisition Economics

**Target CAC** (Customer Acquisition Cost): ₹50-100

**LTV Calculation**:
```
Avg transactions/user/month: 3
Avg transaction value: ₹500
Avg coin redemption: 50%
Effective GMV/user/month: ₹750

Commission (20%): ₹150
User reward: ₹15
Net revenue/user/month: ₹135

LTV (12 months): ₹135 × 12 = ₹1,620

LTV:CAC Ratio = ₹1,620 / ₹75 = 21.6x ✅ (Excellent)
```

### Activation Strategy

**Day 0**: Welcome email, app tutorial
**Day 1**: "Find nearby merchants" notification
**Day 3**: "Complete first transaction, earn 50 bonus coins"
**Day 7**: "You've earned X coins! Redeem at Y merchant"
**Day 30**: Milestone celebration (push notification)

---

## 33. Merchant Onboarding

### Onboarding Process

**Step 1: Application**
- Web form (www.momope.com/merchants/apply)
- Basic info: Business name, category, location
- Commission rate proposal (auto-assigned based on category)

**Step 2: KYC Submission**
- Upload documents (GST, PAN, bank proof)
- Merchant Manager reviews (48-hour SLA)

**Step 3: Approval**
- Email notification (approved/rejected with reason)
- If approved: Login credentials for Merchant App

**Step 4: Onboarding Call**
- 15-minute call (Merchant Manager)
- Explain app, QR code placement, settlement schedule

**Step 5: Go Live**
- Print QR code standee
- First transaction test
- Listed in Customer App (discovery)

### Merchant Retention

**30-Day Check-In**:
- How many transactions?
- Any issues?
- Offer support, promotional ideas

**90-Day Review**:
- Performance analytics shared
- Commission rate renegotiation (if volume high)
- Upsell: Premium tier (T+1 settlements)

**Churn Prevention**:
- If 0 transactions in 30 days → outreach call
- If low volume → suggest promotional offers
- If merchant wants to leave → exit survey (improve product)

---

## 34. Branding Guidelines

### Brand Identity

**Name**: MomoPe (Momo Coins + Payment)

**Tagline**: "Earn More. Spend Smart."

**Personality**:
- Trustworthy (not flashy)
- Simple (not complex)
- Rewarding (not gimmicky)
- Local (not corporate)

### Visual Identity

**Logo**: MomoPe (Coin + Payment)
- Coin motif with teal gradient
- Friendly, approachable, modern
- Works in single color (for QR codes, print)
- Responsive across all sizes

**Color Palette** (Official - Updated February 17, 2026):

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Primary Teal** | `#00C4A7` | Brand identity, primary actions, headers |
| **Teal Light** | `#33D4BB` | Gradients, hover states, accents |
| **Teal Dark** | `#009F85` | Active states, dark variants |
| **Accent Orange** | `#FF9F40` | Call-to-action, warm highlights |
| **Rewards Gold** | `#FFB800` | Coin rewards, achievements, gamification |
| **Success Green** | `#00C853` | Transaction success, positive feedback |
| **Dark Navy** | `#131B26` | Dark mode background, premium feel |
| **Neutral Gray** | `#757575` | Secondary text, borders |
| **White** | `#FFFFFF` | Surfaces, cards, light backgrounds |

**Primary Gradient**: `#2CB78A → #2DBCAF` (teal to teal-light, diagonal)

**Typography** (Material 3 Scale):
- **Display Font**: Manrope (Bold, 36-24px) - Hero headlines
- **Body Font**: Inter (Regular/Medium, 16-12px) - UI text, content
- **Monospace**: JetBrains Mono (Tabular) - Financial amounts, coin counts
- Font weights: 400 (Regular), 600 (Semibold), 700 (Bold), 800 (ExtraBold)

**Spacing System**: 8px grid (4, 8, 12, 16, 24, 32, 48, 64px)

**Border Radius**: 12px (cards), 16px (containers), 24px (bottom sheets), full (pills)

**Shadows**: Subtle elevation system (0dp - 16dp) for depth hierarchy

### Voice & Tone

**Customer Communication**:
- Friendly, not formal
- Clear, not jargon-heavy
- Encouraging, not pushy
- Example: "You earned 50 coins! 🎉" not "Transaction successful. Reward credited."

**Merchant Communication**:
- Professional, not casual
- Transparent, not salesy
- Partners, not vendors
- Example: "Your settlement of ₹45,000 is scheduled for Friday" not "Payout coming soon!"

---

# Part VIII: Future Roadmap

## 35. Product Roadmap

### Q1 2026 (Current)
- [x] Customer App MVP (Android)
- [x] Merchant App MVP (Android)
- [x] **Public Web Platform** (momope.com)
- [ ] PayU integration (in progress)
- [ ] Transaction flow complete

### Q2 2026
- [ ] Super Admin Dashboard
- [ ] Merchant Portal (advanced analytics)
- [ ] Push notifications
- [ ] Referral program (Web Implemented)

### Q3 2026
- [ ] iOS apps (Customer + Merchant)
- [ ] Dynamic reward tuning (admin-controlled)
- [ ] Merchant promotional offers
- [ ] Transaction reconciliation automation

### Q4 2026
- [ ] Predictive redemption modeling
- [ ] Multi-outlet merchant support
- [ ] User tier system (Bronze/Silver/Gold)
- [ ] Advanced fraud detection

---

## 36. Technical Roadmap

### Infrastructure

**Q1 2026**:
- Migrate to Supabase Pro Plan (production-ready)
- Set up monitoring (Sentry for crashes, Supabase logs)
- Deploy webhook endpoint (secure, signed)

**Q2 2026**:
- Add Redis caching (frequently accessed merchants)
- Implement background job queue (expiry, settlement)
- Database read replicas (if needed for scale)

**Q3 2026**:
- CI/CD pipeline (GitHub Actions for Flutter builds)
- Automated testing (unit + integration tests)
- Load testing (simulate 1,000 concurrent transactions)

**Q4 2026**:
- Explore GraphQL (if REST becomes bottleneck)
- Edge caching (CloudFlare for API responses)
- Multi-region deployment (if expanding beyond India)

### Security

**Ongoing**:
- Quarterly penetration testing
- RLS policy audits
- Dependency updates (monthly)
- Security training for team

---

## 37. Expansion Plans

### Geographic Expansion

**Year 1**: Bangalore (establish proof-of-concept)  
**Year 2**: Tier-1 cities (Mumbai, Delhi, Hyderabad, Chennai)  
**Year 3**: Tier-2 cities (Pune, Jaipur, Ahmedabad, Kolkata)  
**Year 4+**: Pan-India presence

### Category Expansion

**Current**: Grocery, F&B, Retail

**Future**:
- Healthcare (clinics, pharmacies)
- Education (tuition centers, courses)
- Travel (local tours, hotel bookings via local travel agents)
- Professional services (salons, gyms)

### Product Expansion

**B2B SaaS** (Year 3):
- White-label MomoPe for corporate cafeterias
- Housing society rewards programs
- University campus loyalty systems

**International** (Year 5+):
- Southeast Asia (similar merchant structures)
- Middle East (expat communities)

---

# Appendices

## Appendix A: Key Metrics Dashboard

**Daily Metrics**:
- New users
- New merchants
- Transactions count
- GMV
- Commission revenue
- Coin liability
- Coverage ratio

**Weekly Metrics**:
- User retention (Day 7, Day 30)
- Merchant transaction frequency
- Redemption rate
- Avg transaction value

**Monthly Metrics**:
- Monthly Active Users (MAU)
- Monthly Active Merchants (MAM)
- Revenue (net of rewards)
- Reserve pool balance
- Customer LTV
- Merchant NPS

---

## Appendix B: Glossary

**Term** | **Definition**
---------|----------------
**Coin** | Loyalty unit with 1:1 rupee redemption value
**Commission** | Percentage of GMV paid by merchant to MomoPe
**Coverage Ratio** | Reserve pool divided by total coin liability
**Expiry** | Automatic coin deactivation after 90 days
**FIFO** | First In, First Out (coin redemption order)
**GMV** | Gross Merchandise Value (total transaction volume)
**Liability** | Outstanding coin balance (financial obligation)
**RLS** | Row-Level Security (database access control)
**T+3** | Settlement 3 days after transaction

---

## Appendix C: Contact & Resources

**Founder**: (Your name/email)  
**Technical Lead**: (Your name/email)  
**CFO/Finance**: (Your name/email)

**Code Repositories** (Monorepo at `c:\DRAGON\MomoPe\`):
- Customer App: `c:\DRAGON\MomoPe\customer_app`
- Merchant App: `c:\DRAGON\MomoPe\merchant_app`
- Super Admin Dashboard: `c:\DRAGON\MomoPe\admin` (Next.js 15.5.12, port 3001)
- Supabase Edge Functions: `c:\DRAGON\MomoPe\supabase\functions`
- Marketing Website: `c:\DRAGON\MomoPe\website` (Live: momope.com)

**Documentation**:
- Product Model: `c:\MomoPe\momope\PRODUCT_MODEL.md`
- Treasury Framework: [artifacts]/treasury_framework.md
- Executive Report: [artifacts]/executive_report.md

**External Resources**:
- PayU Documentation: (URL)
- Supabase Docs: https://supabase.com/docs
- Flutter Docs: https://flutter.dev/docs

---

## Document Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Feb 15, 2026 | 1.0 | Initial consolidated document | Acting CTO |
| Feb 20, 2026 | 2.0 | Phase 1 completions: PayU SDK real integration, Referral onboarding screen, Merchant app navigation fix, Super Admin Dashboard (Next.js, 5 modules, running on port 3001). Next.js 15.5.12 with admin-role JWT middleware. | Acting CTO |

---

---

## Phase 2 Roadmap (As of Feb 20, 2026)

All Phase 1 implementations are complete. The following are prioritized for Phase 2:

### Sprint 5 — Supabase JWT Hook Activation *(Manual, ~15 min)*
The `custom_access_token_hook` DB function is deployed but needs to be enabled in Supabase Dashboard → Authentication → Hooks. Once active, the admin middleware will use the JWT claim directly instead of querying the DB on every request.

### Sprint 6 — Admin Dashboard Enhancements
- **Analytics charts**: 7-day transaction volume (bar) and coin circulation trend (line) on the Overview page using `recharts`
- **Settlements management page**: List and approve pending merchant settlement requests
- **CSV Export**: Download transaction data from the Transactions page
- **Coin minting/burning**: Admin controls to manually credit or deduct coins from any user account (fraud remediation, promotions)

### Sprint 7 — Push Notifications (FCM)
- Firebase Cloud Messaging integration in both Flutter apps (`firebase_messaging` package)
- Customer app: Payment success/failure push notifications
- Merchant app: "New payment received" and "Settlement processed" notifications
- New `send-notification` Supabase Edge Function called from `payu-webhook` on payment completion

### Sprint 8 — Customer App Profile Edit
- Allow customers to update their display name in the Profile screen
- Optional: Profile photo upload to Supabase Storage

### Sprint 9 — Merchant Analytics Screen
- New dedicated analytics screen in the merchant app with 7/30/90-day period selector
- Bar chart for daily earnings, peak-hours heatmap using `fl_chart`

---

**End of Document**

*This is a living document. Update frequently. Refer always. Build consistently with this vision.*
