import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';
import 'package:latinterritory/shared/utils/logger.dart';

/// Repository for all authentication operations.
///
/// Handles API calls and token persistence.
/// Does NOT manage UI state — that's the provider's job.
class AuthRepository {
  AuthRepository({
    required Dio dio,
    required SecureStorageService storage,
  })  : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;

  // ── Email/Password Login ────────────────────────────────

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.mobileLogin,
      data: request.toJson(),
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await _persistSession(authResponse);
    return authResponse;
  }

  // ── Registration ────────────────────────────────────────

  Future<void> register(RegisterRequest request) async {
    await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
  }

  // ── Google Sign-In ──────────────────────────────────────

  Future<AuthResponse> googleSignIn(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.mobileGoogle,
      data: {'idToken': idToken},
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await _persistSession(authResponse);
    return authResponse;
  }

  // ── Forgot Password ────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  // ── Get Current User ───────────────────────────────────

  Future<User> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.usersMe);
    return User.fromJson(response.data);
  }

  // ── Check Existing Session ─────────────────────────────

  /// Restores the session from cached user + stored tokens.
  ///
  /// The backend's `/api/users/me` endpoint currently does not
  /// accept mobile Bearer tokens, so we rely on the user data
  /// cached at login time. The tokens are still valid for all
  /// other API calls (the interceptor handles refresh).
  Future<User?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    final cachedJson = await _storage.getCachedUser();
    if (cachedJson != null) {
      return User.fromJson(cachedJson);
    }

    // Fallback: try the API (in case cache was lost but tokens are valid).
    try {
      final user = await getCurrentUser();
      await _storage.saveUser(user.toJson());
      return user;
    } on DioException catch (e) {
      final error = e.error;
      if (error is UnauthorizedException || error is ForbiddenException) {
        await _storage.clearAll();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Logout ──────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.clearAll();
  }

  // ── Helpers ─────────────────────────────────────────────

  /// Persists tokens AND user data so the session can be
  /// restored without an API call on next app start.
  Future<void> _persistSession(AuthResponse response) async {
    await Future.wait([
      _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ),
      _storage.saveUser(response.user.toJson()),
    ]);
  }
}
