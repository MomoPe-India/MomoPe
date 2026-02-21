import 'package:flutter/material.dart';

/// Custom color palette for MomoPe Customer App
/// Using official MomoPe brand colors (Teal gradient)
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY BRAND COLORS (MomoPe Official Palette)
  // ============================================================================
  
  /// Primary Teal - Brand Identity (#2CB78A - #2DBCAF gradient)
  static const Color primaryTeal = Color(0xFF2CB78A);
  static const Color primaryTealLight = Color(0xFF2DBCAF);
  static const Color primaryTealDark = Color(0xFF24A077);
  static const Color primaryTealExtraLight = Color(0xFFD4F4E8);

  /// Secondary Teal (for variety within brand)
  static const Color secondaryTeal = Color(0xFF20C997);
  static const Color secondaryTealLight = Color(0xFF6EDDB7);
  static const Color secondaryTealDark = Color(0xFF17A779);
  
  /// Secondary Navy - Deep Fintech Aesthetic
  static const Color secondaryNavy = Color(0xFF0B0F19);
  static const Color secondaryNavyLight = Color(0xFF1A2332);
  static const Color secondaryNavyDark = Color(0xFF0D1219);

  /// Accent Colors (Complementary)
  static const Color accentOrange = Color(0xFFFF9F40);  // Warm CTA
  static const Color accentOrangeLight = Color(0xFFFFB366);
  static const Color accentOrangeDark = Color(0xFFE68A2E);

  /// Gold - Rewards & Achievement
  static const Color rewardsGold = Color(0xFFFFB800);
  static const Color rewardsGoldLight = Color(0xFFFFD666);
  static const Color rewardsGoldDark = Color(0xFFCC9300);
  static const Color rewardsGoldExtraLight = Color(0xFFFFF8E1);

  /// Level Colors
  static const Color levelBronze = Color(0xFFCD7F32);
  static const Color levelSilver = Color(0xFFC0C0C0);
  static const Color levelGold = Color(0xFFFFD700);
  static const Color levelPlatinum = Color(0xFFE5E4E2);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success (Financial Gains)
  static const Color successGreen = Color(0xFF00C853);
  static const Color successGreenDark = Color(0xFF00A142);
  static const Color successBackground = Color(0xFFE8F5E9);

  /// Warning (Attention)
  static const Color warningAmber = Color(0xFFFFC107);
  static const Color warningAmberDark = Color(0xFFFF9800);
  static const Color warningBackground = Color(0xFFFFF8E1);

  /// Error (Critical Actions)
  static const Color errorRed = Color(0xFFFF5252);
  static const Color errorRedDark = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFEBEE);

  /// Information
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color infoBlueDark = Color(0xFF1976D2);
  static const Color infoBackground = Color(0xFFE3F2FD);

  // ============================================================================
  // NEUTRAL SCALE (Light Mode)
  // ============================================================================

  static const Color neutral100 = Color(0xFFFAFAFA); // Backgrounds
  static const Color neutral200 = Color(0xFFF5F5F5); // Cards
  static const Color neutral300 = Color(0xFFEEEEEE); // Borders
  static const Color neutral400 = Color(0xFFBDBDBD); // Disabled
  static const Color neutral500 = Color(0xFF9E9E9E); // Icons
  static const Color neutral600 = Color(0xFF757575); // Secondary text
  static const Color neutral700 = Color(0xFF616161); // Body text
  static const Color neutral800 = Color(0xFF424242); // Primary text
  static const Color neutral900 = Color(0xFF212121); // Headers

  // ============================================================================
  // DARK MODE COLORS (MomoPe Dark Theme)
  // ============================================================================

  static const Color darkBackground = Color(0xFF0B0F19); // Official dark navy
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkCard = Color(0xFF242F3D);

  // ============================================================================
  // GRADIENTS (MomoPe Brand)
  // ============================================================================

  /// Primary gradient (Teal to Teal Light)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (Green shades)
  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF69F0AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient (Rewards)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [rewardsGoldDark, rewardsGoldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass morphism overlay
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xB3FFFFFF), // 70% white opacity
      Color(0x4DFFFFFF), // 30% white opacity
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
