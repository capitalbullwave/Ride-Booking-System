import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/common/stat_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardViewModelProvider.notifier).loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardViewModelProvider);

    ref.listen(dashboardStateProvider(dashboardState.isOnline), (prev, next) {
      if (next && mounted) {
        _pollForRides();
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTab(state: dashboardState),
          const _TripsTabPlaceholder(),
          const _WalletTabPlaceholder(),
          const _NotificationsTabPlaceholder(),
          const _ProfileTabPlaceholder(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.push(RouteNames.trips);
          } else if (index == 2) {
            context.push(RouteNames.wallet);
          } else if (index == 3) {
            context.push(RouteNames.notifications);
          } else if (index == 4) {
            context.push(RouteNames.profile);
          } else {
            setState(() => _navIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: dashboardState.isOnline
          ? null
          : null,
    );
  }

  void _pollForRides() async {
    await ref.read(rideViewModelProvider.notifier).pollForRideRequest();
    final rideState = ref.read(rideViewModelProvider);
    if (rideState.incomingRequest != null && mounted) {
      context.push(RouteNames.rideRequest);
    }
  }
}

final dashboardStateProvider = Provider.family<bool, bool>((ref, isOnline) => isOnline);

class _HomeTab extends ConsumerWidget {
  const _HomeTab({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
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
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, ${state.profile?.name.split(' ').first ?? 'Captain'}! 👋',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                              Text(
                                state.statsState is ViewStateSuccess
                                    ? (state.statsState as ViewStateSuccess).data.currentLocation ?? 'Fetching location...'
                                    : 'Fetching location...',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        OnlineToggle(
                          isOnline: state.isOnline,
                          isLoading: state.isTogglingOnline,
                          onChanged: (v) => ref.read(dashboardViewModelProvider.notifier).toggleOnline(v),
                        ),
                      ],
                    ),
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
                    onRetry: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
                  ),
                ViewStateSuccess(:final data) => Padding(
                    padding: padding,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: "Today's Earnings",
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
                                value: '${data.rating} ⭐',
                                icon: Icons.star,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Performance',
                                value: '${data.acceptanceRate.toStringAsFixed(0)}%',
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
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
                Text('Searching for rides...', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('Stay in high-demand areas', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripsTabPlaceholder extends StatelessWidget {
  const _TripsTabPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _WalletTabPlaceholder extends StatelessWidget {
  const _WalletTabPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _NotificationsTabPlaceholder extends StatelessWidget {
  const _NotificationsTabPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProfileTabPlaceholder extends StatelessWidget {
  const _ProfileTabPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
