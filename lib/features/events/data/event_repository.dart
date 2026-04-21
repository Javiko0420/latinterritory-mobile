import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';

/// Repository for event operations.
class EventRepository {
  EventRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches upcoming events with optional filters.
  Future<PaginatedEvents> getEvents({
    int page = 1,
    int limit = 20,
    String? category,
    String? query,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.events,
      queryParameters: {
        'page': page,
        'limit': limit,
        'category': ?category,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    final pagination = response.data['pagination'] as Map<String, dynamic>;

    return PaginatedEvents(
      events: data
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      hasMore: pagination['hasMore'] as bool? ?? false,
    );
  }

  /// Fetches full event detail by ID.
  Future<EventDetail> getEventDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.eventDetail(id));
    return EventDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
