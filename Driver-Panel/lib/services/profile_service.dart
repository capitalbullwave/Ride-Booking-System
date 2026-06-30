import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class ProfileService extends BaseApiService {
  ProfileService(this._localStorage, super.dio);

  final LocalStorageService _localStorage;

  Future<DriverProfile> getProfile() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return DriverProfile.fromJson(
        (await loadMockJson('driver_profile.json'))['data']
            as Map<String, dynamic>,
      );
    }

    return get(
      ApiEndpoints.profile,
      parser: (data) =>
          BackendMappers.driverProfile(data as Map<String, dynamic>),
    );
  }

  Future<DriverProfile> updateProfile(Map<String, dynamic> data) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return getProfile();
    }

    return put(
      ApiEndpoints.updateProfile,
      data: data,
      parser: (data) =>
          BackendMappers.driverProfile(data as Map<String, dynamic>),
    );
  }

  Future<void> submitRegistration(DriverRegistration registration) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 2));
      return;
    }

    final nameParts = registration.fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await put(
      ApiEndpoints.updateProfile,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        if (registration.licenseNumber != null)
          'license_number': registration.licenseNumber,
      },
    );

    if (registration.licenseFrontUrl != null) {
      await post(
        ApiEndpoints.uploadLicense,
        data: {
          'document_type': 'DRIVING_LICENSE',
          'document_url': registration.licenseFrontUrl,
          'document_number': registration.licenseNumber,
        },
      );
    }

    final vehicleTypeId = await _resolveVehicleTypeId(registration.vehicleType);
    final vehicleResponse = await post<Map<String, dynamic>>(
      ApiEndpoints.uploadVehicle,
      data: {
        'vehicle_type_id': vehicleTypeId,
        'license_plate': registration.vehicleNumber ?? '',
        'model': registration.vehicleModel ?? '',
        'color': registration.vehicleColor ?? '',
        'year': registration.manufacturingYear,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    final vehicleId = vehicleResponse['id']?.toString();
    if (vehicleId != null && vehicleId.isNotEmpty) {
      await _localStorage.setString(AppConstants.vehicleIdKey, vehicleId);
    }
  }

  Future<String?> _resolveVehicleTypeId(String? vehicleType) async {
    if (vehicleType == null || vehicleType.isEmpty) return null;

    final types = await get<List<dynamic>>(
      ApiEndpoints.vehicleTypes,
      parser: (data) => data as List<dynamic>,
    );

    if (types.isEmpty) return null;

    for (final item in types) {
      final map = item as Map<String, dynamic>;
      final name = (map['name'] as String? ?? '').toLowerCase();
      if (name == vehicleType.toLowerCase()) {
        return map['id']?.toString();
      }
    }

    return (types.first as Map<String, dynamic>)['id']?.toString();
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return;
    }

    await put(isOnline ? ApiEndpoints.goOnline : ApiEndpoints.goOffline);
  }

  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) async {
    if (useMock) return;

    await post(
      ApiEndpoints.driverLocation,
      data: {
        'lat': lat,
        'lng': lng,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
      },
    );
  }

  Future<DashboardStats> getDashboardStats() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return DashboardStats.fromJson(
        (await loadMockJson('dashboard_stats.json'))['data']
            as Map<String, dynamic>,
      );
    }

    final profile = await getProfile();

    double walletBalance = 0;
    double todayEarnings = 0;

    try {
      final wallet = await get<Map<String, dynamic>>(
        ApiEndpoints.wallet,
        parser: (data) => data as Map<String, dynamic>,
      );
      walletBalance = (wallet['balance'] as num?)?.toDouble() ?? 0;
    } catch (_) {}

    try {
      final earnings = await get<Map<String, dynamic>>(
        ApiEndpoints.earnings,
        queryParameters: {'period': 'daily'},
        parser: (data) => data as Map<String, dynamic>,
      );
      todayEarnings = (earnings['net_earnings'] as num?)?.toDouble() ?? 0;
    } catch (_) {}

    return BackendMappers.dashboardStats(
      profile: profile,
      walletBalance: walletBalance,
      todayEarnings: todayEarnings,
    );
  }

  String? getStoredVehicleId() =>
      _localStorage.getString(AppConstants.vehicleIdKey);
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(
    ref.watch(localStorageProvider),
    ref.watch(dioClientProvider).dio,
  );
});
