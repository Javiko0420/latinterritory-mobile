/// Localiza el nombre de una ronda de la API al español. Copia local del feature
/// para no acoplar a `features/sports` (borrado limpio).
String wcRoundLabel(String round) {
  if (round.startsWith('Group Stage')) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(round);
    return m != null ? 'Fase de grupos · J${m.group(1)}' : 'Fase de grupos';
  }
  switch (round) {
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
      return round;
  }
}
