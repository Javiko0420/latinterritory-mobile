import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.forumId,
    required this.onTap,
  });

  final ForumPost post;
  final String forumId;
  final VoidCallback onTap;

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

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Author + Time ──────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      post.author.nickname[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.nickname,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isEdited)
                    Text(
                      'edited',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Content ────────────────────────────────
              Text(
                post.content,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Actions ────────────────────────────────
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.favorite_border,
                    label: '${post.likesCount}',
                    onPressed: isLoggedIn
                        ? () => ref
                            .read(togglePostLikeProvider)
                            .call(post.id, forumId)
                        : null,
                  ),
                  const SizedBox(width: AppDimensions.md),

                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentsCount}',
                    onPressed: onTap,
                  ),

                  const Spacer(),

                  if (isLoggedIn)
                    IconButton(
                      icon: Icon(
                        Icons.flag_outlined,
                        size: AppDimensions.iconSm,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => _showReportDialog(context, ref),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Why are you reporting this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(forumRepositoryProvider).reportPost(
                      post.id,
                      reason: 'INAPPROPRIATE_CONTENT',
                    );
                if (context.mounted) {
                  context.showSnackBar('Post reported. Thank you.');
                }
              } catch (_) {
                if (context.mounted) {
                  context.showErrorSnackBar('Could not report post.');
                }
              }
            },
            child: Text(
              'Report',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xs,
          vertical: AppDimensions.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSm,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: AppDimensions.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
