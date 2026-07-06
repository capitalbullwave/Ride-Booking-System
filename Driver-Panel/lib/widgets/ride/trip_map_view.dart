import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/services/directions_service.dart';

class TripMapView extends ConsumerStatefulWidget {
  const TripMapView({super.key, required this.ride});

  final ActiveRide ride;

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
  StreamSubscription<Position>? _positionSub;

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
    Future.microtask(() async {
      await _initDriverLocation();
      await _loadRoutes();
    });
    _positionSub = ref.read(locationServiceProvider).getPositionStream().listen(
      (position) {
        if (!mounted) return;
        final lat = position.latitude;
        final lng = position.longitude;
        if (_driverLat == lat && _driverLng == lng) return;
        setState(() {
          _driverLat = lat;
          _driverLng = lng;
        });
        _loadActiveLeg();
      },
      onError: (_) {},
    );
  }

  @override
  void didUpdateWidget(covariant TripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ride.pickupLat != widget.ride.pickupLat ||
        oldWidget.ride.pickupLng != widget.ride.pickupLng ||
        oldWidget.ride.destinationLat != widget.ride.destinationLat ||
        oldWidget.ride.destinationLng != widget.ride.destinationLng ||
        oldWidget.ride.status != widget.ride.status) {
      _loadRoutes();
    }
  }

  Future<void> _initDriverLocation() async {
    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _driverLat = position.latitude;
        _driverLng = position.longitude;
      });
    } catch (_) {}
  }

  Future<void> _loadRoutes() async {
    if (!_hasValidPickup) {
      if (mounted) setState(() => _loadingRoutes = false);
      return;
    }

    setState(() => _loadingRoutes = true);

    List<LatLng> tripPoints = [];
    if (_hasValidDestination) {
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
      setState(() => _activeLegPoints = leg.points);
      _fitBounds();
    } catch (_) {
      if (!mounted) return;
      setState(() => _activeLegPoints = [LatLng(dLat, dLng), LatLng(targetLat, targetLng)]);
      _fitBounds();
    }
  }

  @override
  void dispose() {
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
      _pickup,
      if (_hasValidDestination) _destination,
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
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Passenger pickup',
          snippet: widget.ride.pickupAddress,
        ),
      ),
    };

    if (_hasValidDestination) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Drop location',
            snippet: widget.ride.destinationAddress,
          ),
        ),
      );
    }

    final dLat = _driverLat;
    final dLng = _driverLng;
    if (dLat != null &&
        dLng != null &&
        DirectionsService.hasCoordinates(dLat, dLng)) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(dLat, dLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          infoWindow: const InfoWindow(title: 'You'),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidPickup) {
      return _FallbackLocation(
        title: 'Passenger pickup',
        address: widget.ride.pickupAddress,
      );
    }

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
          zoomControlsEnabled: kIsWeb,
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
