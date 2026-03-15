import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/post_comments_screen.dart';
import 'package:latinterritory/features/forums/ui/widgets/post_card.dart';
import 'package:latinterritory/features/forums/utils/nickname_guard.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class ForumPostsScreen extends ConsumerStatefulWidget {
  const ForumPostsScreen({super.key, required this.forum});
  final Forum forum;

  @override
  ConsumerState<ForumPostsScreen> createState() => _ForumPostsScreenState();
}

class _ForumPostsScreenState extends ConsumerState<ForumPostsScreen> {
  final _postController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _handleCreatePost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    if (!await ensureNickname(context, ref)) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(createPostProvider).createPost(
          forumId: widget.forum.id,
          content: content,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _postController.clear();
        FocusScope.of(context).unfocus();
        context.showSnackBar('Post created!');
      } else {
        context.showErrorSnackBar('Failed to create post.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider(widget.forum.id));
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.value?.isAuthenticated ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forum.name),
      ),
      body: Column(
        children: [
          // ── Posts List ───────────────────────────────
          Expanded(
            child: postsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    const Text('Could not load posts.'),
                    const SizedBox(height: AppDimensions.md),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(
                          forumPostsProvider(widget.forum.id)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (paginatedPosts) {
                final posts = paginatedPosts.posts;
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'No posts yet. Be the first!',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(forumPostsProvider(widget.forum.id));
                    // Wait for the new data to arrive before hiding the spinner.
                    await ref.read(forumPostsProvider(widget.forum.id).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(
                        AppDimensions.screenPaddingH),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        forumId: widget.forum.id,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostCommentsScreen(
                                post: post,
                                forumId: widget.forum.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // ── Create Post Input ───────────────────────
          if (isLoggedIn)
            Container(
              padding: EdgeInsets.only(
                left: AppDimensions.md,
                right: AppDimensions.md,
                top: AppDimensions.sm,
                bottom: MediaQuery.of(context).padding.bottom +
                    AppDimensions.sm,
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
                      controller: _postController,
                      maxLength: 500,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write something...',
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
                    onPressed: _isSubmitting ? null : _handleCreatePost,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
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
