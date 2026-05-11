import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/exchange/data/models/exchange_models.dart';

class ExchangeRepository {
  ExchangeRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<ExchangeRatesData> getPopularRates({required String base}) async {
    final response = await _dio.get(
      ApiEndpoints.exchangeRates,
      queryParameters: {'base': base, 'popular': 1},
    );
    return ExchangeRatesData.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<ConversionData> convert({
    required String base,
    required String target,
    double amount = 1,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.exchangeRates,
      queryParameters: {'base': base, 'target': target, 'amount': amount},
    );
    return ConversionData.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
