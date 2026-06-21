import 'package:flutter/foundation.dart';

@immutable
class RoundsResponse {
  const RoundsResponse({required this.rounds, this.current});

  final List<String> rounds;
  final String? current;

  /// Rondas de eliminatorias (excluye fase de grupos), en orden de la API.
  List<String> get knockoutRounds =>
      rounds.where((r) => !r.startsWith('Group Stage')).toList();

  factory RoundsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['rounds'];
    return RoundsResponse(
      rounds: raw is List ? raw.whereType<String>().toList() : const [],
      current: json['current'] as String?,
    );
  }
}
