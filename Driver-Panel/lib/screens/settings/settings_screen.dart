import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: isDark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English'),
            trailing: Icon(Icons.chevron_right),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Push notifications'),
            value: true,
            onChanged: (_) {},
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
          ),
          SwitchListTile(
            title: const Text('Location Services'),
            subtitle: const Text('Required for ride matching'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              final confirmed = await AppDialog.showConfirm(
                context: context,
                title: 'Delete Account',
                message: 'This action is permanent. All your data will be deleted.',
                confirmLabel: 'Delete',
                confirmVariant: AppButtonVariant.danger,
              );
              if (confirmed == true && context.mounted) {
                AppDialog.showSuccess(
                  context: context,
                  title: 'Request Submitted',
                  message: 'Your account deletion request has been submitted.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
