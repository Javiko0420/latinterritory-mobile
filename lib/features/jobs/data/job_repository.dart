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

  /// Fetches job offers created by the authenticated user.
  Future<List<Job>> getMyJobs() async {
    final response = await _dio.get(ApiEndpoints.myJobs);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Job.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea una nueva oferta de empleo. Devuelve el ID asignado.
  Future<String> createJob(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.jobs, data: data);
    final responseData = response.data['data'];
    if (responseData is Map<String, dynamic>) {
      return responseData['id'] as String? ?? '';
    }
    return '';
  }

  /// Actualiza una oferta de empleo existente.
  Future<void> updateJob(String id, Map<String, dynamic> data) async {
    await _dio.put(ApiEndpoints.jobDetail(id), data: data);
  }

  /// Elimina una oferta de empleo.
  Future<void> deleteJob(String id) async {
    await _dio.delete(ApiEndpoints.jobDetail(id));
  }
}
