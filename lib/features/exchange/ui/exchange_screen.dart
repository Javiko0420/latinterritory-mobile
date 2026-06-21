import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/exchange/data/models/exchange_models.dart';
import 'package:latinterritory/features/exchange/providers/exchange_providers.dart';
import 'package:latinterritory/features/exchange/ui/lt_exchange_rate_widget.dart' show formatRate;
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

// Nombres de moneda (sin emojis). Fallback al código si no está mapeado.
const _currencyNames = <String, String>{
  'AUD': 'Dólar australiano',
  'COP': 'Peso colombiano',
  'MXN': 'Peso mexicano',
  'ARS': 'Peso argentino',
  'BRL': 'Real brasileño',
  'CLP': 'Peso chileno',
  'PEN': 'Sol peruano',
  'UYU': 'Peso uruguayo',
  'BOB': 'Boliviano',
  'PYG': 'Guaraní',
  'VES': 'Bolívar',
  'USD': 'Dólar estadounidense',
  'EUR': 'Euro',
};

// Orden de la lista (audiencia latina + referencias).
const _ratesOrder = [
  'COP', 'MXN', 'ARS', 'BRL', 'CLP', 'PEN', 'UYU', 'BOB', 'USD', 'EUR',
];

String _name(String code) => _currencyNames[code] ?? code;

class ExchangeScreen extends ConsumerWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(audRatesProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: RefreshIndicator(
            color: c.gold,
            onRefresh: () async => ref.invalidate(audRatesProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LTSpace.screenH, LTSpace.x4, LTSpace.screenH, LTSpace.screenBottom,
              ),
              children: [
                _Header(eyebrow: 'TASAS AL INSTANTE', title: 'Cambio de divisas', accent: c.green),
                const SizedBox(height: LTSpace.x4),
                const _ConverterCard(),
                const SizedBox(height: LTSpace.x5),
                const _BaseCard(),
                const SizedBox(height: LTSpace.x5),
                async.when(
                  loading: () => const _Loader(),
                  error: (_, __) => _ErrorBox(onRetry: () => ref.invalidate(audRatesProvider)),
                  data: (data) => _RatesList(data: data),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Convertidor (funcionalidad existente, re-estilizada) ──────────────────

class _ConverterCard extends ConsumerStatefulWidget {
  const _ConverterCard();

  @override
  ConsumerState<_ConverterCard> createState() => _ConverterCardState();
}

class _ConverterCardState extends ConsumerState<_ConverterCard> {
  final _amountCtrl = TextEditingController(text: '1');
  double _amount = 1;

  static const _ink = Color(0xFFF1EDE3);

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final s = ref.watch(exchangeConverterProvider);
    final notifier = ref.read(exchangeConverterProvider.notifier);
    final rateAsync = ref.watch(exchangeRateProvider);
    final conv = rateAsync.asData?.value;
    final result = conv != null ? conv.rate * _amount : null;
    final fill = Colors.white.withValues(alpha: 0.14);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LTBrand.night, Color(0xFF16273F)],
        ),
        borderRadius: BorderRadius.circular(LTRadius.lg),
        boxShadow: c.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONVERTIDOR',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.54,
              color: _ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Picker(value: s.fromCurrency, onChanged: notifier.setFromCurrency, fill: fill)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  textAlign: TextAlign.end,
                  style: GoogleFonts.hankenGrotesk(color: _ink, fontSize: 16, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: fill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LTRadius.sm),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _amount = double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  conv != null ? '1 ${conv.from.currency} = ${formatRate(conv.rate)} ${conv.to.currency}' : '…',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _ink.withValues(alpha: 0.8),
                  ),
                ),
              ),
              GestureDetector(
                onTap: notifier.swap,
                child: Icon(Icons.swap_vert_rounded, color: _ink, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _Picker(value: s.toCurrency, onChanged: notifier.setToCurrency, fill: fill)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 46,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(LTRadius.sm),
                  ),
                  child: Text(
                    result != null ? formatRate(result) : '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(color: _ink, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.value, required this.onChanged, required this.fill});

  final String value;
  final ValueChanged<String> onChanged;
  final Color fill;

  static const _ink = Color(0xFFF1EDE3);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(LTRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1B1F26),
          iconEnabledColor: _ink,
          style: GoogleFonts.hankenGrotesk(color: _ink, fontSize: 15, fontWeight: FontWeight.w700),
          items: supportedCurrencies
              .map((code) => DropdownMenuItem(value: code, child: Text(code)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  const _BaseCard();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(LTSpace.x4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: c.goldBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              'AUD',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: c.goldText,
              ),
            ),
          ),
          const SizedBox(width: LTSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BASE', style: LTType.eyebrow(c.ink3)),
                const SizedBox(height: 2),
                Text('Dólar australiano', style: LTType.card(c.ink, size: 17)),
              ],
            ),
          ),
          Text(
            r'$1',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.48,
              color: c.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatesList extends ConsumerWidget {
  const _RatesList({required this.data});

  final ExchangeRatesData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codes = _ratesOrder.where((code) => data.rates.containsKey(code)).toList();

    return Column(
      children: [
        for (final code in codes) ...[
          _RateRow(code: code, value: data.rates[code]!),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.code, required this.value});

  final String code;
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.card2,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              code,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: c.ink,
              ),
            ),
          ),
          const SizedBox(width: LTSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRate(value),
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _name(code),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LTType.caption(c.ink2, size: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header / estados ──────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title, required this.accent});

  final String eyebrow;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Row(
      children: [
        LtPressable(
          onTap: () => context.go('/home'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(LTRadius.md),
              border: Border.all(color: c.line),
            ),
            child: Icon(Icons.chevron_left, color: c.ink, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: LTType.eyebrow(accent)),
              const SizedBox(height: 2),
              Text(title, style: LTType.display(c.ink, size: 26)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('No pudimos cargar las tasas.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(
            onTap: onRetry,
            child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
