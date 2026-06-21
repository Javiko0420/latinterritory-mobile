import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/widgets/post_card.dart';
import 'package:latinterritory/features/forums/utils/nickname_guard.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_composer.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

class PostCommentsScreen extends ConsumerStatefulWidget {
  const PostCommentsScreen({super.key, required this.post, required this.forumId});

  final ForumPost post;
  final String forumId;

  @override
  ConsumerState<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends ConsumerState<PostCommentsScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    if (!await ensureNickname(context, ref)) return;

    setState(() => _submitting = true);
    try {
      await ref.read(forumRepositoryProvider).createComment(postId: widget.post.id, content: content);
      if (!mounted) return;
      _controller.clear();
      FocusScope.of(context).unfocus();
      ref.invalidate(postCommentsProvider(widget.post.id));
      ref.invalidate(forumPostsProvider(widget.forumId));
      context.showSnackBar('¡Comentario publicado!');
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException ? (e.error?.toString() ?? 'No se pudo publicar el comentario.') : 'No se pudo publicar el comentario.';
      context.showErrorSnackBar(msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final commentsAsync = ref.watch(postCommentsProvider(widget.post.id));
    final isLoggedIn = ref.watch(authStateProvider).value?.isAuthenticated ?? false;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x4, LTSpace.screenH, 12),
              child: Row(
                children: [
                  LtPressable(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(LTRadius.md), border: Border.all(color: c.line)),
                      child: Icon(Icons.chevron_left, color: c.ink, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Publicación', style: LTType.title(c.ink)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 4, LTSpace.screenH, 16),
                children: [
                  PostCard(post: widget.post, forumId: widget.forumId, onTap: () {}),
                  const SizedBox(height: 20),
                  Text('COMENTARIOS', style: LTType.eyebrow(c.green)),
                  const SizedBox(height: 12),
                  commentsAsync.when(
                    loading: () => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                    ),
                    error: (_, __) => Center(
                      child: LtPressable(
                        onTap: () => ref.invalidate(postCommentsProvider(widget.post.id)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text('Aún no hay comentarios.', style: LTType.body(c.ink3))),
                        );
                      }
                      return Column(
                        children: [
                          for (final cm in comments) ...[
                            _CommentTile(comment: cm, postId: widget.post.id),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            if (isLoggedIn)
              LtComposer(
                controller: _controller,
                hint: 'Escribe un comentario…',
                maxLength: 1000,
                submitting: _submitting,
                onSend: _submit,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.postId});

  final ForumComment comment;
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final isLoggedIn = ref.watch(authStateProvider).value?.isAuthenticated ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card2,
        borderRadius: BorderRadius.circular(LTRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LtAvatar(name: comment.author.nickname, size: 26),
              const SizedBox(width: 8),
              Text(comment.author.nickname, style: LTType.body(c.ink, size: 13, weight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(forumTimeAgo(comment.createdAt), style: LTType.caption(c.ink3, size: 11.5)),
              if (comment.isEdited) ...[
                const SizedBox(width: 6),
                Text('editado', style: LTType.caption(c.ink3, size: 11)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: LTType.body(c.ink, size: 14)),
          const SizedBox(height: 8),
          LtPressable(
            onTap: isLoggedIn ? () => ref.read(toggleCommentLikeProvider).call(comment.id, postId) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 15, color: isLoggedIn ? c.coral : c.ink3),
                const SizedBox(width: 5),
                Text('${comment.likesCount}', style: GoogleFonts.hankenGrotesk(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
