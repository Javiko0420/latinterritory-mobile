import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class BusinessListScreen extends ConsumerStatefulWidget {
  const BusinessListScreen({super.key});

  @override
  ConsumerState<BusinessListScreen> createState() =>
      _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  final _searchController = TextEditingController();

  static const _categories = [
    'GASTRONOMIA',
    'TECNOLOGIA',
    'ARTESANIAS',
    'SERVICIOS',
    'MODA',
    'SALUD',
    'EDUCACION',
    'TURISMO',
    'ENTRETENIMIENTO',
    'OTROS',
  ];

  /// Etiquetas en español para mostrar en la UI.
  static const _categoryLabels = {
    'GASTRONOMIA':    'Gastronomía',
    'TECNOLOGIA':     'Tecnología',
    'ARTESANIAS':     'Artesanías',
    'SERVICIOS':      'Servicios',
    'MODA':           'Moda',
    'SALUD':          'Salud',
    'EDUCACION':      'Educación',
    'TURISMO':        'Turismo',
    'ENTRETENIMIENTO':'Entretenimiento',
    'OTROS':          'Otros',
  };

  /// Ícono representativo de cada categoría para el placeholder.
  static const _categoryIcons = {
    'GASTRONOMIA':    Icons.restaurant,
    'TECNOLOGIA':     Icons.computer,
    'ARTESANIAS':     Icons.handyman,
    'SERVICIOS':      Icons.build,
    'MODA':           Icons.checkroom,
    'SALUD':          Icons.health_and_safety,
    'EDUCACION':      Icons.school,
    'TURISMO':        Icons.travel_explore,
    'ENTRETENIMIENTO':Icons.theater_comedy,
    'OTROS':          Icons.store,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final filter = ref.read(businessFilterProvider);
    ref.read(businessFilterProvider.notifier).state = filter.copyWith(
      query: value,
      clearQuery: value.isEmpty,
    );
  }

  void _onCategoryTap(String? category) {
    final filter = ref.read(businessFilterProvider);
    if (filter.category == category) {
      ref.read(businessFilterProvider.notifier).state =
          filter.copyWith(clearCategory: true);
    } else {
      ref.read(businessFilterProvider.notifier).state =
          filter.copyWith(category: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessListProvider);
    final currentFilter = ref.watch(businessFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Directorio')),
      body: Column(
        children: [
          // ── Buscador ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.sm,
              AppDimensions.screenPaddingH,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Buscar negocios...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.sm,
                ),
              ),
            ),
          ),

          // ── Chips de categoría ──────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.sm,
              ),
              itemCount: _categories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.xs),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = currentFilter.category == cat;
                return FilterChip(
                  label: Text(
                    _categoryLabels[cat] ?? cat,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _onCategoryTap(cat),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

          // ── Lista de negocios ───────────────────────
          Expanded(
            child: businessesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    const Text('No se pudieron cargar los negocios.'),
                    const SizedBox(height: AppDimensions.md),
                    TextButton.icon(
                      onPressed: () =>
                          ref.invalidate(businessListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (paginated) {
                if (paginated.businesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store_outlined,
                            size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'No se encontraron negocios',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (currentFilter.category != null ||
                            currentFilter.query != null)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(businessFilterProvider.notifier)
                                  .state = const BusinessFilter();
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(businessListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(
                        AppDimensions.screenPaddingH),
                    itemCount: paginated.businesses.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      return _BusinessCard(
                        business: paginated.businesses[index],
                        categoryIcon:
                            _categoryIcons[paginated.businesses[index].category]
                            ?? Icons.store,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Business Card ─────────────────────────────────────────

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.business, required this.categoryIcon});
  final Business business;
  final IconData categoryIcon;

  @override
  Widget build(BuildContext context) {
    final hasImage = business.images.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.businessDetail,
            pathParameters: {'slug': business.slug},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen o placeholder de categoría ────
            if (hasImage)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: business.images.first,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => _CategoryPlaceholder(
                    icon: categoryIcon,
                    height: 160,
                  ),
                  errorWidget: (_, _, _) => _CategoryPlaceholder(
                    icon: categoryIcon,
                    height: 160,
                  ),
                ),
              )
            else
              // Placeholder con ícono de categoría cuando no hay imagen
              _CategoryPlaceholder(icon: categoryIcon, height: 120),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Categoría + Verificado ──────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                        ),
                        child: Text(
                          business.category,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (business.isVerified) ...[
                        const SizedBox(width: AppDimensions.sm),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),

                  // ── Nombre ──────────────────────────
                  Text(
                    business.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.xs),

                  // ── Descripción ─────────────────────
                  Text(
                    business.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.sm),

                  // ── Ubicación ───────────────────────
                  if (business.city != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${business.city}'
                          '${business.state != null ? ', ${business.state}' : ''}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder de categoría ──────────────────────────────

class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder({required this.icon, required this.height});
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primaryDark.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Icon(
        icon,
        size: 48,
        color: AppColors.primary.withValues(alpha: 0.45),
      ),
    );
  }
}
