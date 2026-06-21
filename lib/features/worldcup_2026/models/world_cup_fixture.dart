import 'package:flutter/foundation.dart';

int? _asInt(dynamic v) => v == null ? null : (v as num).toInt();

/// Fase del partido derivada de `status.short`.
enum WcPhase { notStarted, live, finished, other }

WcPhase phaseOf(String? short) {
  switch (short) {
    case 'NS':
    case 'TBD':
      return WcPhase.notStarted;
    case '1H':
    case 'HT':
    case '2H':
    case 'ET':
    case 'BT':
    case 'P':
    case 'SUSP':
    case 'INT':
    case 'LIVE':
      return WcPhase.live;
    case 'FT':
    case 'AET':
    case 'PEN':
      return WcPhase.finished;
    default:
      return WcPhase.other;
  }
}

@immutable
class WorldCupStatus {
  const WorldCupStatus({this.long, this.short, this.elapsed});

  final String? long;
  final String? short;
  final int? elapsed;

  WcPhase get phase => phaseOf(short);

  factory WorldCupStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WorldCupStatus();
    return WorldCupStatus(
      long: json['long'] as String?,
      short: json['short'] as String?,
      elapsed: _asInt(json['elapsed']),
    );
  }
}

@immutable
class WorldCupTeam {
  const WorldCupTeam({this.id, required this.name, this.logo, this.winner});

  final int? id;
  final String name;
  final String? logo;
  final bool? winner;

  factory WorldCupTeam.fromJson(Map<String, dynamic>? json) {
    return WorldCupTeam(
      id: _asInt(json?['id']),
      name: (json?['name'] as String?) ?? '—',
      logo: json?['logo'] as String?,
      winner: json?['winner'] as bool?,
    );
  }
}

@immutable
class WorldCupGoals {
  const WorldCupGoals({this.home, this.away});

  final int? home;
  final int? away;

  factory WorldCupGoals.fromJson(Map<String, dynamic>? json) {
    return WorldCupGoals(home: _asInt(json?['home']), away: _asInt(json?['away']));
  }
}

@immutable
class WorldCupVenue {
  const WorldCupVenue({this.id, this.name, this.city});

  final int? id;
  final String? name;
  final String? city;

  factory WorldCupVenue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WorldCupVenue();
    return WorldCupVenue(
      id: _asInt(json['id']),
      name: json['name'] as String?,
      city: json['city'] as String?,
    );
  }
}

@immutable
class WorldCupFixture {
  const WorldCupFixture({
    required this.id,
    this.date,
    this.timestamp,
    required this.status,
    this.round,
    this.venue,
    required this.home,
    required this.away,
    required this.goals,
  });

  final int id;
  final DateTime? date; // hora local (ya convertida)
  final int? timestamp;
  final WorldCupStatus status;
  final String? round;
  final WorldCupVenue? venue;
  final WorldCupTeam home;
  final WorldCupTeam away;
  final WorldCupGoals goals;

  WcPhase get phase => status.phase;

  factory WorldCupFixture.fromJson(Map<String, dynamic> json) {
    final teams = (json['teams'] as Map<String, dynamic>?) ?? const {};
    final rawDate = json['date'] as String?;
    return WorldCupFixture(
      id: _asInt(json['id']) ?? 0,
      date: rawDate != null ? DateTime.tryParse(rawDate)?.toLocal() : null,
      timestamp: _asInt(json['timestamp']),
      status: WorldCupStatus.fromJson(json['status'] as Map<String, dynamic>?),
      round: json['round'] as String?,
      venue: WorldCupVenue.fromJson(json['venue'] as Map<String, dynamic>?),
      home: WorldCupTeam.fromJson(teams['home'] as Map<String, dynamic>?),
      away: WorldCupTeam.fromJson(teams['away'] as Map<String, dynamic>?),
      goals: WorldCupGoals.fromJson(json['goals'] as Map<String, dynamic>?),
    );
  }

  static List<WorldCupFixture> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(WorldCupFixture.fromJson)
        .toList();
  }
}

/// Respuesta de `/live`.
@immutable
class WorldCupLive {
  const WorldCupLive({required this.fixtures, required this.hasLive});

  final List<WorldCupFixture> fixtures;
  final bool hasLive;

  factory WorldCupLive.fromJson(Map<String, dynamic> json) {
    return WorldCupLive(
      fixtures: WorldCupFixture.listFrom(json['fixtures']),
      hasLive: json['hasLive'] as bool? ?? false,
    );
  }
}
