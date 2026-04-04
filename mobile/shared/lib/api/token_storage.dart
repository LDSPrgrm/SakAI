import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistence layer for authentication tokens.
/// Built using [FlutterSecureStorage] for encrypted storage on-disk.
class TokenStorage {
  const TokenStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'sakai_access_token';
  static const _keyRefreshToken = 'sakai_refresh_token';
  static const _keyExpiry = 'sakai_token_expiry';

  /// Saves the session tokens and expiry to disk.
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
      _storage.write(key: _keyExpiry, value: expiresAt.toIso8601String()),
    ]);
  }

  /// Saves only the access token.
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  /// Saves only the refresh token.
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);

  /// Saves only the expiry timestamp.
  Future<void> saveExpiry(DateTime expiresAt) =>
      _storage.write(key: _keyExpiry, value: expiresAt.toIso8601String());

  /// Retrieves the stored access token, if any.
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  /// Retrieves the stored refresh token, if any.
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  /// Retrieves the token expiry timestamp.
  Future<DateTime?> getExpiry() async {
    final raw = await _storage.read(key: _keyExpiry);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Returns true if an access token exists.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all auth data from disk (logout).
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyExpiry),
    ]);
  }
}

/// Global provider for [TokenStorage].
/// Can be overridden in tests with a mock/fake storage.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => const TokenStorage(),
);
