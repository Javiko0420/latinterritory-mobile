import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';

/// Entrada de contenido tipo Apple: slide-up sutil (translateY 10 → 0, ~340ms).
///
/// IMPORTANTE: la opacidad base es 1 (no anima desde opacity:0) para que el
/// contenido nunca quede invisible si la animación no corre.
class LtScreenIn extends StatelessWidget {
  const LtScreenIn({super.key, required this.child, this.offset = 10});

  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: LTMotion.screenIn,
      curve: LTMotion.curve,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, t * offset),
        child: child,
      ),
      child: child,
    );
  }
}
