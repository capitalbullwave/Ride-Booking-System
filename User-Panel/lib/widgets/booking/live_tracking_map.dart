import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/map_marker_icons.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/places_service.dart';

class LiveTrackingMap extends ConsumerStatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.ride,
    this.driverLat,
    this.driverLng,
    this.fallbackVehicleSlug,
    this.tripRoute,
  });

  final UserActiveRide ride;
  final double? driverLat;
  final double? driverLng;
  final String? fallbackVehicleSlug;
  final DirectionsResult? tripRoute;

  @override
  ConsumerState<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends ConsumerState<LiveTrackingMap> {
  GoogleMapController? _controller;
  BitmapDescriptor? _driverIcon;
  List<LatLng> _tripRoutePoints = [];
  List<LatLng> _driverLegPoints = [];
  bool _loadingRoutes = true;

  @override
  void initState() {
    super.initState();
    _loadDriverIcon();
    Future.microtask(_loadRoutes);
  }

  @override
  void didUpdateWidget(covariant LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.driverLat != oldWidget.driverLat ||
        widget.driverLng != oldWidget.driverLng ||
        widget.ride.status != oldWidget.ride.status) {
      _loadDriverLeg();
      _fitCamera();
    }
    if (widget.tripRoute != oldWidget.tripRoute ||
        widget.ride.pickupLat != oldWidget.ride.pickupLat ||
        widget.ride.dropoffLat != oldWidget.ride.dropoffLat) {
      _loadRoutes();
    }
    if (widget.ride.vehicleTypeSlug != oldWidget.ride.vehicleTypeSlug ||
        widget.fallbackVehicleSlug != oldWidget.fallbackVehicleSlug) {
      _loadDriverIcon();
    }
  }

  String get _vehicleSlug =>
      widget.ride.vehicleTypeSlug ?? widget.fallbackVehicleSlug ?? 'cab';

  List<LatLng> _latLngsFromDirections(DirectionsResult route) {
    return route.path.map((p) => LatLng(p.lat, p.lng)).toList();
  }

  Future<void> _loadDriverIcon() async {
    final icon = await MapMarkerIcons.vehicleMarker(_vehicleSlug);
    if (!mounted) return;
    setState(() => _driverIcon = icon);
  }

  Future<void> _loadRoutes() async {
    setState(() => _loadingRoutes = true);

    List<LatLng> tripPoints = [];
    if (widget.tripRoute != null && widget.tripRoute!.path.length >= 2) {
      tripPoints = _latLngsFromDirections(widget.tripRoute!);
    } else if (widget.ride.pickupLat != null &&
        widget.ride.pickupLng != null &&
        widget.ride.dropoffLat != null &&
        widget.ride.dropoffLng != null) {
      try {
        final route = await ref.read(placesServiceProvider).getDirectionsByCoordinates(
              pickupLat: widget.ride.pickupLat!,
              pickupLng: widget.ride.pickupLng!,
              dropoffLat: widget.ride.dropoffLat!,
              dropoffLng: widget.ride.dropoffLng!,
              pickupAddress: widget.ride.pickupAddress,
              dropoffAddress: widget.ride.dropoffAddress,
            );
        tripPoints = _latLngsFromDirections(route);
      } catch (_) {}
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
    final dLat = widget.driverLat ?? widget.ride.driverLat;
    final dLng = widget.driverLng ?? widget.ride.driverLng;
    if (dLat == null || dLng == null || dLat == 0 || dLng == 0) {
      if (mounted) setState(() => _driverLegPoints = []);
      return;
    }

    final targetLat = widget.ride.isInProgress
        ? widget.ride.dropoffLat
        : widget.ride.pickupLat;
    final targetLng = widget.ride.isInProgress
        ? widget.ride.dropoffLng
        : widget.ride.pickupLng;
    if (targetLat == null || targetLng == null) return;

    try {
      final leg = await ref.read(placesServiceProvider).getDirectionsByCoordinates(
            pickupLat: dLat,
            pickupLng: dLng,
            dropoffLat: targetLat,
            dropoffLng: targetLng,
          );
      if (!mounted) return;
      setState(() => _driverLegPoints = _latLngsFromDirections(leg));
    } catch (_) {
      if (!mounted) return;
      setState(() => _driverLegPoints = [LatLng(dLat, dLng), LatLng(targetLat, targetLng)]);
    }
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    if (widget.ride.pickupLat != null && widget.ride.pickupLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Pickup', snippet: widget.ride.pickupAddress),
        ),
      );
    }
    if (widget.ride.dropoffLat != null && widget.ride.dropoffLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(widget.ride.dropoffLat!, widget.ride.dropoffLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: InfoWindow(title: 'Drop', snippet: widget.ride.dropoffAddress),
        ),
      );
    }
    final dLat = widget.driverLat ?? widget.ride.driverLat;
    final dLng = widget.driverLng ?? widget.ride.driverLng;
    if (dLat != null && dLng != null && dLat != 0 && dLng != 0) {
      final vehicleLabel = widget.ride.vehicleTypeName ?? 'Captain';
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(dLat, dLng),
          icon: _driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: widget.ride.driverName ?? vehicleLabel,
            snippet: [
              if (widget.ride.vehicleTypeName != null) widget.ride.vehicleTypeName,
              widget.ride.vehicleNumber,
            ].whereType<String>().where((v) => v.isNotEmpty).join(' • '),
          ),
        ),
      );
    }
    return markers;
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
    final dLat = widget.driverLat ?? widget.ride.driverLat;
    final dLng = widget.driverLng ?? widget.ride.driverLng;
    if (dLat != null && dLng != null && dLat != 0 && dLng != 0) {
      return LatLng(dLat, dLng);
    }
    if (widget.ride.pickupLat != null && widget.ride.pickupLng != null) {
      return LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!);
    }
    return const LatLng(28.6139, 77.209);
  }

  Future<void> _fitCamera() async {
    final controller = _controller;
    if (controller == null) return;
    final points = _markers.map((m) => m.position).toList();
    if (points.length < 2) return;
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
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _initialTarget, zoom: 14),
          onMapCreated: (controller) {
            _controller = controller;
            _fitCamera();
          },
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
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
