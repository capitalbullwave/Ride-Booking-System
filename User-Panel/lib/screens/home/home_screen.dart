import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/constants/home_booking_mode.dart';
import 'package:wavego_user/core/constants/services.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/profile_display_provider.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/rental_booking_provider.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/services/ride_realtime_service.dart';
import 'package:wavego_user/widgets/booking/cancel_ride_helper.dart';
import 'package:wavego_user/widgets/home/active_ride_card.dart';
import 'package:wavego_user/widgets/home/location_card.dart';
import 'package:wavego_user/widgets/home/service_tile.dart';
import 'package:wavego_user/widgets/home/service_type_tabs.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _resolvingPickup = false;
  bool _cancellingRide = false;
  Timer? _activeRidePollTimer;
  StreamSubscription? _rideRealtimeSub;
  String? _subscribedRideId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillPickupIfNeeded();
      ref.invalidate(vehicleCategoriesProvider);
      ref.invalidate(activeRideProvider);
      _startActiveRidePolling();
      _startRideRealtime();
    });
  }

  @override
  void dispose() {
    _activeRidePollTimer?.cancel();
    _rideRealtimeSub?.cancel();
    super.dispose();
  }

  void _startRideRealtime() {
    final realtime = ref.read(rideRealtimeProvider);
    realtime.connect();

    _rideRealtimeSub?.cancel();
    _rideRealtimeSub = realtime.messages.listen((msg) {
      final event = msg['event']?.toString() ?? '';
      if (event.isEmpty) return;
      if (mounted) {
        if (event == 'ride_cancelled') {
          ref.read(tripBookingProvider.notifier).clearActiveRideId();
          _subscribedRideId = null;
        }
        ref.invalidate(activeRideProvider);
        if (event == 'ride_accepted') {
          ref.invalidate(notificationsProvider);
          final driverName = msg['driver_name']?.toString() ?? 'Captain';
          final startCode = msg['start_code']?.toString() ?? '----';
          context.showSnackBar('$driverName accepted! Start code: $startCode');
          final rideId = msg['ride_id']?.toString();
          if (rideId != null && rideId.isNotEmpty) {
            ref.read(tripBookingProvider.notifier).setActiveRideId(rideId);
          }
        } else if (event == 'driver_location') {
          ref.invalidate(activeRideProvider);
        }
      }
    });
  }

  void _startActiveRidePolling() {
    _activeRidePollTimer?.cancel();
    _activeRidePollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) ref.invalidate(activeRideProvider);
    });
  }

  void _openActiveRide(UserActiveRide ride) {
    ref.read(tripBookingProvider.notifier).setActiveRideId(ride.id);
    if (ride.isSearching) {
      context.push(RouteNames.bookSearching);
    } else {
      context.push(RouteNames.bookTracking);
    }
  }

  Future<void> _prefillPickupIfNeeded() async {
    final trip = ref.read(tripBookingProvider);
    if (trip.pickup != null) return;

    setState(() => _resolvingPickup = true);

    final position = await ref.read(locationServiceProvider).tryGetCurrentPosition();
    if (position == null || !mounted) {
      setState(() => _resolvingPickup = false);
      return;
    }

    final place = await ref.read(placesServiceProvider).reverseGeocode(
          position.latitude,
          position.longitude,
        );

    if (mounted) {
      ref.read(tripBookingProvider.notifier).setPickup(place);
      setState(() => _resolvingPickup = false);
    }
  }

  void _swapLocations() {
    ref.read(tripBookingProvider.notifier).swapLocations();
  }

  void _handleBook(TripBookingState trip) {
    if (trip.pickup == null || trip.dropoff == null) {
      _openLocation(context, isPickup: trip.pickup == null);
      return;
    }

    switch (trip.mode) {
      case HomeBookingMode.ride:
      case HomeBookingMode.parcel:
        context.push(RouteNames.book);
        break;
      case HomeBookingMode.rental:
        final rentalNotifier = ref.read(rentalBookingProvider.notifier);
        rentalNotifier.setPickup(trip.pickup!);
        rentalNotifier.setDropoff(trip.dropoff!);
        context.push(RouteNames.rental);
        break;
    }
  }

  void _onServiceModeChanged(HomeBookingMode mode) {
    ref.read(tripBookingProvider.notifier).setMode(mode);
  }

  Widget _buildBookingTabs(HomeBookingMode mode) {
    return ServiceTypeTabs(
      selected: mode,
      onChanged: _onServiceModeChanged,
    );
  }

  String _actionLabelFor(TripBookingState trip) {
    if (trip.scheduledAt != null) {
      switch (trip.mode) {
        case HomeBookingMode.ride:
          return 'Schedule ride';
        case HomeBookingMode.parcel:
          return 'Schedule parcel';
        case HomeBookingMode.rental:
          return trip.mode.actionLabel;
      }
    }
    return trip.mode.actionLabel;
  }

  LocationCard _buildLocationCard({
    required TripBookingState trip,
    required String pickup,
    required String dropoff,
    required bool isBookingLocked,
  }) {
    final mode = trip.mode;
    return LocationCard(
      pickup: pickup,
      dropoff: dropoff,
      stops: trip.stops
          .map((s) => s.label.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      onSwap: _swapLocations,
      onPickupTap: () => _openLocation(context, isPickup: true),
      onDropoffTap: () => _openLocation(context, isPickup: false),
      onStopTap: (_) => _openLocation(context, isPickup: false),
      onFindRide: () => _handleBook(trip),
      isBookingLocked: isBookingLocked,
      actionLabel: _actionLabelFor(trip),
      dropPlaceholder: mode.dropPlaceholder,
      dropFieldLabel: mode.dropFieldLabel,
      header: _buildBookingTabs(mode),
      showSchedule: mode != HomeBookingMode.rental,
      scheduledAt: trip.scheduledAt,
      onScheduleChanged: (dateTime) {
        ref.read(tripBookingProvider.notifier).setScheduledAt(dateTime);
      },
    );
  }

  List<HomeServiceItem> _servicesFromCategories(
    List<VehicleCategory> categories,
    HomeBookingMode mode,
  ) {
    final filtered = filterCategoriesForMode(categories, mode);
    return homeServicesForMode(
      filtered.map(homeServiceFromCategory).toList(),
      mode,
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    AsyncValue<List<VehicleCategory>> categoriesAsync,
    HomeBookingMode mode,
  ) {
    return categoriesAsync.when(
      loading: () => const _ServiceListShimmer(),
      error: (error, _) => _ServicesMessage(
        message: 'Unable to load services. Pull down to retry.',
        icon: Icons.cloud_off_outlined,
      ),
      data: (categories) {
        final services = _servicesFromCategories(categories, mode);
        if (services.isEmpty) {
          return const _ServicesMessage(
            message: 'No services available. Enable vehicles in Admin Panel.',
            icon: Icons.directions_car_outlined,
          );
        }

        return Column(
          children: services
              .map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ServiceTile(
                    service: service,
                    onTap: () => context.push(service.route),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripBookingProvider);
    final pickup = _resolvingPickup == true
        ? 'Getting your location...'
        : (trip.pickup?.label ?? '');
    final dropoff = trip.dropoff?.label ?? '';
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final vehicleCategoriesAsync = ref.watch(vehicleCategoriesProvider);
    final rentalCategoriesAsync = ref.watch(rentalCategoriesProvider);
    final serviceCategoriesAsync = trip.mode == HomeBookingMode.rental
        ? rentalCategoriesAsync
        : vehicleCategoriesAsync;
    final profileAsync = ref.watch(userProfileProvider);
    final notificationsAsync = ref.watch(notificationsProvider);
    final activeRideAsync = ref.watch(activeRideProvider);

    // Subscribe to the currently active ride_id for ride-specific events.
    activeRideAsync.whenData((ride) {
      final rideId = ride?.id;
      if (rideId == null || rideId.isEmpty) return;
      if (_subscribedRideId == rideId) return;
      _subscribedRideId = rideId;
      ref.read(rideRealtimeProvider).subscribeRide(rideId);
    });

    final displayName = ref.watch(homeGreetingNameProvider);

    final unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.read).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            refreshVehicleCatalog(ref);
            ref.invalidate(homeDashboardProvider);
            ref.invalidate(activeRideProvider);
            if (trip.mode == HomeBookingMode.rental) {
              await ref.read(rentalCategoriesProvider.future);
            } else {
              await ref.read(vehicleCategoriesProvider.future);
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    child: _HomeHeader(
                      displayName: displayName,
                      unreadCount: unreadCount,
                      onNotificationsTap: () => context.push(RouteNames.notifications),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: activeRideAsync.when(
                        loading: () => const ActiveRideCardShimmer(),
                        error: (e, st) => _buildLocationCard(
                          trip: trip,
                          pickup: pickup,
                          dropoff: dropoff,
                          isBookingLocked: false,
                        ),
                        data: (activeRide) {
                          if (activeRide != null) {
                            return ActiveRideCard(
                              ride: activeRide,
                              onTrack: () => _openActiveRide(activeRide),
                              isCancelling: _cancellingRide == true,
                              onCancel: () async {
                                setState(() => _cancellingRide = true);
                                final cancelled = await cancelRideWithConfirmation(
                                  context: context,
                                  ref: ref,
                                  rideId: activeRide.id,
                                );
                                if (mounted) {
                                  setState(() => _cancellingRide = false);
                                  if (cancelled) {
                                    _subscribedRideId = null;
                                  }
                                }
                              },
                            );
                          }
                          final isLocked = activeRideAsync.maybeWhen(
                            data: (ride) => ride != null,
                            orElse: () => false,
                          );
                          return _buildLocationCard(
                            trip: trip,
                            pickup: pickup,
                            dropoff: dropoff,
                            isBookingLocked: isLocked,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  dashboardAsync.when(
                    loading: () => const _BannerShimmer(),
                    error: (e, st) => const _PromoBanner(),
                    data: (dashboard) => _PromoBanner(
                      title: dashboard.banners.isNotEmpty
                          ? dashboard.banners.first.title
                          : null,
                      subtitle: dashboard.banners.isNotEmpty
                          ? dashboard.banners.first.subtitle
                          : null,
                      nearbyDrivers: dashboard.nearbyDriversCount,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Service',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap a service to get started',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(RouteNames.bookings),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('My bookings'),
                            Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildServicesSection(context, serviceCategoriesAsync, trip.mode),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _openLocation(BuildContext context, {required bool isPickup}) async {
    final result = await context.push<SelectedPlace>(
      RouteNames.location,
      extra: isPickup ? 'pickup' : 'dropoff',
    );
    if (result == null || !mounted) return;

    final notifier = ref.read(tripBookingProvider.notifier);
    if (isPickup) {
      notifier.setPickup(result);
    } else {
      notifier.setDropoff(result);
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.unreadCount,
    required this.onNotificationsTap,
  });

  final String displayName;
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                if (unreadCount > 0)
                  Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    this.title,
    this.subtitle,
    this.nearbyDrivers,
  });

  final String? title;
  final String? subtitle;
  final int? nearbyDrivers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.25),
            Colors.white,
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Ride smarter with Bull Wave Rides',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ??
                      'Book rides, send parcels, or request emergency ambulance — all in one app.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.45,
                      ),
                ),
                if (nearbyDrivers != null && nearbyDrivers! > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$nearbyDrivers drivers nearby',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    );
  }
}

class _ServiceListShimmer extends StatelessWidget {
  const _ServiceListShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesMessage extends StatelessWidget {
  const _ServicesMessage({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.mutedForeground, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),
        ],
      ),
    );
  }
}
