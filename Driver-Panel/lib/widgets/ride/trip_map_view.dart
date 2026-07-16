import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/geo_distance.dart';
import 'package:wavego_driver/core/utils/map_marker_icons.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/services/directions_service.dart';
import 'package:wavego_driver/widgets/ride/trip_speed_eta_overlay.dart';

typedef TripMetricsCallback = void Function({
  double? speedKmh,
  int? etaMinutes,
  double? distanceMeters,
});

/// Lets ActiveTripScreen host the my-location FAB above the bottom sheet.
class TripMapController {
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

class TripMapView extends ConsumerStatefulWidget {
  const TripMapView({
    super.key,
    required this.ride,
    this.onTripMetrics,
    this.controller,
  });

  final ActiveRide ride;
  final TripMetricsCallback? onTripMetrics;
  final TripMapController? controller;

  @override
  ConsumerState<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends ConsumerState<TripMapView> {
  GoogleMapController? _controller;
  bool _mapReady = false;
  List<LatLng> _tripRoutePoints = [];
  List<LatLng> _activeLegPoints = [];
  bool _loadingRoutes = true;
  double? _driverLat;
  double? _driverLng;
  double? _speedKmh;
  int? _etaMinutes;
  double? _distanceMeters;
  StreamSubscription<Position>? _positionSub;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropIcon;
  BitmapDescriptor? _selfIcon;

  void _emitMetrics() {
    widget.onTripMetrics?.call(
      speedKmh: _speedKmh,
      etaMinutes: _etaMinutes,
      distanceMeters: _distanceMeters,
    );
  }

  bool get _hasValidPickup =>
      DirectionsService.hasCoordinates(widget.ride.pickupLat, widget.ride.pickupLng);

  bool get _hasValidDestination => DirectionsService.hasCoordinates(
        widget.ride.destinationLat,
        widget.ride.destinationLng,
      );

  bool get _isRideStarted => widget.ride.status == 'started';

  LatLng get _pickup => LatLng(widget.ride.pickupLat, widget.ride.pickupLng);

  LatLng get _destination =>
      LatLng(widget.ride.destinationLat, widget.ride.destinationLng);

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(goToMyLocation);
    Future.microtask(() async {
      await _loadMarkerIcons();
      await _initDriverLocation();
      await _loadRoutes();
    });
    _positionSub = ref.read(locationServiceProvider).getPositionStream().listen(
      (position) {
        if (!mounted) return;
        final lat = position.latitude;
        final lng = position.longitude;
        final speed = position.speed >= 0 ? position.speed * 3.6 : null;
        final moved = _driverLat != lat || _driverLng != lng;
        final speedChanged = _speedKmh != speed;
        if (!moved && !speedChanged) return;
        setState(() {
          _driverLat = lat;
          _driverLng = lng;
          _speedKmh = speed;
        });
        _updateEtaFallback();
        _emitMetrics();
        if (moved) _loadActiveLeg();
      },
      onError: (_) {},
    );
  }

  @override
  void didUpdateWidget(covariant TripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind(goToMyLocation);
      widget.controller?._bind(goToMyLocation);
    }
    if (oldWidget.ride.pickupLat != widget.ride.pickupLat ||
        oldWidget.ride.pickupLng != widget.ride.pickupLng ||
        oldWidget.ride.destinationLat != widget.ride.destinationLat ||
        oldWidget.ride.destinationLng != widget.ride.destinationLng ||
        oldWidget.ride.status != widget.ride.status) {
      _loadRoutes();
    }
  }

  Future<void> _loadMarkerIcons() async {
    final pickup = await MapMarkerIcons.pickupLabeledMarker();
    final drop = await MapMarkerIcons.dropoffLabeledMarker();
    final self = await MapMarkerIcons.selfMarker();
    if (!mounted) return;
    setState(() {
      _pickupIcon = pickup;
      _dropIcon = drop;
      _selfIcon = self;
    });
  }

  Future<void> _initDriverLocation() async {
    try {
      // Prefer last-known for fast first paint (web GPS can be slow).
      Position? position = await Geolocator.getLastKnownPosition();
      position ??=
          await ref.read(locationServiceProvider).getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _driverLat = position!.latitude;
        _driverLng = position.longitude;
        _speedKmh = position.speed >= 0 ? position.speed * 3.6 : null;
      });
      _updateEtaFallback();
      _emitMetrics();
    } catch (_) {}
  }

  Future<void> _loadRoutes() async {
    if (!_hasValidPickup) {
      if (mounted) setState(() => _loadingRoutes = false);
      return;
    }

    setState(() => _loadingRoutes = true);

    // Full pickup→drop route only after ride starts; before that focus pickup only.
    List<LatLng> tripPoints = [];
    if (_isRideStarted && _hasValidDestination) {
      try {
        final route = await ref.read(directionsServiceProvider).getDirectionsByCoordinates(
              pickupLat: widget.ride.pickupLat,
              pickupLng: widget.ride.pickupLng,
              dropoffLat: widget.ride.destinationLat,
              dropoffLng: widget.ride.destinationLng,
              pickupAddress: widget.ride.pickupAddress,
              dropoffAddress: widget.ride.destinationAddress,
            );
        tripPoints = route.points;
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _tripRoutePoints = tripPoints;
      _loadingRoutes = false;
    });
    await _loadActiveLeg();
    _fitBounds();
  }

  void _updateEtaFallback() {
    final dLat = _driverLat;
    final dLng = _driverLng;
    if (dLat == null || dLng == null) return;

    final targetLat =
        _isRideStarted ? widget.ride.destinationLat : widget.ride.pickupLat;
    final targetLng =
        _isRideStarted ? widget.ride.destinationLng : widget.ride.pickupLng;
    if (!DirectionsService.hasCoordinates(targetLat, targetLng)) return;

    final meters = distanceBetweenMeters(
      lat1: dLat,
      lng1: dLng,
      lat2: targetLat,
      lng2: targetLng,
    );
    _distanceMeters = meters;
    _etaMinutes = estimateEtaMinutes(meters);
  }

  Future<void> _loadActiveLeg() async {
    final dLat = _driverLat;
    final dLng = _driverLng;
    if (dLat == null ||
        dLng == null ||
        !DirectionsService.hasCoordinates(dLat, dLng)) {
      if (mounted) setState(() => _activeLegPoints = []);
      return;
    }

    final targetLat = _isRideStarted ? widget.ride.destinationLat : widget.ride.pickupLat;
    final targetLng = _isRideStarted ? widget.ride.destinationLng : widget.ride.pickupLng;
    if (!DirectionsService.hasCoordinates(targetLat, targetLng)) return;

    try {
      final leg = await ref.read(directionsServiceProvider).getDirectionsByCoordinates(
            pickupLat: dLat,
            pickupLng: dLng,
            dropoffLat: targetLat,
            dropoffLng: targetLng,
          );
      if (!mounted) return;
      setState(() {
        _activeLegPoints = leg.points;
        if (leg.durationMin > 0) {
          _etaMinutes = leg.durationMin.ceil();
        }
        if (leg.distanceKm > 0) {
          _distanceMeters = leg.distanceKm * 1000;
        }
      });
      _emitMetrics();
      _fitBounds();
    } catch (_) {
      if (!mounted) return;
      setState(() => _activeLegPoints = [LatLng(dLat, dLng), LatLng(targetLat, targetLng)]);
      _updateEtaFallback();
      _emitMetrics();
      _fitBounds();
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(goToMyLocation);
    _positionSub?.cancel();
    if (_mapReady && _controller != null && !kIsWeb) {
      _controller!.dispose();
    }
    super.dispose();
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null || !_hasValidPickup) return;

    final points = <LatLng>[
      if (!_isRideStarted) _pickup,
      if (_isRideStarted && _hasValidDestination) _destination,
      ..._tripRoutePoints,
      ..._activeLegPoints,
    ];
    if (_driverLat != null && _driverLng != null) {
      points.add(LatLng(_driverLat!, _driverLng!));
    }
    if (points.isEmpty) return;

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;
    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }

    const pad = 0.002;
    if ((maxLat - minLat).abs() < 0.0001) {
      minLat -= pad;
      maxLat += pad;
    }
    if ((maxLng - minLng).abs() < 0.0001) {
      minLng -= pad;
      maxLng += pad;
    }

    try {
      // Extra padding so route stays visible above the bottom sheet.
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100,
        ),
      );
    } catch (_) {}
  }

  Set<Polyline> get _polylines {
    final lines = <Polyline>{};

    if (_tripRoutePoints.length >= 2) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('trip_route'),
          points: _tripRoutePoints,
          color: AppColors.primary.withValues(alpha: 0.45),
          width: 4,
        ),
      );
    }

    if (_activeLegPoints.length >= 2) {
      lines.add(
        Polyline(
          polylineId: const PolylineId('active_leg'),
          points: _activeLegPoints,
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return lines;
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Heading to pickup / arrived: only pickup. After OTP start: only drop.
    if (!_isRideStarted) {
      final icon = _pickupIcon;
      if (icon != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: _pickup,
            icon: icon,
            anchor: const Offset(0.5, 1),
            infoWindow: InfoWindow(
              title: 'Passenger pickup',
              snippet: widget.ride.pickupAddress,
            ),
          ),
        );
      }
    } else if (_hasValidDestination) {
      final icon = _dropIcon;
      if (icon != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: _destination,
            icon: icon,
            anchor: const Offset(0.5, 1),
            infoWindow: InfoWindow(
              title: 'Drop location',
              snippet: widget.ride.destinationAddress,
            ),
          ),
        );
      }
    }

    final dLat = _driverLat;
    final dLng = _driverLng;
    final selfIcon = _selfIcon;
    if (dLat != null &&
        dLng != null &&
        selfIcon != null &&
        DirectionsService.hasCoordinates(dLat, dLng)) {
      markers.add(
        Marker(
          markerId: const MarkerId('self'),
          position: LatLng(dLat, dLng),
          icon: selfIcon,
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }

    return markers;
  }

  Future<void> goToMyLocation() async {
    try {
      var lat = _driverLat;
      var lng = _driverLng;
      if (lat == null ||
          lng == null ||
          !DirectionsService.hasCoordinates(lat, lng)) {
        final position =
            await ref.read(locationServiceProvider).getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
        if (mounted) {
          setState(() {
            _driverLat = lat;
            _driverLng = lng;
          });
          await _loadActiveLeg();
        }
      }
      if (!mounted) return;
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat!, lng!), 16),
      );
    } catch (_) {
      // Permission / GPS unavailable — ignore; map stays as-is.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidPickup) {
      return _FallbackLocation(
        title: 'Passenger pickup',
        address: widget.ride.pickupAddress,
      );
    }

    final vehicleType =
        ref.watch(dashboardViewModelProvider).profile?.vehicle?.vehicleType;

    return Stack(
      children: [
        GoogleMap(
          key: ValueKey('trip-${widget.ride.id}-${widget.ride.status}'),
          initialCameraPosition: CameraPosition(target: _pickup, zoom: 14),
          onMapCreated: (controller) {
            _controller = controller;
            _mapReady = true;
            _fitBounds();
          },
          myLocationEnabled: !kIsWeb,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: _markers,
          polylines: _polylines,
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
        if (_isRideStarted)
          Positioned(
            right: 12,
            top: MediaQuery.paddingOf(context).top + 72,
            child: TripSpeedEtaOverlay(
              speedKmh: _speedKmh,
              etaMinutes: _etaMinutes,
              vehicleType: vehicleType,
            ),
          ),
      ],
    );
  }
}

class _FallbackLocation extends StatelessWidget {
  const _FallbackLocation({required this.title, required this.address});

  final String title;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBackground,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin_circle, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              address,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
