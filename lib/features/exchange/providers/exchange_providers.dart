import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/exchange/data/exchange_repository.dart';
import 'package:latinterritory/features/exchange/data/models/exchange_models.dart';

// ── Repository ────────────────────────────────────────────

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return ExchangeRepository(dio: ref.watch(dioProvider));
});

// ── Supported currencies (converter dropdowns) ────────────

const supportedCurrencies = [
  'AUD', 'COP', 'USD', 'EUR', 'GBP', 'CAD', 'MXN', 'BRL', 'ARS', 'CLP', 'JPY', 'CNY',
];

// ── Popular rates (base COP) ──────────────────────────────

final popularRatesProvider = FutureProvider<ExchangeRatesData>((ref) async {
  return ref.watch(exchangeRepositoryProvider).getPopularRates(base: 'COP');
});

// ── Converter state ───────────────────────────────────────

class ExchangeConverterState {
  const ExchangeConverterState({
    this.fromCurrency = 'AUD',
    this.toCurrency = 'COP',
  });

  final String fromCurrency;
  final String toCurrency;

  ExchangeConverterState copyWith({String? fromCurrency, String? toCurrency}) {
    return ExchangeConverterState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }
}

final exchangeConverterProvider =
    NotifierProvider<ExchangeConverterNotifier, ExchangeConverterState>(
  ExchangeConverterNotifier.new,
);

class ExchangeConverterNotifier extends Notifier<ExchangeConverterState> {
  @override
  ExchangeConverterState build() => const ExchangeConverterState();

  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
  }

  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
  }

  void swap() {
    state = ExchangeConverterState(
      fromCurrency: state.toCurrency,
      toCurrency: state.fromCurrency,
    );
  }
}

// ── Exchange rate for 1 unit (triggers API on currency change) ──

final exchangeRateProvider = FutureProvider<ConversionData>((ref) async {
  final s = ref.watch(exchangeConverterProvider);
  return ref.watch(exchangeRepositoryProvider).convert(
        base: s.fromCurrency,
        target: s.toCurrency,
      );
});
