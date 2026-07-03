import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final notifications = ref.watch(notificationsEnabledProvider);
    final autoAccept = ref.watch(autoAcceptProvider);
    final navApp = ref.watch(navigationAppProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionLabel(title: 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: isDark,
            onChanged: (v) async {
              ref.read(themeModeProvider.notifier).state = v;
              final prefs = ref.read(sharedPreferencesProvider);
              await prefs.setBool(AppConstants.themeModeKey, v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickLanguage(context, ref, language),
          ),
          const Divider(height: 1),
          _SectionLabel(title: 'Ride Preferences'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Ride requests and updates'),
            value: notifications,
            onChanged: (v) async {
              ref.read(notificationsEnabledProvider.notifier).state = v;
              await ref
                  .read(sharedPreferencesProvider)
                  .setBool(AppConstants.notificationsEnabledKey, v);
            },
          ),
          SwitchListTile(
            title: const Text('Auto Accept Rides'),
            subtitle: const Text('Automatically accept nearby requests'),
            value: autoAccept,
            onChanged: (v) async {
              ref.read(autoAcceptProvider.notifier).state = v;
              await ref
                  .read(sharedPreferencesProvider)
                  .setBool(AppConstants.autoAcceptKey, v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.navigation_outlined),
            title: const Text('Navigation App'),
            subtitle: Text(navApp),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickNavigationApp(context, ref, navApp),
          ),
          const Divider(height: 1),
          _SectionLabel(title: 'Permissions'),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Location Permission'),
            subtitle: const Text('Required for ride matching'),
            trailing: TextButton(
              onPressed: () => ref.read(permissionServiceProvider).requestLocation(),
              child: const Text('Manage'),
            ),
          ),
          const Divider(height: 1),
          _SectionLabel(title: 'Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About WaveGo Captain'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {},
          ),
          const Divider(height: 1),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String current) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.languages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: lang == current ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () => Navigator.pop(ctx, lang),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      ref.read(languageProvider.notifier).state = selected;
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(AppConstants.languageKey, selected);
    }
  }

  Future<void> _pickNavigationApp(BuildContext context, WidgetRef ref, String current) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.navigationApps
              .map(
                (app) => ListTile(
                  title: Text(app),
                  trailing: app == current ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () => Navigator.pop(ctx, app),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      ref.read(navigationAppProvider.notifier).state = selected;
      await ref
          .read(sharedPreferencesProvider)
          .setString(AppConstants.navigationAppKey, selected);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
