import 'package:flutter/material.dart';

/// Mapea un código WMO de clima a un ícono lineal de Material.
/// Fuente única reutilizada por el mini-widget y la pantalla de clima.
IconData weatherIconFor(int code) {
  if (code == 0 || code == 1) return Icons.wb_sunny_outlined;
  if (code == 2) return Icons.cloud_queue;
  if (code == 3) return Icons.cloud_outlined;
  if (code >= 45 && code <= 48) return Icons.blur_on;
  if (code >= 51 && code <= 67) return Icons.grain;
  if (code >= 71 && code <= 77) return Icons.ac_unit;
  if (code >= 80 && code <= 82) return Icons.umbrella;
  if (code >= 95) return Icons.flash_on;
  return Icons.cloud_outlined;
}
