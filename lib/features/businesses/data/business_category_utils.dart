import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

/// Shared category labels, icons and accent colors for business UI.
class BusinessCategoryUtils {
  BusinessCategoryUtils._();

  static const labels = {
    'GASTRONOMIA': 'Gastronomía',
    'TECNOLOGIA': 'Tecnología',
    'ARTESANIAS': 'Artesanías',
    'SERVICIOS': 'Servicios',
    'MODA': 'Moda',
    'SALUD': 'Salud',
    'EDUCACION': 'Educación',
    'TURISMO': 'Turismo',
    'ENTRETENIMIENTO': 'Entretenimiento',
    'OTROS': 'Otros',
  };

  static const icons = {
    'GASTRONOMIA': Icons.restaurant,
    'TECNOLOGIA': Icons.computer,
    'ARTESANIAS': Icons.handyman,
    'SERVICIOS': Icons.build,
    'MODA': Icons.checkroom,
    'SALUD': Icons.health_and_safety,
    'EDUCACION': Icons.school,
    'TURISMO': Icons.travel_explore,
    'ENTRETENIMIENTO': Icons.theater_comedy,
    'OTROS': Icons.store,
  };

  static const accentColors = {
    'GASTRONOMIA': AppColors.latinRed,
    'TECNOLOGIA': AppColors.latinSkyBlue,
    'ARTESANIAS': AppColors.latinGold,
    'SERVICIOS': AppColors.secondary,
    'MODA': AppColors.latinPurple,
    'SALUD': AppColors.latinGreen,
    'EDUCACION': AppColors.primary,
    'TURISMO': AppColors.latinSkyBlue,
    'ENTRETENIMIENTO': AppColors.latinPurple,
    'OTROS': AppColors.primaryDark,
  };

  static String labelFor(String category) =>
      labels[category] ?? _titleCase(category);

  static IconData iconFor(String category) =>
      icons[category] ?? Icons.store;

  static Color accentColorFor(String category) =>
      accentColors[category] ?? AppColors.primary;

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .toLowerCase()
        .split('_')
        .map((part) =>
            part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
