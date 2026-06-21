import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/widgets/category_filter_chips.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Empleos (design system). Reusa `jobListProvider` + filtros. Tab.
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

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final async = ref.watch(jobListProvider);
    final filter = ref.watch(jobFilterProvider);

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
                    Text('OPORTUNIDADES', style: LTType.eyebrow(c.blue)),
                    const SizedBox(height: 4),
                    Text('Empleos', style: LTType.display(c.ink)),
                    const SizedBox(height: LTSpace.x4),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => ref.read(jobFilterProvider.notifier).setQuery(v.isEmpty ? null : v),
                      onClear: () {
                        _searchController.clear();
                        ref.read(jobFilterProvider.notifier).setQuery(null);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              CategoryFilterChips(
                vertical: CategoryVertical.job,
                selectedValue: filter.category,
                onChanged: (value) => ref.read(jobFilterProvider.notifier).setCategory(value),
              ),
              Expanded(
                child: async.when(
                  loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                  error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(jobListProvider)),
                  data: (paginated) {
                    if (paginated.jobs.isEmpty) {
                      return _EmptyState(
                        hasFilters: filter.category != null || filter.query != null,
                        onClear: () {
                          _searchController.clear();
                          ref.read(jobFilterProvider.notifier).clear();
                        },
                      );
                    }
                    return RefreshIndicator(
                      color: c.gold,
                      onRefresh: () async => ref.invalidate(jobListProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 14, LTSpace.screenH, 16),
                        itemCount: paginated.jobs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _JobTile(job: paginated.jobs[i]),
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

// ── Job tile ──────────────────────────────────────────────

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job});

  final Job job;

  String get _initials {
    final parts = job.title.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'Hace un momento';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays}d';
    return DateFormat('d MMM', 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: () => context.pushNamed(RouteNames.jobDetail, pathParameters: {'id': job.id}),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: c.blueSoft, borderRadius: BorderRadius.circular(13)),
                  alignment: Alignment.center,
                  child: Text(_initials, style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: c.blue)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.card(c.ink, size: 16))),
                          if (job.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 15, color: c.green),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(job.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _Chip(label: job.jobType, bg: c.card2, fg: c.ink),
                const SizedBox(width: 8),
                _Chip(label: 'A\$${job.hourlyRate.toStringAsFixed(0)}/h', bg: c.greenSoft, fg: c.green),
                const Spacer(),
                Text(_timeAgo(job.createdAt), style: LTType.caption(c.ink3, size: 11.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LTRadius.pill)),
      child: Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
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
        hintText: 'Buscar empleos',
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
            decoration: BoxDecoration(color: c.blueSoft, borderRadius: BorderRadius.circular(LTRadius.lg)),
            child: Icon(Icons.work_outline, size: 30, color: c.blue),
          ),
          const SizedBox(height: 14),
          Text('No hay empleos disponibles', style: LTType.card(c.ink, size: 16)),
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
          Text('No pudimos cargar los empleos.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
