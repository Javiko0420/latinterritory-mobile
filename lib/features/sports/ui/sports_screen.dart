import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/sports/data/models/sports_models.dart';
import 'package:latinterritory/features/sports/providers/sports_providers.dart';
import 'package:latinterritory/features/sports/ui/sports_format.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Pantalla de Deportes (design system). Acento: coral.
/// Reusa `leagueDetailProvider` + `selectedLeagueIndexProvider`. No cambia datos.
class SportsScreen extends ConsumerWidget {
  const SportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final selectedIndex = ref.watch(selectedLeagueIndexProvider);
    final async = ref.watch(leagueDetailProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: RefreshIndicator(
            color: c.gold,
            onRefresh: () async => ref.invalidate(leagueDetailProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LTSpace.screenH, LTSpace.x4, LTSpace.screenH, LTSpace.screenBottom,
              ),
              children: [
                _Header(eyebrow: 'RESULTADOS EN VIVO', title: 'Deportes', accent: c.coral),
                const SizedBox(height: LTSpace.x4),
                _LeagueSelector(selectedIndex: selectedIndex),
                const SizedBox(height: LTSpace.x4),
                async.when(
                  loading: () => const _Loader(),
                  error: (_, __) => _ErrorBox(onRetry: () => ref.invalidate(leagueDetailProvider)),
                  data: (detail) => _SportsBody(detail: detail),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SportsBody extends StatelessWidget {
  const _SportsBody({required this.detail});

  final LeagueDetail detail;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final now = DateTime.now();
    final todays = detail.results.where((f) {
      final d = DateTime.tryParse(f.dateIso)?.toLocal();
      return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
    final hasToday = todays.isNotEmpty;
    final fixtures = hasToday ? todays : detail.results.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PARTIDOS', style: LTType.eyebrow(c.coral)),
        const SizedBox(height: 5),
        Text(hasToday ? 'Hoy' : 'Últimos resultados', style: LTType.title(c.ink)),
        const SizedBox(height: 12),
        if (fixtures.isEmpty)
          _EmptyBox(message: 'Sin partidos disponibles')
        else
          for (final f in fixtures) ...[
            _MatchCard(fixture: f),
            const SizedBox(height: 11),
          ],
        const SizedBox(height: LTSpace.x4),
        Text('CLASIFICACIÓN', style: LTType.eyebrow(c.coral)),
        const SizedBox(height: 5),
        Text('Tabla de posiciones', style: LTType.title(c.ink)),
        const SizedBox(height: 12),
        if (detail.standings.isEmpty)
          _EmptyBox(message: 'Sin tabla disponible')
        else
          _StandingsCard(standings: detail.standings),
        const SizedBox(height: LTSpace.x4),
        Center(
          child: Text(
            detail.season != null ? '${detail.league.name} · ${detail.season}' : detail.league.name,
            style: LTType.caption(c.ink3, size: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Match card ────────────────────────────────────────────

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.fixture});

  final SimpleFixture fixture;

  static const _finished = {'FT', 'AET', 'PEN', 'Match Finished'};

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final live = isLiveStatus(fixture.status);
    final finished = _finished.contains(fixture.status);
    final showScore = live || finished;

    String statusText;
    Color statusColor;
    if (live) {
      statusText = fixture.elapsed != null ? "EN VIVO · ${fixture.elapsed}'" : 'EN VIVO';
      statusColor = c.coral;
    } else if (finished) {
      statusText = 'FINAL';
      statusColor = c.ink3;
    } else {
      final d = DateTime.tryParse(fixture.dateIso)?.toLocal();
      statusText = d != null ? DateFormat("d MMM · HH:mm", 'es').format(d) : fixture.status;
      statusColor = c.ink3;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (live) ...[
                Container(width: 6, height: 6, decoration: BoxDecoration(color: c.coral, shape: BoxShape.circle)),
                const SizedBox(width: 6),
              ],
              Text(
                statusText,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TeamCol(name: fixture.home.name)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: showScore
                    ? Row(
                        children: [
                          _score(c, fixture.goals.home),
                          Text(' : ', style: GoogleFonts.hankenGrotesk(fontSize: 16, color: c.ink3, fontWeight: FontWeight.w700)),
                          _score(c, fixture.goals.away),
                        ],
                      )
                    : Text('vs', style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink3)),
              ),
              Expanded(child: _TeamCol(name: fixture.away.name)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _score(LTColors c, int? g) => Text(
        '${g ?? 0}',
        style: GoogleFonts.hankenGrotesk(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.3, color: c.ink),
      );
}

class _TeamCol extends StatelessWidget {
  const _TeamCol({required this.name});

  final String name;

  // Hue determinista por nombre (gold / blue / coral / green).
  (Color, Color) _hue(LTColors c) {
    final hues = [(c.gold, c.goldBg), (c.blue, c.blueSoft), (c.coral, c.coralSoft), (c.green, c.greenSoft)];
    return hues[name.hashCode.abs() % hues.length];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final (accent, soft) = _hue(c);
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(13)),
          alignment: Alignment.center,
          child: Text(
            sportTeamCode(name),
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: accent),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: LTType.caption(c.ink2, size: 12, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Standings ─────────────────────────────────────────────

class _StandingsCard extends StatelessWidget {
  const _StandingsCard({required this.standings});

  final List<SimpleStanding> standings;

  List<(String?, List<SimpleStanding>)> get _grouped {
    final hasGroups = standings.any((s) => s.group != null);
    if (!hasGroups) return [(null, standings)];
    final map = <String, List<SimpleStanding>>{};
    for (final s in standings) {
      (map[s.group ?? 'Grupo'] ??= []).add(s);
    }
    return map.entries.map((e) => (e.key, e.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Column(
        children: [
          for (final (group, rows) in _grouped) ...[
            if (group != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(group.toUpperCase(), style: LTType.eyebrow(c.coral)),
                ),
              ),
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0 || group != null) Divider(height: 1, thickness: 1, color: c.line),
              _StandingRow(s: rows[i]),
            ],
          ],
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.s});

  final SimpleStanding s;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '${s.rank}',
              style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w800, color: c.ink3),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(
              sportTeamCode(s.team.name),
              style: GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: c.ink2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              s.team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${s.points}',
            style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: c.gold),
          ),
        ],
      ),
    );
  }
}

// ── League selector ───────────────────────────────────────

class _LeagueSelector extends ConsumerWidget {
  const _LeagueSelector({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: leagueOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = leagueOptions[i];
          final isSel = i == selectedIndex;
          return LtPressable(
            onTap: () => ref.read(selectedLeagueIndexProvider.notifier).select(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? c.coral : c.card,
                borderRadius: BorderRadius.circular(LTRadius.pill),
                border: Border.all(color: isSel ? c.coral : c.line),
              ),
              child: Text(
                opt.label,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.white : c.ink2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Header / estados ──────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title, required this.accent});

  final String eyebrow;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Row(
      children: [
        LtPressable(
          onTap: () => context.go('/home'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(LTRadius.md),
              border: Border.all(color: c.line),
            ),
            child: Icon(Icons.chevron_left, color: c.ink, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: LTType.eyebrow(accent)),
              const SizedBox(height: 2),
              Text(title, style: LTType.display(c.ink, size: 26)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
      ),
      child: Center(child: Text(message, style: LTType.body(c.ink2))),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('No pudimos cargar los deportes.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(
            onTap: onRetry,
            child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
