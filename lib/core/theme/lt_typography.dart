import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// Design System "Latin Territory" — escala tipográfica.
///
/// Fuente: Hanken Grotesk (display + cuerpo) vía google_fonts. Consumir estos
/// helpers en vez de escribir TextStyle a mano, para garantizar la fuente y la
/// escala correctas en toda la app.
/// ============================================================
class LTType {
  LTType._();

  /// Display — títulos de pantalla (27–28 / w800 / -0.03em).
  static TextStyle display(Color color, {double size = 27}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * size,
        height: 1.08,
        color: color,
      );

  /// Title — encabezados de sección (20 / w800 / -0.025em).
  static TextStyle title(Color color, {double size = 20}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.025 * size,
        color: color,
      );

  /// Card — títulos de card (16–17 / w800 / -0.02em).
  static TextStyle card(Color color, {double size = 16.5}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * size,
        color: color,
      );

  /// Body — cuerpo (15 / w500).
  static TextStyle body(Color color, {double size = 15, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: size,
        fontWeight: weight,
        height: 1.4,
        color: color,
      );

  /// Caption — metadatos (12.5 / w500).
  static TextStyle caption(Color color, {double size = 12.5, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.hankenGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  /// Eyebrow / overline — 11 / w700 / +0.14em UPPERCASE (aplicar el color de
  /// acento y `.toUpperCase()` en el call site).
  static TextStyle eyebrow(Color color) => GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.54,
        color: color,
      );
}
