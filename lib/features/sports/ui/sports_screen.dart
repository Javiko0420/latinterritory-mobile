import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/sports/data/models/sports_models.dart';
import 'package:latinterritory/features/sports/providers/sports_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class SportsScreen extends ConsumerWidget {
  const SportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedLeagueIndexProvider);
    final summaryAsync = ref.watch(sportsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deportes')),
      body: Column(
        children: [
          // ── League selector ───────────────────────────
          _LeagueSelector(selectedIndex: selectedIndex),

          // ── Content ───────────────────────────────────
          Expanded(
            child: summaryAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                onRetry: () => ref.invalidate(sportsSummaryProvider),
              ),
              data: (summary) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(sportsSummaryProvider);
                  try {
                    await ref.read(sportsSummaryProvider.future);
                  } catch (_) {}
                },
                child: _SportsContent(
                  summary: summary,
                  selectedIndex: selectedIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── League selector chips ─────────────────────────────────

class _LeagueSelector extends ConsumerWidget {
  const _LeagueSelector({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.sm,
          ),
          itemCount: leagueOptions.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.xs),
          itemBuilder: (context, i) {
            final opt = leagueOptions[i];
            final isSelected = i == selectedIndex;
            return FilterChip(
              label: Text(
                '${opt.flag} ${opt.label}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(selectedLeagueIndexProvider.notifier).select(i),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              visualDensity: VisualDensity.compact,
            );
          },
        ),
      ),
    );
  }
}

// ── Main scrollable content ───────────────────────────────

class _SportsContent extends StatelessWidget {
  const _SportsContent({
    required this.summary,
    required this.selectedIndex,
  });

  final SportsSummary summary;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final league = selectedIndex < summary.leagues.length
        ? summary.leagues[selectedIndex]
        : null;

    final fixtures = league?.todayFixtures ?? [];
    final standings = league?.standings ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Today's Fixtures ──────────────────────────
          Row(
            children: [
              const Icon(Icons.sports_soccer,
                  size: AppDimensions.iconMd, color: AppColors.primary),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Partidos de Hoy',
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          if (fixtures.isEmpty)
            const _EmptyState(
              icon: Icons.sports_soccer_outlined,
              message: 'Sin partidos hoy',
            )
          else
            ...fixtures.map((f) => _FixtureCard(fixture: f)),

          const SizedBox(height: AppDimensions.lg),

          // ── Standings ─────────────────────────────────
          Row(
            children: [
              const Icon(Icons.leaderboard,
                  size: AppDimensions.iconMd, color: AppColors.secondary),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Tabla de Posiciones',
                style: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          if (standings.isEmpty)
            const _EmptyState(
              icon: Icons.table_chart_outlined,
              message: 'Sin tabla disponible',
            )
          else
            _StandingsTable(standings: standings),

          const SizedBox(height: AppDimensions.lg),

          if (league != null)
            Center(
              child: Text(
                league.name,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fixture card ──────────────────────────────────────────

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.fixture});
  final SimpleFixture fixture;

  bool get _isLive {
    final s = fixture.status;
    return s == '1H' ||
        s == '2H' ||
        s == 'HT' ||
        s == 'ET' ||
        s == 'BT' ||
        s == 'P' ||
        s == 'LIVE';
  }

  bool get _isFinished {
    final s = fixture.status;
    return s == 'Match Finished' || s == 'FT' || s == 'AET' || s == 'PEN';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(fixture.dateIso)?.toLocal();
    final timeStr =
        date != null ? DateFormat('HH:mm').format(date) : '--:--';

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm + 2,
        ),
        child: Row(
          children: [
            // Home team
            Expanded(
              child: Text(
                fixture.home.name,
                textAlign: TextAlign.right,
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: AppDimensions.sm),

            // Score / time
            Container(
              width: 80,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFinished || _isLive)
                    Text(
                      '${fixture.goals.home ?? 0} – ${fixture.goals.away ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isLive ? AppColors.error : null,
                      ),
                    )
                  else
                    Text(
                      timeStr,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  if (_isLive)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        fixture.elapsed != null
                            ? "${fixture.elapsed}'"
                            : 'EN VIVO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_isFinished)
                    Text(
                      'Final',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.sm),

            // Away team
            Expanded(
              child: Text(
                fixture.away.name,
                textAlign: TextAlign.left,
                style: context.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Standings table ───────────────────────────────────────

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.standings});
  final List<SimpleStanding> standings;

  @override
  Widget build(BuildContext context) {
    final headerStyle = context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    );
    final cellStyle = context.textTheme.bodySmall;
    final ptsStyle = context.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return Card(
      elevation: AppDimensions.cardElevation,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 44,
          columnSpacing: 10,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn(label: Text('#', style: headerStyle)),
            DataColumn(label: Text('Equipo', style: headerStyle)),
            DataColumn(label: Text('PJ', style: headerStyle)),
            DataColumn(label: Text('G', style: headerStyle)),
            DataColumn(label: Text('E', style: headerStyle)),
            DataColumn(label: Text('P', style: headerStyle)),
            DataColumn(label: Text('GF', style: headerStyle)),
            DataColumn(label: Text('GC', style: headerStyle)),
            DataColumn(label: Text('DG', style: headerStyle)),
            DataColumn(label: Text('Pts', style: headerStyle)),
          ],
          rows: standings.map((s) {
            final dg = s.goalsDiff > 0 ? '+${s.goalsDiff}' : '${s.goalsDiff}';
            return DataRow(
              cells: [
                DataCell(Text('${s.rank}', style: cellStyle)),
                DataCell(
                  SizedBox(
                    width: 130,
                    child: Text(
                      s.team.name,
                      style: cellStyle?.copyWith(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text('${s.played}', style: cellStyle)),
                DataCell(Text('${s.won}', style: cellStyle)),
                DataCell(Text('${s.draw}', style: cellStyle)),
                DataCell(Text('${s.lost}', style: cellStyle)),
                DataCell(Text('${s.goalsFor}', style: cellStyle)),
                DataCell(Text('${s.goalsAgainst}', style: cellStyle)),
                DataCell(Text(dg, style: cellStyle)),
                DataCell(Text('${s.points}', style: ptsStyle)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppDimensions.iconXl, color: AppColors.textTertiary),
          const SizedBox(height: AppDimensions.sm),
          Text(
            message,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: AppDimensions.iconXl, color: AppColors.error),
          const SizedBox(height: AppDimensions.md),
          Text(
            'No se pudieron cargar los deportes',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
