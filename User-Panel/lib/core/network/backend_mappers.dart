import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/core/utils/date_formatter.dart';

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
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final name = '$firstName $lastName'.trim();
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: name.isEmpty ? 'User' : name,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      rating: (json['rating_avg'] as num?)?.toDouble() ?? 0,
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
      read: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
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
