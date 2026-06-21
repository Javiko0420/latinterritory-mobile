import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/match_card.dart';
import 'package:latinterritory/features/worldcup_2026/util/wc_round_label.dart';

class KnockoutRoundSection extends ConsumerWidget {
  const KnockoutRoundSection({super.key, required this.round});

  final String round;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(worldCupRoundFixturesProvider(round));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(wcRoundLabel(round), style: LTType.title(c.ink, size: 18)),
        const SizedBox(height: 10),
        async.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('—', style: LTType.body(c.ink3)),
          ),
          data: (fixtures) {
            if (fixtures.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('—', style: LTType.body(c.ink3)),
              );
            }
            return Column(
              children: [
                for (final f in fixtures) ...[
                  MatchCard(fixture: f),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
