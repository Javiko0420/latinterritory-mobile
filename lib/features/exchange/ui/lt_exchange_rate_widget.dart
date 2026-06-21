import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/exchange/data/models/exchange_models.dart';
import 'package:latinterritory/features/exchange/providers/exchange_providers.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Formatea una tasa al estilo del diseño: miles con separador para valores
/// grandes, 1–2 decimales para los pequeños (p.ej. 2.640 · 640.2 · 11.84).
String formatRate(double v) {
  if (v >= 1000) return NumberFormat('#,##0', 'es').format(v);
  if (v >= 100) return v.toStringAsFixed(1);
  return v.toStringAsFixed(2);
}

/// Mini-tarjeta de tasas de cambio (base AUD) para Home. Datos reales del
/// [audRatesProvider]. Tap → /exchange.
class LTExchangeRateWidget extends ConsumerWidget {
  const LTExchangeRateWidget({super.key, this.width = 178});

  final double width;

  /// Monedas mostradas en el mini (en orden).
  static const _codes = ['COP', 'MXN', 'ARS'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(audRatesProvider);

    return LtPressable(
      onTap: () => context.go('/exchange'),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.tile),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CAMBIO · AUD',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: c.ink2,
                    ),
                  ),
                ),
                _LiveBadge(),
              ],
            ),
            const SizedBox(height: 12),
            async.when(
              loading: () => _placeholderRows(c),
              error: (_, __) => Text('—', style: LTType.body(c.ink2)),
              data: (data) => Column(
                children: [
                  for (final code in _codes) _rateRow(c, code, data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateRow(LTColors c, String code, ExchangeRatesData data) {
    final value = data.rates[code];
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            code,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.ink2,
            ),
          ),
          Text(
            value == null ? '—' : formatRate(value),
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: c.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderRows(LTColors c) => Column(
        children: [
          for (final code in _codes)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(code, style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2)),
                  Text('···', style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
                ],
              ),
            ),
        ],
      );
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: c.greenSoft,
        borderRadius: BorderRadius.circular(LTRadius.pill),
      ),
      child: Text(
        'LIVE',
        style: GoogleFonts.hankenGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: c.green,
        ),
      ),
    );
  }
}
