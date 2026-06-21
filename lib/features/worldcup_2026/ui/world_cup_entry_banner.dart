import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/features/worldcup_2026/state/world_cup_providers.dart';
import 'package:latinterritory/features/worldcup_2026/ui/world_cup_screen.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Punto de entrada a la vista del Mundial dentro de Deportes.
/// Se auto-oculta cuando `worldCupVisible` es false (flag remoto o date-guard),
/// así Deportes queda idéntico a antes al apagarse la campaña.
class WorldCupEntryBanner extends ConsumerWidget {
  const WorldCupEntryBanner({super.key});

  static const _ink = Color(0xFFF1EDE3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(worldCupVisibleProvider)) return const SizedBox.shrink();
    final c = context.lt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LtPressable(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorldCupScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [LTBrand.coral, Color(0xFF8E3A28)],
            ),
            borderRadius: BorderRadius.circular(LTRadius.lg),
            boxShadow: c.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.sports_soccer, color: _ink, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'worldcup.title'),
                      style: GoogleFonts.hankenGrotesk(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.34, color: _ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr(ref, 'worldcup.banner_subtitle'),
                      style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: FontWeight.w500, color: _ink.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _ink, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
