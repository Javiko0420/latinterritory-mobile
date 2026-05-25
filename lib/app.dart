import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/routing/app_router.dart';
import 'package:latinterritory/core/theme/app_theme.dart';
import 'package:latinterritory/features/radio/ui/radio_overlay_wrapper.dart';

/// Root widget de la aplicación.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch mantiene vivo el routerProvider en Riverpod 3.x.
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'LatinTerritory',
      debugShowCheckedModeBanner: false,

      // ── Localización ────────────────────────────────
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Tema ────────────────────────────────────────
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
