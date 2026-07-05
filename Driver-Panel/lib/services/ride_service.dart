import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class RideService extends BaseApiService {
  RideService(this._localStorage, Dio dio, AuthTokenStore tokenStore)
      : super(dio, tokenStore);

  final LocalStorageService _localStorage;

  Future<RideRequest?> getIncomingRideRequest() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 3));
      final data = await loadMockJson('ride_request.json');
      return RideRequest.fromJson(data['data'] as Map<String, dynamic>);
    }

    return get(
      ApiEndpoints.rideRequests,
      parser: (data) => BackendMappers.rideRequestFromList(data),
    );
  }

  Future<ActiveRide> acceptRide(String rideId, {String? vehicleId}) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final data = await loadMockJson('active_ride.json');
      return ActiveRide.fromJson(data['data'] as Map<String, dynamic>);
    }

    final resolvedVehicleId =
        vehicleId ?? _localStorage.getString(AppConstants.vehicleIdKey);

    return post(
      ApiEndpoints.acceptRide,
      data: {
        'ride_id': rideId,
        if (resolvedVehicleId != null && resolvedVehicleId.isNotEmpty)
          'vehicle_id': resolvedVehicleId,
      },
      parser: (data) =>
          BackendMappers.activeRideFromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> declineRide(String rideId, {String? reason}) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return;
    }

    await post(
      ApiEndpoints.rejectRide,
      data: {'ride_id': rideId, if (reason != null) 'reason': reason},
    );
  }

  Future<ActiveRide?> getActiveRide() async {
    if (useMock) {
      final data = await loadMockJson('active_ride.json');
      return ActiveRide.fromJson(data['data'] as Map<String, dynamic>);
    }

    return get(
      ApiEndpoints.activeRide,
      parser: (data) {
        if (data == null) return null;
        return BackendMappers.activeRideFromJson(
          data as Map<String, dynamic>,
        );
      },
    );
  }

  Future<ActiveRide> updateRideStatus(
    String rideId,
    String status, {
    String? otp,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final data = await loadMockJson('active_ride.json');
      final ride = ActiveRide.fromJson(data['data'] as Map<String, dynamic>);
      return ride.copyWith(status: status);
    }

    if (status == 'arrived') {
      final response = await post<Map<String, dynamic>>(
        ApiEndpoints.arrivedRide,
        data: {'ride_id': rideId},
        parser: (data) => data as Map<String, dynamic>,
      );
      return BackendMappers.activeRideFromJson(response);
    }

    if (status == 'started') {
      final code = otp?.trim();
      if (code == null || code.isEmpty) {
        throw const ValidationException('OTP is required to start the ride.');
      }
      final response = await post<Map<String, dynamic>>(
        ApiEndpoints.startRide,
        data: {'ride_id': rideId, 'otp': code},
        parser: (data) => data as Map<String, dynamic>,
      );
      return BackendMappers.activeRideFromJson(response);
    }

    throw ValidationException('Unsupported ride status: $status');
  }

  Future<PaymentBreakdown> completeRide(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final data = await loadMockJson('payment_breakdown.json');
      return PaymentBreakdown.fromJson(data['data'] as Map<String, dynamic>);
    }

    final response = await post<Map<String, dynamic>>(
      ApiEndpoints.endRide,
      data: {'ride_id': rideId},
      parser: (data) => data as Map<String, dynamic>,
    );

    return BackendMappers.paymentFromRide(response);
  }

  Future<Map<String, dynamic>> collectCashPayment(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final data = await loadMockJson('payment_breakdown.json');
      final breakdown = data['data'] as Map<String, dynamic>;
      return {
        ...breakdown,
        'success': true,
        'payment_status': 'COMPLETED',
        'payment_collected': true,
      };
    }

    return post<Map<String, dynamic>>(
      ApiEndpoints.collectPayment,
      data: {'ride_id': rideId, 'method': 'CASH'},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> createOnlinePaymentQr(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final data = await loadMockJson('payment_breakdown.json');
      final breakdown = data['data'] as Map<String, dynamic>;
      return {
        ...breakdown,
        'success': true,
        'payment_status': 'PENDING',
        'payment_collected': false,
        'qr_code_id': 'mock_qr_1',
        'short_url': 'https://rzp.io/rzp/mock-ride-payment',
        'image_url': null,
        'amount': breakdown['trip_fare'],
        'key_id': 'rzp_test_T9MSfwbXZfCFjC',
      };
    }

    return post<Map<String, dynamic>>(
      ApiEndpoints.collectPayment,
      data: {'ride_id': rideId, 'method': 'RAZORPAY'},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> checkOnlinePaymentStatus(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return {
        'success': true,
        'payment_status': 'COMPLETED',
        'payment_collected': true,
      };
    }

    return get<Map<String, dynamic>>(
      ApiEndpoints.collectPaymentStatus(rideId),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> ratePassenger(
    String rideId, {
    required int rating,
    String? comment,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }

    await post(
      ApiEndpoints.ratePassenger(rideId),
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  Future<RideSummary> getRideSummary(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final data = await loadMockJson('ride_summary.json');
      return RideSummary.fromJson(data['data'] as Map<String, dynamic>);
    }

    final history = await get<Map<String, dynamic>>(
      ApiEndpoints.rideHistory,
      queryParameters: {'page': 1, 'page_size': 50},
      parser: (data) => data as Map<String, dynamic>,
    );

    final items = history['items'] as List<dynamic>? ?? [];
    final ride = items.cast<Map<String, dynamic>>().firstWhere(
          (item) => item['id']?.toString() == rideId,
          orElse: () => <String, dynamic>{},
        );

    if (ride.isEmpty) {
      throw const ValidationException('Ride summary not found.');
    }

    return BackendMappers.rideSummaryFromJson(ride);
  }
}

final rideServiceProvider = Provider<RideService>((ref) {
  return RideService(
    ref.watch(localStorageProvider),
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
