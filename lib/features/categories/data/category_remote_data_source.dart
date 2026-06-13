import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<Map<String, List<CategoryOption>>> fetchAll() async {
    final response = await _dio.get(ApiEndpoints.categories);
    final body = response.data as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('GET /api/categories returned success:false');
    }

    final data = body['data'] as Map<String, dynamic>;

    return {
      'businesses': _parseList(data['businesses']),
      'jobs': _parseList(data['jobs']),
      'events': _parseList(data['events']),
    };
  }

  List<CategoryOption> _parseList(dynamic raw) {
    return (raw as List<dynamic>).map((item) {
      final map = item as Map<String, dynamic>;
      return CategoryOption(
        value: map['value'] as String,
        labelEs: map['label'] as String,
      );
    }).toList();
  }
}
