import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para subir imágenes a Cloudinary (unsigned upload).
class CloudinaryService {
  CloudinaryService() : _dio = _buildDio();

  final Dio _dio;

  static const String _cloudName = 'dflpxec6d';
  static const String _uploadPreset = 'latinterritory_uploads';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[CLOUDINARY] $obj'),
        ),
      );
    }
    return dio;
  }

  /// Sube una imagen a Cloudinary y retorna la [secure_url].
  ///
  /// Lanza [CloudinaryException] con el mensaje real del servidor
  /// si la subida falla.
  Future<String> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'upload_preset': _uploadPreset,
        'resource_type': 'image',
      });

      final response = await _dio.post(_uploadUrl, data: formData);
      final body = response.data as Map<String, dynamic>;
      final secureUrl = body['secure_url'] as String?;
      if (secureUrl == null) {
        throw CloudinaryException(
          'Cloudinary no retornó secure_url. Respuesta: $body',
        );
      }
      return secureUrl;
    } on DioException catch (e) {
      // Extrae el mensaje real de la respuesta de Cloudinary.
      final rawBody = e.response?.data;
      String cloudinaryMessage = 'Error al subir la imagen.';

      if (rawBody is Map<String, dynamic>) {
        final error = rawBody['error'];
        if (error is Map<String, dynamic>) {
          cloudinaryMessage = error['message'] as String? ?? cloudinaryMessage;
        }
      }

      debugPrint(
        '[CLOUDINARY] Upload failed — status=${e.response?.statusCode} '
        'type=${e.type} msg=$cloudinaryMessage',
      );
      throw CloudinaryException(cloudinaryMessage);
    }
  }
}

/// Excepción tipada para errores de Cloudinary.
class CloudinaryException implements Exception {
  const CloudinaryException(this.message);
  final String message;

  @override
  String toString() => 'CloudinaryException: $message';
}

/// Provider de CloudinaryService.
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
