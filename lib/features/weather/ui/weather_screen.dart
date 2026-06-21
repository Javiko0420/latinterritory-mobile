import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/weather/data/models/weather_models.dart';
import 'package:latinterritory/features/weather/providers/weather_providers.dart';
import 'package:latinterritory/features/weather/ui/weather_icon.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Pantalla de Clima (design system). Acento: azul.
/// Reusa `weatherProvider` (ciudad de `selectedCityProvider`). No cambia datos.
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  // Card oscura (fija en ambos temas) + sol dorado.
  static const _ink = Color(0xFFF1EDE3);
  static const _sun = Color(0xFFE6B84D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final city = ref.watch(selectedCityProvider);
    final async = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: RefreshIndicator(
            color: c.gold,
            onRefresh: () async => ref.invalidate(weatherProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LTSpace.screenH, LTSpace.x4, LTSpace.screenH, LTSpace.screenBottom,
              ),
              children: [
                _Header(eyebrow: 'CLIMA', title: 'El tiempo', accent: c.blue),
                const SizedBox(height: LTSpace.x4),
                _CitySelector(selected: city),
                const SizedBox(height: LTSpace.x4),
                async.when(
                  loading: () => const _Loader(),
                  error: (_, __) => _ErrorBox(
                    onRetry: () => ref.invalidate(weatherProvider),
                  ),
                  data: (bundle) => _WeatherBody(city: city, bundle: bundle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherBody extends StatelessWidget {
  const _WeatherBody({required this.city, required this.bundle});

  final WeatherCity city;
  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final cur = bundle.current;
    final temps = bundle.next24h.map((h) => h.temperatureC);
    final maxT = (temps.isEmpty ? cur.temperatureC : temps.reduce((a, b) => a > b ? a : b)).round();
    final minT = (temps.isEmpty ? cur.temperatureC : temps.reduce((a, b) => a < b ? a : b)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(city: city, current: cur, maxT: maxT, minT: minT),
        const SizedBox(height: LTSpace.x5),
        if (bundle.next24h.isNotEmpty) ...[
          Text('POR HORA', style: LTType.eyebrow(c.blue)),
          const SizedBox(height: 5),
          Text('Próximas horas', style: LTType.title(c.ink)),
          const SizedBox(height: 12),
          _HourlyRow(hours: bundle.next24h),
          const SizedBox(height: LTSpace.x5),
        ],
        Text('CONDICIONES', style: LTType.eyebrow(c.blue)),
        const SizedBox(height: 5),
        Text('Ahora mismo', style: LTType.title(c.ink)),
        const SizedBox(height: 12),
        _ConditionsCard(current: cur),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.city,
    required this.current,
    required this.maxT,
    required this.minT,
  });

  final WeatherCity city;
  final CurrentWeather current;
  final int maxT;
  final int minT;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LTBrand.night, Color(0xFF16273F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: c.softShadow,
      ),
      child: Column(
        children: [
          Text(
            '${city.name.toUpperCase()}${city.country != null ? ', ${city.country!.toUpperCase()}' : ''}',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: WeatherScreen._ink.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(weatherIconFor(current.weatherCode), size: 46, color: WeatherScreen._sun),
              const SizedBox(width: 10),
              Text(
                '${current.temperatureC.round()}°',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 62,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -3,
                  height: 1,
                  color: WeatherScreen._ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            current.weatherTextEs,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: WeatherScreen._ink.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Máx $maxT° · Mín $minT° · Sensación ${current.feelsLikeC.round()}°',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: WeatherScreen._ink.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyRow extends StatelessWidget {
  const _HourlyRow({required this.hours});

  final List<HourlyPoint> hours;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: hours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final h = hours[i];
          final t = DateTime.tryParse(h.time);
          final label = t != null ? DateFormat('HH:mm').format(t) : '';
          return Container(
            width: 66,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: c.line),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(label, style: LTType.caption(c.ink2, size: 12)),
                Icon(weatherIconFor(h.weatherCode), size: 24, color: c.blue),
                Text(
                  '${h.temperatureC.round()}°',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.ink,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.current});

  final CurrentWeather current;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Row(
        children: [
          _Stat(icon: Icons.thermostat, label: 'Sensación', value: '${current.feelsLikeC.round()}°'),
          _divider(c),
          _Stat(icon: Icons.water_drop_outlined, label: 'Humedad', value: '${current.humidityPercent}%'),
          _divider(c),
          _Stat(icon: Icons.air, label: 'Viento', value: '${current.windSpeedKmh.round()} km/h'),
        ],
      ),
    );
  }

  Widget _divider(LTColors c) =>
      Container(width: 1, height: 36, color: c.line);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: c.blue),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: LTType.caption(c.ink3, size: 11)),
        ],
      ),
    );
  }
}

class _CitySelector extends ConsumerWidget {
  const _CitySelector({required this.selected});

  final WeatherCity selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: allWeatherCities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final city = allWeatherCities[i];
          final isSel = city.slug == selected.slug;
          return LtPressable(
            onTap: () => ref.read(selectedCityProvider.notifier).select(city),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? c.gold : c.card,
                borderRadius: BorderRadius.circular(LTRadius.pill),
                border: Border.all(color: isSel ? c.gold : c.line),
              ),
              child: Text(
                city.name,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSel ? LTBrand.onGold : c.ink2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Header / estados compartidos ──────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title, required this.accent});

  final String eyebrow;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Row(
      children: [
        LtPressable(
          onTap: () => context.go('/home'),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(LTRadius.md),
              border: Border.all(color: c.line),
            ),
            child: Icon(Icons.chevron_left, color: c.ink, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow, style: LTType.eyebrow(accent)),
            const SizedBox(height: 2),
            Text(title, style: LTType.display(c.ink, size: 26)),
          ],
        ),
      ],
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: c.gold),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('No pudimos cargar el clima.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(
            onTap: onRetry,
            child: Text(
              'Reintentar',
              style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
