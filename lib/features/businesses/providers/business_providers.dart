import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/businesses/data/business_repository.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';

// ── Repository ────────────────────────────────────────────

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(dio: ref.watch(dioProvider));
});

// ── Business List ─────────────────────────────────────────

/// Holds current filter/search state.
final businessFilterProvider =
    NotifierProvider<BusinessFilterNotifier, BusinessFilter>(
  BusinessFilterNotifier.new,
);

class BusinessFilterNotifier extends Notifier<BusinessFilter> {
  @override
  BusinessFilter build() => const BusinessFilter();

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
    state = const BusinessFilter();
  }
}

class BusinessFilter {
  const BusinessFilter({this.category, this.city, this.query});
  final String? category;
  final String? city;
  final String? query;

  BusinessFilter copyWith({
    String? category,
    String? city,
    String? query,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearQuery = false,
  }) {
    return BusinessFilter(
      category: clearCategory ? null : (category ?? this.category),
      city: clearCity ? null : (city ?? this.city),
      query: clearQuery ? null : (query ?? this.query),
    );
  }
}

/// Fetches businesses based on current filters.
final businessListProvider =
    FutureProvider<PaginatedBusinesses>((ref) async {
  final repo = ref.watch(businessRepositoryProvider);
  final filter = ref.watch(businessFilterProvider);
  return repo.getBusinesses(
    category: filter.category,
    city: filter.city,
    query: filter.query,
  );
});

// ── Featured Businesses ───────────────────────────────────

final featuredBusinessesProvider =
    FutureProvider<List<Business>>((ref) async {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.getFeaturedBusinesses();
});

// ── Business Detail ───────────────────────────────────────

final businessDetailProvider =
    FutureProvider.family<BusinessDetail, String>((ref, slug) async {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.getBusinessBySlug(slug);
});
