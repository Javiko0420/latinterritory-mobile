import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/radio/data/models/radio_models.dart';
import 'package:latinterritory/features/radio/providers/radio_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

// ── Países disponibles ────────────────────────────────────

class _Country {
  const _Country(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}

const _countries = [
  _Country('CO', 'Colombia', '🇨🇴'),
  _Country('AU', 'Australia', '🇦🇺'),
  _Country('MX', 'México', '🇲🇽'),
  _Country('AR', 'Argentina', '🇦🇷'),
  _Country('ES', 'España', '🇪🇸'),
];

// ── Pantalla ──────────────────────────────────────────────

class RadioScreen extends ConsumerStatefulWidget {
  const RadioScreen({super.key});

  @override
  ConsumerState<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends ConsumerState<RadioScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(radioSearchQueryProvider.notifier).update(value);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(radioSearchQueryProvider.notifier).clear();
  }

  Future<void> _playStation(RadioStation station) async {
    try {
      ref.read(currentStationProvider.notifier).set(station);
      ref.read(isPlayingProvider.notifier).set(true);
      await ref.read(radioPlayerServiceProvider).play(station.streamUrl);
    } catch (e) {
      // Log del error real para facilitar debugging
      debugPrint('[Radio] Error al reproducir "${station.name}": $e');
      debugPrint('[Radio] URL: ${station.streamUrl}');

      ref.read(isPlayingProvider.notifier).set(false);
      if (mounted) {
        // En debug muestra el error técnico; en release mensaje amigable
        final msg = kDebugMode
            ? 'Error: $e'
            : 'No se pudo conectar a la emisora. Intenta con otra.';
        context.showErrorSnackBar(msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(radioSearchQueryProvider);
    final isSearching = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.radio,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Radio en Vivo',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar emisoras...',
                hintStyle: GoogleFonts.dmSans(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Chips de países ───────────────────────────
          if (!isSearching) _CountryChips(),

          const SizedBox(height: 4),

          // ── Lista de estaciones ───────────────────────
          Expanded(
            child: isSearching
                ? _SearchResults(onTap: _playStation)
                : _PopularStations(onTap: _playStation),
          ),
        ],
      ),
    );
  }
}

// ── Chips de países ───────────────────────────────────────

class _CountryChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCountryProvider);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _countries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _countries[i];
          final isSelected = c.code == selected;
          return FilterChip(
            label: Text(
              '${c.flag} ${c.label}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(selectedCountryProvider.notifier).select(c.code),
            selectedColor: AppColors.primary,
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
            showCheckmark: false,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
            ),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ── Estaciones populares ──────────────────────────────────

class _PopularStations extends ConsumerWidget {
  const _PopularStations({required this.onTap});
  final Future<void> Function(RadioStation) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularStationsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(popularStationsProvider),
      ),
      data: (stations) {
        if (stations.isEmpty) {
          return const _EmptyState(
            message: 'No hay emisoras disponibles para este país.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(popularStationsProvider),
          child: _StationGrid(stations: stations, onTap: onTap),
        );
      },
    );
  }
}

// ── Resultados de búsqueda ────────────────────────────────

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.onTap});
  final Future<void> Function(RadioStation) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchStationsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(searchStationsProvider),
      ),
      data: (stations) {
        if (stations.isEmpty) {
          return const _EmptyState(
            message: 'No se encontraron emisoras.\nIntenta con otro término.',
          );
        }
        return _StationGrid(stations: stations, onTap: onTap);
      },
    );
  }
}

// ── Grid de estaciones ────────────────────────────────────

class _StationGrid extends ConsumerWidget {
  const _StationGrid({required this.stations, required this.onTap});
  final List<RadioStation> stations;
  final Future<void> Function(RadioStation) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentStationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: stations.length,
      itemBuilder: (context, i) {
        final station = stations[i];
        final isPlaying = current?.id == station.id;
        return _StationCard(
          station: station,
          isPlaying: isPlaying,
          isDark: isDark,
          onTap: () => onTap(station),
        );
      },
    );
  }
}

// ── Card de estación ──────────────────────────────────────

class _StationCard extends ConsumerWidget {
  const _StationCard({
    required this.station,
    required this.isPlaying,
    required this.isDark,
    required this.onTap,
  });

  final RadioStation station;
  final bool isPlaying;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isPlaying
        ? AppColors.primary
        : isDark
            ? AppColors.darkBorder
            : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: borderColor,
            width: isPlaying ? 2 : 1,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Logo ────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: station.logoUrl != null &&
                          station.logoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: station.logoUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: (context, error, _) =>
                              _StationLogoPlaceholder(isDark: isDark),
                        )
                      : _StationLogoPlaceholder(isDark: isDark),
                ),
                if (isPlaying)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Nombre ───────────────────────────────────
            Text(
              station.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPlaying
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // ── País + codec ─────────────────────────────
            if (station.country != null || station.codec != null)
              Text(
                [
                  if (station.country != null) station.country!,
                  if (station.codec != null) station.codec!.toUpperCase(),
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                ),
              ),

            const Spacer(),

            // ── Tags ─────────────────────────────────────
            if (station.tags.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: station.tags.take(2).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _StationLogoPlaceholder extends StatelessWidget {
  const _StationLogoPlaceholder({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.radio,
        size: 28,
        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
      ),
    );
  }
}

// ── Estados vacío y error ─────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radio_outlined,
            size: 64,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Error al cargar las emisoras.',
            style: GoogleFonts.dmSans(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
