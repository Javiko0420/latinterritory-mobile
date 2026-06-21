import 'package:flutter/animation.dart';

/// ============================================================
/// Design System "Latin Territory" — forma, espaciado y motion.
/// Valores EXACTOS del design system. Consumir SIEMPRE estos tokens; prohibido
/// hardcodear radios/medidas/duraciones en las pantallas.
/// ============================================================

/// Radios de borde.
class LTRadius {
  LTRadius._();
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 22.0;
  static const double tile = 20.0; // tiles de íconos / shortcuts
  static const double pill = 99.0;
}

/// Escala de espaciado + paddings de pantalla.
class LTSpace {
  LTSpace._();
  static const double x2 = 8.0;
  static const double x3 = 12.0;
  static const double x4 = 16.0;
  static const double x5 = 22.0;

  /// Padding horizontal de pantalla.
  static const double screenH = 22.0;

  /// Espacio superior (deja libre la status bar).
  static const double screenTop = 62.0;

  /// Espacio inferior (deja libre el bottom nav).
  static const double screenBottom = 116.0;
}

/// Duraciones y curva de las microinteracciones (precisas, tipo Apple).
class LTMotion {
  LTMotion._();
  static const Duration press = Duration(milliseconds: 160);
  static const Duration screenIn = Duration(milliseconds: 340);
  static const Duration sheet = Duration(milliseconds: 380);
  static const Duration theme = Duration(milliseconds: 400);
  static const Cubic curve = Cubic(0.2, 0.8, 0.2, 1);
}
