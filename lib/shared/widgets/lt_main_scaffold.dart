import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

/// Main scaffold that wraps tabbed screens with a bottom navigation bar.
///
/// Used as the ShellRoute builder in [GoRouter].
class LtMainScaffold extends StatelessWidget {
  const LtMainScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,   activeIcon: Icons.home,         label: 'Inicio',     path: '/home'),
    _TabItem(icon: Icons.store_outlined,  activeIcon: Icons.store,        label: 'Directorio', path: '/businesses'),
    _TabItem(icon: Icons.work_outline,    activeIcon: Icons.work,         label: 'Empleos',    path: '/jobs'),
    _TabItem(icon: Icons.event_outlined,  activeIcon: Icons.event,        label: 'Eventos',    path: '/events'),
    _TabItem(icon: Icons.forum_outlined,  activeIcon: Icons.forum,        label: 'Foros',      path: '/forums'),
    _TabItem(icon: Icons.person_outline,  activeIcon: Icons.person,       label: 'Perfil',     path: '/profile'),
  ];

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
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].path);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon, color: AppColors.primary),
                label: tab.label,
              ),
            )
            .toList(),
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
