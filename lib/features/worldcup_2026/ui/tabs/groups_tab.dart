import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/standings_table.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/wc_states.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(worldCupStandingsProvider);
    Future<void> refresh() async => ref.invalidate(worldCupStandingsProvider);

    return async.when(
      loading: () => const WcLoading(),
      error: (_, __) => WcError(
        message: tr(ref, 'worldcup.error'),
        retryLabel: tr(ref, 'worldcup.retry'),
        onRetry: refresh,
      ),
      data: (resp) {
        if (resp.groups.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                WcEmpty(message: tr(ref, 'worldcup.groups_empty'), icon: Icons.table_chart_outlined),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 16, LTSpace.screenH, 24),
            itemCount: resp.groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, i) => StandingsTable(group: resp.groups[i]),
          ),
        );
      },
    );
  }
}
