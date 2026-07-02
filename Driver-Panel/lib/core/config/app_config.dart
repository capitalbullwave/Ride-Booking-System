import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'WaveGo Captain';
  static const String appVersion = '1.0.0';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // Android emulator cannot reach host machine via 127.0.0.1
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int otpLength = 6;
  static const int rideRequestTimeoutSeconds = 15;
  static const int otpResendSeconds = 60;
  static const int verificationEstimateHours = 24;

  static const bool enableMockApi = bool.fromEnvironment(
    'ENABLE_MOCK_API',
    defaultValue: false,
  );
}
