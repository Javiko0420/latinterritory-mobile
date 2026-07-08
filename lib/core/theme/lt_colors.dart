import 'package:flutter/material.dart';

/// ============================================================
/// Design System "Latin Territory" — color tokens (single source of truth).
///
/// Valores EXACTOS del design system (coherentes con la web). No modificar los
/// hex. Consumir SIEMPRE vía `Theme.of(context).extension<LTColors>()!` para que
/// el cambio de tema (claro/oscuro) se refleje en toda la app.
/// ============================================================

/// Acentos de marca (banderas latinas, baja saturación). Iguales en ambos temas.
class LTBrand {
  LTBrand._();
  static const gold    = Color(0xFFE0A92E); // acento principal / CTA
  static const goldInk = Color(0xFFC0851E); // oro para TEXTO sobre claro
  static const night   = Color(0xFF1E3A5F); // azul noche / marca
  static const coral   = Color(0xFFBF553D); // terracota / eventos
  static const green   = Color(0xFF3F7F61); // verde suave / éxito
  static const onGold  = Color(0xFF1A1408); // texto sobre botones dorados
}

/// Paleta del tema CLARO.
class LTLight {
  LTLight._();
  static const bg        = Color(0xFFFAF6EE);
  static const card      = Color(0xFFFFFFFF);
  static const card2     = Color(0xFFF4EEE2);
  static const ink       = Color(0xFF1A1916);
  static const ink2      = Color(0xFF6E6A60);
  static const ink3      = Color(0xFFA7A296);
  static const line      = Color(0xFFECE6D8);
  static const gold      = Color(0xFFE0A92E);
  static const goldText  = Color(0xFFC0851E);
  static const goldBg    = Color(0xFFF6EAD0);
  static const blue      = Color(0xFF1E3A5F);
  static const blueSoft  = Color(0xFFE5EAF1);
  static const coral     = Color(0xFFBF553D);
  static const coralSoft = Color(0xFFF6E2DB);
  static const green     = Color(0xFF3F7F61);
  static const greenSoft = Color(0xFFE2EDE6);
  static const onGreen   = Color(0xFFFFFFFF); // texto sobre relleno green (4.75:1)
  static const tabbar    = Color(0xDBFFFFFF); // blanco 86%
  static const shadow1   = Color(0x0F282114); // blur 22, offset (0,4)
  static const shadow2   = Color(0x0D282114); // blur 3,  offset (0,1)
}

/// Paleta del tema OSCURO (azul noche).
class LTDark {
  LTDark._();
  static const bg        = Color(0xFF121519);
  static const card      = Color(0xFF1B1F26);
  static const card2     = Color(0xFF232A33);
  static const ink       = Color(0xFFF1EDE3);
  static const ink2      = Color(0xFFA29E94);
  static const ink3      = Color(0xFF6E6A62);
  static const line      = Color(0x17FFFFFF); // blanco 9%
  static const gold      = Color(0xFFE6B84D);
  static const goldText  = Color(0xFFE6B84D);
  static const goldBg    = Color(0xFF2A2616);
  static const blue      = Color(0xFF3A6491);
  static const blueSoft  = Color(0xFF1E2A3A);
  static const coral     = Color(0xFFDC7257);
  static const coralSoft = Color(0xFF2E211C);
  static const green     = Color(0xFF5FA07E);
  static const greenSoft = Color(0xFF18261F);
  static const onGreen   = Color(0xFF18261F); // texto sobre relleno green (5.1:1)
  static const tabbar    = Color(0xD11B1F26); // card 82%
  static const shadow1   = Color(0x73000000); // blur 26, offset (0,6)
  static const shadow2   = Color(0x40000000); // blur 2,  offset (0,1)
}

/// ThemeExtension con TODOS los tokens de superficie/acento + sombra suave.
/// Acceso: `final c = context.lt;` (ver extensión [LTColorsX] abajo).
@immutable
class LTColors extends ThemeExtension<LTColors> {
  final Color bg, card, card2, ink, ink2, ink3, line, tabbar;
  final Color gold, goldText, goldBg, blue, blueSoft, coral, coralSoft, green, greenSoft, onGreen;
  final List<BoxShadow> softShadow;

  const LTColors({
    required this.bg,
    required this.card,
    required this.card2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.tabbar,
    required this.gold,
    required this.goldText,
    required this.goldBg,
    required this.blue,
    required this.blueSoft,
    required this.coral,
    required this.coralSoft,
    required this.green,
    required this.greenSoft,
    required this.onGreen,
    required this.softShadow,
  });

  // Acentos de marca compartidos (no dependen del tema).
  Color get onGold => LTBrand.onGold;

  static const light = LTColors(
    bg: LTLight.bg, card: LTLight.card, card2: LTLight.card2,
    ink: LTLight.ink, ink2: LTLight.ink2, ink3: LTLight.ink3, line: LTLight.line,
    tabbar: LTLight.tabbar, gold: LTLight.gold, goldText: LTLight.goldText, goldBg: LTLight.goldBg,
    blue: LTLight.blue, blueSoft: LTLight.blueSoft, coral: LTLight.coral, coralSoft: LTLight.coralSoft,
    green: LTLight.green, greenSoft: LTLight.greenSoft, onGreen: LTLight.onGreen,
    softShadow: [
      BoxShadow(color: LTLight.shadow1, blurRadius: 22, offset: Offset(0, 4)),
      BoxShadow(color: LTLight.shadow2, blurRadius: 3, offset: Offset(0, 1)),
    ],
  );

  static const dark = LTColors(
    bg: LTDark.bg, card: LTDark.card, card2: LTDark.card2,
    ink: LTDark.ink, ink2: LTDark.ink2, ink3: LTDark.ink3, line: LTDark.line,
    tabbar: LTDark.tabbar, gold: LTDark.gold, goldText: LTDark.goldText, goldBg: LTDark.goldBg,
    blue: LTDark.blue, blueSoft: LTDark.blueSoft, coral: LTDark.coral, coralSoft: LTDark.coralSoft,
    green: LTDark.green, greenSoft: LTDark.greenSoft, onGreen: LTDark.onGreen,
    softShadow: [
      BoxShadow(color: LTDark.shadow1, blurRadius: 26, offset: Offset(0, 6)),
      BoxShadow(color: LTDark.shadow2, blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  @override
  LTColors copyWith({
    Color? bg, Color? card, Color? card2, Color? ink, Color? ink2, Color? ink3,
    Color? line, Color? tabbar, Color? gold, Color? goldText, Color? goldBg,
    Color? blue, Color? blueSoft, Color? coral, Color? coralSoft, Color? green,
    Color? greenSoft, Color? onGreen, List<BoxShadow>? softShadow,
  }) {
    return LTColors(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      card2: card2 ?? this.card2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      tabbar: tabbar ?? this.tabbar,
      gold: gold ?? this.gold,
      goldText: goldText ?? this.goldText,
      goldBg: goldBg ?? this.goldBg,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      coral: coral ?? this.coral,
      coralSoft: coralSoft ?? this.coralSoft,
      green: green ?? this.green,
      greenSoft: greenSoft ?? this.greenSoft,
      onGreen: onGreen ?? this.onGreen,
      softShadow: softShadow ?? this.softShadow,
    );
  }

  /// Lerp real para que la transición de tema (~400ms) anime los colores.
  @override
  LTColors lerp(covariant LTColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return LTColors(
      bg: c(bg, other.bg),
      card: c(card, other.card),
      card2: c(card2, other.card2),
      ink: c(ink, other.ink),
      ink2: c(ink2, other.ink2),
      ink3: c(ink3, other.ink3),
      line: c(line, other.line),
      tabbar: c(tabbar, other.tabbar),
      gold: c(gold, other.gold),
      goldText: c(goldText, other.goldText),
      goldBg: c(goldBg, other.goldBg),
      blue: c(blue, other.blue),
      blueSoft: c(blueSoft, other.blueSoft),
      coral: c(coral, other.coral),
      coralSoft: c(coralSoft, other.coralSoft),
      green: c(green, other.green),
      greenSoft: c(greenSoft, other.greenSoft),
      onGreen: c(onGreen, other.onGreen),
      softShadow: t < 0.5 ? softShadow : other.softShadow,
    );
  }
}

/// Azúcar sintáctico: `context.lt.card`, `context.lt.softShadow`, …
extension LTColorsX on BuildContext {
  LTColors get lt => Theme.of(this).extension<LTColors>()!;
}
