import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/radio/data/models/radio_models.dart';
import 'package:latinterritory/features/radio/providers/radio_player_provider.dart';
import 'package:latinterritory/features/radio/providers/radio_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

// ── Países disponibles (sin emoji; código + etiqueta) ─────
class _Country {
  const _Country(this.code, this.label);
  final String code;
  final String label;
}

const _countries = [
  _Country('CO', 'Colombia'),
  _Country('AU', 'Australia'),
  _Country('MX', 'México'),
  _Country('AR', 'Argentina'),
  _Country('ES', 'España'),
];

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

  // ── Lógica del player intacta ───────────────────────────
  Future<void> _playStation(RadioStation station, List<RadioStation> contextStations) async {
    try {
      await ref.read(radioPlayerProvider.notifier).playApiStation(
            station,
            screenSize: MediaQuery.sizeOf(context),
            contextStations: contextStations,
          );
    } catch (e) {
      debugPrint('[Radio] Error al reproducir "${station.name}": $e');
      debugPrint('[Radio] URL: ${station.streamUrl}');
      ref.read(isPlayingProvider.notifier).set(false);
      if (mounted) {
        final msg = kDebugMode ? 'Error: $e' : 'No se pudo conectar a la emisora. Intenta con otra.';
        context.showErrorSnackBar(msg);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final query = ref.watch(radioSearchQueryProvider);
    final isSearching = query.trim().isNotEmpty;

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
                    Row(
                      children: [
                        LtPressable(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(LTRadius.md), border: Border.all(color: c.line)),
                            child: Icon(Icons.chevron_left, color: c.ink, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EN VIVO', style: LTType.eyebrow(c.coral)),
                              const SizedBox(height: 2),
                              Text('Radio', style: LTType.display(c.ink, size: 26)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: LTSpace.x4),
                    _SearchField(
                      controller: _searchController,
                      onChanged: (v) => ref.read(radioSearchQueryProvider.notifier).update(v),
                      onClear: () {
                        _searchController.clear();
                        ref.read(radioSearchQueryProvider.notifier).clear();
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              if (!isSearching) _CountryChips(),
              const SizedBox(height: 4),
              Expanded(
                child: isSearching ? _SearchResults(onTap: _playStation) : _PopularStations(onTap: _playStation),
              ),
            ],
          ),
        ),
      ),
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
      textInputAction: TextInputAction.search,
      style: LTType.body(c.ink),
      decoration: InputDecoration(
        hintText: 'Buscar emisoras',
        hintStyle: LTType.body(c.ink3),
        prefixIcon: Icon(Icons.search, color: c.ink3, size: 20),
        suffixIcon: controller.text.isNotEmpty ? IconButton(icon: Icon(Icons.close, color: c.ink3, size: 18), onPressed: onClear) : null,
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

// ── Country chips ─────────────────────────────────────────

class _CountryChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final selected = ref.watch(selectedCountryProvider);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: LTSpace.screenH),
        itemCount: _countries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final country = _countries[i];
          final isSel = country.code == selected;
          return LtPressable(
            onTap: () => ref.read(selectedCountryProvider.notifier).select(country.code),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? c.coral : c.card,
                borderRadius: BorderRadius.circular(LTRadius.pill),
                border: Border.all(color: isSel ? c.coral : c.line),
              ),
              child: Text(
                country.label,
                style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: isSel ? Colors.white : c.ink2),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Listas ────────────────────────────────────────────────

class _PopularStations extends ConsumerWidget {
  const _PopularStations({required this.onTap});
  final Future<void> Function(RadioStation, List<RadioStation>) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(popularStationsProvider);
    return async.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
      error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(popularStationsProvider)),
      data: (stations) {
        if (stations.isEmpty) return const _EmptyState(message: 'No hay emisoras para este país.');
        return RefreshIndicator(
          color: c.gold,
          onRefresh: () async => ref.invalidate(popularStationsProvider),
          child: _StationGrid(stations: stations, onTap: onTap),
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.onTap});
  final Future<void> Function(RadioStation, List<RadioStation>) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(searchStationsProvider);
    return async.when(
      loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
      error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(searchStationsProvider)),
      data: (stations) {
        if (stations.isEmpty) return const _EmptyState(message: 'No se encontraron emisoras.\nIntenta con otro término.');
        return _StationGrid(stations: stations, onTap: onTap);
      },
    );
  }
}

class _StationGrid extends ConsumerWidget {
  const _StationGrid({required this.stations, required this.onTap});
  final List<RadioStation> stations;
  final Future<void> Function(RadioStation, List<RadioStation>) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentStationProvider);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 10, LTSpace.screenH, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: stations.length,
      itemBuilder: (context, i) {
        final station = stations[i];
        return _StationCard(
          station: station,
          playing: current?.id == station.id,
          onTap: () => onTap(station, stations),
        );
      },
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.station, required this.playing, required this.onTap});

  final RadioStation station;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LTMotion.press,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: playing ? c.coral : c.line, width: playing ? 2 : 1),
          boxShadow: playing
              ? [BoxShadow(color: c.coral.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 5))]
              : c.softShadow,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (station.logoUrl != null && station.logoUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: station.logoUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _logoPh(c),
                        )
                      : _logoPh(c),
                ),
                if (playing)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: c.coral, shape: BoxShape.circle),
                    child: const Icon(Icons.graphic_eq, color: Colors.white, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              station.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: FontWeight.w800, color: playing ? c.coral : c.ink),
            ),
            const SizedBox(height: 3),
            if (station.country != null || station.codec != null)
              Text(
                [if (station.country != null) station.country!, if (station.codec != null) station.codec!.toUpperCase()].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LTType.caption(c.ink3, size: 10.5),
              ),
            const Spacer(),
            if (station.tags.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: station.tags.take(2).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: c.coralSoft, borderRadius: BorderRadius.circular(LTRadius.pill)),
                    child: Text(tag, style: GoogleFonts.hankenGrotesk(fontSize: 9.5, fontWeight: FontWeight.w700, color: c.coral)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _logoPh(LTColors c) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.radio, size: 28, color: c.ink3),
      );
}

// ── Estados ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

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
            decoration: BoxDecoration(color: c.coralSoft, borderRadius: BorderRadius.circular(LTRadius.lg)),
            child: Icon(Icons.radio_outlined, size: 30, color: c.coral),
          ),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center, style: LTType.body(c.ink2)),
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
          Icon(Icons.wifi_off, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('Error al cargar las emisoras.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
