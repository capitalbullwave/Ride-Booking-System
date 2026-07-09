import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';

/// Resolves where a driver should land after login or app relaunch.
class PostAuthNavigation {
  PostAuthNavigation._();

  static const _earlyOnboardingRoutes = {
    RouteNames.captainWelcome,
    RouteNames.captainCitySelection,
    RouteNames.captainVehicleSelection,
  };

  static bool shouldLeaveEarlyOnboarding(String route) =>
      !_earlyOnboardingRoutes.contains(route);

  static Future<String> resolveRoute({
    required ProfileRepository profileRepo,
    required LocalStorageService localStorage,
    LoginResponse? loginResponse,
  }) async {
    try {
      final profile = loginResponse?.driver ?? await profileRepo.getProfile();

      await _persistProfile(localStorage, profile);

      if (BackendMappers.isDriverVerified(profile)) {
        return RouteNames.dashboard;
      }

      if (profile.verificationStatus == 'rejected') {
        return RouteNames.documentCentre;
      }

      final progress = await profileRepo.getRegistrationProgress();
      final submitted = progress['submitted'] == true;

      if (submitted) {
        return RouteNames.documentCentre;
      }

      final steps = progress['steps'] as List<dynamic>? ?? [];
      final hasProgress = steps.any((step) {
        if (step is! Map<String, dynamic>) return false;
        return step['completed'] == true;
      });
      if (hasProgress) {
        return RouteNames.documentCentre;
      }

      try {
        final regData = await profileRepo.getRegistrationData();
        if (_hasRegistrationData(regData)) {
          return RouteNames.documentCentre;
        }
      } catch (_) {}

      if (loginResponse != null) {
        if (loginResponse.isVerified) return RouteNames.dashboard;
        if (loginResponse.isRegistered) return RouteNames.documentCentre;
      }

      return RouteNames.captainWelcome;
    } catch (_) {
      if (loginResponse?.isVerified == true) {
        return RouteNames.dashboard;
      }
      if (loginResponse?.isRegistered == true) {
        return RouteNames.documentCentre;
      }
      return RouteNames.captainWelcome;
    }
  }

  static Future<void> _persistProfile(
    LocalStorageService localStorage,
    DriverProfile profile,
  ) async {
    await localStorage.setBool(AppConstants.driverRegisteredKey, true);
    await localStorage.setJson(AppConstants.driverProfileKey, profile.toJson());
    if (profile.phone.isNotEmpty) {
      await localStorage.setString(AppConstants.driverPhoneKey, profile.phone);
    }
  }

  static bool _hasRegistrationData(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    const keys = [
      'vehicle_type',
      'city',
      'first_name',
      'license_number',
      'vehicle_number',
      'profile_photo',
    ];

    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toUpperCase() != 'PENDING') {
        return true;
      }
    }
    return false;
  }
}
