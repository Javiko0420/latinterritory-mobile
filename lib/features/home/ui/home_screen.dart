import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/features/exchange/ui/lt_exchange_rate_widget.dart';
import 'package:latinterritory/features/forums/ui/lt_forum_widget.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/features/sports/ui/lt_sports_widget.dart';
import 'package:latinterritory/features/weather/ui/lt_weather_widget.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_cards.dart';
import 'package:latinterritory/shared/widgets/lt_category_shortcut.dart';
import 'package:latinterritory/shared/widgets/lt_eq_bars.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';
import 'package:latinterritory/shared/widgets/lt_search_bar.dart';
import 'package:latinterritory/shared/widgets/lt_section_header.dart';

/// Home — design system "Latin Territory".
///
/// Solo presentación: reusa los providers existentes (negocios destacados,
/// empleos, eventos próximos, auth) y las rutas actuales. No cambia lógica.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h < 12) return 'home.greeting_morning';
    if (h < 19) return 'home.greeting_afternoon';
    return 'home.greeting_evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final user = ref.watch(authStateProvider).value?.user;
    final firstName = (user?.name?.trim().isNotEmpty ?? false)
        ? user!.name!.trim().split(RegExp(r'\s+')).first
        : null;
    final greeting = tr(ref, _greetingKey()) + (firstName != null ? ', $firstName' : '');

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LTSpace.screenH,
              LTSpace.x4,
              LTSpace.screenH,
              24,
            ),
            children: [
              // ── Header ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: LTType.body(c.ink2)),
                        const SizedBox(height: 3),
                        Text(tr(ref, 'home.hero_title'), style: LTType.display(c.ink)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (user != null)
                    LtAvatar(
                      name: user.name ?? user.email,
                      size: 44,
                      onTap: () => context.go('/profile'),
                    )
                  else
                    LtPressable(
                      onTap: () => context.pushNamed(RouteNames.login),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(LTRadius.pill),
                          border: Border.all(color: c.line),
                        ),
                        child: Text(
                          tr(ref, 'auth.login'),
                          style: LTType.caption(c.ink, size: 13, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: LTSpace.x5),

              // ── Search ──────────────────────────────────────
              LtSearchBar(
                hint: tr(ref, 'home.search_hint'),
                onTap: () => context.go('/businesses'),
              ),
              const SizedBox(height: LTSpace.x5),

              // ── Accesos rápidos ─────────────────────────────
              const _Shortcuts(),
              const SizedBox(height: LTSpace.x5),

              // ── Servicios ───────────────────────────────────
              const _Services(),
              const SizedBox(height: 28),

              // ── Negocios destacados ─────────────────────────
              LtSectionHeader(
                eyebrow: tr(ref, 'home.eyebrow_directory'),
                title: tr(ref, 'home.featured_businesses'),
                accent: c.goldText,
                actionLabel: tr(ref, 'home.see_all'),
                onAction: () => context.go('/businesses'),
              ),
              const SizedBox(height: 14),
              const _BusinessesCarousel(),
              const SizedBox(height: 28),

              // ── Empleos recientes ───────────────────────────
              LtSectionHeader(
                eyebrow: tr(ref, 'home.eyebrow_opportunities'),
                title: tr(ref, 'home.recent_jobs'),
                accent: c.blue,
                actionLabel: tr(ref, 'home.see_all'),
                onAction: () => context.go('/jobs'),
              ),
              const SizedBox(height: 14),
              const _JobsList(),
              const SizedBox(height: 28),

              // ── Eventos próximos ────────────────────────────
              LtSectionHeader(
                eyebrow: tr(ref, 'home.eyebrow_agenda'),
                title: tr(ref, 'home.upcoming_events'),
                accent: c.coral,
                actionLabel: tr(ref, 'home.see_agenda'),
                onAction: () => context.go('/events'),
              ),
              const SizedBox(height: 14),
              const _EventsFeatured(),
              const SizedBox(height: 24),

              // ── Foro del día ────────────────────────────────
              const LTForumWidget(),

              // ── Radio ───────────────────────────────────────
              const _RadioCard(),
              const SizedBox(height: 16),

              // ── CTA Publicar ────────────────────────────────
              const _PublishCta(),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Accesos rápidos
// ════════════════════════════════════════════════════════════

class _Shortcuts extends ConsumerWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final items = [
      (Icons.storefront_outlined, tr(ref, 'nav.directory'), c.gold, c.goldBg, '/businesses'),
      (Icons.work_outline, tr(ref, 'nav.jobs'), c.blue, c.blueSoft, '/jobs'),
      (Icons.event_outlined, tr(ref, 'nav.events'), c.coral, c.coralSoft, '/events'),
      (Icons.forum_outlined, tr(ref, 'nav.forums'), c.green, c.greenSoft, '/forums'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final it in items)
          LtCategoryShortcut(
            icon: it.$1,
            label: it.$2,
            accent: it.$3,
            accentSoft: it.$4,
            onTap: () => context.go(it.$5),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Servicios (clima / tasas / deportes)
// ════════════════════════════════════════════════════════════

class _Services extends StatelessWidget {
  const _Services();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: const [
          LTWeatherWidget(),
          SizedBox(width: 12),
          LTExchangeRateWidget(),
          SizedBox(width: 12),
          LTSportsWidget(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Negocios destacados
// ════════════════════════════════════════════════════════════

class _BusinessesCarousel extends ConsumerWidget {
  const _BusinessesCarousel();

  static const _height = 202.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(featuredBusinessesProvider);

    return async.when(
      loading: () => const _LoaderBox(height: _height),
      error: (_, __) => _MessageBox(
        height: _height,
        message: tr(ref, 'home.featured_businesses_error'),
        actionLabel: tr(ref, 'home.retry'),
        onAction: () => ref.invalidate(featuredBusinessesProvider),
      ),
      data: (businesses) {
        if (businesses.isEmpty) {
          return _MessageBox(
            height: _height,
            message: tr(ref, 'home.featured_businesses_empty'),
          );
        }
        return SizedBox(
          height: _height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: businesses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, i) {
              final b = businesses[i];
              return LtBusinessCard(
                business: b,
                onTap: () => context.pushNamed(
                  RouteNames.businessDetail,
                  pathParameters: {'slug': b.slug},
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Empleos recientes
// ════════════════════════════════════════════════════════════

class _JobsList extends ConsumerWidget {
  const _JobsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(jobListProvider);

    return async.when(
      loading: () => const _LoaderBox(height: 120),
      error: (_, __) => _MessageBox(
        height: 120,
        message: tr(ref, 'home.recent_jobs_error'),
        actionLabel: tr(ref, 'home.retry'),
        onAction: () => ref.invalidate(jobListProvider),
      ),
      data: (paginated) {
        final jobs = paginated.jobs.take(3).toList();
        if (jobs.isEmpty) {
          return _MessageBox(height: 120, message: tr(ref, 'home.recent_jobs_empty'));
        }
        return Column(
          children: [
            for (var i = 0; i < jobs.length; i++) ...[
              if (i > 0) const SizedBox(height: 11),
              LtJobCard(
                job: jobs[i],
                onTap: () => context.pushNamed(
                  RouteNames.jobDetail,
                  pathParameters: {'id': jobs[i].id},
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Eventos próximos (destacado)
// ════════════════════════════════════════════════════════════

class _EventsFeatured extends ConsumerWidget {
  const _EventsFeatured();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingEventsProvider);
    final localeCode = ref.watch(localeProvider).languageCode;

    return async.when(
      loading: () => const _LoaderBox(height: 188),
      error: (_, __) => _MessageBox(
        height: 120,
        message: tr(ref, 'home.upcoming_events_error'),
        actionLabel: tr(ref, 'home.retry'),
        onAction: () => ref.invalidate(upcomingEventsProvider),
      ),
      data: (events) {
        if (events.isEmpty) {
          return _MessageBox(height: 120, message: tr(ref, 'home.upcoming_events_empty'));
        }
        final event = events.first;
        return LtEventCard(
          event: event,
          localeCode: localeCode,
          onTap: () => context.pushNamed(
            RouteNames.eventDetail,
            pathParameters: {'id': event.id},
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Radio (card coral)
// ════════════════════════════════════════════════════════════

class _RadioCard extends ConsumerWidget {
  const _RadioCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return LtPressable(
      onTap: () => context.go('/radio'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.coral, const Color(0xFFA8442F)],
          ),
          borderRadius: BorderRadius.circular(LTRadius.lg),
          boxShadow: c.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const LtEqBars(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(ref, 'home.radio_live'),
                    style: LTType.eyebrow(Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 3),
                  Text(tr(ref, 'home.radio_title'), style: LTType.card(Colors.white, size: 16)),
                  const SizedBox(height: 2),
                  Text(
                    tr(ref, 'home.radio_desc'),
                    style: LTType.caption(Colors.white.withValues(alpha: 0.82), size: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: c.coral, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CTA Publicar (gradiente azul noche)
// ════════════════════════════════════════════════════════════

class _PublishCta extends ConsumerWidget {
  const _PublishCta();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LTBrand.night, Color(0xFF16273F)],
        ),
        borderRadius: BorderRadius.circular(LTRadius.lg),
        boxShadow: c.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(ref, 'home.cta_title'),
            style: LTType.card(const Color(0xFFF1EDE3), size: 19),
          ),
          const SizedBox(height: 6),
          Text(
            tr(ref, 'home.cta_desc'),
            style: LTType.body(const Color(0xFFF1EDE3).withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          LtPressable(
            onTap: () => context.pushNamed(RouteNames.publish),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                color: LTBrand.gold,
                borderRadius: BorderRadius.circular(LTRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr(ref, 'home.cta_button'),
                    style: LTType.card(LTBrand.onGold, size: 14.5),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 17, color: LTBrand.onGold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Estados auxiliares (loader / mensaje)
// ════════════════════════════════════════════════════════════

class _LoaderBox extends StatelessWidget {
  const _LoaderBox({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: c.gold),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.height,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final double height;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: LTType.caption(c.ink2, size: 13),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            LtPressable(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: LTType.caption(c.gold, size: 13, weight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
