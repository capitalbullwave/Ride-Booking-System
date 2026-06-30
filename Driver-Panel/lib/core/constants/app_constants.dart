class AppConstants {
  AppConstants._();

  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String driverProfileKey = 'driver_profile';
  static const String driverStatusKey = 'driver_status';
  static const String isOnlineKey = 'is_online';
  static const String vehicleIdKey = 'vehicle_id';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';

  static const List<String> vehicleTypes = [
    'Bike',
    'Auto',
    'Mini Cab',
    'Sedan',
    'SUV',
  ];

  static const List<String> genders = ['Male', 'Female', 'Other'];

  static const List<String> documentTypes = [
    'Driving License',
    'RC',
    'Insurance',
    'Pollution Certificate',
    'Permit',
    'Fitness Certificate',
    'PAN',
    'Aadhaar',
  ];

  static const List<String> paymentModes = [
    'Cash',
    'Online',
    'Wallet',
    'UPI',
  ];

  static const List<String> tripStatuses = [
    'Completed',
    'Cancelled',
    'Ongoing',
  ];
}
