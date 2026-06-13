import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class EventCategoryUtils {
  EventCategoryUtils._();

  static const accentColors = {
    'CONCIERTO': AppColors.latinRed,
    'TEATRO': AppColors.latinPurple,
    'COMEDIA': AppColors.latinGold,
    'FIESTA': AppColors.primary,
    'FESTIVAL': AppColors.primaryLight,
    'DEPORTES': AppColors.latinGreen,
    'CULTURAL': AppColors.latinSkyBlue,
    'NETWORKING': AppColors.secondary,
    'OTRO': AppColors.primaryDark,
  };

  // Maps legacy Title Case labels to their UPPERCASE enum value.
  static const Map<String, String> _legacyAliases = {
    'Concierto': 'CONCIERTO',
    'Teatro': 'TEATRO',
    'Comedia': 'COMEDIA',
    'Fiesta': 'FIESTA',
    'Festival': 'FESTIVAL',
    'Deportes': 'DEPORTES',
    'Cultural': 'CULTURAL',
    'Networking': 'NETWORKING',
    'Otro': 'OTRO',
  };

  /// Returns the canonical UPPERCASE enum value, tolerating legacy Title Case labels.
  static String normalize(String category) =>
      _legacyAliases[category] ?? category;

  static Color accentColorFor(String category) =>
      accentColors[normalize(category)] ?? AppColors.latinPurple;
}
