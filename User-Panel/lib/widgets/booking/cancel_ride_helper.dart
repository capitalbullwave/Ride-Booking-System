import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

Future<bool> confirmCancelRide(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancel ride?'),
      content: const Text(
        'Your captain search will stop and this booking will be cancelled.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Keep ride'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Cancel ride'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> cancelRideWithConfirmation({
  required BuildContext context,
  required WidgetRef ref,
  required String rideId,
  bool navigateHome = false,
}) async {
  if (rideId.isEmpty) {
    context.showSnackBar('Ride not found', isError: true);
    return false;
  }

  final confirmed = await confirmCancelRide(context);
  if (!confirmed || !context.mounted) return false;

  try {
    await ref.read(rideBookingServiceProvider).cancelRide(rideId);
    ref.read(tripBookingProvider.notifier).clearActiveRideId();
    ref.invalidate(activeRideProvider);

    if (context.mounted) {
      context.showSnackBar('Ride cancelled');
      if (navigateHome) {
        context.go(RouteNames.home);
      }
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      context.showSnackBar(e.userMessage, isError: true);
    }
    return false;
  }
}

class CancelRideButton extends ConsumerStatefulWidget {
  const CancelRideButton({
    super.key,
    required this.rideId,
    this.navigateHome = false,
    this.compact = false,
  });

  final String rideId;
  final bool navigateHome;
  final bool compact;

  @override
  ConsumerState<CancelRideButton> createState() => _CancelRideButtonState();
}

class _CancelRideButtonState extends ConsumerState<CancelRideButton> {
  bool _loading = false;

  Future<void> _onCancel() async {
    if (_loading) return;
    setState(() => _loading = true);
    await cancelRideWithConfirmation(
      context: context,
      ref: ref,
      rideId: widget.rideId,
      navigateHome: widget.navigateHome,
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return TextButton(
        onPressed: _loading ? null : _onCancel,
        style: TextButton.styleFrom(foregroundColor: AppColors.error),
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Cancel ride'),
      );
    }

    return AppButton(
      label: 'Cancel ride',
      variant: AppButtonVariant.outline,
      isLoading: _loading,
      onPressed: _onCancel,
    );
  }
}
