import 'package:dio/dio.dart';
import 'package:latinterritory/features/worldcup_2026/models/rounds_response.dart';
import 'package:latinterritory/features/worldcup_2026/models/standings.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_config.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';

/// Paths del backend (relativos; la base URL la pone el Dio configurado por
/// entorno). Aislados aquí para borrar la feature sin tocar `ApiEndpoints`.
class _WcPaths {
  _WcPaths._();
  static const config = '/api/sports/worldcup/config';
  static const live = '/api/sports/worldcup/live';
  static const standings = '/api/sports/worldcup/standings';
  static const rounds = '/api/sports/worldcup/rounds';
  static const fixtures = '/api/sports/worldcup/fixtures';
}

/// Cliente del Mundial 2026. Envuelve las llamadas HTTP a nuestro backend.
/// Los métodos (salvo [fetchConfig]) relanzan el error de Dio para que la capa
/// de estado lo capture con `AsyncValue.guard` y la UI lo muestre con
/// `resolveApiErrorMessage`.
class WorldCupApi {
  WorldCupApi(this._dio);

  final Dio _dio;

  Map<String, dynamic> _obj(Response<dynamic> res) {
    final data = res.data;
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  /// Feature flag remoto. Fail-safe: ante cualquier error/timeout → null.
  Future<WorldCupConfig?> fetchConfig() async {
    try {
      final res = await _dio.get<dynamic>(_WcPaths.config);
      return WorldCupConfig.fromJson(_obj(res));
    } catch (_) {
      return null;
    }
  }

  Future<WorldCupLive> fetchLive() async {
    final res = await _dio.get<dynamic>(_WcPaths.live);
    return WorldCupLive.fromJson(_obj(res));
  }

  Future<StandingsResponse> fetchStandings() async {
    final res = await _dio.get<dynamic>(_WcPaths.standings);
    return StandingsResponse.fromJson(_obj(res));
  }

  Future<RoundsResponse> fetchRounds() async {
    final res = await _dio.get<dynamic>(_WcPaths.rounds);
    return RoundsResponse.fromJson(_obj(res));
  }

  Future<List<WorldCupFixture>> fetchFixturesByRound(String round) async {
    final res = await _dio.get<dynamic>(
      _WcPaths.fixtures,
      queryParameters: {'round': round},
    );
    return WorldCupFixture.listFrom(_obj(res)['fixtures']);
  }
}
