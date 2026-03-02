import 'package:freezed_annotation/freezed_annotation.dart';

part 'forum_models.freezed.dart';
part 'forum_models.g.dart';

/// Author info nested in posts and comments.
@freezed
abstract class PostAuthor with _$PostAuthor {
  const factory PostAuthor({
    required String id,
    @Default('Anonymous') String nickname,
    @Default(0) int reputation,
  }) = _PostAuthor;

  factory PostAuthor.fromJson(Map<String, dynamic> json) =>
      _$PostAuthorFromJson(json);
}

/// Forum model from GET /api/forums.
@freezed
abstract class Forum with _$Forum {
  const factory Forum({
    required String id,
    required String name,
    required String description,
    required String slug,
    required String topic,
    required DateTime startDate,
    required DateTime endDate,
    @Default(true) bool isActive,
    @Default(0) int postsCount,
  }) = _Forum;

  factory Forum.fromJson(Map<String, dynamic> json) => _$ForumFromJson(json);
}

/// Post model from GET /api/forums/[id]/posts.
@freezed
abstract class ForumPost with _$ForumPost {
  const factory ForumPost({
    required String id,
    required String content,
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    @Default(false) bool isFlagged,
    String? flagReason,
    @Default(0) int likesCount,
    @Default(0) int reportsCount,
    @Default(0) int commentsCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required PostAuthor author,
  }) = _ForumPost;

  factory ForumPost.fromJson(Map<String, dynamic> json) =>
      _$ForumPostFromJson(json);
}

/// Comment model from GET /api/posts/[id]/comments.
@freezed
abstract class ForumComment with _$ForumComment {
  const factory ForumComment({
    required String id,
    required String content,
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    @Default(false) bool isFlagged,
    String? flagReason,
    @Default(0) int likesCount,
    @Default(0) int reportsCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required PostAuthor author,
  }) = _ForumComment;

  factory ForumComment.fromJson(Map<String, dynamic> json) =>
      _$ForumCommentFromJson(json);
}

/// Paginated response wrapper for posts.
@freezed
abstract class PaginatedPosts with _$PaginatedPosts {
  const factory PaginatedPosts({
    required List<ForumPost> posts,
    required int page,
    required int limit,
    @Default(false) bool hasMore,
  }) = _PaginatedPosts;
}
