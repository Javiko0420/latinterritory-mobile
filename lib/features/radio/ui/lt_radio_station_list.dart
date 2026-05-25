import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';

void showStationSheet(
  BuildContext context,
  RadioPlayerNotifier notifier,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Consumer(
      builder: (_, ref, __) {
        final state = ref.watch(radioPlayerProvider);
        final playlist = state.playlist;
        final activeIndex = state.stationIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Estaciones de Radio',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: playlist.length,
                itemBuilder: (ctx, i) {
                  final s = playlist[i];
                  final active = i == activeIndex;
                  return ListTile(
                    onTap: () {
                      notifier.setStation(i);
                      Navigator.pop(ctx);
                    },
                    leading:
                        Text(s.country, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      s.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color:
                            active ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${s.frequency} · ${s.genre}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: active
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    ),
  );
}
