import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/ride_model.dart';

class TripMapView extends StatefulWidget {
  const TripMapView({super.key, required this.ride});

  final ActiveRide ride;

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView> {
  GoogleMapController? _controller;
  bool _mapReady = false;

  bool get _hasValidPickup =>
      widget.ride.pickupLat != 0 || widget.ride.pickupLng != 0;

  LatLng get _pickup => LatLng(widget.ride.pickupLat, widget.ride.pickupLng);

  LatLng get _destination =>
      LatLng(widget.ride.destinationLat, widget.ride.destinationLng);

  @override
  void dispose() {
    if (_mapReady && _controller != null && !kIsWeb) {
      _controller!.dispose();
    }
    super.dispose();
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null || !_hasValidPickup) return;

    final points = [_pickup, _destination];
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

  @override
  Widget build(BuildContext context) {
    if (!_hasValidPickup) {
      return _FallbackLocation(
        title: 'Passenger pickup',
        address: widget.ride.pickupAddress,
      );
    }

    return GoogleMap(
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
      markers: {
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Passenger pickup',
            snippet: widget.ride.pickupAddress,
          ),
        ),
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Drop location',
            snippet: widget.ride.destinationAddress,
          ),
        ),
      },
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickup, _destination],
          color: AppColors.primary,
          width: 4,
        ),
      },
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
