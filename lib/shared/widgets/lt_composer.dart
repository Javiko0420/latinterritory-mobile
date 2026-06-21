import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Barra inferior para escribir un post/comentario: input + botón de envío
/// dorado. Reutilizable en foros (posts y comentarios).
class LtComposer extends StatelessWidget {
  const LtComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.maxLength,
    required this.submitting,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final bool submitting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 10, LTSpace.screenH, 10),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: 4,
              minLines: 1,
              enabled: !submitting,
              style: LTType.body(c.ink, size: 14.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: LTType.body(c.ink3, size: 14.5),
                counterText: '',
                filled: true,
                fillColor: c.card2,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.lg), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.lg), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.lg), borderSide: BorderSide(color: c.gold, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          LtPressable(
            onTap: submitting ? null : onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: c.gold, shape: BoxShape.circle),
              child: submitting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: LTBrand.onGold),
                    )
                  : const Icon(Icons.arrow_upward_rounded, color: LTBrand.onGold, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
