import 'package:flutter/material.dart';

/// Brand color palette for LatinTerritory.
///
/// Aligned with the "Diseño mobile Latin Territory" design system:
/// warm map-paper light theme, deep night-blue / charcoal dark theme, and a
/// latin-flag accent set whose principal accent is **gold** (`LTColors.gold`).
///
/// Two gold values exist on purpose:
///   - [primary] / [gold] `#C0851E` — text/icon-safe gold (good contrast on
///     cream). This is what drives `colorScheme.primary` and the many
///     incidental `AppColors.primary` text usages.
///   - [goldStrong] `#E0A92E` — the vibrant gold used for filled CTAs / FAB.
class AppColors {
  AppColors._();

  // ── Brand Primary (gold — principal accent) ────────────────────────
  static const Color primary      = Color(0xFFC0851E); // gold · text-safe
  static const Color primaryLight = Color(0xFFE6B84D); // gold · dark theme
  static const Color primaryDark  = Color(0xFFC0851E); // gold · deep

  // ── Brand Secondary (night blue) ───────────────────────────────────
  static const Color secondary      = Color(0xFF1E3A5F);
  static const Color secondaryLight = Color(0xFF3A6491);
  static const Color secondaryDark  = Color(0xFF16273F);

  // ── Design Accents (light) ─────────────────────────────────────────
  static const Color gold       = Color(0xFFC0851E); // text-safe gold
  static const Color goldStrong = Color(0xFFE0A92E); // filled CTA gold
  static const Color goldBg     = Color(0xFFF6EAD0); // soft gold surface
  static const Color blue       = Color(0xFF1E3A5F); // night
  static const Color blueSoft   = Color(0xFFE5EAF1);
  static const Color coral      = Color(0xFFBF553D);
  static const Color coralSoft  = Color(0xFFF6E2DB);
  static const Color green      = Color(0xFF3F7F61);
  static const Color greenSoft  = Color(0xFFE2EDE6);

  // ── Design Accents (dark) ──────────────────────────────────────────
  static const Color goldDark       = Color(0xFFE6B84D);
  static const Color goldStrongDark = Color(0xFFE6B84D);
  static const Color goldBgDark     = Color(0xFF2A2616);
  static const Color blueDark       = Color(0xFF3A6491);
  static const Color blueSoftDark   = Color(0xFF1E2A3A);
  static const Color coralDark      = Color(0xFFDC7257);
  static const Color coralSoftDark  = Color(0xFF2E211C);
  static const Color greenDark      = Color(0xFF5FA07E);
  static const Color greenSoftDark  = Color(0xFF18261F);

  // ── Latin Palette (mapped onto the design accents) ─────────────────
  static const Color latinGold    = Color(0xFFE0A92E); // compass gold
  static const Color latinRed     = Color(0xFFBF553D); // coral
  static const Color latinGreen   = Color(0xFF3F7F61);
  static const Color latinSkyBlue = Color(0xFF1E3A5F);
  static const Color latinPurple  = Color(0xFF7B3FA0); // legacy accent

  // ── Backgrounds (light) ────────────────────────────────────────────
  static const Color background     = Color(0xFFFAF6EE); // warm map paper
  static const Color surface        = Color(0xFFFFFFFF); // card
  static const Color surfaceVariant = Color(0xFFF4EEE2); // card-2
  static const Color border         = Color(0xFFECE6D8); // line
  static const Color divider        = Color(0xFFECE6D8);

  // ── Text (light) ───────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1916); // ink
  static const Color textSecondary = Color(0xFF6E6A60); // ink-2
  static const Color textTertiary  = Color(0xFFA7A296); // ink-3

  // ── Backgrounds (dark · night blue / charcoal) ─────────────────────
  static const Color darkBackground     = Color(0xFF121519); // bg
  static const Color darkSurface        = Color(0xFF1B1F26); // card
  static const Color darkSurfaceVariant = Color(0xFF232A33); // card-2
  static const Color darkBorder         = Color(0x17FFFFFF); // line · 9% white

  // ── Text (dark) ────────────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFF1EDE3); // ink
  static const Color darkTextSecondary = Color(0xFFA29E94); // ink-2
  static const Color darkTextTertiary  = Color(0xFF6E6A62); // ink-3

  // ── Semantic ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF3F7F61); // green
  static const Color warning = Color(0xFFE0A92E); // gold
  static const Color error   = Color(0xFFC8371A); // real red (validation)
  static const Color info    = Color(0xFF1E3A5F); // night blue

  // ── Categories (mapped to design accents) ──────────────────────────
  static const Color categoryDirectorio = Color(0xFFC0851E); // gold
  static const Color categoryEmpleos    = Color(0xFF1E3A5F); // blue
  static const Color categoryEventos    = Color(0xFFBF553D); // coral
  static const Color categoryForos      = Color(0xFF3F7F61); // green
  static const Color categoryClima      = Color(0xFF1E3A5F); // blue
  static const Color categoryDivisas    = Color(0xFF3F7F61); // green
  static const Color categoryDeportes   = Color(0xFFBF553D); // coral

  // ── Legacy aliases (kept for backwards compat) ─────────────────────
  static const Color categoryFood          = latinRed;
  static const Color categoryServices      = latinSkyBlue;
  static const Color categoryHealth        = latinGreen;
  static const Color categoryShopping      = latinPurple;
  static const Color categoryEntertainment = latinGold;
}
