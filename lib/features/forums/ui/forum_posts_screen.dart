import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/widgets/post_card.dart';
import 'package:latinterritory/features/forums/utils/nickname_guard.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_composer.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';

class ForumPostsScreen extends ConsumerStatefulWidget {
  const ForumPostsScreen({super.key, required this.forum});

  final Forum forum;

  @override
  ConsumerState<ForumPostsScreen> createState() => _ForumPostsScreenState();
}

class _ForumPostsScreenState extends ConsumerState<ForumPostsScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    if (!await ensureNickname(context, ref)) return;

    setState(() => _submitting = true);
    final ok = await ref.read(createPostProvider).createPost(forumId: widget.forum.id, content: content);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      _controller.clear();
      FocusScope.of(context).unfocus();
      context.showSnackBar('¡Mensaje publicado!');
    } else {
      context.showErrorSnackBar('No se pudo publicar el mensaje.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final async = ref.watch(forumPostsProvider(widget.forum.id));
    final isLoggedIn = ref.watch(authStateProvider).value?.isAuthenticated ?? false;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.forum.topic.replaceAll('_', ' ').toUpperCase(), style: LTType.eyebrow(c.green)),
                        const SizedBox(height: 2),
                        Text(widget.forum.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.title(c.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ── Posts ───────────────────────────────────
            Expanded(
              child: async.when(
                loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
                error: (_, __) => _ErrorBox(onRetry: () => ref.invalidate(forumPostsProvider(widget.forum.id))),
                data: (paginated) {
                  final posts = paginated.posts;
                  if (posts.isEmpty) return const _EmptyBox();
                  return RefreshIndicator(
                    color: c.gold,
                    onRefresh: () async {
                      ref.invalidate(forumPostsProvider(widget.forum.id));
                      await ref.read(forumPostsProvider(widget.forum.id).future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(LTSpace.screenH, 4, LTSpace.screenH, 16),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final post = posts[i];
                        return PostCard(
                          post: post,
                          forumId: widget.forum.id,
                          onTap: () => context.pushNamed(
                            RouteNames.forumPost,
                            pathParameters: {'forumId': widget.forum.id, 'postId': post.id},
                            extra: post,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // ── Composer ────────────────────────────────
            if (isLoggedIn)
              LtComposer(
                controller: _controller,
                hint: 'Escribe algo…',
                maxLength: 500,
                submitting: _submitting,
                onSend: _create,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox();

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 44, color: c.ink3),
          const SizedBox(height: 12),
          Text('Aún no hay mensajes', style: LTType.card(c.ink, size: 16)),
          const SizedBox(height: 4),
          Text('¡Sé el primero en escribir!', style: LTType.caption(c.ink2, size: 13)),
        ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: c.ink3),
          const SizedBox(height: 12),
          Text('No pudimos cargar los mensajes.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
