class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.rating = 0,
    this.totalRides = 0,
    this.initial = '?',
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final double rating;
  final int totalRides;
  final String initial;

  bool get isFemale => (gender ?? '').trim().toLowerCase() == 'female';

  /// True when the backend only has the OTP signup placeholder name.
  bool get isPlaceholderName {
    final trimmed = name.trim().toLowerCase();
    return trimmed.isEmpty || trimmed == 'user';
  }

  /// Best label for UI — prefers a real name, then phone, then fallback.
  String get displayName {
    if (!isPlaceholderName) return name.trim();
    final phoneTrimmed = phone.trim();
    if (phoneTrimmed.isNotEmpty) return phoneTrimmed;
    return name.trim().isNotEmpty ? name.trim() : 'User';
  }

  String get displayInitial {
    final label = displayName.trim();
    if (label.isEmpty) return 'U';
    return label[0].toUpperCase();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'User';
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: name,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      gender: json['gender'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalRides: (json['total_rides'] as num?)?.toInt() ?? 0,
      initial: json['initial'] as String? ??
          (name.isNotEmpty ? name[0].toUpperCase() : '?'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'gender': gender,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'rating': rating,
        'total_rides': totalRides,
        'initial': initial,
      };
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String? ?? '',
        refreshToken: json['refresh_token'] as String? ?? '',
      );
}

class OtpResponse {
  const OtpResponse({
    required this.success,
    required this.message,
    this.sessionId,
  });

  final bool success;
  final String message;
  final String? sessionId;

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        sessionId: json['session_id'] as String?,
      );
}

class LoginResponse {
  const LoginResponse({
    required this.success,
    required this.isRegistered,
    required this.isVerified,
    required this.tokens,
    this.user,
  });

  final bool success;
  final bool isRegistered;
  final bool isVerified;
  final AuthTokens tokens;
  final UserProfile? user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json['success'] as bool? ?? false,
        isRegistered: json['is_registered'] as bool? ?? true,
        isVerified: json['is_verified'] as bool? ?? true,
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
        user: json['user'] != null
            ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );
}

class HomeBanner {
  const HomeBanner({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  factory HomeBanner.fromJson(Map<String, dynamic> json) => HomeBanner(
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
      );
}

class VehicleCategory {
  const VehicleCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.baseFare,
    required this.perKmRate,
    this.includedDistanceKm,
    this.includedHours,
    this.perHourRate,
    this.iconUrl,
    this.serviceGroup = 'ride',
    this.capacity = 4,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final double baseFare;
  final double perKmRate;
  final double? includedDistanceKm;
  final double? includedHours;
  final double? perHourRate;
  final String? iconUrl;
  final String serviceGroup;
  final int capacity;

  factory VehicleCategory.fromJson(Map<String, dynamic> json) => VehicleCategory(
        id: json['id']?.toString() ?? '',
        slug: json['slug'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        baseFare: (json['base_fare'] as num?)?.toDouble() ?? 0,
        perKmRate: (json['per_km_rate'] as num?)?.toDouble() ?? 0,
        includedDistanceKm: (json['included_distance_km'] as num?)?.toDouble(),
        includedHours: (json['included_hours'] as num?)?.toDouble(),
        perHourRate: (json['per_hour_rate'] as num?)?.toDouble(),
        iconUrl: json['icon_url'] as String? ?? json['image_url'] as String?,
        serviceGroup: json['service_group'] as String? ?? 'ride',
        capacity: (json['capacity'] as num?)?.toInt() ?? 4,
      );
}

class HomeDashboard {
  const HomeDashboard({
    required this.greetingName,
    this.fullName = '',
    required this.nearbyDriversCount,
    required this.banners,
    required this.vehicleCategories,
  });

  final String greetingName;
  final String fullName;
  final int nearbyDriversCount;
  final List<HomeBanner> banners;
  final List<VehicleCategory> vehicleCategories;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) => HomeDashboard(
        greetingName: json['greeting_name'] as String? ?? 'there',
        fullName: json['full_name'] as String? ?? '',
        nearbyDriversCount: json['nearby_drivers_count'] as int? ?? 0,
        banners: (json['banners'] as List<dynamic>? ?? [])
            .map((e) => HomeBanner.fromJson(e as Map<String, dynamic>))
            .toList(),
        vehicleCategories: (json['vehicle_categories'] as List<dynamic>? ?? [])
            .map((e) => VehicleCategory.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.bonusBalance,
    required this.total,
    required this.paymentMethods,
    this.hasBankAccount = false,
    this.bank,
  });

  final double balance;
  final double bonusBalance;
  final double total;
  final List<PaymentMethod> paymentMethods;
  final bool hasBankAccount;
  final UserBankInfo? bank;

  factory WalletSummary.fromJson(Map<String, dynamic> json) => WalletSummary(
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        bonusBalance: (json['bonus_balance'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        paymentMethods: (json['payment_methods'] as List<dynamic>? ?? [])
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasBankAccount: json['has_bank_account'] == true || json['bank'] != null,
        bank: json['bank'] is Map<String, dynamic>
            ? UserBankInfo.fromJson(json['bank'] as Map<String, dynamic>)
            : null,
      );
}

class UserBankInfo {
  const UserBankInfo({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
    this.upiId,
  });

  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String bankName;
  final String? upiId;

  factory UserBankInfo.fromJson(Map<String, dynamic> json) => UserBankInfo(
        accountHolder: json['account_holder'] as String? ?? '',
        accountNumber: json['account_number'] as String? ?? '',
        ifsc: json['ifsc'] as String? ?? '',
        bankName: json['bank_name'] as String? ?? '',
        upiId: json['upi_id'] as String?,
      );

  bool get isUpi => bankName.toUpperCase() == 'UPI' || (upiId?.isNotEmpty ?? false);
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour,
  });

  final String id;
  final String type;
  final String label;
  final String? lastFour;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        label: json['label'] as String? ?? '',
        lastFour: json['last_four'] as String?,
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    this.data,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String time;
  final bool read;
  final Map<String, dynamic>? data;

  bool get isRideAccepted =>
      type == 'ride' && data?['event'] == 'ride_accepted';

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? json['body'] as String? ?? '',
        time: json['time'] as String? ?? '',
        read: json['read'] as bool? ?? json['is_read'] as bool? ?? true,
        data: json['data'] as Map<String, dynamic>?,
      );
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.address,
    required this.date,
    required this.price,
    required this.status,
  });

  final int id;
  final String title;
  final String address;
  final String date;
  final String price;
  final String status;

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        address: json['address'] as String? ?? '',
        date: json['date'] as String? ?? '',
        price: json['price'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
}

class RideStopLocation {
  const RideStopLocation({
    required this.address,
    required this.lat,
    required this.lng,
    this.sequence = 1,
  });

  final String address;
  final double lat;
  final double lng;
  final int sequence;

  factory RideStopLocation.fromJson(Map<String, dynamic> json) => RideStopLocation(
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
      );

  bool get hasCoordinates => lat != 0 || lng != 0;
}

class UserActiveRide {
  const UserActiveRide({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    this.publicId,
    this.fareEstimate,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverPhotoUrl,
    this.vehicleNumber,
    this.vehicleTypeSlug,
    this.vehicleTypeName,
    this.startCode,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.driverLat,
    this.driverLng,
    this.stops = const [],
    this.distanceKm,
    this.durationMin,
    this.paymentMethod,
    this.womenSafetyEnabled = false,
    this.preferWomenRiders = false,
    this.isEmergency = false,
  });

  final String id;
  final String? publicId;
  final String pickupAddress;
  final String dropoffAddress;
  final String status;
  final double? fareEstimate;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? driverPhotoUrl;
  final String? vehicleNumber;
  final String? vehicleTypeSlug;
  final String? vehicleTypeName;
  final String? startCode;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final double? driverLat;
  final double? driverLng;
  final List<RideStopLocation> stops;
  final double? distanceKm;
  final double? durationMin;
  final String? paymentMethod;
  final bool womenSafetyEnabled;
  final bool preferWomenRiders;
  final bool isEmergency;

  /// Share Ride + SOS — available for every passenger during an active trip.
  bool get showEmergencySafetyControls => true;

  /// Extra women safety UX (badge + periodic "Are you safe?" check-in).
  bool get showWomenSafetyControls =>
      womenSafetyEnabled || preferWomenRiders;

  static List<RideStopLocation> stopsFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => RideStopLocation.fromJson(Map<String, dynamic>.from(e)))
        .where((s) => s.address.trim().isNotEmpty)
        .toList();
  }

  factory UserActiveRide.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final vehicleType = json['vehicle_type'] as Map<String, dynamic>?;
    return UserActiveRide(
      id: json['id']?.toString() ?? '',
      publicId: json['public_id']?.toString(),
      pickupAddress: json['pickup_address'] as String? ?? '',
      dropoffAddress: json['dropoff_address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      fareEstimate: (json['fare_estimate'] as num?)?.toDouble(),
      driverName: driver?['name'] as String?,
      driverPhone: driver?['phone'] as String?,
      driverRating: (driver?['rating'] as num?)?.toDouble(),
      driverPhotoUrl: driver?['photo_url'] as String? ??
          json['driver_photo_url'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleTypeSlug: vehicleType?['slug'] as String? ??
          json['vehicle_type_slug'] as String?,
      vehicleTypeName: vehicleType?['name'] as String? ??
          json['vehicle_type_name'] as String?,
      startCode: json['start_code'] as String?,
      pickupLat: (json['pickup_lat'] as num?)?.toDouble(),
      pickupLng: (json['pickup_lng'] as num?)?.toDouble(),
      dropoffLat: (json['dropoff_lat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoff_lng'] as num?)?.toDouble(),
      driverLat: (json['driver_lat'] as num?)?.toDouble(),
      driverLng: (json['driver_lng'] as num?)?.toDouble(),
      stops: stopsFromJson(json['stops']),
      distanceKm: (json['estimated_distance_km'] as num?)?.toDouble(),
      durationMin: (json['estimated_duration_min'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String?,
      womenSafetyEnabled: json['women_safety_enabled'] == true,
      preferWomenRiders: json['prefer_women_riders'] == true,
      isEmergency: json['is_emergency'] == true,
    );
  }

  UserActiveRide copyWithDriverLocation({double? lat, double? lng}) {
    return UserActiveRide(
      id: id,
      publicId: publicId,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: status,
      fareEstimate: fareEstimate,
      driverName: driverName,
      driverPhone: driverPhone,
      driverRating: driverRating,
      driverPhotoUrl: driverPhotoUrl,
      vehicleNumber: vehicleNumber,
      vehicleTypeSlug: vehicleTypeSlug,
      vehicleTypeName: vehicleTypeName,
      startCode: startCode,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      driverLat: lat ?? driverLat,
      driverLng: lng ?? driverLng,
      stops: stops,
      distanceKm: distanceKm,
      durationMin: durationMin,
      paymentMethod: paymentMethod,
      womenSafetyEnabled: womenSafetyEnabled,
      preferWomenRiders: preferWomenRiders,
      isEmergency: isEmergency,
    );
  }

  UserActiveRide copyWith({
    String? status,
    String? startCode,
    bool? womenSafetyEnabled,
    bool? preferWomenRiders,
    bool? isEmergency,
    List<RideStopLocation>? stops,
  }) {
    return UserActiveRide(
      id: id,
      publicId: publicId,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      status: status ?? this.status,
      fareEstimate: fareEstimate,
      driverName: driverName,
      driverPhone: driverPhone,
      driverRating: driverRating,
      driverPhotoUrl: driverPhotoUrl,
      vehicleNumber: vehicleNumber,
      vehicleTypeSlug: vehicleTypeSlug,
      vehicleTypeName: vehicleTypeName,
      startCode: startCode ?? this.startCode,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      driverLat: driverLat,
      driverLng: driverLng,
      stops: stops ?? this.stops,
      distanceKm: distanceKm,
      durationMin: durationMin,
      paymentMethod: paymentMethod,
      womenSafetyEnabled: womenSafetyEnabled ?? this.womenSafetyEnabled,
      preferWomenRiders: preferWomenRiders ?? this.preferWomenRiders,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }

  bool get isInProgress {
    final normalized = status.toUpperCase();
    return normalized == 'OTP_VERIFIED' ||
        normalized == 'STARTED' ||
        normalized == 'IN_PROGRESS';
  }

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  bool get hasDriver => driverName != null && driverName!.isNotEmpty;

  bool get isSearching {
    final normalized = status.toUpperCase();
    return normalized == 'REQUESTED' || normalized == 'SEARCHING_DRIVER';
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
      case 'SEARCHING_DRIVER':
        return 'Finding captain';
      case 'DRIVER_ASSIGNED':
        return 'Captain on the way';
      case 'DRIVER_ARRIVED':
        return 'Captain arrived';
      case 'OTP_VERIFIED':
      case 'STARTED':
      case 'IN_PROGRESS':
        return 'Ride in progress';
      default:
        return 'Active ride';
    }
  }

  String get statusSubtitle {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
      case 'SEARCHING_DRIVER':
        return 'We are notifying nearby captains';
      case 'DRIVER_ASSIGNED':
        return 'Your captain is heading to pickup';
      case 'DRIVER_ARRIVED':
        return 'Meet your captain at pickup';
      case 'OTP_VERIFIED':
      case 'STARTED':
      case 'IN_PROGRESS':
        return 'Enjoy your trip';
      default:
        return 'Tap to view live updates';
    }
  }
}
