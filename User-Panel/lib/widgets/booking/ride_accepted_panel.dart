import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/geo_distance.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/widgets/booking/driver_avatar_rating.dart';

class RideAcceptedPanel extends ConsumerWidget {
  const RideAcceptedPanel({
    super.key,
    required this.ride,
    required this.onMessage,
    this.onCall,
    this.onTripDetails,
  });

  final UserActiveRide ride;
  final VoidCallback onMessage;
  final VoidCallback? onCall;
  final VoidCallback? onTripDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double? meters;
    if (ride.driverLat != null &&
        ride.driverLng != null &&
        ride.pickupLat != null &&
        ride.pickupLng != null) {
      meters = distanceBetweenMeters(
        lat1: ride.driverLat!,
        lng1: ride.driverLng!,
        lat2: ride.pickupLat!,
        lng2: ride.pickupLng!,
      );
    }

    final pickupMinutes = meters != null ? estimatePickupMinutes(meters) : 1;
    final distanceLabel = meters != null
        ? 'Captain ${formatDistanceAway(meters)}'
        : 'Captain is on the way';
    final driverDisplay = (ride.driverName ?? 'Captain').trim();
    final driverUpper = driverDisplay.toUpperCase();
    final showPin = !ride.isInProgress &&
        ride.startCode != null &&
        ride.startCode!.isNotEmpty;
    final pinDigits = showPin
        ? ride.startCode!.padRight(4, ' ').split('').take(4).toList()
        : <String>[];

    final headlinePrefix = ride.isInProgress ? 'Drop in ' : 'Pickup in ';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1F1F),
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(text: headlinePrefix),
                        TextSpan(
                          text: '$pickupMinutes min',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distanceLabel,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PickupThumbnail(address: ride.pickupAddress),
          ],
        ),
        if (showPin) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Start your order with PIN',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              for (var i = 0; i < pinDigits.length; i++) ...[
                _PinBox(digit: pinDigits[i].trim()),
                if (i < pinDigits.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ride.vehicleNumber != null &&
                            ride.vehicleNumber!.isNotEmpty)
                          Text(
                            ride.vehicleNumber!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 0.3,
                              color: Color(0xFF111827),
                            ),
                          ),
                        Text(
                          driverUpper,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            letterSpacing: 0.2,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DriverAvatarWithRating(
                    name: driverDisplay,
                    photoUrl: ride.driverPhotoUrl,
                    rating: ride.driverRating,
                    radius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onMessage,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 15,
                          color: Color(0xFF374151),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Message $driverUpper',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                        if (onCall != null)
                          GestureDetector(
                            onTap: onCall,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pickup From',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ride.pickupAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF111827),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onTripDetails ??
                  () => showRideTripDetailsSheet(
                        context: context,
                        ride: ride,
                        route: ref.read(tripBookingProvider).route,
                      ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                minimumSize: const Size(0, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Trip Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickupThumbnail extends StatelessWidget {
  const _PickupThumbnail({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: AppColors.primary, size: 18),
          Text(
            'Pickup',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({required this.digit});

  final String digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

void showRideTripDetailsSheet({
  required BuildContext context,
  required UserActiveRide ride,
  DirectionsResult? route,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _TripDetailsSheet(ride: ride, route: route),
  );
}

class _TripDetailsSheet extends ConsumerWidget {
  const _TripDetailsSheet({
    required this.ride,
    this.route,
  });

  final UserActiveRide ride;
  final DirectionsResult? route;

  List<RideStopLocation> _effectiveStops(TripBookingState trip) {
    if (ride.stops.any((s) => s.address.trim().isNotEmpty)) {
      return ride.stops.where((s) => s.address.trim().isNotEmpty).toList();
    }
    return [
      for (final s in trip.stops.where((s) => s.label.trim().isNotEmpty))
        RideStopLocation(
          address: s.label,
          lat: s.latitude ?? 0,
          lng: s.longitude ?? 0,
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripBookingProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final filledStops = _effectiveStops(trip);
    final distanceKm =
        ride.distanceKm ?? route?.distanceKm ?? trip.route?.distanceKm;
    final durationMin =
        ride.durationMin ?? route?.durationMin ?? trip.route?.durationMin;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Trip details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (ride.publicId != null && ride.publicId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Ride ID: ${ride.publicId}',
                  style: const TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                ride.statusLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              _TripDetailRow(
                label: 'Pickup',
                value: ride.pickupAddress,
                dotColor: const Color(0xFFE53935),
              ),
              for (var i = 0; i < filledStops.length; i++) ...[
                const SizedBox(height: 12),
                _TripDetailRow(
                  label: 'Stop ${i + 1}',
                  value: filledStops[i].address,
                  dotColor: AppColors.primary,
                  diamond: true,
                  number: i + 1,
                ),
              ],
              const SizedBox(height: 12),
              _TripDetailRow(
                label: 'Drop',
                value: ride.dropoffAddress,
                dotColor: AppColors.success,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              if (ride.fareEstimate != null)
                _metaRow(
                  'Estimated fare',
                  '₹${ride.fareEstimate!.round()}',
                  highlight: true,
                ),
              if (distanceKm != null && distanceKm > 0)
                _metaRow(
                  'Distance',
                  '${distanceKm.toStringAsFixed(1)} km',
                ),
              if (durationMin != null && durationMin > 0)
                _metaRow(
                  'Duration',
                  '${durationMin.round()} min',
                ),
              if (filledStops.isNotEmpty)
                _metaRow(
                  'Stops',
                  '${filledStops.length}',
                ),
              if (ride.vehicleTypeName != null)
                _metaRow('Vehicle', ride.vehicleTypeName!),
              if (ride.vehicleNumber != null && ride.vehicleNumber!.isNotEmpty)
                _metaRow('Vehicle number', ride.vehicleNumber!),
              if (ride.driverName != null && ride.driverName!.isNotEmpty)
                _metaRow('Captain', ride.driverName!),
              if (ride.paymentMethod != null && ride.paymentMethod!.isNotEmpty)
                _metaRow('Payment', ride.paymentMethod!),
              if (ride.startCode != null &&
                  ride.startCode!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Ride PIN',
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ride.startCode!
                      .trim()
                      .split('')
                      .map(
                        (digit) => Container(
                          width: 40,
                          height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            digit,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share this PIN with your captain only when you start the ride.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedForeground),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: highlight ? 16 : 14,
              color: highlight ? AppColors.primary : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  const _TripDetailRow({
    required this.label,
    required this.value,
    required this.dotColor,
    this.diamond = false,
    this.number,
  });

  final String label;
  final String value;
  final Color dotColor;
  final bool diamond;
  final int? number;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: diamond && number != null
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 12,
                        height: 12,
                        alignment: Alignment.center,
                        color: dotColor,
                        child: Transform.rotate(
                          angle: -0.785398,
                          child: Text(
                            '$number',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: diamond ? AppColors.primary : AppColors.mutedForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
