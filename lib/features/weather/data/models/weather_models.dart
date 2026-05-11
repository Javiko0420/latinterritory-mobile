import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_models.freezed.dart';
part 'weather_models.g.dart';

/// City model for the weather selector.
@freezed
abstract class WeatherCity with _$WeatherCity {
  const factory WeatherCity({
    required String slug,
    required String name,
    String? country,
  }) = _WeatherCity;
}

/// Current weather data.
@freezed
abstract class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    required double temperatureC,
    required double feelsLikeC,
    required int humidityPercent,
    double? pressureHpa,
    required double windSpeedKmh,
    required int windDirectionDeg,
    required int weatherCode,
    required String weatherTextEs,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

/// Hourly forecast point.
@freezed
abstract class HourlyPoint with _$HourlyPoint {
  const factory HourlyPoint({
    required String time,
    required double temperatureC,
    required double feelsLikeC,
    required double precipitationMm,
    double? precipitationProbPercent,
    required double windSpeedKmh,
    required int windDirectionDeg,
    required int weatherCode,
  }) = _HourlyPoint;

  factory HourlyPoint.fromJson(Map<String, dynamic> json) =>
      _$HourlyPointFromJson(json);
}

/// Full weather bundle from GET /api/weather.
@freezed
abstract class WeatherBundle with _$WeatherBundle {
  const factory WeatherBundle({
    required CurrentWeather current,
    required List<HourlyPoint> next24h,
  }) = _WeatherBundle;

  factory WeatherBundle.fromJson(Map<String, dynamic> json) =>
      _$WeatherBundleFromJson(json);
}
