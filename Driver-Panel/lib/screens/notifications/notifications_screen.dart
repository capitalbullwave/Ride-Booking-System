import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/ride_notification_utils.dart';
import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/notifications/ride_request_notification_card.dart';

enum _NotifFilter { all, rides, offers, system }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items =
          await ref.read(notificationRepositoryProvider).getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _loading = false;
      });
      ref.read(notificationUnreadCountProvider.notifier).state =
          items.where((n) => !n.read).length;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<AppNotification> get _filtered {
    return _notifications.where((n) {
      switch (_filter) {
        case _NotifFilter.rides:
          return n.type == 'ride';
        case _NotifFilter.offers:
          return n.type == 'offer' || n.type == 'bonus';
        case _NotifFilter.system:
          return n.type == 'system' || n.type == 'expiry';
        case _NotifFilter.all:
          return true;
      }
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> _markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    await _load();
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.read) return;
    await ref.read(notificationRepositoryProvider).markAsRead(n.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        actions: [
          if (_unreadCount > 0 && !_loading)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          6,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(height: 88, borderRadius: 16),
          ),
        ),
      );
    }

    if (_error != null) {
      return ErrorStateWidget(message: _error!, onRetry: _load);
    }

    if (_notifications.isEmpty) {
      return const EmptyStateWidget(
        title: 'No notifications',
        subtitle: 'Ride alerts, bonuses, and updates will appear here.',
        icon: Icons.notifications_none_outlined,
      );
    }

    final items = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (_unreadCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_email_unread_outlined,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  count: _notifications.length,
                  selected: _filter == _NotifFilter.all,
                  onTap: () => setState(() => _filter = _NotifFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Rides',
                  count: _notifications.where((n) => n.type == 'ride').length,
                  selected: _filter == _NotifFilter.rides,
                  onTap: () => setState(() => _filter = _NotifFilter.rides),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Offers',
                  count: _notifications
                      .where((n) => n.type == 'offer' || n.type == 'bonus')
                      .length,
                  selected: _filter == _NotifFilter.offers,
                  onTap: () => setState(() => _filter = _NotifFilter.offers),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'System',
                  count: _notifications
                      .where((n) => n.type == 'system' || n.type == 'expiry')
                      .length,
                  selected: _filter == _NotifFilter.system,
                  onTap: () => setState(() => _filter = _NotifFilter.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No notifications in this category',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            )
          else
            ...items.map((n) {
              if (isActionableRideRequestNotification(n)) {
                return RideRequestNotificationCard(
                  notification: n,
                  onHandled: () async {
                    await _markRead(n);
                  },
                );
              }
              if (isRideRequestNotification(n)) {
                return const SizedBox.shrink();
              }
              return _NotificationCard(
                notification: n,
                onTap: () => _markRead(n),
              );
            }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.type) {
        'ride' => Icons.local_taxi_rounded,
        'bonus' => Icons.card_giftcard_rounded,
        'offer' => Icons.local_offer_rounded,
        'expiry' => Icons.warning_amber_rounded,
        _ => Icons.notifications_rounded,
      };

  Color get _color => switch (notification.type) {
        'ride' => AppColors.primary,
        'bonus' => AppColors.success,
        'offer' => AppColors.secondaryDark,
        'expiry' => AppColors.warning,
        _ => AppColors.info,
      };

  String _timeAgo(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormatter.date(dt);
    } catch (_) {
      return raw.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final unread = !n.read;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: unread
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: unread
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.foreground.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_icon, color: _color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight:
                                        unread ? FontWeight.w800 : FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _timeAgo(n.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
