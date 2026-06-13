import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/businesses/data/business_category_utils.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/categories/application/category_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/events/data/event_category_utils.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/shared/widgets/lt_andean_pattern.dart';

/// "El Periódico" home — V2 design.
///
/// Hero banner with brand gradient + Andean overlay, scrollable category
/// chips, horizontal businesses carousel and a vertical events list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          'LatinTerritory',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.pushNamed(RouteNames.login),
              child: const Text('Iniciar Sesión'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _HeroBanner(),
          const SizedBox(height: 20),
          const _CategoryChips(),
          const SizedBox(height: 24),
          _SectionHeader(titleKey: 'home.featured_businesses'),
          const SizedBox(height: 12),
          const _BusinessesCarousel(),
          const SizedBox(height: 20),
          const _UtilitiesSection(),
          const SizedBox(height: 20),
          _SectionHeader(titleKey: 'home.upcoming_events'),
          const SizedBox(height: 12),
          const _EventsList(),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────

class _HeroBanner extends ConsumerWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final today = DateFormat("EEEE d 'de' MMMM", locale.languageCode)
        .format(DateTime.now());

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: AndeanPatternPainter(
                    color: AppColors.background,
                    opacity: 0.10,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    today.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      color: AppColors.background.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(ref, 'home.discover'),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/businesses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.primaryDark,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          textStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(tr(ref, 'home.explore')),
                      ),
                      OutlinedButton(
                        onPressed: () => context.pushNamed(RouteNames.register),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.background,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          side: BorderSide(
                            color: AppColors.background.withValues(alpha: 0.5),
                          ),
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          textStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(tr(ref, 'home.join_free')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chips ────────────────────────────────────────

class _CategoryChips extends StatefulWidget {
  const _CategoryChips();

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  static const _categories = [
    _CategoryChipData(label: 'Todos', path: null),
    _CategoryChipData(label: 'Negocios', path: '/businesses'),
    _CategoryChipData(label: 'Empleos', path: '/jobs'),
    _CategoryChipData(label: 'Eventos', path: '/events'),
    _CategoryChipData(label: 'Foros', path: '/forums'),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = i == _selected;
          return _Chip(
            label: cat.label,
            selected: selected,
            onTap: () {
              setState(() => _selected = i);
              if (cat.path != null) context.go(cat.path!);
            },
          );
        },
      ),
    );
  }
}

class _CategoryChipData {
  const _CategoryChipData({required this.label, this.path});
  final String label;
  final String? path;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.primary
        : isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.surfaceVariant;
    final fg = selected
        ? Colors.white
        : isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────

class _SectionHeader extends ConsumerWidget {
  const _SectionHeader({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      tr(ref, titleKey),
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// ── Businesses carousel ───────────────────────────────────

class _BusinessesCarousel extends ConsumerWidget {
  const _BusinessesCarousel();

  static const _carouselHeight = 168.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredBusinessesProvider);

    return featuredAsync.when(
      loading: () => const SizedBox(
        height: _carouselHeight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => _FeaturedMessage(
        height: _carouselHeight,
        message: tr(ref, 'home.featured_businesses_error'),
        actionLabel: tr(ref, 'home.retry'),
        onAction: () => ref.invalidate(featuredBusinessesProvider),
      ),
      data: (businesses) {
        if (businesses.isEmpty) {
          return _FeaturedMessage(
            height: _carouselHeight,
            message: tr(ref, 'home.featured_businesses_empty'),
          );
        }

        return SizedBox(
          height: _carouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: businesses.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FeaturedBusinessCard(business: businesses[index]);
            },
          ),
        );
      },
    );
  }
}

class _FeaturedMessage extends StatelessWidget {
  const _FeaturedMessage({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturedBusinessCard extends ConsumerWidget {
  const _FeaturedBusinessCard({required this.business});

  final Business business;

  String? get _imageUrl {
    if (business.images.isNotEmpty) return business.images.first;
    return business.logoUrl;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeProvider);
    final categoryLabel = ref.watch(businessCategoriesProvider).when(
      data: (cats) => resolveCategory(business.category, cats)
          .label(CategoryVertical.business, locale),
      loading: () => business.category,
      error: (_, __) => business.category,
    );
    final categoryIcon = BusinessCategoryUtils.iconFor(business.category);
    final accentColor =
        BusinessCategoryUtils.accentColorFor(business.category);
    final imageUrl = _imageUrl;

    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteNames.businessDetail,
          pathParameters: {'slug': business.slug},
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLg),
              ),
              child: SizedBox(
                height: 84,
                width: double.infinity,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _FeaturedImageFallback(
                          icon: categoryIcon,
                          color: accentColor,
                        ),
                        errorWidget: (_, _, _) => _FeaturedImageFallback(
                          icon: categoryIcon,
                          color: accentColor,
                        ),
                      )
                    : _FeaturedImageFallback(
                        icon: categoryIcon,
                        color: accentColor,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedImageFallback extends StatelessWidget {
  const _FeaturedImageFallback({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.6)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 32,
        color: Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

// ── Events list ───────────────────────────────────────────

class _EventsList extends ConsumerWidget {
  const _EventsList();

  static const _listMinHeight = 120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingEventsProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final dateFormat = DateFormat('EEE d MMM', locale);

    return upcomingAsync.when(
      loading: () => const SizedBox(
        height: _listMinHeight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) => _FeaturedMessage(
        height: _listMinHeight,
        message: tr(ref, 'home.upcoming_events_error'),
        actionLabel: tr(ref, 'home.retry'),
        onAction: () => ref.invalidate(upcomingEventsProvider),
      ),
      data: (events) {
        if (events.isEmpty) {
          return _FeaturedMessage(
            height: _listMinHeight,
            message: tr(ref, 'home.upcoming_events_empty'),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          children: [
            for (var i = 0; i < events.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _UpcomingEventTile(
                event: events[i],
                dateLabel: _formatEventDate(dateFormat, events[i].eventDate),
                accentColor:
                    EventCategoryUtils.accentColorFor(events[i].category),
                isDark: isDark,
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatEventDate(DateFormat dateFormat, DateTime eventDate) {
    final formatted = dateFormat.format(eventDate);
    if (formatted.isEmpty) return formatted;
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({
    required this.event,
    required this.dateLabel,
    required this.accentColor,
    required this.isDark,
  });

  final Event event;
  final String dateLabel;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteNames.eventDetail,
          pathParameters: {'id': event.id},
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.celebration,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Utilities section ─────────────────────────────────────

class _UtilitiesSection extends ConsumerWidget {
  const _UtilitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'home.utilities'),
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _UtilityButton(
              icon: Icons.wb_sunny,
              label: tr(ref, 'home.weather'),
              color: AppColors.latinSkyBlue,
              onTap: () => context.go('/weather'),
            ),
            const SizedBox(width: 10),
            _UtilityButton(
              icon: Icons.currency_exchange,
              label: tr(ref, 'home.exchange'),
              color: AppColors.secondary,
              onTap: () => context.go('/exchange'),
            ),
            const SizedBox(width: 10),
            _UtilityButton(
              icon: Icons.sports_soccer,
              label: tr(ref, 'home.sports'),
              color: AppColors.latinRed,
              onTap: () => context.go('/sports'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _UtilityButton(
              icon: Icons.radio,
              label: tr(ref, 'home.radio'),
              color: AppColors.latinPurple,
              onTap: () => context.go('/radio'),
            ),
          ],
        ),
      ],
    );
  }
}

class _UtilityButton extends StatelessWidget {
  const _UtilityButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.border;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A1C1208),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
