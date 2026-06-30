import 'package:wavego_user/models/user_models.dart';

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
}
