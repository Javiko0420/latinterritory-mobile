import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/forums/data/forum_repository.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';

// ── Repository Provider ───────────────────────────────────

final forumRepositoryProvider = Provider<ForumRepository>((ref) {
  return ForumRepository(dio: ref.watch(dioProvider));
});

// ── Forums List ───────────────────────────────────────────

final forumsProvider = FutureProvider<List<Forum>>((ref) async {
  final repo = ref.watch(forumRepositoryProvider);
  return repo.getForums();
});

// ── Posts for a Forum ─────────────────────────────────────

final forumPostsProvider =
    FutureProvider.family<PaginatedPosts, String>((ref, forumId) async {
  final repo = ref.watch(forumRepositoryProvider);
  return repo.getForumPosts(forumId);
});

// ── Comments for a Post ───────────────────────────────────

final postCommentsProvider =
    FutureProvider.family<List<ForumComment>, String>((ref, postId) async {
  final repo = ref.watch(forumRepositoryProvider);
  return repo.getPostComments(postId);
});

// ── Create Post Controller ────────────────────────────────

final createPostProvider = Provider<CreatePost>((ref) {
  return CreatePost(ref);
});

class CreatePost {
  CreatePost(this._ref);
  final Ref _ref;

  Future<bool> createPost({
    required String forumId,
    required String content,
  }) async {
    try {
      final repo = _ref.read(forumRepositoryProvider);
      await repo.createPost(forumId: forumId, content: content);
      _ref.invalidate(forumPostsProvider(forumId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── Like Toggle Controller ────────────────────────────────

final togglePostLikeProvider = Provider<TogglePostLike>((ref) {
  return TogglePostLike(ref);
});

class TogglePostLike {
  TogglePostLike(this._ref);
  final Ref _ref;

  Future<void> call(String postId, String forumId) async {
    final repo = _ref.read(forumRepositoryProvider);
    await repo.togglePostLike(postId);
    // Refresh posts to reflect updated like count.
    _ref.invalidate(forumPostsProvider(forumId));
  }
}

final toggleCommentLikeProvider = Provider<ToggleCommentLike>((ref) {
  return ToggleCommentLike(ref);
});

class ToggleCommentLike {
  ToggleCommentLike(this._ref);
  final Ref _ref;

  Future<void> call(String commentId, String postId) async {
    final repo = _ref.read(forumRepositoryProvider);
    await repo.toggleCommentLike(commentId);
    // Refresh comments to reflect updated like count.
    _ref.invalidate(postCommentsProvider(postId));
  }
}
