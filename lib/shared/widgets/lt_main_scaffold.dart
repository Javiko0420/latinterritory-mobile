import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

/// Main scaffold that wraps tabbed screens with a floating "pill" bottom nav.
///
/// Used as the ShellRoute builder in [GoRouter]. The body content is padded
/// at the bottom so the floating nav doesn't cover scrollable content.
class LtMainScaffold extends StatelessWidget {
  const LtMainScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,   activeIcon: Icons.home,   label: 'Inicio',     path: '/home'),
    _TabItem(icon: Icons.store_outlined,  activeIcon: Icons.store,  label: 'Directorio', path: '/businesses'),
    _TabItem(icon: Icons.work_outline,    activeIcon: Icons.work,   label: 'Empleos',    path: '/jobs'),
    _TabItem(icon: Icons.event_outlined,  activeIcon: Icons.event,  label: 'Eventos',    path: '/events'),
    _TabItem(icon: Icons.forum_outlined,  activeIcon: Icons.forum,  label: 'Foros',      path: '/forums'),
    _TabItem(icon: Icons.person_outline,  activeIcon: Icons.person, label: 'Perfil',     path: '/profile'),
  ];

  /// Vertical padding reserved at the bottom of the body so the floating
  /// pill nav doesn't overlap content. Exposed for child screens that
  /// scroll (so they can subtract this from their own bottom insets).
  static const double bottomNavReservedSpace = 92.0;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

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
                tabs: _tabs,
                currentIndex: currentIndex,
                onTap: (index) => context.go(_tabs[index].path),
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
