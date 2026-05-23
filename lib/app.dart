import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/routing/app_router.dart';
import 'package:latinterritory/core/theme/app_theme.dart';

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
    // Read instead of watch — the router is created once and manages
    // its own refresh via _RouterRefreshNotifier + refreshListenable.
    // Watching here would cause MaterialApp.router to rebuild (and
    // flash blank) on every auth state change.
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: 'LatinTerritory',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── Routing ─────────────────────────────────────
      routerConfig: router,
    );
  }
}
