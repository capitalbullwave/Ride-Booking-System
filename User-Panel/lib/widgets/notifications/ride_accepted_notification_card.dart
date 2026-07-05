import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/user_models.dart';

class RideAcceptedNotificationCard extends StatelessWidget {
  const RideAcceptedNotificationCard({
    super.key,
    required this.notification,
  });

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final data = notification.data ?? {};
    final driverName = data['driver_name'] as String? ?? 'Driver';
    final vehicle = data['vehicle_number'] as String? ?? '—';
    final phone = data['driver_phone'] as String? ?? '';
    final startCode = data['start_code'] as String? ?? '----';
    final pickup = data['pickup_address'] as String? ?? '';
    final dropoff = data['dropoff_address'] as String? ?? '';
    final fare = (data['estimated_fare'] as num?)?.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                child: const Icon(Icons.check_circle, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      driverName,
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pickup.isNotEmpty) _RowLabel(icon: Icons.trip_origin, label: 'Pickup', value: pickup),
          if (dropoff.isNotEmpty) ...[
            const SizedBox(height: 8),
            _RowLabel(icon: Icons.location_on, label: 'Drop', value: dropoff),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(label: 'Vehicle: $vehicle'),
              if (fare != null) _Chip(label: '₹${fare.toStringAsFixed(0)}'),
              if (phone.isNotEmpty)
                InkWell(
                  onTap: () => launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', ''))),
                  child: _Chip(label: phone, icon: Icons.phone),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Text(
                  'Your ride start code',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  startCode,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share only when driver arrives',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notification.time,
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

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
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
