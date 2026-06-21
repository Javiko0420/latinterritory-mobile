import 'package:flutter_test/flutter_test.dart';
import 'package:latinterritory/features/worldcup_2026/models/standings.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_config.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';

void main() {
  group('phaseOf', () {
    test('not started', () {
      expect(phaseOf('NS'), WcPhase.notStarted);
      expect(phaseOf('TBD'), WcPhase.notStarted);
    });
    test('live', () {
      for (final s in ['1H', 'HT', '2H', 'ET', 'BT', 'P', 'SUSP', 'INT', 'LIVE']) {
        expect(phaseOf(s), WcPhase.live, reason: s);
      }
    });
    test('finished', () {
      for (final s in ['FT', 'AET', 'PEN']) {
        expect(phaseOf(s), WcPhase.finished, reason: s);
      }
    });
    test('other / unknown / null', () {
      expect(phaseOf('PST'), WcPhase.other);
      expect(phaseOf('CANC'), WcPhase.other);
      expect(phaseOf(null), WcPhase.other);
    });
  });

  group('WorldCupFixture.fromJson', () {
    test('tolera objeto vacío (nulls y campos faltantes)', () {
      final f = WorldCupFixture.fromJson(const {});
      expect(f.id, 0);
      expect(f.date, isNull);
      expect(f.goals.home, isNull);
      expect(f.goals.away, isNull);
      expect(f.status.short, isNull);
      expect(f.home.name, '—');
      expect(f.away.name, '—');
    });

    test('parsea fixture completo y convierte la fecha', () {
      final f = WorldCupFixture.fromJson({
        'id': 123,
        'date': '2026-06-21T18:00:00+00:00',
        'timestamp': 1781000000,
        'status': {'long': 'Second Half', 'short': '2H', 'elapsed': 67},
        'round': 'Round of 16',
        'venue': {'id': 1, 'name': 'Estadio', 'city': 'Bogotá'},
        'teams': {
          'home': {'id': 8, 'name': 'Colombia', 'logo': 'h.png', 'winner': true},
          'away': {'id': 6, 'name': 'Argentina', 'logo': 'a.png', 'winner': false},
        },
        'goals': {'home': 2, 'away': 1},
      });
      expect(f.id, 123);
      expect(f.phase, WcPhase.live);
      expect(f.status.elapsed, 67);
      expect(f.round, 'Round of 16');
      expect(f.home.name, 'Colombia');
      expect(f.home.winner, true);
      expect(f.goals.home, 2);
      expect(f.date, isNotNull);
    });

    test('acepta números como double (id/goles)', () {
      final f = WorldCupFixture.fromJson({
        'id': 9.0,
        'goals': {'home': 2.0, 'away': 0.0},
      });
      expect(f.id, 9);
      expect(f.goals.home, 2);
    });
  });

  test('WorldCupLive.fromJson con fixtures vacíos', () {
    final live = WorldCupLive.fromJson(const {'fixtures': [], 'hasLive': false});
    expect(live.fixtures, isEmpty);
    expect(live.hasLive, false);
  });

  test('StandingsResponse con groups vacío / ausente', () {
    expect(StandingsResponse.fromJson(const {}).groups, isEmpty);
    expect(StandingsResponse.fromJson(const {'groups': []}).groups, isEmpty);
  });

  test('StandingRow.fromJson', () {
    final r = StandingRow.fromJson({
      'rank': 1,
      'team': {'id': 8, 'name': 'Colombia', 'logo': 'l.png'},
      'points': 9,
      'goalsDiff': 5,
      'played': 3,
      'win': 3,
      'draw': 0,
      'lose': 0,
      'goalsFor': 7,
      'goalsAgainst': 2,
      'form': 'WWW',
    });
    expect(r.rank, 1);
    expect(r.team.name, 'Colombia');
    expect(r.points, 9);
    expect(r.goalsDiff, 5);
    expect(r.form, 'WWW');
  });

  test('WorldCupConfig.fromJson', () {
    final c = WorldCupConfig.fromJson({'enabled': true, 'sunsetAt': '2026-07-20T00:00:00-05:00'});
    expect(c.enabled, true);
    expect(c.sunsetAt, isNotNull);
    expect(WorldCupConfig.fromJson(const {}).enabled, false);
  });
}
