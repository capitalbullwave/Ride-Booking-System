import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/models/user_models.dart';

class LiveTrackingMap extends StatefulWidget {
  const LiveTrackingMap({
    super.key,
    required this.ride,
    this.driverLat,
    this.driverLng,
  });

  final UserActiveRide ride;
  final double? driverLat;
  final double? driverLng;

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant LiveTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.driverLat != oldWidget.driverLat ||
        widget.driverLng != oldWidget.driverLng) {
      _fitCamera();
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
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(dLat, dLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: widget.ride.driverName ?? 'Captain',
            snippet: widget.ride.vehicleNumber,
          ),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> get _polylines {
    final dLat = widget.driverLat ?? widget.ride.driverLat;
    final dLng = widget.driverLng ?? widget.ride.driverLng;
    if (dLat == null || dLng == null || dLat == 0 || dLng == 0) return {};

    if (widget.ride.isInProgress &&
        widget.ride.dropoffLat != null &&
        widget.ride.dropoffLng != null) {
      return {
        Polyline(
          polylineId: const PolylineId('driver_to_dropoff'),
          points: [
            LatLng(dLat, dLng),
            LatLng(widget.ride.dropoffLat!, widget.ride.dropoffLng!),
          ],
          color: AppColors.primary,
          width: 4,
        ),
      };
    }

    final points = <LatLng>[];
    if (widget.ride.pickupLat != null && widget.ride.pickupLng != null) {
      points.add(LatLng(widget.ride.pickupLat!, widget.ride.pickupLng!));
    }
    points.add(LatLng(dLat, dLng));
    if (points.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('driver_to_pickup'),
        points: points,
        color: AppColors.primary,
        width: 4,
      ),
    };
  }

  LatLng get _initialTarget {
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
    return GoogleMap(
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
    );
  }
}
