import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Shell raíz (LTAppShell) con la barra inferior del design system:
/// 4 tabs + FAB dorado central "Publicar".
///
/// La estructura de rutas NO cambia: Foros y Perfil siguen accesibles (Perfil
/// desde el avatar/acción del header de cada pantalla; Foros desde Home). Aquí
/// solo cambia el conjunto de entradas visibles en la barra.
class LtMainScaffold extends ConsumerWidget {
  const LtMainScaffold({super.key, required this.child});

  final Widget child;

  static const _tabDefs = [
    _TabDef(icon: Icons.home_outlined,       activeIcon: Icons.home,       labelKey: 'nav.home',      path: '/home'),
    _TabDef(icon: Icons.storefront_outlined, activeIcon: Icons.storefront, labelKey: 'nav.directory', path: '/businesses'),
    _TabDef(icon: Icons.work_outline,        activeIcon: Icons.work,       labelKey: 'nav.jobs',      path: '/jobs'),
    _TabDef(icon: Icons.event_outlined,      activeIcon: Icons.event,      labelKey: 'nav.events',    path: '/events'),
  ];

  static const double bottomNavReservedSpace = 96.0;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabDefs.length; i++) {
      if (location.startsWith(_tabDefs[i].path)) return i;
    }
    return -1; // pantallas fuera de la barra (foros, perfil, utilidades)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);

    final tabs = _tabDefs
        .map((d) => _TabItem(
              icon: d.icon,
              activeIcon: d.activeIcon,
              label: tr(ref, d.labelKey),
              path: d.path,
            ))
        .toList();

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: bottomNavReservedSpace),
            child: child,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: _LtBottomNav(
                tabs: tabs,
                currentIndex: currentIndex,
                onTap: (index) => context.go(tabs[index].path),
                onPublish: () => context.pushNamed(RouteNames.publish),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LtBottomNav extends StatelessWidget {
  const _LtBottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.onPublish,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;

    return SizedBox(
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Glass pill ──────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.tabbar,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: c.line, width: 1),
                    boxShadow: c.softShadow,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(child: _NavTab(tab: tabs[0], active: currentIndex == 0, onTap: () => onTap(0))),
                      Expanded(child: _NavTab(tab: tabs[1], active: currentIndex == 1, onTap: () => onTap(1))),
                      const SizedBox(width: 64), // hueco para el FAB
                      Expanded(child: _NavTab(tab: tabs[2], active: currentIndex == 2, onTap: () => onTap(2))),
                      Expanded(child: _NavTab(tab: tabs[3], active: currentIndex == 3, onTap: () => onTap(3))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── FAB dorado "Publicar" ───────────────────────────
          Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(child: _PublishFab(onTap: onPublish)),
          ),
        ],
      ),
    );
  }
}

class _PublishFab extends StatelessWidget {
  const _PublishFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LtPressable(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LTBrand.gold, Color(0xFFC98A1A)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: LTBrand.gold.withValues(alpha: 0.55),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: LTBrand.onGold, size: 28),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.tab, required this.active, required this.onTap});

  final _TabItem tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final color = active ? c.gold : c.ink3;

    return LtPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: LTMotion.press,
              curve: Curves.easeOut,
              width: 40,
              height: 26,
              decoration: BoxDecoration(
                color: active ? c.gold.withValues(alpha: 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(active ? tab.activeIcon : tab.icon, size: 19, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────

class _TabDef {
  const _TabDef({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final String path;
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
