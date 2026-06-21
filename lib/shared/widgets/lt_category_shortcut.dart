import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Acceso rápido a una sección: tile de 62px con ícono sobre fondo *Soft del
/// acento + etiqueta debajo. Diseñado para una fila horizontal.
class LtCategoryShortcut extends StatelessWidget {
  const LtCategoryShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(LTRadius.tile),
              ),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: LTType.caption(c.ink2, size: 12, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
