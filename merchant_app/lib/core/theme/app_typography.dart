import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Typography system for MomoPe Merchant App
/// Using Inter for body text and Manrope for display/headers
/// Harmonized with Customer App for brand consistency
class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  static const String primaryFont = 'Inter';      // Body text, UI elements
  static const String displayFont = 'Manrope';    // Headers, emphasis
  static const String monoFont = 'JetBrains Mono'; // Numbers, amounts

  // ============================================================================
  // DISPLAY STYLES (Large headlines, hero text)
  // ============================================================================

  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ============================================================================
  // HEADLINE STYLES (Section headers)
  // ============================================================================

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ============================================================================
  // TITLE STYLES (Card titles, list headers)
  // ============================================================================

  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ============================================================================
  // BODY STYLES (Main content text)
  // ============================================================================

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ============================================================================
  // LABEL STYLES (Buttons, tabs, form labels)
  // ============================================================================

  static const TextStyle labelLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // FINANCIAL AMOUNT STYLES (Tabular numbers for alignment)
  // ============================================================================

  static const TextStyle amountDisplay = TextStyle(
    fontFamily: monoFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFeatures: [ui.FontFeature.tabularFigures()],
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: monoFont,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFeatures: [ui.FontFeature.tabularFigures()],
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: monoFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFeatures: [ui.FontFeature.tabularFigures()],
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFeatures: [ui.FontFeature.tabularFigures()],
  );

  // ============================================================================
  // SPECIALIZED STYLES
  // ============================================================================

  /// Caption text (timestamps, metadata)
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Overline text (section labels, category tags)
  static const TextStyle overline = TextStyle(
    fontFamily: primaryFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
  );

  /// Button text (all caps)
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
