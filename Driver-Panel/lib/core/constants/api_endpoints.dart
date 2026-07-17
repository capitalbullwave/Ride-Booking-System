class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // Common
  static const String vehicleTypes = '/common/vehicle-types';

  // Profile & driver status
  static const String profile = '/driver/profile';
  static const String updateProfile = '/driver/profile';
  static const String uploadLicense = '/driver/upload-license';
  static const String uploadVehicle = '/driver/upload-vehicle';
  static const String completeRegistration = '/drivers/complete-registration';
  static const String registrationProgress = '/driver/registration-progress';
  static const String registrationData = '/driver/registration-data';
  static const String registrationLicenseUpload = '/driver/registration/license-upload';
  static const String registrationLicenseNumber = '/driver/registration/license-number';
  static const String registrationProfile = '/driver/registration/profile';
  static const String registrationVehicle = '/driver/registration/vehicle';
  static const String registrationVehicleType = '/driver/registration/vehicle-type';
  static const String registrationVehicleDocuments =
      '/driver/registration/vehicle-documents';
  static const String registrationKyc = '/driver/registration/kyc';
  static const String registrationSubmit = '/driver/registration/submit';
  static const String goOnline = '/driver/go-online';
  static const String goOffline = '/driver/go-offline';
  static const String driverLocation = '/driver/location';

  // Documents (mock fallback — no backend route yet)
  static const String documents = '/driver/documents';
  static const String uploadDocument = '/driver/documents/upload';

  // Rides
  static const String rideRequests = '/driver/ride-requests';
  static const String acceptRide = '/driver/accept-ride';
  static const String rejectRide = '/driver/reject-ride';
  static const String arrivedRide = '/driver/arrived-ride';
  static const String startRide = '/driver/start-ride';
  static const String endRide = '/driver/end-ride';
  static const String collectPayment = '/driver/collect-payment';
  static String collectPaymentStatus(String rideId) =>
      '/driver/collect-payment/$rideId/status';
  static String ratePassenger(String rideId) => '/driver/ride/$rideId/rate';
  static String rideMessages(String rideId) => '/driver/ride/$rideId/messages';
  static const String activeRide = '/driver/active-ride';
  static const String rideHistory = '/driver/ride-history';
  static String rideSummary(String rideId) => '/driver/rides/$rideId/summary';

  // Wallet & earnings
  static const String dashboard = '/driver/dashboard';
  static const String wallet = '/driver/wallet';
  static const String referEarn = '/driver/refer-earn';
  static const String referEarnApply = '/driver/refer-earn/apply';
  static const String earnings = '/driver/earnings';

  // Notifications
  static const String driverNotifications = '/driver/notifications';
  static const String deviceToken = '/driver/device-token';

  // Support
  static const String faq = '/common/support/faqs';
  static const String tickets = '/driver/support/tickets';
  static const String createTicket = '/driver/support';

  // SOS
  static const String sos = '/driver/sos';
  static const String driverEmergencyContacts = '/driver/emergency-contacts';

  // Bank
  static const String bankDetails = '/driver/bank';
  static const String withdraw = '/driver/wallet/withdraw';
  static const String walletTransactions = '/driver/wallet/transactions';
  static const String transactions = '/driver/transactions';
}
