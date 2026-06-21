import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/worldcup_2026/data/world_cup_api.dart';
import 'package:latinterritory/features/worldcup_2026/models/rounds_response.dart';
import 'package:latinterritory/features/worldcup_2026/models/standings.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_config.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';

/// Apagado automático local (fallback). 00:00 hora local del 20-jul-2026:
/// visible durante toda la final del 19-jul.
final DateTime kWorldCupSunsetDate = DateTime(2026, 7, 20);

/// "Ahora" inyectable (override en tests).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ── API ───────────────────────────────────────────────────

final worldCupApiProvider = Provider<WorldCupApi>((ref) {
  return WorldCupApi(ref.watch(dioProvider));
});

// ── Visibilidad (feature flag remoto + fail-safe local) ───

final worldCupConfigProvider =
    FutureProvider.autoDispose<WorldCupConfig?>((ref) async {
  return ref.watch(worldCupApiProvider).fetchConfig();
});

/// Resuelve si la campaña debe mostrarse. Prioriza el config del servidor;
/// si no hay config (loading/error/null) cae al date-guard local.
final worldCupVisibleProvider = Provider.autoDispose<bool>((ref) {
  final now = ref.watch(clockProvider)();
  final cfg = ref.watch(worldCupConfigProvider).asData?.value;
  if (cfg != null) {
    final sunset = cfg.sunsetAt ?? kWorldCupSunsetDate;
    return cfg.enabled && now.isBefore(sunset);
  }
  return now.isBefore(kWorldCupSunsetDate);
});

// ── En vivo (polling de intervalo variable) ───────────────

const _liveInterval = Duration(seconds: 15);
const _idleInterval = Duration(seconds: 60);

class WorldCupLiveNotifier extends AsyncNotifier<WorldCupLive> {
  Timer? _timer;
  bool _paused = false;
  bool _disposed = false;

  @override
  Future<WorldCupLive> build() async {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    final live = await ref.read(worldCupApiProvider).fetchLive();
    _schedule(live.hasLive);
    return live;
  }

  void _schedule(bool hasLive) {
    _timer?.cancel();
    if (_paused) return;
    _timer = Timer(hasLive ? _liveInterval : _idleInterval, _tick);
  }

  /// Refresh silencioso: no vuelve a "Cargando…" y conserva datos si falla.
  Future<void> _tick() async {
    final next = await AsyncValue.guard(() => ref.read(worldCupApiProvider).fetchLive());
    if (_disposed) return; // el provider pudo disponerse durante el await
    if (next.hasError && state.hasValue) {
      _schedule(state.value!.hasLive);
      return;
    }
    state = next;
    _schedule(next.value?.hasLive ?? false);
  }

  /// Pausa el polling (app en background).
  void pause() {
    _paused = true;
    _timer?.cancel();
  }

  /// Reanuda el polling (app en foreground) con un refresh inmediato.
  void resume() {
    if (!_paused) return;
    _paused = false;
    _tick();
  }
}

final worldCupLiveProvider =
    AsyncNotifierProvider.autoDispose<WorldCupLiveNotifier, WorldCupLive>(
  WorldCupLiveNotifier.new,
);

// ── Grupos ────────────────────────────────────────────────

final worldCupStandingsProvider =
    FutureProvider.autoDispose<StandingsResponse>((ref) async {
  return ref.watch(worldCupApiProvider).fetchStandings();
});

// ── Eliminatorias ─────────────────────────────────────────

final worldCupRoundsProvider =
    FutureProvider.autoDispose<RoundsResponse>((ref) async {
  return ref.watch(worldCupApiProvider).fetchRounds();
});

/// Fixtures de una ronda concreta (paralelizable por ronda).
final worldCupRoundFixturesProvider = FutureProvider.autoDispose
    .family<List<WorldCupFixture>, String>((ref, round) async {
  return ref.watch(worldCupApiProvider).fetchFixturesByRound(round);
});
