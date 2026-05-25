import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/routing/app_router.dart';
import 'package:latinterritory/core/theme/app_theme.dart';
import 'package:latinterritory/features/radio/ui/radio_overlay_wrapper.dart';

/// Root widget of the application.
///
/// Sets up MaterialApp with:
/// - GoRouter for declarative routing (created once, never recreated)
/// - Light + dark theme from [AppTheme]
/// - Riverpod for state management (wrapped in main.dart)
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IMPORTANTE: usar ref.watch (no ref.read) para que Riverpod mantenga
    // vivo el routerProvider durante toda la sesión.
    //
    // En Riverpod 3.x, los providers se auto-disposan cuando ningún widget
    // los observa. Con ref.read, el routerProvider se disponía justo después
    // del primer build(), destruyendo el _RouterRefreshNotifier y cortando
    // las notificaciones de cambio de auth a GoRouter.
    //
    // Como routerProvider devuelve siempre la MISMA instancia de GoRouter
    // (nunca cambia), este watch NO provoca rebuilds innecesarios de App.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LatinTerritory',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Routing ─────────────────────────────────────
      routerConfig: router,

      // ── Global overlay (radio mini player) ──────────
      builder: (context, child) =>
          RadioOverlayWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
