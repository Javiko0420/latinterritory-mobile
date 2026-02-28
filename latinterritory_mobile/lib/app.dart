import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/routing/app_router.dart';
import 'package:latinterritory/core/theme/app_theme.dart';

/// Root widget of the application.
///
/// Sets up MaterialApp with:
/// - GoRouter for declarative routing
/// - Light + dark theme from [AppTheme]
/// - Riverpod for state management (wrapped in main.dart)
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    );
  }
}
