import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/otp_send_result.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/auth_service.dart';
import 'package:wavego_driver/services/profile_service.dart';

class AuthRepository {
  AuthRepository({
    required AuthService authService,
    required AuthTokenStore tokenStore,
    required LocalStorageService localStorage,
  })  : _authService = authService,
        _tokenStore = tokenStore,
        _localStorage = localStorage;

  final AuthService _authService;
  final AuthTokenStore _tokenStore;
  final LocalStorageService _localStorage;
  bool _loggingOut = false;

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

    await _tokenStore.setTokens(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );

    await _localStorage.setBool(
      AppConstants.driverRegisteredKey,
      response.isVerified,
    );

    final verifiedPhone = response.driver?.phone ?? phone;
    if (verifiedPhone.isNotEmpty) {
      await _localStorage.setString(AppConstants.driverPhoneKey, verifiedPhone);
    }

    if (response.driver != null) {
      await _localStorage.setJson(
        AppConstants.driverProfileKey,
        response.driver!.toJson(),
      );
    }

    return response;
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStore.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// User-initiated logout: revoke on server (if token exists), then clear local state.
  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      final token = await _tokenStore.readAccessToken();
      if (token != null && token.isNotEmpty) {
        await _authService.logout(accessToken: token);
      }
      await clearLocalSession(reason: 'user_logout');
    } finally {
      _loggingOut = false;
    }
  }

  /// Local-only cleanup used for session expiry. Never calls `/auth/logout`.
  Future<void> clearLocalSession({String reason = 'local_clear'}) async {
    await _tokenStore.clear();
    await _localStorage.remove(AppConstants.driverProfileKey);
    await _localStorage.remove(AppConstants.driverRegisteredKey);
    await _localStorage.remove(AppConstants.isOnlineKey);
  }

  Future<bool> isOnboardingComplete() async =>
      _localStorage.getBool(AppConstants.onboardingCompleteKey) ?? false;

  Future<String?> getVerifiedPhone() async {
    final stored = _localStorage.getString(AppConstants.driverPhoneKey);
    if (stored != null && stored.isNotEmpty) return stored;

    final profileJson = _localStorage.getJson(AppConstants.driverProfileKey);
    final profilePhone = profileJson?['phone'] as String?;
    if (profilePhone != null && profilePhone.isNotEmpty) {
      return profilePhone;
    }

    return null;
  }

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
  Future<Map<String, dynamic>> getRegistrationProgress() =>
      _service.getRegistrationProgress();

  Future<Map<String, dynamic>> getRegistrationData() =>
      _service.getRegistrationData();
  Future<void> saveLicenseUpload({
    required String documentUrl,
    required String side,
  }) =>
      _service.saveLicenseUpload(documentUrl: documentUrl, side: side);
  Future<void> saveLicenseNumber({required String licenseNumber}) =>
      _service.saveLicenseNumber(licenseNumber: licenseNumber);
  Future<Map<String, dynamic>> saveProfileStep({
    required String firstName,
    String lastName = '',
    String? dateOfBirth,
    String? gender,
    String? profilePhoto,
    String? city,
    String? state,
    String? country,
    String? referralCode,
  }) =>
      _service.saveProfileStep(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profilePhoto: profilePhoto,
        city: city,
        state: state,
        country: country,
        referralCode: referralCode,
      );
  Future<void> saveVehicleNumber({
    required String licensePlate,
    String? vehicleTypeId,
    String? rcFrontUrl,
    String? rcBackUrl,
  }) =>
      _service.saveVehicleNumber(
        licensePlate: licensePlate,
        vehicleTypeId: vehicleTypeId,
        rcFrontUrl: rcFrontUrl,
        rcBackUrl: rcBackUrl,
      );
  Future<void> saveVehicleType({required String vehicleTypeId}) =>
      _service.saveVehicleType(vehicleTypeId: vehicleTypeId);
  Future<void> saveVehicleDocuments({
    String? insuranceUrl,
    String? pollutionUrl,
    String? permitUrl,
    String? fitnessUrl,
    String? vehicleFrontUrl,
    String? vehicleBackUrl,
    String? vehicleSideUrl,
  }) =>
      _service.saveVehicleDocuments(
        insuranceUrl: insuranceUrl,
        pollutionUrl: pollutionUrl,
        permitUrl: permitUrl,
        fitnessUrl: fitnessUrl,
        vehicleFrontUrl: vehicleFrontUrl,
        vehicleBackUrl: vehicleBackUrl,
        vehicleSideUrl: vehicleSideUrl,
      );
  Future<void> saveKyc({
    required String idType,
    required String frontUrl,
    String? backUrl,
    required String documentNumber,
  }) =>
      _service.saveKyc(
        idType: idType,
        frontUrl: frontUrl,
        backUrl: backUrl,
        documentNumber: documentNumber,
      );
  Future<void> submitRegistrationProgress() =>
      _service.submitRegistrationProgress();
  Future<String?> resolveVehicleTypeId(String? vehicleType) =>
      _service.resolveVehicleTypeId(vehicleType);
  Future<void> setOnlineStatus(bool isOnline) =>
      _service.setOnlineStatus(isOnline);
  Future<DashboardStats> getDashboardStats() => _service.getDashboardStats();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.watch(authServiceProvider),
    tokenStore: ref.watch(authTokenStoreProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileServiceProvider));
});
