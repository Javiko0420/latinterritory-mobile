import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/category_filter_chips.dart';

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(jobFilterProvider.notifier).setQuery(
          value.isEmpty ? null : value,
        );
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);
    final currentFilter = ref.watch(jobFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Empleos')),
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
                hintText: 'Buscar empleos...',
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
            vertical: CategoryVertical.job,
            selectedValue: currentFilter.category,
            onChanged: (value) =>
                ref.read(jobFilterProvider.notifier).setCategory(value),
          ),

          // ── Job List ────────────────────────────────
          Expanded(
            child: jobsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    const Text('No se pudieron cargar los empleos.'),
                    const SizedBox(height: AppDimensions.md),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(jobListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (paginated) {
                if (paginated.jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_off_outlined,
                            size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'No hay empleos disponibles',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (currentFilter.category != null ||
                            currentFilter.query != null)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(jobFilterProvider.notifier).clear();
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(jobListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(
                        AppDimensions.screenPaddingH),
                    itemCount: paginated.jobs.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      return _JobCard(job: paginated.jobs[index]);
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

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final Job job;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'Hace un momento';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return DateFormat('d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.jobDetail,
            pathParameters: {'id': job.id},
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.latinSkyBlue,
                          AppColors.secondary,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: const Icon(Icons.work_outline,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(job.createdAt),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.isVerified)
                    Icon(Icons.verified,
                        size: 18, color: Colors.green.shade600),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Tags ────────────────────────────────
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.xs,
                children: [
                  _Tag(
                    icon: Icons.category_outlined,
                    label: job.category,
                  ),
                  _Tag(
                    icon: Icons.location_on_outlined,
                    label: job.location,
                  ),
                  _Tag(
                    icon: Icons.schedule,
                    label: job.jobType,
                  ),
                  _Tag(
                    icon: Icons.attach_money,
                    label: '\$${job.hourlyRate.toStringAsFixed(0)}/hr',
                    color: Colors.green.shade700,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Description Preview ─────────────────
              Text(
                job.description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color ?? AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color ?? AppColors.textTertiary,
            fontWeight: color != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
