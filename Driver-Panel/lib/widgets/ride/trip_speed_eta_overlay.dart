import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

class TripSpeedEtaOverlay extends StatelessWidget {
  const TripSpeedEtaOverlay({
    super.key,
    required this.speedKmh,
    required this.etaMinutes,
    this.vehicleType,
  });

  final double? speedKmh;
  final int? etaMinutes;
  final String? vehicleType;

  bool get _isBike {
    final type = (vehicleType ?? '').toLowerCase();
    return type.contains('bike') ||
        type.contains('scooter') ||
        type.contains('motor');
  }

  @override
  Widget build(BuildContext context) {
    final speedLabel = speedKmh != null && speedKmh! >= 0
        ? speedKmh!.round().toString()
        : '--';
    final etaLabel = etaMinutes != null && etaMinutes! > 0
        ? '$etaMinutes'
        : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _OverlayCard(
          child: Column(
            children: [
              Icon(
                _isBike ? Icons.two_wheeler : Icons.directions_car_filled,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                speedLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  height: 1,
                ),
              ),
              const Text(
                'km/h',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _OverlayCard(
          child: Column(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                etaLabel,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  height: 1,
                ),
              ),
              const Text(
                'min ETA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
