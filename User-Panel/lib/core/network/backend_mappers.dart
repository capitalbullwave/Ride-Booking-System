import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/core/utils/date_formatter.dart';
import 'package:wavego_user/models/saved_place.dart';

class BackendMappers {
  BackendMappers._();

  static OtpResponse otpFromMessage(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'OTP sent',
    );
  }

  static String? devOtpHintFromMessage(Map<String, dynamic> json) {
    return json['otp'] as String?;
  }

  static LoginResponse loginFromToken(Map<String, dynamic> json) {
    return LoginResponse(
      success: true,
      isRegistered: true,
      isVerified: true,
      tokens: AuthTokens.fromJson(json),
    );
  }

  static UserProfile userProfile(Map<String, dynamic> json) {
    return profileFromApi(json);
  }

  static UserProfile profileFromApi(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String?;
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final explicitName = json['name'] as String?;
    final combined = fullName?.trim().isNotEmpty == true
        ? fullName!.trim()
        : explicitName?.trim().isNotEmpty == true
            ? explicitName!.trim()
            : '$firstName $lastName'.trim();
    final name = combined.isEmpty ? 'User' : combined;
    final rating = (json['rating_avg'] as num?)?.toDouble() ??
        (json['rating'] as num?)?.toDouble() ??
        0;

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: name,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      rating: rating,
      totalRides: (json['total_rides'] as num?)?.toInt() ?? 0,
      initial: name.isNotEmpty ? name[0].toUpperCase() : 'U',
    );
  }

  static SavedPlace savedPlaceFromApi(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id']?.toString() ?? '',
      title: json['label'] as String? ?? 'Saved place',
      address: json['address_line'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isFavorite: json['is_default'] as bool? ?? false,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  static LoginResponse loginWithProfile(
    Map<String, dynamic> tokenJson,
    Map<String, dynamic> profileJson,
  ) {
    return LoginResponse(
      success: true,
      isRegistered: true,
      isVerified: profileJson['is_verified'] as bool? ?? true,
      tokens: AuthTokens.fromJson(tokenJson),
      user: userProfile(profileJson),
    );
  }

  static AppNotification notificationFromBackend(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ??
        json['notification_type'] as String? ??
        'system';

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: _notificationType(rawType),
      title: json['title'] as String? ?? '',
      message: json['body'] as String? ?? json['message'] as String? ?? '',
      time: _relativeTime(json['created_at'] as String?),
      read: _parseBool(json['is_read'] ?? json['read']),
    );
  }

  static Map<String, List<ActivityItem>> ridesListFromBackend(
    Map<String, dynamic> json,
  ) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => rideToActivity(e as Map<String, dynamic>))
        .toList();

    return {
      'Rides': items,
      'Deliveries': <ActivityItem>[],
      'Emergency': <ActivityItem>[],
    };
  }

  static ActivityItem rideToActivity(Map<String, dynamic> json) {
    final fare = json['fare'] as num? ??
        json['fare_final'] as num? ??
        json['fare_estimate'] as num?;
    return ActivityItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['pickup_address'] as String? ?? 'Ride',
      address: json['dropoff_address'] as String? ?? '',
      date: _relativeTime(json['created_at'] as String?),
      price: fare != null ? '₹${fare.toStringAsFixed(0)}' : '',
      status: json['status'] as String? ?? '',
    );
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return defaultValue;
  }

  static String _notificationType(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('ride')) return 'ride';
    if (value.contains('payment') || value.contains('wallet')) return 'payment';
    if (value.contains('promo')) return 'promo';
    if (value.contains('ambulance')) return 'ambulance';
    return 'system';
  }

  static String _relativeTime(String? iso) {
    if (iso == null || iso.isEmpty) return 'Recently';

    try {
      final date = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) {
        final hours = diff.inHours;
        return hours == 1 ? '1 hour ago' : '$hours hours ago';
      }
      if (diff.inDays < 7) {
        final days = diff.inDays;
        return days == 1 ? 'Yesterday' : '$days days ago';
      }
      return DateFormatter.date(date);
    } catch (_) {
      return 'Recently';
    }
  }
}
