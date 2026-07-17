import 'package:wavego_driver/core/utils/media_url_resolver.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/models/trip_model.dart';
import 'package:wavego_driver/models/wallet_model.dart';

class BackendMappers {
  BackendMappers._();

  static LoginResponse loginFromToken(
    Map<String, dynamic> json, {
    DriverProfile? driver,
  }) {
    return LoginResponse(
      tokens: AuthTokens.fromJson(json),
      driver: driver,
      isRegistered: driver != null &&
          (driver.verificationStatus != 'pending' ||
              (driver.vehicle?.id?.isNotEmpty ?? false)),
      isVerified: driver?.verificationStatus == 'approved' ||
          driver?.verificationStatus == 'verified',
    );
  }

  static OtpResponse otpFromMessage(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      sessionId: null,
    );
  }

  static String? devOtpHintFromMessage(Map<String, dynamic> json) {
    return json['otp'] as String?;
  }

  /// Auto-generated `phone@driver.ridebook.app` / `phone@ridebook.app` — treat as empty.
  static String? displayEmail(String? email, String? phone) {
    final value = (email ?? '').trim();
    if (value.isEmpty) return null;
    final lower = value.toLowerCase();
    if (!lower.endsWith('@ridebook.app')) return value;
    final local = lower.split('@').first;
    final phoneDigits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    final localDigits = local.replaceAll(RegExp(r'\D'), '');
    if (localDigits.isNotEmpty &&
        phoneDigits.isNotEmpty &&
        phoneDigits.contains(localDigits)) {
      return null;
    }
    return value;
  }

  static DriverProfile driverProfile(Map<String, dynamic> json) {
    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final status = (json['status'] as String? ?? 'OFFLINE').toUpperCase();
    final kyc = (json['kyc_status'] as String? ?? 'PENDING').toLowerCase();
    final phone = json['phone'] as String? ?? '';

    return DriverProfile(
      id: json['id']?.toString() ?? '',
      name: '$firstName $lastName'.trim().isEmpty ? 'Driver' : '$firstName $lastName'.trim(),
      phone: phone,
      email: displayEmail(json['email'] as String?, phone),
      avatar: resolveMediaUrl(json['profile_photo'] as String?),
      rating: (json['rating_avg'] as num?)?.toDouble(),
      totalTrips: (json['total_rides'] as num?)?.toInt() ?? 0,
      isOnline: status == 'ONLINE',
      // Phone OTP verified (`is_verified`) is not the same as KYC/document approval.
      verificationStatus: _mapKycStatus(kyc),
    );
  }

  static String _mapKycStatus(String kyc) {
    switch (kyc.toUpperCase()) {
      case 'APPROVED':
        return 'approved';
      case 'REJECTED':
        return 'rejected';
      case 'UNDER_REVIEW':
      case 'SUBMITTED':
        return 'pending';
      default:
        return 'pending';
    }
  }

  static bool isDriverRegistered(DriverProfile profile) {
    return profile.verificationStatus != 'pending' || profile.totalTrips > 0;
  }

  static bool isDriverVerified(DriverProfile profile) {
    return profile.verificationStatus == 'approved' ||
        profile.verificationStatus == 'verified';
  }

  /// True when admin has approved documents (not just phone OTP verified).
  static bool isDriverKycApproved(Map<String, dynamic> profileJson) =>
      _isKycApproved(profileJson);

  static LoginResponse loginWithProfile(
    Map<String, dynamic> tokenJson,
    Map<String, dynamic> profileJson,
  ) {
    final driver = driverProfile(profileJson);
    return LoginResponse(
      tokens: AuthTokens.fromJson(tokenJson),
      driver: driver,
      isRegistered: _hasCompletedRegistration(profileJson),
      isVerified: _isKycApproved(profileJson),
    );
  }

  static bool _isKycApproved(Map<String, dynamic> profileJson) {
    final kyc = (profileJson['kyc_status'] as String? ?? 'PENDING').toUpperCase();
    return kyc == 'APPROVED' || kyc == 'VERIFIED';
  }

  static bool _hasCompletedRegistration(Map<String, dynamic> profileJson) {
    if (_isKycApproved(profileJson)) return true;

    final kyc = (profileJson['kyc_status'] as String? ?? 'PENDING').toUpperCase();
    if (kyc == 'SUBMITTED' || kyc == 'UNDER_REVIEW') return true;

    final totalRides = (profileJson['total_rides'] as num?)?.toInt() ?? 0;
    if (totalRides > 0) return true;

    final license = profileJson['license_number'] as String?;
    return license != null &&
        license.isNotEmpty &&
        license.toUpperCase() != 'PENDING';
  }

  static String rideStatusToApp(String backendStatus) {
    switch (backendStatus.toUpperCase()) {
      case 'DRIVER_ASSIGNED':
        return 'heading_to_pickup';
      case 'DRIVER_ARRIVED':
        return 'arrived';
      case 'OTP_VERIFIED':
      case 'STARTED':
      case 'IN_PROGRESS':
        return 'started';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return 'heading_to_pickup';
    }
  }

  static RideRequest? rideRequestFromList(dynamic data) {
    if (data is! List || data.isEmpty) return null;
    return rideRequestFromJson(data.first as Map<String, dynamic>);
  }

  static List<RideStop> _stopsFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final stops = <RideStop>[];
    for (final item in raw) {
      Map<String, dynamic>? map;
      if (item is Map<String, dynamic>) {
        map = item;
      } else if (item is Map) {
        map = Map<String, dynamic>.from(item);
      }
      if (map == null) continue;
      final stop = RideStop.fromJson(map);
      if (stop.address.trim().isEmpty) continue;
      stops.add(stop);
      if (stops.length >= 3) break;
    }
    return stops;
  }

  static RideRequest rideRequestFromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id']?.toString() ?? json['ride_id']?.toString() ?? '',
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationAddress: json['dropoff_address'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0,
      destinationLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0,
      destinationLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0,
      distance: (json['estimated_distance_km'] as num?)?.toDouble() ?? 0,
      estimatedTime:
          ((json['estimated_duration_min'] as num?)?.toDouble() ?? 0).round(),
      estimatedFare: (json['estimated_fare'] as num?)?.toDouble() ?? 0,
      paymentMode: json['payment_method'] as String? ?? 'CASH',
      passengerName: json['passenger_name'] as String? ?? 'Passenger',
      passengerPhone: json['passenger_phone'] as String?,
      expiresIn: 15,
      stops: _stopsFromJson(json['stops']),
    );
  }

  static ActiveRide activeRideFromJson(Map<String, dynamic> json) {
    return ActiveRide(
      id: json['id']?.toString() ?? '',
      status: rideStatusToApp(json['status'] as String? ?? ''),
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationAddress: json['dropoff_address'] as String? ?? '',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 0,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 0,
      destinationLat: (json['dropoff_lat'] as num?)?.toDouble() ?? 0,
      destinationLng: (json['dropoff_lng'] as num?)?.toDouble() ?? 0,
      passengerName: json['passenger_name'] as String? ?? 'Passenger',
      passengerPhone: json['passenger_phone'] as String?,
      paymentMode: json['payment_method'] as String? ?? 'CASH',
      estimatedFare:
          (json['final_fare'] as num?)?.toDouble() ??
          (json['estimated_fare'] as num?)?.toDouble() ??
          0,
      distance: (json['estimated_distance_km'] as num?)?.toDouble(),
      startedAt: json['started_at']?.toString(),
      stops: _stopsFromJson(json['stops']),
    );
  }

  static PaymentBreakdown paymentFromRide(Map<String, dynamic> json) {
    final fare = (json['trip_fare'] as num?)?.toDouble() ??
        (json['final_fare'] as num?)?.toDouble() ??
        (json['estimated_fare'] as num?)?.toDouble() ??
        0;
    var commission = (json['commission'] as num?)?.toDouble() ??
        (json['company_earning'] as num?)?.toDouble() ??
        0;
    var totalEarnings = (json['total_earnings'] as num?)?.toDouble() ??
        (json['driver_earning'] as num?)?.toDouble() ??
        0;

    // Coherent fallback: earnings + commission must add up to fare.
    if (fare > 0 && totalEarnings <= 0 && commission <= 0) {
      final pct = (json['commission_percentage'] as num?)?.toDouble();
      if (pct != null && pct > 0) {
        totalEarnings = double.parse((fare * pct / 100).toStringAsFixed(2));
        commission = double.parse((fare - totalEarnings).toStringAsFixed(2));
      } else {
        // Default driver share 80% when backend did not send a split.
        totalEarnings = double.parse((fare * 0.8).toStringAsFixed(2));
        commission = double.parse((fare - totalEarnings).toStringAsFixed(2));
      }
    } else if (fare > 0 && totalEarnings <= 0 && commission > 0) {
      totalEarnings = double.parse((fare - commission).toStringAsFixed(2));
      if (totalEarnings < 0) totalEarnings = 0;
    } else if (fare > 0 && commission <= 0 && totalEarnings > 0) {
      commission = double.parse((fare - totalEarnings).toStringAsFixed(2));
      if (commission < 0) commission = 0;
    }

    return PaymentBreakdown(
      tripFare: fare,
      commission: commission,
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0,
      totalEarnings: totalEarnings,
      paymentMode: json['payment_mode'] as String? ??
          json['payment_method'] as String? ??
          'CASH',
    );
  }

  static Map<String, dynamic> collectPaymentFromJson(Map<String, dynamic> json) {
    return json;
  }

  static RideSummary rideSummaryFromJson(Map<String, dynamic> json) {
    final fare = (json['trip_fare'] as num?)?.toDouble() ??
        (json['final_fare'] as num?)?.toDouble() ??
        (json['estimated_fare'] as num?)?.toDouble() ??
        0;

    var commission = (json['commission'] as num?)?.toDouble() ??
        (json['company_earning'] as num?)?.toDouble() ??
        0;
    var netEarnings = (json['total_earnings'] as num?)?.toDouble() ??
        (json['driver_earning'] as num?)?.toDouble() ??
        (json['net_earnings'] as num?)?.toDouble() ??
        0;

    // Same coherent fallback as payment screen.
    if (fare > 0 && netEarnings <= 0 && commission <= 0) {
      final pct = (json['commission_percentage'] as num?)?.toDouble() ??
          (json['driver_commission_percentage'] as num?)?.toDouble();
      if (pct != null && pct > 0) {
        netEarnings = double.parse((fare * pct / 100).toStringAsFixed(2));
        commission = double.parse((fare - netEarnings).toStringAsFixed(2));
      } else {
        netEarnings = double.parse((fare * 0.8).toStringAsFixed(2));
        commission = double.parse((fare - netEarnings).toStringAsFixed(2));
      }
    } else if (fare > 0 && netEarnings <= 0 && commission > 0) {
      netEarnings = double.parse((fare - commission).toStringAsFixed(2));
      if (netEarnings < 0) netEarnings = 0;
    } else if (fare > 0 && commission <= 0 && netEarnings > 0) {
      commission = double.parse((fare - netEarnings).toStringAsFixed(2));
      if (commission < 0) commission = 0;
    }

    final distance = (json['actual_distance_km'] as num?)?.toDouble() ??
        (json['estimated_distance_km'] as num?)?.toDouble() ??
        (json['distance'] as num?)?.toDouble() ??
        0;
    final duration = ((json['actual_duration_min'] as num?)?.toDouble() ??
            (json['estimated_duration_min'] as num?)?.toDouble() ??
            (json['duration'] as num?)?.toDouble() ??
            0)
        .round();

    final stops = _stopsFromJson(json['stops']);

    return RideSummary(
      id: json['id']?.toString() ?? '',
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationAddress: json['dropoff_address'] as String? ??
          json['destination_address'] as String? ??
          '',
      distance: distance,
      duration: duration,
      fare: fare,
      commission: commission,
      netEarnings: netEarnings,
      paymentMode: json['payment_mode'] as String? ??
          json['payment_method'] as String? ??
          'CASH',
      completedAt: json['completed_at']?.toString(),
      stops: stops,
    );
  }

  static Trip tripFromRideJson(Map<String, dynamic> json) {
    final fare = (json['final_fare'] as num?)?.toDouble() ??
        (json['estimated_fare'] as num?)?.toDouble() ??
        0;
    final driverEarning = (json['driver_earning'] as num?)?.toDouble() ?? 0;
    return Trip(
      id: json['id']?.toString() ?? '',
      status: (json['status'] as String? ?? '').toLowerCase(),
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationAddress: json['dropoff_address'] as String? ?? '',
      distance: (json['estimated_distance_km'] as num?)?.toDouble() ?? 0,
      duration:
          ((json['estimated_duration_min'] as num?)?.toDouble() ?? 0).round(),
      fare: fare,
      netEarnings: driverEarning,
      paymentMode: json['payment_method'] as String? ?? 'CASH',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static TripDetail tripDetailFromRideJson(Map<String, dynamic> json) {
    final fare = (json['final_fare'] as num?)?.toDouble() ??
        (json['estimated_fare'] as num?)?.toDouble() ??
        0;
    final driverEarning = (json['driver_earning'] as num?)?.toDouble() ?? 0;
    final companyEarning = (json['company_earning'] as num?)?.toDouble() ?? 0;
    return TripDetail(
      id: json['id']?.toString() ?? '',
      status: (json['status'] as String? ?? '').toLowerCase(),
      pickupAddress: json['pickup_address'] as String? ?? '',
      destinationAddress: json['dropoff_address'] as String? ?? '',
      distance: (json['estimated_distance_km'] as num?)?.toDouble() ?? 0,
      duration:
          ((json['estimated_duration_min'] as num?)?.toDouble() ?? 0).round(),
      fare: fare,
      commission: companyEarning > 0 ? companyEarning : fare - driverEarning,
      netEarnings: driverEarning,
      paymentMode: json['payment_method'] as String? ?? 'CASH',
      createdAt: json['created_at']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
    );
  }

  static EarningsSummary earningsFromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayEarnings: (json['net_earnings'] as num?)?.toDouble() ??
          (json['total_earnings'] as num?)?.toDouble() ??
          0,
      weeklyEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      monthlyEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      totalTrips: (json['total_rides'] as num?)?.toInt() ?? 0,
      todayTrips: (json['total_rides'] as num?)?.toInt() ?? 0,
    );
  }

  static List<EarningsRideItem> earningsRidesFromJson(Map<String, dynamic> json) {
    final rides = json['rides'] as List<dynamic>? ?? [];
    return rides.map((raw) {
      final item = raw as Map<String, dynamic>;
      return EarningsRideItem(
        rideId: item['ride_id']?.toString() ?? '',
        rideFare: (item['ride_fare'] as num?)?.toDouble() ?? 0,
        driverCommissionPercentage:
            (item['driver_commission_percentage'] as num?)?.toDouble() ?? 0,
        driverEarning: (item['driver_earning'] as num?)?.toDouble() ?? 0,
        rideDate: item['ride_date']?.toString(),
        status: item['status'] as String? ?? 'COMPLETED',
      );
    }).toList();
  }

  static WalletInfo walletFromJson(Map<String, dynamic> json) {
    final available = (json['available_balance'] as num?)?.toDouble() ??
        (json['balance'] as num?)?.toDouble() ??
        0;
    return WalletInfo(
      currentBalance: available,
      pendingBalance: (json['pending_balance'] as num?)?.toDouble() ?? 0,
      totalEarnings: (json['lifetime_earnings'] as num?)?.toDouble() ?? 0,
      bank: json['bank'] != null
          ? bankFromJson(json['bank'] as Map<String, dynamic>)
          : null,
    );
  }

  static BankInfo bankFromJson(Map<String, dynamic> json) {
    return BankInfo(
      accountHolder: json['account_holder'] as String?,
      accountNumber: json['account_number'] as String?,
      ifsc: json['ifsc'] as String?,
      bankName: json['bank_name'] as String?,
      upiId: json['upi_id'] as String?,
    );
  }

  static DashboardStats dashboardStats({
    required DriverProfile profile,
    double walletBalance = 0,
    double todayEarnings = 0,
  }) {
    return DashboardStats(
      todayEarnings: todayEarnings,
      walletBalance: walletBalance,
      completedTrips: profile.totalTrips,
      todayTrips: 0,
      rating: profile.rating ?? 0,
    );
  }
}
