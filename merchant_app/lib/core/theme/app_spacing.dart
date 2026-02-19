import 'package:flutter/material.dart';

/// Spacing constants based on 8px grid system
/// Following Material Design 3 spacing guidelines
class AppSpacing {
  // Prevent instantiation
  AppSpacing._();

  // ============================================================================
  // BASE SPACING SCALE (8px grid)
  // ============================================================================

  static const double space4 = 4.0;   // Tight spacing (icons, badges)
  static const double space8 = 8.0;   // Base unit (minimum padding)
  static const double space12 = 12.0; // Small gap (list items)
  static const double space16 = 16.0; // Standard gap (default padding)
  static const double space20 = 20.0; // Medium gap
  static const double space24 = 24.0; // Section spacing
  static const double space32 = 32.0; // Large sections
  static const double space40 = 40.0; // Major separations
  static const double space48 = 48.0; // Hero content spacing
  static const double space64 = 64.0; // Extra large spacing
  static const double space80 = 80.0; // Ultra spacing (rare)

  // ============================================================================
  // SEMANTIC SPACING
  // ============================================================================

  /// Default screen horizontal padding
  static const double screenPadding = space16;

  /// Default screen vertical padding
  static const double screenPaddingVertical = space24;

  /// Card internal padding
  static const double cardPadding = space16;

  /// Section spacing between major UI blocks
  static const double sectionSpacing = space24;

  /// List item spacing
  static const double listItemSpacing = space12;

  /// Bottom navigation height
  static const double bottomNavHeight = 70.0;

  /// App bar height (default)
  static const double appBarHeight = 56.0;

  // ============================================================================
  // EDGE INSETS (Convenience)
  // ============================================================================

  static const EdgeInsets paddingAll4 = EdgeInsets.all(space4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(space12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(space20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(space24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(space32);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: space12);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: space24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: space12);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: space16);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: space24);

  /// Standard screen padding (horizontal and vertical)
  static const EdgeInsets screenPaddingAll = EdgeInsets.symmetric(
    horizontal: screenPadding,
    vertical: screenPaddingVertical,
  );

  /// Horizontal screen padding only
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: screenPadding,
  );
}
