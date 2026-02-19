# Merchant App - Premium UI Redesign Plan

**Date:** February 17, 2026  
**Goal:** Unified MomoPe brand experience across Customer and Merchant apps  
**Timeline:** 1-2 days

---

## Problem Statement

**Current State:**
- Merchant app uses basic Material Design with minimal branding
- Simple white cards, basic buttons, generic colors
- Feels like a different product than Customer app
- No premium design components or brand gradients

**Desired State:**
- Both apps share the same visual DNA
- Unified color system, typography, spacing, and components
- Premium, modern aesthetic across ecosystem
- Consistent user experience

---

## Design System Audit

### Customer App (Premium ✅)

**Color System:**
- Brand: `AppColors.primaryTeal` (#2CB78A)
- Gradients: `primaryGradient`, `goldGradient`
- Semantic colors: `rewardsGold`, `successGreen`, `errorRed`
- Neutral scale: `neutral100-neutral900`

**Premium Components:**
- `PremiumCard` - Elevated/outlined/gradient styles
- `PremiumButton` - Primary/secondary/outline/text/icon styles
- `QuickActionCard` - Icon-based action buttons
- `TransactionCard` - Transaction list items with status

**Typography:**
- Google Fonts: Inter (consistent font family)
- `AppTypography` system with proper hierarchy
- Bold headers, medium body, small captions

**Spacing:**
- `AppSpacing` tokens (8px grid)
- Consistent padding: 8, 12, 16, 24
- Proper vertical rhythm

---

### Merchant App (Basic  ❌)

**Colors:**
- Hardcoded hex values (#111827, #6B7280, etc.)
- Inconsistent with MomoPe brand
- No gradients or premium effects

**Components:**
- Generic `Container` widgets
- Basic Material `TextField`, `ElevatedButton`
- No reusable branded components

**Typography:**
- Direct GoogleFonts.inter() calls inline
- No typography system
- Inconsistent sizing and weights

**Spacing:**
- Hardcoded values (24.0, 16.0, etc.)
- No spacing tokens

---

## Implementation Strategy

### Approach: **Shared Design System**

**Rationale:**
- Both apps should use identical core design files
- Maintain single source of truth for brand
- Enable instant brand updates across ecosystem
- Reduce maintenance overhead

**Decision:** Copy Customer app's `core/` directory to Merchant app

---

## Proposed Changes

### Phase 1: Core Design System Migration (2-3 hours)

**Copy from Customer App:**

**1. Theme Files** (Shared Brand Identity)
```
customer_app/lib/core/theme/ → merchant_app/lib/core/theme/
├── app_colors.dart           ✅ MomoPe color palette
├── app_typography.dart       ✅ Typography system
├── app_spacing.dart          ✅ Spacing tokens
├── app_design_tokens.dart    ✅ Border radius, shadows
└── app_theme.dart            ✅ ThemeData configuration
```

**2. Premium Widget Library** (Branded Components)
```
customer_app/lib/core/widgets/ → merchant_app/lib/core/widgets/
├── premium_card.dart         ✅ Elevated/outlined/gradient cards
├── premium_button.dart       ✅ 5 button styles
├── quick_action_card.dart    ✅ Icon-based actions
└── widgets.dart              ✅ Barrel export
```

**Verification:**
- Run `flutter analyze` - no errors
- Import widgets in test screen
- Confirm visual match with Customer app

---

### Phase 2: Screen Redesigns (3-4 hours)

**1. Merchant Registration Screen** (Priority High)

**Current Issues:**
- Basic white form with default Material styling
- No brand personality
- Generic input fields

**Redesign:**
```dart
// BEFORE
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(...)],
  ),
  child: TextFormField(...),
)

// AFTER
PremiumCard(
  style: PremiumCardStyle.elevated,
  child: Column(
    children: [
      _buildSectionHeader('Business Details'),
      const SizedBox(height: AppSpacing.space16),
      // Branded input fields
    ],
  ),
)
```

**Features:**
- Welcome screen with brand gradient header
- Progress indicator with brand colors
- Premium input fields with brand focus colors
- PremiumButton for CTAs
- Success screen with celebration animation

---

**2. Merchant Home / QR Code Screen** (Priority High)

**Current:**
- White cards with basic shadows
- Generic QR display
- No brand presence

**Redesign:**
```dart
// Business Info Card
PremiumCard(
  style: PremiumCardStyle.gradient,  // Brand gradient
  child: Column(
    children: [
      // Business name with brand typography
      Text(
        businessName,
        style: AppTypography.headlineLarge.copyWith(
          color: Colors.white,
        ),
      ),
      // Category badge with accent color
      // Commission rate with rewardsGold
    ],
  ),
)

// QR Code Card
PremiumCard(
  style: PremiumCardStyle.elevated,
  child: Column(
    children: [
      // QR code container
      Container(
        decoration: BoxDecoration(
          gradient: AppColors.glassGradient,
          borderRadius: AppDesignTokens.radius16,
        ),
        child: QrImageView(...),
      ),
      //Share/download buttons
      Row(
        children: [
          Expanded(
            child: PremiumButton(
              text: 'Share QR',
              icon: Icons.share,
              onPressed: () {},
              style: PremiumButtonStyle.primary,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

---

**3. Merchant Dashboard** (Priority Medium)

**Current:**
- Basic stats display
- No visual hierarchy

**Redesign:**
- Stats cards with `PremiumCard.outlined`
- Today's earnings with `goldGradient`
- Transaction list using `TransactionCard` from Customer app
- Quick actions using `QuickActionCard`

**Layout:**
```
┌────────────────────────────────────┐
│  Today's Earnings (Gold Gradient) │
│  ₹12,450                          │
└────────────────────────────────────┘

┌─────────────┬──────────────┬───────┐
│ Total Sales │ Commissions  │ Orders│
│   ₹50,000   │   ₹10,000    │  45   │
└─────────────┴──────────────┴───────┘

┌────────────────────────────────────┐
│  Recent Transactions               │
│  [TransactionCard]                 │
│  [TransactionCard]                 │
│  [TransactionCard]                 │
└────────────────────────────────────┘
```

---

### Phase 3: Navigation & Branding (1-2 hours)

**Bottom Navigation:**
- Use `AppColors.primaryTeal` for selected items
- Add icons with brand personality
- Premium tab indicator

**App Bar:**
- Brand gradient background for key screens
- Typography from `AppTypography`
- Consistent iconography

**Splash Screen:**
- Brand gradient background
- MomoPe logo
- Loading animation with brand colors

---

## File Structure (After Migration)

```
merchant_app/lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          ✅ Copied from Customer
│   │   ├── app_typography.dart      ✅ Copied
│   │   ├── app_spacing.dart         ✅ Copied
│   │   ├── app_design_tokens.dart   ✅ Copied
│   │   └── app_theme.dart           ✅ Updated (no more hardcoded colors)
│   └── widgets/
│       ├── premium_card.dart        ✅ Copied
│       ├── premium_button.dart      ✅ Copied
│       ├── quick_action_card.dart   ✅ Copied
│       └── widgets.dart             ✅ Copied
├── models/
│   └── merchant.dart                (existing)
├── providers/
│   └── ...                          (existing)
├── screens/
│   ├── registration/
│   │   └── merchant_registration_screen.dart   ✨ Redesigned
│   ├── home/
│   │   └── merchant_home_screen.dart           ✨ Redesigned
│   └── dashboard/
│       └── merchant_dashboard_screen.dart      ✨ Redesigned
└── main.dart                        ✅ Already uses AppTheme
```

---

## Specific Component Replacements

### Replace ALL Hardcoded Colors

**Find & Replace:**
```dart
// BEFORE → AFTER
Color(0xFF111827) → AppColors.neutral900
Color(0xFF6B7280) → AppColors.neutral600
Color(0xFF9CA3AF) → AppColors.neutral500
Color(0xFFE5E7EB) → AppColors.neutral300
Color(0xFFF9FAFB) → AppColors.neutral100
Color(0xFF10B981) → AppColors.successGreen
Color(0xFF6366F1) → AppColors.primaryTeal  // Main brand color
```

### Replace All Containers with PremiumCard

**Pattern:**
```dart
// BEFORE
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(...)],
  ),
  child: ...,
)

// AFTER
PremiumCard(
  style: PremiumCardStyle.elevated,
  child: ...,
)
```

### Replace All Buttons with PremiumButton

**Pattern:**
```dart
// BEFORE
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(...),
  child: Text('Submit'),
)

// AFTER
PremiumButton(
  text: 'Submit',
  onPressed: () {},
  style: PremiumButtonStyle.primary,
)
```

### Replace All Typography

**Pattern:**
```dart
// BEFORE
GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.bold,
)

// AFTER
AppTypography.headlineLarge
```

### Replace All Spacing

**Pattern:**
```dart
// BEFORE
SizedBox(height: 24)
EdgeInsets.all(24)

// AFTER
SizedBox(height: AppSpacing.space24)
AppSpacing.paddingAll24
```

---

## Verification Plan

### 1. Visual Regression Testing (Manual)

**Prerequisites:**
- Customer app running on port A
- Merchant app running on port B
- Side-by-side browser windows

**Test Steps:**

**Step 1: Compare Registration Screens**
1. Open Customer app registration (if exists)
2. Open Merchant registration
3. Verify:
   - Same button styles (teal, rounded, shadows)
   - Same card elevations
   - Same input field styling (focus colors, borders)
   - Same spacing between elements

**Step 2: Compare Home Screens**
1. Sign in to both apps
2. Navigate to home
3. Verify:
   - Same color palette
   - Same typography (font family, sizes, weights)
   - Same card styles
   - Same spacing rhythm

**Step 3: Compare Component Library**
1. Create test screen in both apps
2. Render all components:
   ```dart
   PremiumCard(style: elevated)
   PremiumCard(style: outlined)
   PremiumCard(style: gradient)
   PremiumButton(style: primary)
   PremiumButton(style: secondary)
   ```
3. Verify identical appearance

**Expected Result:** Both apps look like they belong to the same product family

---

### 2. Build & Runtime Verification

**Command:**
```bash
cd c:\DRAGON\MomoPe\merchant_app
flutter run -d chrome
```

**Verify:**
- ✅ No compilation errors
- ✅ No widget overflow issues
- ✅ Smooth animations
- ✅ Proper color contrast (accessibility)

---

### 3. Design Token Audit

**Script:**
```bash
# Search for hardcoded colors
cd c:\DRAGON\MomoPe\merchant_app
grep -r "Color(0x" lib/screens/

# Should return ZERO results after refactor
```

**Expected:** No hardcoded color values in screens

---

### 4. Brand Consistency Checklist

**Must Have:**
- [x] `AppColors.primaryTeal` used for primary actions
- [x] `AppColors.rewardsGold` for earnings/rewards
- [x] `AppTypography` used throughout (no inline GoogleFonts)
- [x] `AppSpacing` tokens for all spacing
- [x] `PremiumCard` for all card-like containers
- [x] `PremiumButton` for all CTAs
- [x] Gradients used for premium sections
- [x] Consistent border radius (`AppDesignTokens`)

---

## Success Criteria

**1. Visual Unity**
- Merchant app indistinguishable from Customer app in terms of brand
- Same color palette, typography, spacing
- Same component library

**2. Code Quality**
- Zero hardcoded design values in screens
- All styling via design tokens
- Reusable components

**3. Maintainability**
- Single source of truth for brand (core/)
- Brand changes propagate to both apps
- Easy to keep in sync

---

## Risks & Mitigation

**Risk 1: Widget Compatibility**
- Some Customer widgets may not fit Merchant use cases
- **Mitigation:** Create Merchant-specific variants if needed, but keep core design system shared

**Risk 2: Breaking Existing Functionality**
- UI refactor may affect existing logic
- **Mitigation:** Test all user flows after redesign

**Risk 3: Performance**
- Premium components may be heavier
- **Mitigation:** Profile build times and runtime performance

---

## Post-Redesign Maintenance

**Future Brand Updates:**
1. Edit files in `customer_app/lib/core/`
2. Copy to `merchant_app/lib/core/`
3. Both apps updated simultaneously

**Better Approach (Future):**
- Create shared `momope_design_system` Flutter package
- Both apps depend on single package
- Guaranteed consistency

---

## Timeline

**Day 1 (Morning):**
- Phase 1: Copy core design system (2-3 hours)
- Verify build success

**Day 1 (Afternoon):**
- Phase 2: Redesign registration screen (2-3 hours)
- Test registration flow

**Day 2 (Morning):**
- Phase 2 cont: Redesign home/QR screen (2-3 hours)
- Phase 2 cont: Redesign dashboard (if time)

**Day 2 (Afternoon):**
- Phase 3: Navigation branding (1-2 hours)
- Final verification and polish

---

## Next Steps

1. **Get User Approval** on this plan
2. **Phase 1:** Copy design system files
3. **Phase 2:** Refactor screens one-by-one
4. **Phase 3:** Polish and verify
5. **Manual Testing:** Side-by-side comparison

Ready to proceed?
