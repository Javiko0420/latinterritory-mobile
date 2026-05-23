import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

/// Full user profile returned by GET /api/users/me.
///
/// Contains all fields including optional ones not present in the
/// minimal [User] model used by the auth module.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    String? name,
    String? nickname,
    String? image,
    @Default('USER') String role,
    String? dateOfBirth,
    String? phoneNumber,
    @Default(true) bool hasPassword,
    @Default(false) bool isGoogleUser,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Request body for PUT /api/users/me.
///
/// Only [name] is required; all other fields are optional.
/// Null values are stripped before sending to the API (handled in repository).
@freezed
abstract class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    required String name,
    String? nickname,
    String? image,
    String? phoneNumber,
    String? dateOfBirth,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
