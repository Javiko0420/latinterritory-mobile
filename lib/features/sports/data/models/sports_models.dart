import 'package:freezed_annotation/freezed_annotation.dart';

part 'sports_models.freezed.dart';
part 'sports_models.g.dart';

// Safe converters for nullable numbers that might arrive as int or double.
int? _toIntOrNull(dynamic v) => v == null ? null : (v as num).toInt();

@freezed
abstract class SportTeam with _$SportTeam {
  const factory SportTeam({
    @JsonKey(fromJson: _toIntOrNull) int? id,
    required String name,
  }) = _SportTeam;

  factory SportTeam.fromJson(Map<String, dynamic> json) =>
      _$SportTeamFromJson(json);
}

@freezed
abstract class FixtureGoals with _$FixtureGoals {
  const factory FixtureGoals({
    @JsonKey(fromJson: _toIntOrNull) int? home,
    @JsonKey(fromJson: _toIntOrNull) int? away,
  }) = _FixtureGoals;

  factory FixtureGoals.fromJson(Map<String, dynamic> json) =>
      _$FixtureGoalsFromJson(json);
}

@freezed
abstract class SimpleFixture with _$SimpleFixture {
  const factory SimpleFixture({
    required int id,
    required String dateIso,
    required String status,
    @JsonKey(fromJson: _toIntOrNull) int? elapsed,
    required SportTeam league,
    required SportTeam home,
    required SportTeam away,
    required FixtureGoals goals,
  }) = _SimpleFixture;

  factory SimpleFixture.fromJson(Map<String, dynamic> json) =>
      _$SimpleFixtureFromJson(json);
}

@freezed
abstract class SimpleStanding with _$SimpleStanding {
  const factory SimpleStanding({
    required int rank,
    required SportTeam team,
    required int points,
    required int played,
    required int won,
    required int draw,
    required int lost,
    required int goalsFor,
    required int goalsAgainst,
    required int goalsDiff,
    /// Present for group-stage competitions (Libertadores, UCL, etc.)
    String? group,
  }) = _SimpleStanding;

  factory SimpleStanding.fromJson(Map<String, dynamic> json) =>
      _$SimpleStandingFromJson(json);
}

@freezed
abstract class LeagueSummary with _$LeagueSummary {
  const factory LeagueSummary({
    required int id,
    required String name,
    required List<SimpleStanding> standings,
    required List<SimpleFixture> todayFixtures,
  }) = _LeagueSummary;

  factory LeagueSummary.fromJson(Map<String, dynamic> json) =>
      _$LeagueSummaryFromJson(json);
}

@freezed
abstract class SportsSummary with _$SportsSummary {
  const factory SportsSummary({
    required List<LeagueSummary> leagues,
  }) = _SportsSummary;

  factory SportsSummary.fromJson(Map<String, dynamic> json) =>
      _$SportsSummaryFromJson(json);
}

@freezed
abstract class LeagueDetail with _$LeagueDetail {
  const factory LeagueDetail({
    required SportTeam league,
    /// Season year as integer (e.g. 2026). Nullable for error-tolerant parsing.
    @JsonKey(fromJson: _toIntOrNull) int? season,
    required List<SimpleFixture> results,
    required List<SimpleStanding> standings,
  }) = _LeagueDetail;

  factory LeagueDetail.fromJson(Map<String, dynamic> json) =>
      _$LeagueDetailFromJson(json);
}
