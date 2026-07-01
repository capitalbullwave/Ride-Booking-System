import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/registration_payload.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class ProfileService extends BaseApiService {
  ProfileService(this._localStorage, Dio dio, AuthTokenStore tokenStore)
      : super(dio, tokenStore);

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

    final vehicleTypeId = await _resolveVehicleTypeId(registration.vehicleType);
    if (vehicleTypeId == null || vehicleTypeId.isEmpty) {
      throw const ValidationException('Please select a valid vehicle type.');
    }

    final plate = (registration.vehicleNumber ?? '').trim().toUpperCase();
    if (plate.isEmpty || plate.length > 20) {
      throw const ValidationException(
        'Vehicle number must be 1–20 characters (e.g. DL-08-AB-1234).',
      );
    }

    if (registration.licenseNumber == null ||
        registration.licenseNumber!.trim().isEmpty) {
      throw const ValidationException('Driving license number is required.');
    }

    final model = (registration.vehicleModel ?? '').trim();
    final brand = (registration.vehicleBrand ?? '').trim();
    if (model.isEmpty && brand.isEmpty) {
      throw const ValidationException(
        'Vehicle model or brand is required before submitting.',
      );
    }

    final color = (registration.vehicleColor ?? '').trim();
    if (color.isEmpty) {
      throw const ValidationException('Vehicle color is required before submitting.');
    }

    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.completeRegistration,
      data: await buildCompleteRegistrationPayload(
        registration: registration,
        vehicleTypeId: vehicleTypeId,
      ),
      parser: (data) => data as Map<String, dynamic>,
    );

    final vehicleId = response['vehicle_id']?.toString();
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

    final normalized = vehicleType.trim().toLowerCase();
    const aliases = <String, List<String>>{
      'bike': ['bike', 'motorcycle', 'two wheeler', 'scooter'],
      'auto': ['auto', 'rickshaw', 'three wheeler'],
      'mini cab': ['mini', 'mini cab', 'hatchback'],
      'sedan': ['sedan', 'comfort'],
      'suv': ['suv', 'xl', 'premium'],
    };
    final keywords = aliases[normalized] ?? [normalized];

    for (final item in types) {
      final map = item as Map<String, dynamic>;
      final name = (map['name'] as String? ?? '').toLowerCase();
      final slug = (map['slug'] as String? ?? '').toLowerCase();

      if (name == normalized || slug == normalized.replaceAll(' ', '-')) {
        return map['id']?.toString();
      }

      for (final keyword in keywords) {
        if (name.contains(keyword) || slug.contains(keyword)) {
          return map['id']?.toString();
        }
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
    ref.watch(authTokenStoreProvider),
  );
});
