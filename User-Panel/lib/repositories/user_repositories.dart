import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';
import 'package:wavego_user/models/otp_send_result.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/user_services.dart';

class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  })  : _authService = authService,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  final AuthService _authService;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  String _pendingPhone = '';
  String _pendingCountryCode = '+91';

  String get pendingPhone => _pendingPhone;
  String get pendingCountryCode => _pendingCountryCode;

  Future<OtpSendResult> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    _pendingPhone = phone;
    _pendingCountryCode = countryCode;
    await _localStorage.setString(AppConstants.pendingPhoneKey, phone);
    await _localStorage.setString(AppConstants.pendingCountryCodeKey, countryCode);

    return _authService.sendOtp(phone: phone, countryCode: countryCode);
  }

  Future<LoginResponse> verifyOtp(String otp) async {
    final phone = _pendingPhone.isNotEmpty
        ? _pendingPhone
        : _localStorage.getString(AppConstants.pendingPhoneKey) ?? '';
    final countryCode = _pendingCountryCode.isNotEmpty
        ? _pendingCountryCode
        : _localStorage.getString(AppConstants.pendingCountryCodeKey) ?? '+91';

    final response = await _authService.verifyOtp(
      phone: phone,
      countryCode: countryCode,
      otp: otp,
    );

    await _secureStorage.write(
      AppConstants.accessTokenKey,
      response.tokens.accessToken,
    );
    await _secureStorage.write(
      AppConstants.refreshTokenKey,
      response.tokens.refreshToken,
    );

    if (response.user != null) {
      await _localStorage.setJson(
        AppConstants.userProfileKey,
        response.user!.toJson(),
      );
    }

    return response;
  }

  Future<UserProfile?> getProfile() async {
    final json = _localStorage.getJson(AppConstants.userProfileKey);
    if (json == null) return null;
    return UserProfile.fromJson(json);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<bool> isOnboardingComplete() async =>
      _localStorage.getBool(AppConstants.onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _localStorage.setBool(AppConstants.onboardingCompleteKey, true);

  Future<void> logout() async {
    await _authService.logout();
    await _secureStorage.deleteAll();
    await _localStorage.remove(AppConstants.userProfileKey);
  }
}

class HomeRepository {
  HomeRepository(this._service);
  final HomeService _service;
  Future<HomeDashboard> getDashboard() => _service.getDashboard();
}

class WalletRepository {
  WalletRepository(this._service);
  final WalletService _service;
  Future<WalletSummary> getWallet() => _service.getWallet();
}

class NotificationRepository {
  NotificationRepository(this._service);
  final NotificationService _service;
  Future<List<AppNotification>> getNotifications() => _service.getNotifications();
}

class ActivityRepository {
  ActivityRepository(this._service);
  final ActivityService _service;
  Future<Map<String, List<ActivityItem>>> getActivities() => _service.getActivities();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(homeServiceProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletServiceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(notificationServiceProvider));
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(ref.watch(activityServiceProvider));
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.watch(authRepositoryProvider).getProfile();
});
