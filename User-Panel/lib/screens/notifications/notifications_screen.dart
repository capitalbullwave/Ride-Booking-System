import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/widgets/common/app_button.dart';
import 'package:wavego_user/widgets/notifications/ride_accepted_notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _NotificationsError(
          message: e.userMessage,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return _NotificationsEmpty(
              onRefresh: () => ref.invalidate(notificationsProvider),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final n = notifications[index];
                if (n.isRideAccepted) {
                  return RideAcceptedNotificationCard(notification: n);
                }
                return _NotificationTile(
                  notification: n,
                  icon: _iconForType(n.type),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.mutedForeground),
            const SizedBox(height: 16),
            Text(
              'Could not load notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.mutedForeground),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ride updates, payments, and offers will show up here.',
              style: TextStyle(color: AppColors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Refresh', onPressed: onRefresh),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.icon});

  final AppNotification notification;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.read ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: notification.read ? AppColors.border : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!notification.read)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
