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
  static const String activeRide = '/driver/active-ride';
  static const String rideHistory = '/driver/ride-history';

  // Wallet & earnings
  static const String wallet = '/driver/wallet';
  static const String earnings = '/driver/earnings';

  // Notifications (mock fallback — no backend route yet)
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  // Support (mock fallback)
  static const String faq = '/support/faq';
  static const String tickets = '/support/tickets';
  static const String createTicket = '/support/tickets';

  // SOS (mock fallback)
  static const String sos = '/sos/trigger';
  static const String emergencyContacts = '/sos/contacts';

  // Bank (mock fallback)
  static const String bankDetails = '/driver/bank';
  static const String withdraw = '/wallet/withdraw';
  static const String walletTransactions = '/wallet/transactions';
}
