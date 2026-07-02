import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/place_models.dart';

class RouteMapPreview extends StatefulWidget {
  const RouteMapPreview({
    super.key,
    required this.route,
    this.height = 180,
  });

  final DirectionsResult route;
  final double height;

  @override
  State<RouteMapPreview> createState() => _RouteMapPreviewState();
}

class _RouteMapPreviewState extends State<RouteMapPreview> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final points = widget.route.path
        .map((p) => LatLng(p.lat, p.lng))
        .toList();

    if (points.isEmpty) {
      return _fallback(height: widget.height);
    }

    final pickup = LatLng(widget.route.pickup.lat, widget.route.pickup.lng);
    final dropoff = LatLng(widget.route.dropoff.lat, widget.route.dropoff.lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: pickup, zoom: 12),
          onMapCreated: (controller) {
            _controller = controller;
            _fitBounds(points);
          },
          markers: {
            Marker(
              markerId: const MarkerId('pickup'),
              position: pickup,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: dropoff,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
            ),
          },
          polylines: {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: AppColors.primary,
              width: 4,
            ),
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (_controller == null || points.length < 2) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  Widget _fallback({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: AppColors.mutedForeground),
            SizedBox(height: 8),
            Text('Route preview', style: TextStyle(color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}
