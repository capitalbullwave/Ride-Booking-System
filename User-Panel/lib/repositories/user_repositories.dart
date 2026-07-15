import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/network/api_exception.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';
import 'package:wavego_user/models/otp_send_result.dart';
import 'package:wavego_user/core/utils/profile_name_resolver.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/profile_service.dart';
import 'package:wavego_user/services/user_services.dart';

class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required ProfileService profileService,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  })  : _authService = authService,
        _profileService = profileService,
        _secureStorage = secureStorage,
        _localStorage = localStorage;

  final AuthService _authService;
  final ProfileService _profileService;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  bool _loggingOut = false;
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

    try {
      final profile = await syncProfileFromApi();
      return LoginResponse(
        success: response.success,
        isRegistered: response.isRegistered,
        isVerified: response.isVerified,
        tokens: response.tokens,
        user: profile,
      );
    } catch (_) {
      if (response.user != null) {
        await _cacheProfile(response.user!);
      }
      return response;
    }
  }

  Future<void> _cacheProfile(UserProfile profile) async {
    await _localStorage.setJson(
      AppConstants.userProfileKey,
      profile.toJson(),
    );
  }

  Future<void> cacheProfilePublic(UserProfile profile) => _cacheProfile(profile);

  Future<UserProfile> syncProfileFromApi() async {
    final profile = await _profileService.getProfile();
    await _cacheProfile(profile);
    return profile;
  }

  Future<UserProfile> updateProfile({
    String? fullName,
    String? email,
    String? gender,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? referralCode,
  }) async {
    final profile = await _profileService.updateProfile(
      fullName: fullName,
      email: email,
      gender: gender,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      referralCode: referralCode,
    );
    await _cacheProfile(profile);
    return profile;
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

  /// Returns true when access token works or was refreshed successfully.
  Future<bool> ensureValidSession() async {
    final access = await _secureStorage.read(AppConstants.accessTokenKey);
    if (access == null || access.isEmpty) return false;

    try {
      await syncProfileFromApi();
      return true;
    } on UnauthorizedException {
      return refreshSession();
    } catch (_) {
      return true;
    }
  }

  Future<bool> refreshSession() async {
    final refresh = await _secureStorage.read(AppConstants.refreshTokenKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final tokens = await _authService.refreshTokens(refresh);
      await _secureStorage.write(AppConstants.accessTokenKey, tokens.accessToken);
      await _secureStorage.write(AppConstants.refreshTokenKey, tokens.refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isOnboardingComplete() async =>
      _localStorage.getBool(AppConstants.onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _localStorage.setBool(AppConstants.onboardingCompleteKey, true);

  Future<bool> needsProfileSetup() async {
    if (!await isLoggedIn()) return false;

    var profile = await getProfile();
    if (profile == null) {
      try {
        profile = await syncProfileFromApi();
      } catch (_) {
        return true;
      }
    }
    return profile.isPlaceholderName;
  }

  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      final token = await _secureStorage.read(AppConstants.accessTokenKey);
      if (token != null && token.isNotEmpty) {
        await _authService.logout(accessToken: token);
      }
      await clearLocalSession(reason: 'user_logout');
    } finally {
      _loggingOut = false;
    }
  }

  /// Used for expired sessions / splash recovery. Never calls `/auth/logout`.
  Future<void> clearLocalSession({String reason = 'local_clear'}) async {
    await _secureStorage.deleteAll();
    await _localStorage.remove(AppConstants.userProfileKey);
  }
}

class HomeRepository {
  HomeRepository(this._service);
  final HomeService _service;
  Future<HomeDashboard> getDashboard() => _service.getDashboard();
  Future<List<VehicleCategory>> getVehicleCategories({String? serviceGroup}) =>
      _service.getVehicleCategories(serviceGroup: serviceGroup);
  Future<List<VehicleCategory>> getRentalCategories() => _service.getRentalCategories();
}

class WalletRepository {
  WalletRepository(this._service);
  final WalletService _service;
  Future<WalletSummary> getWallet() => _service.getWallet();
  Future<List<Map<String, dynamic>>> getTransactions() => _service.getTransactions();
  Future<UserBankInfo> saveBank({
    required String paymentType,
    required String accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? upiId,
  }) =>
      _service.saveBank(
        paymentType: paymentType,
        accountHolderName: accountHolderName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        bankName: bankName,
        upiId: upiId,
      );
  Future<Map<String, dynamic>> withdraw(double amount) => _service.withdraw(amount);
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
    profileService: ref.watch(profileServiceProvider),
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
  final auth = ref.watch(authRepositoryProvider);
  if (!await auth.isLoggedIn()) return null;

  UserProfile? profile;
  try {
    profile = await auth.syncProfileFromApi();
  } catch (_) {
    profile = await auth.getProfile();
  }

  HomeDashboard? dashboard;
  try {
    dashboard = await ref.read(homeRepositoryProvider).getDashboard();
  } catch (_) {}

  final merged = ProfileNameResolver.merge(
    profile: profile,
    dashboard: dashboard,
  );

  await auth.cacheProfilePublic(merged);
  return merged;
});
