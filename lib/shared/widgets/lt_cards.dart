import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/businesses/data/business_category_utils.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/events/data/event_category_utils.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

// ════════════════════════════════════════════════════════════
//  LtBusinessCard — card de negocio (carrusel / grid)
// ════════════════════════════════════════════════════════════

class LtBusinessCard extends ConsumerWidget {
  const LtBusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    this.width = 200,
    this.rating,
  });

  final Business business;
  final VoidCallback onTap;
  final double width;

  /// Rating opcional (el modelo de lista [Business] no lo trae; se pasa solo
  /// cuando hay dato disponible).
  final double? rating;

  String? get _imageUrl {
    if (business.images.isNotEmpty) return business.images.first;
    return business.logoUrl;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(businessCategoriesProvider).when(
          data: (cats) => resolveCategory(business.category, cats)
              .label(CategoryVertical.business, locale),
          loading: () => business.category,
          error: (_, __) => business.category,
        );
    final accent = BusinessCategoryUtils.accentColorFor(business.category);
    final icon = BusinessCategoryUtils.iconFor(business.category);
    final rating = this.rating;

    return LtPressable(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(LTRadius.lg)),
              child: SizedBox(
                height: 108,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Cover(imageUrl: _imageUrl, accent: accent, icon: icon),
                    if (rating != null && rating > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _RatingBadge(rating: rating),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LTType.card(c.ink, size: 16),
                  ),
                  if ((business.city ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: c.ink3),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            business.city!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LTType.caption(c.ink2, size: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LtJobCard — card de empleo (lista compacta)
// ════════════════════════════════════════════════════════════

class LtJobCard extends StatelessWidget {
  const LtJobCard({super.key, required this.job, required this.onTap});

  final Job job;
  final VoidCallback onTap;

  String get _initials {
    final parts = job.title.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final pay = 'A\$${job.hourlyRate.toStringAsFixed(0)}/h';

    return LtPressable(
      onTap: onTap,
      child: Container(
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: c.blueSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: c.blue,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LTType.card(c.ink, size: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LTType.caption(c.ink2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pay,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.jobType,
                  style: LTType.caption(c.ink3, size: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LtEventCard — card de evento (cover full-bleed)
// ════════════════════════════════════════════════════════════

class LtEventCard extends StatelessWidget {
  const LtEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.localeCode = 'es',
    this.height = 188,
  });

  final Event event;
  final VoidCallback onTap;
  final String localeCode;
  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = EventCategoryUtils.accentColorFor(event.category);
    final day = event.eventDate.day.toString();
    final month = DateFormat('MMM', localeCode).format(event.eventDate).toUpperCase();

    return LtPressable(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LTRadius.lg),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Cover(imageUrl: event.imageUrl, accent: accent, icon: Icons.celebration),
              // overlay oscuro inferior
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xB80F0C08), Color(0x000F0C08)],
                    stops: [0.08, 0.58],
                  ),
                ),
              ),
              // chip de fecha
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  width: 50,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: const Color(0xFF1A1916),
                        ),
                      ),
                      Text(
                        month,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // pill categoría
              Positioned(
                top: 18,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x6B140C08),
                    borderRadius: BorderRadius.circular(LTRadius.pill),
                  ),
                  child: Text(
                    event.category,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // título + ubicación
              Positioned(
                left: 16,
                right: 16,
                bottom: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.38,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cover compartido (imagen o placeholder con gradiente del acento) ──
class _Cover extends StatelessWidget {
  const _Cover({required this.imageUrl, required this.accent, required this.icon});

  final String? imageUrl;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 34, color: Colors.white.withValues(alpha: 0.92)),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x6B140C08),
        borderRadius: BorderRadius.circular(LTRadius.pill),
      ),
      child: Text(
        '★ ${rating.toStringAsFixed(1)}',
        style: GoogleFonts.hankenGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
