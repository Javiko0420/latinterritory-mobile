import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Selector "¿Qué quieres publicar?" — abierto desde el FAB central del nav.
///
/// No contiene lógica de negocio: solo enruta a las pantallas de creación
/// existentes (negocio / empleo / evento), que mantienen su propio flujo y auth.
class LTPublishScreen extends ConsumerWidget {
  const LTPublishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: LtScreenIn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LTSpace.screenH,
              LTSpace.x4,
              LTSpace.screenH,
              LTSpace.screenBottom,
            ),
            children: [
              // Header: back + eyebrow + título
              Row(
                children: [
                  LtPressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(LTRadius.md),
                        border: Border.all(color: c.line),
                      ),
                      child: Icon(Icons.chevron_left, color: c.ink, size: 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LTSpace.x5),
              Text(tr(ref, 'publish.eyebrow'), style: LTType.eyebrow(c.goldText)),
              const SizedBox(height: 6),
              Text(tr(ref, 'publish.title'), style: LTType.display(c.ink)),
              const SizedBox(height: 8),
              Text(tr(ref, 'publish.subtitle'), style: LTType.body(c.ink2)),
              const SizedBox(height: LTSpace.x5),

              _PublishOption(
                icon: Icons.storefront_outlined,
                accent: c.gold,
                accentSoft: c.goldBg,
                title: tr(ref, 'publish.business'),
                description: tr(ref, 'publish.business_desc'),
                onTap: () => context.pushNamed(RouteNames.createBusiness),
              ),
              const SizedBox(height: LTSpace.x3),
              _PublishOption(
                icon: Icons.work_outline,
                accent: c.blue,
                accentSoft: c.blueSoft,
                title: tr(ref, 'publish.job'),
                description: tr(ref, 'publish.job_desc'),
                onTap: () => context.pushNamed(RouteNames.createJob),
              ),
              const SizedBox(height: LTSpace.x3),
              _PublishOption(
                icon: Icons.event_outlined,
                accent: c.coral,
                accentSoft: c.coralSoft,
                title: tr(ref, 'publish.event'),
                description: tr(ref, 'publish.event_desc'),
                onTap: () => context.pushNamed(RouteNames.createEvent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublishOption extends StatelessWidget {
  const _PublishOption({
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;

    return LtPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(LTSpace.x4),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(LTRadius.md),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: LTSpace.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: LTType.card(c.ink, size: 17)),
                  const SizedBox(height: 2),
                  Text(description, style: LTType.caption(c.ink2, size: 13)),
                ],
              ),
            ),
            const SizedBox(width: LTSpace.x2),
            Icon(Icons.chevron_right, color: c.ink3, size: 22),
          ],
        ),
      ),
    );
  }
}
