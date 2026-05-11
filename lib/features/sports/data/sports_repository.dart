import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/sports/data/models/sports_models.dart';

class SportsRepository {
  SportsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<SportsSummary> getSummary() async {
    final response = await _dio.get(ApiEndpoints.sportsSummary);
    return SportsSummary.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  Future<LeagueDetail> getLeagueDetail({required String league}) async {
    final response = await _dio.get(
      ApiEndpoints.sportsLeague,
      queryParameters: {'league': league, 'include': 'results,standings'},
    );
    return LeagueDetail.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
