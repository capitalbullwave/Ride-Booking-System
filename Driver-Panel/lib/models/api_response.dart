import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
    @JsonKey(name: 'meta') Map<String, dynamic>? meta,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

@freezed
abstract class OtpResponse with _$OtpResponse {
  const factory OtpResponse({
    required bool success,
    String? message,
    @JsonKey(name: 'session_id') String? sessionId,
  }) = _OtpResponse;

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);
}

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required AuthTokens tokens,
    DriverProfile? driver,
    @JsonKey(name: 'is_registered') @Default(false) bool isRegistered,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
abstract class DriverProfile with _$DriverProfile {
  const factory DriverProfile({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? avatar,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    String? gender,
    double? rating,
    @JsonKey(name: 'total_trips') @Default(0) int totalTrips,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
    @JsonKey(name: 'verification_status')
    @Default('pending')
    String verificationStatus,
    VehicleInfo? vehicle,
    BankDetails? bankDetails,
  }) = _DriverProfile;

  factory DriverProfile.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileFromJson(json);
}

@freezed
abstract class VehicleInfo with _$VehicleInfo {
  const factory VehicleInfo({
    String? id,
    @JsonKey(name: 'vehicle_type') String? vehicleType,
    @JsonKey(name: 'vehicle_number') String? vehicleNumber,
    String? brand,
    String? model,
    String? color,
    @JsonKey(name: 'manufacturing_year') int? manufacturingYear,
  }) = _VehicleInfo;

  factory VehicleInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleInfoFromJson(json);
}

@freezed
abstract class BankDetails with _$BankDetails {
  const factory BankDetails({
    @JsonKey(name: 'account_holder') String? accountHolder,
    @JsonKey(name: 'account_number') String? accountNumber,
    String? ifsc,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'upi_id') String? upiId,
  }) = _BankDetails;

  factory BankDetails.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsFromJson(json);
}
