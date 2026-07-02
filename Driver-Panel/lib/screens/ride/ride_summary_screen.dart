import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class RideSummaryScreen extends ConsumerStatefulWidget {
  const RideSummaryScreen({super.key});

  @override
  ConsumerState<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends ConsumerState<RideSummaryScreen> {
  RideSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ride = ref.read(rideViewModelProvider).activeRide;
    if (ride == null) {
      setState(() { _loading = false; _error = 'No ride data'; });
      return;
    }
    final summary = await ref.read(rideViewModelProvider.notifier).getSummary(ride.id);
    setState(() {
      _summary = summary;
      _loading = false;
      _error = summary == null ? 'Failed to load summary' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: ErrorStateWidget(message: _error!, onRetry: _load));

    final s = _summary!;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Summary')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _Row(Icons.trip_origin, AppColors.success, 'Pickup', s.pickupAddress),
                    const SizedBox(height: 12),
                    _Row(Icons.location_on, AppColors.error, 'Destination', s.destinationAddress),
                    const Divider(height: 32),
                    _Detail('Distance', DateFormatter.distance(s.distance)),
                    _Detail('Duration', DateFormatter.duration(s.duration)),
                    _Detail('Fare', DateFormatter.currency(s.fare)),
                    _Detail('Commission', DateFormatter.currency(s.commission)),
                    _Detail('Net Earnings', DateFormatter.currency(s.netEarnings), highlight: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Rating('Passenger', s.passengerRating ?? 0),
                    _Rating('Your Rating', s.driverRating ?? 0),
                  ],
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Back to Dashboard',
              onPressed: () {
                ref.read(rideViewModelProvider.notifier).clearRide();
                context.go(RouteNames.dashboard);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.color, this.label, this.value);
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.w600, color: highlight ? AppColors.primary : null)),
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating(this.label, this.rating);
  final String label;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.warning, size: 20),
            Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ],
    );
  }
}
