import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/sports/data/models/worldcup_widget_models.dart';

class WorldcupWidgetRepository {
  WorldcupWidgetRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// GET /api/sports/worldcup/widget (público, sin auth).
  /// Acepta respuesta envuelta en `{ "data": {...} }` o el objeto directo.
  /// Lanza si `mode` no es "live"/"last" (contrato → tratar como error).
  Future<WorldcupWidget> getWidget() async {
    final response = await _dio.get(ApiEndpoints.sportsWorldcupWidget);

    final body = response.data;
    final raw = (body is Map<String, dynamic> && body['data'] is Map)
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;

    final widget = WorldcupWidget.fromJson(raw);
    if (!widget.isValidMode) {
      throw const FormatException('Invalid worldcup widget mode');
    }
    return widget;
  }
}
