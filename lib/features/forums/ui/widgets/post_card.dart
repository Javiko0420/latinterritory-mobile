import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

/// "hace 5m / 2h / 3d" en español.
String forumTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
  if (diff.inHours < 24) return 'hace ${diff.inHours}h';
  if (diff.inDays < 7) return 'hace ${diff.inDays}d';
  return '${date.day}/${date.month}/${date.year}';
}

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, required this.forumId, required this.onTap});

  final ForumPost post;
  final String forumId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final authState = ref.watch(authStateProvider).value;
    final isLoggedIn = authState?.isAuthenticated ?? false;
    final currentUserId = authState?.user?.id;

    return LtPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
                LtAvatar(name: post.author.nickname, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author.nickname, style: LTType.body(c.ink, size: 14, weight: FontWeight.w700)),
                      Text(forumTimeAgo(post.createdAt), style: LTType.caption(c.ink3, size: 11.5)),
                    ],
                  ),
                ),
                if (post.isEdited)
                  Text('editado', style: LTType.caption(c.ink3, size: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content, style: LTType.body(c.ink, size: 14.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                _Action(
                  icon: Icons.favorite_border,
                  label: '${post.likesCount}',
                  accent: c.coral,
                  onTap: isLoggedIn
                      ? () async {
                          final ok = await ref.read(togglePostLikeProvider).call(post.id, forumId);
                          if (!ok && context.mounted) context.showErrorSnackBar('No se pudo dar me gusta.');
                        }
                      : null,
                ),
                const SizedBox(width: 18),
                _Action(icon: Icons.chat_bubble_outline, label: '${post.commentsCount}', accent: c.blue, onTap: onTap),
                const Spacer(),
                if (isLoggedIn && currentUserId != post.author.id)
                  LtPressable(
                    onTap: () => _report(context, ref),
                    child: Icon(Icons.flag_outlined, size: 16, color: c.ink3),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _report(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar mensaje'),
        content: const Text('¿Por qué reportas este mensaje?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(forumRepositoryProvider).reportPost(post.id, reason: 'INAPPROPRIATE_CONTENT');
                if (context.mounted) context.showSnackBar('Mensaje reportado. Gracias.');
              } catch (_) {
                if (context.mounted) context.showErrorSnackBar('No se pudo reportar el mensaje.');
              }
            },
            style: TextButton.styleFrom(foregroundColor: ctx.lt.coral),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.accent, this.onTap});

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: onTap != null ? accent : c.ink3),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
        ],
      ),
    );
  }
}
