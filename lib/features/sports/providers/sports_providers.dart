import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/sports/data/models/sports_models.dart';
import 'package:latinterritory/features/sports/data/sports_repository.dart';

// ── League options ────────────────────────────────────────

class LeagueOption {
  const LeagueOption(this.slug, this.label, this.flag);
  final String slug;
  final String label;
  final String flag;
}

const leagueOptions = [
  // Latinoamérica
  LeagueOption('colombia',     'BetPlay',       '🇨🇴'),
  LeagueOption('argentina',    'Argentina',     '🇦🇷'),
  LeagueOption('libertadores', 'Libertadores',  '🏆'),
  // Europa — Top 5
  LeagueOption('spain',        'La Liga',       '🇪🇸'),
  LeagueOption('england',      'Premier',       '🇬🇧'),
  LeagueOption('italy',        'Serie A',       '🇮🇹'),
  LeagueOption('germany',      'Bundesliga',    '🇩🇪'),
  LeagueOption('france',       'Ligue 1',       '🇫🇷'),
  // UEFA
  LeagueOption('ucl',          'Champions',     '⭐'),
];

// ── Repository ────────────────────────────────────────────

final sportsRepositoryProvider = Provider<SportsRepository>((ref) {
  return SportsRepository(dio: ref.watch(dioProvider));
});

// ── Selected league index (position in leagueOptions) ─────

final selectedLeagueIndexProvider =
    NotifierProvider<SelectedLeagueNotifier, int>(
  SelectedLeagueNotifier.new,
);

class SelectedLeagueNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

// ── Sports summary (all leagues + today fixtures) ─────────

final sportsSummaryProvider = FutureProvider<SportsSummary>((ref) async {
  return ref.watch(sportsRepositoryProvider).getSummary();
});

// ── League detail (results + standings for selected league) ─

final leagueDetailProvider = FutureProvider<LeagueDetail>((ref) async {
  final index = ref.watch(selectedLeagueIndexProvider);
  final slug = leagueOptions[index].slug;
  return ref.watch(sportsRepositoryProvider).getLeagueDetail(league: slug);
});
