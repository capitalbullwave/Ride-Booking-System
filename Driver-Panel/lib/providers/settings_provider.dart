import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';

/// Loads persisted preferences into Riverpod state on app start.
void hydrateAppPreferences(WidgetRef ref) {
  final prefs = ref.read(sharedPreferencesProvider);

  ref.read(themeModeProvider.notifier).state =
      prefs.getBool(AppConstants.themeModeKey) ?? false;
  ref.read(languageProvider.notifier).state =
      prefs.getString(AppConstants.languageKey) ?? 'English';
  ref.read(notificationsEnabledProvider.notifier).state =
      prefs.getBool(AppConstants.notificationsEnabledKey) ?? true;
  ref.read(autoAcceptProvider.notifier).state =
      prefs.getBool(AppConstants.autoAcceptKey) ?? false;
  ref.read(navigationAppProvider.notifier).state =
      prefs.getString(AppConstants.navigationAppKey) ?? 'Google Maps';
}

final themeModeProvider = StateProvider<bool>((ref) => false);

final languageProvider = StateProvider<String>((ref) => 'English');

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

final autoAcceptProvider = StateProvider<bool>((ref) => false);

final navigationAppProvider =
    StateProvider<String>((ref) => 'Google Maps');

final notificationUnreadCountProvider = StateProvider<int>((ref) => 0);
