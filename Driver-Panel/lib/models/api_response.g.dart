// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  _ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'meta': instance.meta,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  expiresIn: (json['expires_in'] as num?)?.toInt(),
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
    };

_OtpResponse _$OtpResponseFromJson(Map<String, dynamic> json) => _OtpResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  sessionId: json['session_id'] as String?,
);

Map<String, dynamic> _$OtpResponseToJson(_OtpResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'session_id': instance.sessionId,
    };

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      driver: json['driver'] == null
          ? null
          : DriverProfile.fromJson(json['driver'] as Map<String, dynamic>),
      isRegistered: json['is_registered'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'tokens': instance.tokens,
      'driver': instance.driver,
      'is_registered': instance.isRegistered,
      'is_verified': instance.isVerified,
    };

_DriverProfile _$DriverProfileFromJson(Map<String, dynamic> json) =>
    _DriverProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      isOnline: json['is_online'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      vehicle: json['vehicle'] == null
          ? null
          : VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
      bankDetails: json['bankDetails'] == null
          ? null
          : BankDetails.fromJson(json['bankDetails'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DriverProfileToJson(_DriverProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'avatar': instance.avatar,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'rating': instance.rating,
      'total_trips': instance.totalTrips,
      'is_online': instance.isOnline,
      'verification_status': instance.verificationStatus,
      'vehicle': instance.vehicle,
      'bankDetails': instance.bankDetails,
    };

_VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => _VehicleInfo(
  id: json['id'] as String?,
  vehicleType: json['vehicle_type'] as String?,
  vehicleNumber: json['vehicle_number'] as String?,
  brand: json['brand'] as String?,
  model: json['model'] as String?,
  color: json['color'] as String?,
  manufacturingYear: (json['manufacturing_year'] as num?)?.toInt(),
);

Map<String, dynamic> _$VehicleInfoToJson(_VehicleInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicle_type': instance.vehicleType,
      'vehicle_number': instance.vehicleNumber,
      'brand': instance.brand,
      'model': instance.model,
      'color': instance.color,
      'manufacturing_year': instance.manufacturingYear,
    };

_BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => _BankDetails(
  accountHolder: json['account_holder'] as String?,
  accountNumber: json['account_number'] as String?,
  ifsc: json['ifsc'] as String?,
  bankName: json['bank_name'] as String?,
  upiId: json['upi_id'] as String?,
);

Map<String, dynamic> _$BankDetailsToJson(_BankDetails instance) =>
    <String, dynamic>{
      'account_holder': instance.accountHolder,
      'account_number': instance.accountNumber,
      'ifsc': instance.ifsc,
      'bank_name': instance.bankName,
      'upi_id': instance.upiId,
    };
