import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  const RideRequestScreen({super.key});

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen> {
  Timer? _timer;
  int _countdown = 15;
  RideRequest? _request;

  @override
  void initState() {
    super.initState();
    _request = ref.read(rideViewModelProvider).incomingRequest;
    _countdown = _request?.expiresIn ?? 15;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _decline();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _accept() async {
    if (_request == null) return;
    _timer?.cancel();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      ref.read(rideViewModelProvider.notifier).setIncomingRequest(_request!);
      ref.read(rideViewModelProvider.notifier).primeActiveTripFromRequest(_request!);
      router.go(RouteNames.activeTrip);
      await ref.read(rideViewModelProvider.notifier).acceptRide(_request!.id);
    } catch (e) {
      ref.read(rideViewModelProvider.notifier).clearRide();
      router.go(RouteNames.dashboard);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.userMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _decline() async {
    if (_request == null) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Reason for declining',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ...['Too far', 'Low fare', 'Traffic / road issue', 'Personal reason']
                .map(
              (r) => ListTile(
                title: Text(r),
                onTap: () => Navigator.pop(ctx, r),
              ),
            ),
            ListTile(
              title: const Text('Decline without reason'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
    _timer?.cancel();
    await ref
        .read(rideViewModelProvider.notifier)
        .declineRide(_request!.id, reason: reason);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    if (request == null) {
      return const Scaffold(body: Center(child: Text('No ride request')));
    }

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Column(
        children: [
          const Spacer(),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Text(
                        '$_countdown s',
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 18),
                        Text(' ${request.passengerRating}'),
                        const SizedBox(width: 8),
                        Text(request.passengerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _AddressRow(icon: Icons.trip_origin, color: AppColors.success, address: request.pickupAddress, label: 'Pickup'),
                const SizedBox(height: 12),
                _AddressRow(icon: Icons.location_on, color: AppColors.error, address: request.destinationAddress, label: 'Destination'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _InfoChip(icon: Icons.straighten, label: DateFormatter.distance(request.distance)),
                    const SizedBox(width: 12),
                    _InfoChip(icon: Icons.access_time, label: DateFormatter.duration(request.estimatedTime)),
                    const SizedBox(width: 12),
                    _InfoChip(icon: Icons.payment, label: request.paymentMode),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    DateFormatter.currency(request.estimatedFare),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Decline',
                        variant: AppButtonVariant.outline,
                        onPressed: _decline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Accept Ride',
                        variant: AppButtonVariant.secondary,
                        isLoading: ref.watch(rideViewModelProvider).isAccepting,
                        onPressed: _accept,
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

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.icon, required this.color, required this.address, required this.label});
  final IconData icon;
  final Color color;
  final String address;
  final String label;

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
              Text(address, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
