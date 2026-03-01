import 'package:dio/dio.dart';
import 'package:latinterritory/core/constants/api_endpoints.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';

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
    await _persistTokens(authResponse);
    return authResponse;
  }

  // ── Registration ────────────────────────────────────────

  Future<void> register(RegisterRequest request) async {
    await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    // Backend sends verification email.
    // User must login after verifying.
  }

  // ── Google Sign-In ──────────────────────────────────────

  Future<AuthResponse> googleSignIn(String idToken) async {
    final response = await _dio.post(
      ApiEndpoints.mobileGoogle,
      data: {'idToken': idToken},
    );
    final authResponse = AuthResponse.fromJson(response.data);
    await _persistTokens(authResponse);
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

  /// Returns the current user if a valid token exists in storage.
  /// Returns null if no token or token is invalid.
  Future<User?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;

    try {
      return await getCurrentUser();
    } catch (_) {
      // Token expired or invalid — clear and return null.
      await _storage.clearAll();
      return null;
    }
  }

  // ── Logout ──────────────────────────────────────────────

  Future<void> logout() async {
    // TODO: Optionally notify backend to invalidate refresh token.
    await _storage.clearAll();
  }

  // ── Helpers ─────────────────────────────────────────────

  Future<void> _persistTokens(AuthResponse response) async {
    await _storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
