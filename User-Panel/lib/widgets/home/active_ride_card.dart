import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class ActiveRideCard extends StatelessWidget {
  const ActiveRideCard({
    super.key,
    required this.ride,
    required this.onTrack,
    this.onCancel,
    this.isCancelling = false,
  });

  final UserActiveRide ride;
  final VoidCallback onTrack;
  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ride.isSearching ? Icons.radar : Icons.local_taxi,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.statusLabel,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ride.statusSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                if (ride.fareEstimate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${ride.fareEstimate!.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RideLocationRow(
                  dotColor: AppColors.success,
                  label: 'Pickup',
                  value: ride.pickupAddress,
                ),
                const SizedBox(height: 12),
                _RideLocationRow(
                  dotColor: AppColors.error,
                  label: 'Drop',
                  value: ride.dropoffAddress,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: ride.isSearching ? 'View ride status' : 'Track ride',
                  onPressed: onTrack,
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Cancel ride',
                    variant: AppButtonVariant.outline,
                    isLoading: isCancelling == true,
                    onPressed: isCancelling == true ? null : onCancel,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideLocationRow extends StatelessWidget {
  const _RideLocationRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dotColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveRideCardShimmer extends StatelessWidget {
  const ActiveRideCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    );
  }
}
