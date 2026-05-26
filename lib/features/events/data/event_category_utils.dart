import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

/// Shared category accent colors for event UI.
class EventCategoryUtils {
  EventCategoryUtils._();

  static const accentColors = {
    'Concierto': AppColors.latinRed,
    'Teatro': AppColors.latinPurple,
    'Comedia': AppColors.latinGold,
    'Fiesta': AppColors.primary,
    'Deportes': AppColors.latinGreen,
    'Cultural': AppColors.latinSkyBlue,
    'Networking': AppColors.secondary,
    'Otro': AppColors.primaryDark,
  };

  static Color accentColorFor(String category) =>
      accentColors[category] ?? AppColors.latinPurple;
}
