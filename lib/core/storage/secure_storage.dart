import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] for auth tokens.
///
/// Stores tokens in iOS Keychain / Android KeyStore.
/// Never use SharedPreferences for sensitive data.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final FlutterSecureStorage _storage;

  // ── Keys ────────────────────────────────────────────────
  static const String _accessTokenKey = 'lt_access_token';
  static const String _refreshTokenKey = 'lt_refresh_token';
  static const String _tokenExpiryKey = 'lt_token_expiry';

  // ── Access Token ────────────────────────────────────────

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // ── Refresh Token ───────────────────────────────────────

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // ── Token Expiry ────────────────────────────────────────

  Future<DateTime?> getTokenExpiry() async {
    final value = await _storage.read(key: _tokenExpiryKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> setTokenExpiry(DateTime expiry) async {
    await _storage.write(
      key: _tokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  /// Whether the access token has expired (or will within [buffer]).
  Future<bool> isTokenExpired({Duration buffer = Duration.zero}) async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry.subtract(buffer));
  }

  // ── Store Both Tokens ───────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiry,
  }) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
      if (expiry != null) setTokenExpiry(expiry),
    ]);
  }

  // ── Clear All ───────────────────────────────────────────

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
