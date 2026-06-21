import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/weather/providers/weather_providers.dart';
import 'package:latinterritory/features/weather/ui/weather_icon.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Mini-tarjeta de clima para Home (card azul noche). Datos reales del
/// [weatherProvider] (ciudad de [selectedCityProvider]). Tap → /weather.
class LTWeatherWidget extends ConsumerWidget {
  const LTWeatherWidget({super.key, this.width = 160});

  final double width;

  // Texto claro sobre la card oscura (fijo en ambos temas).
  static const _ink = Color(0xFFF1EDE3);
  static const _sun = Color(0xFFE6B84D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final city = ref.watch(selectedCityProvider);
    final async = ref.watch(weatherProvider);

    return LtPressable(
      onTap: () => context.go('/weather'),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LTBrand.night, Color(0xFF16273F)],
          ),
          borderRadius: BorderRadius.circular(LTRadius.tile),
          boxShadow: c.softShadow,
        ),
        child: async.when(
          loading: () => _shell(
            city.name,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _ink),
              ),
            ),
            Icons.cloud_outlined,
          ),
          error: (_, __) => _shell(
            city.name,
            Text('—', style: _tempStyle()),
            Icons.cloud_off_outlined,
          ),
          data: (bundle) {
            final temp = bundle.current.temperatureC.round();
            final temps = bundle.next24h.map((h) => h.temperatureC);
            final min = (temps.isEmpty ? bundle.current.temperatureC : temps.reduce((a, b) => a < b ? a : b)).round();
            final max = (temps.isEmpty ? bundle.current.temperatureC : temps.reduce((a, b) => a > b ? a : b)).round();
            return _shell(
              city.name,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$temp°', style: _tempStyle()),
                  const SizedBox(height: 2),
                  Text(
                    '${bundle.current.weatherTextEs} · $min° / $max°',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
              weatherIconFor(bundle.current.weatherCode),
            );
          },
        ),
      ),
    );
  }

  TextStyle _tempStyle() => GoogleFonts.hankenGrotesk(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1,
        color: _ink,
      );

  Widget _shell(String cityName, Widget body, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                cityName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: _ink.withValues(alpha: 0.7),
                ),
              ),
            ),
            Icon(icon, size: 22, color: _sun),
          ],
        ),
        const SizedBox(height: 14),
        body,
      ],
    );
  }
}
