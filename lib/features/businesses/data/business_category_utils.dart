import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class BusinessCategoryUtils {
  BusinessCategoryUtils._();

  static const icons = {
    'GASTRONOMIA': Icons.restaurant,
    'TECNOLOGIA': Icons.computer,
    'ARTESANIAS': Icons.handyman,
    'SERVICIOS': Icons.build,
    'MODA': Icons.checkroom,
    'AGRICULTURA': Icons.agriculture,
    'TURISMO': Icons.travel_explore,
    'SALUD': Icons.health_and_safety,
    'EDUCACION': Icons.school,
    'CONSTRUCCION': Icons.construction,
    'TRANSPORTE': Icons.local_shipping,
    'ENTRETENIMIENTO': Icons.theater_comedy,
    'OTROS': Icons.store,
  };

  static const accentColors = {
    'GASTRONOMIA': AppColors.latinRed,
    'TECNOLOGIA': AppColors.latinSkyBlue,
    'ARTESANIAS': AppColors.latinGold,
    'SERVICIOS': AppColors.secondary,
    'MODA': AppColors.latinPurple,
    'AGRICULTURA': AppColors.latinGreen,
    'TURISMO': AppColors.latinSkyBlue,
    'SALUD': AppColors.latinGreen,
    'EDUCACION': AppColors.primary,
    'CONSTRUCCION': AppColors.latinGold,
    'TRANSPORTE': AppColors.secondary,
    'ENTRETENIMIENTO': AppColors.latinPurple,
    'OTROS': AppColors.primaryDark,
  };

  // Maps legacy Title Case labels to their UPPERCASE enum value.
  static const Map<String, String> _legacyAliases = {
    'Gastronomía': 'GASTRONOMIA',
    'Tecnología': 'TECNOLOGIA',
    'Artesanías': 'ARTESANIAS',
    'Servicios': 'SERVICIOS',
    'Moda': 'MODA',
    'Agricultura': 'AGRICULTURA',
    'Turismo': 'TURISMO',
    'Salud': 'SALUD',
    'Educación': 'EDUCACION',
    'Construcción': 'CONSTRUCCION',
    'Transporte': 'TRANSPORTE',
    'Entretenimiento': 'ENTRETENIMIENTO',
    'Otros': 'OTROS',
  };

  /// Returns the canonical UPPERCASE enum value, tolerating legacy Title Case labels.
  static String normalize(String category) =>
      _legacyAliases[category] ?? category;

  static IconData iconFor(String category) =>
      icons[normalize(category)] ?? Icons.store;

  static Color accentColorFor(String category) =>
      accentColors[normalize(category)] ?? AppColors.primary;
}
