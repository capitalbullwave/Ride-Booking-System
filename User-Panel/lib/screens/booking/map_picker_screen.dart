import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/services/location_service.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(
    LocationService.defaultLat,
    LocationService.defaultLng,
  );
  String _addressLabel = 'Move the map to pick a spot';
  bool _loadingAddress = false;
  bool _confirming = false;
  bool _mapReady = false;
  Timer? _geocodeDebounce;

  @override
  void dispose() {
    _geocodeDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initMapCenter() async {
    final position = await ref.read(locationServiceProvider).tryGetCurrentPosition();
    if (!mounted) return;

    if (position != null) {
      _center = LatLng(position.latitude, position.longitude);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_center, 16),
      );
    }

    await _resolveAddress(_center);
  }

  void _onCameraIdle() {
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _resolveAddress(_center);
    });
  }

  Future<SelectedPlace> _placeAt(LatLng point) {
    return ref.read(placesServiceProvider).reverseGeocode(
          point.latitude,
          point.longitude,
        );
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _loadingAddress = true);
    final place = await _placeAt(point);
    if (mounted) {
      setState(() {
        _addressLabel = place.label;
        _loadingAddress = false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    final place = await _placeAt(_center);
    if (mounted) {
      Navigator.of(context).pop(place);
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition(forceFresh: true);
      final target = LatLng(position.latitude, position.longitude);
      setState(() => _center = target);
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      await _resolveAddress(target);
    } on LocationServiceException catch (e) {
      if (!mounted) return;
      context.showSnackBar(e.message, isError: true);
      if (e.openSettings) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Open Settings to enable location'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => ref.read(locationServiceProvider).openLocationSettings(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) async {
              _mapController = controller;
              setState(() => _mapReady = true);
              await _initMapCenter();
            },
            onCameraMove: (position) => _center = position.target,
            onCameraIdle: _onCameraIdle,
          ),
          if (!_mapReady)
            const ColoredBox(
              color: AppColors.muted,
              child: Center(child: CircularProgressIndicator()),
            ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: IgnorePointer(
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 160,
            child: FloatingActionButton.small(
              heroTag: 'map_my_location',
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Drag the map to adjust the pin',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                  const SizedBox(height: 6),
                  _loadingAddress
                      ? const LinearProgressIndicator(minHeight: 2)
                      : Text(
                          _addressLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Confirm this location',
                    isLoading: _confirming,
                    onPressed: _confirming ? null : _confirm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
