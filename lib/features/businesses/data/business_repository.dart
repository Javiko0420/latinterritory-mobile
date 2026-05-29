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

  /// Fetches featured businesses for the home carousel.
  ///
  /// Backend resolves slot logic (paid placements + organic fallback).
  /// Falls back to the first page of active businesses if the dedicated
  /// endpoint is not available yet.
  Future<List<Business>> getFeaturedBusinesses({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.featuredBusinesses,
        queryParameters: {'limit': limit},
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => Business.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        final fallback = await getBusinesses(page: 1, limit: limit);
        return fallback.businesses;
      }
      rethrow;
    }
  }

  /// Fetches full business detail by slug.
  Future<BusinessDetail> getBusinessBySlug(String slug) async {
    final response = await _dio.get(ApiEndpoints.businessBySlug(slug));
    return BusinessDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// Fetches full business detail by ID.
  Future<BusinessDetail> getBusinessById(String id) async {
    final response = await _dio.get(ApiEndpoints.businessDetail(id));
    return BusinessDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// Fetches businesses created by the authenticated user.
  Future<List<Business>> getMyBusinesses() async {
    final response = await _dio.get(ApiEndpoints.myBusinesses);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Business.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea un nuevo negocio en el directorio. Devuelve el SLUG asignado.
  ///
  /// Se usa el slug (no el ID) porque el endpoint estable para obtener
  /// el detalle es GET /api/businesses/slug/:slug.
  Future<String> createBusiness(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.businesses, data: data);
    final responseData = response.data['data'];
    if (responseData is Map<String, dynamic>) {
      return responseData['slug'] as String? ?? '';
    }
    return '';
  }

  /// Actualiza un negocio existente.
  Future<void> updateBusiness(
      String id, Map<String, dynamic> data) async {
    await _dio.put(ApiEndpoints.businessDetail(id), data: data);
  }

  /// Elimina un negocio del directorio.
  Future<void> deleteBusiness(String id) async {
    await _dio.delete(ApiEndpoints.businessDetail(id));
  }
}
