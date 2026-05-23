import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppDimensions.md),
              const Text('No se pudo cargar el empleo.'),
              const SizedBox(height: AppDimensions.md),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(jobDetailProvider(jobId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (job) => _JobDetailBody(job: job),
      ),
    );
  }
}

class _JobDetailBody extends StatelessWidget {
  const _JobDetailBody({required this.job});
  final JobDetail job;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postedDate = DateFormat('MMMM d, yyyy').format(job.createdAt);
    final expiresDate = DateFormat('MMMM d, yyyy').format(job.expiresAt);

    return CustomScrollView(
      slivers: [
        // ── App Bar ─────────────────────────────────
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              job.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade700,
                    Colors.red.shade400,
                  ],
                ),
              ),
              child: const Center(
                child:
                    Icon(Icons.work, size: 64, color: Colors.white24),
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
                // ── Tags ──────────────────────────────
                Wrap(
                  spacing: AppDimensions.sm,
                  runSpacing: AppDimensions.xs,
                  children: [
                    Chip(
                      avatar:
                          const Icon(Icons.category, size: 14),
                      label: Text(job.category,
                          style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      avatar: const Icon(Icons.location_on, size: 14),
                      label: Text(job.location,
                          style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      avatar: const Icon(Icons.schedule, size: 14),
                      label: Text(job.jobType,
                          style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      avatar: Icon(Icons.attach_money,
                          size: 14, color: Colors.green.shade700),
                      label: Text(
                        '\$${job.hourlyRate.toStringAsFixed(2)} AUD/hr',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (job.isVerified)
                      Chip(
                        avatar: Icon(Icons.verified,
                            size: 14, color: Colors.green.shade600),
                        label: const Text('Verified',
                            style: TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Dates ─────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Posted',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary)),
                              const SizedBox(height: 2),
                              Text(postedDate,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.textTertiary
                              .withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppDimensions.md),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Expires',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.textTertiary)),
                                const SizedBox(height: 2),
                                Text(expiresDate,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Description ───────────────────────
                Text(
                  'Job Description',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  job.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Contact / Apply ───────────────────
                Text(
                  'Apply',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),

                if (job.externalLink != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launch(job.externalLink!),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Apply Online'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
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

                if (job.email != null) ...[
                  const SizedBox(height: AppDimensions.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launch('mailto:${job.email}'),
                      icon: const Icon(Icons.email_outlined),
                      label: Text('Email: ${job.email}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],

                if (job.phone != null) ...[
                  const SizedBox(height: AppDimensions.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _launch('tel:${job.phone}'),
                      icon: const Icon(Icons.phone_outlined),
                      label: Text('Call: ${job.phone}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.lg),

                // ── Community Note ────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                        color: Colors.blue.shade100),
                  ),
                  child: Text(
                    'Found this job through Latin Territory? Mention it when you apply!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
