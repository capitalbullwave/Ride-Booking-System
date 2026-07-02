import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/storage/secure_storage_service.dart';

/// Keeps the access token in memory so authenticated requests work immediately
/// after login. On web, also mirrors tokens to [SharedPreferences] because
/// flutter_secure_storage can be unreliable across hot restarts.
class AuthTokenStore {
  AuthTokenStore(this._secureStorage, this._prefs);

  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;
  String? _accessToken;

  String? get accessToken => _accessToken;

  /// Loads a persisted token into memory on app startup.
  Future<void> hydrate() async {
    await readAccessToken();
  }

  Future<String?> readAccessToken() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }

    if (kIsWeb) {
      final webToken = _prefs.getString(AppConstants.accessTokenKey);
      if (webToken != null && webToken.isNotEmpty) {
        _accessToken = webToken;
        return _accessToken;
      }
    }

    final stored = await _secureStorage.read(AppConstants.accessTokenKey);
    if (stored != null && stored.isNotEmpty) {
      _accessToken = stored;
    }
    return _accessToken;
  }

  Future<String?> readRefreshToken() async {
    if (kIsWeb) {
      final webToken = _prefs.getString(AppConstants.refreshTokenKey);
      if (webToken != null && webToken.isNotEmpty) return webToken;
    }
    return _secureStorage.read(AppConstants.refreshTokenKey);
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;

    if (kIsWeb) {
      await _prefs.setString(AppConstants.accessTokenKey, accessToken);
      await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    }

    await _secureStorage.write(AppConstants.accessTokenKey, accessToken);
    await _secureStorage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _secureStorage.deleteAll();
  }
}

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  ref.keepAlive();
  return AuthTokenStore(
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
