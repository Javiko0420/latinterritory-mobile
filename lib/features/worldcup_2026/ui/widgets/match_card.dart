import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/worldcup_2026/models/world_cup_fixture.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/live_badge.dart';

class MatchCard extends ConsumerWidget {
  const MatchCard({super.key, required this.fixture});

  final WorldCupFixture fixture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final localeCode = ref.watch(localeProvider).languageCode;
    final phase = fixture.phase;
    final hasWinner = fixture.home.winner == true || fixture.away.winner == true;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Column(
        children: [
          Center(child: _statusChip(context, ref, c, phase, localeCode)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Team(team: fixture.home, hasWinner: hasWinner)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _center(c, phase, localeCode),
              ),
              Expanded(child: _Team(team: fixture.away, hasWinner: hasWinner)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, WidgetRef ref, LTColors c, WcPhase phase, String localeCode) {
    switch (phase) {
      case WcPhase.live:
        return LiveBadge(
          label: tr(ref, 'worldcup.live'),
          color: c.coral,
          soft: c.coralSoft,
          trailing: fixture.status.elapsed != null ? "${fixture.status.elapsed}'" : null,
        );
      case WcPhase.finished:
        return _pill(c, tr(ref, 'worldcup.final'), c.ink2, c.card2);
      case WcPhase.notStarted:
        final d = fixture.date;
        final label = d != null ? DateFormat('EEE d MMM', localeCode).format(d) : '—';
        return _pill(c, label, c.ink3, c.card2);
      case WcPhase.other:
        return _pill(c, fixture.status.long ?? '—', c.ink3, c.card2);
    }
  }

  Widget _pill(LTColors c, String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LTRadius.pill)),
      child: Text(text, style: GoogleFonts.hankenGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _center(LTColors c, WcPhase phase, String localeCode) {
    if (phase == WcPhase.live || phase == WcPhase.finished) {
      return Text(
        '${fixture.goals.home ?? 0} - ${fixture.goals.away ?? 0}',
        style: GoogleFonts.hankenGrotesk(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1, color: c.ink),
      );
    }
    if (phase == WcPhase.notStarted) {
      final d = fixture.date;
      return Text(
        d != null ? DateFormat('HH:mm', localeCode).format(d) : 'vs',
        style: GoogleFonts.hankenGrotesk(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink2),
      );
    }
    return Text('—', style: GoogleFonts.hankenGrotesk(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink3));
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.team, required this.hasWinner});

  final WorldCupTeam team;
  final bool hasWinner;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final isWinner = team.winner == true;
    final Color color;
    final FontWeight weight;
    if (isWinner) {
      color = c.ink;
      weight = FontWeight.w800;
    } else if (hasWinner) {
      color = c.ink2;
      weight = FontWeight.w600;
    } else {
      color = c.ink;
      weight = FontWeight.w700;
    }

    return Column(
      children: [
        _Logo(url: team.logo, name: team.name),
        const SizedBox(height: 7),
        Text(
          team.name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: weight, color: color),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    Widget fallback() => Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: c.card2, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            name.isEmpty ? '?' : name.characters.first.toUpperCase(),
            style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink2),
          ),
        );

    if (url == null || url!.isEmpty) return fallback();
    return SizedBox(
      width: 40,
      height: 40,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.contain,
        placeholder: (_, __) => fallback(),
        errorWidget: (_, __, ___) => fallback(),
      ),
    );
  }
}
