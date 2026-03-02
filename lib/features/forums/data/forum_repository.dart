import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';

/// Repository for all forum operations.
class ForumRepository {
  ForumRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // ── Forums ──────────────────────────────────────────────

  /// Fetches active forums for today.
  Future<List<Forum>> getForums() async {
    final response = await _dio.get(ApiEndpoints.forums);
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => Forum.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches a single forum by ID.
  Future<Forum> getForumDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.forumDetail(id));
    return Forum.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ── Posts ───────────────────────────────────────────────

  /// Fetches posts for a forum with pagination.
  Future<PaginatedPosts> getForumPosts(
    String forumId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.forumPosts(forumId),
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] as List<dynamic>;
    final pagination = response.data['pagination'] as Map<String, dynamic>;

    return PaginatedPosts(
      posts: data.map((json) => ForumPost.fromJson(json as Map<String, dynamic>)).toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      hasMore: pagination['hasMore'] as bool? ?? false,
    );
  }

  /// Creates a new post in a forum. Requires auth.
  Future<ForumPost> createPost({
    required String forumId,
    required String content,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.forumPosts(forumId),
      data: {'content': content},
    );
    return ForumPost.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ── Comments ────────────────────────────────────────────

  /// Fetches comments for a post.
  Future<List<ForumComment>> getPostComments(String postId) async {
    final response = await _dio.get(ApiEndpoints.postComments(postId));
    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => ForumComment.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Creates a new comment on a post. Requires auth.
  Future<ForumComment> createComment({
    required String postId,
    required String content,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.postComments(postId),
      data: {'content': content},
    );
    return ForumComment.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ── Likes ───────────────────────────────────────────────

  /// Toggles like on a post. Requires auth.
  Future<void> togglePostLike(String postId) async {
    await _dio.post(ApiEndpoints.postLike(postId));
  }

  /// Toggles like on a comment. Requires auth.
  Future<void> toggleCommentLike(String commentId) async {
    await _dio.post(ApiEndpoints.commentLike(commentId));
  }

  // ── Reports ─────────────────────────────────────────────

  /// Reports a post. Requires auth.
  Future<void> reportPost(String postId, {required String reason, String? details}) async {
    await _dio.post(
      ApiEndpoints.postReport(postId),
      data: {'reason': reason, if (details != null) 'details': details},
    );
  }

  /// Reports a comment. Requires auth.
  Future<void> reportComment(String commentId, {required String reason, String? details}) async {
    await _dio.post(
      ApiEndpoints.commentReport(commentId),
      data: {'reason': reason, if (details != null) 'details': details},
    );
  }
}
