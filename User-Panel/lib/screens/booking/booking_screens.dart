import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/screens/booking/map_picker_screen.dart';
import 'package:wavego_user/services/location_service.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/services/recent_places_service.dart';
import 'package:wavego_user/services/saved_places_service.dart';
import 'package:wavego_user/widgets/booking/cancel_ride_helper.dart';
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
      await ref.read(recentPlacesServiceProvider).add(place);
      ref.read(recentPlacesProvider.notifier).state =
          ref.read(recentPlacesServiceProvider).getAll();
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
      await ref.read(recentPlacesServiceProvider).add(result);
      ref.read(recentPlacesProvider.notifier).state =
          ref.read(recentPlacesServiceProvider).getAll();
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

  Widget _recommendationSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  Widget _recommendedTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }

  void _selectPlace(PlaceSuggestion place) async {
    if (!place.hasCoordinates && place.id.isNotEmpty && place.source == 'google') {
      try {
        final resolved = await ref.read(placesServiceProvider).resolvePlaceDetails(place.id);
        if (!mounted) return;
        final selected = SelectedPlace(
          label: resolved.displayLabel,
          latitude: resolved.latitude,
          longitude: resolved.longitude,
        );
        await ref.read(recentPlacesServiceProvider).add(selected);
        ref.read(recentPlacesProvider.notifier).state =
            ref.read(recentPlacesServiceProvider).getAll();
        if (!mounted) return;
        context.pop(selected);
        return;
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.userMessage, isError: true);
        }
        return;
      }
    }

    final selected = SelectedPlace(
      label: place.displayLabel,
      latitude: place.latitude,
      longitude: place.longitude,
    );
    await ref.read(recentPlacesServiceProvider).add(selected);
    ref.read(recentPlacesProvider.notifier).state =
        ref.read(recentPlacesServiceProvider).getAll();
    if (!mounted) return;
    context.pop(selected);
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
                ? Builder(
                    builder: (context) {
                      final q = _searchController.text.trim();
                      if (q.length >= 2) {
                        return Center(
                          child: Text(
                            'No places found',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        );
                      }

                      final saved = ref.watch(savedPlacesProvider);
                      final favorites = saved.where((p) => p.isFavorite).toList();
                      final recents = ref.watch(recentPlacesProvider);

                      if (favorites.isEmpty && saved.isEmpty && recents.isEmpty) {
                        return Center(
                          child: Text(
                            'Search or pick a saved place',
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        );
                      }

                      return ListView(
                        children: [
                          if (favorites.isNotEmpty) ...[
                            _recommendationSectionTitle('Favorites'),
                            ...favorites.take(6).map((p) => _recommendedTile(
                                  icon: Icons.favorite,
                                  title: p.title,
                                  subtitle: p.address,
                                  onTap: () async {
                                    final selected = ref.read(savedPlacesServiceProvider).toSelectedPlace(p);
                                    await ref.read(recentPlacesServiceProvider).add(selected);
                                    ref.read(recentPlacesProvider.notifier).state =
                                        ref.read(recentPlacesServiceProvider).getAll();
                                    if (context.mounted) context.pop(selected);
                                  },
                                )),
                            const Divider(height: 1),
                          ],
                          if (saved.isNotEmpty) ...[
                            _recommendationSectionTitle('Saved places'),
                            ...saved.take(8).map((p) => _recommendedTile(
                                  icon: Icons.bookmark,
                                  title: p.title,
                                  subtitle: p.address,
                                  onTap: () async {
                                    final selected = ref.read(savedPlacesServiceProvider).toSelectedPlace(p);
                                    await ref.read(recentPlacesServiceProvider).add(selected);
                                    ref.read(recentPlacesProvider.notifier).state =
                                        ref.read(recentPlacesServiceProvider).getAll();
                                    if (context.mounted) context.pop(selected);
                                  },
                                )),
                            const Divider(height: 1),
                          ],
                          if (recents.isNotEmpty) ...[
                            _recommendationSectionTitle('Recent'),
                            ...recents.take(10).map((p) => _recommendedTile(
                                  icon: Icons.history,
                                  title: p.label,
                                  subtitle: p.latitude != null && p.longitude != null
                                      ? 'Saved coordinates'
                                      : 'No coordinates',
                                  onTap: () async {
                                    final selected = p.toSelected();
                                    await ref.read(recentPlacesServiceProvider).add(selected);
                                    ref.read(recentPlacesProvider.notifier).state =
                                        ref.read(recentPlacesServiceProvider).getAll();
                                    if (context.mounted) context.pop(selected);
                                  },
                                )),
                          ],
                        ],
                      );
                    },
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
  List<BookableVehicle> _vehicles = fallbackBookableVehicles();
  bool _loadingVehicles = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
      _loadVehicles();
    });
  }

  Future<void> _loadVehicles() async {
    try {
      final categories = await ref.read(vehicleCategoriesProvider.future);
      if (!mounted) return;
      setState(() {
        _vehicles = categories.isNotEmpty
            ? categories
                .asMap()
                .entries
                .map((entry) => bookableVehicleFromCategory(entry.value, entry.key))
                .toList()
            : fallbackBookableVehicles();
        _loadingVehicles = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _vehicles = fallbackBookableVehicles();
          _loadingVehicles = false;
        });
      }
    }
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
    final activeRide = await ref.read(activeRideProvider.future);
    if (activeRide != null) {
      if (mounted) {
        context.showSnackBar(
          'You already have an active ride. Please finish or cancel it before booking a new one.',
          isError: true,
        );
      }
      return;
    }

    final trip = ref.read(tripBookingProvider);
    final pickup = trip.pickup;
    final dropoff = trip.dropoff;
    final route = _route ?? trip.route;

    if (pickup == null || dropoff == null || route == null) {
      context.showSnackBar('Route not ready yet', isError: true);
      return;
    }

    try {
      final result = await ref.read(rideBookingServiceProvider).bookRide(
            pickupAddress: pickup.label,
            dropoffAddress: dropoff.label,
            pickupLat: route.pickup.lat,
            pickupLng: route.pickup.lng,
            dropoffLat: route.dropoff.lat,
            dropoffLng: route.dropoff.lng,
          );
      final rideId = result['id']?.toString();
      if (rideId != null && rideId.isNotEmpty) {
        ref.read(tripBookingProvider.notifier).setActiveRideId(rideId);
      }
      if (mounted) context.go(RouteNames.bookSearching);
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
            child: _loadingVehicles
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._vehicles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final vehicle = entry.value;
                        final isSelected = _selectedVehicleIndex == index;
                        final fare = _route != null
                            ? vehicle.fareForDistanceKm(_route!.distanceKm)
                            : vehicle.fareForDistanceKm(5);

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
                                  if (vehicle.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        vehicle.imageUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          vehicle.icon,
                                          size: 32,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(vehicle.icon, size: 32, color: AppColors.primary),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          vehicle.etaLabel(index),
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

class RideSearchingScreen extends ConsumerStatefulWidget {
  const RideSearchingScreen({super.key});

  @override
  ConsumerState<RideSearchingScreen> createState() => _RideSearchingScreenState();
}

class _RideSearchingScreenState extends ConsumerState<RideSearchingScreen> {
  Timer? _pollTimer;
  String? _rideId;

  bool _isDriverAssigned(String? status) {
    if (status == null) return false;
    const assigned = {
      'DRIVER_ASSIGNED',
      'DRIVER_ARRIVED',
      'OTP_VERIFIED',
      'STARTED',
      'IN_PROGRESS',
    };
    return assigned.contains(status.toUpperCase());
  }

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkRideStatus());
    Future.microtask(() async {
      await _loadRideId();
      await _checkRideStatus();
    });
  }

  Future<void> _loadRideId() async {
    final fromState = ref.read(tripBookingProvider).activeRideId;
    if (fromState != null && fromState.isNotEmpty) {
      if (mounted) setState(() => _rideId = fromState);
      return;
    }
    final active = await ref.read(rideBookingServiceProvider).getActiveRide();
    final id = active?['id']?.toString();
    if (id != null && id.isNotEmpty && mounted) {
      ref.read(tripBookingProvider.notifier).setActiveRideId(id);
      setState(() => _rideId = id);
    }
  }

  Future<void> _checkRideStatus() async {
    try {
      final active = await ref.read(rideBookingServiceProvider).getActiveRide();
      final status = active?['status']?.toString();
      if (_isDriverAssigned(status) && mounted) {
        _pollTimer?.cancel();
        context.pushReplacement('/book/tracking');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _goHomeFromSearching() {
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final rideId = _rideId ?? ref.watch(tripBookingProvider).activeRideId ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHomeFromSearching();
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goHomeFromSearching,
        ),
        title: const Text('Finding captain'),
        actions: [
          if (rideId.isNotEmpty)
            CancelRideButton(
              rideId: rideId,
              navigateHome: true,
              compact: true,
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              'Notifying nearby captains...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Live tracking will start once a captain accepts',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
            if (rideId.isNotEmpty) ...[
              const SizedBox(height: 28),
              CancelRideButton(rideId: rideId, navigateHome: true),
            ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  String? _rideId;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRideId);
  }

  Future<void> _loadRideId() async {
    final fromState = ref.read(tripBookingProvider).activeRideId;
    if (fromState != null && fromState.isNotEmpty) {
      if (mounted) setState(() => _rideId = fromState);
      return;
    }
    final active = await ref.read(rideBookingServiceProvider).getActiveRide();
    if (mounted) setState(() => _rideId = active?['id']?.toString());
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(tripBookingProvider).route;
    final rideId = _rideId ?? ref.watch(tripBookingProvider).activeRideId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live tracking'),
        actions: [
          if (rideId.isNotEmpty)
            CancelRideButton(
              rideId: rideId,
              navigateHome: true,
              compact: true,
            ),
        ],
      ),
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
                if (rideId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CancelRideButton(rideId: rideId, navigateHome: true),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
