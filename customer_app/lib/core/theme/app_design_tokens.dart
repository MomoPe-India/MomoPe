import 'package:flutter/material.dart';

/// Border radius, shadows, and other design tokens
class AppDesignTokens {
  // Prevent instantiation
  AppDesignTokens._();

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const BorderRadius radius4 = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radius20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));

  /// Semantic radius values
  static const BorderRadius radiusButton = radius12;
  static const BorderRadius radiusCard = radius12;
  static const BorderRadius radiusBottomSheet = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  );

  // ============================================================================
  // ELEVATION & SHADOWS
  // ============================================================================

  /// Subtle depth (Cards, containers)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium depth (Floating elements, buttons)
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// High depth (Modals, important CTAs)
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Extra high (Full-screen overlays)
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x29000000), // 16% black
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration durationFast = Duration(milliseconds: 150);    // Micro-interactions
  static const Duration durationNormal = Duration(milliseconds: 250);  // Standard transitions
  static const Duration durationSlow = Duration(milliseconds: 400);    // Page transitions
  static const Duration durationDelayed = Duration(milliseconds: 600); // Success feedback

  // ============================================================================
  // ANIMATION CURVES
  // ============================================================================

  static const Curve curveSnappy = Curves.easeOutCubic;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveLinear = Curves.linear;

  // ============================================================================
  // OPACITIES
  // ============================================================================

  static const double opacityDisabled = 0.38;
  static const double opacityPressed = 0.12;
  static const double opacityHover = 0.08;
  static const double opacityFocus = 0.12;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // ============================================================================
  // BORDER WIDTHS
  // ============================================================================

  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;
}
