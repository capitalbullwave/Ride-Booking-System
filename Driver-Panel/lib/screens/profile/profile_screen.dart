import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(dashboardViewModelProvider).profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    (profile?.name ?? 'D')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(profile?.name ?? 'Driver', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(profile?.phone ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                if (profile?.rating != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppColors.warning, size: 18),
                      Text(' ${profile!.rating} • ${profile.totalTrips} trips'),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _MenuSection(
            items: [
              _MenuItem(Icons.edit, 'Edit Profile', RouteNames.editProfile),
              _MenuItem(Icons.directions_car, 'Vehicle Details', RouteNames.documents),
              _MenuItem(Icons.description, 'Documents', RouteNames.documents),
              _MenuItem(Icons.account_balance, 'Bank Details', RouteNames.wallet),
            ],
          ),
          const SizedBox(height: 16),
          _MenuSection(
            items: [
              _MenuItem(Icons.settings, 'Settings', RouteNames.settings),
              _MenuItem(Icons.help_center, 'Help Center', RouteNames.support),
              _MenuItem(Icons.emergency, 'SOS', RouteNames.sos, color: AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              final confirmed = await AppDialog.showConfirm(
                context: context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmVariant: AppButtonVariant.danger,
              );
              if (confirmed == true) {
                await ref.read(authViewModelProvider.notifier).logout();
                if (context.mounted) context.go(RouteNames.phoneLogin);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: items.map((item) => ListTile(
          leading: Icon(item.icon, color: item.color ?? AppColors.primary),
          title: Text(item.label),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(item.route),
        )).toList(),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.route, {this.color});
  final IconData icon;
  final String label;
  final String route;
  final Color? color;
}
