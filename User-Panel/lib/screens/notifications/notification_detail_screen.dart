import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.notification});

  final AppNotification notification;

  IconData _iconForType(String type) {
    switch (type) {
      case 'ride':
        return Icons.directions_car;
      case 'payment':
        return Icons.payment;
      case 'promo':
        return Icons.local_offer;
      case 'ambulance':
        return Icons.medical_services;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(_iconForType(notification.type), size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    notification.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.5, color: AppColors.foreground),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (notification.type == 'ride')
              AppButton(
                label: 'Track ride',
                onPressed: () => context.showSnackBar('Opening ride tracking...'),
              ),
            if (notification.type == 'promo') ...[
              AppButton(
                label: 'Apply offer',
                onPressed: () => context.showSnackBar('Promo code applied'),
              ),
            ],
            if (notification.type == 'payment')
              AppButton(
                label: 'View payment',
                variant: AppButtonVariant.outline,
                onPressed: () => context.showSnackBar('Opening payment details...'),
              ),
          ],
        ),
      ),
    );
  }
}
