import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/shared/widgets/category_filter_chips.dart';
import 'package:latinterritory/shared/widgets/lt_cards.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Eventos (design system). Reusa `eventListProvider` + filtros. Tab.
class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final async = ref.watch(eventListProvider);
    final filter = ref.watch(eventFilterProvider);
    final localeCode = ref.watch(localeProvider).languageCode;

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
                    Text('AGENDA CULTURAL', style: LTType.eyebrow(c.coral)),
                    const SizedBox(height: 4),
                    Text('Eventos', style: LTType.display(c.ink)),
                    const SizedBox(height: LTSpace.x4),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => ref.read(eventFilterProvider.notifier).setQuery(v.isEmpty ? null : v),
                      onClear: () {
                        _searchController.clear();
                        ref.read(eventFilterProvider.notifier).setQuery(null);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              CategoryFilterChips(
                vertical: CategoryVertical.event,
                selectedValue: filter.category,
                onChanged: (value) => ref.read(eventFilterProvider.notifier).setCategory(value),
              ),
              Expanded(
                child: async.when(
                  loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                  error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(eventListProvider)),
                  data: (paginated) {
                    if (paginated.events.isEmpty) {
                      return _EmptyState(
                        hasFilters: filter.category != null || filter.query != null,
                        onClear: () {
                          _searchController.clear();
                          ref.read(eventFilterProvider.notifier).clear();
                        },
                      );
                    }
                    return RefreshIndicator(
                      color: c.gold,
                      onRefresh: () async => ref.invalidate(eventListProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 14, LTSpace.screenH, 16),
                        itemCount: paginated.events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, i) {
                          final e = paginated.events[i];
                          return LtEventCard(
                            event: e,
                            localeCode: localeCode,
                            onTap: () => context.pushNamed(RouteNames.eventDetail, pathParameters: {'id': e.id}),
                          );
                        },
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
        hintText: 'Buscar eventos',
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
            decoration: BoxDecoration(color: c.coralSoft, borderRadius: BorderRadius.circular(LTRadius.lg)),
            child: Icon(Icons.event_outlined, size: 30, color: c.coral),
          ),
          const SizedBox(height: 14),
          Text('No hay eventos disponibles', style: LTType.card(c.ink, size: 16)),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            LtPressable(onTap: onClear, child: Text('Limpiar filtros', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
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
          Text('No pudimos cargar los eventos.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
