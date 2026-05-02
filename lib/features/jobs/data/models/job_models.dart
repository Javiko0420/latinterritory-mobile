import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_models.freezed.dart';
part 'job_models.g.dart';

/// Job list item from GET /api/jobs.
@freezed
abstract class Job with _$Job {
  const factory Job({
    required String id,
    required String title,
    required String category,
    required String description,
    required String location,
    required String jobType,
    required double hourlyRate,
    @Default(false) bool isVerified,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}

/// Full job detail from GET /api/jobs/[id].
@freezed
abstract class JobDetail with _$JobDetail {
  const factory JobDetail({
    required String id,
    required String title,
    required String category,
    required String description,
    required String location,
    required String jobType,
    required double hourlyRate,
    String? email,
    String? phone,
    String? externalLink,
    @Default(false) bool isVerified,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _JobDetail;

  factory JobDetail.fromJson(Map<String, dynamic> json) =>
      _$JobDetailFromJson(json);
}

/// Paginated response wrapper for jobs.
@freezed
abstract class PaginatedJobs with _$PaginatedJobs {
  const factory PaginatedJobs({
    required List<Job> jobs,
    required int page,
    required int limit,
    required int total,
    @Default(false) bool hasMore,
  }) = _PaginatedJobs;
}
