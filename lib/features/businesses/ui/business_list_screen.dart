import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/businesses/data/business_category_utils.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/shared/widgets/category_filter_chips.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Directorio (design system). Reusa `businessListProvider` + filtros. Tab.
class BusinessListScreen extends ConsumerStatefulWidget {
  const BusinessListScreen({super.key});

  @override
  ConsumerState<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final async = ref.watch(businessListProvider);
    final filter = ref.watch(businessFilterProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x4, LTSpace.screenH, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DIRECTORIO LATINO', style: LTType.eyebrow(c.goldText)),
                    const SizedBox(height: 4),
                    Text('Negocios', style: LTType.display(c.ink)),
                    const SizedBox(height: LTSpace.x4),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => ref.read(businessFilterProvider.notifier).setQuery(v),
                      onClear: () {
                        _searchController.clear();
                        ref.read(businessFilterProvider.notifier).setQuery(null);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              CategoryFilterChips(
                vertical: CategoryVertical.business,
                selectedValue: filter.category,
                onChanged: (value) =>
                    ref.read(businessFilterProvider.notifier).setCategory(value),
              ),
              Expanded(
                child: async.when(
                  loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                  error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(businessListProvider)),
                  data: (paginated) {
                    if (paginated.businesses.isEmpty) {
                      return _EmptyState(
                        hasFilters: filter.category != null || filter.query != null,
                        onClear: () {
                          _searchController.clear();
                          ref.read(businessFilterProvider.notifier).clear();
                        },
                      );
                    }
                    return RefreshIndicator(
                      color: c.gold,
                      onRefresh: () async => ref.invalidate(businessListProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 14, LTSpace.screenH, 16),
                        itemCount: paginated.businesses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _BizTile(business: paginated.businesses[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search field ──────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: LTType.body(c.ink),
      decoration: InputDecoration(
        hintText: 'Buscar negocios',
        hintStyle: LTType.body(c.ink3),
        prefixIcon: Icon(Icons.search, color: c.ink3, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(icon: Icon(Icons.close, color: c.ink3, size: 18), onPressed: onClear)
            : null,
        filled: true,
        fillColor: c.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.md), borderSide: BorderSide(color: c.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.md), borderSide: BorderSide(color: c.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(LTRadius.md), borderSide: BorderSide(color: c.gold, width: 1.5)),
      ),
    );
  }
}

// ── Business tile (fila horizontal) ───────────────────────

class _BizTile extends ConsumerWidget {
  const _BizTile({required this.business});

  final Business business;

  String? get _imageUrl => business.images.isNotEmpty ? business.images.first : business.logoUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(businessCategoriesProvider).when(
          data: (cats) => resolveCategory(business.category, cats).label(CategoryVertical.business, locale),
          loading: () => business.category,
          error: (_, __) => business.category,
        );
    final accent = BusinessCategoryUtils.accentColorFor(business.category);
    final icon = BusinessCategoryUtils.iconFor(business.category);
    final area = [business.city, business.state].where((s) => s != null && s.isNotEmpty).join(', ');
    final img = _imageUrl;

    return LtPressable(
      onTap: () => context.pushNamed(RouteNames.businessDetail, pathParameters: {'slug': business.slug}),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                width: 72,
                height: 72,
                child: img != null
                    ? CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _ph(accent, icon),
                        errorWidget: (_, __, ___) => _ph(accent, icon),
                      )
                    : _ph(accent, icon),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    categoryLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: accent),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(child: Text(business.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.card(c.ink, size: 16.5))),
                      if (business.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 15, color: c.green),
                      ],
                    ],
                  ),
                  if (area.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: c.ink3),
                        const SizedBox(width: 3),
                        Expanded(child: Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2, size: 12.5))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph(Color accent, IconData icon) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, accent.withValues(alpha: 0.6)],
          ),
        ),
        child: Center(child: Icon(icon, size: 28, color: Colors.white.withValues(alpha: 0.92))),
      );
}

// ── Estados ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters, required this.onClear});

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: c.goldBg, borderRadius: BorderRadius.circular(LTRadius.lg)),
            child: Icon(Icons.storefront_outlined, size: 30, color: c.gold),
          ),
          const SizedBox(height: 14),
          Text('No se encontraron negocios', style: LTType.card(c.ink, size: 16)),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            LtPressable(
              onTap: onClear,
              child: Text('Limpiar filtros', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('No pudimos cargar los negocios.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
