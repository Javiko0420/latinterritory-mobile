import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';

/// Repository for user profile operations.
///
/// Communicates with:
/// - GET  /api/users/me            → [getProfile]
/// - PUT  /api/users/me            → [updateProfile]
/// - POST /api/users/me/change-password → [changePassword]
class ProfileRepository {
  ProfileRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  // ── Get Profile ─────────────────────────────────────────

  /// Fetches the full profile of the authenticated user.
  Future<UserProfile> getProfile() async {
    final response = await _dio.get(ApiEndpoints.usersMe);
    return UserProfile.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  // ── Update Profile ───────────────────────────────────────

  /// Updates editable profile fields.
  ///
  /// Only non-null fields are sent in the request body.
  ///
  /// Note: PUT /api/users/me returns the raw user object directly
  /// (no `{success, data}` wrapper), unlike the GET endpoint.
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    // Strip null values — backend only updates fields that are present.
    final data = request.toJson()..removeWhere((_, v) => v == null);
    final response = await _dio.put(ApiEndpoints.usersMe, data: data);
    // PUT returns the raw user object at the top level, not wrapped.
    final body = response.data as Map<String, dynamic>;
    final userJson = body.containsKey('data')
        ? body['data'] as Map<String, dynamic>
        : body;
    return UserProfile.fromJson(userJson);
  }

  // ── Change Password ──────────────────────────────────────

  /// Submits a password change request.
  ///
  /// ⚠️  This endpoint currently uses server-side session (getServerSession)
  /// and may not accept mobile Bearer tokens yet. The UI handles this
  /// gracefully by displaying the API error message.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }
}
