import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/models/coupon_models.dart';
import 'package:wavego_user/models/fare_models.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

class PlacesService extends BaseApiService {
  PlacesService(super.dio);

  static final Dio _geoHttp = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'Bull Wave Rides-User/1.0 (support@ridebook.com)',
      },
    ),
  );

  static const _mockSuggestions = [
    PlaceSuggestion(
      id: 'mock-1',
      name: 'Connaught Place',
      address: 'Connaught Place, New Delhi',
      latitude: 28.6315,
      longitude: 77.2167,
      source: 'mock',
    ),
    PlaceSuggestion(
      id: 'mock-2',
      name: 'IGI Airport',
      address: 'Indira Gandhi International Airport, New Delhi',
      latitude: 28.5562,
      longitude: 77.1000,
      source: 'mock',
    ),
    PlaceSuggestion(
      id: 'mock-3',
      name: 'Cyber City',
      address: 'Cyber City, Gurugram',
      latitude: 28.4946,
      longitude: 77.0889,
      source: 'mock',
    ),
  ];

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final lower = trimmed.toLowerCase();
      return _mockSuggestions
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                p.address.toLowerCase().contains(lower),
          )
          .toList();
    }

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.placesSearch,
      queryParameters: {'q': trimmed, 'limit': 8, 'country': 'in'},
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return (data['results'] as List<dynamic>? ?? [])
        .map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DirectionsResult> getDirections({
    required SelectedPlace pickup,
    required SelectedPlace dropoff,
    List<SelectedPlace> stops = const [],
  }) async {
    final pickupQuery = _directionsQuery(pickup);
    final dropoffQuery = _directionsQuery(dropoff);
    final filledStops = stops
        .where((s) => s.label.trim().isNotEmpty && s.hasCoordinates)
        .take(3)
        .toList();

    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return DirectionsResult(
        pickup: RoutePoint(lat: 28.6315, lng: 77.2167, address: pickup.label),
        dropoff: RoutePoint(lat: 28.5562, lng: 77.1000, address: dropoff.label),
        stops: [
          for (final s in filledStops)
            RoutePoint(
              lat: s.latitude!,
              lng: s.longitude!,
              address: s.label,
            ),
        ],
        distanceKm: 18.5 + filledStops.length * 3,
        durationMin: 42 + filledStops.length * 8.0,
        path: const [
          LatLngPoint(lat: 28.6315, lng: 77.2167),
          LatLngPoint(lat: 28.6000, lng: 77.1500),
          LatLngPoint(lat: 28.5562, lng: 77.1000),
        ],
        source: 'mock',
      );
    }

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.placesDirections,
      queryParameters: {
        'pickup': pickupQuery,
        'dropoff': dropoffQuery,
        if (filledStops.isNotEmpty)
          'waypoints': filledStops.map(_directionsQuery).join('|'),
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return DirectionsResult.fromJson(data);
  }

  Future<DirectionsResult> getDirectionsByCoordinates({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String pickupAddress = '',
    String dropoffAddress = '',
    List<SelectedPlace> stops = const [],
  }) {
    return getDirections(
      pickup: SelectedPlace(
        label: pickupAddress.isNotEmpty ? pickupAddress : '$pickupLat,$pickupLng',
        latitude: pickupLat,
        longitude: pickupLng,
      ),
      dropoff: SelectedPlace(
        label: dropoffAddress.isNotEmpty ? dropoffAddress : '$dropoffLat,$dropoffLng',
        latitude: dropoffLat,
        longitude: dropoffLng,
      ),
      stops: stops,
    );
  }

  Future<SelectedPlace> reverseGeocode(double lat, double lng) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _reverseGeocodeWithFallback(lat, lng);
    }

    try {
      final data = await get<Map<String, dynamic>>(
        ApiEndpoints.placesReverse,
        queryParameters: {'lat': lat, 'lng': lng},
        parser: (raw) => raw as Map<String, dynamic>,
      );

      final address = data['address'] as String?;

      if (address != null && address.trim().isNotEmpty) {
        return SelectedPlace(
          label: address.trim(),
          latitude: lat,
          longitude: lng,
        );
      }

      return _reverseGeocodeWithFallback(lat, lng);
    } catch (_) {
      return _reverseGeocodeWithFallback(lat, lng);
    }
  }

  Future<SelectedPlace> _reverseGeocodeWithFallback(double lat, double lng) async {
    final nominatim = await _nominatimReverseGeocode(lat, lng);
    if (nominatim != null) return nominatim;

    return SelectedPlace(
      label: 'Current location',
      latitude: lat,
      longitude: lng,
    );
  }

  Future<SelectedPlace?> _nominatimReverseGeocode(double lat, double lng) async {
    try {
      final response = await _geoHttp.get<dynamic>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': '$lat',
          'lon': '$lng',
          'format': 'json',
          'addressdetails': '1',
        },
      );
      if (response.statusCode != 200 || response.data == null) return null;

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data as String) as Map<String, dynamic>;
      final display = data['display_name'] as String?;
      if (display == null || display.trim().isEmpty) return null;

      return SelectedPlace(
        label: _shortAddress(
          display.trim(),
          data['address'] as Map<String, dynamic>?,
        ),
        latitude: double.tryParse('${data['lat']}') ?? lat,
        longitude: double.tryParse('${data['lon']}') ?? lng,
      );
    } catch (_) {
      return null;
    }
  }

  String _shortAddress(String display, Map<String, dynamic>? address) {
    if (address != null) {
      final parts = <String>[
        if (address['house_number'] != null) '${address['house_number']}',
        if (address['road'] != null) '${address['road']}',
        if (address['suburb'] != null)
          '${address['suburb']}'
        else if (address['neighbourhood'] != null)
          '${address['neighbourhood']}',
        if (address['city'] != null)
          '${address['city']}'
        else if (address['town'] != null)
          '${address['town']}'
        else if (address['village'] != null)
          '${address['village']}',
        if (address['state'] != null) '${address['state']}',
      ].where((part) => part.trim().isNotEmpty).toList();

      if (parts.isNotEmpty) {
        return parts.take(3).join(', ');
      }
    }

    final segments = display
        .split(',')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.length <= 3) return display;
    return segments.take(3).join(', ');
  }

  /// Resolve Google place_id to coordinates (search results often lack lat/lng).
  Future<PlaceSuggestion> resolvePlaceDetails(String placeId) async {
    if (useMock) {
      return _mockSuggestions.firstWhere(
        (p) => p.id == placeId,
        orElse: () => _mockSuggestions.first,
      );
    }

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.placesDetails,
      queryParameters: {'place_id': placeId},
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return PlaceSuggestion(
      id: data['id'] as String? ?? placeId,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      source: data['source'] as String? ?? 'google',
    );
  }

  /// Prefer lat/lng for GPS picks — text labels like "Current location" fail geocoding.
  String _directionsQuery(SelectedPlace place) {
    if (place.hasCoordinates) {
      return '${place.latitude},${place.longitude}';
    }
    return place.label;
  }
}

class RideBookingService extends BaseApiService {
  RideBookingService(super.dio);

  Future<List<RideCoupon>> listCoupons() async {
    if (useMock) {
      return const [
        RideCoupon(
          id: 'mock-1',
          code: 'GOFREE',
          title: 'Free ride discount',
          discountType: 'flat',
          discountValue: 10,
        ),
      ];
    }

    final data = await get<List<dynamic>>(
      ApiEndpoints.userCoupons,
      parser: (raw) => raw as List<dynamic>,
    );
    return data
        .map((item) => RideCoupon.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppliedCoupon> validateCoupon({
    required String code,
    required double orderAmount,
  }) async {
    if (useMock) {
      final coupon = RideCoupon(
        id: 'mock',
        code: code.toUpperCase(),
        title: 'Mock offer',
        discountType: 'flat',
        discountValue: 10,
      );
      final discount = 10.0;
      return AppliedCoupon(
        coupon: coupon,
        discountAmount: discount,
        finalAmount: (orderAmount - discount).clamp(0, double.infinity),
      );
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.validateCoupon,
      data: {
        'code': code,
        'order_amount': orderAmount,
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return AppliedCoupon(
      coupon: RideCoupon.fromJson(data['coupon'] as Map<String, dynamic>),
      discountAmount: (data['discount_amount'] as num).toDouble(),
      finalAmount: (data['final_amount'] as num).toDouble(),
    );
  }

  Future<RideFareEstimateResult> estimateRide({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String serviceGroup = 'ride',
    double? rentalHours,
    double? distanceKm,
    double? durationMin,
    List<SelectedPlace> stops = const [],
  }) async {
    if (useMock) {
      return const RideFareEstimateResult(
        discountPercent: 0,
        quotes: {},
      );
    }

    final filledStops = stops
        .where((s) => s.label.trim().isNotEmpty && s.hasCoordinates)
        .take(3)
        .toList();

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.rideEstimate,
      data: {
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'service_group': serviceGroup,
        if (rentalHours != null) 'rental_hours': rentalHours,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMin != null) 'duration_min': durationMin,
        if (filledStops.isNotEmpty)
          'stops': [
            for (var i = 0; i < filledStops.length; i++)
              {
                'address': filledStops[i].label,
                'lat': filledStops[i].latitude,
                'lng': filledStops[i].longitude,
                'sequence': i + 1,
              },
          ],
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );

    final vehicleTypes = data['vehicle_types'] as List<dynamic>? ?? [];
    final quotes = <String, VehicleFareQuote>{};
    for (final item in vehicleTypes) {
      if (item is Map<String, dynamic>) {
        final quote = VehicleFareQuote.fromJson(item);
        if (quote.vehicleTypeId.isNotEmpty) {
          quotes[quote.vehicleTypeId.toLowerCase()] = quote;
        }
      }
    }

    return RideFareEstimateResult(
      discountPercent: (data['discount_percent'] as num?)?.toDouble() ?? 0,
      quotes: quotes,
      distanceKm: (data['distance_km'] as num?)?.toDouble(),
      durationMin: (data['duration_min'] as num?)?.toDouble(),
    );
  }

  Future<Map<String, dynamic>> bookRide({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String paymentMethod = 'CASH',
    String? promoCode,
    String? vehicleCategoryId,
    double? rentalHours,
    DateTime? scheduledAt,
    bool womenSafetyEnabled = false,
    bool preferWomenRiders = false,
    double? distanceKm,
    double? durationMin,
    List<SelectedPlace>? stops,
    String rideType = 'NORMAL',
    String? companyId,
    String? employeeId,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return {
        'id': 'mock-ride-1',
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'status': 'SEARCHING',
        'fare_estimate': 120.0,
      };
    }

    return post<Map<String, dynamic>>(
      ApiEndpoints.bookRide,
      data: {
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'payment_method': paymentMethod,
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
        if (vehicleCategoryId != null) 'vehicle_category_id': vehicleCategoryId,
        if (rentalHours != null) 'rental_hours': rentalHours,
        if (scheduledAt != null) 'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'women_safety_enabled': womenSafetyEnabled,
        'prefer_women_riders': preferWomenRiders,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMin != null) 'duration_min': durationMin,
        if (stops != null && stops.isNotEmpty)
          'stops': [
            for (var i = 0; i < stops.length && i < 3; i++)
              {
                'address': stops[i].label,
                'lat': stops[i].latitude ?? 0,
                'lng': stops[i].longitude ?? 0,
                'sequence': i + 1,
              },
          ],
        'ride_type': rideType,
        if (companyId != null) 'company_id': companyId,
        if (employeeId != null) 'employee_id': employeeId,
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>?> getActiveRide() async {
    if (useMock) return null;

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.rides,
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final active = data['active'];
    if (active is Map<String, dynamic>) return active;
    return null;
  }

  Future<void> cancelRide(
    String rideId, {
    String reason = 'Cancelled by user',
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return;
    }

    await post(
      ApiEndpoints.cancelRide,
      data: {
        'ride_id': rideId,
        'reason': reason,
      },
    );
  }

  Future<Map<String, dynamic>> continueWithAllRiders(String rideId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return {
        'id': rideId,
        'status': 'SEARCHING_DRIVER',
        'allow_all_riders': true,
      };
    }

    return post<Map<String, dynamic>>(
      ApiEndpoints.continueWithAllRiders,
      data: {'ride_id': rideId},
      parser: (raw) => raw as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> triggerRideSos(
    String rideId, {
    double? lat,
    double? lng,
    String? message,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'is_emergency': true,
        'message': 'Emergency contacts and support have been notified.',
      };
    }

    return post<Map<String, dynamic>>(
      ApiEndpoints.rideSos(rideId),
      data: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (message != null && message.isNotEmpty) 'message': message,
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );
  }

  Future<void> rateRide(
    String rideId, {
    required int rating,
    String? comment,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }

    await post(
      ApiEndpoints.rateRide(rideId),
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}

final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService(ref.watch(dioClientProvider).dio);
});

final rideBookingServiceProvider = Provider<RideBookingService>((ref) {
  return RideBookingService(ref.watch(dioClientProvider).dio);
});
