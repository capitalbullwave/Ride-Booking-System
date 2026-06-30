import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_model.freezed.dart';
part 'registration_model.g.dart';

@freezed
abstract class DriverRegistration with _$DriverRegistration {
  const factory DriverRegistration({
    // Step 1 - Personal
    @Default('') String fullName,
    @Default('') String phone,
    @Default('') String email,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    String? gender,
    @JsonKey(name: 'referral_code') String? referralCode,
    // Step 2 - Address
    String? country,
    String? state,
    String? city,
    @JsonKey(name: 'pin_code') String? pinCode,
    @JsonKey(name: 'current_address') String? currentAddress,
    // Step 3 - License
    @JsonKey(name: 'license_number') String? licenseNumber,
    @JsonKey(name: 'license_issue_date') String? licenseIssueDate,
    @JsonKey(name: 'license_expiry_date') String? licenseExpiryDate,
    @JsonKey(name: 'license_front_url') String? licenseFrontUrl,
    @JsonKey(name: 'license_back_url') String? licenseBackUrl,
    // Step 4 - Vehicle
    @JsonKey(name: 'vehicle_type') String? vehicleType,
    @JsonKey(name: 'vehicle_number') String? vehicleNumber,
    @JsonKey(name: 'vehicle_brand') String? vehicleBrand,
    @JsonKey(name: 'vehicle_model') String? vehicleModel,
    @JsonKey(name: 'vehicle_color') String? vehicleColor,
    @JsonKey(name: 'manufacturing_year') int? manufacturingYear,
    // Step 5 - Documents
    @JsonKey(name: 'rc_url') String? rcUrl,
    @JsonKey(name: 'insurance_url') String? insuranceUrl,
    @JsonKey(name: 'pollution_url') String? pollutionUrl,
    @JsonKey(name: 'permit_url') String? permitUrl,
    @JsonKey(name: 'fitness_url') String? fitnessUrl,
    @JsonKey(name: 'vehicle_front_url') String? vehicleFrontUrl,
    @JsonKey(name: 'vehicle_back_url') String? vehicleBackUrl,
    @JsonKey(name: 'vehicle_side_url') String? vehicleSideUrl,
    // Step 6 - Selfie
    @JsonKey(name: 'selfie_url') String? selfieUrl,
    // Step 7 - Bank
    @JsonKey(name: 'account_holder') String? accountHolder,
    @JsonKey(name: 'account_number') String? accountNumber,
    String? ifsc,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'upi_id') String? upiId,
  }) = _DriverRegistration;

  factory DriverRegistration.fromJson(Map<String, dynamic> json) =>
      _$DriverRegistrationFromJson(json);
}

@freezed
abstract class DocumentInfo with _$DocumentInfo {
  const factory DocumentInfo({
    required String id,
    required String type,
    required String status,
    @JsonKey(name: 'document_url') String? documentUrl,
    @JsonKey(name: 'expiry_date') String? expiryDate,
    @JsonKey(name: 'is_expiring_soon') @Default(false) bool isExpiringSoon,
  }) = _DocumentInfo;

  factory DocumentInfo.fromJson(Map<String, dynamic> json) =>
      _$DocumentInfoFromJson(json);
}

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @JsonKey(name: 'today_earnings') @Default(0) double todayEarnings,
    @JsonKey(name: 'wallet_balance') @Default(0) double walletBalance,
    @JsonKey(name: 'completed_trips') @Default(0) int completedTrips,
    @JsonKey(name: 'today_trips') @Default(0) int todayTrips,
    @Default(4.5) double rating,
    @JsonKey(name: 'acceptance_rate') @Default(0) double acceptanceRate,
    @JsonKey(name: 'cancellation_rate') @Default(0) double cancellationRate,
    @JsonKey(name: 'current_location') String? currentLocation,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}

@freezed
abstract class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    required String subject,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);
}

@freezed
abstract class FaqItem with _$FaqItem {
  const factory FaqItem({
    required String id,
    required String question,
    required String answer,
    String? category,
  }) = _FaqItem;

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      _$FaqItemFromJson(json);
}

@freezed
abstract class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String id,
    required String name,
    required String phone,
    String? relation,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}
