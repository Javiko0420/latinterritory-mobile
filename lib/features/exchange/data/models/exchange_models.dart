import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_models.freezed.dart';
part 'exchange_models.g.dart';

Map<String, double> _ratesFromJson(Map<String, dynamic> json) =>
    json.map((k, v) => MapEntry(k, (v as num).toDouble()));

@freezed
abstract class ExchangeRatesData with _$ExchangeRatesData {
  const factory ExchangeRatesData({
    required String baseCurrency,
    required String lastUpdate,
    @JsonKey(fromJson: _ratesFromJson) required Map<String, double> rates,
  }) = _ExchangeRatesData;

  factory ExchangeRatesData.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRatesDataFromJson(json);
}

@freezed
abstract class CurrencyAmount with _$CurrencyAmount {
  const factory CurrencyAmount({
    required String currency,
    required double amount,
  }) = _CurrencyAmount;

  factory CurrencyAmount.fromJson(Map<String, dynamic> json) =>
      _$CurrencyAmountFromJson(json);
}

@freezed
abstract class ConversionData with _$ConversionData {
  const factory ConversionData({
    required CurrencyAmount from,
    required CurrencyAmount to,
    required double rate,
    required String lastUpdate,
  }) = _ConversionData;

  factory ConversionData.fromJson(Map<String, dynamic> json) =>
      _$ConversionDataFromJson(json);
}
