import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class RoadRoute {
  const RoadRoute({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });

  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;
}

class DirectionsService extends BaseApiService {
  DirectionsService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  static bool hasCoordinates(double lat, double lng) => lat != 0 || lng != 0;

  static String coordinatesQuery(double lat, double lng) => '$lat,$lng';

  Future<RoadRoute> getRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String pickupAddress = '',
    String dropoffAddress = '',
  }) {
    return getDirectionsByCoordinates(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
    );
  }

  Future<RoadRoute> getDirectionsByCoordinates({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String pickupAddress = '',
    String dropoffAddress = '',
  }) async {
    final pickup = hasCoordinates(pickupLat, pickupLng)
        ? coordinatesQuery(pickupLat, pickupLng)
        : (pickupAddress.isNotEmpty
            ? pickupAddress
            : coordinatesQuery(pickupLat, pickupLng));
    final dropoff = hasCoordinates(dropoffLat, dropoffLng)
        ? coordinatesQuery(dropoffLat, dropoffLng)
        : (dropoffAddress.isNotEmpty
            ? dropoffAddress
            : coordinatesQuery(dropoffLat, dropoffLng));

    final data = await get<Map<String, dynamic>>(
      '/public/places/directions',
      queryParameters: {'pickup': pickup, 'dropoff': dropoff},
      parser: (raw) => raw as Map<String, dynamic>,
    );

    final path = (data['path'] as List<dynamic>? ?? [])
        .map((point) {
          final map = point as Map<String, dynamic>;
          return LatLng(
            (map['lat'] as num).toDouble(),
            (map['lng'] as num).toDouble(),
          );
        })
        .toList();

    return RoadRoute(
      points: path,
      distanceKm: (data['distance_km'] as num?)?.toDouble() ?? 0,
      durationMin: (data['duration_min'] as num?)?.toDouble() ?? 0,
    );
  }
}

final directionsServiceProvider = Provider<DirectionsService>((ref) {
  return DirectionsService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
