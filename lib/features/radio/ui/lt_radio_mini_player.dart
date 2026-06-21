import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';
import 'package:latinterritory/features/radio/ui/lt_radio_station_list.dart';
import 'package:latinterritory/shared/widgets/lt_andean_pattern.dart';
import 'package:latinterritory/shared/widgets/lt_eq_bars.dart';

const double kPlayerWidth = 300.0;
const double kPlayerHeight = 72.0;
const double kFabSize = 52.0;
const double kNavBarMargin = 96.0;
const double kTopSafeArea = 50.0;

/// Floating draggable radio mini player rendered in the app overlay.
class LtRadioMiniPlayer extends ConsumerWidget {
  const LtRadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioPlayerProvider);
    final notifier = ref.read(radioPlayerProvider.notifier);
    final screen = MediaQuery.of(context).size;

    if (state.mode == RadioPlayerMode.hidden) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: state.position.dx,
      top: state.position.dy,
      child: state.mode == RadioPlayerMode.minimized
          ? _MinimizedFab(
              state: state,
              notifier: notifier,
              screen: screen,
            )
          : _ExpandedPlayer(
              state: state,
              notifier: notifier,
              screen: screen,
            ),
    );
  }
}

class _ExpandedPlayer extends StatelessWidget {
  const _ExpandedPlayer({
    required this.state,
    required this.notifier,
    required this.screen,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;
  final Size screen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final newX = (state.position.dx + details.delta.dx)
            .clamp(0.0, screen.width - kPlayerWidth);
        final newY = (state.position.dy + details.delta.dy)
            .clamp(kTopSafeArea, screen.height - kPlayerHeight - kNavBarMargin);
        notifier.updatePosition(Offset(newX, newY));
      },
      child: _PlayerCard(state: state, notifier: notifier),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.state,
    required this.notifier,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kPlayerWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBB4F25), Color(0xFFE07830), Color(0xFFE38D18)],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE07830).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                painter: AndeanPatternPainter(
                  color: const Color(0xFFFAF7F1),
                  opacity: 0.10,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 2),
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
                child: Row(
                  children: [
                    _PulseAvatar(
                      country: state.currentStation.country,
                      isPlaying: state.isPlaying,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showStationSheet(context, notifier),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    state.currentStation.name,
                                    style: GoogleFonts.hankenGrotesk(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (state.isPlaying) const LtEqBars(),
                                if (state.isPlaying) const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${state.currentStation.frequency} · ${state.currentStation.genre}',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    _Controls(state: state, notifier: notifier),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.notifier,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleBtn(
          icon: Icons.skip_previous,
          size: 32,
          onTap: notifier.prevStation,
        ),
        const SizedBox(width: 4),
        _CircleBtn(
          icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
          size: 38,
          filled: true,
          onTap: notifier.toggle,
        ),
        const SizedBox(width: 4),
        _CircleBtn(
          icon: Icons.skip_next,
          size: 32,
          onTap: notifier.nextStation,
        ),
        const SizedBox(width: 6),
        _CircleBtn(
          icon: Icons.remove,
          size: 28,
          dark: true,
          onTap: notifier.minimize,
        ),
        const SizedBox(width: 4),
        _CircleBtn(
          icon: Icons.close,
          size: 28,
          dark: true,
          onTap: notifier.hide,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.size,
    required this.onTap,
    this.filled = false,
    this.dark = false,
  });

  final IconData icon;
  final double size;
  final bool filled;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (filled) {
      bg = Colors.white.withValues(alpha: 0.25);
    } else if (dark) {
      bg = Colors.black.withValues(alpha: 0.15);
    } else {
      bg = Colors.white.withValues(alpha: 0.15);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: filled
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

class _MinimizedFab extends StatelessWidget {
  const _MinimizedFab({
    required this.state,
    required this.notifier,
    required this.screen,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;
  final Size screen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: notifier.expand,
      onPanUpdate: (details) {
        final newX = (state.position.dx + details.delta.dx)
            .clamp(0.0, screen.width - kFabSize);
        final newY = (state.position.dy + details.delta.dy)
            .clamp(kTopSafeArea, screen.height - kFabSize - kNavBarMargin);
        notifier.updatePosition(Offset(newX, newY));
      },
      onPanEnd: (_) => notifier.snapToEdge(screen),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (state.isPlaying)
            const Positioned(
              top: -6,
              left: -6,
              right: -6,
              bottom: -6,
              child: _PulseRing(),
            ),
          Container(
            width: kFabSize,
            height: kFabSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE07830), Color(0xFFBB4F25)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE07830).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.radio, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _PulseAvatar extends StatefulWidget {
  const _PulseAvatar({
    required this.country,
    required this.isPlaying,
  });

  final String country;
  final bool isPlaying;

  @override
  State<_PulseAvatar> createState() => _PulseAvatarState();
}

class _PulseAvatarState extends State<_PulseAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulseAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = widget.isPlaying ? 1.0 + _ctrl.value * 0.08 : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(widget.country, style: const TextStyle(fontSize: 20)),
          ),
        );
      },
    );
  }
}

class _PulseRing extends StatefulWidget {
  const _PulseRing();

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = (1 - _ctrl.value).clamp(0.0, 1.0);
        final scale = 0.85 + _ctrl.value * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE07830).withValues(alpha: opacity * 0.6),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
