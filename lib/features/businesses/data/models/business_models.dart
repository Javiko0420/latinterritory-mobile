import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_models.freezed.dart';
part 'business_models.g.dart';

/// Business list item from GET /api/businesses.
@freezed
abstract class Business with _$Business {
  const factory Business({
    required String id,
    required String name,
    required String slug,
    required String description,
    required String category,
    String? city,
    String? state,
    String? phone,
    String? email,
    String? website,
    String? whatsapp,
    String? instagram,
    @Default([]) List<String> images,
    @Default(false) bool isVerified,
    String? logoUrl,
    DateTime? createdAt,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) =>
      _$BusinessFromJson(json);
}

/// Owner info nested in business detail.
@freezed
abstract class BusinessOwner with _$BusinessOwner {
  const factory BusinessOwner({
    required String id,
    String? name,
    String? image,
  }) = _BusinessOwner;

  factory BusinessOwner.fromJson(Map<String, dynamic> json) =>
      _$BusinessOwnerFromJson(json);
}

/// Review user info.
@freezed
abstract class ReviewUser with _$ReviewUser {
  const factory ReviewUser({
    required String id,
    String? name,
    String? image,
  }) = _ReviewUser;

  factory ReviewUser.fromJson(Map<String, dynamic> json) =>
      _$ReviewUserFromJson(json);
}

/// Review model from business detail.
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required int rating,
    required String comment,
    required DateTime createdAt,
    required ReviewUser user,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);
}

/// Product model from business detail.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    double? price,
    @Default('COP') String currency,
    String? image,
    @Default(false) bool featured,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// Full business detail from GET /api/businesses/slug/[slug].
@freezed
abstract class BusinessDetail with _$BusinessDetail {
  const factory BusinessDetail({
    required String id,
    required String name,
    required String slug,
    required String description,
    required String category,
    String? city,
    String? state,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? whatsapp,
    String? instagram,
    String? facebook,
    String? tiktok,
    @Default([]) List<String> images,
    String? logoUrl,
    @Default(false) bool isVerified,
    String? plan,
    required BusinessOwner owner,
    @Default([]) List<Review> reviews,
    @Default(0) int reviewsCount,
    double? averageRating,
    @Default([]) List<Product> products,
    required DateTime createdAt,
  }) = _BusinessDetail;

  factory BusinessDetail.fromJson(Map<String, dynamic> json) =>
      _$BusinessDetailFromJson(json);
}

/// Paginated response wrapper for businesses.
@freezed
abstract class PaginatedBusinesses with _$PaginatedBusinesses {
  const factory PaginatedBusinesses({
    required List<Business> businesses,
    required int page,
    required int limit,
    required int total,
    @Default(false) bool hasMore,
  }) = _PaginatedBusinesses;
}
