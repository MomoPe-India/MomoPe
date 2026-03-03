import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension MomoPeThemeContext on BuildContext {
  MomoPeColors get theme => Theme.of(this).extension<MomoPeColors>()!;
}

class MomoPeColors extends ThemeExtension<MomoPeColors> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color accent;
  final Color success;
  final Color error;
  final Color warning;

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color card;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final LinearGradient coinGradient;

  const MomoPeColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.accent,
    required this.success,
    required this.error,
    required this.warning,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.coinGradient,
  });

  @override
  ThemeExtension<MomoPeColors> copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? accent,
    Color? success,
    Color? error,
    Color? warning,
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    LinearGradient? coinGradient,
  }) {
    return MomoPeColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      coinGradient: coinGradient ?? this.coinGradient,
    );
  }

  @override
  ThemeExtension<MomoPeColors> lerp(ThemeExtension<MomoPeColors>? other, double t) {
    if (other is! MomoPeColors) return this;
    return MomoPeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      coinGradient: LinearGradient.lerp(coinGradient, other.coinGradient, t)!,
    );
  }
}

class MomoPeTheme {
  MomoPeTheme._();

  // The base shared brand colors
  static const Color brandPrimaryStart = Color(0xFF2CB78A);
  static const Color brandPrimaryEnd   = Color(0xFF2DBCAF);
  static const Color brandDark         = Color(0xFF131B26);
  static const Color brandWhite        = Color(0xFFFFFFFF);

  static const Color accent  = Color(0xFFFFB800); // gold
  static const Color success = Color(0xFF00C48C);
  static const Color error   = Color(0xFFFF4C4C);
  static const Color warning = Color(0xFFFF8C00);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandPrimaryStart, brandPrimaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final MomoPeColors lightColors = MomoPeColors(
    primary: brandPrimaryStart,
    primaryDark: brandDark,
    primaryLight: brandPrimaryEnd,
    accent: accent,
    success: success,
    error: error,
    warning: warning,
    bg: brandWhite,
    surface: Color(0xFFF5F7FA), // light surface
    surfaceAlt: Color(0xFFE2E8F0),
    card: brandWhite,
    textPrimary: brandDark,
    textSecondary: Color(0xFF4A5568),
    textMuted: Color(0xFF718096),
    coinGradient: primaryGradient,
  );

  static final MomoPeColors darkColors = MomoPeColors(
    primary: brandPrimaryStart,
    primaryDark: brandDark,
    primaryLight: brandPrimaryEnd,
    accent: accent,
    success: success,
    error: error,
    warning: warning,
    bg: brandDark,
    surface: Color(0xFF1A2433),
    surfaceAlt: Color(0xFF233045),
    card: Color(0xFF1E2A3B),
    textPrimary: brandWhite,
    textSecondary: Color(0xFFA0AEC0),
    textMuted: Color(0xFF718096),
    coinGradient: primaryGradient,
  );

  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: lightColors.bg,
      colorScheme: ColorScheme.light(
        primary: lightColors.primary,
        secondary: lightColors.accent,
        surface: lightColors.surface,
        error: lightColors.error,
      ),
      extensions: [lightColors],
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: lightColors.textPrimary,
        displayColor: lightColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: lightColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightColors.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: lightColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: lightColors.error, width: 1.5)),
        labelStyle: TextStyle(color: lightColors.textSecondary),
        hintStyle: TextStyle(color: lightColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: lightColors.primary)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightColors.surfaceAlt,
        contentTextStyle: TextStyle(color: lightColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: lightColors.surfaceAlt),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightColors.surface,
        selectedItemColor: lightColors.primary,
        unselectedItemColor: lightColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: darkColors.bg,
      colorScheme: ColorScheme.dark(
        primary: darkColors.primary,
        secondary: darkColors.accent,
        surface: darkColors.surface,
        error: darkColors.error,
      ),
      extensions: [darkColors],
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: darkColors.textPrimary,
        displayColor: darkColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkColors.surfaceAlt,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: darkColors.error, width: 1.5)),
        labelStyle: TextStyle(color: darkColors.textSecondary),
        hintStyle: TextStyle(color: darkColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: darkColors.primary)),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColors.surfaceAlt,
        contentTextStyle: TextStyle(color: darkColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: darkColors.surfaceAlt),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColors.surface,
        selectedItemColor: darkColors.primary,
        unselectedItemColor: darkColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
