import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/i18n/tr.dart';

/// Main scaffold that wraps tabbed screens with a floating "pill" bottom nav.
///
/// ConsumerWidget para que los labels del nav reaccionen al cambio de idioma.
class LtMainScaffold extends ConsumerWidget {
  const LtMainScaffold({super.key, required this.child});

  final Widget child;

  static const _tabDefs = [
    _TabDef(icon: Icons.home_outlined,  activeIcon: Icons.home,   labelKey: 'nav.home',      path: '/home'),
    _TabDef(icon: Icons.store_outlined, activeIcon: Icons.store,  labelKey: 'nav.directory',  path: '/businesses'),
    _TabDef(icon: Icons.work_outline,   activeIcon: Icons.work,   labelKey: 'nav.jobs',       path: '/jobs'),
    _TabDef(icon: Icons.event_outlined, activeIcon: Icons.event,  labelKey: 'nav.events',     path: '/events'),
    _TabDef(icon: Icons.forum_outlined, activeIcon: Icons.forum,  labelKey: 'nav.forums',     path: '/forums'),
    _TabDef(icon: Icons.person_outline, activeIcon: Icons.person, labelKey: 'nav.profile',    path: '/profile'),
  ];

  static const double bottomNavReservedSpace = 92.0;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabDefs.length; i++) {
      if (location.startsWith(_tabDefs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _currentIndex(context);

    // Construye tabs con labels traducidas — se reconstruye al cambiar locale.
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
              child: _LtFloatingNav(
                tabs: tabs,
                currentIndex: currentIndex,
                onTap: (index) => context.go(tabs[index].path),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LtFloatingNav extends StatelessWidget {
  const _LtFloatingNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : const Color(0xFF1C1208).withValues(alpha: 0.18);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 4),
            blurRadius: 24,
          ),
        ],
        border: isDark
            ? Border.all(color: AppColors.darkBorder, width: 1)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _NavTab(
                tab: tabs[i],
                active: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final _TabItem tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    const activeColor = AppColors.primary;
    final color = active ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 44,
            height: 26,
            decoration: BoxDecoration(
              color: active
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(
              active ? tab.activeIcon : tab.icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
              letterSpacing: 0.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────

/// Definición estática del tab (sin label, que es dinámica).
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

/// Tab con label ya traducida, construido en build().
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
