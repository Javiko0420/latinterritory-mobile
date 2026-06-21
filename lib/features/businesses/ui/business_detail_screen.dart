import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/businesses/data/business_category_utils.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(businessDetailProvider(slug));

    return Scaffold(
      backgroundColor: c.bg,
      body: async.when(
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
        error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(businessDetailProvider(slug))),
        data: (biz) => _Body(business: biz),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.business});

  final BusinessDetail business;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(businessCategoriesProvider).when(
          data: (cats) => resolveCategory(business.category, cats).label(CategoryVertical.business, locale),
          loading: () => business.category,
          error: (_, __) => business.category,
        );
    final accent = BusinessCategoryUtils.accentColorFor(business.category);
    final area = [business.city, business.state].where((s) => s != null && s.isNotEmpty).join(', ');
    final mapsQuery = [business.address, business.city, business.state]
        .where((s) => s != null && s.isNotEmpty).join(', ');

    return LtScreenIn(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Cover + back ────────────────────────────────
          _Cover(business: business, accent: accent),
          // ── Info card (solapada) ────────────────────────
          Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LTSpace.screenH),
              child: Container(
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
                        Text(categoryLabel.toUpperCase(), style: LTType.eyebrow(accent)),
                        if (business.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.verified, size: 15, color: c.green),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(business.name, style: LTType.display(c.ink, size: 25)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (business.averageRating != null) ...[
                          Text('★ ${business.averageRating!.toStringAsFixed(1)}',
                              style: GoogleFonts.hankenGrotesk(fontSize: 14, fontWeight: FontWeight.w800, color: c.gold)),
                          const SizedBox(width: 6),
                          Text('${business.reviewsCount} reseñas', style: LTType.caption(c.ink2, size: 13)),
                          if (area.isNotEmpty) Text('  ·  ', style: LTType.caption(c.ink3, size: 13)),
                        ],
                        if (area.isNotEmpty)
                          Flexible(child: Text(area, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2, size: 13))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Actions(
                      phone: business.phone,
                      whatsapp: business.whatsapp,
                      mapsQuery: mapsQuery,
                      onLaunch: _launch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── Cuerpo ──────────────────────────────────────
          Transform.translate(
            offset: const Offset(0, -14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 0, LTSpace.screenH, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Sobre el negocio'),
                  const SizedBox(height: 8),
                  Text(business.description, style: LTType.body(c.ink2)),

                  // ── Contacto ──────────────────────────────
                  if (_hasContact) ...[
                    const SizedBox(height: 22),
                    _SectionTitle('Contacto'),
                    const SizedBox(height: 10),
                    if (business.email != null)
                      _ContactRow(icon: Icons.email_outlined, label: 'Email', value: business.email!, onTap: () => _launch('mailto:${business.email}')),
                    if (business.website != null)
                      _ContactRow(icon: Icons.language, label: 'Sitio web', value: business.website!, onTap: () => _launch(business.website!)),
                    if (business.instagram != null)
                      _ContactRow(
                        icon: Icons.camera_alt_outlined,
                        label: 'Instagram',
                        value: '@${business.instagram!.replaceAll(RegExp(r'^@'), '')}',
                        onTap: () => _launch('https://instagram.com/${business.instagram!.replaceAll(RegExp(r'^@'), '')}'),
                      ),
                  ],

                  // ── Galería ───────────────────────────────
                  if (business.images.length > 1) ...[
                    const SizedBox(height: 22),
                    _SectionTitle('Galería'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: business.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(imageUrl: business.images[i], width: 150, height: 110, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],

                  // ── Productos ─────────────────────────────
                  if (business.products.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    _SectionTitle('Productos y servicios'),
                    const SizedBox(height: 10),
                    for (final p in business.products) ...[
                      _ProductRow(product: p),
                      const SizedBox(height: 10),
                    ],
                  ],

                  // ── Reseñas ───────────────────────────────
                  const SizedBox(height: 22),
                  _SectionTitle('Reseñas (${business.reviewsCount})'),
                  const SizedBox(height: 10),
                  if (business.reviews.isEmpty)
                    Text('Aún no hay reseñas.', style: LTType.body(c.ink3))
                  else
                    for (final r in business.reviews) ...[
                      _ReviewCard(review: r),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasContact =>
      business.email != null || business.website != null || business.instagram != null;
}

// ── Cover ─────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  const _Cover({required this.business, required this.accent});

  final BusinessDetail business;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final img = business.images.isNotEmpty ? business.images.first : business.logoUrl;
    return SizedBox(
      height: 268,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (img != null)
            CachedNetworkImage(
              imageUrl: img,
              fit: BoxFit.cover,
              placeholder: (_, __) => _ph(),
              errorWidget: (_, __, ___) => _ph(),
            )
          else
            _ph(),
          // back button
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
        child: Center(child: Icon(BusinessCategoryUtils.iconFor(business.category), size: 54, color: Colors.white.withValues(alpha: 0.85))),
      );
}

// ── Acciones (Llamar / WhatsApp / Cómo llegar) ────────────

class _Actions extends StatelessWidget {
  const _Actions({required this.phone, required this.whatsapp, required this.mapsQuery, required this.onLaunch});

  final String? phone;
  final String? whatsapp;
  final String mapsQuery;
  final Future<void> Function(String) onLaunch;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final tiles = <Widget>[
      if (phone != null)
        _ActionTile(icon: Icons.phone_outlined, label: 'Llamar', accent: c.gold, soft: c.goldBg, onTap: () => onLaunch('tel:$phone')),
      if (whatsapp != null)
        _ActionTile(icon: Icons.chat_bubble_outline, label: 'WhatsApp', accent: c.green, soft: c.greenSoft, onTap: () => onLaunch('https://wa.me/${whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}')),
      if (mapsQuery.isNotEmpty)
        _ActionTile(icon: Icons.directions_outlined, label: 'Cómo llegar', accent: c.blue, soft: c.blueSoft, onTap: () => onLaunch('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}')),
    ];
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.accent, required this.soft, required this.onTap});

  final IconData icon;
  final String label;
  final Color accent;
  final Color soft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LtPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: accent)),
          ],
        ),
      ),
    );
  }
}

// ── Helpers UI ────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Text(text, style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink));
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, required this.value, required this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 18, color: c.ink2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: LTType.caption(c.ink3, size: 11.5)),
                  Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.body(c.ink, size: 14, weight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: c.ink3),
          ],
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          if (product.image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(imageUrl: product.image!, width: 46, height: 46, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.card(c.ink, size: 14.5)),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2, size: 12.5)),
                ],
              ],
            ),
          ),
          if (product.price != null) ...[
            const SizedBox(width: 10),
            Text('\$${product.price!.toStringAsFixed(2)} ${product.currency}',
                style: GoogleFonts.hankenGrotesk(fontSize: 13.5, fontWeight: FontWeight.w800, color: c.ink)),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.md),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LtAvatar(name: review.user.name ?? 'Anónimo', size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(review.user.name ?? 'Anónimo', style: LTType.body(c.ink, size: 14, weight: FontWeight.w700)),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: c.gold,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: LTType.body(c.ink2, size: 13.5)),
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
          Text('No pudimos cargar el negocio.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
