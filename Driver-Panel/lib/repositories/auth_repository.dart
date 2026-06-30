import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/storage/secure_storage_service.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/otp_send_result.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/auth_service.dart';
import 'package:wavego_driver/services/profile_service.dart';

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

  Future<OtpSendResult> sendOtp({
    required String phone,
    required String countryCode,
  }) =>
      _authService.sendOtp(phone: phone, countryCode: countryCode);

  Future<LoginResponse> verifyOtp({
    required String phone,
    required String otp,
    required String countryCode,
  }) async {
    final response = await _authService.verifyOtp(
      phone: phone,
      otp: otp,
      countryCode: countryCode,
    );

    await _secureStorage.write(
      AppConstants.accessTokenKey,
      response.tokens.accessToken,
    );
    await _secureStorage.write(
      AppConstants.refreshTokenKey,
      response.tokens.refreshToken,
    );

    if (response.driver != null) {
      await _localStorage.setJson(
        AppConstants.driverProfileKey,
        response.driver!.toJson(),
      );
    }

    return response;
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _secureStorage.deleteAll();
    await _localStorage.remove(AppConstants.driverProfileKey);
    await _localStorage.remove(AppConstants.isOnlineKey);
  }

  Future<bool> isOnboardingComplete() async =>
      _localStorage.getBool(AppConstants.onboardingCompleteKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _localStorage.setBool(AppConstants.onboardingCompleteKey, true);
}

class ProfileRepository {
  ProfileRepository(this._service);

  final ProfileService _service;

  Future<DriverProfile> getProfile() => _service.getProfile();
  Future<DriverProfile> updateProfile(Map<String, dynamic> data) =>
      _service.updateProfile(data);
  Future<void> submitRegistration(DriverRegistration registration) =>
      _service.submitRegistration(registration);
  Future<void> setOnlineStatus(bool isOnline) =>
      _service.setOnlineStatus(isOnline);
  Future<DashboardStats> getDashboardStats() => _service.getDashboardStats();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    secureStorage: ref.watch(secureStorageProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileServiceProvider));
});
