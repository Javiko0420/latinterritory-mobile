import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LatinTerritory'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.pushNamed(RouteNames.login),
              child: const Text('Log In'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome ─────────────────────────────────
            if (user != null)
              Text(
                'Welcome, ${user.name ?? "there"}!',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'Welcome to LatinTerritory',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: AppDimensions.lg),

            // ── Quick Access Grid ───────────────────────
            _QuickAccessGrid(),

            const SizedBox(height: AppDimensions.lg),

            // ── Placeholder sections ────────────────────
            const _SectionPlaceholder(
              title: 'Weather & Exchange Rates',
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: AppDimensions.md),
            const _SectionPlaceholder(
              title: 'Latest from Forums',
              icon: Icons.forum_outlined,
            ),
            const SizedBox(height: AppDimensions.md),
            const _SectionPlaceholder(
              title: 'Upcoming Events',
              icon: Icons.event_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  final _items = const [
    _QuickItem(Icons.store, 'Directory', '/businesses', AppColors.categoryServices),
    _QuickItem(Icons.work, 'Jobs', '/jobs', AppColors.categoryFood),
    _QuickItem(Icons.event, 'Events', '/events', AppColors.categoryShopping),
    _QuickItem(Icons.forum, 'Forums', '/forums', AppColors.categoryEntertainment),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.sm,
      crossAxisSpacing: AppDimensions.sm,
      childAspectRatio: 2.2,
      children: _items
          .map((item) => _QuickAccessCard(item: item))
          .toList(),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});
  final _QuickItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go(item.path),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickItem {
  const _QuickItem(this.icon, this.label, this.path, this.color);
  final IconData icon;
  final String label;
  final String path;
  final Color color;
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textTertiary),
          const SizedBox(height: AppDimensions.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Coming soon',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
