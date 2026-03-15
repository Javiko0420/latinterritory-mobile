import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/providers/forum_providers.dart';
import 'package:latinterritory/features/forums/ui/forum_posts_screen.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';

class ForumListScreen extends ConsumerWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumsAsync = ref.watch(forumsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Forums')),
      body: forumsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: 'Could not load forums.',
          onRetry: () => ref.invalidate(forumsProvider),
        ),
        data: (forums) {
          if (forums.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(forumsProvider);
              await ref.read(forumsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
              itemCount: forums.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.sm),
              itemBuilder: (context, index) {
                return _ForumCard(forum: forums[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ForumCard extends StatelessWidget {
  const _ForumCard({required this.forum});
  final Forum forum;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ForumPostsScreen(forum: forum),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Topic Badge ──────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  forum.topic.replaceAll('_', ' '),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Name ─────────────────────────────────
              Text(
                forum.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),

              // ── Description ──────────────────────────
              Text(
                forum.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.sm),

              // ── Footer ───────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: AppDimensions.iconSm,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '${forum.postsCount} posts',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'No active forums right now',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Check back later for new discussions.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.md),
            Text(message, style: context.textTheme.bodyLarge),
            const SizedBox(height: AppDimensions.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
