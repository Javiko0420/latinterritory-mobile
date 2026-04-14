import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';

/// Repository for business directory operations.
class BusinessRepository {
  BusinessRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches paginated list of active businesses with optional filters.
  Future<PaginatedBusinesses> getBusinesses({
    int page = 1,
    int limit = 20,
    String? category,
    String? city,
    String? query,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.businesses,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    final pagination = response.data['pagination'] as Map<String, dynamic>;

    return PaginatedBusinesses(
      businesses: data
          .map((json) => Business.fromJson(json as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      hasMore: pagination['hasMore'] as bool? ?? false,
    );
  }

  /// Fetches full business detail by slug.
  Future<BusinessDetail> getBusinessBySlug(String slug) async {
    final response = await _dio.get(ApiEndpoints.businessBySlug(slug));
    return BusinessDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
