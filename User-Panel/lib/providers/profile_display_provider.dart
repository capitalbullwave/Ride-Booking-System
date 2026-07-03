import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/utils/profile_name_resolver.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/repositories/user_repositories.dart';

/// UI-facing profile label — same name source as the home greeting.
class ResolvedProfileLabel {
  const ResolvedProfileLabel({
    required this.name,
    required this.phone,
    required this.initial,
    required this.rating,
    required this.totalRides,
  });

  final String name;
  final String phone;
  final String initial;
  final double rating;
  final int totalRides;
}

ResolvedProfileLabel _buildLabel({
  required UserProfile? profile,
  required HomeDashboard? dashboard,
}) {
  final resolved = ProfileNameResolver.fromProfileAndDashboard(
    profile: profile,
    dashboard: dashboard,
  );

  final name = resolved.isNotEmpty
      ? resolved
      : (profile?.phone.trim().isNotEmpty == true ? profile!.phone.trim() : '');

  final label = name.isNotEmpty ? name : 'User';

  return ResolvedProfileLabel(
    name: label,
    phone: profile?.phone ?? '',
    initial: label.isNotEmpty ? label[0].toUpperCase() : 'U',
    rating: profile?.rating ?? 0,
    totalRides: profile?.totalRides ?? 0,
  );
}

/// Keeps profile + dashboard in sync for every screen that shows the user name.
final resolvedProfileLabelProvider = Provider<AsyncValue<ResolvedProfileLabel>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final dashboardAsync = ref.watch(homeDashboardProvider);

  if (profileAsync.isLoading && !profileAsync.hasValue && dashboardAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final profile = profileAsync.valueOrNull;
  final dashboard = dashboardAsync.valueOrNull;

  if (profile == null && dashboard == null) {
    if (profileAsync.hasError && dashboardAsync.hasError) {
      return AsyncValue.error(
        profileAsync.error ?? dashboardAsync.error ?? 'Unable to load profile',
        profileAsync.stackTrace ?? dashboardAsync.stackTrace ?? StackTrace.empty,
      );
    }
    if (profileAsync.isLoading || dashboardAsync.isLoading) {
      return const AsyncValue.loading();
    }
  }

  return AsyncValue.data(_buildLabel(profile: profile, dashboard: dashboard));
});

/// First name for home greeting — identical resolution rules as profile tab.
final homeGreetingNameProvider = Provider<String>((ref) {
  final label = ref.watch(resolvedProfileLabelProvider);
  return label.maybeWhen(
    data: (resolved) {
      final first = resolved.name.split(' ').first;
      return first.isNotEmpty && first.toLowerCase() != 'user' ? first : 'there';
    },
    orElse: () => 'there',
  );
});
