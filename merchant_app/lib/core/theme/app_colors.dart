import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryTeal = Color(0xFF2CB78A);
  static const Color primaryTealDark = Color(0xFF24A077);
  static const Color primaryTealLight = Color(0xFF2DBCAF);
  static const Color primaryTealExtraLight = Color(0xFFD4F4E8);
  static const Color secondaryNavy = Color(0xFF0B0F19);
  
  // Accents
  static const Color accentOrange = Color(0xFFFF9F40);
  static const Color successGreen = Color(0xFF00C853);
  static const Color errorRed = Color(0xFFFF5252);
  static const Color rewardsGold = Color(0xFFFFB800);
  static const Color warningAmber = Color(0xFFFFC107);
  
  // Neutrals
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryTealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [secondaryNavy, Color(0xFF1A2235)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient used for the Today's Earnings card
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass / frosted-glass gradient for overlay cards
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
