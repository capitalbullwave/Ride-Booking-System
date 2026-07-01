// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverRegistration _$DriverRegistrationFromJson(Map<String, dynamic> json) =>
    _DriverRegistration(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      referralCode: json['referral_code'] as String?,
      languagesSpoken: json['languages_spoken'] as String?,
      alternatePhone: json['alternate_phone'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      pinCode: json['pin_code'] as String?,
      currentAddress: json['current_address'] as String?,
      licenseNumber: json['license_number'] as String?,
      licenseIssueDate: json['license_issue_date'] as String?,
      licenseExpiryDate: json['license_expiry_date'] as String?,
      licenseFrontUrl: json['license_front_url'] as String?,
      licenseBackUrl: json['license_back_url'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleBrand: json['vehicle_brand'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      vehicleColor: json['vehicle_color'] as String?,
      manufacturingYear: (json['manufacturing_year'] as num?)?.toInt(),
      variant: json['variant'] as String?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      rcUrl: json['rc_url'] as String?,
      insuranceUrl: json['insurance_url'] as String?,
      pollutionUrl: json['pollution_url'] as String?,
      permitUrl: json['permit_url'] as String?,
      fitnessUrl: json['fitness_url'] as String?,
      vehicleFrontUrl: json['vehicle_front_url'] as String?,
      vehicleBackUrl: json['vehicle_back_url'] as String?,
      vehicleSideUrl: json['vehicle_side_url'] as String?,
      vehicleLeftUrl: json['vehicle_left_url'] as String?,
      vehicleRightUrl: json['vehicle_right_url'] as String?,
      selfieUrl: json['selfie_url'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      aadhaarNumber: json['aadhaar_number'] as String?,
      panNumber: json['pan_number'] as String?,
      aadhaarFrontUrl: json['aadhaar_front_url'] as String?,
      aadhaarBackUrl: json['aadhaar_back_url'] as String?,
      panUrl: json['pan_url'] as String?,
      accountHolder: json['account_holder'] as String?,
      accountNumber: json['account_number'] as String?,
      ifsc: json['ifsc'] as String?,
      bankName: json['bank_name'] as String?,
      bankBranch: json['bank_branch'] as String?,
      upiId: json['upi_id'] as String?,
      confirmAccountNumber: json['confirm_account_number'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactRelation: json['emergency_contact_relation'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencySecondaryPhone: json['emergency_secondary_phone'] as String?,
    );

Map<String, dynamic> _$DriverRegistrationToJson(_DriverRegistration instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'referral_code': instance.referralCode,
      'languages_spoken': instance.languagesSpoken,
      'alternate_phone': instance.alternatePhone,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'pin_code': instance.pinCode,
      'current_address': instance.currentAddress,
      'license_number': instance.licenseNumber,
      'license_issue_date': instance.licenseIssueDate,
      'license_expiry_date': instance.licenseExpiryDate,
      'license_front_url': instance.licenseFrontUrl,
      'license_back_url': instance.licenseBackUrl,
      'vehicle_type': instance.vehicleType,
      'vehicle_number': instance.vehicleNumber,
      'vehicle_brand': instance.vehicleBrand,
      'vehicle_model': instance.vehicleModel,
      'vehicle_color': instance.vehicleColor,
      'manufacturing_year': instance.manufacturingYear,
      'variant': instance.variant,
      'fuel_type': instance.fuelType,
      'transmission': instance.transmission,
      'rc_url': instance.rcUrl,
      'insurance_url': instance.insuranceUrl,
      'pollution_url': instance.pollutionUrl,
      'permit_url': instance.permitUrl,
      'fitness_url': instance.fitnessUrl,
      'vehicle_front_url': instance.vehicleFrontUrl,
      'vehicle_back_url': instance.vehicleBackUrl,
      'vehicle_side_url': instance.vehicleSideUrl,
      'vehicle_left_url': instance.vehicleLeftUrl,
      'vehicle_right_url': instance.vehicleRightUrl,
      'selfie_url': instance.selfieUrl,
      'profile_photo_url': instance.profilePhotoUrl,
      'aadhaar_number': instance.aadhaarNumber,
      'pan_number': instance.panNumber,
      'aadhaar_front_url': instance.aadhaarFrontUrl,
      'aadhaar_back_url': instance.aadhaarBackUrl,
      'pan_url': instance.panUrl,
      'account_holder': instance.accountHolder,
      'account_number': instance.accountNumber,
      'ifsc': instance.ifsc,
      'bank_name': instance.bankName,
      'bank_branch': instance.bankBranch,
      'upi_id': instance.upiId,
      'confirm_account_number': instance.confirmAccountNumber,
      'emergency_contact_name': instance.emergencyContactName,
      'emergency_contact_relation': instance.emergencyContactRelation,
      'emergency_contact_phone': instance.emergencyContactPhone,
      'emergency_secondary_phone': instance.emergencySecondaryPhone,
    };

_DocumentInfo _$DocumentInfoFromJson(Map<String, dynamic> json) =>
    _DocumentInfo(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      documentUrl: json['document_url'] as String?,
      expiryDate: json['expiry_date'] as String?,
      isExpiringSoon: json['is_expiring_soon'] as bool? ?? false,
    );

Map<String, dynamic> _$DocumentInfoToJson(_DocumentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'status': instance.status,
      'document_url': instance.documentUrl,
      'expiry_date': instance.expiryDate,
      'is_expiring_soon': instance.isExpiringSoon,
    };

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      completedTrips: (json['completed_trips'] as num?)?.toInt() ?? 0,
      todayTrips: (json['today_trips'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 0,
      cancellationRate: (json['cancellation_rate'] as num?)?.toDouble() ?? 0,
      weeklyTrips: (json['weekly_trips'] as num?)?.toInt() ?? 0,
      monthlyTrips: (json['monthly_trips'] as num?)?.toInt() ?? 0,
      cancelledTrips: (json['cancelled_trips'] as num?)?.toInt() ?? 0,
      onlineHours: (json['online_hours'] as num?)?.toDouble() ?? 0,
      currentLocation: json['current_location'] as String?,
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'today_earnings': instance.todayEarnings,
      'wallet_balance': instance.walletBalance,
      'completed_trips': instance.completedTrips,
      'today_trips': instance.todayTrips,
      'rating': instance.rating,
      'acceptance_rate': instance.acceptanceRate,
      'cancellation_rate': instance.cancellationRate,
      'weekly_trips': instance.weeklyTrips,
      'monthly_trips': instance.monthlyTrips,
      'cancelled_trips': instance.cancelledTrips,
      'online_hours': instance.onlineHours,
      'current_location': instance.currentLocation,
    };

_SupportTicket _$SupportTicketFromJson(Map<String, dynamic> json) =>
    _SupportTicket(
      id: json['id'] as String,
      subject: json['subject'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SupportTicketToJson(_SupportTicket instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

_FaqItem _$FaqItemFromJson(Map<String, dynamic> json) => _FaqItem(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String,
  category: json['category'] as String?,
);

Map<String, dynamic> _$FaqItemToJson(_FaqItem instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
  'category': instance.category,
};

_EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    _EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relation: json['relation'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(_EmergencyContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'relation': instance.relation,
    };
