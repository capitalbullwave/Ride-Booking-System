import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class RideStatisticsScreen extends ConsumerWidget {
  const RideStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardViewModelProvider).statsState;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Statistics')),
      body: switch (statsState) {
        ViewStateLoading() => const _StatsGridSkeleton(),
        ViewStateError(:final message) => ErrorStateWidget(
            message: message,
            onRetry: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
          ),
        ViewStateSuccess(:final data) => _StatsBody(stats: data),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const _StatsBody({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = [
      _StatCardData('Today\'s Trips', '${stats.todayTrips}', Icons.today_outlined, AppColors.primary),
      _StatCardData('Weekly Trips', '${stats.weeklyTrips}', Icons.date_range_outlined, AppColors.info),
      _StatCardData('Monthly Trips', '${stats.monthlyTrips}', Icons.calendar_month_outlined, AppColors.secondary),
      _StatCardData('Completed', '${stats.completedTrips}', Icons.check_circle_outline, AppColors.success),
      _StatCardData('Cancelled', '${stats.cancelledTrips}', Icons.cancel_outlined, AppColors.error),
      _StatCardData('Acceptance Rate', '${stats.acceptanceRate.toStringAsFixed(0)}%', Icons.thumb_up_outlined, AppColors.success),
      _StatCardData('Cancellation Rate', '${stats.cancellationRate.toStringAsFixed(0)}%', Icons.thumb_down_outlined, AppColors.warning),
      _StatCardData('Online Hours', '${stats.onlineHours.toStringAsFixed(1)}h', Icons.access_time, AppColors.primary),
      _StatCardData('Average Rating', stats.rating.toStringAsFixed(1), Icons.star_outline, AppColors.warning),
    ];

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Icon(card.icon, color: card.color, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    card.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerLoading(height: double.infinity, borderRadius: AppRadius.card),
    );
  }
}
