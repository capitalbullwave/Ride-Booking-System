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
  static const String studentPass = '/user/student-pass';
  static const String subscriptionPlans = '/user/subscription-plans';
  static const String userSubscription = '/user/subscription';
  static const String subscriptionCheckout = '/user/subscription/checkout';
  static const String subscriptionVerifyPayment = '/user/subscription/verify-payment';
  static const String walletCheckout = '/user/wallet/checkout';
  static const String walletVerifyPayment = '/user/wallet/verify-payment';
  static const String referEarn = '/user/refer-earn';
  static const String referEarnApply = '/user/refer-earn/apply';

  // User panel (legacy /user/* prefix on backend)
  static const String dashboard = '/user/dashboard';
  static const String wallet = '/user/wallet';
  static const String walletTransactions = '/user/transactions';
  static const String walletBank = '/user/wallet/bank';
  static const String walletWithdraw = '/user/wallet/withdraw';
  static const String notifications = '/user/notifications';
  static const String deviceToken = '/user/device-token';
  static const String rides = '/user/rides';
  static const String bookRide = '/user/book-ride';
  static const String rideEstimate = '/rides/estimate';
  static const String cancelRide = '/user/cancel-ride';
  static const String continueWithAllRiders = '/user/continue-with-all-riders';
  static const String userCoupons = '/user/coupons';
  static const String validateCoupon = '/user/coupons/validate';
  static String rateRide(String rideId) => '/user/ride/$rideId/rate';
  static String rideMessages(String rideId) => '/user/ride/$rideId/messages';
  static String rideSos(String rideId) => '/user/ride/$rideId/sos';

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

  // Corporate
  static const String corporateMembership = '/corporate/membership';
}
