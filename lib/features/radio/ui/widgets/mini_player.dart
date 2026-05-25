import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/features/radio/providers/radio_providers.dart';
import 'package:latinterritory/features/radio/services/radio_player_service.dart';

/// Mini player persistente que aparece sobre el bottom nav cuando
/// hay una estación en reproducción.
class RadioMiniPlayer extends ConsumerWidget {
  const RadioMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(currentStationProvider);
    if (station == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<bool>(
      stream: RadioPlayerService.instance.isPlayingStream,
      initialData: RadioPlayerService.instance.isPlaying,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Toca para ir a la pantalla de radio (si el contexto lo permite)
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // ── Logo ─────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: station.logoUrl != null &&
                              station.logoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: station.logoUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (context, error, _) =>
                                  _LogoPlaceholder(isDark: isDark),
                            )
                          : _LogoPlaceholder(isDark: isDark),
                    ),
                    const SizedBox(width: 10),

                    // ── Info ──────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (station.country != null ||
                              station.codec != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (station.country != null) station.country!,
                                if (station.codec != null)
                                  station.codec!.toUpperCase(),
                                if (station.bitrate != null)
                                  '${station.bitrate} kbps',
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Play / Stop ───────────────────────
                    _PlayStopButton(isPlaying: isPlaying, station: station),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.radio, color: Colors.white, size: 22),
    );
  }
}

class _PlayStopButton extends ConsumerWidget {
  const _PlayStopButton({
    required this.isPlaying,
    required this.station,
  });

  final bool isPlaying;
  final dynamic station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 28,
      ),
      onPressed: () async {
        final player = ref.read(radioPlayerServiceProvider);
        if (isPlaying) {
          await player.stop();
          ref.read(isPlayingProvider.notifier).set(false);
        } else {
          await player.play(station.streamUrl as String);
          ref.read(isPlayingProvider.notifier).set(true);
        }
      },
    );
  }
}
