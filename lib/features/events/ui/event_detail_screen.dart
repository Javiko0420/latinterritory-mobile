import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppDimensions.md),
              const Text('No se pudo cargar el evento.'),
              const SizedBox(height: AppDimensions.md),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(eventDetailProvider(eventId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (event) => _EventDetailBody(event: event),
      ),
    );
  }
}

class _EventDetailBody extends ConsumerWidget {
  const _EventDetailBody({required this.event});
  final EventDetail event;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(eventCategoriesProvider).when(
          data: (cats) => resolveCategory(event.category, cats)
              .label(CategoryVertical.event, locale),
          loading: () => event.category,
          error: (_, __) => event.category,
        );
    final dateFormat = DateFormat("EEEE d 'de' MMMM, yyyy", 'en');
    final timeFormat = DateFormat('h:mm a');
    final isFree = event.ticketPrice == null || event.ticketPrice == 0;

    return CustomScrollView(
      slivers: [
        // ── Hero Image ──────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: event.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: event.imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.darken,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade600,
                          Colors.red.shade500,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.event,
                          size: 64, color: Colors.white54),
                    ),
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date & Time Card ──────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade600,
                                Colors.red.shade500,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMM')
                                    .format(event.eventDate)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('d').format(event.eventDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormat.format(event.eventDate),
                                style: context.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeFormat.format(event.eventDate),
                                style:
                                    context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Location ──────────────────────────
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.blue.withValues(alpha: 0.1),
                      child: const Icon(Icons.location_on,
                          color: Colors.blue),
                    ),
                    title: const Text('Location',
                        style: TextStyle(fontSize: 12)),
                    subtitle: Text(
                      event.location,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => _launch(
                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}'),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Category + Price ──────────────────
                Row(
                  children: [
                    Chip(
                      avatar: const Icon(Icons.category, size: 14),
                      label: Text(categoryLabel,
                          style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Chip(
                      avatar: Icon(
                        isFree ? Icons.celebration : Icons.attach_money,
                        size: 14,
                        color: isFree ? Colors.green : null,
                      ),
                      label: Text(
                        isFree
                            ? 'Free'
                            : '\$${event.ticketPrice!.toStringAsFixed(2)} AUD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFree ? Colors.green.shade700 : null,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Description ───────────────────────
                Text(
                  'About this event',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  event.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Organizer ─────────────────────────
                Text(
                  'Organizer',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        (event.organizer.name ?? 'A')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      event.organizer.name ?? 'Anonymous',
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Ticket Button ─────────────────────
                if (event.ticketLink != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launch(event.ticketLink!),
                      icon: const Icon(Icons.confirmation_num),
                      label: const Text('Buy Tickets'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Latin Territory does not sell tickets. Purchases are handled by the organizer.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
