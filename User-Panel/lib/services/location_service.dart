import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const defaultLat = 28.6139;
  static const defaultLng = 77.2090;

  static const indiaLatMin = 6.0;
  static const indiaLatMax = 37.6;
  static const indiaLngMin = 68.0;
  static const indiaLngMax = 97.5;

  /// iOS Simulator does not use your Mac's GPS/Wi‑Fi — it uses a fake GPS point
  /// (often San Francisco). Browser Google Maps on Mac uses network/IP location.
  static bool get isIOSSimulator {
    if (kIsWeb || !Platform.isIOS) return false;
    final env = Platform.environment;
    return env.containsKey('SIMULATOR_DEVICE_NAME') ||
        env.containsKey('SIMULATOR_HOST_HOME');
  }

  static bool isInIndia(double lat, double lng) {
    return lat >= indiaLatMin &&
        lat <= indiaLatMax &&
        lng >= indiaLngMin &&
        lng <= indiaLngMax;
  }

  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are off. Turn on GPS in Settings.',
        openSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission blocked. Enable it in Settings.',
        openSettings: true,
      );
    }

    if (permission == LocationPermission.denied) {
      throw LocationServiceException('Location permission denied');
    }

    if (Platform.isIOS) {
      final accuracyStatus = await Geolocator.getLocationAccuracy();
      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        await Geolocator.requestTemporaryFullAccuracy(
          purposeKey: 'RidePickup',
        );
      }
    }

    return true;
  }

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  LocationSettings _settings({Duration timeLimit = const Duration(seconds: 60)}) {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: false,
        timeLimit: timeLimit,
      );
    }
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: false,
        intervalDuration: const Duration(milliseconds: 500),
        timeLimit: timeLimit,
      );
    }
    return LocationSettings(
      accuracy: LocationAccuracy.best,
      timeLimit: timeLimit,
    );
  }

  Future<Position> getCurrentPosition({bool forceFresh = false}) async {
    // Simulator: use Mac network location (same idea as Google Maps in Safari).
    if (isIOSSimulator) {
      final network = await _fetchNetworkPosition();
      if (network != null) {
        return network;
      }
    }

    await ensurePermission();

    Position? lastKnown;
    if (!forceFresh) {
      lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final age = DateTime.now().difference(lastKnown.timestamp);
        if (age.inMinutes < 1 &&
            lastKnown.accuracy <= 150 &&
            isInIndia(lastKnown.latitude, lastKnown.longitude)) {
          return lastKnown;
        }
      }
    }

    try {
      final position = await _fetchFreshPosition();
      if (isInIndia(position.latitude, position.longitude)) {
        return position;
      }

      // Simulator GPS is often San Francisco — try network before failing.
      if (isIOSSimulator || kDebugMode) {
        final network = await _fetchNetworkPosition();
        if (network != null) {
          return network;
        }
      }

      _validatePosition(position);
      return position;
    } on LocationServiceException {
      rethrow;
    } on LocationServiceDisabledException {
      throw LocationServiceException(
        'Location services are off. Turn on GPS in Settings.',
        openSettings: true,
      );
    } on PermissionDeniedException {
      throw LocationServiceException('Location permission denied');
    } on TimeoutException {
      final network = await _networkFallbackAfterGpsFailure();
      if (network != null) return network;

      if (lastKnown != null && isInIndia(lastKnown.latitude, lastKnown.longitude)) {
        return lastKnown;
      }
      throw LocationServiceException(
        'Could not get GPS fix. Move outdoors or wait a few seconds and try again.',
      );
    } catch (_) {
      final network = await _networkFallbackAfterGpsFailure();
      if (network != null) return network;

      if (lastKnown != null && isInIndia(lastKnown.latitude, lastKnown.longitude)) {
        return lastKnown;
      }
      throw LocationServiceException(
        'Could not get your location. Check GPS and try again.',
      );
    }
  }

  Future<Position?> _networkFallbackAfterGpsFailure() async {
    if (!isIOSSimulator && !kDebugMode) return null;
    return _fetchNetworkPosition();
  }

  Future<Position> _fetchFreshPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _settings(),
      );
    } catch (_) {
      final stream = Geolocator.getPositionStream(locationSettings: _settings());
      return stream.timeout(const Duration(seconds: 45)).first;
    }
  }

  void _validatePosition(Position position) {
    if (!isInIndia(position.latitude, position.longitude)) {
      final hint = isIOSSimulator
          ? ' Simulator GPS is not your Mac location — enable Wi‑Fi and retry.'
          : '';
      throw LocationServiceException(
        'GPS shows a location outside India.$hint',
      );
    }
  }

  /// Approximate location from your network IP (Wi‑Fi), like Google Maps in a browser.
  Future<Position?> _fetchNetworkPosition() async {
    final sources = <Future<Position?> Function()>[
      _fetchFromIpInfo,
      _fetchFromIpApiCo,
    ];

    for (final source in sources) {
      final position = await source();
      if (position != null && isInIndia(position.latitude, position.longitude)) {
        return position;
      }
    }
    return null;
  }

  Future<Position?> _fetchFromIpInfo() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 12);
      final request = await client.getUrl(Uri.parse('https://ipinfo.io/json'));
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final loc = data['loc'] as String?;
      if (loc == null || !loc.contains(',')) return null;

      final parts = loc.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      return _positionFrom(lat, lng, accuracyMeters: 2500);
    } catch (_) {
      return null;
    }
  }

  Future<Position?> _fetchFromIpApiCo() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 12);
      final request = await client.getUrl(Uri.parse('https://ipapi.co/json/'));
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final lat = data['latitude'];
      final lng = data['longitude'];
      if (lat == null || lng == null) return null;

      return _positionFrom(
        (lat as num).toDouble(),
        (lng as num).toDouble(),
        accuracyMeters: 2500,
      );
    } catch (_) {
      return null;
    }
  }

  Position _positionFrom(
    double lat,
    double lng, {
    required double accuracyMeters,
  }) {
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: accuracyMeters,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  Future<Position?> tryGetCurrentPosition({bool forceFresh = false}) async {
    try {
      return await getCurrentPosition(forceFresh: forceFresh);
    } catch (_) {
      return null;
    }
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}

class LocationServiceException implements Exception {
  LocationServiceException(this.message, {this.openSettings = false});

  final String message;
  final bool openSettings;

  @override
  String toString() => message;
}
