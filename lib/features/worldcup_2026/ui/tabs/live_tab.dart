import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/match_card.dart';
import 'package:latinterritory/features/worldcup_2026/ui/widgets/wc_states.dart';

/// Tab "En vivo". Polling gestionado por el provider; aquí solo pausamos/
/// reanudamos según el ciclo de vida de la app (background).
class LiveTab extends ConsumerStatefulWidget {
  const LiveTab({super.key});

  @override
  ConsumerState<LiveTab> createState() => _LiveTabState();
}

class _LiveTabState extends ConsumerState<LiveTab> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(worldCupLiveProvider.notifier);
    if (state == AppLifecycleState.resumed) {
      notifier.resume();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      notifier.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(worldCupLiveProvider);
    final data = async.asData?.value;

    Future<void> refresh() async => ref.invalidate(worldCupLiveProvider);

    if (data == null) {
      if (async.isLoading) return const WcLoading();
      return WcError(
        message: tr(ref, 'worldcup.error'),
        retryLabel: tr(ref, 'worldcup.retry'),
        onRetry: refresh,
      );
    }

    final fixtures = data.fixtures;
    if (!data.hasLive || fixtures.isEmpty) {
      // Pull-to-refresh disponible incluso en vacío.
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
            WcEmpty(message: tr(ref, 'worldcup.no_live'), icon: Icons.podcasts_outlined),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 16, LTSpace.screenH, 24),
        itemCount: fixtures.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => MatchCard(fixture: fixtures[i]),
      ),
    );
  }
}
