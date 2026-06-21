import 'package:flutter/material.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

class WcLoading extends StatelessWidget {
  const WcLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold));
  }
}

class WcEmpty extends StatelessWidget {
  const WcEmpty({super.key, required this.message, this.icon = Icons.sports_soccer_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: c.coralSoft, borderRadius: BorderRadius.circular(LTRadius.lg)),
              child: Icon(icon, size: 30, color: c.coral),
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: LTType.body(c.ink2)),
          ],
        ),
      ),
    );
  }
}

class WcError extends StatelessWidget {
  const WcError({super.key, required this.message, required this.retryLabel, required this.onRetry});

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: c.ink3),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: LTType.body(c.ink2)),
            const SizedBox(height: 10),
            LtPressable(onTap: onRetry, child: Text(retryLabel, style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}
