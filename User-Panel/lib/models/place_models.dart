class PlaceSuggestion {
  const PlaceSuggestion({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.source = 'google',
  });

  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String source;

  String get displayLabel => address.isNotEmpty ? address : name;

  bool get hasCoordinates => latitude != null && longitude != null;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        source: json['source'] as String? ?? 'google',
      );
}

class SelectedPlace {
  const SelectedPlace({
    required this.label,
    this.latitude,
    this.longitude,
  });

  final String label;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;
}

class LatLngPoint {
  const LatLngPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) => LatLngPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class RoutePoint {
  const RoutePoint({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        address: json['address'] as String? ?? '',
      );
}

class DirectionsResult {
  const DirectionsResult({
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.durationMin,
    required this.path,
    this.source = 'google',
  });

  final RoutePoint pickup;
  final RoutePoint dropoff;
  final double distanceKm;
  final double durationMin;
  final List<LatLngPoint> path;
  final String source;

  factory DirectionsResult.fromJson(Map<String, dynamic> json) => DirectionsResult(
        pickup: RoutePoint.fromJson(json['pickup'] as Map<String, dynamic>),
        dropoff: RoutePoint.fromJson(json['dropoff'] as Map<String, dynamic>),
        distanceKm: (json['distance_km'] as num).toDouble(),
        durationMin: (json['duration_min'] as num).toDouble(),
        path: (json['path'] as List<dynamic>)
            .map((e) => LatLngPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: json['source'] as String? ?? 'google',
      );
}

class TripBookingState {
  const TripBookingState({
    this.pickup,
    this.dropoff,
    this.route,
    this.activeRideId,
  });

  final SelectedPlace? pickup;
  final SelectedPlace? dropoff;
  final DirectionsResult? route;
  final String? activeRideId;

  TripBookingState copyWith({
    SelectedPlace? pickup,
    SelectedPlace? dropoff,
    DirectionsResult? route,
    String? activeRideId,
    bool clearRoute = false,
  }) =>
      TripBookingState(
        pickup: pickup ?? this.pickup,
        dropoff: dropoff ?? this.dropoff,
        route: clearRoute ? null : (route ?? this.route),
        activeRideId: activeRideId ?? this.activeRideId,
      );
}
