import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/knockout_round_section.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/wc_states.dart';

class KnockoutTab extends ConsumerWidget {
  const KnockoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(worldCupRoundsProvider);
    Future<void> refresh() async => ref.invalidate(worldCupRoundsProvider);

    return async.when(
      loading: () => const WcLoading(),
      error: (_, __) => WcError(
        message: tr(ref, 'worldcup.error'),
        retryLabel: tr(ref, 'worldcup.retry'),
        onRetry: refresh,
      ),
      data: (resp) {
        final rounds = resp.knockoutRounds;
        if (rounds.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                WcEmpty(message: tr(ref, 'worldcup.knockout_empty'), icon: Icons.account_tree_outlined),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(worldCupRoundsProvider);
            for (final r in rounds) {
              ref.invalidate(worldCupRoundFixturesProvider(r));
            }
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 16, LTSpace.screenH, 24),
            itemCount: rounds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 22),
            itemBuilder: (context, i) => KnockoutRoundSection(round: rounds[i]),
          ),
        );
      },
    );
  }
}
