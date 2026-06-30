import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await ref.read(notificationRepositoryProvider).getNotifications();
    setState(() { _notifications = items; _loading = false; });
  }

  IconData _iconForType(String type) => switch (type) {
    'ride' => Icons.local_taxi,
    'bonus' => Icons.card_giftcard,
    'offer' => Icons.local_offer,
    'expiry' => Icons.warning_amber,
    _ => Icons.notifications,
  };

  Color _colorForType(String type) => switch (type) {
    'ride' => AppColors.primary,
    'bonus' => AppColors.accent,
    'offer' => AppColors.secondary,
    'expiry' => AppColors.warning,
    _ => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const EmptyStateWidget(title: 'No notifications', subtitle: 'You\'re all caught up!')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: n.read ? null : AppColors.primary.withValues(alpha: 0.04),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _colorForType(n.type).withValues(alpha: 0.12),
                            child: Icon(_iconForType(n.type), color: _colorForType(n.type), size: 20),
                          ),
                          title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(n.body),
                          trailing: n.read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          onTap: () => ref.read(notificationRepositoryProvider).markAsRead(n.id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
