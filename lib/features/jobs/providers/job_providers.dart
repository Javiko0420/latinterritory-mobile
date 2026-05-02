import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/jobs/data/job_repository.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';

// ── Repository ────────────────────────────────────────────

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(dio: ref.watch(dioProvider));
});

// ── Job List ──────────────────────────────────────────────

final jobFilterProvider =
    NotifierProvider<JobFilterNotifier, JobFilter>(
  JobFilterNotifier.new,
);

class JobFilter {
  const JobFilter({this.category, this.location, this.query});
  final String? category;
  final String? location;
  final String? query;

  JobFilter copyWith({
    String? category,
    String? location,
    String? query,
    bool clearCategory = false,
    bool clearLocation = false,
    bool clearQuery = false,
  }) {
    return JobFilter(
      category: clearCategory ? null : (category ?? this.category),
      location: clearLocation ? null : (location ?? this.location),
      query: clearQuery ? null : (query ?? this.query),
    );
  }
}

class JobFilterNotifier extends Notifier<JobFilter> {
  @override
  JobFilter build() => const JobFilter();

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
    state = const JobFilter();
  }
}

/// Fetches jobs based on current filters.
final jobListProvider = FutureProvider<PaginatedJobs>((ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  final filter = ref.watch(jobFilterProvider);
  return repo.getJobs(
    category: filter.category,
    location: filter.location,
    query: filter.query,
  );
});

// ── Job Detail ────────────────────────────────────────────

final jobDetailProvider =
    FutureProvider.family<JobDetail, String>((ref, id) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getJobDetail(id);
});
