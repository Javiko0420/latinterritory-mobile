import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';

/// Ratio de contraste WCAG entre dos colores (1..21).
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('onGreen cumple AA (>= 4.5:1) sobre green en ambos temas', () {
    expect(
      _contrast(LTColors.light.onGreen, LTColors.light.green),
      greaterThanOrEqualTo(4.5),
      reason: 'texto onGreen sobre pill verde en light theme',
    );
    expect(
      _contrast(LTColors.dark.onGreen, LTColors.dark.green),
      greaterThanOrEqualTo(4.5),
      reason: 'texto onGreen sobre pill verde en dark theme',
    );
  });
}
