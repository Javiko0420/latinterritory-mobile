import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
          error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(jobDetailProvider(jobId))),
          data: (job) => _Body(job: job),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.job});

  final JobDetail job;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String get _initials {
    final parts = job.title.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(jobCategoriesProvider).when(
          data: (cats) => resolveCategory(job.category, cats).label(CategoryVertical.job, locale),
          loading: () => job.category,
          error: (_, __) => job.category,
        );

    return LtScreenIn(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x4, LTSpace.screenH, 36),
        children: [
          // ── Header ──────────────────────────────────────
          Row(
            children: [
              LtPressable(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(LTRadius.md), border: Border.all(color: c.line)),
                  child: Icon(Icons.chevron_left, color: c.ink, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Text('Detalle de empleo', style: LTType.body(c.ink2, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: LTSpace.x5),
          // ── Logo + título ───────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: c.blueSoft, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: Text(_initials, style: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w800, color: c.blue)),
                ),
                const SizedBox(height: 14),
                Text(job.title, textAlign: TextAlign.center, style: LTType.display(c.ink, size: 24)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: c.ink3),
                    const SizedBox(width: 4),
                    Text(job.location, style: LTType.caption(c.ink2, size: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Chips ───────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Chip(label: categoryLabel, bg: c.card2, fg: c.ink),
              _Chip(label: job.jobType, bg: c.card2, fg: c.ink),
              _Chip(label: 'A\$${job.hourlyRate.toStringAsFixed(0)}/h', bg: c.greenSoft, fg: c.green),
              if (job.isVerified) _Chip(label: 'Verificado', bg: c.goldBg, fg: c.goldText),
            ],
          ),
          const SizedBox(height: LTSpace.x5),
          // ── Fechas ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(LTRadius.md), border: Border.all(color: c.line), boxShadow: c.softShadow),
            child: Row(
              children: [
                _DateCol(label: 'Publicado', value: DateFormat('d MMM yyyy', 'es').format(job.createdAt)),
                Container(width: 1, height: 34, color: c.line),
                _DateCol(label: 'Expira', value: DateFormat('d MMM yyyy', 'es').format(job.expiresAt)),
              ],
            ),
          ),
          const SizedBox(height: LTSpace.x5),
          // ── Descripción ─────────────────────────────────
          Text('Descripción', style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink)),
          const SizedBox(height: 8),
          Text(job.description, style: LTType.body(c.ink2)),
          const SizedBox(height: LTSpace.x5),
          // ── Postular ────────────────────────────────────
          Text('Postular', style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink)),
          const SizedBox(height: 10),
          ..._applyButtons(c),
          const SizedBox(height: LTSpace.x5),
          // ── Nota comunidad ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.blueSoft, borderRadius: BorderRadius.circular(LTRadius.md)),
            child: Text(
              '¿Encontraste este empleo en Latin Territory? Menciónalo al postular.',
              textAlign: TextAlign.center,
              style: LTType.caption(c.blue, size: 13, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _applyButtons(LTColors c) {
    // Lista de métodos disponibles; el primero va como CTA dorado, el resto secundario.
    final actions = <({IconData icon, String label, String url})>[
      if (job.externalLink != null) (icon: Icons.open_in_new, label: 'Postular en línea', url: job.externalLink!),
      if (job.email != null) (icon: Icons.email_outlined, label: 'Enviar correo', url: 'mailto:${job.email}'),
      if (job.phone != null) (icon: Icons.phone_outlined, label: 'Llamar', url: 'tel:${job.phone}'),
    ];
    if (actions.isEmpty) {
      return [Text('Sin datos de contacto para postular.', style: LTType.body(c.ink3))];
    }
    return [
      for (var i = 0; i < actions.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        _ApplyButton(icon: actions[i].icon, label: actions[i].label, primary: i == 0, onTap: () => _launch(actions[i].url)),
      ],
    ];
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.icon, required this.label, required this.primary, required this.onTap});

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final bg = primary ? c.gold : c.card;
    final fg = primary ? LTBrand.onGold : c.ink;
    return LtPressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(LTRadius.md),
          border: primary ? null : Border.all(color: c.line),
          boxShadow: primary ? c.softShadow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
          ],
        ),
      ),
    );
  }
}

class _DateCol extends StatelessWidget {
  const _DateCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: LTType.eyebrow(c.ink3)),
          const SizedBox(height: 3),
          Text(value, style: LTType.body(c.ink, size: 14, weight: FontWeight.w700)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LTRadius.pill)),
      child: Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
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
          Text('No pudimos cargar el empleo.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
