import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/category_filter_chips.dart';

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

  void _onSearch(String value) {
    ref.read(eventFilterProvider.notifier).setQuery(
          value.isEmpty ? null : value,
        );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventListProvider);
    final currentFilter = ref.watch(eventFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: Column(
        children: [
          // ── Search Bar (pill) ───────────────────────
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
                hintText: 'Buscar eventos...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textTertiary),
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
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // ── Category Chips ──────────────────────────
          CategoryFilterChips(
            vertical: CategoryVertical.event,
            selectedValue: currentFilter.category,
            onChanged: (value) =>
                ref.read(eventFilterProvider.notifier).setCategory(value),
          ),

          // ── Event List ──────────────────────────────
          Expanded(
            child: eventsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    const Text('No se pudieron cargar los eventos.'),
                    const SizedBox(height: AppDimensions.md),
                    TextButton.icon(
                      onPressed: () =>
                          ref.invalidate(eventListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (paginated) {
                if (paginated.events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'No hay eventos próximos',
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
                                  .read(eventFilterProvider.notifier)
                                  .clear();
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(eventListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(
                        AppDimensions.screenPaddingH),
                    itemCount: paginated.events.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      return _EventCard(event: paginated.events[index]);
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

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final isFree = event.ticketPrice == null || event.ticketPrice == 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.eventDetail,
            pathParameters: {'id': event.id},
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date Column ───────────────────────────
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.latinPurple,
                    AppColors.primary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(event.eventDate).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(event.eventDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    timeFormat.format(event.eventDate),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          child: Text(
                            event.category,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isFree
                              ? 'Gratis'
                              : '\$${event.ticketPrice!.toStringAsFixed(0)} AUD',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isFree
                                ? Colors.green.shade600
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),

                    // Title
                    Text(
                      event.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textTertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
