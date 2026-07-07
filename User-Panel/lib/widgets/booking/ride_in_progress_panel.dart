import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/geo_distance.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/widgets/booking/ride_accepted_panel.dart';

class RideInProgressPanel extends StatelessWidget {
  const RideInProgressPanel({
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
  Widget build(BuildContext context) {
    double? meters;
    if (ride.driverLat != null &&
        ride.driverLng != null &&
        ride.dropoffLat != null &&
        ride.dropoffLng != null) {
      meters = distanceBetweenMeters(
        lat1: ride.driverLat!,
        lng1: ride.driverLng!,
        lat2: ride.dropoffLat!,
        lng2: ride.dropoffLng!,
      );
    }

    final etaMinutes = meters != null ? estimatePickupMinutes(meters) : 5;
    final distanceLabel = meters != null
        ? formatDistanceAway(meters)
        : 'Heading to destination';
    final driverDisplay = (ride.driverName ?? 'Captain').trim();
    final driverUpper = driverDisplay.toUpperCase();
    final vehicleSlug = ride.vehicleTypeSlug ?? 'cab';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Ride in progress',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 8),
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
                        const TextSpan(text: 'Reach in '),
                        TextSpan(
                          text: '$etaMinutes min',
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
            _DropThumbnail(slug: vehicleSlug),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  driverUpper.isNotEmpty ? driverUpper[0] : 'C',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverUpper,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    if (ride.vehicleNumber != null &&
                        ride.vehicleNumber!.isNotEmpty)
                      Text(
                        ride.vehicleNumber!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                color: AppColors.primary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              if (onCall != null)
                IconButton(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                    'Drop at',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ride.dropoffAddress,
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
                  () => showRideTripDetailsSheet(context: context, ride: ride),
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

class _DropThumbnail extends StatelessWidget {
  const _DropThumbnail({required this.slug});

  final String slug;

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            vehicleIconForSlug(slug),
            color: AppColors.success,
            size: 18,
          ),
          const Text(
            'Drop',
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
