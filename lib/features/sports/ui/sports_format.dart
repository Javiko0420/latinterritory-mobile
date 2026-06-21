import 'package:latinterritory/features/sports/data/models/sports_models.dart';

/// Código de 3 letras a partir del nombre del equipo (no hay code en el modelo).
String sportTeamCode(String name) {
  final cleaned = name.trim();
  if (cleaned.isEmpty) return '?';
  final letters = cleaned.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚÑáéíóúñ]'), '');
  final base = letters.isEmpty ? cleaned : letters;
  return base.substring(0, base.length < 3 ? base.length : 3).toUpperCase();
}

/// True si el partido está en juego (estados de api-football en vivo).
bool isLiveStatus(String status) {
  const live = {'1H', '2H', 'HT', 'ET', 'BT', 'P', 'LIVE', 'INT'};
  return live.contains(status.toUpperCase());
}

/// Elige el partido a destacar: primero uno en vivo; si no, el primero de hoy.
SimpleFixture? featuredFixture(SportsSummary summary) {
  final all = summary.leagues.expand((l) => l.todayFixtures).toList();
  if (all.isEmpty) return null;
  for (final f in all) {
    if (isLiveStatus(f.status)) return f;
  }
  return all.first;
}

/// Traduce la ronda de la API al español (igual que la web).
/// "Group Stage - N" → "Fase de grupos · J{N}"; rondas finales mapeadas;
/// cualquier otro valor se devuelve sin cambios.
String roundLabel(String? round) {
  if (round == null || round.trim().isEmpty) return '';
  final r = round.trim();
  if (r.startsWith('Group Stage')) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(r);
    return m != null ? 'Fase de grupos · J${m.group(1)}' : 'Fase de grupos';
  }
  switch (r) {
    case 'Round of 16':
      return 'Octavos de final';
    case 'Quarter-finals':
      return 'Cuartos de final';
    case 'Semi-finals':
      return 'Semifinales';
    case 'Final':
      return 'Final';
    case '3rd Place Final':
      return 'Tercer puesto';
    default:
      return r;
  }
}
