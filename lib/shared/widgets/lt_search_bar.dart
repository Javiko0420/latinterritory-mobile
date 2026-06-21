import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Barra de búsqueda del design system. Por defecto es un "botón" tappable
/// (abre la búsqueda real); si se pasa [readOnly] = false puede integrarse con
/// un TextField en el futuro. No contiene lógica de búsqueda.
class LtSearchBar extends StatelessWidget {
  const LtSearchBar({
    super.key,
    required this.hint,
    this.onTap,
  });

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.md),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 20, color: c.ink3),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LTType.body(c.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
