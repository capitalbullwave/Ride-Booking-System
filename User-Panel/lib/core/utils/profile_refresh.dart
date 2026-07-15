import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/repositories/user_repositories.dart';

/// Refreshes vehicle categories shown on home and booking screens.
void refreshVehicleCatalog(WidgetRef ref) {
  ref.invalidate(vehicleCategoriesProvider);
  ref.invalidate(rentalCategoriesProvider);
}

/// Refreshes user profile and any screens that display profile-derived data.
void refreshUserProfile(WidgetRef ref) {
  ref.invalidate(userProfileProvider);
  ref.invalidate(homeDashboardProvider);
  refreshVehicleCatalog(ref);
}
