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
        if (category != null) 'category': category,
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

  /// Fetches upcoming events for the home section.
  ///
  /// Backend resolves slot logic (paid placements + organic fallback).
  /// Falls back to the first page of upcoming events if the dedicated
  /// endpoint is not available yet.
  Future<List<Event>> getUpcomingEvents({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.upcomingEvents,
        queryParameters: {'limit': limit},
      );

      final data = response.data['data'] as List<dynamic>;
      return data
          .map((json) => Event.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404 || statusCode == 500) {
        final fallback = await getEvents(page: 1, limit: limit);
        return fallback.events;
      }
      rethrow;
    }
  }

  /// Fetches full event detail by ID.
  Future<EventDetail> getEventDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.eventDetail(id));
    return EventDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  /// Fetches events created by the authenticated user.
  Future<List<Event>> getMyEvents() async {
    final response = await _dio.get(ApiEndpoints.myEvents);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea un nuevo evento. Devuelve el ID asignado.
  Future<String> createEvent(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.events, data: data);
    final responseData = response.data['data'];
    if (responseData is Map<String, dynamic>) {
      return responseData['id'] as String? ?? '';
    }
    return '';
  }

  /// Actualiza un evento existente.
  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiEndpoints.eventDetail(id), data: data);
  }

  /// Elimina un evento.
  Future<void> deleteEvent(String id) async {
    await _dio.delete(ApiEndpoints.eventDetail(id));
  }
}
