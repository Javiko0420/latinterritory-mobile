import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/features/profile/providers/my_publications_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class MyPublicationsScreen extends ConsumerStatefulWidget {
  const MyPublicationsScreen({super.key});

  @override
  ConsumerState<MyPublicationsScreen> createState() =>
      _MyPublicationsScreenState();
}

class _MyPublicationsScreenState
    extends ConsumerState<MyPublicationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Publicaciones',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Negocios'),
            Tab(text: 'Eventos'),
            Tab(text: 'Empleos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BusinessesTab(),
          _EventsTab(),
          _JobsTab(),
        ],
      ),
    );
  }
}

// ── Tab: Negocios ─────────────────────────────────────────

class _BusinessesTab extends ConsumerWidget {
  const _BusinessesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myBusinessesProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(myBusinessesProvider),
      child: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(myBusinessesProvider),
        ),
        data: (businesses) => businesses.isEmpty
            ? const _EmptyBody(
                icon: Icons.store_outlined,
                message: 'Aún no tienes negocios publicados.\nTira hacia abajo para actualizar.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                itemCount: businesses.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, i) => _BusinessCard(
                  business: businesses[i],
                  onEdit: () async {
                    await context.pushNamed(
                      RouteNames.editBusiness,
                      pathParameters: {'slug': businesses[i].slug},
                    );
                    ref.invalidate(myBusinessesProvider);
                  },
                  onDelete: () async {
                    final confirmed = await _confirmDelete(
                        context, businesses[i].name);
                    if (!confirmed) return;
                    try {
                      final repo = ref.read(businessRepositoryProvider);
                      await repo.deleteBusiness(businesses[i].id);
                      ref.invalidate(myBusinessesProvider);
                      if (context.mounted) {
                        context.showSnackBar('Negocio eliminado.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showErrorSnackBar(
                            'No se pudo eliminar el negocio.');
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({
    required this.business,
    required this.onEdit,
    required this.onDelete,
  });

  final Business business;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _PublicationCard(
      icon: Icons.store_outlined,
      iconColor: AppColors.primary,
      title: business.name,
      subtitle: business.category,
      dateLabel: business.createdAt != null
          ? DateFormat("d MMM yyyy", 'es').format(business.createdAt!)
          : '',
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ── Tab: Eventos ─────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myEventsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(myEventsProvider),
      child: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(myEventsProvider),
        ),
        data: (events) => events.isEmpty
            ? const _EmptyBody(
                icon: Icons.event_outlined,
                message: 'Aún no tienes eventos publicados.\nTira hacia abajo para actualizar.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                itemCount: events.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, i) => _EventCard(
                  event: events[i],
                  onEdit: () async {
                    await context.pushNamed(
                      RouteNames.editEvent,
                      pathParameters: {'id': events[i].id},
                    );
                    ref.invalidate(myEventsProvider);
                  },
                  onDelete: () async {
                    final confirmed = await _confirmDelete(
                        context, events[i].title);
                    if (!confirmed) return;
                    try {
                      final repo = ref.read(eventRepositoryProvider);
                      await repo.deleteEvent(events[i].id);
                      ref.invalidate(myEventsProvider);
                      if (context.mounted) {
                        context.showSnackBar('Evento eliminado.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showErrorSnackBar(
                            'No se pudo eliminar el evento.');
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _PublicationCard(
      icon: Icons.event_outlined,
      iconColor: AppColors.latinPurple,
      title: event.title,
      subtitle: event.category,
      dateLabel: DateFormat("d MMM yyyy, HH:mm", 'es').format(event.eventDate),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ── Tab: Empleos ─────────────────────────────────────────

class _JobsTab extends ConsumerWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myJobsProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(myJobsProvider),
      child: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          onRetry: () => ref.invalidate(myJobsProvider),
        ),
        data: (jobs) => jobs.isEmpty
            ? const _EmptyBody(
                icon: Icons.work_outline,
                message: 'Aún no tienes empleos publicados.\nTira hacia abajo para actualizar.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                itemCount: jobs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.sm),
                itemBuilder: (context, i) => _JobCard(
                  job: jobs[i],
                  onEdit: () async {
                    await context.pushNamed(
                      RouteNames.editJob,
                      pathParameters: {'id': jobs[i].id},
                    );
                    ref.invalidate(myJobsProvider);
                  },
                  onDelete: () async {
                    final confirmed = await _confirmDelete(
                        context, jobs[i].title);
                    if (!confirmed) return;
                    try {
                      final repo = ref.read(jobRepositoryProvider);
                      await repo.deleteJob(jobs[i].id);
                      ref.invalidate(myJobsProvider);
                      if (context.mounted) {
                        context.showSnackBar('Empleo eliminado.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showErrorSnackBar(
                            'No se pudo eliminar el empleo.');
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({
    required this.job,
    required this.onEdit,
    required this.onDelete,
  });

  final Job job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(jobCategoriesProvider).when(
          data: (cats) => resolveCategory(job.category, cats)
              .label(CategoryVertical.job, locale),
          loading: () => job.category,
          error: (_, __) => job.category,
        );
    return _PublicationCard(
      icon: Icons.work_outline,
      iconColor: AppColors.latinSkyBlue,
      title: job.title,
      subtitle: '$categoryLabel · ${job.location}',
      dateLabel: DateFormat("d MMM yyyy", 'es').format(job.createdAt),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ── Shared: Publication Card ──────────────────────────────

class _PublicationCard extends StatelessWidget {
  const _PublicationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.border;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Column(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                color: AppColors.primary,
                tooltip: 'Editar',
                onTap: onEdit,
              ),
              const SizedBox(height: 4),
              _ActionButton(
                icon: Icons.delete_outline,
                color: AppColors.error,
                tooltip: 'Eliminar',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ── Shared: Empty & Error ─────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 56,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppDimensions.md),
          Text(
            'No se pudo cargar tus publicaciones.',
            style: GoogleFonts.dmSans(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.lg),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ── Dialog de confirmación ────────────────────────────────

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text(
        '¿Estás seguro de que quieres eliminar "$name"? Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => ctx.pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => ctx.pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
