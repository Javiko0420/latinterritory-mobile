import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Saludo contextual según la hora del día.
  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final forumsAsync = ref.watch(forumsProvider);

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
              child: const Text('Iniciar Sesión'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Saludo ───────────────────────────────────
            if (user != null)
              Text(
                '${_greeting()}, ${user.name?.split(' ').first ?? ""}!',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'Bienvenido a LatinTerritory',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: AppDimensions.lg),

            // ── Accesos rápidos ───────────────────────────
            const _QuickAccessGrid(),

            const SizedBox(height: AppDimensions.lg),

            // ── Utilidades ───────────────────────────────
            const _WeatherCard(),
            const SizedBox(height: AppDimensions.md),
            const _ExchangeRatesCard(),
            const SizedBox(height: AppDimensions.md),
            const _SportsCard(),
            const SizedBox(height: AppDimensions.md),

            // ── Sección foros (dinámica) ──────────────────
            forumsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (forums) {
                if (forums.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    _ForumsSummaryCard(forumCount: forums.length),
                    const SizedBox(height: AppDimensions.md),
                  ],
                );
              },
            ),

            // ── Próximos eventos (placeholder) ────────────
            const _SectionPlaceholder(
              title: 'Próximos Eventos',
              icon: Icons.event_outlined,
            ),

            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }
}

// ── Grid de accesos rápidos ───────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  static const _items = [
    _QuickItem(Icons.store,  'Directorio', '/businesses', AppColors.categoryServices),
    _QuickItem(Icons.work,   'Empleos',    '/jobs',       AppColors.categoryFood),
    _QuickItem(Icons.event,  'Eventos',    '/events',     AppColors.categoryShopping),
    _QuickItem(Icons.forum,  'Foros',      '/forums',     AppColors.categoryEntertainment),
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
      children: _items.map((item) => _QuickAccessCard(item: item)).toList(),
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

// ── Tarjetas de utilidades ────────────────────────────────

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return _UtilityCard(
      icon: Icons.wb_sunny_outlined,
      iconColor: Colors.blue,
      label: 'Clima',
      onTap: () => context.go('/weather'),
    );
  }
}

class _ExchangeRatesCard extends StatelessWidget {
  const _ExchangeRatesCard();

  @override
  Widget build(BuildContext context) {
    return _UtilityCard(
      icon: Icons.currency_exchange,
      iconColor: AppColors.secondary,
      label: 'Tasas de Cambio',
      onTap: () => context.go('/exchange'),
    );
  }
}

class _SportsCard extends StatelessWidget {
  const _SportsCard();

  @override
  Widget build(BuildContext context) {
    return _UtilityCard(
      icon: Icons.sports_soccer,
      iconColor: AppColors.success,
      label: 'Deportes',
      onTap: () => context.go('/sports'),
    );
  }
}

/// Tarjeta genérica reutilizable para accesos de utilidades.
class _UtilityCard extends StatelessWidget {
  const _UtilityCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Foros activos (dinámico) ──────────────────────────────

class _ForumsSummaryCard extends StatelessWidget {
  const _ForumsSummaryCard({required this.forumCount});
  final int forumCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/forums'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.categoryEntertainment.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(Icons.forum_outlined,
                    color: AppColors.categoryEntertainment),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foros de la Comunidad',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '$forumCount foro${forumCount == 1 ? '' : 's'} activo${forumCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Placeholder de sección ────────────────────────────────

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
            'Próximamente',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}
