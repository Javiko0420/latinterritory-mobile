import 'package:flutter/material.dart';

/// Brand color palette for LatinTerritory.
///
/// Calibrated pixel-by-pixel from the launch icon (teal background +
/// orange compass pin). Inspired by Latin American flags (red, gold,
/// green, sky blue, purple) and warm "map paper" cream backgrounds.
class AppColors {
  AppColors._();

  // ── Brand Primary (warm orange — map pin) ──────────────────────────
  static const Color primary      = Color(0xFFE07830);
  static const Color primaryLight = Color(0xFFE38D18); // golden halo
  static const Color primaryDark  = Color(0xFFBB4F25); // pin body

  // ── Brand Secondary (exact teal of icon background) ────────────────
  static const Color secondary      = Color(0xFF15989F);
  static const Color secondaryLight = Color(0xFF2DB3BA);
  static const Color secondaryDark  = Color(0xFF0B8087);

  // ── Latin Palette (flag colors of Latin America) ───────────────────
  static const Color latinGold    = Color(0xFFFCD55E); // compass / Colombia / Brasil
  static const Color latinRed     = Color(0xFFC8371A); // México / Chile / Perú
  static const Color latinGreen   = Color(0xFF1E8A4A); // México / Brasil
  static const Color latinSkyBlue = Color(0xFF2E85C3); // Argentina / Honduras
  static const Color latinPurple  = Color(0xFF7B3FA0); // accent

  // ── Backgrounds (light) ────────────────────────────────────────────
  static const Color background     = Color(0xFFFAF7F1); // warm cream (map paper)
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EDE4);
  static const Color border         = Color(0xFFE4DDD4);
  static const Color divider        = Color(0xFFF5F0E8);

  // ── Text (light) ───────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1C1208);
  static const Color textSecondary = Color(0xFF6B5E52);
  static const Color textTertiary  = Color(0xFFA89880);

  // ── Backgrounds (dark) ─────────────────────────────────────────────
  static const Color darkBackground     = Color(0xFF1A1208);
  static const Color darkSurface        = Color(0xFF261D0E);
  static const Color darkSurfaceVariant = Color(0xFF352A18);
  static const Color darkBorder         = Color(0xFF3A2E1E);

  // ── Text (dark) ────────────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFFAF7F1);
  static const Color darkTextSecondary = Color(0xFFC4B8A8);
  static const Color darkTextTertiary  = Color(0xFF8A7D6E);

  // ── Semantic ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF1E8A4A);
  static const Color warning = Color(0xFFFCD55E);
  static const Color error   = Color(0xFFC8371A);
  static const Color info    = Color(0xFF2E85C3);

  // ── Categories (mapped to Latin palette) ───────────────────────────
  static const Color categoryDirectorio = Color(0xFFE07830); // primary
  static const Color categoryEmpleos    = Color(0xFF2E85C3); // skyBlue
  static const Color categoryEventos    = Color(0xFF7B3FA0); // purple
  static const Color categoryForos      = Color(0xFFFCD55E); // gold
  static const Color categoryClima      = Color(0xFF2E85C3);
  static const Color categoryDivisas    = Color(0xFF15989F); // secondary
  static const Color categoryDeportes   = Color(0xFFC8371A); // red

  // ── Legacy aliases (kept for backwards compat — point to new palette)
  static const Color categoryFood          = latinRed;
  static const Color categoryServices      = latinSkyBlue;
  static const Color categoryHealth        = latinGreen;
  static const Color categoryShopping      = latinPurple;
  static const Color categoryEntertainment = latinGold;
}
