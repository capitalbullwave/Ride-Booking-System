class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String me = '/auth/me';

  static const String userProfile = '/user/profile';
  static const String userProfileAddresses = '/user/profile/addresses';

  // User panel (legacy /user/* prefix on backend)
  static const String dashboard = '/user/dashboard';
  static const String wallet = '/user/wallet';
  static const String notifications = '/user/notifications';
  static const String rides = '/user/rides';
  static const String bookRide = '/user/book-ride';
  static const String cancelRide = '/user/cancel-ride';

  // Public / maps (no auth)
  static const String placesSearch = '/public/places/search';
  static const String placesDirections = '/public/places/directions';
  static const String placesReverse = '/public/places/reverse';
  static const String placesDetails = '/public/places/details';
  static const String placesNetworkLocation = '/public/places/network-location';

  static const String vehicleTypes = '/common/vehicle-types';
  static const String rentalCategories = '/common/rental-categories';

  static const String createSupportTicket = '/user/support';
  static const String supportTickets = '/user/support/tickets';
  static const String supportFaqs = '/common/support/faqs';
}
