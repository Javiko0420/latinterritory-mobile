import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/radio/data/models/radio_models.dart';
import 'package:latinterritory/features/radio/data/radio_repository.dart';
import 'package:latinterritory/features/radio/services/radio_player_service.dart';

// ── Repository ────────────────────────────────────────────

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository(dio: ref.watch(dioProvider));
});

// ── País seleccionado ─────────────────────────────────────

const _defaultCountry = 'CO';

class SelectedCountryNotifier extends Notifier<String> {
  @override
  String build() => _defaultCountry;

  void select(String countryCode) => state = countryCode;
}

final selectedCountryProvider =
    NotifierProvider<SelectedCountryNotifier, String>(
  SelectedCountryNotifier.new,
);

// ── Query de búsqueda ─────────────────────────────────────

class RadioSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

final radioSearchQueryProvider =
    NotifierProvider<RadioSearchQueryNotifier, String>(
  RadioSearchQueryNotifier.new,
);

// ── Estaciones populares ──────────────────────────────────

final popularStationsProvider =
    FutureProvider.autoDispose<List<RadioStation>>((ref) async {
  final repo = ref.watch(radioRepositoryProvider);
  final country = ref.watch(selectedCountryProvider);
  return repo.getPopularStations(countryCode: country);
});

// ── Búsqueda de estaciones ────────────────────────────────

final searchStationsProvider =
    FutureProvider.autoDispose<List<RadioStation>>((ref) async {
  final query = ref.watch(radioSearchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repo = ref.watch(radioRepositoryProvider);
  final country = ref.watch(selectedCountryProvider);
  return repo.searchStations(query: query, countryCode: country);
});

// ── Estación actual en reproducción ──────────────────────

class CurrentStationNotifier extends Notifier<RadioStation?> {
  @override
  RadioStation? build() => null;

  void set(RadioStation station) => state = station;

  void clear() => state = null;
}

final currentStationProvider =
    NotifierProvider<CurrentStationNotifier, RadioStation?>(
  CurrentStationNotifier.new,
);

// ── Estado de reproducción ────────────────────────────────

class IsPlayingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool playing) => state = playing;
}

final isPlayingProvider =
    NotifierProvider<IsPlayingNotifier, bool>(IsPlayingNotifier.new);

// ── Player service (acceso al singleton desde Riverpod) ───

final radioPlayerServiceProvider = Provider<RadioPlayerService>((ref) {
  return RadioPlayerService.instance;
});
