import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/core/utils/ride_notification_utils.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/services/ride_realtime_service.dart';
import 'package:wavego_driver/screens/notifications/notifications_screen.dart';
import 'package:wavego_driver/screens/profile/profile_screen.dart';
import 'package:wavego_driver/screens/trip/trip_history_screen.dart';
import 'package:wavego_driver/screens/wallet/wallet_screen.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/common/stat_card.dart';
import 'package:wavego_driver/widgets/ride/ride_request_bottom_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = 0;
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;
  final Set<String> _presentedRideIds = {};
  bool _showingRideSheet = false;

  bool get _isOnRideRequestRoute {
    if (!mounted) return false;
    final location = GoRouter.of(context).state.matchedLocation;
    return location == RouteNames.rideRequest ||
        location.startsWith('${RouteNames.rideRequest}/');
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(dashboardViewModelProvider.notifier).loadDashboard();
      if (!mounted) return;

      final activeRide =
          await ref.read(rideViewModelProvider.notifier).restoreActiveRide();
      if (activeRide != null && mounted) {
        context.go(RouteNames.activeTrip);
        return;
      }

      await _loadNotificationBadge();
      if (!mounted) return;

      if (ref.read(dashboardViewModelProvider).isOnline) {
        await _refreshOnlineData();
        _startRealtimeRideListener();
      }
    });
  }

  @override
  void dispose() {
    _stopRealtimeRideListener();
    super.dispose();
  }

  Future<void> _refreshOnlineData() async {
    if (!ref.read(dashboardViewModelProvider).isOnline) return;
    await _pollForRides();
    await _pollNotifications();
    await _checkActiveRideRedirect();
  }

  void _startRealtimeRideListener() {
    _stopRealtimeRideListener();
    final realtime = ref.read(rideRealtimeProvider);
    unawaited(_connectRealtime(realtime));
  }

  Future<void> _connectRealtime(RideRealtimeService realtime) async {
    await realtime.connect();
    if (!mounted) return;
    _realtimeSub = realtime.messages.listen((message) {
      if (!mounted) return;
      if (message['event'] != 'ride_request') return;
      if (!ref.read(dashboardViewModelProvider).isOnline) return;
      if (ref.read(rideViewModelProvider).activeRide != null) return;
      if (_showingRideSheet || _isOnRideRequestRoute) return;

      final request = rideRequestFromRealtimePayload(message);
      if (request == null) return;
      if (_presentedRideIds.contains(request.id)) return;
      if (ref.read(rideViewModelProvider.notifier).isDismissed(request.id)) {
        return;
      }
      unawaited(_presentRideRequestOnce(request));
    });
  }

  void _stopRealtimeRideListener() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
  }

  Future<void> _checkActiveRideRedirect() async {
    if (!mounted) return;
    if (ref.read(rideViewModelProvider).activeRide != null) {
      if (GoRouter.of(context).state.matchedLocation != RouteNames.activeTrip) {
        context.go(RouteNames.activeTrip);
      }
      return;
    }
    final ride = await ref.read(rideViewModelProvider.notifier).restoreActiveRide();
    if (ride != null && mounted) {
      context.go(RouteNames.activeTrip);
    }
  }

  Future<void> _loadNotificationBadge() async {
    try {
      final items =
          await ref.read(notificationRepositoryProvider).getNotifications();
      final unread = items.where((n) => !n.read).length;
      ref.read(notificationUnreadCountProvider.notifier).state = unread;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final unreadCount = ref.watch(notificationUnreadCountProvider);

    ref.listen(dashboardStateProvider(dashboardState.isOnline), (prev, next) {
      if (next && mounted) {
        unawaited(_refreshOnlineData());
        _startRealtimeRideListener();
      } else {
        _stopRealtimeRideListener();
      }
    });

    ref.listen(rideViewModelProvider.select((s) => s.activeRide), (prev, next) {
      if (next != null && mounted) {
        context.go(RouteNames.activeTrip);
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(
            state: dashboardState,
            onRefresh: () async {
              await ref.read(dashboardViewModelProvider.notifier).loadDashboard();
              await _refreshOnlineData();
            },
          ),
          const TripHistoryScreen(embedded: true),
          const WalletScreen(embedded: true),
          const NotificationsScreen(embedded: true),
          const ProfileScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          setState(() => _navIndex = index);
          if (index == 4) {
            ref.read(dashboardViewModelProvider.notifier).loadDashboard();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Trips',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            selectedIcon: unreadCount > 0
                ? Badge(
                    label: Text('$unreadCount'),
                    child: const Icon(Icons.notifications),
                  )
                : const Icon(Icons.notifications),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _pollNotifications() async {
    if (!ref.read(dashboardViewModelProvider).isOnline) return;
    if (ref.read(rideViewModelProvider).activeRide != null) return;

    try {
      final items =
          await ref.read(notificationRepositoryProvider).getNotifications();
      final unread = items.where((n) => !n.read).length;
      ref.read(notificationUnreadCountProvider.notifier).state = unread;

      if (_showingRideSheet || _isOnRideRequestRoute) return;
      if (ref.read(rideViewModelProvider).incomingRequest != null) return;

      for (final n in items) {
        if (!isActionableRideRequestNotification(n)) continue;
        final id = rideIdFromNotification(n);
        if (id == null || _presentedRideIds.contains(id)) continue;
        if (ref.read(rideViewModelProvider.notifier).isDismissed(id)) continue;

        final request = rideRequestFromNotification(n);
        if (request == null) continue;
        await _presentRideRequestOnce(request);
        break;
      }
    } catch (_) {}
  }

  Future<void> _presentRideRequestOnce(RideRequest request) async {
    if (!mounted) return;
    if (_presentedRideIds.contains(request.id)) return;
    if (_showingRideSheet) return;
    if (ref.read(rideViewModelProvider.notifier).isDismissed(request.id)) return;

    _presentedRideIds.add(request.id);
    ref.read(rideViewModelProvider.notifier).setIncomingRequest(request);

    if (ref.read(autoAcceptProvider)) {
      try {
        ref.read(rideViewModelProvider.notifier).setIncomingRequest(request);
        ref.read(rideViewModelProvider.notifier).primeActiveTripFromRequest(request);
        if (mounted) context.go(RouteNames.activeTrip);
        await ref.read(rideViewModelProvider.notifier).acceptRide(request.id);
      } catch (e) {
        if (mounted) context.showSnackBar(e.userMessage, isError: true);
      }
      return;
    }

    _showingRideSheet = true;
    await showRideRequestBottomSheet(
      context: context,
      ref: ref,
      request: request,
    );
    _showingRideSheet = false;
  }

  Future<void> _pollForRides() async {
    if (!ref.read(dashboardViewModelProvider).isOnline) return;
    if (ref.read(rideViewModelProvider).activeRide != null) return;
    if (_showingRideSheet || _isOnRideRequestRoute) return;

    await ref.read(rideViewModelProvider.notifier).pollForRideRequest();
    final request = ref.read(rideViewModelProvider).incomingRequest;
    if (request == null || !mounted) return;
    if (_presentedRideIds.contains(request.id)) return;

    await _presentRideRequestOnce(request);
  }
}

final dashboardStateProvider = Provider.family<bool, bool>((ref, isOnline) => isOnline);

class _HomeTab extends ConsumerWidget {
  const _HomeTab({
    required this.state,
    required this.onRefresh,
  });

  final DashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          child: Text(
                            (state.profile?.name ?? 'D')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${state.profile?.name.split(' ').first ?? 'Captain'}! 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                state.statsState is ViewStateSuccess
                                    ? (state.statsState as ViewStateSuccess)
                                            .data
                                            .currentLocation ??
                                        'Fetching location...'
                                    : 'Fetching location...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        OnlineToggle(
                          isOnline: state.isOnline,
                          isLoading: state.isTogglingOnline,
                          canGoOnline: state.canGoOnline,
                          onBlockedGoOnline: () => context.showSnackBar(
                            state.profile?.verificationStatus == 'rejected'
                                ? 'Your documents were rejected. Please update and resubmit.'
                                : 'Account verification is pending. You can go online after admin approval.',
                            isError: true,
                          ),
                          onChanged: (v) async {
                            final error = await ref
                                .read(dashboardViewModelProvider.notifier)
                                .toggleOnline(v);
                            if (error != null && context.mounted) {
                              context.showSnackBar(error, isError: true);
                            }
                          },
                        ),
                      ],
                    ),
                    if (!state.canGoOnline) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.profile?.verificationStatus == 'rejected'
                                    ? 'Verification rejected. Update your documents to go online.'
                                    : 'Verification in progress. You can go online after admin approval.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (state.isOnline) _SearchingAnimation(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: switch (state.statsState) {
                ViewStateLoading() => const DashboardSkeleton(),
                ViewStateError(:final message) => ErrorStateWidget(
                    message: message,
                    onRetry: () => ref
                        .read(dashboardViewModelProvider.notifier)
                        .loadDashboard(),
                  ),
                ViewStateSuccess(:final data) => Padding(
                    padding: padding,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: "Today's Commission",
                                value: DateFormatter.currency(data.todayEarnings),
                                icon: Icons.currency_rupee,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Wallet Balance',
                                value: DateFormatter.currency(data.walletBalance),
                                icon: Icons.account_balance_wallet,
                                onTap: () => context.push(RouteNames.wallet),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Completed Trips',
                                value: '${data.completedTrips}',
                                icon: Icons.check_circle_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: "Today's Trips",
                                value: '${data.todayTrips}',
                                icon: Icons.local_taxi,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Rating',
                                value: data.rating.toStringAsFixed(1),
                                icon: Icons.star,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Performance',
                                value:
                                    '${data.acceptanceRate.toStringAsFixed(0)}%',
                                subtitle: 'Acceptance rate',
                                icon: Icons.trending_up,
                                onTap: () => context.push(RouteNames.earnings),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                _ => const DashboardSkeleton(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchingAnimation extends StatefulWidget {
  @override
  State<_SearchingAnimation> createState() => _SearchingAnimationState();
}

class _SearchingAnimationState extends State<_SearchingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          RotationTransition(
            turns: _controller,
            child: const Icon(Icons.radar, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Searching for rides...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Stay in high-demand areas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
