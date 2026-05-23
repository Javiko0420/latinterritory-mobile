import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/events/data/event_repository.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';

// ── Repository ────────────────────────────────────────────

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(dio: ref.watch(dioProvider));
});

// ── Event List ────────────────────────────────────────────

/// Current filter/search state for events.
final eventFilterProvider =
    NotifierProvider<EventFilterNotifier, EventFilter>(
  EventFilterNotifier.new,
);

class EventFilter {
  const EventFilter({this.category, this.query});
  final String? category;
  final String? query;

  EventFilter copyWith({
    String? category,
    String? query,
    bool clearCategory = false,
    bool clearQuery = false,
  }) {
    return EventFilter(
      category: clearCategory ? null : (category ?? this.category),
      query: clearQuery ? null : (query ?? this.query),
    );
  }
}

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => const EventFilter();

  void setCategory(String? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
    );
  }

  void setQuery(String? query) {
    state = state.copyWith(
      query: query,
      clearQuery: query == null || query.isEmpty,
    );
  }

  void clear() {
    state = const EventFilter();
  }
}

/// Fetches events based on current filters.
///
/// Uses autoDispose so the provider is destroyed when the Events screen
/// is not visible — next visit always fetches fresh data from the API.
final eventListProvider = FutureProvider.autoDispose<PaginatedEvents>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  final filter = ref.watch(eventFilterProvider);
  return repo.getEvents(
    category: filter.category,
    query: filter.query,
  );
});

// ── Event Detail ──────────────────────────────────────────

final eventDetailProvider =
    FutureProvider.family<EventDetail, String>((ref, id) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventDetail(id);
});
