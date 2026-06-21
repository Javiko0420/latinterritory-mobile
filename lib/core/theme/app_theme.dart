import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';

/// App theme configuration with Material Design 3.
///
/// Aligned with the "Latin Territory Mobile" design system.
///
/// Typography rule:
///   - Everything uses **Hanken Grotesk** (the design's single family).
///     Headings / labels lean on heavier weights (700/800), body on 400/500.
class AppTheme {
  AppTheme._();

  /// Dark ink used as the foreground on gold-filled CTAs (per the mockup's
  /// "Publicar ahora" button — dark text on gold).
  static const Color _onGold = Color(0xFF1A1408);

  // ── Text Themes ─────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary) {
    return GoogleFonts.hankenGroteskTextTheme(base).copyWith(
      displayLarge:  GoogleFonts.hankenGrotesk(textStyle: base.displayLarge,  fontWeight: FontWeight.w800, color: primary),
      displayMedium: GoogleFonts.hankenGrotesk(textStyle: base.displayMedium, fontWeight: FontWeight.w800, color: primary),
      displaySmall:  GoogleFonts.hankenGrotesk(textStyle: base.displaySmall,  fontWeight: FontWeight.w800, color: primary),
      headlineLarge:  GoogleFonts.hankenGrotesk(textStyle: base.headlineLarge,  fontWeight: FontWeight.w800, color: primary),
      headlineMedium: GoogleFonts.hankenGrotesk(textStyle: base.headlineMedium, fontWeight: FontWeight.w800, color: primary),
      headlineSmall:  GoogleFonts.hankenGrotesk(textStyle: base.headlineSmall,  fontWeight: FontWeight.w700, color: primary),
      titleLarge:  GoogleFonts.hankenGrotesk(textStyle: base.titleLarge,  fontWeight: FontWeight.w700, color: primary),
      titleMedium: GoogleFonts.hankenGrotesk(textStyle: base.titleMedium, fontWeight: FontWeight.w700, color: primary),
      titleSmall:  GoogleFonts.hankenGrotesk(textStyle: base.titleSmall,  fontWeight: FontWeight.w600, color: primary),
      labelLarge:  GoogleFonts.hankenGrotesk(textStyle: base.labelLarge,  fontWeight: FontWeight.w700, color: primary),
      labelMedium: GoogleFonts.hankenGrotesk(textStyle: base.labelMedium, fontWeight: FontWeight.w600, color: primary),
      labelSmall:  GoogleFonts.hankenGrotesk(textStyle: base.labelSmall,  fontWeight: FontWeight.w600, color: primary),
      bodyLarge:  GoogleFonts.hankenGrotesk(fontSize: 16, color: primary),
      bodyMedium: GoogleFonts.hankenGrotesk(fontSize: 14, color: primary),
      bodySmall:  GoogleFonts.hankenGrotesk(fontSize: 12, color: secondary),
    );
  }

  // ── Light Theme ─────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(
      base.textTheme,
      AppColors.textPrimary,
      AppColors.textSecondary,
    );

    return base.copyWith(
      brightness: Brightness.light,
      extensions: const <ThemeExtension<dynamic>>[LTColors.light],
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: _onGold,
        primaryContainer: AppColors.goldBg,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.blueSoft,
        onSecondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          side: const BorderSide(color: AppColors.border),
        ),
        shadowColor: const Color(0x141C1208),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldStrong,
          foregroundColor: _onGold,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.goldStrong, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.goldStrong,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(
      base.textTheme,
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      extensions: const <ThemeExtension<dynamic>>[LTColors.dark],
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: _onGold,
        primaryContainer: AppColors.goldBgDark,
        onPrimaryContainer: AppColors.goldDark,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.darkTextPrimary,
        secondaryContainer: AppColors.blueSoftDark,
        onSecondaryContainer: AppColors.darkTextPrimary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        error: AppColors.error,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.3,
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldStrongDark,
          foregroundColor: _onGold,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          side: const BorderSide(color: AppColors.darkBorder),
          backgroundColor: AppColors.darkSurface,
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryLight,
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide:
              const BorderSide(color: AppColors.goldStrongDark, width: 2),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          color: AppColors.darkTextTertiary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.goldStrongDark,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        labelStyle: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: AppColors.darkTextSecondary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
      ),
    );
  }
}
