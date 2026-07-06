import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/models/trip_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class TripService extends BaseApiService {
  TripService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<List<Trip>> getTrips({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final list = await loadMockJsonList('trips.json');
      return list
          .map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .where((trip) {
        if (status == null || status == 'All') return true;
        return trip.status.toLowerCase() == status.toLowerCase();
      }).toList();
    }

    return get(
      ApiEndpoints.rideHistory,
      queryParameters: {
        'page': page,
        'page_size': limit,
      },
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['items'] as List<dynamic>? ?? [];
        return list
            .map((e) => BackendMappers.tripFromRideJson(
                  e as Map<String, dynamic>,
                ))
            .where((trip) {
          if (status == null || status == 'All') return true;
          return trip.status.toLowerCase() == status.toLowerCase();
        }).toList();
      },
    );
  }

  Future<TripDetail> getTripDetail(String id) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final data = await loadMockJson('trip_detail.json');
      return TripDetail.fromJson(data['data'] as Map<String, dynamic>);
    }

    final history = await get<Map<String, dynamic>>(
      ApiEndpoints.rideHistory,
      queryParameters: {'page': 1, 'page_size': 100},
      parser: (data) => data as Map<String, dynamic>,
    );

    final items = history['items'] as List<dynamic>? ?? [];
    final ride = items.cast<Map<String, dynamic>>().firstWhere(
          (item) => item['id']?.toString() == id,
          orElse: () => <String, dynamic>{},
        );

    return BackendMappers.tripDetailFromRideJson(ride);
  }

  Future<EarningsSummary> getEarnings({String period = 'weekly'}) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final data = await loadMockJson('earnings.json');
      return EarningsSummary.fromJson(data['data'] as Map<String, dynamic>);
    }

    return get(
      ApiEndpoints.earnings,
      queryParameters: {'period': period},
      parser: (data) =>
          BackendMappers.earningsFromJson(data as Map<String, dynamic>),
    );
  }

  Future<({EarningsSummary summary, List<EarningsRideItem> rides})>
      getEarningsBundle({String period = 'weekly'}) async {
    if (useMock) {
      final summary = await getEarnings(period: period);
      return (summary: summary, rides: const <EarningsRideItem>[]);
    }

    return get(
      ApiEndpoints.earnings,
      queryParameters: {'period': period},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return (
          summary: BackendMappers.earningsFromJson(map),
          rides: BackendMappers.earningsRidesFromJson(map),
        );
      },
    );
  }

  Future<EarningsSummary> getEarningsSummary() async {
    if (useMock) {
      return getEarnings();
    }

    Future<Map<String, dynamic>> fetchRaw(String period) {
      return get(
        ApiEndpoints.earnings,
        queryParameters: {'period': period},
        parser: (data) => data as Map<String, dynamic>,
      );
    }

    final results = await Future.wait([
      fetchRaw('daily'),
      fetchRaw('weekly'),
      fetchRaw('monthly'),
    ]);

    double amount(Map<String, dynamic> json) =>
        (json['net_earnings'] as num?)?.toDouble() ??
        (json['total_earnings'] as num?)?.toDouble() ??
        0;

    int trips(Map<String, dynamic> json) =>
        (json['total_rides'] as num?)?.toInt() ?? 0;

    return EarningsSummary(
      todayEarnings: amount(results[0]),
      weeklyEarnings: amount(results[1]),
      monthlyEarnings: amount(results[2]),
      totalTrips: trips(results[1]),
      todayTrips: trips(results[0]),
    );
  }
}

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
