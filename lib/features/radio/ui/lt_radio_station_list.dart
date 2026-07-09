import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';

void showStationSheet(
  BuildContext context,
  RadioPlayerNotifier notifier,
) {
  final c = context.lt;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(LTRadius.lg)),
    ),
    builder: (ctx) => Consumer(
      builder: (_, ref, __) {
        final c = ctx.lt;
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
                color: c.ink3.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Estaciones de Radio',
                style: LTType.title(c.ink, size: 16),
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
                      style: LTType.body(
                        active ? c.coral : c.ink,
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${s.frequency} · ${s.genre}',
                      style: LTType.caption(c.ink2, size: 12),
                    ),
                    trailing: active
                        ? Icon(Icons.check_circle, color: c.coral)
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
