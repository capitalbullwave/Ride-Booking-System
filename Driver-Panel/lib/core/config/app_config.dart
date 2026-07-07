class AppConfig {
  AppConfig._();

  static const String appName = 'Fast Bull Captain';
  static const String appVersion = '1.0.0';

  static const String productionApiBaseUrl =
      'http://127.0.0.1:8000/api/v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

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
