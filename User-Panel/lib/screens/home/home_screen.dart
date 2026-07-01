import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/constants/services.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/widgets/home/location_card.dart';
import 'package:wavego_user/widgets/home/service_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _resolvingPickup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillPickupIfNeeded());
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

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripBookingProvider);
    final pickup = _resolvingPickup
        ? 'Getting your location...'
        : (trip.pickup?.label ?? '');
    final dropoff = trip.dropoff?.label ?? '';
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    final displayName = dashboardAsync.maybeWhen(
      data: (d) => d.greetingName,
      orElse: () => profileAsync.maybeWhen(
        data: (p) => p?.name.split(' ').first ?? 'there',
        orElse: () => 'there',
      ),
    );

    final unreadCount = notificationsAsync.maybeWhen(
      data: (list) => list.where((n) => !n.read).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
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
                      child: LocationCard(
                        pickup: pickup,
                        dropoff: dropoff,
                        onSwap: _swapLocations,
                        onPickupTap: () => _openLocation(context, isPickup: true),
                        onDropoffTap: () => _openLocation(context, isPickup: false),
                        onFindRide: () {
                          if (trip.pickup == null || trip.dropoff == null) {
                            _openLocation(context, isPickup: trip.pickup == null);
                            return;
                          }
                          context.push(RouteNames.book);
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
                    error: (_, __) => const _PromoBanner(),
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
                  ...AppServices.homeServices.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceTile(
                        service: service,
                        onTap: () => context.push(service.route),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
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
                  title ?? 'Ride smarter with WaveGo',
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
