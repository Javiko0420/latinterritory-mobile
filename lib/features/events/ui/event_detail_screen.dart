import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:latinterritory/features/events/data/event_category_utils.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      backgroundColor: c.bg,
      body: async.when(
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
        error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(eventDetailProvider(eventId))),
        data: (event) => _Body(event: event),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.event});

  final EventDetail event;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(eventCategoriesProvider).when(
          data: (cats) => resolveCategory(event.category, cats).label(CategoryVertical.event, locale),
          loading: () => event.category,
          error: (_, __) => event.category,
        );
    final accent = EventCategoryUtils.accentColorFor(event.category);
    final isFree = event.ticketPrice == null || event.ticketPrice == 0;
    final fullDate = _cap(DateFormat("EEEE d 'de' MMMM, yyyy", 'es').format(event.eventDate));
    final time = DateFormat('HH:mm', 'es').format(event.eventDate);

    return LtScreenIn(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Cover(event: event, accent: accent),
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LTSpace.screenH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info card ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.line),
                      boxShadow: c.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(categoryLabel.toUpperCase(), style: LTType.eyebrow(accent))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: isFree ? c.greenSoft : c.goldBg,
                                borderRadius: BorderRadius.circular(LTRadius.pill),
                              ),
                              child: Text(
                                isFree ? 'Gratis' : '\$${event.ticketPrice!.toStringAsFixed(0)} AUD',
                                style: GoogleFonts.hankenGrotesk(fontSize: 11.5, fontWeight: FontWeight.w700, color: isFree ? c.green : c.goldText),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(event.title, style: LTType.display(c.ink, size: 25)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Fecha / hora ──────────────────────────
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    accent: accent,
                    title: fullDate,
                    subtitle: time,
                  ),
                  const SizedBox(height: 12),
                  // ── Ubicación (tap → maps) ────────────────
                  _InfoRow(
                    icon: Icons.place_outlined,
                    accent: c.blue,
                    title: event.location,
                    subtitle: 'Cómo llegar',
                    onTap: () => _launch('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}'),
                  ),
                  const SizedBox(height: 22),
                  // ── Descripción ───────────────────────────
                  Text('Sobre el evento', style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink)),
                  const SizedBox(height: 8),
                  Text(event.description, style: LTType.body(c.ink2)),
                  const SizedBox(height: 22),
                  // ── Organizador ───────────────────────────
                  Text('Organiza', style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      LtAvatar(name: event.organizer.name ?? 'Anónimo', size: 38),
                      const SizedBox(width: 12),
                      Text(event.organizer.name ?? 'Anónimo', style: LTType.body(c.ink, weight: FontWeight.w700)),
                    ],
                  ),
                  // ── Entradas ──────────────────────────────
                  if (event.ticketLink != null) ...[
                    const SizedBox(height: 22),
                    LtPressable(
                      onTap: () => _launch(event.ticketLink!),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: c.gold,
                          borderRadius: BorderRadius.circular(LTRadius.md),
                          boxShadow: c.softShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.confirmation_number_outlined, size: 18, color: LTBrand.onGold),
                            const SizedBox(width: 8),
                            Text('Comprar entradas', style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: LTBrand.onGold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latin Territory no vende entradas. La compra la gestiona el organizador.',
                      textAlign: TextAlign.center,
                      style: LTType.caption(c.ink3, size: 12),
                    ),
                  ],
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cover ─────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.event, required this.accent});

  final EventDetail event;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (event.imageUrl != null)
            CachedNetworkImage(imageUrl: event.imageUrl!, fit: BoxFit.cover, placeholder: (_, __) => _ph(), errorWidget: (_, __, ___) => _ph())
          else
            _ph(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 18,
            child: LtPressable(
              onTap: () => context.pop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                child: const Icon(Icons.chevron_left, color: Color(0xFF1A1916), size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ph() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, accent.withValues(alpha: 0.55)],
          ),
        ),
        child: Center(child: Icon(Icons.celebration_outlined, size: 54, color: Colors.white.withValues(alpha: 0.85))),
      );
}

// ── Info row card ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.accent, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: LTType.body(c.ink, size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: LTType.caption(c.ink2, size: 12.5)),
              ],
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, size: 20, color: c.ink3),
        ],
      ),
    );
    return onTap != null ? LtPressable(onTap: onTap, child: card) : card;
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
          Text('No pudimos cargar el evento.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
