import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Bull Wave Rides Captain';
  static const String appVersion = '1.0.0';

  static const String productionApiBaseUrl =
      'https://ride-application-backend.onrender.com/api/v1';

  /// Host for local dev backend. Override with `--dart-define=HOST_IP=192.168.x.x`
  /// when testing on a physical phone/tablet.
  static String get _localHost {
    if (kIsWeb) return 'localhost';

    const hostIp = String.fromEnvironment('HOST_IP');
    if (hostIp.isNotEmpty) return hostIp;

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator reaches the PC via 10.0.2.2
      return '10.0.2.2';
    }

    return '127.0.0.1';
  }

  static String get localApiBaseUrl => 'http://$_localHost:8000/api/v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    const useLocal = bool.fromEnvironment('USE_LOCAL_API', defaultValue: false);
    if (useLocal) return localApiBaseUrl;

    return productionApiBaseUrl;
  }

  static String get websocketBaseUrl {
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
  static const int otpLength = 6;
  static const int rideRequestTimeoutSeconds = 15;
  static const int otpResendSeconds = 60;
  static const int verificationEstimateHours = 24;

  static const bool enableMockApi = bool.fromEnvironment(
    'ENABLE_MOCK_API',
    defaultValue: false,
  );
}
