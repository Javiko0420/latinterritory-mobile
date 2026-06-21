import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/weather/data/location_service.dart';
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

// ── Geolocalización → ciudad soportada más cercana ─────────

/// Coordenadas de las ciudades soportadas (para elegir la más cercana al
/// dispositivo). El backend solo acepta estos slugs.
const _cityCoords = <String, ({double lat, double lon})>{
  'brisbane': (lat: -27.4698, lon: 153.0251),
  'sydney': (lat: -33.8688, lon: 151.2093),
  'melbourne': (lat: -37.8136, lon: 144.9631),
  'bogota': (lat: 4.7110, lon: -74.0721),
  'medellin': (lat: 6.2442, lon: -75.5812),
  'cali': (lat: 3.4516, lon: -76.5320),
  'barranquilla': (lat: 10.9685, lon: -74.7813),
  'cartagena': (lat: 10.3910, lon: -75.4794),
  'bucaramanga': (lat: 7.1193, lon: -73.1227),
  'cucuta': (lat: 7.8939, lon: -72.5078),
  'pereira': (lat: 4.8133, lon: -75.6961),
  'santa-marta': (lat: 11.2408, lon: -74.1990),
  'manizales': (lat: 5.0703, lon: -75.5138),
};

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0; // km
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// Ciudad soportada más cercana a las coordenadas dadas.
WeatherCity nearestWeatherCity(double lat, double lon) {
  var best = australiaCities.first;
  var bestKm = double.infinity;
  for (final city in allWeatherCities) {
    final co = _cityCoords[city.slug];
    if (co == null) continue;
    final km = _haversineKm(lat, lon, co.lat, co.lon);
    if (km < bestKm) {
      bestKm = km;
      best = city;
    }
  }
  return best;
}

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

/// Detecta la ubicación una vez al arrancar y selecciona la ciudad soportada
/// más cercana. Si el permiso se niega o falla, mantiene la ciudad por defecto.
final cityAutoLocateProvider = FutureProvider<void>((ref) async {
  final pos = await ref.read(locationServiceProvider).currentPosition();
  if (pos == null) return;
  ref.read(selectedCityProvider.notifier)
      .select(nearestWeatherCity(pos.latitude, pos.longitude));
});

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
