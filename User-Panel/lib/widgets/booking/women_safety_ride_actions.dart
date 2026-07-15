import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/services/places_service.dart';

String buildLiveRideShareText(UserActiveRide ride, {int? etaMinutes}) {
  final driver = (ride.driverName ?? 'Captain').trim();
  final vehicle = (ride.vehicleNumber ?? '—').trim();
  final lat = ride.driverLat ?? ride.pickupLat;
  final lng = ride.driverLng ?? ride.pickupLng;
  final maps = (lat != null && lng != null)
      ? 'https://www.google.com/maps?q=$lat,$lng'
      : null;
  final eta = etaMinutes != null ? '$etaMinutes min' : 'Updating…';
  final rideRef = ride.publicId?.isNotEmpty == true ? ride.publicId! : ride.id;

  return [
    'Bull Wave Rides — Live Trip Share',
    'Driver: $driver',
    'Vehicle: $vehicle',
    'Destination: ${ride.dropoffAddress}',
    'ETA: $eta',
    if (maps != null) 'Live location: $maps',
    'Ride: $rideRef',
  ].join('\n');
}

Future<void> shareLiveRide(UserActiveRide ride, {int? etaMinutes}) async {
  final text = buildLiveRideShareText(ride, etaMinutes: etaMinutes);
  await Share.share(text, subject: 'Live ride tracking');
}

Future<bool> confirmAndTriggerSos(
  BuildContext context,
  WidgetRef ref,
  UserActiveRide ride,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      title: const Text('Send SOS alert?'),
      content: const Text(
        'We will notify your emergency contacts and our support team with '
        'your live location, driver name, and vehicle details.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Send SOS'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  double? lat = ride.driverLat ?? ride.pickupLat;
  double? lng = ride.driverLng ?? ride.pickupLng;
  try {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 4),
      ),
    );
    lat = pos.latitude;
    lng = pos.longitude;
  } catch (_) {}

  try {
    final result = await ref.read(rideBookingServiceProvider).triggerRideSos(
          ride.id,
          lat: lat,
          lng: lng,
          message: 'Passenger triggered SOS',
        );
    ref.invalidate(activeRideProvider);
    if (context.mounted) {
      final apiMessage = result['message']?.toString();
      final smsSent = result['emergency_sms_sent'] == true;
      context.showSnackBar(
        (apiMessage != null && apiMessage.isNotEmpty)
            ? apiMessage
            : (smsSent
                ? 'SOS sent. Emergency contacts and support have been notified.'
                : 'SOS sent to support. Emergency SMS may not have been delivered.'),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      context.showSnackBar(e.userMessage, isError: true);
    }
    return false;
  }
}

Future<void> showSafetyCheckDialog({
  required BuildContext context,
  required WidgetRef ref,
  required UserActiveRide ride,
}) async {
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      title: const Text('Are you safe?'),
      content: const Text(
        'Quick safety check. Tap Yes if everything is fine, or Need Help '
        'to alert emergency contacts.',
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop('help'),
          child: const Text(
            'Need Help',
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop('yes'),
          child: const Text('Yes, I am safe'),
        ),
      ],
    ),
  );

  if (result == 'help' && context.mounted) {
    await confirmAndTriggerSos(context, ref, ride);
  }
}

class WomenSafetyActionButtons extends ConsumerWidget {
  const WomenSafetyActionButtons({
    super.key,
    required this.ride,
    this.etaMinutes,
  });

  final UserActiveRide ride;
  final int? etaMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => shareLiveRide(ride, etaMinutes: etaMinutes),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share Ride'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => confirmAndTriggerSos(context, ref, ride),
            icon: const Icon(Icons.emergency_share_rounded, size: 18),
            label: const Text('SOS'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SafetyModeBadge extends StatelessWidget {
  const SafetyModeBadge({super.key, this.isEmergency = false});

  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    final bg = isEmergency
        ? AppColors.error.withValues(alpha: 0.12)
        : AppColors.success.withValues(alpha: 0.14);
    final fg = isEmergency ? AppColors.error : AppColors.success;
    final label = isEmergency ? 'Emergency Active' : 'Safety Mode Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
