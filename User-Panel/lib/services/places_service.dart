import 'dart:convert';
import 'dart:io' show HttpClient;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

class PlacesService extends BaseApiService {
  PlacesService(super.dio);

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
  }) async {
    final pickupQuery = _directionsQuery(pickup);
    final dropoffQuery = _directionsQuery(dropoff);

    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return DirectionsResult(
        pickup: RoutePoint(lat: 28.6315, lng: 77.2167, address: pickup.label),
        dropoff: RoutePoint(lat: 28.5562, lng: 77.1000, address: dropoff.label),
        distanceKm: 18.5,
        durationMin: 42,
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
      queryParameters: {'pickup': pickupQuery, 'dropoff': dropoffQuery},
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return DirectionsResult.fromJson(data);
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
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 12);
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {'lat': '$lat', 'lon': '$lng', 'format': 'json', 'addressdetails': '1'},
      );
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'WaveGo-User/1.0 (support@ridebook.com)');
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
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

  Future<Map<String, dynamic>> bookRide({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String paymentMethod = 'CASH',
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
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );
  }
}

final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService(ref.watch(dioClientProvider).dio);
});

final rideBookingServiceProvider = Provider<RideBookingService>((ref) {
  return RideBookingService(ref.watch(dioClientProvider).dio);
});
