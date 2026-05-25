import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/radio/data/models/radio_models.dart';

/// Repository for radio station operations.
class RadioRepository {
  RadioRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Obtiene estaciones populares por país.
  Future<List<RadioStation>> getPopularStations({
    String countryCode = 'CO',
    int limit = 12,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.radioPopular,
      queryParameters: {'countryCode': countryCode, 'limit': limit},
    );
    return _parseStations(response.data);
  }

  /// Busca estaciones por query y país opcional.
  Future<List<RadioStation>> searchStations({
    required String query,
    String? countryCode,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.radioSearch,
      queryParameters: {
        'q': query,
        if (countryCode != null) 'countryCode': countryCode,
        'limit': limit,
      },
    );
    return _parseStations(response.data);
  }

  List<RadioStation> _parseStations(dynamic responseData) {
    final body = responseData as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final stations = data['stations'] as List<dynamic>;
    return stations
        .map((s) => RadioStation.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList();
  }
}
