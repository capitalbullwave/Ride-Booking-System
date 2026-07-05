import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Fast Bull';
  static const String appTagline = 'Rides, parcels & ambulance — one app';
  static const String appVersion = '1.0.0';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // Android emulator cannot reach the host machine via 127.0.0.1
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get websocketBaseUrl {
    // Convert http(s)://host:port/api/v1 -> ws(s)://host:port
    final rawBase = baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
    final uri = Uri.parse(rawBase);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(scheme: wsScheme).toString();
  }

  static String rideWebsocketUrl(String token) {
    return '$websocketBaseUrl/ws/ride?token=$token';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  /// Use the real backend by default. Pass `--dart-define=ENABLE_MOCK_API=true`
  /// only when you want to run without a server.
  static const bool enableMockApi = bool.fromEnvironment(
    'ENABLE_MOCK_API',
    defaultValue: false,
  );

  static const int otpLength = 6;
  static const int otpResendSeconds = 30;
  static const String mockOtp = '123456';
}
