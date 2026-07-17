import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/map_marker_icons.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/services/location_service.dart';
import 'package:wavego_user/services/places_service.dart';

/// Lets the parent screen call "my location" while keeping the FAB above the sheet.
class LiveTrackingMapController {
  Future<void> Function()? _goToMyLocation;

  void _bind(Future<void> Function() fn) => _goToMyLocation = fn;

  void _unbind(Future<void> Function() fn) {
    if (_goToMyLocation == fn) _goToMyLocation = null;
  }

  Future<void> goToMyLocation() async {
    final fn = _goToMyLocation;
    if (fn != null) await fn();
  }
}

/// Live map after captain accepts — Rapido-style pickup + captain tracking.
class LiveTrackingMap extends ConsumerStatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.ride,
    this.driverLat,
    this.driverLng,
    this.driverHeading,
    this.fallbackVehicleSlug,
    this.tripRoute,
    this.controller,
  });

  final UserActiveRide ride;
  final double? driverLat;
  final double? driverLng;
  /// Degrees from north, clockwise (GPS / device heading).
  final double? driverHeading;
  final String? fallbackVehicleSlug;
  final DirectionsResult? tripRoute;
  final LiveTrackingMapController? controller;

  @override
  ConsumerState<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends ConsumerState<LiveTrackingMap> {
  GoogleMapController? _controller;
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;
  List<LatLng> _tripRoutePoints = [];
  List<LatLng> _driverLegPoints = [];
  bool _loadingRoutes = true;
  double? _prevLat;
  double? _prevLng;
  double _bearing = 0;

  /// Captain still heading to pickup (Rapido pre-trip view).
  bool get _enRouteToPickup => !widget.ride.isInProgress;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(goToMyLocation);
    _loadMarkerIcons();
    Future.microtask(_loadRoutes);
    _syncBearingFromProps();
  }

  @override
  void didUpdateWidget(covariant LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind(goToMyLocation);
      widget.controller?._bind(goToMyLocation);
    }
    if (widget.driverLat != oldWidget.driverLat ||
        widget.driverLng != oldWidget.driverLng ||
        widget.driverHeading != oldWidget.driverHeading ||
        widget.ride.driverLat != oldWidget.ride.driverLat ||
        widget.ride.driverLng != oldWidget.ride.driverLng ||
        widget.ride.status != oldWidget.ride.status) {
      _syncBearingFromProps();
      _loadDriverLeg();
      _fitCamera();
    }
    if (widget.tripRoute != oldWidget.tripRoute ||
        widget.ride.pickupLat != oldWidget.ride.pickupLat ||
        widget.ride.dropoffLat != oldWidget.ride.dropoffLat ||
        widget.ride.stops != oldWidget.ride.stops ||
        widget.ride.status != oldWidget.ride.status) {
      _loadRoutes();
    }
    if (widget.ride.vehicleTypeSlug != oldWidget.ride.vehicleTypeSlug ||
        widget.fallbackVehicleSlug != oldWidget.fallbackVehicleSlug) {
      _loadMarkerIcons();
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(goToMyLocation);
    super.dispose();
  }

  void _syncBearingFromProps() {
    final heading = widget.driverHeading;
    if (heading != null && heading.isFinite && heading >= 0) {
      _bearing = heading % 360;
    }

    final lat = _dLat;
    final lng = _dLng;
    if (lat == null || lng == null) return;

    if (_prevLat != null &&
        _prevLng != null &&
        (heading == null || !heading.isFinite || heading < 0)) {
      final moved = (lat - _prevLat!).abs() > 0.00001 ||
          (lng - _prevLng!).abs() > 0.00001;
      if (moved) {
        _bearing = _bearingBetween(_prevLat!, _prevLng!, lat, lng);
      }
    } else if (_prevLat == null &&
        (heading == null || !heading.isFinite) &&
        _driverLegPoints.length >= 2) {
      _bearing = _bearingBetween(
        lat,
        lng,
        _driverLegPoints[1].latitude,
        _driverLegPoints[1].longitude,
      );
    }

    _prevLat = lat;
    _prevLng = lng;
  }

  static double _bearingBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLng);
    final bearingDeg = math.atan2(y, x) * 180 / math.pi;
    return (bearingDeg + 360) % 360;
  }

  String get _vehicleSlug =>
      widget.ride.vehicleTypeSlug ?? widget.fallbackVehicleSlug ?? 'cab';

  double? get _dLat {
    final live = widget.driverLat ?? widget.ride.driverLat;
    if (live != null && live != 0) return live;
    return null;
  }

  double? get _dLng {
    final live = widget.driverLng ?? widget.ride.driverLng;
    if (live != null && live != 0) return live;
    return null;
  }

  bool get _hasDriverLocation => _dLat != null && _dLng != null;

  List<LatLng> _latLngsFromDirections(DirectionsResult route) {
    return route.path.map((p) => LatLng(p.lat, p.lng)).toList();
  }

  Future<void> _loadMarkerIcons() async {
    try {
      // Captain location MUST use bike_topdown.png — never the capsule fallback.
      final bike = await MapMarkerIcons.captainBikeMarker();
      final pickup = await MapMarkerIcons.pickupLabeledMarker();
      final drop = await MapMarkerIcons.dropoffLabeledMarker();
      if (!mounted) return;
      setState(() {
        _driverIcon = bike;
        _pickupIcon = pickup;
        _dropoffIcon = drop;
      });
    } catch (e, st) {
      debugPrint('LiveTrackingMap: marker load failed: $e\n$st');
      // Still try bike alone so capsule never replaces it silently.
      try {
        final bike = await MapMarkerIcons.captainBikeMarker();
        if (mounted) setState(() => _driverIcon = bike);
      } catch (_) {}
    }
  }

  List<SelectedPlace> _stopPlaces() {
    final fromRoute = widget.tripRoute?.stops ?? const <RoutePoint>[];
    if (fromRoute.isNotEmpty) {
      return [
        for (final s in fromRoute)
          SelectedPlace(
            label: s.address,
            latitude: s.lat,
            longitude: s.lng,
          ),
      ];
    }
    return [
      for (final s in widget.ride.stops.where((s) => s.hasCoordinates))
        SelectedPlace(
          label: s.address,
          latitude: s.lat,
          longitude: s.lng,
        ),
    ];
  }

  List<RoutePoint> _stopPoints() {
    final fromRoute = widget.tripRoute?.stops ?? const <RoutePoint>[];
    if (fromRoute.isNotEmpty) return fromRoute;
    return [
      for (final s in widget.ride.stops.where((s) => s.hasCoordinates))
        RoutePoint(lat: s.lat, lng: s.lng, address: s.address),
    ];
  }

  Future<void> _loadRoutes() async {
    setState(() => _loadingRoutes = true);

    List<LatLng> tripPoints = [];
    final stopPlaces = _stopPlaces();
    // Full trip route only once ride has started (pickup → stops → drop).
    if (!_enRouteToPickup) {
      final cached = widget.tripRoute;
      final canUseCached = cached != null &&
          cached.path.length >= 2 &&
          (stopPlaces.isEmpty || cached.stops.isNotEmpty);
      if (canUseCached) {
        tripPoints = _latLngsFromDirections(cached);
      } else if (widget.ride.pickupLat != null &&
          widget.ride.pickupLng != null &&
          widget.ride.dropoffLat != null &&
          widget.ride.dropoffLng != null) {
        try {
          final route =
              await ref.read(placesServiceProvider).getDirectionsByCoordinates(
                    pickupLat: widget.ride.pickupLat!,
                    pickupLng: widget.ride.pickupLng!,
                    dropoffLat: widget.ride.dropoffLat!,
                    dropoffLng: widget.ride.dropoffLng!,
                    pickupAddress: widget.ride.pickupAddress,
                    dropoffAddress: widget.ride.dropoffAddress,
                    stops: stopPlaces,
                  );
          tripPoints = _latLngsFromDirections(route);
        } catch (_) {}
      }
    }

    if (!mounted) return;
    setState(() {
      _tripRoutePoints = tripPoints;
      _loadingRoutes = false;
    });
    await _loadDriverLeg();
    _fitCamera();
  }

  Future<void> _loadDriverLeg() async {
    final dLat = _dLat;
    final dLng = _dLng;
    if (dLat == null || dLng == null) {
      if (mounted) setState(() => _driverLegPoints = []);
      return;
    }

    final targetLat = _enRouteToPickup
        ? widget.ride.pickupLat
        : widget.ride.dropoffLat;
    final targetLng = _enRouteToPickup
        ? widget.ride.pickupLng
        : widget.ride.dropoffLng;
    if (targetLat == null || targetLng == null) return;

    List<LatLng> points;
    try {
      final leg =
          await ref.read(placesServiceProvider).getDirectionsByCoordinates(
                pickupLat: dLat,
                pickupLng: dLng,
                dropoffLat: targetLat,
                dropoffLng: targetLng,
              );
      points = _latLngsFromDirections(leg);
    } catch (_) {
      points = [LatLng(dLat, dLng), LatLng(targetLat, targetLng)];
    }

    if (!mounted) return;

    // Face along the road when GPS heading is missing.
    final heading = widget.driverHeading;
    var nextBearing = _bearing;
    if ((heading == null || !heading.isFinite || heading < 0) &&
        points.length >= 2) {
      nextBearing = _bearingBetween(
        points[0].latitude,
        points[0].longitude,
        points[1].latitude,
        points[1].longitude,
      );
    } else if (heading != null && heading.isFinite && heading >= 0) {
      nextBearing = heading % 360;
    }

    setState(() {
      _driverLegPoints = points;
      _bearing = nextBearing;
    });
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Pickup only while captain is heading there; after start show Drop only.
    if (_enRouteToPickup &&
        widget.ride.pickupLat != null &&
        widget.ride.pickupLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!),
          icon: _pickupIcon ?? MapMarkerIcons.pickupMarker,
          anchor: const Offset(0.5, 1.0),
          zIndex: 2,
        ),
      );
    }

    if (!_enRouteToPickup &&
        widget.ride.dropoffLat != null &&
        widget.ride.dropoffLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(widget.ride.dropoffLat!, widget.ride.dropoffLng!),
          icon: _dropoffIcon ?? MapMarkerIcons.dropoffMarker,
          anchor: const Offset(0.5, 1.0),
          zIndex: 1,
        ),
      );
    }

    final stops = _stopPoints();
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];
      markers.add(
        Marker(
          markerId: MarkerId('stop_${i + 1}'),
          position: LatLng(stop.lat, stop.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          anchor: const Offset(0.5, 1.0),
          zIndex: 1,
          infoWindow: InfoWindow(title: 'Stop ${i + 1}', snippet: stop.address),
        ),
      );
    }

    // Captain — ONLY bike_topdown.png (wait until loaded; no capsule)
    if (_hasDriverLocation && _driverIcon != null) {
      final vehicleLabel = widget.ride.vehicleTypeName ?? 'Captain';
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(_dLat!, _dLng!),
          icon: _driverIcon!,
          anchor: const Offset(0.5, 0.5),
          rotation: _bearing,
          flat: true,
          zIndex: 5,
          infoWindow: InfoWindow(
            title: widget.ride.driverName ?? vehicleLabel,
            snippet: widget.ride.vehicleNumber,
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> get _polylines {
    final lines = <Polyline>{};

    if (!_enRouteToPickup && _tripRoutePoints.length >= 2) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('trip_route'),
          points: _tripRoutePoints,
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 4,
        ),
      );
    }

    // Captain → pickup (or → drop once started)
    if (_driverLegPoints.length >= 2) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('driver_leg'),
          points: _driverLegPoints,
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return lines;
  }

  LatLng get _initialTarget {
    if (_hasDriverLocation) return LatLng(_dLat!, _dLng!);
    if (widget.ride.pickupLat != null && widget.ride.pickupLng != null) {
      return LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!);
    }
    return const LatLng(28.6139, 77.209);
  }

  Future<void> _fitCamera() async {
    final controller = _controller;
    if (controller == null) return;

    final points = <LatLng>[];
    if (_enRouteToPickup &&
        widget.ride.pickupLat != null &&
        widget.ride.pickupLng != null) {
      points.add(LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!));
    }
    if (_hasDriverLocation) {
      points.add(LatLng(_dLat!, _dLng!));
    }
    if (!_enRouteToPickup &&
        widget.ride.dropoffLat != null &&
        widget.ride.dropoffLng != null) {
      points.add(LatLng(widget.ride.dropoffLat!, widget.ride.dropoffLng!));
    }
    for (final stop in _stopPoints()) {
      points.add(LatLng(stop.lat, stop.lng));
    }

    if (points.isEmpty) return;
    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 15),
      );
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }
    // Avoid zero-size bounds when points are almost identical.
    if ((maxLat - minLat).abs() < 0.0002) {
      minLat -= 0.001;
      maxLat += 0.001;
    }
    if ((maxLng - minLng).abs() < 0.0002) {
      minLng -= 0.001;
      maxLng += 0.001;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        72,
      ),
    );
  }

  Future<void> goToMyLocation() async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition(forceFresh: true);
      if (!mounted) return;
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } on LocationServiceException catch (e) {
      if (mounted) context.showSnackBar(e.message, isError: true);
    } catch (_) {
      if (mounted) {
        context.showSnackBar('Could not get current location', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _initialTarget, zoom: 14.5),
          onMapCreated: (controller) {
            _controller = controller;
            _fitCamera();
          },
          markers: _markers,
          polylines: _polylines,
          // OFF — blue GPS dot was covering captain bike and looked like a "capsule"
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
        if (_loadingRoutes)
          const Positioned(
            top: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        if (_enRouteToPickup && !_hasDriverLocation)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 56,
            left: 16,
            right: 16,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Waiting for captain location…',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
