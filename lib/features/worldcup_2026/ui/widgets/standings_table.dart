import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/worldcup_2026/models/standings.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';

const double _numW = 22;

class StandingsTable extends ConsumerWidget {
  const StandingsTable({super.key, required this.group});

  final GroupStandings group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.group, style: LTType.title(c.ink, size: 18)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(LTRadius.md),
            border: Border.all(color: c.line),
            boxShadow: c.softShadow,
          ),
          child: Column(
            children: [
              _HeaderRow(),
              for (var i = 0; i < group.standings.length; i++) ...[
                Divider(height: 1, thickness: 1, color: c.line),
                _Row(row: group.standings[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    Widget h(String key) => SizedBox(
          width: _numW,
          child: Text(
            tr(ref, key),
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: c.ink3),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          const SizedBox(width: 18),
          const Spacer(),
          h('worldcup.col_played'),
          h('worldcup.col_win'),
          h('worldcup.col_draw'),
          h('worldcup.col_lose'),
          h('worldcup.col_gf'),
          h('worldcup.col_ga'),
          h('worldcup.col_gd'),
          h('worldcup.col_pts'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row});

  final StandingRow row;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    Widget cell(String text, {bool bold = false, Color? color}) => SizedBox(
          width: _numW,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? c.ink2,
            ),
          ),
        );
    final dg = row.goalsDiff > 0 ? '+${row.goalsDiff}' : '${row.goalsDiff}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text('${row.rank}', style: GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w800, color: c.ink3)),
          ),
          _TeamLogo(team: row.team),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.team.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.ink),
            ),
          ),
          cell('${row.played}'),
          cell('${row.win}'),
          cell('${row.draw}'),
          cell('${row.lose}'),
          cell('${row.goalsFor}'),
          cell('${row.goalsAgainst}'),
          cell(dg),
          cell('${row.points}', bold: true, color: c.gold),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.team});

  final WorldCupTeam team;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    Widget fallback() => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: c.card2, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            team.name.isEmpty ? '?' : team.name.characters.first.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(fontSize: 10, fontWeight: FontWeight.w800, color: c.ink2),
          ),
        );
    final url = team.logo;
    if (url == null || url.isEmpty) return fallback();
    return SizedBox(
      width: 22,
      height: 22,
      child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain, placeholder: (_, __) => fallback(), errorWidget: (_, __, ___) => fallback()),
    );
  }
}
