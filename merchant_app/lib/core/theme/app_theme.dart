import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_design_tokens.dart';

/// Main theme configuration for MomoPe Merchant App
/// Harmonized with Customer App and Website for brand consistency
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryNavy,
        onSecondary: Colors.white,
        error: AppColors.errorRed,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.neutral900,
      ),

      // ========================================================================
      // TYPOGRAPHY
      // ========================================================================
      textTheme: TextTheme(
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.neutral900),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.neutral900),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.neutral800),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.neutral900),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.neutral800),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.neutral800),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.neutral700),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.neutral700),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.neutral600),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.neutral900),
      ),

      // ========================================================================
      // SCAFFOLDS & SURFACES
      // ========================================================================
      scaffoldBackgroundColor: AppColors.neutral100,
      cardColor: Colors.white,

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.secondaryNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: AppColors.secondaryNavy),
        iconTheme: const IconThemeData(color: AppColors.secondaryNavy),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // ========================================================================
      // BUTTON THEMES
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppDesignTokens.radiusButton),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // ========================================================================
      // CARD THEME (Premium Shadow)
      // ========================================================================
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignTokens.radiusCard,
          side: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),

      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
