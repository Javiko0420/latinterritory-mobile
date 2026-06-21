import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/worldcup_2026/ui/tabs/groups_tab.dart';
import 'package:latinterritory/features/worldcup_2026/ui/tabs/knockout_tab.dart';
import 'package:latinterritory/features/worldcup_2026/ui/tabs/live_tab.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// Vista del Mundial 2026 (feature temporal). Se abre desde el banner de
/// Deportes con `Navigator.push` (sin tocar el router).
class WorldCupScreen extends ConsumerWidget {
  const WorldCupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x4, LTSpace.screenH, 8),
                child: Row(
                  children: [
                    LtPressable(
                      onTap: () => Navigator.of(context).maybePop(),
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
                          Text('FIFA', style: LTType.eyebrow(c.coral)),
                          const SizedBox(height: 2),
                          Text(tr(ref, 'worldcup.title'), style: LTType.display(c.ink, size: 26)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: c.coral,
                unselectedLabelColor: c.ink3,
                indicatorColor: c.coral,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: c.line,
                labelStyle: GoogleFonts.hankenGrotesk(fontSize: 13.5, fontWeight: FontWeight.w800),
                unselectedLabelStyle: GoogleFonts.hankenGrotesk(fontSize: 13.5, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(text: tr(ref, 'worldcup.tab_live')),
                  Tab(text: tr(ref, 'worldcup.tab_groups')),
                  Tab(text: tr(ref, 'worldcup.tab_knockout')),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [LiveTab(), GroupsTab(), KnockoutTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
