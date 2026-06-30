class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.rating = 0,
    this.initial = '?',
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final double rating;
  final String initial;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'User';
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: name,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      initial: json['initial'] as String? ??
          (name.isNotEmpty ? name[0].toUpperCase() : '?'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'rating': rating,
        'initial': initial,
      };
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
      );
}

class OtpResponse {
  const OtpResponse({
    required this.success,
    required this.message,
    this.sessionId,
  });

  final bool success;
  final String message;
  final String? sessionId;

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        sessionId: json['session_id'] as String?,
      );
}

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.isRegistered,
    required this.isVerified,
    required this.tokens,
    this.user,
  });

  final bool success;
  final bool isRegistered;
  final bool isVerified;
  final AuthTokens tokens;
  final UserProfile? user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'] as bool? ?? false,
        isRegistered: json['is_registered'] as bool? ?? true,
        isVerified: json['is_verified'] as bool? ?? true,
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
        user: json['user'] != null
            ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class HomeBanner {
  const HomeBanner({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  factory HomeBanner.fromJson(Map<String, dynamic> json) => HomeBanner(
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
      );
}

class HomeDashboard {
  const HomeDashboard({
    required this.greetingName,
    required this.nearbyDriversCount,
    required this.banners,
  });

  final String greetingName;
  final int nearbyDriversCount;
  final List<HomeBanner> banners;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) => HomeDashboard(
        greetingName: json['greeting_name'] as String? ?? 'there',
        nearbyDriversCount: json['nearby_drivers_count'] as int? ?? 0,
        banners: (json['banners'] as List<dynamic>? ?? [])
            .map((e) => HomeBanner.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.bonusBalance,
    required this.total,
    required this.paymentMethods,
  });

  final double balance;
  final double bonusBalance;
  final double total;
  final List<PaymentMethod> paymentMethods;

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        bonusBalance: (json['bonus_balance'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        paymentMethods: (json['payment_methods'] as List<dynamic>? ?? [])
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
  });

  final String id;
  final String type;
  final String label;
  final String? lastFour;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        label: json['label'] as String? ?? '',
        lastFour: json['last_four'] as String?,
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        time: json['time'] as String? ?? '',
        read: json['read'] as bool? ?? true,
      );
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.address,
    required this.date,
    required this.price,
    required this.status,
  });

  final int id;
  final String title;
  final String address;
  final String date;
  final String price;
  final String status;

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        address: json['address'] as String? ?? '',
        date: json['date'] as String? ?? '',
        price: json['price'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
}
