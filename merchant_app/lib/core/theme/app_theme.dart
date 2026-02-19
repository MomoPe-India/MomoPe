import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_design_tokens.dart';

/// Main theme configuration for MomoPe Customer App
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Light theme (primary theme)
  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryTealLight,
        onPrimaryContainer: AppColors.primaryTealDark,
        
        secondary: AppColors.accentOrange,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentOrangeLight,
        onSecondaryContainer: AppColors.accentOrangeDark,
        
        tertiary: AppColors.rewardsGold,
        onTertiary: AppColors.neutral900,
        tertiaryContainer: AppColors.rewardsGoldLight,
        onTertiaryContainer: AppColors.rewardsGoldDark,
        
        error: AppColors.errorRed,
        onError: Colors.white,
        errorContainer: AppColors.errorBackground,
        onErrorContainer: AppColors.errorRedDark,
        
        surface: Colors.white,
        onSurface: AppColors.neutral900,
        surfaceContainerHighest: AppColors.neutral100,
        
        outline: AppColors.neutral300,
        outlineVariant: AppColors.neutral200,
      ),

      // ========================================================================
      // TYPOGRAPHY
      // ========================================================================
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.neutral900),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.neutral900),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.neutral900),
        
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
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.neutral800),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.neutral600),
      ),

      // ========================================================================
      // SCAFFOLDS & SURFACES
      // ========================================================================
      scaffoldBackgroundColor: AppColors.neutral100,
      cardColor: Colors.white,
      canvasColor: Colors.white,

      // ========================================================================
      // ELEVATED BUTTON THEME
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.neutral400,
          disabledForegroundColor: AppColors.neutral600,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppDesignTokens.radiusButton),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON THEME
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          disabledForegroundColor: AppColors.neutral400,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: AppColors.primaryTeal, width: 2),
          shape: RoundedRectangleBorder(borderRadius: AppDesignTokens.radiusButton),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================================================
      // TEXT BUTTON THEME
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          disabledForegroundColor: AppColors.neutral400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================================================
      // INPUT DECORATION THEME
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        
        border: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: BorderSide.none,
        ),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: BorderSide.none,
        ),
        
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        
        errorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDesignTokens.radius12,
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral600),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.neutral400),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.errorRed),
      ),

      // ========================================================================
      // CARD THEME
      // ========================================================================
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Color(0x0A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.neutral300, width: 1),
        ),
      ),

      // ========================================================================
      // APP BAR THEME
      // ========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: AppColors.neutral900),
        iconTheme: const IconThemeData(color: AppColors.neutral900, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ========================================================================
      // BOTTOM NAV BAR THEME
      // ========================================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: AppColors.neutral600,
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 24),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ========================================================================
      // SNACKBAR THEME
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral900,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppDesignTokens.radius12),
      ),

      // ========================================================================
      // DIVIDER THEME
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.neutral300,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // MISC
      // ========================================================================
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
    );
  }

  /// Dark theme (future implementation)
  static ThemeData get darkTheme {
    // TODO: Implement dark theme
    return lightTheme;
  }
}
