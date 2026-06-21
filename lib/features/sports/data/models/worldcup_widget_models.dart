import 'package:freezed_annotation/freezed_annotation.dart';

part 'worldcup_widget_models.freezed.dart';
part 'worldcup_widget_models.g.dart';

// Conversores defensivos: la API puede mandar números como int o double, y
// muchos campos pueden venir null (goles, elapsed, winner, venue…).
int _toInt(dynamic v) => (v as num).toInt();
int? _toIntOrNull(dynamic v) => v == null ? null : (v as num).toInt();

/// Respuesta del widget del Mundial: GET /api/sports/worldcup/widget
@freezed
abstract class WorldcupWidget with _$WorldcupWidget {
  const WorldcupWidget._();

  const factory WorldcupWidget({
    required String mode, // "live" | "last"
    WidgetFixture? fixture,
    String? cachedAt,
  }) = _WorldcupWidget;

  /// Partido en juego.
  bool get isLive => mode == 'live';

  /// El contrato solo admite "live" o "last".
  bool get isValidMode => mode == 'live' || mode == 'last';

  factory WorldcupWidget.fromJson(Map<String, dynamic> json) =>
      _$WorldcupWidgetFromJson(json);
}

@freezed
abstract class WidgetFixture with _$WidgetFixture {
  const factory WidgetFixture({
    @JsonKey(fromJson: _toInt) required int id,
    required String date,
    @JsonKey(fromJson: _toIntOrNull) int? timestamp,
    required WidgetStatus status,
    String? round,
    WidgetVenue? venue,
    required WidgetTeams teams,
    required WidgetGoals goals,
  }) = _WidgetFixture;

  factory WidgetFixture.fromJson(Map<String, dynamic> json) =>
      _$WidgetFixtureFromJson(json);
}

@freezed
abstract class WidgetTeams with _$WidgetTeams {
  const factory WidgetTeams({
    required WidgetTeam home,
    required WidgetTeam away,
  }) = _WidgetTeams;

  factory WidgetTeams.fromJson(Map<String, dynamic> json) =>
      _$WidgetTeamsFromJson(json);
}

@freezed
abstract class WidgetTeam with _$WidgetTeam {
  const factory WidgetTeam({
    @JsonKey(fromJson: _toIntOrNull) int? id,
    required String name,
    String? logo,
    bool? winner,
  }) = _WidgetTeam;

  factory WidgetTeam.fromJson(Map<String, dynamic> json) =>
      _$WidgetTeamFromJson(json);
}

@freezed
abstract class WidgetStatus with _$WidgetStatus {
  const factory WidgetStatus({
    String? long,
    String? short,
    @JsonKey(fromJson: _toIntOrNull) int? elapsed,
  }) = _WidgetStatus;

  factory WidgetStatus.fromJson(Map<String, dynamic> json) =>
      _$WidgetStatusFromJson(json);
}

@freezed
abstract class WidgetGoals with _$WidgetGoals {
  const factory WidgetGoals({
    @JsonKey(fromJson: _toIntOrNull) int? home,
    @JsonKey(fromJson: _toIntOrNull) int? away,
  }) = _WidgetGoals;

  factory WidgetGoals.fromJson(Map<String, dynamic> json) =>
      _$WidgetGoalsFromJson(json);
}

@freezed
abstract class WidgetVenue with _$WidgetVenue {
  const factory WidgetVenue({
    @JsonKey(fromJson: _toIntOrNull) int? id,
    String? name,
    String? city,
  }) = _WidgetVenue;

  factory WidgetVenue.fromJson(Map<String, dynamic> json) =>
      _$WidgetVenueFromJson(json);
}
