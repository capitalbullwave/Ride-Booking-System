import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/widgets/common/app_button.dart';
import 'package:wavego_user/widgets/home/ride_schedule_section.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.onSwap,
    required this.onPickupTap,
    required this.onDropoffTap,
    required this.onFindRide,
    this.isBookingLocked = false,
    this.actionLabel = 'Find a ride',
    this.dropPlaceholder = 'Where are you going?',
    this.dropFieldLabel = 'Drop',
    this.header,
    this.showSchedule = false,
    this.scheduledAt,
    this.onScheduleChanged,
  });

  final String pickup;
  final String dropoff;
  final VoidCallback onSwap;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final VoidCallback onFindRide;
  final bool isBookingLocked;
  final String actionLabel;
  final String dropPlaceholder;
  final String dropFieldLabel;
  final Widget? header;
  final bool showSchedule;
  final DateTime? scheduledAt;
  final ValueChanged<DateTime?>? onScheduleChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: 16),
          ],
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 18, bottom: 18),
                  child: CustomPaint(
                    size: const Size(10, double.infinity),
                    painter: _DottedLinePainter(
                      color: AppColors.mutedForeground.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      _LocationRow(
                        dotColor: AppColors.error,
                        label: 'Pickup',
                        labelColor: AppColors.success,
                        value: pickup.isEmpty ? 'Current Location' : pickup,
                        isPlaceholder: pickup.isEmpty,
                        onTap: onPickupTap,
                      ),
                      const SizedBox(height: 12),
                      _LocationRow(
                        dotColor: AppColors.success,
                        label: dropFieldLabel,
                        labelColor: AppColors.error,
                        value: dropoff.isEmpty ? dropPlaceholder : dropoff,
                        isPlaceholder: dropoff.isEmpty,
                        onTap: onDropoffTap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Center(
                  child: Material(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onSwap,
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showSchedule && onScheduleChanged != null) ...[
            const SizedBox(height: 12),
            RideScheduleSection(
              scheduledAt: scheduledAt,
              onChanged: onScheduleChanged!,
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: isBookingLocked ? 'Active ride in progress' : actionLabel,
            onPressed: isBookingLocked ? null : onFindRide,
            variant: isBookingLocked ? AppButtonVariant.outline : AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  _DottedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const gap = 4.0;
    var y = 0.0;
    final x = size.width / 2;

    while (y < size.height) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.dotColor,
    required this.label,
    required this.labelColor,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
  });

  final Color dotColor;
  final String label;
  final Color labelColor;
  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
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
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.w500,
                        color: isPlaceholder
                            ? AppColors.mutedForeground
                            : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
