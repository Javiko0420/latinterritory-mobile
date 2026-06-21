import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/sports/data/models/worldcup_widget_models.dart';
import 'package:latinterritory/features/sports/providers/worldcup_widget_providers.dart';
import 'package:latinterritory/features/sports/ui/sports_format.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Mini-tarjeta del widget del Mundial 2026 en Home. Replica el widget web:
/// datos reales de [worldcupWidgetProvider] (polling 30s + refresh silencioso),
/// estados live / final / cargando / error. Tap → pantalla de deportes.
class LTSportsWidget extends ConsumerWidget {
  const LTSportsWidget({super.key, this.width = 178});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(worldcupWidgetProvider);
    final data = async.asData?.value;

    Widget content;
    if (data == null) {
      content = async.isLoading
          ? _centered(c, 'Cargando marcador…')
          : _centered(c, 'No pudimos cargar el marcador.');
    } else if (data.fixture == null) {
      content = _centered(c, 'No pudimos cargar el marcador.');
    } else {
      content = _scoreboard(c, data, data.fixture!);
    }

    return LtPressable(
      onTap: () => context.go('/sports'),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.tile),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: content,
      ),
    );
  }

  Widget _centered(LTColors c, String msg) {
    return Center(
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: c.ink3,
        ),
      ),
    );
  }

  Widget _scoreboard(LTColors c, WorldcupWidget w, WidgetFixture fx) {
    final live = w.isLive;
    final round = roundLabel(fx.round);
    final subtitle = round.isEmpty ? 'Mundial 2026' : 'Mundial 2026 · $round';

    // Resaltado del ganador (winner manda incluso en penales).
    final homeWin = fx.teams.home.winner == true;
    final awayWin = fx.teams.away.winner == true;
    final hasWinner = homeWin || awayWin;

    String footer;
    if (live && fx.status.elapsed != null) {
      footer = "${fx.status.elapsed}'";
    } else {
      final dt = DateTime.tryParse(fx.date);
      footer = dt != null
          ? DateFormat('d MMM', 'es').format(dt)
          : (fx.status.short ?? '');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Deportes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: c.ink2,
                ),
              ),
            ),
            if (live) _LiveBadge(color: c.coral, soft: c.coralSoft)
            else _FinalBadge(c: c),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c.ink3,
          ),
        ),
        const SizedBox(height: 10),
        _teamRow(c, fx.teams.home, fx.goals.home, homeWin, hasWinner),
        const SizedBox(height: 6),
        _teamRow(c, fx.teams.away, fx.goals.away, awayWin, hasWinner),
        const SizedBox(height: 8),
        Center(
          child: Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: live ? c.coral : c.ink3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _teamRow(LTColors c, WidgetTeam team, int? goal, bool isWinner, bool hasWinner) {
    // Ganador resaltado; el otro atenuado; si no hay ganador, ambos normales.
    final Color nameColor;
    final FontWeight weight;
    if (isWinner) {
      nameColor = c.ink;
      weight = FontWeight.w800;
    } else if (hasWinner) {
      nameColor = c.ink2;
      weight = FontWeight.w600;
    } else {
      nameColor = c.ink;
      weight = FontWeight.w700;
    }

    return Row(
      children: [
        _TeamLogo(url: team.logo, fallback: c.ink3),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            team.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: weight,
              color: nameColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          goal?.toString() ?? '–',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: nameColor,
          ),
        ),
      ],
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.fallback});

  final String? url;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    final placeholder = Icon(Icons.sports_soccer, size: 18, color: fallback);
    if (url == null || url!.isEmpty) {
      return SizedBox(width: 22, height: 22, child: placeholder);
    }
    return SizedBox(
      width: 22,
      height: 22,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.contain,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _FinalBadge extends StatelessWidget {
  const _FinalBadge({required this.c});

  final LTColors c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.card2,
        borderRadius: BorderRadius.circular(LTRadius.pill),
      ),
      child: Text(
        'Final',
        style: GoogleFonts.hankenGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: c.ink2,
        ),
      ),
    );
  }
}

/// Badge "EN VIVO" con punto terracota pulsante.
class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.color, required this.soft});

  final Color color;
  final Color soft;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: widget.soft,
        borderRadius: BorderRadius.circular(LTRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.35).animate(_ctrl),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'EN VIVO',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
