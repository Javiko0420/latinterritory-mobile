import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

/// Subtle Andean-textile pattern (diamonds + chevrons) used as a
/// decorative overlay on color-rich screens (Login hero, Home banner,
/// Profile hero, Weather, Sports live card, Exchange card).
///
/// Avoid using on flat cream backgrounds — it's meant to add texture
/// over saturated gradients or solid brand colors.
class AndeanPatternPainter extends CustomPainter {
  const AndeanPatternPainter({
    this.color = AppColors.primary,
    this.opacity = 0.05,
    this.tile = 28.0,
  });

  final Color color;
  final double opacity;
  final double tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final tileW = tile;
    final tileH = tile;

    for (double x = 0; x < size.width + tileW; x += tileW) {
      for (double y = 0; y < size.height + tileH; y += tileH) {
        // Left diamond
        final left = Path()
          ..moveTo(x, y + tileH / 2)
          ..lineTo(x + tileW / 4, y)
          ..lineTo(x + tileW / 2, y + tileH / 2)
          ..lineTo(x + tileW / 4, y + tileH)
          ..close();
        canvas.drawPath(left, paint);

        // Right diamond
        final right = Path()
          ..moveTo(x + tileW / 2, y + tileH / 2)
          ..lineTo(x + 3 * tileW / 4, y)
          ..lineTo(x + tileW, y + tileH / 2)
          ..lineTo(x + 3 * tileW / 4, y + tileH)
          ..close();
        canvas.drawPath(right, paint);

        // Center dot
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(x + tileW / 2, y + tileH / 2),
          1.2,
          paint,
        );
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AndeanPatternPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.tile != tile;
}

/// Wraps [child] in a stack with an optional solid background color
/// and an Andean pattern overlay drawn behind the child.
class AndeanPatternBackground extends StatelessWidget {
  const AndeanPatternBackground({
    super.key,
    required this.child,
    this.patternColor = AppColors.primary,
    this.opacity = 0.05,
    this.backgroundColor,
    this.tile = 28.0,
  });

  final Widget child;
  final Color patternColor;
  final double opacity;
  final Color? backgroundColor;
  final double tile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (backgroundColor != null)
          Positioned.fill(child: ColoredBox(color: backgroundColor!)),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: AndeanPatternPainter(
                color: patternColor,
                opacity: opacity,
                tile: tile,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
