import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

/// Comunidad / Foros (design system). Reusa `forumsProvider`.
class ForumListScreen extends ConsumerWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(forumsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: LtScreenIn(
          child: RefreshIndicator(
            color: c.gold,
            onRefresh: () async => ref.invalidate(forumsProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x4, LTSpace.screenH, LTSpace.screenBottom),
              children: [
                _Header(eyebrow: 'COMUNIDAD', title: 'Foros', accent: c.green),
                const SizedBox(height: LTSpace.x4),
                const _CommunityBanner(),
                const SizedBox(height: LTSpace.x4),
                async.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                  ),
                  error: (_, __) => _ErrorBox(onRetry: () => ref.invalidate(forumsProvider)),
                  data: (forums) {
                    if (forums.isEmpty) return const _EmptyBox();
                    return Column(
                      children: [
                        for (final f in forums) ...[
                          _ForumCard(forum: f),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityBanner extends StatelessWidget {
  const _CommunityBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LTBrand.green, Color(0xFF2C5A45)],
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
            child: const Icon(Icons.groups_outlined, color: Color(0xFFF1EDE3), size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu comunidad latina',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.34, color: Color(0xFFF1EDE3)),
                ),
                SizedBox(height: 2),
                Text(
                  'Únete a la conversación con tu gente',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xCCF1EDE3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumCard extends ConsumerWidget {
  const _ForumCard({required this.forum});

  final Forum forum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return LtPressable(
      onTap: () => context.pushNamed(RouteNames.forumDetail, pathParameters: {'id': forum.id}, extra: forum),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(LTRadius.lg),
          border: Border.all(color: c.line),
          boxShadow: c.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.forum_outlined, color: c.green, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(LTRadius.pill)),
                  child: Text(
                    forum.topic.replaceAll('_', ' '),
                    style: GoogleFonts.hankenGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: c.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(forum.name, style: LTType.card(c.ink, size: 16.5)),
            const SizedBox(height: 4),
            Text(forum.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2, size: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 14, color: c.ink3),
                const SizedBox(width: 5),
                Text('${forum.postsCount} ${tr(ref, 'forums.posts')}', style: LTType.caption(c.ink3, size: 12)),
                const Spacer(),
                Icon(Icons.chevron_right, size: 20, color: c.ink3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header / estados ──────────────────────────────────────

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
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(LTRadius.md), border: Border.all(color: c.line)),
            child: Icon(Icons.chevron_left, color: c.ink, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: LTType.eyebrow(accent)),
              const SizedBox(height: 2),
              Text(title, style: LTType.display(c.ink, size: 26)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(LTRadius.lg)),
              child: Icon(Icons.forum_outlined, size: 30, color: c.green),
            ),
            const SizedBox(height: 14),
            Text('No hay foros activos', style: LTType.card(c.ink, size: 16)),
            const SizedBox(height: 4),
            Text('Vuelve más tarde para nuevas discusiones.', style: LTType.caption(c.ink2, size: 13)),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 40, color: c.ink3),
            const SizedBox(height: 12),
            Text('No pudimos cargar los foros.', style: LTType.body(c.ink2)),
            const SizedBox(height: 10),
            LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
          ],
        ),
      ),
    );
  }
}
