import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';
import 'package:latinterritory/features/radio/ui/lt_radio_station_list.dart';
import 'package:latinterritory/shared/widgets/lt_eq_bars.dart';

const double kPlayerWidth = 300.0;
const double kPlayerHeight = 72.0;
const double kFabSize = 52.0;

/// Reserva de diseño del bottom nav flotante: no es un inset del sistema, por
/// eso se mantiene constante en lugar de derivarse de MediaQuery.
const double kNavBarMargin = 96.0;

/// Separación mínima entre el player y las safe areas del sistema.
const double kSafeAreaMargin = 8.0;

// Segundo stop del gradiente coral, igual al de la card de radio del Home.
const Color _kCoralDeep = Color(0xFFA8442F);

/// Límites de posición del mini player para las métricas de pantalla actuales.
///
/// Se recalculan en cada build porque dependen de `MediaQuery`: Android 16
/// ignora el lock a portrait en pantallas grandes (sw >= 600dp), así que rotar
/// o entrar en split-screen puede dejar fuera de pantalla un offset que era
/// válido con las métricas anteriores. En landscape el display cutout pasa al
/// costado, por eso los cuatro bordes salen de `viewPadding`.
@visibleForTesting
class PlayerBounds {
  const PlayerBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// [size] es el tamaño del widget posicionado: card expandida o FAB.
  factory PlayerBounds.of({
    required Size screen,
    required EdgeInsets viewPadding,
    required Size size,
  }) {
    final minX = viewPadding.left + kSafeAreaMargin;
    final minY = viewPadding.top + kSafeAreaMargin;
    // math.max evita que clamp() reciba un rango invertido (lanzaría
    // ArgumentError) cuando la ventana es más angosta o más corta que el propio
    // player: split-screen, landscape en teléfono.
    return PlayerBounds(
      minX: minX,
      maxX: math.max(
        minX,
        screen.width - size.width - viewPadding.right - kSafeAreaMargin,
      ),
      minY: minY,
      // kNavBarMargin ya reserva el hueco inferior; viewPadding.bottom es el
      // inset del sistema (gesture bar) y se suma encima.
      maxY: math.max(
        minY,
        screen.height - size.height - kNavBarMargin - viewPadding.bottom,
      ),
    );
  }

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  Offset clamp(Offset position) => Offset(
        position.dx.clamp(minX, maxX),
        position.dy.clamp(minY, maxY),
      );
}

/// Floating draggable radio mini player rendered in the app overlay.
class LtRadioMiniPlayer extends ConsumerWidget {
  const LtRadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioPlayerProvider);

    if (state.mode == RadioPlayerMode.hidden) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(radioPlayerProvider.notifier);
    final screen = MediaQuery.sizeOf(context);
    final minimized = state.mode == RadioPlayerMode.minimized;
    final bounds = PlayerBounds.of(
      screen: screen,
      viewPadding: MediaQuery.viewPaddingOf(context),
      size: minimized
          ? const Size(kFabSize, kFabSize)
          : const Size(kPlayerWidth, kPlayerHeight),
    );

    // El clamp se aplica a una variable LOCAL a propósito: mutar estado de
    // Riverpod dentro de build() provoca rebuild loops. El estado persistido se
    // autocorrige en el próximo onPanUpdate, que clampea con estos mismos
    // límites.
    final position = bounds.clamp(state.position);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: minimized
          ? _MinimizedFab(
              state: state,
              notifier: notifier,
              position: position,
              bounds: bounds,
              screen: screen,
            )
          : _ExpandedPlayer(
              state: state,
              notifier: notifier,
              position: position,
              bounds: bounds,
            ),
    );
  }
}

class _ExpandedPlayer extends StatelessWidget {
  const _ExpandedPlayer({
    required this.state,
    required this.notifier,
    required this.position,
    required this.bounds,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;

  /// Posición ya clampeada del frame actual: el drag parte de lo que se ve, no
  /// del offset almacenado (que puede haber quedado fuera de pantalla).
  final Offset position;
  final PlayerBounds bounds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) =>
          notifier.updatePosition(bounds.clamp(position + details.delta)),
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
    final c = context.lt;
    // Glass pill: mismo idioma que el bottom nav (chrome flotante).
    return ClipRRect(
      borderRadius: BorderRadius.circular(LTRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: kPlayerWidth,
          decoration: BoxDecoration(
            color: c.tabbar,
            borderRadius: BorderRadius.circular(LTRadius.lg),
            border: Border.all(color: c.line),
            boxShadow: c.softShadow,
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 6, bottom: 2),
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: c.ink3.withValues(alpha: 0.5),
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
                                    style: LTType.card(c.ink, size: 13.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: c.ink3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                if (state.isPlaying) LtEqBars(color: c.coral),
                                if (state.isPlaying) const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    '${state.currentStation.frequency} · ${state.currentStation.genre}',
                                    style: LTType.caption(c.ink2, size: 11),
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
        ),
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
          subtle: true,
          onTap: notifier.minimize,
        ),
        const SizedBox(width: 4),
        _CircleBtn(
          icon: Icons.close,
          size: 28,
          subtle: true,
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
    this.subtle = false,
  });

  final IconData icon;
  final double size;

  /// Acción primaria (play/pause): relleno coral, ícono blanco.
  final bool filled;

  /// Acción terciaria (minimizar/cerrar): ícono atenuado.
  final bool subtle;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final bg = filled ? c.coral : c.card2;
    final fg = filled
        ? Colors.white
        : subtle
            ? c.ink2
            : c.ink;

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
            border: subtle || filled ? null : Border.all(color: c.line),
          ),
          child: Icon(
            icon,
            color: fg,
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
    required this.position,
    required this.bounds,
    required this.screen,
  });

  final RadioPlayerState state;
  final RadioPlayerNotifier notifier;

  /// Posición ya clampeada del frame actual (ver [_ExpandedPlayer.position]).
  final Offset position;
  final PlayerBounds bounds;
  final Size screen;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return GestureDetector(
      onTap: notifier.expand,
      onPanUpdate: (details) =>
          notifier.updatePosition(bounds.clamp(position + details.delta)),
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
              // Identidad de radio: mismo gradiente coral de la card del Home.
              gradient: LinearGradient(
                colors: [c.coral, _kCoralDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: c.softShadow,
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
    final c = context.lt;
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
              color: c.coralSoft,
              border: Border.all(color: c.line, width: 1.5),
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
    final coral = context.lt.coral;
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
                color: coral.withValues(alpha: opacity * 0.6),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
