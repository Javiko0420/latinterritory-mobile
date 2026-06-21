import 'package:flutter/foundation.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';

int _asInt0(dynamic v) {
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

@immutable
class StandingRow {
  const StandingRow({
    required this.rank,
    required this.team,
    required this.points,
    required this.goalsDiff,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
    this.form,
  });

  final int rank;
  final WorldCupTeam team;
  final int points;
  final int goalsDiff;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int goalsFor;
  final int goalsAgainst;
  final String? form;

  factory StandingRow.fromJson(Map<String, dynamic> json) {
    return StandingRow(
      rank: _asInt0(json['rank']),
      team: WorldCupTeam.fromJson(json['team'] as Map<String, dynamic>?),
      points: _asInt0(json['points']),
      goalsDiff: _asInt0(json['goalsDiff']),
      played: _asInt0(json['played']),
      win: _asInt0(json['win']),
      draw: _asInt0(json['draw']),
      lose: _asInt0(json['lose']),
      goalsFor: _asInt0(json['goalsFor']),
      goalsAgainst: _asInt0(json['goalsAgainst']),
      form: json['form'] as String?,
    );
  }
}

@immutable
class GroupStandings {
  const GroupStandings({required this.group, required this.standings});

  final String group;
  final List<StandingRow> standings;

  factory GroupStandings.fromJson(Map<String, dynamic> json) {
    final raw = json['standings'];
    return GroupStandings(
      group: (json['group'] as String?) ?? '—',
      standings: raw is List
          ? raw.whereType<Map<String, dynamic>>().map(StandingRow.fromJson).toList()
          : const [],
    );
  }
}

@immutable
class StandingsResponse {
  const StandingsResponse({required this.groups});

  final List<GroupStandings> groups;

  factory StandingsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['groups'];
    return StandingsResponse(
      groups: raw is List
          ? raw.whereType<Map<String, dynamic>>().map(GroupStandings.fromJson).toList()
          : const [],
    );
  }
}
