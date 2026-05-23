import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/features/exchange/data/models/exchange_models.dart';
import 'package:latinterritory/features/exchange/providers/exchange_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_andean_pattern.dart';

// ── Currency metadata ─────────────────────────────────────

class _CurrencyMeta {
  const _CurrencyMeta(this.flag, this.name);
  final String flag;
  final String name;
}

const _meta = <String, _CurrencyMeta>{
  'USD': _CurrencyMeta('🇺🇸', 'Dólar Estadounidense'),
  'EUR': _CurrencyMeta('🇪🇺', 'Euro'),
  'GBP': _CurrencyMeta('🇬🇧', 'Libra Esterlina'),
  'CAD': _CurrencyMeta('🇨🇦', 'Dólar Canadiense'),
  'AUD': _CurrencyMeta('🇦🇺', 'Dólar Australiano'),
  'MXN': _CurrencyMeta('🇲🇽', 'Peso Mexicano'),
  'BRL': _CurrencyMeta('🇧🇷', 'Real Brasileño'),
  'ARS': _CurrencyMeta('🇦🇷', 'Peso Argentino'),
  'CLP': _CurrencyMeta('🇨🇱', 'Peso Chileno'),
  'JPY': _CurrencyMeta('🇯🇵', 'Yen Japonés'),
  'CNY': _CurrencyMeta('🇨🇳', 'Yuan Chino'),
  'COP': _CurrencyMeta('🇨🇴', 'Peso Colombiano'),
};

String _flag(String code) => _meta[code]?.flag ?? '';
String _name(String code) => _meta[code]?.name ?? code;

String _fmt(double value) {
  if (value >= 1000) return NumberFormat('#,##0', 'en_US').format(value);
  if (value >= 10) return NumberFormat('#,##0.0#', 'en_US').format(value);
  if (value >= 1) return NumberFormat('#,##0.00', 'en_US').format(value);
  return NumberFormat('#,##0.0000', 'en_US').format(value);
}

// ── Screen ────────────────────────────────────────────────

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  final _amountController = TextEditingController(text: '1');
  double _fromAmount = 1.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rateAsync = ref.watch(exchangeRateProvider);
    final popularAsync = ref.watch(popularRatesProvider);
    final toAmount = rateAsync.asData?.value != null
        ? rateAsync.asData!.value.rate * _fromAmount
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasas de Cambio')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(popularRatesProvider);
          ref.invalidate(exchangeRateProvider);
          try {
            await Future.wait([
              ref.read(popularRatesProvider.future),
              ref.read(exchangeRateProvider.future),
            ]);
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Converter ─────────────────────────────
              _ConverterCard(
                amountController: _amountController,
                toAmount: toAmount,
                rateAsync: rateAsync,
                onAmountChanged: (v) => setState(() {
                  _fromAmount = double.tryParse(v) ?? 0.0;
                }),
              ),

              const SizedBox(height: AppDimensions.lg),

              // ── Popular rates ─────────────────────────
              Text(
                'Monedas Populares vs COP',
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.sm),
              popularAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _PopularRatesError(
                  onRetry: () => ref.invalidate(popularRatesProvider),
                ),
                data: (rates) => _PopularRatesGrid(rates: rates),
              ),

              // ── Last update ───────────────────────────
              if (popularAsync.asData?.value != null) ...[
                const SizedBox(height: AppDimensions.md),
                _LastUpdateRow(
                    lastUpdate: popularAsync.asData!.value.lastUpdate),
              ],

              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Converter card ────────────────────────────────────────

class _ConverterCard extends ConsumerWidget {
  const _ConverterCard({
    required this.amountController,
    required this.toAmount,
    required this.rateAsync,
    required this.onAmountChanged,
  });

  final TextEditingController amountController;
  final double? toAmount;
  final AsyncValue<ConversionData> rateAsync;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(exchangeConverterProvider);
    final notifier = ref.read(exchangeConverterProvider.notifier);
    final innerFill = Colors.white.withValues(alpha: 0.16);
    final innerBorder = Colors.white.withValues(alpha: 0.25);

    InputDecoration field({String? prefixText}) => InputDecoration(
          filled: true,
          fillColor: innerFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(color: innerBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide: BorderSide(color: innerBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            borderSide:
                const BorderSide(color: Colors.white, width: 1.5),
          ),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.white),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.secondaryDark],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: AndeanPatternPainter(
                    color: Colors.white,
                    opacity: 0.10,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_exchange,
                          color: Colors.white, size: AppDimensions.iconMd),
                      const SizedBox(width: AppDimensions.sm),
                      Text(
                        'Convertidor',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // ── De ────────────────────────────────
                  Text(
                    'De',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _CurrencyDropdown(
                          value: s.fromCurrency,
                          onChanged: notifier.setFromCurrency,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]')),
                          ],
                          textAlign: TextAlign.end,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration:
                              field(prefixText: '${_flag(s.fromCurrency)} '),
                          onChanged: onAmountChanged,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.sm),

                  // ── Rate + swap button ────────────────
                  Row(
                    children: [
                      Expanded(
                        child: rateAsync.when(
                          loading: () => const SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (e, _) => Text(
                            'Error al obtener tasa',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          data: (conv) => Text(
                            '1 ${conv.from.currency} = ${_fmt(conv.rate)} ${conv.to.currency}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color:
                                  Colors.white.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: notifier.swap,
                        icon: const Icon(Icons.swap_vert_rounded),
                        color: Colors.white,
                        tooltip: 'Intercambiar monedas',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.xs),

                  // ── A ─────────────────────────────────
                  Text(
                    'A',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _CurrencyDropdown(
                          value: s.toCurrency,
                          onChanged: notifier.setToCurrency,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: innerFill,
                            border: Border.all(color: innerBorder),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_flag(s.toCurrency)} ',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Flexible(
                                child: Text(
                                  toAmount != null ? _fmt(toAmount!) : '—',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Currency dropdown ─────────────────────────────────────

class _CurrencyDropdown extends StatelessWidget {
  const _CurrencyDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.xs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: supportedCurrencies.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text('${_flag(code)} $code'),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ── Popular rates grid ────────────────────────────────────

const _popularOrder = [
  'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'MXN', 'BRL', 'ARS', 'CLP', 'JPY', 'CNY',
];

class _PopularRatesGrid extends StatelessWidget {
  const _PopularRatesGrid({required this.rates});
  final ExchangeRatesData rates;

  @override
  Widget build(BuildContext context) {
    final currencies =
        _popularOrder.where((c) => rates.rates.containsKey(c)).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.sm,
        crossAxisSpacing: AppDimensions.sm,
        childAspectRatio: 1.7,
      ),
      itemCount: currencies.length,
      itemBuilder: (context, i) {
        final code = currencies[i];
        final raw = rates.rates[code] ?? 0.0;
        final rateVsCop = raw > 0 ? 1.0 / raw : 0.0;
        return _RateCard(code: code, copRate: rateVsCop);
      },
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.code, required this.copRate});

  final String code;
  final double copRate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text(_flag(code), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  code,
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              _name(code),
              style: context.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '1 $code = ${_fmt(copRate)} COP',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error widget ──────────────────────────────────────────

class _PopularRatesError extends StatelessWidget {
  const _PopularRatesError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.lg),
          const Icon(Icons.error_outline,
              color: AppColors.error, size: AppDimensions.iconXl),
          const SizedBox(height: AppDimensions.sm),
          const Text('No se pudieron cargar las tasas'),
          const SizedBox(height: AppDimensions.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
          const SizedBox(height: AppDimensions.lg),
        ],
      ),
    );
  }
}

// ── Last update ───────────────────────────────────────────

class _LastUpdateRow extends StatelessWidget {
  const _LastUpdateRow({required this.lastUpdate});
  final String lastUpdate;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(lastUpdate)?.toLocal();
    if (date == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Actualizado: ${DateFormat("dd/MM/yyyy HH:mm").format(date)}',
        style: context.textTheme.bodySmall
            ?.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
