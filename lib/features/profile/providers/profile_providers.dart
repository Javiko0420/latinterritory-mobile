import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';
import 'package:latinterritory/features/profile/data/profile_repository.dart';

// ── Repository ────────────────────────────────────────────

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(dio: ref.watch(dioProvider));
});

// ── Profile Data ──────────────────────────────────────────

/// Loads the full user profile from GET /api/users/me.
///
/// Invalidate with [ref.invalidate(profileProvider)] to force a refresh.
final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});

// ── Edit Profile ──────────────────────────────────────────

class EditProfileState {
  const EditProfileState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  EditProfileState copyWith({bool? isLoading, String? error}) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final editProfileNotifierProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);

class EditProfileNotifier extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  /// Sends PUT /api/users/me and refreshes profile + auth state on success.
  ///
  /// Returns [true] on success so the UI can navigate back.
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = const EditProfileState(isLoading: true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(request);
      // Refresh the profile cache so profile screen shows fresh data.
      ref.invalidate(profileProvider);
      // Sync the top-level auth state (e.g. bottom nav avatar).
      await ref.read(authStateProvider.notifier).refreshUser();
      state = const EditProfileState();
      return true;
    } catch (e) {
      state = EditProfileState(error: resolveApiErrorMessage(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ── Change Password ───────────────────────────────────────


class ChangePasswordState {
  const ChangePasswordState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  ChangePasswordState copyWith({bool? isLoading, String? error}) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final changePasswordNotifierProvider =
    NotifierProvider<ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  /// Sends POST /api/users/me/change-password.
  ///
  /// Returns [true] on success so the UI can navigate back.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = const ChangePasswordState(isLoading: true);
    try {
      await ref.read(profileRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          );
      state = const ChangePasswordState();
      return true;
    } catch (e) {
      state = ChangePasswordState(error: resolveApiErrorMessage(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ── Delete Account ────────────────────────────────────────

class DeleteAccountState {
  const DeleteAccountState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;

  DeleteAccountState copyWith({bool? isLoading, String? error}) {
    return DeleteAccountState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final deleteAccountNotifierProvider =
    NotifierProvider<DeleteAccountNotifier, DeleteAccountState>(
  DeleteAccountNotifier.new,
);

class DeleteAccountNotifier extends Notifier<DeleteAccountState> {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  /// Calls DELETE /api/users/me/delete, then logs the user out on success.
  ///
  /// Returns [true] on success — GoRouter redirect handles navigation.
  Future<bool> deleteAccount() async {
    state = const DeleteAccountState(isLoading: true);
    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      await ref.read(authStateProvider.notifier).logout();
      state = const DeleteAccountState();
      return true;
    } catch (e) {
      state = DeleteAccountState(error: resolveApiErrorMessage(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
