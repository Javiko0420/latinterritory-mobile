import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/weather/data/models/weather_models.dart';
import 'package:latinterritory/features/weather/data/weather_repository.dart';

// ── Repository ────────────────────────────────────────────

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(dio: ref.watch(dioProvider));
});

// ── Cities ────────────────────────────────────────────────

const colombiaCities = [
  WeatherCity(slug: 'bogota', name: 'Bogotá', country: 'Colombia'),
  WeatherCity(slug: 'medellin', name: 'Medellín', country: 'Colombia'),
  WeatherCity(slug: 'cali', name: 'Cali', country: 'Colombia'),
  WeatherCity(slug: 'barranquilla', name: 'Barranquilla', country: 'Colombia'),
  WeatherCity(slug: 'cartagena', name: 'Cartagena', country: 'Colombia'),
  WeatherCity(slug: 'bucaramanga', name: 'Bucaramanga', country: 'Colombia'),
  WeatherCity(slug: 'cucuta', name: 'Cúcuta', country: 'Colombia'),
  WeatherCity(slug: 'pereira', name: 'Pereira', country: 'Colombia'),
  WeatherCity(slug: 'santa-marta', name: 'Santa Marta', country: 'Colombia'),
  WeatherCity(slug: 'manizales', name: 'Manizales', country: 'Colombia'),
];

const australiaCities = [
  WeatherCity(slug: 'brisbane', name: 'Brisbane', country: 'Australia'),
  WeatherCity(slug: 'sydney', name: 'Sydney', country: 'Australia'),
  WeatherCity(slug: 'melbourne', name: 'Melbourne', country: 'Australia'),
];

const allWeatherCities = [...australiaCities, ...colombiaCities];

// ── Selected City ─────────────────────────────────────────

final selectedCityProvider =
    NotifierProvider<SelectedCityNotifier, WeatherCity>(
  SelectedCityNotifier.new,
);

class SelectedCityNotifier extends Notifier<WeatherCity> {
  @override
  WeatherCity build() => australiaCities.first; // Default: Brisbane

  void select(WeatherCity city) {
    state = city;
  }
}

// ── Weather Data ──────────────────────────────────────────

final weatherProvider = FutureProvider<WeatherBundle>((ref) async {
  final repo = ref.watch(weatherRepositoryProvider);
  final city = ref.watch(selectedCityProvider);
  return repo.getWeatherByCity(city.slug);
});
