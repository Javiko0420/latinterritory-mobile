import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_models.freezed.dart';
part 'event_models.g.dart';

/// Event list item from GET /api/events.
@freezed
abstract class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String description,
    required String category,
    required DateTime eventDate,
    required String location,
    String? imageUrl,
    double? ticketPrice,
    required DateTime createdAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

/// Organizer info nested in event detail.
@freezed
abstract class EventOrganizer with _$EventOrganizer {
  const factory EventOrganizer({
    required String id,
    String? name,
  }) = _EventOrganizer;

  factory EventOrganizer.fromJson(Map<String, dynamic> json) =>
      _$EventOrganizerFromJson(json);
}

/// Full event detail from GET /api/events/[id].
@freezed
abstract class EventDetail with _$EventDetail {
  const factory EventDetail({
    required String id,
    required String title,
    required String description,
    required String category,
    required DateTime eventDate,
    required String location,
    String? imageUrl,
    String? ticketLink,
    double? ticketPrice,
    required EventOrganizer organizer,
    required DateTime createdAt,
  }) = _EventDetail;

  factory EventDetail.fromJson(Map<String, dynamic> json) =>
      _$EventDetailFromJson(json);
}

/// Paginated response wrapper for events.
@freezed
abstract class PaginatedEvents with _$PaginatedEvents {
  const factory PaginatedEvents({
    required List<Event> events,
    required int page,
    required int limit,
    required int total,
    @Default(false) bool hasMore,
  }) = _PaginatedEvents;
}
