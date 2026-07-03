import 'package:wavego_user/models/user_models.dart';

/// Resolves the best display/edit name from profile and dashboard payloads.
class ProfileNameResolver {
  ProfileNameResolver._();

  static bool _isGenericName(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.isEmpty || trimmed == 'user';
  }

  static String fromProfileAndDashboard({
    UserProfile? profile,
    HomeDashboard? dashboard,
  }) {
    if (profile != null && !profile.isPlaceholderName) {
      return profile.name.trim();
    }

    if (dashboard != null) {
      final full = dashboard.fullName.trim();
      if (!_isGenericName(full)) return full;

      final greeting = dashboard.greetingName.trim();
      if (!_isGenericName(greeting)) return greeting;
    }

    if (profile != null) {
      return profile.isPlaceholderName ? '' : profile.name.trim();
    }

    return '';
  }

  static UserProfile merge({
    required UserProfile? profile,
    required HomeDashboard? dashboard,
  }) {
    final resolvedName = fromProfileAndDashboard(
      profile: profile,
      dashboard: dashboard,
    );

    if (profile == null) {
      return UserProfile(
        id: '',
        name: resolvedName,
        phone: '',
      );
    }

    if (resolvedName.isEmpty || resolvedName == profile.name) {
      return profile;
    }

    return UserProfile(
      id: profile.id,
      name: resolvedName,
      phone: profile.phone,
      email: profile.email,
      rating: profile.rating,
      totalRides: profile.totalRides,
      initial: resolvedName.isNotEmpty
          ? resolvedName[0].toUpperCase()
          : profile.initial,
    );
  }
}
