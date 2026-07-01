import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/screens/booking/map_picker_screen.dart';
import 'package:wavego_user/services/location_service.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/widgets/booking/route_map_preview.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key, required this.field});

  final String field;

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<PlaceSuggestion> _results = [];
  bool _isSearching = false;
  bool _isLocating = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().length < 2) {
      if (mounted) setState(() => _results = []);
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await ref.read(placesServiceProvider).searchPlaces(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _error = null;
    });

    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentPosition(forceFresh: true);
      final place = await ref.read(placesServiceProvider).reverseGeocode(
            position.latitude,
            position.longitude,
          );
      if (!mounted) return;
      context.pop(place);
    } on LocationServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _error = e.message;
      });
      context.showSnackBar(e.message, isError: true);
      if (e.openSettings) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Enable location in Settings'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () =>
                  ref.read(locationServiceProvider).openLocationSettings(),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        _error = e.userMessage;
      });
      context.showSnackBar(_error!, isError: true);
    }
  }

  Future<void> _openMapPicker() async {
    final isPickup = widget.field == 'pickup';
    final result = await Navigator.of(context, rootNavigator: true).push<SelectedPlace>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MapPickerScreen(
          title: isPickup ? 'Set pickup on map' : 'Set destination on map',
        ),
      ),
    );
    if (result != null && mounted) {
      context.pop(result);
    }
  }

  Widget _locationOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _selectPlace(PlaceSuggestion place) async {
    if (!place.hasCoordinates && place.id.isNotEmpty && place.source == 'google') {
      try {
        final resolved = await ref.read(placesServiceProvider).resolvePlaceDetails(place.id);
        if (!mounted) return;
        context.pop(
          SelectedPlace(
            label: resolved.displayLabel,
            latitude: resolved.latitude,
            longitude: resolved.longitude,
          ),
        );
        return;
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.userMessage, isError: true);
        }
        return;
      }
    }

    context.pop(
      SelectedPlace(
        label: place.displayLabel,
        latitude: place.latitude,
        longitude: place.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.field == 'pickup';

    return Scaffold(
      appBar: AppBar(
        title: Text(isPickup ? 'Set pickup' : 'Set destination'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _results = []);
                        },
                      )
                    : null,
              ),
            ),
          ),
          _locationOptionTile(
            icon: Icons.my_location,
            title: 'Use current location',
            subtitle: 'GPS based',
            loading: _isLocating,
            onTap: _isLocating ? null : _useCurrentLocation,
          ),
          _locationOptionTile(
            icon: Icons.map_outlined,
            title: 'Set on map',
            subtitle: 'Drag pin to choose manually',
            onTap: _openMapPicker,
          ),
          const Divider(height: 1),
          if (_isSearching)
            const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          Expanded(
            child: _results.isEmpty && !_isSearching
                ? Center(
                    child: Text(
                      _searchController.text.length < 2
                          ? 'Type at least 2 characters to search'
                          : 'No places found',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final place = _results[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.place_outlined,
                          color: AppColors.mutedForeground,
                        ),
                        title: Text(place.name),
                        subtitle: Text(
                          place.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectPlace(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BookRideScreen extends ConsumerStatefulWidget {
  const BookRideScreen({super.key});

  @override
  ConsumerState<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends ConsumerState<BookRideScreen> {
  DirectionsResult? _route;
  bool _loadingRoute = true;
  String? _routeError;
  int? _selectedVehicleIndex;

  static const _vehicles = [
    ('Bike', '₹45', '4 min', Icons.two_wheeler),
    ('Auto', '₹65', '5 min', Icons.electric_rickshaw),
    ('Cab', '₹120', '6 min', Icons.directions_car),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute());
  }

  Future<void> _loadRoute() async {
    final trip = ref.read(tripBookingProvider);
    final pickup = trip.pickup;
    final dropoff = trip.dropoff;

    if (pickup == null || dropoff == null) {
      setState(() {
        _loadingRoute = false;
        _routeError = 'Pickup and destination are required';
      });
      return;
    }

    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    try {
      final route = await ref.read(placesServiceProvider).getDirections(
            pickup: pickup,
            dropoff: dropoff,
          );
      ref.read(tripBookingProvider.notifier).setRoute(route);
      if (mounted) {
        setState(() {
          _route = route;
          _loadingRoute = false;
          _selectedVehicleIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
          _routeError = e.userMessage;
        });
      }
    }
  }

  Future<void> _confirmBooking() async {
    final trip = ref.read(tripBookingProvider);
    final pickup = trip.pickup;
    final dropoff = trip.dropoff;
    final route = _route ?? trip.route;

    if (pickup == null || dropoff == null || route == null) {
      context.showSnackBar('Route not ready yet', isError: true);
      return;
    }

    try {
      await ref.read(rideBookingServiceProvider).bookRide(
            pickupAddress: pickup.label,
            dropoffAddress: dropoff.label,
            pickupLat: route.pickup.lat,
            pickupLng: route.pickup.lng,
            dropoffLat: route.dropoff.lat,
            dropoffLng: route.dropoff.lng,
          );
      if (mounted) context.push('/book/searching');
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripBookingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a ride')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.pickup?.label ?? 'Pickup',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.dropoff?.label ?? 'Destination',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
                if (_route != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_route!.distanceKm.toStringAsFixed(1)} km • ${_route!.durationMin.round()} min',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _loadingRoute
                ? Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : _route != null
                    ? RouteMapPreview(route: _route!)
                    : Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.muted,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Center(
                          child: Text(
                            _routeError ?? 'Could not load route',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                      ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._vehicles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final v = entry.value;
                  final isSelected = _selectedVehicleIndex == index;
                  final fare = _route != null
                      ? '₹${(_route!.distanceKm * 8).round()}'
                      : v.$2;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _route == null
                          ? null
                          : () => setState(() => _selectedVehicleIndex = index),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(v.$4, size: 32, color: AppColors.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.$1,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    v.$3,
                                    style: TextStyle(
                                      color: AppColors.mutedForeground,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              fare,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Confirm booking',
              onPressed: _route != null && _selectedVehicleIndex != null
                  ? _confirmBooking
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class RideSearchingScreen extends StatefulWidget {
  const RideSearchingScreen({super.key});

  @override
  State<RideSearchingScreen> createState() => _RideSearchingScreenState();
}

class _RideSearchingScreenState extends State<RideSearchingScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) context.pushReplacement('/book/tracking');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text(
              'Finding your captain...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Matching with nearby drivers',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class RideTrackingScreen extends ConsumerWidget {
  const RideTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(tripBookingProvider).route;

    return Scaffold(
      appBar: AppBar(title: const Text('Live tracking')),
      body: Column(
        children: [
          Expanded(
            child: route != null
                ? RouteMapPreview(route: route, height: double.infinity)
                : Container(
                    color: AppColors.muted,
                    child: const Center(
                      child: Icon(Icons.map, size: 64, color: AppColors.mutedForeground),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Finding captain...', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'We will notify you when assigned',
                            style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (route != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${route.durationMin.round()} min',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
