import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/weather/data/models/weather_models.dart';
import 'package:latinterritory/features/weather/providers/weather_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: Column(
        children: [
          // ── City Selector ───────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.sm,
              ),
              itemCount: allWeatherCities.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimensions.xs),
              itemBuilder: (context, index) {
                final city = allWeatherCities[index];
                final isSelected = selectedCity.slug == city.slug;
                return FilterChip(
                  label: Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      ref.read(selectedCityProvider.notifier).select(city),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

          // ── Weather Content ─────────────────────────
          Expanded(
            child: weatherAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    const Text('Could not load weather.'),
                    const SizedBox(height: AppDimensions.md),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(weatherProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (bundle) => RefreshIndicator(
                onRefresh: () async => ref.invalidate(weatherProvider),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                  child: Column(
                    children: [
                      _CurrentWeatherCard(
                        city: selectedCity,
                        current: bundle.current,
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      _HourlyForecast(hours: bundle.next24h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.city, required this.current});
  final WeatherCity city;
  final CurrentWeather current;

  IconData _weatherIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny;
    if (code == 2) return Icons.cloud_queue;
    if (code == 3) return Icons.cloud;
    if (code >= 45 && code <= 48) return Icons.blur_on;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.umbrella;
    if (code >= 95) return Icons.flash_on;
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              '${city.name}, ${city.country}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Icon(
              _weatherIcon(current.weatherCode),
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              '${current.temperatureC.round()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w200,
              ),
            ),
            Text(
              current.weatherTextEs,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _WeatherStat(
                  icon: Icons.thermostat,
                  label: 'Feels like',
                  value: '${current.feelsLikeC.round()}°C',
                ),
                _WeatherStat(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${current.humidityPercent}%',
                ),
                _WeatherStat(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${current.windSpeedKmh.round()} km/h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HourlyForecast extends StatelessWidget {
  const _HourlyForecast({required this.hours});
  final List<HourlyPoint> hours;

  IconData _weatherIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny;
    if (code == 2) return Icons.cloud_queue;
    if (code == 3) return Icons.cloud;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80) return Icons.umbrella;
    return Icons.cloud;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next 24 Hours',
          style: context.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.sm),
            itemBuilder: (context, index) {
              final h = hours[index];
              final time = DateTime.tryParse(h.time);
              final label = time != null
                  ? DateFormat('HH:mm').format(time)
                  : '';

              return Container(
                width: 64,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.sm,
                  horizontal: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Icon(
                      _weatherIcon(h.weatherCode),
                      size: 22,
                      color: AppColors.primary,
                    ),
                    Text(
                      '${h.temperatureC.round()}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (h.precipitationMm > 0)
                      Text(
                        '${h.precipitationMm.toStringAsFixed(1)}mm',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.blue.shade600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
