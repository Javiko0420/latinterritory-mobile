import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/sports/data/models/worldcup_widget_models.dart';
import 'package:latinterritory/features/sports/data/worldcup_widget_repository.dart';

// ── Repository ────────────────────────────────────────────

final worldcupWidgetRepositoryProvider =
    Provider<WorldcupWidgetRepository>((ref) {
  return WorldcupWidgetRepository(dio: ref.watch(dioProvider));
});

// ── Polling ───────────────────────────────────────────────

const _pollInterval = Duration(seconds: 30);

/// Notifier del widget del Mundial con polling cada 30s y refresh silencioso.
///
/// `autoDispose`: el timer se crea en [build] y se cancela en `ref.onDispose`,
/// así deja de pollear cuando el widget del home deja de estar montado.
class WorldcupWidgetNotifier extends AsyncNotifier<WorldcupWidget> {
  Timer? _timer;

  @override
  Future<WorldcupWidget> build() async {
    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();
    _timer = Timer.periodic(_pollInterval, (_) => _refresh());
    return ref.read(worldcupWidgetRepositoryProvider).getWidget();
  }

  /// Revalidación en segundo plano: nunca vuelve a "Cargando…" y, si el poll
  /// falla, conserva el último marcador en pantalla (no muestra error).
  Future<void> _refresh() async {
    final next = await AsyncValue.guard(
      () => ref.read(worldcupWidgetRepositoryProvider).getWidget(),
    );
    if (next.hasError && state.hasValue) return;
    state = next;
  }
}

final worldcupWidgetProvider =
    AsyncNotifierProvider.autoDispose<WorldcupWidgetNotifier, WorldcupWidget>(
  WorldcupWidgetNotifier.new,
);
