import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_section_header.dart';

/// Sección "Foro del día" del home — design system "Latin Territory".
///
/// Solo presentación: observa [forumsProvider] (foros activos de hoy) y
/// muestra el primero con `isActive == true`. En loading, error o sin foros
/// activos no renderiza nada: la sección desaparece del home.
class LTForumWidget extends ConsumerWidget {
  const LTForumWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final forums = ref.watch(forumsProvider).value ?? const <Forum>[];
    final active = forums.where((f) => f.isActive).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    final forum = active.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LtSectionHeader(
          eyebrow: tr(ref, 'home.eyebrow_community'),
          title: tr(ref, 'home.forum_of_day'),
          accent: c.green,
          actionLabel: tr(ref, 'home.see_forums'),
          onAction: () => context.go('/forums'),
        ),
        const SizedBox(height: 14),
        _ForumCard(forum: forum),
        // Spacing propio: al ocultarse la sección no deja hueco doble.
        const SizedBox(height: 24),
      ],
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
      onTap: () => context.pushNamed(
        RouteNames.forumDetail,
        pathParameters: {'id': forum.id},
        extra: forum,
      ),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.greenSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.forum_outlined, color: c.green, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(ref, 'home.forum_topic_of_day').toUpperCase(),
                        style: LTType.eyebrow(c.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        forum.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LTType.card(c.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              forum.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LTType.caption(c.ink2, size: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${forum.postsCount} ${tr(ref, 'forums.posts')}',
                  style: LTType.caption(c.ink2, size: 13, weight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: c.green,
                    borderRadius: BorderRadius.circular(LTRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr(ref, 'home.forum_join'),
                        style: LTType.caption(
                          Colors.white,
                          size: 13,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward,
                          size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
