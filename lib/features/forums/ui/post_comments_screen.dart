import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/widgets/post_card.dart';
import 'package:latinterritory/features/forums/utils/nickname_guard.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class PostCommentsScreen extends ConsumerStatefulWidget {
  const PostCommentsScreen({
    super.key,
    required this.post,
    required this.forumId,
  });

  final ForumPost post;
  final String forumId;

  @override
  ConsumerState<PostCommentsScreen> createState() =>
      _PostCommentsScreenState();
}

class _PostCommentsScreenState extends ConsumerState<PostCommentsScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    if (!await ensureNickname(context, ref)) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(forumRepositoryProvider);
      await repo.createComment(
        postId: widget.post.id,
        content: content,
      );

      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        ref.invalidate(postCommentsProvider(widget.post.id));
        ref.invalidate(forumPostsProvider(widget.forumId));
        context.showSnackBar('Comment added!');
      }
    } catch (_) {
      if (mounted) {
        context.showErrorSnackBar('Failed to post comment.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(postCommentsProvider(widget.post.id));
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Original Post ───────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
                    child: PostCard(
                      post: widget.post,
                      forumId: widget.forumId,
                      onTap: () {},
                    ),
                  ),
                ),

                // ── Comments Header ─────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPaddingH,
                    ),
                    child: Text(
                      'Comments',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.sm),
                ),

                // ── Comments List ───────────────────────
                commentsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.xl),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (_, __) => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.xl),
                        child: TextButton.icon(
                          onPressed: () => ref.invalidate(
                              postCommentsProvider(widget.post.id)),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ),
                    ),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.xl),
                          child: Center(
                            child: Text(
                              'No comments yet.',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _CommentTile(
                          comment: comments[index],
                          postId: widget.post.id,
                        ),
                        childCount: comments.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Comment Input ─────────────────────────────
          if (isLoggedIn)
            Container(
              padding: EdgeInsets.only(
                left: AppDimensions.md,
                right: AppDimensions.md,
                top: AppDimensions.sm,
                bottom:
                    MediaQuery.of(context).padding.bottom + AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLength: 1000,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        counterText: '',
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                      ),
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  IconButton(
                    onPressed: _isSubmitting ? null : _handleSubmitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send, color: AppColors.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.postId});
  final ForumComment comment;
  final String postId;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn =
        ref.watch(authStateProvider).value?.isAuthenticated ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Author + Time ─────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      AppColors.secondary.withValues(alpha: 0.12),
                  child: Text(
                    comment.author.nickname[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  comment.author.nickname,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  _timeAgo(comment.createdAt),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (comment.isEdited) ...[
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '(edited)',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.sm),

            // ── Content ───────────────────────────────
            Text(comment.content, style: context.textTheme.bodyMedium),
            const SizedBox(height: AppDimensions.sm),

            // ── Actions ───────────────────────────────
            Row(
              children: [
                InkWell(
                  onTap: isLoggedIn
                      ? () => ref
                          .read(toggleCommentLikeProvider)
                          .call(comment.id, postId)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likesCount}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
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
