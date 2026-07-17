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

Future<void> showRideRequestBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required RideRequest request,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RideRequestSheet(request: request),
  );
}

class _RideRequestSheet extends ConsumerStatefulWidget {
  const _RideRequestSheet({required this.request});

  final RideRequest request;

  @override
  ConsumerState<_RideRequestSheet> createState() => _RideRequestSheetState();
}

class _RideRequestSheetState extends ConsumerState<_RideRequestSheet> {
  Timer? _timer;
  late int _countdown;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _countdown = widget.request.expiresIn;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _decline(auto: true);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    _timer?.cancel();
    final rideId = widget.request.id;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      ref.read(rideViewModelProvider.notifier).setIncomingRequest(widget.request);
      // Wait for accept to commit before opening the trip screen — otherwise
      // active-ride polling can see null and show a false "ride cancelled" popup.
      await ref.read(rideViewModelProvider.notifier).acceptRide(rideId);
      if (mounted) Navigator.of(context).pop();
      router.go(RouteNames.activeTrip);
    } catch (e) {
      ref.read(rideViewModelProvider.notifier).clearRide();
      if (mounted) Navigator.of(context).pop();
      router.go(RouteNames.dashboard);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.userMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _decline({bool auto = false}) async {
    if (_busy) return;
    _timer?.cancel();
    if (!auto) {
      setState(() => _busy = true);
    }
    try {
      await ref
          .read(rideViewModelProvider.notifier)
          .declineRide(widget.request.id, reason: auto ? 'Timed out' : null);
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final isAccepting = ref.watch(rideViewModelProvider).isAccepting || _busy;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
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
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 18),
                      Text(' ${request.passengerRating}'),
                      const SizedBox(width: 8),
                      Text(
                        request.passengerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _AddressRow(
                icon: Icons.trip_origin,
                color: AppColors.success,
                address: request.pickupAddress,
                label: 'Pickup',
              ),
              for (var i = 0; i < request.stops.length; i++) ...[
                if (request.stops[i].address.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AddressRow(
                    icon: Icons.change_history,
                    color: AppColors.primary,
                    address: request.stops[i].address,
                    label: 'Stop ${i + 1}',
                  ),
                ],
              ],
              const SizedBox(height: 12),
              _AddressRow(
                icon: Icons.location_on,
                color: AppColors.error,
                address: request.destinationAddress,
                label: 'Destination',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.straighten,
                    label: DateFormatter.distance(request.distance),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.access_time,
                    label: DateFormatter.duration(request.estimatedTime),
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(icon: Icons.payment, label: request.paymentMode),
                ],
              ),
              const SizedBox(height: 20),
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
                      expand: false,
                      onPressed: isAccepting ? null : () => _decline(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: isAccepting ? 'Accepting...' : 'Accept Ride',
                      variant: AppButtonVariant.primary,
                      expand: false,
                      isLoading: isAccepting,
                      onPressed: isAccepting ? null : _accept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.icon,
    required this.color,
    required this.address,
    required this.label,
  });

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
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
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
