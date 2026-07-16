import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/constants/home_booking_mode.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';
import 'package:wavego_user/models/coupon_models.dart';
import 'package:wavego_user/models/fare_models.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/membership_service.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/screens/booking/map_picker_screen.dart';
import 'package:wavego_user/services/location_service.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/services/recent_places_service.dart';
import 'package:wavego_user/services/ride_realtime_service.dart';
import 'package:wavego_user/services/saved_places_service.dart';
import 'package:wavego_user/widgets/booking/booking_checkout_bar.dart';
import 'package:wavego_user/widgets/booking/booking_offers_sheet.dart';
import 'package:wavego_user/widgets/booking/cancel_ride_helper.dart';
import 'package:wavego_user/widgets/booking/ride_accepted_panel.dart';
import 'package:wavego_user/widgets/booking/ride_in_progress_panel.dart';
import 'package:wavego_user/widgets/booking/women_safety_ride_actions.dart';
import 'package:wavego_user/widgets/home/ride_schedule_section.dart';
import 'package:wavego_user/widgets/booking/live_tracking_map.dart';
import 'package:wavego_user/widgets/booking/rate_ride_dialog.dart';
import 'package:wavego_user/widgets/booking/route_map_preview.dart';
import 'package:wavego_user/widgets/booking/women_riders_unavailable_dialog.dart';
import 'package:wavego_user/widgets/booking/prefer_women_captains_dialog.dart';
import 'package:wavego_user/core/utils/navigation_launcher.dart';
import 'package:wavego_user/providers/ride_chat_provider.dart';
import 'package:wavego_user/widgets/ride/ride_chat_notification.dart';
import 'package:wavego_user/widgets/ride/ride_chat_sheet.dart';

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
      if (e.openSettings && !kIsWeb) {
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
      final message = e.userMessage;
      setState(() {
        _isLocating = false;
        _error = message;
      });
      context.showSnackBar(message, isError: true);
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
  List<BookableVehicle> _vehicles = [];
  bool _loadingVehicles = true;
  Map<String, VehicleFareQuote> _fareQuotes = {};
  bool _loadingFares = false;
  double _memberDiscountPercent = 0;
  String _paymentMethod = 'CASH';
  AppliedCoupon? _appliedCoupon;
  List<RideCoupon> _coupons = const [];
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(vehicleCategoriesProvider);
      _loadRoute();
      _loadVehicles();
      _loadCoupons();
    });
  }

  Future<void> _loadCoupons() async {
    try {
      final coupons = await ref.read(rideBookingServiceProvider).listCoupons();
      if (!mounted) return;
      setState(() => _coupons = coupons);
    } catch (_) {}
  }

  double _orderAmountForSelectedVehicle() {
    if (_selectedVehicleIndex == null) return 0;
    final vehicle = _vehicles[_selectedVehicleIndex!];
    final quote = _fareQuotes[vehicle.id.toLowerCase()];
    return quote?.estimatedFare ?? 0;
  }

  Future<void> _openOffersSheet() async {
    final amount = _orderAmountForSelectedVehicle();
    if (amount <= 0) {
      context.showSnackBar('Select a vehicle first', isError: true);
      return;
    }

    await _loadCoupons();

    final applied = await showBookingOffersSheet(
      context: context,
      coupons: _coupons,
      orderAmount: amount,
      current: _appliedCoupon,
      onValidate: (code) => ref.read(rideBookingServiceProvider).validateCoupon(
            code: code,
            orderAmount: amount,
          ),
    );

    if (!mounted) return;
    setState(() => _appliedCoupon = applied);
  }

  Future<void> _openPaymentSheet() async {
    const methods = [
      ('CASH', 'Cash'),
      ('UPI', 'UPI'),
      ('WALLET', 'Wallet'),
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text('Payment method', style: TextStyle(fontWeight: FontWeight.bold)),
            ...methods.map(
              (item) => ListTile(
                title: Text(item.$2),
                trailing: _paymentMethod == item.$1
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, item.$1),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _paymentMethod = selected);
    }
  }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case 'UPI':
        return 'UPI';
      case 'WALLET':
        return 'Wallet';
      default:
        return 'Cash';
    }
  }

  String get _bookButtonLabel {
    if (_selectedVehicleIndex == null) return 'Select a ride';
    return 'Book ${_vehicles[_selectedVehicleIndex!].name}';
  }

  Future<void> _loadVehicles() async {
    final mode = ref.read(tripBookingProvider).mode;
    try {
      final categories = mode == HomeBookingMode.rental
          ? await ref.read(rentalCategoriesProvider.future)
          : await ref.read(vehicleCategoriesProvider.future);
      if (!mounted) return;
      final filtered = filterCategoriesForMode(categories, mode);
      setState(() {
        _vehicles = filtered
            .asMap()
            .entries
            .map((entry) => bookableVehicleFromCategory(entry.value, entry.key))
            .toList();
        _loadingVehicles = false;
      });
      final trip = ref.read(tripBookingProvider);
      if (trip.pickup != null && trip.dropoff != null) {
        await _loadFareEstimates();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _vehicles = [];
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
        await _loadFareEstimates();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
          _routeError = e.userMessage;
        });
        await _loadFareEstimates();
      }
    }
  }

  Future<void> _loadFareEstimates() async {
    final trip = ref.read(tripBookingProvider);
    final route = _route ?? trip.route;

    final double? pickupLat;
    final double? pickupLng;
    final double? dropoffLat;
    final double? dropoffLng;

    if (route != null) {
      pickupLat = route.pickup.lat;
      pickupLng = route.pickup.lng;
      dropoffLat = route.dropoff.lat;
      dropoffLng = route.dropoff.lng;
    } else {
      pickupLat = trip.pickup?.latitude;
      pickupLng = trip.pickup?.longitude;
      dropoffLat = trip.dropoff?.latitude;
      dropoffLng = trip.dropoff?.longitude;
    }

    if (pickupLat == null ||
        pickupLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      return;
    }

    setState(() => _loadingFares = true);

    try {
      final mode = ref.read(tripBookingProvider).mode;
      final result = await ref.read(rideBookingServiceProvider).estimateRide(
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            dropoffLat: dropoffLat,
            dropoffLng: dropoffLng,
            serviceGroup: mode == HomeBookingMode.rental ? 'rental' : 'ride',
            distanceKm: route?.distanceKm,
            durationMin: route?.durationMin,
          );
      if (!mounted) return;
      setState(() {
        _fareQuotes = result.quotes;
        _memberDiscountPercent = result.discountPercent;
        _loadingFares = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _fareQuotes = {};
          _loadingFares = false;
        });
      }
    }
  }

  Widget _buildFareLabel(BookableVehicle vehicle) {
    if (_loadingFares) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final quote = _fareQuotes[vehicle.id.toLowerCase()];

    if (quote == null) {
      return Text(
        '—',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.mutedForeground,
        ),
      );
    }

    if (quote.hasDiscount) {
      final original = quote.originalFare ??
          (quote.estimatedFare + quote.memberDiscount);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${original.round()}',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
          Text(
            '₹${quote.estimatedFare.round()}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

    return Text(
      '₹${quote.estimatedFare.round()}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.primary,
      ),
    );
  }

  Future<void> _confirmBooking() async {
    UserActiveRide? activeRide;
    try {
      activeRide = await ref.read(activeRideProvider.future);
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          e.userMessage,
          isError: true,
        );
      }
      return;
    }

    if (activeRide != null &&
        activeRide.status.toUpperCase() != 'SEARCHING_DRIVER' &&
        activeRide.status.toUpperCase() != 'REQUESTED') {
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

    final selectedVehicle = _selectedVehicleIndex != null
        ? _vehicles[_selectedVehicleIndex!]
        : null;

    var preferWomenRiders = false;
    try {
      final profile = await ref.read(authRepositoryProvider).getProfile();
      if (profile?.isFemale == true && mounted) {
        final choice = await showPreferWomenCaptainsDialog(context);
        if (!mounted) return;
        if (choice == null) return;
        preferWomenRiders = choice;
      }
    } catch (_) {
      // Continue booking if profile cannot be loaded.
    }

    setState(() => _booking = true);
    try {
      final result = await ref.read(rideBookingServiceProvider).bookRide(
            pickupAddress: pickup.label,
            dropoffAddress: dropoff.label,
            pickupLat: route.pickup.lat,
            pickupLng: route.pickup.lng,
            dropoffLat: route.dropoff.lat,
            dropoffLng: route.dropoff.lng,
            vehicleCategoryId: selectedVehicle?.id,
            paymentMethod: _paymentMethod,
            promoCode: _appliedCoupon?.coupon.code,
            scheduledAt: trip.scheduledAt,
            preferWomenRiders: preferWomenRiders,
            womenSafetyEnabled: preferWomenRiders,
            distanceKm: route.distanceKm,
            durationMin: route.durationMin,
          );
      final rideId = result['id']?.toString();
      if (rideId != null && rideId.isNotEmpty) {
        ref.read(tripBookingProvider.notifier).setActiveRideId(rideId);
      }

      // Female passenger + no women captains → ask before expanding search.
      final needsPreferenceChoice =
          result['requires_rider_preference_choice'] == true;
      if (needsPreferenceChoice && rideId != null && rideId.isNotEmpty) {
        if (!mounted) return;
        setState(() => _booking = false);
        final continueWithOthers =
            await showWomenRidersUnavailableDialog(context);
        if (!mounted) return;
        if (continueWithOthers != true) {
          try {
            await ref.read(rideBookingServiceProvider).cancelRide(
                  rideId,
                  reason: 'Cancelled — women captains unavailable',
                );
          } catch (_) {}
          ref.read(tripBookingProvider.notifier).clearActiveRideId();
          ref.invalidate(activeRideProvider);
          return;
        }
        setState(() => _booking = true);
        try {
          await ref
              .read(rideBookingServiceProvider)
              .continueWithAllRiders(rideId);
        } catch (e) {
          if (mounted) {
            context.showSnackBar(e.userMessage, isError: true);
          }
          return;
        }
      }

      if (selectedVehicle != null) {
        ref
            .read(tripBookingProvider.notifier)
            .setBookedVehicleSlug(selectedVehicle.slug);
      }
      ref.invalidate(activeRideProvider);
      if (!mounted) return;
      if (trip.scheduledAt != null && trip.scheduledAt!.isAfter(DateTime.now())) {
        ref.read(tripBookingProvider.notifier).setScheduledAt(null);
        context.showSnackBar('Ride scheduled successfully');
        context.go(RouteNames.bookings);
      } else {
        context.go(RouteNames.bookSearching);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.userMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripBookingProvider);
    final selectedSlug = _selectedVehicleIndex != null
        ? _vehicles[_selectedVehicleIndex!].slug
        : bookedVehicleSlugForTrip(trip.mode, trip.bookedVehicleSlug);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          trip.mode == HomeBookingMode.parcel ? 'Send parcel' : 'Choose a ride',
        ),
      ),
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
                if (trip.scheduledAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        RideScheduleSection.formatSchedule(trip.scheduledAt!),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
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
                if (_memberDiscountPercent > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_memberDiscountPercent.round()}% member discount applied',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                    ? RouteMapPreview(route: _route!, vehicleSlug: selectedSlug)
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
                : _vehicles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No vehicles available. Enable them in Admin Panel.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.mutedForeground),
                          ),
                        ),
                      )
                    : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._vehicles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final vehicle = entry.value;
                        final isSelected = _selectedVehicleIndex == index;
                        final distanceKm = _route?.distanceKm ?? 5.0;

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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: vehicle.imageUrl != null
                                        ? Image.network(
                                            vehicle.imageUrl!,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset(
                                              vehicle.imageAsset,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            vehicle.imageAsset,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              vehicle.icon,
                                              size: 32,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                vehicle.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.person_outline, size: 14, color: AppColors.mutedForeground),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${vehicle.capacity}',
                                              style: TextStyle(
                                                color: AppColors.mutedForeground,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          vehicle.tripSubtitle(distanceKm, index),
                                          style: TextStyle(
                                            color: AppColors.mutedForeground,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildFareLabel(vehicle),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: BookingCheckoutBar(
              paymentLabel: _paymentLabel,
              bookLabel: _bookButtonLabel,
              appliedCoupon: _appliedCoupon,
              isLoading: _booking,
              enabled: _route != null && _selectedVehicleIndex != null,
              onPaymentTap: _openPaymentSheet,
              onOffersTap: _openOffersSheet,
              onBookTap: _confirmBooking,
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
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;
  String? _rideId;
  DirectionsResult? _mapRoute;
  bool _loadingMapRoute = true;

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
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _checkRideStatus());
    Future.microtask(() async {
      await _loadRideId();
      _startRideRealtime();
      await _checkRideStatus();
      await _loadMapRoute();
    });
  }

  void _startRideRealtime() {
    final realtime = ref.read(rideRealtimeProvider);
    realtime.connect();
    _realtimeSub?.cancel();
    _realtimeSub = realtime.messages.listen((msg) {
      final event = msg['event']?.toString() ?? '';
      if (event != 'ride_accepted' || !mounted) return;
      _onDriverAccepted(msg);
    });
    final rideId = _rideId ?? ref.read(tripBookingProvider).activeRideId;
    if (rideId != null && rideId.isNotEmpty) {
      realtime.subscribeRide(rideId);
    }
  }

  void _onDriverAccepted(Map<String, dynamic> msg) {
    _pollTimer?.cancel();
    ref.invalidate(activeRideProvider);
    ref.invalidate(notificationsProvider);
    final driverName = msg['driver_name']?.toString() ?? 'Captain';
    final startCode = msg['start_code']?.toString() ?? '----';
    context.showSnackBar('$driverName accepted! Start code: $startCode');
    context.pushReplacement(RouteNames.bookTracking);
  }

  Future<void> _loadRideId() async {
    final fromState = ref.read(tripBookingProvider).activeRideId;
    if (fromState != null && fromState.isNotEmpty) {
      if (mounted) setState(() => _rideId = fromState);
      ref.read(rideRealtimeProvider).subscribeRide(fromState);
      return;
    }
    final active = await ref.read(rideBookingServiceProvider).getActiveRide();
    final id = active?['id']?.toString();
    if (id != null && id.isNotEmpty && mounted) {
      ref.read(tripBookingProvider.notifier).setActiveRideId(id);
      setState(() => _rideId = id);
      ref.read(rideRealtimeProvider).subscribeRide(id);
    }
  }

  Future<void> _checkRideStatus() async {
    try {
      final active = await ref.read(rideBookingServiceProvider).getActiveRide();
      final status = active?['status']?.toString();
      if (_isDriverAssigned(status) && mounted) {
        _onDriverAccepted({
          'driver_name': (active?['driver'] as Map?)?['name'] ?? 'Captain',
          'start_code': active?['start_code'] ?? '----',
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMapRoute() async {
    final trip = ref.read(tripBookingProvider);
    if (trip.route != null && trip.route!.path.length >= 2) {
      if (mounted) {
        setState(() {
          _mapRoute = trip.route;
          _loadingMapRoute = false;
        });
      }
      return;
    }

    final activeRide = ref.read(activeRideProvider).valueOrNull;
    final pickupLat = trip.pickup?.latitude ?? activeRide?.pickupLat;
    final pickupLng = trip.pickup?.longitude ?? activeRide?.pickupLng;
    final dropoffLat = trip.dropoff?.latitude ?? activeRide?.dropoffLat;
    final dropoffLng = trip.dropoff?.longitude ?? activeRide?.dropoffLng;

    if (pickupLat == null ||
        pickupLng == null ||
        dropoffLat == null ||
        dropoffLng == null) {
      if (mounted) setState(() => _loadingMapRoute = false);
      return;
    }

    try {
      final route = await ref.read(placesServiceProvider).getDirectionsByCoordinates(
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            dropoffLat: dropoffLat,
            dropoffLng: dropoffLng,
            pickupAddress: trip.pickup?.label ?? activeRide?.pickupAddress ?? '',
            dropoffAddress: trip.dropoff?.label ?? activeRide?.dropoffAddress ?? '',
          );
      ref.read(tripBookingProvider.notifier).setRoute(route);
      if (mounted) {
        setState(() {
          _mapRoute = route;
          _loadingMapRoute = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMapRoute = false);
    }
  }

  DirectionsResult? _resolveDirections(TripBookingState trip, UserActiveRide? activeRide) {
    if (_mapRoute != null) return _mapRoute;
    if (trip.route != null && trip.route!.path.length >= 2) return trip.route;
    return null;
  }

  Widget _buildMap(DirectionsResult? route, {String? vehicleSlug}) {
    if (route != null) {
      return RouteMapPreview(
        route: route,
        height: double.infinity,
        vehicleSlug: vehicleSlug,
      );
    }
    return Container(
      color: AppColors.muted,
      child: const Center(
        child: Icon(Icons.map_outlined, size: 64, color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _buildLocationRow({
    required Color dotColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeSub?.cancel();
    super.dispose();
  }

  void _goHomeFromSearching() {
    context.go(RouteNames.home);
  }

  String _searchingTitle(HomeBookingMode mode) {
    switch (mode) {
      case HomeBookingMode.parcel:
        return 'Finding delivery partner';
      case HomeBookingMode.rental:
        return 'Finding rental captain';
      case HomeBookingMode.ride:
        return 'Finding captain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideId = _rideId ?? ref.watch(tripBookingProvider).activeRideId ?? '';
    final trip = ref.watch(tripBookingProvider);
    final activeRide = ref.watch(activeRideProvider).valueOrNull;
    final route = _resolveDirections(trip, activeRide);
    final vehicleSlug = bookedVehicleSlugForTrip(trip.mode, trip.bookedVehicleSlug);
    final pickupAddress =
        trip.pickup?.label ?? activeRide?.pickupAddress ?? 'Pickup location';
    final dropoffAddress =
        trip.dropoff?.label ?? activeRide?.dropoffAddress ?? 'Drop location';

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
          title: Text(_searchingTitle(trip.mode)),
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
              child: Stack(
                children: [
                  _buildMap(route, vehicleSlug: vehicleSlug),
                  if (_loadingMapRoute)
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
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationRow(
                    dotColor: AppColors.success,
                    label: 'Pickup',
                    address: pickupAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildLocationRow(
                    dotColor: AppColors.error,
                    label: 'Drop',
                    address: dropoffAddress,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifying nearby captains...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Live tracking will start once a captain accepts',
                              style: TextStyle(
                                color: AppColors.mutedForeground,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (rideId.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    CancelRideButton(rideId: rideId, navigateHome: true),
                  ],
                ],
              ),
            ),
          ],
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
  Timer? _pollTimer;
  Timer? _safetyCheckTimer;
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;
  UserActiveRide? _optimisticRide;
  double? _liveDriverLat;
  double? _liveDriverLng;
  double? _liveDriverHeading;
  bool _ratingShown = false;
  bool _rideCompleted = false;
  bool _safetyCheckOpen = false;
  bool _locatingMe = false;
  final _liveMapController = LiveTrackingMapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadRideId();
      _startRideRealtime();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      ref.invalidate(activeRideProvider);
      _maybeStartSafetyCheckTimer();
    });
  }

  void _maybeStartSafetyCheckTimer() {
    final ride = ref.read(activeRideProvider).valueOrNull ?? _optimisticRide;
    final shouldRun = ride != null &&
        ride.showWomenSafetyControls &&
        ride.isInProgress &&
        !_rideCompleted;
    if (!shouldRun) {
      _safetyCheckTimer?.cancel();
      _safetyCheckTimer = null;
      return;
    }
    if (_safetyCheckTimer != null) return;
    _safetyCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _promptSafetyCheck();
    });
  }

  Future<void> _promptSafetyCheck() async {
    if (!mounted || _safetyCheckOpen || _rideCompleted) return;
    final ride = ref.read(activeRideProvider).valueOrNull ?? _optimisticRide;
    if (ride == null || !ride.showWomenSafetyControls || !ride.isInProgress) return;
    _safetyCheckOpen = true;
    try {
      await showSafetyCheckDialog(context: context, ref: ref, ride: ride);
    } finally {
      _safetyCheckOpen = false;
    }
  }

  void _startRideRealtime() {
    final realtime = ref.read(rideRealtimeProvider);
    realtime.connect();
    _realtimeSub?.cancel();
    _realtimeSub = realtime.messages.listen((msg) {
      final event = msg['event']?.toString() ?? '';
      if (!mounted) return;
      if (event == 'ride_accepted') {
        setState(() {
          _optimisticRide = UserActiveRide(
            id: msg['ride_id']?.toString() ?? _rideId ?? '',
            pickupAddress: msg['pickup_address'] as String? ?? '',
            dropoffAddress: msg['dropoff_address'] as String? ?? '',
            status: msg['status'] as String? ?? 'DRIVER_ASSIGNED',
            fareEstimate: (msg['estimated_fare'] as num?)?.toDouble(),
            driverName: msg['driver_name'] as String?,
            driverPhone: msg['driver_phone'] as String?,
            driverRating: (msg['driver_rating'] as num?)?.toDouble(),
            driverPhotoUrl: msg['driver_photo_url'] as String?,
            vehicleNumber: msg['vehicle_number'] as String?,
            vehicleTypeSlug: (msg['vehicle_type'] as Map?)?['slug'] as String? ??
                msg['vehicle_type_slug'] as String?,
            vehicleTypeName: (msg['vehicle_type'] as Map?)?['name'] as String? ??
                msg['vehicle_type_name'] as String?,
            startCode: msg['start_code']?.toString(),
            pickupLat: (msg['pickup_lat'] as num?)?.toDouble(),
            pickupLng: (msg['pickup_lng'] as num?)?.toDouble(),
            dropoffLat: (msg['dropoff_lat'] as num?)?.toDouble(),
            dropoffLng: (msg['dropoff_lng'] as num?)?.toDouble(),
          );
        });
        ref.invalidate(activeRideProvider);
        ref.invalidate(notificationsProvider);
      } else if (event == 'driver_location') {
        setState(() {
          _liveDriverLat = (msg['lat'] as num?)?.toDouble();
          _liveDriverLng = (msg['lng'] as num?)?.toDouble();
          final h = (msg['heading'] as num?)?.toDouble();
          if (h != null && h.isFinite && h >= 0) {
            _liveDriverHeading = h;
          }
        });
      } else if (event == 'ride_started') {
        setState(() {
          final status = msg['status']?.toString() ?? 'STARTED';
          if (_optimisticRide != null) {
            _optimisticRide = _optimisticRide!.copyWith(status: status, startCode: '');
          } else {
            final current = ref.read(activeRideProvider).valueOrNull;
            if (current != null) {
              _optimisticRide = current.copyWith(status: status, startCode: '');
            }
          }
        });
        ref.invalidate(activeRideProvider);
      } else if (event == 'ride_completed') {
        _handleRideCompleted(msg);
      } else if (event == 'chat_message') {
        _handleIncomingChat(msg);
      }
    });
    final rideId = _rideId ?? ref.read(tripBookingProvider).activeRideId;
    if (rideId != null && rideId.isNotEmpty) {
      realtime.subscribeRide(rideId);
    }
  }

  void _handleIncomingChat(Map<String, dynamic> msg) {
    final rideId = msg['ride_id']?.toString() ?? _rideId ?? '';
    if (rideId.isEmpty) return;
    if ((msg['sender_type']?.toString() ?? '') == 'user') return;
    if (ref.read(rideChatSheetOpenProvider)) return;

    final ride = _resolvedRide(ref.read(activeRideProvider).valueOrNull);
    final senderName = msg['sender_name']?.toString() ?? ride?.driverName ?? 'Captain';
    final text = msg['message']?.toString() ?? '';
    if (text.isEmpty || !mounted) return;

    showRideChatNotification(
      context,
      senderName: senderName,
      message: text,
      onTap: () {
        final resolved = _resolvedRide(ref.read(activeRideProvider).valueOrNull);
        if (resolved == null) return;
        showRideChatSheet(
          context: context,
          ref: ref,
          rideId: resolved.id,
          peerName: resolved.driverName ?? 'Captain',
          mySenderType: 'user',
        );
      },
    );
  }

  Future<void> _handleRideCompleted(Map<String, dynamic> msg) async {
    if (_ratingShown || !mounted) return;
    _ratingShown = true;
    _pollTimer?.cancel();
    _safetyCheckTimer?.cancel();
    setState(() => _rideCompleted = true);

    final rideId = msg['ride_id']?.toString() ?? _rideId ?? '';
    final driverName =
        _optimisticRide?.driverName ?? ref.read(activeRideProvider).valueOrNull?.driverName;

    if (!mounted) return;
    final result = await showRateRideDialog(
      context,
      title: 'Rate your captain',
      subtitle: driverName != null && driverName.isNotEmpty
          ? 'How was your ride with $driverName?'
          : 'How was your ride?',
    );

    if (result != null && rideId.isNotEmpty) {
      try {
        await ref.read(rideBookingServiceProvider).rateRide(
              rideId,
              rating: result['rating'] as int? ?? 5,
              comment: result['comment'] as String?,
            );
        if (mounted) {
          context.showSnackBar('Thanks for your feedback!');
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.userMessage, isError: true);
        }
      }
    }

    ref.read(tripBookingProvider.notifier).clearActiveRideId();
    ref.invalidate(activeRideProvider);
    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _safetyCheckTimer?.cancel();
    _realtimeSub?.cancel();
    super.dispose();
  }

  Future<void> _loadRideId() async {
    final fromState = ref.read(tripBookingProvider).activeRideId;
    if (fromState != null && fromState.isNotEmpty) {
      if (mounted) setState(() => _rideId = fromState);
      ref.read(rideRealtimeProvider).subscribeRide(fromState);
      return;
    }
    final active = await ref.read(rideBookingServiceProvider).getActiveRide();
    if (mounted) {
      setState(() => _rideId = active?['id']?.toString());
      final id = active?['id']?.toString();
      if (id != null && id.isNotEmpty) {
        ref.read(rideRealtimeProvider).subscribeRide(id);
      }
    }
  }

  UserActiveRide? _resolvedRide(UserActiveRide? apiRide) {
    UserActiveRide? base;
    if (apiRide != null && !apiRide.isSearching) {
      base = apiRide;
      if (_optimisticRide != null &&
          base.isInProgress &&
          (_optimisticRide!.startCode?.isNotEmpty ?? false)) {
        base = base.copyWith(startCode: '');
      }
    } else if (_optimisticRide != null) {
      base = _optimisticRide;
    } else {
      base = apiRide;
    }
    if (base == null) return null;
    if (_liveDriverLat != null && _liveDriverLng != null) {
      return base.copyWithDriverLocation(lat: _liveDriverLat, lng: _liveDriverLng);
    }
    return base;
  }

  Future<void> _goToMyLocation() async {
    if (_locatingMe) return;
    setState(() => _locatingMe = true);
    try {
      await _liveMapController.goToMyLocation();
    } finally {
      if (mounted) setState(() => _locatingMe = false);
    }
  }

  double _myLocationButtonBottom(UserActiveRide? ride) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (ride == null || ride.isSearching) {
      return screenHeight * 0.22 + 12;
    }
    if (ride.isInProgress) {
      return screenHeight * 0.48 + 12;
    }
    return screenHeight * 0.45 + 12;
  }

  Widget _buildMap(UserActiveRide? ride) {
    final trip = ref.watch(tripBookingProvider);
    final bookedVehicleSlug =
        bookedVehicleSlugForTrip(trip.mode, trip.bookedVehicleSlug);
    if (ride != null && !ride.isSearching && ride.pickupLat != null) {
      return LiveTrackingMap(
        ride: ride,
        driverLat: _liveDriverLat ?? ride.driverLat,
        driverLng: _liveDriverLng ?? ride.driverLng,
        driverHeading: _liveDriverHeading,
        fallbackVehicleSlug: bookedVehicleSlug,
        tripRoute: trip.route,
        controller: _liveMapController,
      );
    }
    final route = trip.route;
    if (route != null) {
      return RouteMapPreview(
        route: route,
        height: double.infinity,
        vehicleSlug: bookedVehicleSlug,
      );
    }
    return Container(
      color: AppColors.muted,
      child: const Center(
        child: Icon(Icons.map, size: 64, color: AppColors.mutedForeground),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideId = _rideId ?? ref.watch(tripBookingProvider).activeRideId ?? '';
    final activeRideAsync = ref.watch(activeRideProvider);
    final resolvedForMap = activeRideAsync.maybeWhen(
      data: (ride) => _resolvedRide(ride),
      orElse: () => _optimisticRide,
    );
    final driverAssigned =
        resolvedForMap != null && !resolvedForMap.isSearching;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: driverAssigned
          ? null
          : AppBar(
              title: const Text('Live tracking'),
            ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap(resolvedForMap)),
          if (driverAssigned)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _TrackingMapButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (rideId.isNotEmpty && !_rideCompleted)
                    Builder(
                      builder: (context) {
                        final resolved = _resolvedRide(activeRideAsync.valueOrNull);
                        if (resolved != null && resolved.isInProgress) {
                          return const SizedBox.shrink();
                        }
                        return CancelRideButton(
                          rideId: rideId,
                          navigateHome: true,
                          compact: true,
                        );
                      },
                    ),
                ],
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: activeRideAsync.when(
              loading: () => _TrackingBottomSheet.searching(rideId: rideId),
              error: (_, __) => _TrackingBottomSheet.searching(rideId: rideId),
              data: (ride) {
                final resolved = _resolvedRide(ride);
                if (resolved != null && resolved.isCompleted && !_ratingShown) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleRideCompleted({'ride_id': resolved.id});
                  });
                }
                if (resolved == null || resolved.isSearching) {
                  return _TrackingBottomSheet.searching(rideId: rideId);
                }
                return _TrackingBottomSheet.assigned(
                  ride: resolved,
                  rideId: rideId,
                );
              },
            ),
          ),
          // Above bottom sheet so it stays visible (map overlays sit under the sheet).
          if (driverAssigned)
            Positioned(
              right: 12,
              bottom: _myLocationButtonBottom(resolvedForMap),
              child: Material(
                color: Colors.white,
                elevation: 3,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _locatingMe ? null : _goToMyLocation,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: _locatingMe
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.my_location,
                            size: 22,
                            color: Color(0xFF1A73E8),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackingMapButton extends StatelessWidget {
  const _TrackingMapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: AppColors.foreground),
        ),
      ),
    );
  }
}

class _TrackingBottomSheet extends ConsumerWidget {
  const _TrackingBottomSheet._({
    required this.rideId,
    this.ride,
    required this.searching,
  });

  factory _TrackingBottomSheet.searching({required String rideId}) {
    return _TrackingBottomSheet._(rideId: rideId, searching: true);
  }

  factory _TrackingBottomSheet.assigned({
    required UserActiveRide ride,
    required String rideId,
  }) {
    return _TrackingBottomSheet._(
      rideId: rideId,
      ride: ride,
      searching: false,
    );
  }

  final String rideId;
  final UserActiveRide? ride;
  final bool searching;

  Future<void> _callDriver(BuildContext context) async {
    final phone = ride?.driverPhone;
    if (phone == null || phone.isEmpty) {
      context.showSnackBar('Driver phone not available', isError: true);
      return;
    }
    final launched = await NavigationLauncher.callPhone(phone);
    if (!launched && context.mounted) {
      context.showSnackBar('Could not open phone dialer', isError: true);
    }
  }

  void _openChat(BuildContext context, WidgetRef ref) {
    if (rideId.isEmpty) return;
    showRideChatSheet(
      context: context,
      ref: ref,
      rideId: rideId,
      peerName: ride?.driverName ?? 'Captain',
      mySenderType: 'user',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final inProgress = ride?.isInProgress == true;
    final sheetHeight = searching
        ? screenHeight * 0.22
        : inProgress
            ? screenHeight * 0.48
            : screenHeight * 0.45;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 14, 8 + bottomInset),
                child: searching || ride == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Finding captain...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'We will notify you when assigned',
                                      style: TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (rideId.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            CancelRideButton(rideId: rideId, navigateHome: true),
                          ],
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ride!.isInProgress
                            ? RideInProgressPanel(
                                ride: ride!,
                                onMessage: () => _openChat(context, ref),
                                onCall: () => _callDriver(context),
                              )
                            : RideAcceptedPanel(
                                ride: ride!,
                                onMessage: () => _openChat(context, ref),
                                onCall: () => _callDriver(context),
                              ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
