import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/weather/data/models/weather_models.dart';

/// Repository for weather operations.
class WeatherRepository {
  WeatherRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches weather for a city by slug.
  Future<WeatherBundle> getWeatherByCity(String citySlug) async {
    final response = await _dio.get(
      ApiEndpoints.weather,
      queryParameters: {'city': citySlug},
    );
    return WeatherBundle.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
