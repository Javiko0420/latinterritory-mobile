import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';

/// Repository for job operations.
class JobRepository {
  JobRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Fetches active job offers with optional filters.
  Future<PaginatedJobs> getJobs({
    int page = 1,
    int limit = 20,
    String? category,
    String? location,
    String? query,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.jobs,
      queryParameters: {
        'page': page,
        'limit': limit,
        'category': ?category,
        'location': ?location,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    final pagination = response.data['pagination'] as Map<String, dynamic>;

    return PaginatedJobs(
      jobs: data
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      hasMore: pagination['hasMore'] as bool? ?? false,
    );
  }

  /// Fetches full job detail by ID.
  Future<JobDetail> getJobDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.jobDetail(id));
    return JobDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
