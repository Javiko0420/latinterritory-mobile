import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(businessDetailProvider(slug));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppDimensions.md),
              const Text('No se pudo cargar el negocio.'),
              const SizedBox(height: AppDimensions.md),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(businessDetailProvider(slug)),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (biz) => _BusinessDetailBody(business: biz),
      ),
    );
  }
}

class _BusinessDetailBody extends StatelessWidget {
  const _BusinessDetailBody({required this.business});
  final BusinessDetail business;

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero Image ──────────────────────────────
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              business.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
            background: business.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: business.images.first,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.3),
                    colorBlendMode: BlendMode.darken,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.store, size: 64, color: Colors.white54),
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
                // ── Category + Verified + Rating ──────
                Wrap(
                  spacing: AppDimensions.sm,
                  runSpacing: AppDimensions.xs,
                  children: [
                    Chip(
                      label: Text(business.category,
                          style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (business.isVerified)
                      Chip(
                        avatar: Icon(Icons.verified,
                            size: 14, color: Colors.green.shade600),
                        label: const Text('Verified',
                            style: TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (business.averageRating != null)
                      Chip(
                        avatar: const Icon(Icons.star,
                            size: 14, color: Colors.amber),
                        label: Text(
                          '${business.averageRating} (${business.reviewsCount})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Location ─────────────────────────
                if (business.city != null || business.address != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [business.address, business.city, business.state]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(', '),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppDimensions.lg),

                // ── Description ──────────────────────
                Text(
                  'About',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  business.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Contact Buttons ──────────────────
                Text(
                  'Contact',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),

                if (business.whatsapp != null)
                  _ContactTile(
                    icon: Icons.chat,
                    iconColor: Colors.green,
                    label: 'WhatsApp',
                    value: business.whatsapp!,
                    onTap: () => _launch(
                        'https://wa.me/${business.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}'),
                  ),
                if (business.phone != null)
                  _ContactTile(
                    icon: Icons.phone,
                    iconColor: Colors.blue,
                    label: 'Call',
                    value: business.phone!,
                    onTap: () => _launch('tel:${business.phone}'),
                  ),
                if (business.email != null)
                  _ContactTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    label: 'Email',
                    value: business.email!,
                    onTap: () => _launch('mailto:${business.email}'),
                  ),
                if (business.website != null)
                  _ContactTile(
                    icon: Icons.language,
                    iconColor: Colors.blue,
                    label: 'Website',
                    value: business.website!,
                    onTap: () => _launch(business.website!),
                  ),
                if (business.instagram != null)
                  _ContactTile(
                    icon: Icons.camera_alt_outlined,
                    iconColor: Colors.pink,
                    label: 'Instagram',
                    value: '@${business.instagram!.replaceAll(RegExp(r'^@'), '')}',
                    onTap: () => _launch(
                        'https://instagram.com/${business.instagram!.replaceAll(RegExp(r'^@'), '')}'),
                  ),

                // ── Gallery ──────────────────────────
                if (business.images.length > 1) ...[
                  const SizedBox(height: AppDimensions.lg),
                  Text(
                    'Gallery',
                    style: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: business.images.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppDimensions.sm),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                          child: CachedNetworkImage(
                            imageUrl: business.images[index],
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // ── Products ─────────────────────────
                if (business.products.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.lg),
                  Text(
                    'Products & Services',
                    style: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  ...business.products.map((product) => Card(
                        child: ListTile(
                          leading: product.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: product.image!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                          title: Text(product.name),
                          subtitle: Text(
                            product.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: product.price != null
                              ? Text(
                                  '\$${product.price!.toStringAsFixed(2)} ${product.currency}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      )),
                ],

                // ── Reviews ──────────────────────────
                const SizedBox(height: AppDimensions.lg),
                Text(
                  'Reviews (${business.reviewsCount})',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.sm),

                if (business.reviews.isEmpty)
                  Text(
                    'No reviews yet.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  )
                else
                  ...business.reviews.map((review) => _ReviewCard(
                        review: review,
                      )),

                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppColors.secondary.withValues(alpha: 0.12),
                  child: Text(
                    (review.user.name ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    review.user.name ?? 'Anonymous',
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              review.comment,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
