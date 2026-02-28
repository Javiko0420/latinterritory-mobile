import 'package:flutter/material.dart';

/// Brand color palette for LatinTerritory.
///
/// Colors are inspired by the web platform with a warm, latino feel.
/// Primary: warm orange/amber tones.
/// Secondary: teal/green accents.
class AppColors {
  AppColors._();

  // ── Primary (Warm Latin Orange) ─────────────────────────
  static const Color primary = Color(0xFFE8792B);
  static const Color primaryLight = Color(0xFFF5A623);
  static const Color primaryDark = Color(0xFFC25D10);

  // ── Secondary (Teal) ────────────────────────────────────
  static const Color secondary = Color(0xFF1A9E8F);
  static const Color secondaryLight = Color(0xFF4DB8A8);
  static const Color secondaryDark = Color(0xFF0D7A6E);

  // ── Neutrals ────────────────────────────────────────────
  static const Color background = Color(0xFFF8F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F0EB);
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textTertiary = Color(0xFFA8A29E);
  static const Color border = Color(0xFFE7E5E4);
  static const Color divider = Color(0xFFF5F5F4);

  // ── Dark Mode ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1C1917);
  static const Color darkSurface = Color(0xFF292524);
  static const Color darkSurfaceVariant = Color(0xFF44403C);
  static const Color darkTextPrimary = Color(0xFFFAFAF9);
  static const Color darkTextSecondary = Color(0xFFA8A29E);
  static const Color darkBorder = Color(0xFF44403C);

  // ── Semantic ────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ── Category Colors (for business types, etc.) ──────────
  static const Color categoryFood = Color(0xFFEF4444);
  static const Color categoryServices = Color(0xFF3B82F6);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryShopping = Color(0xFF8B5CF6);
  static const Color categoryEntertainment = Color(0xFFF59E0B);
}
