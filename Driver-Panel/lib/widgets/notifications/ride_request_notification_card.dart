import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/ride_notification_utils.dart';
import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class RideRequestNotificationCard extends ConsumerStatefulWidget {
  const RideRequestNotificationCard({
    super.key,
    required this.notification,
    required this.onHandled,
  });

  final AppNotification notification;
  final VoidCallback onHandled;

  @override
  ConsumerState<RideRequestNotificationCard> createState() =>
      _RideRequestNotificationCardState();
}

class _RideRequestNotificationCardState
    extends ConsumerState<RideRequestNotificationCard> {
  bool _busy = false;

  RideRequest? get _request => rideRequestFromNotification(widget.notification);

  Future<void> _accept() async {
    final request = _request;
    if (request == null || _busy) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      ref.read(rideViewModelProvider.notifier).setIncomingRequest(request);
      await ref.read(rideViewModelProvider.notifier).acceptRide(request.id);
      router.go(RouteNames.activeTrip);
      if (!mounted) return;
      widget.onHandled();
    } catch (e) {
      ref.read(rideViewModelProvider.notifier).clearRide();
      router.go(RouteNames.dashboard);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.userMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final request = _request;
    if (request == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(rideViewModelProvider.notifier).declineRide(request.id);
      if (!mounted) return;
      widget.onHandled();
      context.showSnackBar('Ride declined');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final request = _request;
    final unread = !n.read;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: unread
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (request != null)
                          Text(
                            request.passengerName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (unread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (request != null) ...[
                _LocationRow(
                  icon: Icons.trip_origin,
                  color: AppColors.success,
                  label: 'Pickup',
                  address: request.pickupAddress,
                ),
                const SizedBox(height: 8),
                _LocationRow(
                  icon: Icons.location_on,
                  color: AppColors.error,
                  label: 'Drop',
                  address: request.destinationAddress,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.payments_outlined,
                      label: DateFormatter.currency(request.estimatedFare),
                    ),
                    _MetaChip(
                      icon: Icons.straighten,
                      label: DateFormatter.distance(request.distance),
                    ),
                    _MetaChip(
                      icon: Icons.access_time,
                      label: DateFormatter.duration(request.estimatedTime),
                    ),
                    _MetaChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: request.paymentMode,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Reject',
                        variant: AppButtonVariant.outline,
                        isLoading: _busy,
                        onPressed: _busy ? null : _reject,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: _busy ? 'Accepting...' : 'Accept',
                        expand: false,
                        isLoading: _busy,
                        onPressed: _busy ? null : _accept,
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  n.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
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
              Text(
                address,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(20),
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
