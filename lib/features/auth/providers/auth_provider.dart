import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latinterritory/core/config/app_config.dart';
import 'package:latinterritory/core/networking/api_client.dart';
import 'package:latinterritory/core/storage/secure_storage.dart';
import 'package:latinterritory/features/auth/data/auth_repository.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';

// ── Service Providers ─────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient.createApiClient(
    storage: storage,
    onForceLogout: () {
      // Reset auth state — triggers router redirect to login.
      ref.read(authStateProvider.notifier).logout();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

// Google Sign-In 7.x uses a singleton; initialize once before use.

// ── Auth State ────────────────────────────────────────────

/// The core auth state for the entire app.
///
/// On app start, attempts to restore a previous session.
/// Router watches this to redirect to login/home.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  const AuthState({this.user});
  final User? user;

  bool get isAuthenticated => user != null;

  static const unauthenticated = AuthState();
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // On app start, try to restore session from stored token.
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.restoreSession();
    return user != null ? AuthState(user: user) : const AuthState();
  }

  /// Email + password login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(
        LoginRequest(email: email, password: password),
      );
      return AuthState(user: response.user);
    });
  }

  /// Google Sign-In flow (7.x singleton + initialize + authenticate).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final gs = GoogleSignIn.instance;
      await gs.initialize(
        clientId: Platform.isIOS ? AppConfig.googleIosClientId : null,
        serverClientId: AppConfig.googleWebClientId,
      );

      GoogleSignInAccount account;
      try {
        account = await gs.authenticate();
      } on GoogleSignInException catch (e) {
        // User cancelled or flow failed.
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted) {
          return state.value ?? const AuthState();
        }
        rethrow;
      }

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Exception('Failed to get Google ID token.');
      }

      final repo = ref.read(authRepositoryProvider);
      final response = await repo.googleSignIn(idToken);
      return AuthState(user: response.user);
    });
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();

    // Also sign out of Google (7.x singleton).
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google sign-out errors.
    }

    state = const AsyncData(AuthState());
  }

  /// Refresh user data (after profile edit, etc.).
  Future<void> refreshUser() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    state = AsyncData(AuthState(user: user));
  }
}
