class AppConfig {
  AppConfig._();

  static const String appName = 'WaveGo';
  static const String appTagline = 'Rides, parcels & ambulance — one app';
  static const String appVersion = '1.0.0';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const bool enableMockApi = bool.fromEnvironment(
    'ENABLE_MOCK_API',
    defaultValue: false,
  );

  static const int otpLength = 6;
  static const int otpResendSeconds = 30;
  static const String mockOtp = '123456';
}
