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
  // ELEVATION & SHADOWS (Umbra Shadow System)
  // ============================================================================
  
  /// Surface Shadow - Subtle depth for cards
  static const List<BoxShadow> shadowUmbraSurface = [
    BoxShadow(
      color: Color(0x080B0F19), // 3% Navy
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x050B0F19), // 2% Navy
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Medium Shadow - For interactive elements
  static const List<BoxShadow> shadowUmbraMedium = [
    BoxShadow(
      color: Color(0x120B0F19), // 7% Navy
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0B0F19), // 4% Navy
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// High Shadow - For modals and CTAs
  static const List<BoxShadow> shadowUmbraHigh = [
    BoxShadow(
      color: Color(0x1F0B0F19), // 12% Navy
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x140B0F19), // 8% Navy
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  /// Legacy Elevations (Mapped to Umbra)
  static const List<BoxShadow> elevation1 = shadowUmbraSurface;
  static const List<BoxShadow> elevation2 = shadowUmbraMedium;
  static const List<BoxShadow> elevation3 = shadowUmbraHigh;
  static const List<BoxShadow> elevation4 = shadowUmbraHigh;

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
