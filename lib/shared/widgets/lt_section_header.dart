import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Encabezado de sección del design system: EYEBROW (mayúsculas, color de
/// acento) + título grande w800, con acción opcional "Ver todos" (azul).
class LtSectionHeader extends StatelessWidget {
  const LtSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.accent,
    this.actionLabel,
    this.onAction,
  });

  final String eyebrow;
  final String title;

  /// Color del eyebrow. Por defecto, el dorado de texto del tema.
  final Color? accent;

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: LTType.eyebrow(accent ?? c.goldText)),
              const SizedBox(height: 5),
              Text(title, style: LTType.title(c.ink)),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          LtPressable(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 2),
              child: Text(
                actionLabel!,
                style: LTType.caption(c.blue, size: 13, weight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
