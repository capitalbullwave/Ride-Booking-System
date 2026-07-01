// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registration_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverRegistration {

// Step 1 - Personal
 String get fullName; String get phone; String get email;@JsonKey(name: 'date_of_birth') String? get dateOfBirth; String? get gender;@JsonKey(name: 'referral_code') String? get referralCode;@JsonKey(name: 'languages_spoken') String? get languagesSpoken;@JsonKey(name: 'alternate_phone') String? get alternatePhone;// Step 2 - Address
 String? get country; String? get state; String? get city;@JsonKey(name: 'pin_code') String? get pinCode;@JsonKey(name: 'current_address') String? get currentAddress;// Step 3 - License
@JsonKey(name: 'license_number') String? get licenseNumber;@JsonKey(name: 'license_issue_date') String? get licenseIssueDate;@JsonKey(name: 'license_expiry_date') String? get licenseExpiryDate;@JsonKey(name: 'license_front_url') String? get licenseFrontUrl;@JsonKey(name: 'license_back_url') String? get licenseBackUrl;// Step 4 - Vehicle
@JsonKey(name: 'vehicle_type') String? get vehicleType;@JsonKey(name: 'vehicle_number') String? get vehicleNumber;@JsonKey(name: 'vehicle_brand') String? get vehicleBrand;@JsonKey(name: 'vehicle_model') String? get vehicleModel;@JsonKey(name: 'vehicle_color') String? get vehicleColor;@JsonKey(name: 'manufacturing_year') int? get manufacturingYear; String? get variant;@JsonKey(name: 'fuel_type') String? get fuelType; String? get transmission;// Step 5 - Documents
@JsonKey(name: 'rc_url') String? get rcUrl;@JsonKey(name: 'insurance_url') String? get insuranceUrl;@JsonKey(name: 'pollution_url') String? get pollutionUrl;@JsonKey(name: 'permit_url') String? get permitUrl;@JsonKey(name: 'fitness_url') String? get fitnessUrl;@JsonKey(name: 'vehicle_front_url') String? get vehicleFrontUrl;@JsonKey(name: 'vehicle_back_url') String? get vehicleBackUrl;@JsonKey(name: 'vehicle_side_url') String? get vehicleSideUrl;@JsonKey(name: 'vehicle_left_url') String? get vehicleLeftUrl;@JsonKey(name: 'vehicle_right_url') String? get vehicleRightUrl;// Step 6 - Profile photo / selfie
@JsonKey(name: 'selfie_url') String? get selfieUrl;@JsonKey(name: 'profile_photo_url') String? get profilePhotoUrl;// Step 7 - KYC
@JsonKey(name: 'aadhaar_number') String? get aadhaarNumber;@JsonKey(name: 'pan_number') String? get panNumber;@JsonKey(name: 'aadhaar_front_url') String? get aadhaarFrontUrl;@JsonKey(name: 'aadhaar_back_url') String? get aadhaarBackUrl;@JsonKey(name: 'pan_url') String? get panUrl;// Step 8 - Bank
@JsonKey(name: 'account_holder') String? get accountHolder;@JsonKey(name: 'account_number') String? get accountNumber; String? get ifsc;@JsonKey(name: 'bank_name') String? get bankName;@JsonKey(name: 'bank_branch') String? get bankBranch;@JsonKey(name: 'upi_id') String? get upiId;@JsonKey(name: 'confirm_account_number') String? get confirmAccountNumber;// Step 9 - Emergency contact
@JsonKey(name: 'emergency_contact_name') String? get emergencyContactName;@JsonKey(name: 'emergency_contact_relation') String? get emergencyContactRelation;@JsonKey(name: 'emergency_contact_phone') String? get emergencyContactPhone;@JsonKey(name: 'emergency_secondary_phone') String? get emergencySecondaryPhone;
/// Create a copy of DriverRegistration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverRegistrationCopyWith<DriverRegistration> get copyWith => _$DriverRegistrationCopyWithImpl<DriverRegistration>(this as DriverRegistration, _$identity);

  /// Serializes this DriverRegistration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverRegistration&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode)&&(identical(other.languagesSpoken, languagesSpoken) || other.languagesSpoken == languagesSpoken)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.currentAddress, currentAddress) || other.currentAddress == currentAddress)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.licenseIssueDate, licenseIssueDate) || other.licenseIssueDate == licenseIssueDate)&&(identical(other.licenseExpiryDate, licenseExpiryDate) || other.licenseExpiryDate == licenseExpiryDate)&&(identical(other.licenseFrontUrl, licenseFrontUrl) || other.licenseFrontUrl == licenseFrontUrl)&&(identical(other.licenseBackUrl, licenseBackUrl) || other.licenseBackUrl == licenseBackUrl)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.vehicleBrand, vehicleBrand) || other.vehicleBrand == vehicleBrand)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.vehicleColor, vehicleColor) || other.vehicleColor == vehicleColor)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.rcUrl, rcUrl) || other.rcUrl == rcUrl)&&(identical(other.insuranceUrl, insuranceUrl) || other.insuranceUrl == insuranceUrl)&&(identical(other.pollutionUrl, pollutionUrl) || other.pollutionUrl == pollutionUrl)&&(identical(other.permitUrl, permitUrl) || other.permitUrl == permitUrl)&&(identical(other.fitnessUrl, fitnessUrl) || other.fitnessUrl == fitnessUrl)&&(identical(other.vehicleFrontUrl, vehicleFrontUrl) || other.vehicleFrontUrl == vehicleFrontUrl)&&(identical(other.vehicleBackUrl, vehicleBackUrl) || other.vehicleBackUrl == vehicleBackUrl)&&(identical(other.vehicleSideUrl, vehicleSideUrl) || other.vehicleSideUrl == vehicleSideUrl)&&(identical(other.vehicleLeftUrl, vehicleLeftUrl) || other.vehicleLeftUrl == vehicleLeftUrl)&&(identical(other.vehicleRightUrl, vehicleRightUrl) || other.vehicleRightUrl == vehicleRightUrl)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.aadhaarNumber, aadhaarNumber) || other.aadhaarNumber == aadhaarNumber)&&(identical(other.panNumber, panNumber) || other.panNumber == panNumber)&&(identical(other.aadhaarFrontUrl, aadhaarFrontUrl) || other.aadhaarFrontUrl == aadhaarFrontUrl)&&(identical(other.aadhaarBackUrl, aadhaarBackUrl) || other.aadhaarBackUrl == aadhaarBackUrl)&&(identical(other.panUrl, panUrl) || other.panUrl == panUrl)&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.confirmAccountNumber, confirmAccountNumber) || other.confirmAccountNumber == confirmAccountNumber)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactRelation, emergencyContactRelation) || other.emergencyContactRelation == emergencyContactRelation)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.emergencySecondaryPhone, emergencySecondaryPhone) || other.emergencySecondaryPhone == emergencySecondaryPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,fullName,phone,email,dateOfBirth,gender,referralCode,languagesSpoken,alternatePhone,country,state,city,pinCode,currentAddress,licenseNumber,licenseIssueDate,licenseExpiryDate,licenseFrontUrl,licenseBackUrl,vehicleType,vehicleNumber,vehicleBrand,vehicleModel,vehicleColor,manufacturingYear,variant,fuelType,transmission,rcUrl,insuranceUrl,pollutionUrl,permitUrl,fitnessUrl,vehicleFrontUrl,vehicleBackUrl,vehicleSideUrl,vehicleLeftUrl,vehicleRightUrl,selfieUrl,profilePhotoUrl,aadhaarNumber,panNumber,aadhaarFrontUrl,aadhaarBackUrl,panUrl,accountHolder,accountNumber,ifsc,bankName,bankBranch,upiId,confirmAccountNumber,emergencyContactName,emergencyContactRelation,emergencyContactPhone,emergencySecondaryPhone]);

@override
String toString() {
  return 'DriverRegistration(fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, referralCode: $referralCode, languagesSpoken: $languagesSpoken, alternatePhone: $alternatePhone, country: $country, state: $state, city: $city, pinCode: $pinCode, currentAddress: $currentAddress, licenseNumber: $licenseNumber, licenseIssueDate: $licenseIssueDate, licenseExpiryDate: $licenseExpiryDate, licenseFrontUrl: $licenseFrontUrl, licenseBackUrl: $licenseBackUrl, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleColor: $vehicleColor, manufacturingYear: $manufacturingYear, variant: $variant, fuelType: $fuelType, transmission: $transmission, rcUrl: $rcUrl, insuranceUrl: $insuranceUrl, pollutionUrl: $pollutionUrl, permitUrl: $permitUrl, fitnessUrl: $fitnessUrl, vehicleFrontUrl: $vehicleFrontUrl, vehicleBackUrl: $vehicleBackUrl, vehicleSideUrl: $vehicleSideUrl, vehicleLeftUrl: $vehicleLeftUrl, vehicleRightUrl: $vehicleRightUrl, selfieUrl: $selfieUrl, profilePhotoUrl: $profilePhotoUrl, aadhaarNumber: $aadhaarNumber, panNumber: $panNumber, aadhaarFrontUrl: $aadhaarFrontUrl, aadhaarBackUrl: $aadhaarBackUrl, panUrl: $panUrl, accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, bankBranch: $bankBranch, upiId: $upiId, confirmAccountNumber: $confirmAccountNumber, emergencyContactName: $emergencyContactName, emergencyContactRelation: $emergencyContactRelation, emergencyContactPhone: $emergencyContactPhone, emergencySecondaryPhone: $emergencySecondaryPhone)';
}


}

/// @nodoc
abstract mixin class $DriverRegistrationCopyWith<$Res>  {
  factory $DriverRegistrationCopyWith(DriverRegistration value, $Res Function(DriverRegistration) _then) = _$DriverRegistrationCopyWithImpl;
@useResult
$Res call({
 String fullName, String phone, String email,@JsonKey(name: 'date_of_birth') String? dateOfBirth, String? gender,@JsonKey(name: 'referral_code') String? referralCode,@JsonKey(name: 'languages_spoken') String? languagesSpoken,@JsonKey(name: 'alternate_phone') String? alternatePhone, String? country, String? state, String? city,@JsonKey(name: 'pin_code') String? pinCode,@JsonKey(name: 'current_address') String? currentAddress,@JsonKey(name: 'license_number') String? licenseNumber,@JsonKey(name: 'license_issue_date') String? licenseIssueDate,@JsonKey(name: 'license_expiry_date') String? licenseExpiryDate,@JsonKey(name: 'license_front_url') String? licenseFrontUrl,@JsonKey(name: 'license_back_url') String? licenseBackUrl,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber,@JsonKey(name: 'vehicle_brand') String? vehicleBrand,@JsonKey(name: 'vehicle_model') String? vehicleModel,@JsonKey(name: 'vehicle_color') String? vehicleColor,@JsonKey(name: 'manufacturing_year') int? manufacturingYear, String? variant,@JsonKey(name: 'fuel_type') String? fuelType, String? transmission,@JsonKey(name: 'rc_url') String? rcUrl,@JsonKey(name: 'insurance_url') String? insuranceUrl,@JsonKey(name: 'pollution_url') String? pollutionUrl,@JsonKey(name: 'permit_url') String? permitUrl,@JsonKey(name: 'fitness_url') String? fitnessUrl,@JsonKey(name: 'vehicle_front_url') String? vehicleFrontUrl,@JsonKey(name: 'vehicle_back_url') String? vehicleBackUrl,@JsonKey(name: 'vehicle_side_url') String? vehicleSideUrl,@JsonKey(name: 'vehicle_left_url') String? vehicleLeftUrl,@JsonKey(name: 'vehicle_right_url') String? vehicleRightUrl,@JsonKey(name: 'selfie_url') String? selfieUrl,@JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,@JsonKey(name: 'aadhaar_number') String? aadhaarNumber,@JsonKey(name: 'pan_number') String? panNumber,@JsonKey(name: 'aadhaar_front_url') String? aadhaarFrontUrl,@JsonKey(name: 'aadhaar_back_url') String? aadhaarBackUrl,@JsonKey(name: 'pan_url') String? panUrl,@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'bank_branch') String? bankBranch,@JsonKey(name: 'upi_id') String? upiId,@JsonKey(name: 'confirm_account_number') String? confirmAccountNumber,@JsonKey(name: 'emergency_contact_name') String? emergencyContactName,@JsonKey(name: 'emergency_contact_relation') String? emergencyContactRelation,@JsonKey(name: 'emergency_contact_phone') String? emergencyContactPhone,@JsonKey(name: 'emergency_secondary_phone') String? emergencySecondaryPhone
});




}
/// @nodoc
class _$DriverRegistrationCopyWithImpl<$Res>
    implements $DriverRegistrationCopyWith<$Res> {
  _$DriverRegistrationCopyWithImpl(this._self, this._then);

  final DriverRegistration _self;
  final $Res Function(DriverRegistration) _then;

/// Create a copy of DriverRegistration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phone = null,Object? email = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? referralCode = freezed,Object? languagesSpoken = freezed,Object? alternatePhone = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? pinCode = freezed,Object? currentAddress = freezed,Object? licenseNumber = freezed,Object? licenseIssueDate = freezed,Object? licenseExpiryDate = freezed,Object? licenseFrontUrl = freezed,Object? licenseBackUrl = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? vehicleBrand = freezed,Object? vehicleModel = freezed,Object? vehicleColor = freezed,Object? manufacturingYear = freezed,Object? variant = freezed,Object? fuelType = freezed,Object? transmission = freezed,Object? rcUrl = freezed,Object? insuranceUrl = freezed,Object? pollutionUrl = freezed,Object? permitUrl = freezed,Object? fitnessUrl = freezed,Object? vehicleFrontUrl = freezed,Object? vehicleBackUrl = freezed,Object? vehicleSideUrl = freezed,Object? vehicleLeftUrl = freezed,Object? vehicleRightUrl = freezed,Object? selfieUrl = freezed,Object? profilePhotoUrl = freezed,Object? aadhaarNumber = freezed,Object? panNumber = freezed,Object? aadhaarFrontUrl = freezed,Object? aadhaarBackUrl = freezed,Object? panUrl = freezed,Object? accountHolder = freezed,Object? accountNumber = freezed,Object? ifsc = freezed,Object? bankName = freezed,Object? bankBranch = freezed,Object? upiId = freezed,Object? confirmAccountNumber = freezed,Object? emergencyContactName = freezed,Object? emergencyContactRelation = freezed,Object? emergencyContactPhone = freezed,Object? emergencySecondaryPhone = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,languagesSpoken: freezed == languagesSpoken ? _self.languagesSpoken : languagesSpoken // ignore: cast_nullable_to_non_nullable
as String?,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,currentAddress: freezed == currentAddress ? _self.currentAddress : currentAddress // ignore: cast_nullable_to_non_nullable
as String?,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseIssueDate: freezed == licenseIssueDate ? _self.licenseIssueDate : licenseIssueDate // ignore: cast_nullable_to_non_nullable
as String?,licenseExpiryDate: freezed == licenseExpiryDate ? _self.licenseExpiryDate : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
as String?,licenseFrontUrl: freezed == licenseFrontUrl ? _self.licenseFrontUrl : licenseFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,licenseBackUrl: freezed == licenseBackUrl ? _self.licenseBackUrl : licenseBackUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleBrand: freezed == vehicleBrand ? _self.vehicleBrand : vehicleBrand // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,vehicleColor: freezed == vehicleColor ? _self.vehicleColor : vehicleColor // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as int?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,rcUrl: freezed == rcUrl ? _self.rcUrl : rcUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceUrl: freezed == insuranceUrl ? _self.insuranceUrl : insuranceUrl // ignore: cast_nullable_to_non_nullable
as String?,pollutionUrl: freezed == pollutionUrl ? _self.pollutionUrl : pollutionUrl // ignore: cast_nullable_to_non_nullable
as String?,permitUrl: freezed == permitUrl ? _self.permitUrl : permitUrl // ignore: cast_nullable_to_non_nullable
as String?,fitnessUrl: freezed == fitnessUrl ? _self.fitnessUrl : fitnessUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleFrontUrl: freezed == vehicleFrontUrl ? _self.vehicleFrontUrl : vehicleFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleBackUrl: freezed == vehicleBackUrl ? _self.vehicleBackUrl : vehicleBackUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleSideUrl: freezed == vehicleSideUrl ? _self.vehicleSideUrl : vehicleSideUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleLeftUrl: freezed == vehicleLeftUrl ? _self.vehicleLeftUrl : vehicleLeftUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleRightUrl: freezed == vehicleRightUrl ? _self.vehicleRightUrl : vehicleRightUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieUrl: freezed == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,aadhaarNumber: freezed == aadhaarNumber ? _self.aadhaarNumber : aadhaarNumber // ignore: cast_nullable_to_non_nullable
as String?,panNumber: freezed == panNumber ? _self.panNumber : panNumber // ignore: cast_nullable_to_non_nullable
as String?,aadhaarFrontUrl: freezed == aadhaarFrontUrl ? _self.aadhaarFrontUrl : aadhaarFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,aadhaarBackUrl: freezed == aadhaarBackUrl ? _self.aadhaarBackUrl : aadhaarBackUrl // ignore: cast_nullable_to_non_nullable
as String?,panUrl: freezed == panUrl ? _self.panUrl : panUrl // ignore: cast_nullable_to_non_nullable
as String?,accountHolder: freezed == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,ifsc: freezed == ifsc ? _self.ifsc : ifsc // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankBranch: freezed == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,confirmAccountNumber: freezed == confirmAccountNumber ? _self.confirmAccountNumber : confirmAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactRelation: freezed == emergencyContactRelation ? _self.emergencyContactRelation : emergencyContactRelation // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,emergencySecondaryPhone: freezed == emergencySecondaryPhone ? _self.emergencySecondaryPhone : emergencySecondaryPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverRegistration].
extension DriverRegistrationPatterns on DriverRegistration {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverRegistration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverRegistration() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverRegistration value)  $default,){
final _that = this;
switch (_that) {
case _DriverRegistration():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverRegistration value)?  $default,){
final _that = this;
switch (_that) {
case _DriverRegistration() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String phone,  String email, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender, @JsonKey(name: 'referral_code')  String? referralCode, @JsonKey(name: 'languages_spoken')  String? languagesSpoken, @JsonKey(name: 'alternate_phone')  String? alternatePhone,  String? country,  String? state,  String? city, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'current_address')  String? currentAddress, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_issue_date')  String? licenseIssueDate, @JsonKey(name: 'license_expiry_date')  String? licenseExpiryDate, @JsonKey(name: 'license_front_url')  String? licenseFrontUrl, @JsonKey(name: 'license_back_url')  String? licenseBackUrl, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_brand')  String? vehicleBrand, @JsonKey(name: 'vehicle_model')  String? vehicleModel, @JsonKey(name: 'vehicle_color')  String? vehicleColor, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear,  String? variant, @JsonKey(name: 'fuel_type')  String? fuelType,  String? transmission, @JsonKey(name: 'rc_url')  String? rcUrl, @JsonKey(name: 'insurance_url')  String? insuranceUrl, @JsonKey(name: 'pollution_url')  String? pollutionUrl, @JsonKey(name: 'permit_url')  String? permitUrl, @JsonKey(name: 'fitness_url')  String? fitnessUrl, @JsonKey(name: 'vehicle_front_url')  String? vehicleFrontUrl, @JsonKey(name: 'vehicle_back_url')  String? vehicleBackUrl, @JsonKey(name: 'vehicle_side_url')  String? vehicleSideUrl, @JsonKey(name: 'vehicle_left_url')  String? vehicleLeftUrl, @JsonKey(name: 'vehicle_right_url')  String? vehicleRightUrl, @JsonKey(name: 'selfie_url')  String? selfieUrl, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl, @JsonKey(name: 'aadhaar_number')  String? aadhaarNumber, @JsonKey(name: 'pan_number')  String? panNumber, @JsonKey(name: 'aadhaar_front_url')  String? aadhaarFrontUrl, @JsonKey(name: 'aadhaar_back_url')  String? aadhaarBackUrl, @JsonKey(name: 'pan_url')  String? panUrl, @JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'bank_branch')  String? bankBranch, @JsonKey(name: 'upi_id')  String? upiId, @JsonKey(name: 'confirm_account_number')  String? confirmAccountNumber, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_relation')  String? emergencyContactRelation, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone, @JsonKey(name: 'emergency_secondary_phone')  String? emergencySecondaryPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverRegistration() when $default != null:
return $default(_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.referralCode,_that.languagesSpoken,_that.alternatePhone,_that.country,_that.state,_that.city,_that.pinCode,_that.currentAddress,_that.licenseNumber,_that.licenseIssueDate,_that.licenseExpiryDate,_that.licenseFrontUrl,_that.licenseBackUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleBrand,_that.vehicleModel,_that.vehicleColor,_that.manufacturingYear,_that.variant,_that.fuelType,_that.transmission,_that.rcUrl,_that.insuranceUrl,_that.pollutionUrl,_that.permitUrl,_that.fitnessUrl,_that.vehicleFrontUrl,_that.vehicleBackUrl,_that.vehicleSideUrl,_that.vehicleLeftUrl,_that.vehicleRightUrl,_that.selfieUrl,_that.profilePhotoUrl,_that.aadhaarNumber,_that.panNumber,_that.aadhaarFrontUrl,_that.aadhaarBackUrl,_that.panUrl,_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.bankBranch,_that.upiId,_that.confirmAccountNumber,_that.emergencyContactName,_that.emergencyContactRelation,_that.emergencyContactPhone,_that.emergencySecondaryPhone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String phone,  String email, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender, @JsonKey(name: 'referral_code')  String? referralCode, @JsonKey(name: 'languages_spoken')  String? languagesSpoken, @JsonKey(name: 'alternate_phone')  String? alternatePhone,  String? country,  String? state,  String? city, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'current_address')  String? currentAddress, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_issue_date')  String? licenseIssueDate, @JsonKey(name: 'license_expiry_date')  String? licenseExpiryDate, @JsonKey(name: 'license_front_url')  String? licenseFrontUrl, @JsonKey(name: 'license_back_url')  String? licenseBackUrl, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_brand')  String? vehicleBrand, @JsonKey(name: 'vehicle_model')  String? vehicleModel, @JsonKey(name: 'vehicle_color')  String? vehicleColor, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear,  String? variant, @JsonKey(name: 'fuel_type')  String? fuelType,  String? transmission, @JsonKey(name: 'rc_url')  String? rcUrl, @JsonKey(name: 'insurance_url')  String? insuranceUrl, @JsonKey(name: 'pollution_url')  String? pollutionUrl, @JsonKey(name: 'permit_url')  String? permitUrl, @JsonKey(name: 'fitness_url')  String? fitnessUrl, @JsonKey(name: 'vehicle_front_url')  String? vehicleFrontUrl, @JsonKey(name: 'vehicle_back_url')  String? vehicleBackUrl, @JsonKey(name: 'vehicle_side_url')  String? vehicleSideUrl, @JsonKey(name: 'vehicle_left_url')  String? vehicleLeftUrl, @JsonKey(name: 'vehicle_right_url')  String? vehicleRightUrl, @JsonKey(name: 'selfie_url')  String? selfieUrl, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl, @JsonKey(name: 'aadhaar_number')  String? aadhaarNumber, @JsonKey(name: 'pan_number')  String? panNumber, @JsonKey(name: 'aadhaar_front_url')  String? aadhaarFrontUrl, @JsonKey(name: 'aadhaar_back_url')  String? aadhaarBackUrl, @JsonKey(name: 'pan_url')  String? panUrl, @JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'bank_branch')  String? bankBranch, @JsonKey(name: 'upi_id')  String? upiId, @JsonKey(name: 'confirm_account_number')  String? confirmAccountNumber, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_relation')  String? emergencyContactRelation, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone, @JsonKey(name: 'emergency_secondary_phone')  String? emergencySecondaryPhone)  $default,) {final _that = this;
switch (_that) {
case _DriverRegistration():
return $default(_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.referralCode,_that.languagesSpoken,_that.alternatePhone,_that.country,_that.state,_that.city,_that.pinCode,_that.currentAddress,_that.licenseNumber,_that.licenseIssueDate,_that.licenseExpiryDate,_that.licenseFrontUrl,_that.licenseBackUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleBrand,_that.vehicleModel,_that.vehicleColor,_that.manufacturingYear,_that.variant,_that.fuelType,_that.transmission,_that.rcUrl,_that.insuranceUrl,_that.pollutionUrl,_that.permitUrl,_that.fitnessUrl,_that.vehicleFrontUrl,_that.vehicleBackUrl,_that.vehicleSideUrl,_that.vehicleLeftUrl,_that.vehicleRightUrl,_that.selfieUrl,_that.profilePhotoUrl,_that.aadhaarNumber,_that.panNumber,_that.aadhaarFrontUrl,_that.aadhaarBackUrl,_that.panUrl,_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.bankBranch,_that.upiId,_that.confirmAccountNumber,_that.emergencyContactName,_that.emergencyContactRelation,_that.emergencyContactPhone,_that.emergencySecondaryPhone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String phone,  String email, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender, @JsonKey(name: 'referral_code')  String? referralCode, @JsonKey(name: 'languages_spoken')  String? languagesSpoken, @JsonKey(name: 'alternate_phone')  String? alternatePhone,  String? country,  String? state,  String? city, @JsonKey(name: 'pin_code')  String? pinCode, @JsonKey(name: 'current_address')  String? currentAddress, @JsonKey(name: 'license_number')  String? licenseNumber, @JsonKey(name: 'license_issue_date')  String? licenseIssueDate, @JsonKey(name: 'license_expiry_date')  String? licenseExpiryDate, @JsonKey(name: 'license_front_url')  String? licenseFrontUrl, @JsonKey(name: 'license_back_url')  String? licenseBackUrl, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber, @JsonKey(name: 'vehicle_brand')  String? vehicleBrand, @JsonKey(name: 'vehicle_model')  String? vehicleModel, @JsonKey(name: 'vehicle_color')  String? vehicleColor, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear,  String? variant, @JsonKey(name: 'fuel_type')  String? fuelType,  String? transmission, @JsonKey(name: 'rc_url')  String? rcUrl, @JsonKey(name: 'insurance_url')  String? insuranceUrl, @JsonKey(name: 'pollution_url')  String? pollutionUrl, @JsonKey(name: 'permit_url')  String? permitUrl, @JsonKey(name: 'fitness_url')  String? fitnessUrl, @JsonKey(name: 'vehicle_front_url')  String? vehicleFrontUrl, @JsonKey(name: 'vehicle_back_url')  String? vehicleBackUrl, @JsonKey(name: 'vehicle_side_url')  String? vehicleSideUrl, @JsonKey(name: 'vehicle_left_url')  String? vehicleLeftUrl, @JsonKey(name: 'vehicle_right_url')  String? vehicleRightUrl, @JsonKey(name: 'selfie_url')  String? selfieUrl, @JsonKey(name: 'profile_photo_url')  String? profilePhotoUrl, @JsonKey(name: 'aadhaar_number')  String? aadhaarNumber, @JsonKey(name: 'pan_number')  String? panNumber, @JsonKey(name: 'aadhaar_front_url')  String? aadhaarFrontUrl, @JsonKey(name: 'aadhaar_back_url')  String? aadhaarBackUrl, @JsonKey(name: 'pan_url')  String? panUrl, @JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'bank_branch')  String? bankBranch, @JsonKey(name: 'upi_id')  String? upiId, @JsonKey(name: 'confirm_account_number')  String? confirmAccountNumber, @JsonKey(name: 'emergency_contact_name')  String? emergencyContactName, @JsonKey(name: 'emergency_contact_relation')  String? emergencyContactRelation, @JsonKey(name: 'emergency_contact_phone')  String? emergencyContactPhone, @JsonKey(name: 'emergency_secondary_phone')  String? emergencySecondaryPhone)?  $default,) {final _that = this;
switch (_that) {
case _DriverRegistration() when $default != null:
return $default(_that.fullName,_that.phone,_that.email,_that.dateOfBirth,_that.gender,_that.referralCode,_that.languagesSpoken,_that.alternatePhone,_that.country,_that.state,_that.city,_that.pinCode,_that.currentAddress,_that.licenseNumber,_that.licenseIssueDate,_that.licenseExpiryDate,_that.licenseFrontUrl,_that.licenseBackUrl,_that.vehicleType,_that.vehicleNumber,_that.vehicleBrand,_that.vehicleModel,_that.vehicleColor,_that.manufacturingYear,_that.variant,_that.fuelType,_that.transmission,_that.rcUrl,_that.insuranceUrl,_that.pollutionUrl,_that.permitUrl,_that.fitnessUrl,_that.vehicleFrontUrl,_that.vehicleBackUrl,_that.vehicleSideUrl,_that.vehicleLeftUrl,_that.vehicleRightUrl,_that.selfieUrl,_that.profilePhotoUrl,_that.aadhaarNumber,_that.panNumber,_that.aadhaarFrontUrl,_that.aadhaarBackUrl,_that.panUrl,_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.bankBranch,_that.upiId,_that.confirmAccountNumber,_that.emergencyContactName,_that.emergencyContactRelation,_that.emergencyContactPhone,_that.emergencySecondaryPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverRegistration implements DriverRegistration {
  const _DriverRegistration({this.fullName = '', this.phone = '', this.email = '', @JsonKey(name: 'date_of_birth') this.dateOfBirth, this.gender, @JsonKey(name: 'referral_code') this.referralCode, @JsonKey(name: 'languages_spoken') this.languagesSpoken, @JsonKey(name: 'alternate_phone') this.alternatePhone, this.country, this.state, this.city, @JsonKey(name: 'pin_code') this.pinCode, @JsonKey(name: 'current_address') this.currentAddress, @JsonKey(name: 'license_number') this.licenseNumber, @JsonKey(name: 'license_issue_date') this.licenseIssueDate, @JsonKey(name: 'license_expiry_date') this.licenseExpiryDate, @JsonKey(name: 'license_front_url') this.licenseFrontUrl, @JsonKey(name: 'license_back_url') this.licenseBackUrl, @JsonKey(name: 'vehicle_type') this.vehicleType, @JsonKey(name: 'vehicle_number') this.vehicleNumber, @JsonKey(name: 'vehicle_brand') this.vehicleBrand, @JsonKey(name: 'vehicle_model') this.vehicleModel, @JsonKey(name: 'vehicle_color') this.vehicleColor, @JsonKey(name: 'manufacturing_year') this.manufacturingYear, this.variant, @JsonKey(name: 'fuel_type') this.fuelType, this.transmission, @JsonKey(name: 'rc_url') this.rcUrl, @JsonKey(name: 'insurance_url') this.insuranceUrl, @JsonKey(name: 'pollution_url') this.pollutionUrl, @JsonKey(name: 'permit_url') this.permitUrl, @JsonKey(name: 'fitness_url') this.fitnessUrl, @JsonKey(name: 'vehicle_front_url') this.vehicleFrontUrl, @JsonKey(name: 'vehicle_back_url') this.vehicleBackUrl, @JsonKey(name: 'vehicle_side_url') this.vehicleSideUrl, @JsonKey(name: 'vehicle_left_url') this.vehicleLeftUrl, @JsonKey(name: 'vehicle_right_url') this.vehicleRightUrl, @JsonKey(name: 'selfie_url') this.selfieUrl, @JsonKey(name: 'profile_photo_url') this.profilePhotoUrl, @JsonKey(name: 'aadhaar_number') this.aadhaarNumber, @JsonKey(name: 'pan_number') this.panNumber, @JsonKey(name: 'aadhaar_front_url') this.aadhaarFrontUrl, @JsonKey(name: 'aadhaar_back_url') this.aadhaarBackUrl, @JsonKey(name: 'pan_url') this.panUrl, @JsonKey(name: 'account_holder') this.accountHolder, @JsonKey(name: 'account_number') this.accountNumber, this.ifsc, @JsonKey(name: 'bank_name') this.bankName, @JsonKey(name: 'bank_branch') this.bankBranch, @JsonKey(name: 'upi_id') this.upiId, @JsonKey(name: 'confirm_account_number') this.confirmAccountNumber, @JsonKey(name: 'emergency_contact_name') this.emergencyContactName, @JsonKey(name: 'emergency_contact_relation') this.emergencyContactRelation, @JsonKey(name: 'emergency_contact_phone') this.emergencyContactPhone, @JsonKey(name: 'emergency_secondary_phone') this.emergencySecondaryPhone});
  factory _DriverRegistration.fromJson(Map<String, dynamic> json) => _$DriverRegistrationFromJson(json);

// Step 1 - Personal
@override@JsonKey() final  String fullName;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey(name: 'date_of_birth') final  String? dateOfBirth;
@override final  String? gender;
@override@JsonKey(name: 'referral_code') final  String? referralCode;
@override@JsonKey(name: 'languages_spoken') final  String? languagesSpoken;
@override@JsonKey(name: 'alternate_phone') final  String? alternatePhone;
// Step 2 - Address
@override final  String? country;
@override final  String? state;
@override final  String? city;
@override@JsonKey(name: 'pin_code') final  String? pinCode;
@override@JsonKey(name: 'current_address') final  String? currentAddress;
// Step 3 - License
@override@JsonKey(name: 'license_number') final  String? licenseNumber;
@override@JsonKey(name: 'license_issue_date') final  String? licenseIssueDate;
@override@JsonKey(name: 'license_expiry_date') final  String? licenseExpiryDate;
@override@JsonKey(name: 'license_front_url') final  String? licenseFrontUrl;
@override@JsonKey(name: 'license_back_url') final  String? licenseBackUrl;
// Step 4 - Vehicle
@override@JsonKey(name: 'vehicle_type') final  String? vehicleType;
@override@JsonKey(name: 'vehicle_number') final  String? vehicleNumber;
@override@JsonKey(name: 'vehicle_brand') final  String? vehicleBrand;
@override@JsonKey(name: 'vehicle_model') final  String? vehicleModel;
@override@JsonKey(name: 'vehicle_color') final  String? vehicleColor;
@override@JsonKey(name: 'manufacturing_year') final  int? manufacturingYear;
@override final  String? variant;
@override@JsonKey(name: 'fuel_type') final  String? fuelType;
@override final  String? transmission;
// Step 5 - Documents
@override@JsonKey(name: 'rc_url') final  String? rcUrl;
@override@JsonKey(name: 'insurance_url') final  String? insuranceUrl;
@override@JsonKey(name: 'pollution_url') final  String? pollutionUrl;
@override@JsonKey(name: 'permit_url') final  String? permitUrl;
@override@JsonKey(name: 'fitness_url') final  String? fitnessUrl;
@override@JsonKey(name: 'vehicle_front_url') final  String? vehicleFrontUrl;
@override@JsonKey(name: 'vehicle_back_url') final  String? vehicleBackUrl;
@override@JsonKey(name: 'vehicle_side_url') final  String? vehicleSideUrl;
@override@JsonKey(name: 'vehicle_left_url') final  String? vehicleLeftUrl;
@override@JsonKey(name: 'vehicle_right_url') final  String? vehicleRightUrl;
// Step 6 - Profile photo / selfie
@override@JsonKey(name: 'selfie_url') final  String? selfieUrl;
@override@JsonKey(name: 'profile_photo_url') final  String? profilePhotoUrl;
// Step 7 - KYC
@override@JsonKey(name: 'aadhaar_number') final  String? aadhaarNumber;
@override@JsonKey(name: 'pan_number') final  String? panNumber;
@override@JsonKey(name: 'aadhaar_front_url') final  String? aadhaarFrontUrl;
@override@JsonKey(name: 'aadhaar_back_url') final  String? aadhaarBackUrl;
@override@JsonKey(name: 'pan_url') final  String? panUrl;
// Step 8 - Bank
@override@JsonKey(name: 'account_holder') final  String? accountHolder;
@override@JsonKey(name: 'account_number') final  String? accountNumber;
@override final  String? ifsc;
@override@JsonKey(name: 'bank_name') final  String? bankName;
@override@JsonKey(name: 'bank_branch') final  String? bankBranch;
@override@JsonKey(name: 'upi_id') final  String? upiId;
@override@JsonKey(name: 'confirm_account_number') final  String? confirmAccountNumber;
// Step 9 - Emergency contact
@override@JsonKey(name: 'emergency_contact_name') final  String? emergencyContactName;
@override@JsonKey(name: 'emergency_contact_relation') final  String? emergencyContactRelation;
@override@JsonKey(name: 'emergency_contact_phone') final  String? emergencyContactPhone;
@override@JsonKey(name: 'emergency_secondary_phone') final  String? emergencySecondaryPhone;

/// Create a copy of DriverRegistration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverRegistrationCopyWith<_DriverRegistration> get copyWith => __$DriverRegistrationCopyWithImpl<_DriverRegistration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverRegistrationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverRegistration&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.referralCode, referralCode) || other.referralCode == referralCode)&&(identical(other.languagesSpoken, languagesSpoken) || other.languagesSpoken == languagesSpoken)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.city, city) || other.city == city)&&(identical(other.pinCode, pinCode) || other.pinCode == pinCode)&&(identical(other.currentAddress, currentAddress) || other.currentAddress == currentAddress)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.licenseIssueDate, licenseIssueDate) || other.licenseIssueDate == licenseIssueDate)&&(identical(other.licenseExpiryDate, licenseExpiryDate) || other.licenseExpiryDate == licenseExpiryDate)&&(identical(other.licenseFrontUrl, licenseFrontUrl) || other.licenseFrontUrl == licenseFrontUrl)&&(identical(other.licenseBackUrl, licenseBackUrl) || other.licenseBackUrl == licenseBackUrl)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.vehicleBrand, vehicleBrand) || other.vehicleBrand == vehicleBrand)&&(identical(other.vehicleModel, vehicleModel) || other.vehicleModel == vehicleModel)&&(identical(other.vehicleColor, vehicleColor) || other.vehicleColor == vehicleColor)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.transmission, transmission) || other.transmission == transmission)&&(identical(other.rcUrl, rcUrl) || other.rcUrl == rcUrl)&&(identical(other.insuranceUrl, insuranceUrl) || other.insuranceUrl == insuranceUrl)&&(identical(other.pollutionUrl, pollutionUrl) || other.pollutionUrl == pollutionUrl)&&(identical(other.permitUrl, permitUrl) || other.permitUrl == permitUrl)&&(identical(other.fitnessUrl, fitnessUrl) || other.fitnessUrl == fitnessUrl)&&(identical(other.vehicleFrontUrl, vehicleFrontUrl) || other.vehicleFrontUrl == vehicleFrontUrl)&&(identical(other.vehicleBackUrl, vehicleBackUrl) || other.vehicleBackUrl == vehicleBackUrl)&&(identical(other.vehicleSideUrl, vehicleSideUrl) || other.vehicleSideUrl == vehicleSideUrl)&&(identical(other.vehicleLeftUrl, vehicleLeftUrl) || other.vehicleLeftUrl == vehicleLeftUrl)&&(identical(other.vehicleRightUrl, vehicleRightUrl) || other.vehicleRightUrl == vehicleRightUrl)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl)&&(identical(other.profilePhotoUrl, profilePhotoUrl) || other.profilePhotoUrl == profilePhotoUrl)&&(identical(other.aadhaarNumber, aadhaarNumber) || other.aadhaarNumber == aadhaarNumber)&&(identical(other.panNumber, panNumber) || other.panNumber == panNumber)&&(identical(other.aadhaarFrontUrl, aadhaarFrontUrl) || other.aadhaarFrontUrl == aadhaarFrontUrl)&&(identical(other.aadhaarBackUrl, aadhaarBackUrl) || other.aadhaarBackUrl == aadhaarBackUrl)&&(identical(other.panUrl, panUrl) || other.panUrl == panUrl)&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.bankBranch, bankBranch) || other.bankBranch == bankBranch)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.confirmAccountNumber, confirmAccountNumber) || other.confirmAccountNumber == confirmAccountNumber)&&(identical(other.emergencyContactName, emergencyContactName) || other.emergencyContactName == emergencyContactName)&&(identical(other.emergencyContactRelation, emergencyContactRelation) || other.emergencyContactRelation == emergencyContactRelation)&&(identical(other.emergencyContactPhone, emergencyContactPhone) || other.emergencyContactPhone == emergencyContactPhone)&&(identical(other.emergencySecondaryPhone, emergencySecondaryPhone) || other.emergencySecondaryPhone == emergencySecondaryPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,fullName,phone,email,dateOfBirth,gender,referralCode,languagesSpoken,alternatePhone,country,state,city,pinCode,currentAddress,licenseNumber,licenseIssueDate,licenseExpiryDate,licenseFrontUrl,licenseBackUrl,vehicleType,vehicleNumber,vehicleBrand,vehicleModel,vehicleColor,manufacturingYear,variant,fuelType,transmission,rcUrl,insuranceUrl,pollutionUrl,permitUrl,fitnessUrl,vehicleFrontUrl,vehicleBackUrl,vehicleSideUrl,vehicleLeftUrl,vehicleRightUrl,selfieUrl,profilePhotoUrl,aadhaarNumber,panNumber,aadhaarFrontUrl,aadhaarBackUrl,panUrl,accountHolder,accountNumber,ifsc,bankName,bankBranch,upiId,confirmAccountNumber,emergencyContactName,emergencyContactRelation,emergencyContactPhone,emergencySecondaryPhone]);

@override
String toString() {
  return 'DriverRegistration(fullName: $fullName, phone: $phone, email: $email, dateOfBirth: $dateOfBirth, gender: $gender, referralCode: $referralCode, languagesSpoken: $languagesSpoken, alternatePhone: $alternatePhone, country: $country, state: $state, city: $city, pinCode: $pinCode, currentAddress: $currentAddress, licenseNumber: $licenseNumber, licenseIssueDate: $licenseIssueDate, licenseExpiryDate: $licenseExpiryDate, licenseFrontUrl: $licenseFrontUrl, licenseBackUrl: $licenseBackUrl, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, vehicleColor: $vehicleColor, manufacturingYear: $manufacturingYear, variant: $variant, fuelType: $fuelType, transmission: $transmission, rcUrl: $rcUrl, insuranceUrl: $insuranceUrl, pollutionUrl: $pollutionUrl, permitUrl: $permitUrl, fitnessUrl: $fitnessUrl, vehicleFrontUrl: $vehicleFrontUrl, vehicleBackUrl: $vehicleBackUrl, vehicleSideUrl: $vehicleSideUrl, vehicleLeftUrl: $vehicleLeftUrl, vehicleRightUrl: $vehicleRightUrl, selfieUrl: $selfieUrl, profilePhotoUrl: $profilePhotoUrl, aadhaarNumber: $aadhaarNumber, panNumber: $panNumber, aadhaarFrontUrl: $aadhaarFrontUrl, aadhaarBackUrl: $aadhaarBackUrl, panUrl: $panUrl, accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, bankBranch: $bankBranch, upiId: $upiId, confirmAccountNumber: $confirmAccountNumber, emergencyContactName: $emergencyContactName, emergencyContactRelation: $emergencyContactRelation, emergencyContactPhone: $emergencyContactPhone, emergencySecondaryPhone: $emergencySecondaryPhone)';
}


}

/// @nodoc
abstract mixin class _$DriverRegistrationCopyWith<$Res> implements $DriverRegistrationCopyWith<$Res> {
  factory _$DriverRegistrationCopyWith(_DriverRegistration value, $Res Function(_DriverRegistration) _then) = __$DriverRegistrationCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String phone, String email,@JsonKey(name: 'date_of_birth') String? dateOfBirth, String? gender,@JsonKey(name: 'referral_code') String? referralCode,@JsonKey(name: 'languages_spoken') String? languagesSpoken,@JsonKey(name: 'alternate_phone') String? alternatePhone, String? country, String? state, String? city,@JsonKey(name: 'pin_code') String? pinCode,@JsonKey(name: 'current_address') String? currentAddress,@JsonKey(name: 'license_number') String? licenseNumber,@JsonKey(name: 'license_issue_date') String? licenseIssueDate,@JsonKey(name: 'license_expiry_date') String? licenseExpiryDate,@JsonKey(name: 'license_front_url') String? licenseFrontUrl,@JsonKey(name: 'license_back_url') String? licenseBackUrl,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber,@JsonKey(name: 'vehicle_brand') String? vehicleBrand,@JsonKey(name: 'vehicle_model') String? vehicleModel,@JsonKey(name: 'vehicle_color') String? vehicleColor,@JsonKey(name: 'manufacturing_year') int? manufacturingYear, String? variant,@JsonKey(name: 'fuel_type') String? fuelType, String? transmission,@JsonKey(name: 'rc_url') String? rcUrl,@JsonKey(name: 'insurance_url') String? insuranceUrl,@JsonKey(name: 'pollution_url') String? pollutionUrl,@JsonKey(name: 'permit_url') String? permitUrl,@JsonKey(name: 'fitness_url') String? fitnessUrl,@JsonKey(name: 'vehicle_front_url') String? vehicleFrontUrl,@JsonKey(name: 'vehicle_back_url') String? vehicleBackUrl,@JsonKey(name: 'vehicle_side_url') String? vehicleSideUrl,@JsonKey(name: 'vehicle_left_url') String? vehicleLeftUrl,@JsonKey(name: 'vehicle_right_url') String? vehicleRightUrl,@JsonKey(name: 'selfie_url') String? selfieUrl,@JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,@JsonKey(name: 'aadhaar_number') String? aadhaarNumber,@JsonKey(name: 'pan_number') String? panNumber,@JsonKey(name: 'aadhaar_front_url') String? aadhaarFrontUrl,@JsonKey(name: 'aadhaar_back_url') String? aadhaarBackUrl,@JsonKey(name: 'pan_url') String? panUrl,@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'bank_branch') String? bankBranch,@JsonKey(name: 'upi_id') String? upiId,@JsonKey(name: 'confirm_account_number') String? confirmAccountNumber,@JsonKey(name: 'emergency_contact_name') String? emergencyContactName,@JsonKey(name: 'emergency_contact_relation') String? emergencyContactRelation,@JsonKey(name: 'emergency_contact_phone') String? emergencyContactPhone,@JsonKey(name: 'emergency_secondary_phone') String? emergencySecondaryPhone
});




}
/// @nodoc
class __$DriverRegistrationCopyWithImpl<$Res>
    implements _$DriverRegistrationCopyWith<$Res> {
  __$DriverRegistrationCopyWithImpl(this._self, this._then);

  final _DriverRegistration _self;
  final $Res Function(_DriverRegistration) _then;

/// Create a copy of DriverRegistration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = null,Object? email = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? referralCode = freezed,Object? languagesSpoken = freezed,Object? alternatePhone = freezed,Object? country = freezed,Object? state = freezed,Object? city = freezed,Object? pinCode = freezed,Object? currentAddress = freezed,Object? licenseNumber = freezed,Object? licenseIssueDate = freezed,Object? licenseExpiryDate = freezed,Object? licenseFrontUrl = freezed,Object? licenseBackUrl = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? vehicleBrand = freezed,Object? vehicleModel = freezed,Object? vehicleColor = freezed,Object? manufacturingYear = freezed,Object? variant = freezed,Object? fuelType = freezed,Object? transmission = freezed,Object? rcUrl = freezed,Object? insuranceUrl = freezed,Object? pollutionUrl = freezed,Object? permitUrl = freezed,Object? fitnessUrl = freezed,Object? vehicleFrontUrl = freezed,Object? vehicleBackUrl = freezed,Object? vehicleSideUrl = freezed,Object? vehicleLeftUrl = freezed,Object? vehicleRightUrl = freezed,Object? selfieUrl = freezed,Object? profilePhotoUrl = freezed,Object? aadhaarNumber = freezed,Object? panNumber = freezed,Object? aadhaarFrontUrl = freezed,Object? aadhaarBackUrl = freezed,Object? panUrl = freezed,Object? accountHolder = freezed,Object? accountNumber = freezed,Object? ifsc = freezed,Object? bankName = freezed,Object? bankBranch = freezed,Object? upiId = freezed,Object? confirmAccountNumber = freezed,Object? emergencyContactName = freezed,Object? emergencyContactRelation = freezed,Object? emergencyContactPhone = freezed,Object? emergencySecondaryPhone = freezed,}) {
  return _then(_DriverRegistration(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,referralCode: freezed == referralCode ? _self.referralCode : referralCode // ignore: cast_nullable_to_non_nullable
as String?,languagesSpoken: freezed == languagesSpoken ? _self.languagesSpoken : languagesSpoken // ignore: cast_nullable_to_non_nullable
as String?,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,pinCode: freezed == pinCode ? _self.pinCode : pinCode // ignore: cast_nullable_to_non_nullable
as String?,currentAddress: freezed == currentAddress ? _self.currentAddress : currentAddress // ignore: cast_nullable_to_non_nullable
as String?,licenseNumber: freezed == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String?,licenseIssueDate: freezed == licenseIssueDate ? _self.licenseIssueDate : licenseIssueDate // ignore: cast_nullable_to_non_nullable
as String?,licenseExpiryDate: freezed == licenseExpiryDate ? _self.licenseExpiryDate : licenseExpiryDate // ignore: cast_nullable_to_non_nullable
as String?,licenseFrontUrl: freezed == licenseFrontUrl ? _self.licenseFrontUrl : licenseFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,licenseBackUrl: freezed == licenseBackUrl ? _self.licenseBackUrl : licenseBackUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,vehicleBrand: freezed == vehicleBrand ? _self.vehicleBrand : vehicleBrand // ignore: cast_nullable_to_non_nullable
as String?,vehicleModel: freezed == vehicleModel ? _self.vehicleModel : vehicleModel // ignore: cast_nullable_to_non_nullable
as String?,vehicleColor: freezed == vehicleColor ? _self.vehicleColor : vehicleColor // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as int?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,fuelType: freezed == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,rcUrl: freezed == rcUrl ? _self.rcUrl : rcUrl // ignore: cast_nullable_to_non_nullable
as String?,insuranceUrl: freezed == insuranceUrl ? _self.insuranceUrl : insuranceUrl // ignore: cast_nullable_to_non_nullable
as String?,pollutionUrl: freezed == pollutionUrl ? _self.pollutionUrl : pollutionUrl // ignore: cast_nullable_to_non_nullable
as String?,permitUrl: freezed == permitUrl ? _self.permitUrl : permitUrl // ignore: cast_nullable_to_non_nullable
as String?,fitnessUrl: freezed == fitnessUrl ? _self.fitnessUrl : fitnessUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleFrontUrl: freezed == vehicleFrontUrl ? _self.vehicleFrontUrl : vehicleFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleBackUrl: freezed == vehicleBackUrl ? _self.vehicleBackUrl : vehicleBackUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleSideUrl: freezed == vehicleSideUrl ? _self.vehicleSideUrl : vehicleSideUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleLeftUrl: freezed == vehicleLeftUrl ? _self.vehicleLeftUrl : vehicleLeftUrl // ignore: cast_nullable_to_non_nullable
as String?,vehicleRightUrl: freezed == vehicleRightUrl ? _self.vehicleRightUrl : vehicleRightUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieUrl: freezed == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String?,profilePhotoUrl: freezed == profilePhotoUrl ? _self.profilePhotoUrl : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,aadhaarNumber: freezed == aadhaarNumber ? _self.aadhaarNumber : aadhaarNumber // ignore: cast_nullable_to_non_nullable
as String?,panNumber: freezed == panNumber ? _self.panNumber : panNumber // ignore: cast_nullable_to_non_nullable
as String?,aadhaarFrontUrl: freezed == aadhaarFrontUrl ? _self.aadhaarFrontUrl : aadhaarFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,aadhaarBackUrl: freezed == aadhaarBackUrl ? _self.aadhaarBackUrl : aadhaarBackUrl // ignore: cast_nullable_to_non_nullable
as String?,panUrl: freezed == panUrl ? _self.panUrl : panUrl // ignore: cast_nullable_to_non_nullable
as String?,accountHolder: freezed == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,ifsc: freezed == ifsc ? _self.ifsc : ifsc // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,bankBranch: freezed == bankBranch ? _self.bankBranch : bankBranch // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,confirmAccountNumber: freezed == confirmAccountNumber ? _self.confirmAccountNumber : confirmAccountNumber // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactName: freezed == emergencyContactName ? _self.emergencyContactName : emergencyContactName // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactRelation: freezed == emergencyContactRelation ? _self.emergencyContactRelation : emergencyContactRelation // ignore: cast_nullable_to_non_nullable
as String?,emergencyContactPhone: freezed == emergencyContactPhone ? _self.emergencyContactPhone : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
as String?,emergencySecondaryPhone: freezed == emergencySecondaryPhone ? _self.emergencySecondaryPhone : emergencySecondaryPhone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DocumentInfo {

 String get id; String get type; String get status;@JsonKey(name: 'document_url') String? get documentUrl;@JsonKey(name: 'expiry_date') String? get expiryDate;@JsonKey(name: 'is_expiring_soon') bool get isExpiringSoon;
/// Create a copy of DocumentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentInfoCopyWith<DocumentInfo> get copyWith => _$DocumentInfoCopyWithImpl<DocumentInfo>(this as DocumentInfo, _$identity);

  /// Serializes this DocumentInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.documentUrl, documentUrl) || other.documentUrl == documentUrl)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.isExpiringSoon, isExpiringSoon) || other.isExpiringSoon == isExpiringSoon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,documentUrl,expiryDate,isExpiringSoon);

@override
String toString() {
  return 'DocumentInfo(id: $id, type: $type, status: $status, documentUrl: $documentUrl, expiryDate: $expiryDate, isExpiringSoon: $isExpiringSoon)';
}


}

/// @nodoc
abstract mixin class $DocumentInfoCopyWith<$Res>  {
  factory $DocumentInfoCopyWith(DocumentInfo value, $Res Function(DocumentInfo) _then) = _$DocumentInfoCopyWithImpl;
@useResult
$Res call({
 String id, String type, String status,@JsonKey(name: 'document_url') String? documentUrl,@JsonKey(name: 'expiry_date') String? expiryDate,@JsonKey(name: 'is_expiring_soon') bool isExpiringSoon
});




}
/// @nodoc
class _$DocumentInfoCopyWithImpl<$Res>
    implements $DocumentInfoCopyWith<$Res> {
  _$DocumentInfoCopyWithImpl(this._self, this._then);

  final DocumentInfo _self;
  final $Res Function(DocumentInfo) _then;

/// Create a copy of DocumentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? documentUrl = freezed,Object? expiryDate = freezed,Object? isExpiringSoon = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documentUrl: freezed == documentUrl ? _self.documentUrl : documentUrl // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,isExpiringSoon: null == isExpiringSoon ? _self.isExpiringSoon : isExpiringSoon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentInfo].
extension DocumentInfoPatterns on DocumentInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentInfo value)  $default,){
final _that = this;
switch (_that) {
case _DocumentInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String status, @JsonKey(name: 'document_url')  String? documentUrl, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'is_expiring_soon')  bool isExpiringSoon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentInfo() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.documentUrl,_that.expiryDate,_that.isExpiringSoon);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String status, @JsonKey(name: 'document_url')  String? documentUrl, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'is_expiring_soon')  bool isExpiringSoon)  $default,) {final _that = this;
switch (_that) {
case _DocumentInfo():
return $default(_that.id,_that.type,_that.status,_that.documentUrl,_that.expiryDate,_that.isExpiringSoon);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String status, @JsonKey(name: 'document_url')  String? documentUrl, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'is_expiring_soon')  bool isExpiringSoon)?  $default,) {final _that = this;
switch (_that) {
case _DocumentInfo() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.documentUrl,_that.expiryDate,_that.isExpiringSoon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentInfo implements DocumentInfo {
  const _DocumentInfo({required this.id, required this.type, required this.status, @JsonKey(name: 'document_url') this.documentUrl, @JsonKey(name: 'expiry_date') this.expiryDate, @JsonKey(name: 'is_expiring_soon') this.isExpiringSoon = false});
  factory _DocumentInfo.fromJson(Map<String, dynamic> json) => _$DocumentInfoFromJson(json);

@override final  String id;
@override final  String type;
@override final  String status;
@override@JsonKey(name: 'document_url') final  String? documentUrl;
@override@JsonKey(name: 'expiry_date') final  String? expiryDate;
@override@JsonKey(name: 'is_expiring_soon') final  bool isExpiringSoon;

/// Create a copy of DocumentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentInfoCopyWith<_DocumentInfo> get copyWith => __$DocumentInfoCopyWithImpl<_DocumentInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.documentUrl, documentUrl) || other.documentUrl == documentUrl)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.isExpiringSoon, isExpiringSoon) || other.isExpiringSoon == isExpiringSoon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,documentUrl,expiryDate,isExpiringSoon);

@override
String toString() {
  return 'DocumentInfo(id: $id, type: $type, status: $status, documentUrl: $documentUrl, expiryDate: $expiryDate, isExpiringSoon: $isExpiringSoon)';
}


}

/// @nodoc
abstract mixin class _$DocumentInfoCopyWith<$Res> implements $DocumentInfoCopyWith<$Res> {
  factory _$DocumentInfoCopyWith(_DocumentInfo value, $Res Function(_DocumentInfo) _then) = __$DocumentInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String status,@JsonKey(name: 'document_url') String? documentUrl,@JsonKey(name: 'expiry_date') String? expiryDate,@JsonKey(name: 'is_expiring_soon') bool isExpiringSoon
});




}
/// @nodoc
class __$DocumentInfoCopyWithImpl<$Res>
    implements _$DocumentInfoCopyWith<$Res> {
  __$DocumentInfoCopyWithImpl(this._self, this._then);

  final _DocumentInfo _self;
  final $Res Function(_DocumentInfo) _then;

/// Create a copy of DocumentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? documentUrl = freezed,Object? expiryDate = freezed,Object? isExpiringSoon = null,}) {
  return _then(_DocumentInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,documentUrl: freezed == documentUrl ? _self.documentUrl : documentUrl // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,isExpiringSoon: null == isExpiringSoon ? _self.isExpiringSoon : isExpiringSoon // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DashboardStats {

@JsonKey(name: 'today_earnings') double get todayEarnings;@JsonKey(name: 'wallet_balance') double get walletBalance;@JsonKey(name: 'completed_trips') int get completedTrips;@JsonKey(name: 'today_trips') int get todayTrips; double get rating;@JsonKey(name: 'acceptance_rate') double get acceptanceRate;@JsonKey(name: 'cancellation_rate') double get cancellationRate;@JsonKey(name: 'weekly_trips') int get weeklyTrips;@JsonKey(name: 'monthly_trips') int get monthlyTrips;@JsonKey(name: 'cancelled_trips') int get cancelledTrips;@JsonKey(name: 'online_hours') double get onlineHours;@JsonKey(name: 'current_location') String? get currentLocation;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance)&&(identical(other.completedTrips, completedTrips) || other.completedTrips == completedTrips)&&(identical(other.todayTrips, todayTrips) || other.todayTrips == todayTrips)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.cancellationRate, cancellationRate) || other.cancellationRate == cancellationRate)&&(identical(other.weeklyTrips, weeklyTrips) || other.weeklyTrips == weeklyTrips)&&(identical(other.monthlyTrips, monthlyTrips) || other.monthlyTrips == monthlyTrips)&&(identical(other.cancelledTrips, cancelledTrips) || other.cancelledTrips == cancelledTrips)&&(identical(other.onlineHours, onlineHours) || other.onlineHours == onlineHours)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,todayEarnings,walletBalance,completedTrips,todayTrips,rating,acceptanceRate,cancellationRate,weeklyTrips,monthlyTrips,cancelledTrips,onlineHours,currentLocation);

@override
String toString() {
  return 'DashboardStats(todayEarnings: $todayEarnings, walletBalance: $walletBalance, completedTrips: $completedTrips, todayTrips: $todayTrips, rating: $rating, acceptanceRate: $acceptanceRate, cancellationRate: $cancellationRate, weeklyTrips: $weeklyTrips, monthlyTrips: $monthlyTrips, cancelledTrips: $cancelledTrips, onlineHours: $onlineHours, currentLocation: $currentLocation)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'today_earnings') double todayEarnings,@JsonKey(name: 'wallet_balance') double walletBalance,@JsonKey(name: 'completed_trips') int completedTrips,@JsonKey(name: 'today_trips') int todayTrips, double rating,@JsonKey(name: 'acceptance_rate') double acceptanceRate,@JsonKey(name: 'cancellation_rate') double cancellationRate,@JsonKey(name: 'weekly_trips') int weeklyTrips,@JsonKey(name: 'monthly_trips') int monthlyTrips,@JsonKey(name: 'cancelled_trips') int cancelledTrips,@JsonKey(name: 'online_hours') double onlineHours,@JsonKey(name: 'current_location') String? currentLocation
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todayEarnings = null,Object? walletBalance = null,Object? completedTrips = null,Object? todayTrips = null,Object? rating = null,Object? acceptanceRate = null,Object? cancellationRate = null,Object? weeklyTrips = null,Object? monthlyTrips = null,Object? cancelledTrips = null,Object? onlineHours = null,Object? currentLocation = freezed,}) {
  return _then(_self.copyWith(
todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as double,completedTrips: null == completedTrips ? _self.completedTrips : completedTrips // ignore: cast_nullable_to_non_nullable
as int,todayTrips: null == todayTrips ? _self.todayTrips : todayTrips // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,acceptanceRate: null == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as double,cancellationRate: null == cancellationRate ? _self.cancellationRate : cancellationRate // ignore: cast_nullable_to_non_nullable
as double,weeklyTrips: null == weeklyTrips ? _self.weeklyTrips : weeklyTrips // ignore: cast_nullable_to_non_nullable
as int,monthlyTrips: null == monthlyTrips ? _self.monthlyTrips : monthlyTrips // ignore: cast_nullable_to_non_nullable
as int,cancelledTrips: null == cancelledTrips ? _self.cancelledTrips : cancelledTrips // ignore: cast_nullable_to_non_nullable
as int,onlineHours: null == onlineHours ? _self.onlineHours : onlineHours // ignore: cast_nullable_to_non_nullable
as double,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'wallet_balance')  double walletBalance, @JsonKey(name: 'completed_trips')  int completedTrips, @JsonKey(name: 'today_trips')  int todayTrips,  double rating, @JsonKey(name: 'acceptance_rate')  double acceptanceRate, @JsonKey(name: 'cancellation_rate')  double cancellationRate, @JsonKey(name: 'weekly_trips')  int weeklyTrips, @JsonKey(name: 'monthly_trips')  int monthlyTrips, @JsonKey(name: 'cancelled_trips')  int cancelledTrips, @JsonKey(name: 'online_hours')  double onlineHours, @JsonKey(name: 'current_location')  String? currentLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.todayEarnings,_that.walletBalance,_that.completedTrips,_that.todayTrips,_that.rating,_that.acceptanceRate,_that.cancellationRate,_that.weeklyTrips,_that.monthlyTrips,_that.cancelledTrips,_that.onlineHours,_that.currentLocation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'wallet_balance')  double walletBalance, @JsonKey(name: 'completed_trips')  int completedTrips, @JsonKey(name: 'today_trips')  int todayTrips,  double rating, @JsonKey(name: 'acceptance_rate')  double acceptanceRate, @JsonKey(name: 'cancellation_rate')  double cancellationRate, @JsonKey(name: 'weekly_trips')  int weeklyTrips, @JsonKey(name: 'monthly_trips')  int monthlyTrips, @JsonKey(name: 'cancelled_trips')  int cancelledTrips, @JsonKey(name: 'online_hours')  double onlineHours, @JsonKey(name: 'current_location')  String? currentLocation)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.todayEarnings,_that.walletBalance,_that.completedTrips,_that.todayTrips,_that.rating,_that.acceptanceRate,_that.cancellationRate,_that.weeklyTrips,_that.monthlyTrips,_that.cancelledTrips,_that.onlineHours,_that.currentLocation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'wallet_balance')  double walletBalance, @JsonKey(name: 'completed_trips')  int completedTrips, @JsonKey(name: 'today_trips')  int todayTrips,  double rating, @JsonKey(name: 'acceptance_rate')  double acceptanceRate, @JsonKey(name: 'cancellation_rate')  double cancellationRate, @JsonKey(name: 'weekly_trips')  int weeklyTrips, @JsonKey(name: 'monthly_trips')  int monthlyTrips, @JsonKey(name: 'cancelled_trips')  int cancelledTrips, @JsonKey(name: 'online_hours')  double onlineHours, @JsonKey(name: 'current_location')  String? currentLocation)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.todayEarnings,_that.walletBalance,_that.completedTrips,_that.todayTrips,_that.rating,_that.acceptanceRate,_that.cancellationRate,_that.weeklyTrips,_that.monthlyTrips,_that.cancelledTrips,_that.onlineHours,_that.currentLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStats implements DashboardStats {
  const _DashboardStats({@JsonKey(name: 'today_earnings') this.todayEarnings = 0, @JsonKey(name: 'wallet_balance') this.walletBalance = 0, @JsonKey(name: 'completed_trips') this.completedTrips = 0, @JsonKey(name: 'today_trips') this.todayTrips = 0, this.rating = 4.5, @JsonKey(name: 'acceptance_rate') this.acceptanceRate = 0, @JsonKey(name: 'cancellation_rate') this.cancellationRate = 0, @JsonKey(name: 'weekly_trips') this.weeklyTrips = 0, @JsonKey(name: 'monthly_trips') this.monthlyTrips = 0, @JsonKey(name: 'cancelled_trips') this.cancelledTrips = 0, @JsonKey(name: 'online_hours') this.onlineHours = 0, @JsonKey(name: 'current_location') this.currentLocation});
  factory _DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);

@override@JsonKey(name: 'today_earnings') final  double todayEarnings;
@override@JsonKey(name: 'wallet_balance') final  double walletBalance;
@override@JsonKey(name: 'completed_trips') final  int completedTrips;
@override@JsonKey(name: 'today_trips') final  int todayTrips;
@override@JsonKey() final  double rating;
@override@JsonKey(name: 'acceptance_rate') final  double acceptanceRate;
@override@JsonKey(name: 'cancellation_rate') final  double cancellationRate;
@override@JsonKey(name: 'weekly_trips') final  int weeklyTrips;
@override@JsonKey(name: 'monthly_trips') final  int monthlyTrips;
@override@JsonKey(name: 'cancelled_trips') final  int cancelledTrips;
@override@JsonKey(name: 'online_hours') final  double onlineHours;
@override@JsonKey(name: 'current_location') final  String? currentLocation;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance)&&(identical(other.completedTrips, completedTrips) || other.completedTrips == completedTrips)&&(identical(other.todayTrips, todayTrips) || other.todayTrips == todayTrips)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.acceptanceRate, acceptanceRate) || other.acceptanceRate == acceptanceRate)&&(identical(other.cancellationRate, cancellationRate) || other.cancellationRate == cancellationRate)&&(identical(other.weeklyTrips, weeklyTrips) || other.weeklyTrips == weeklyTrips)&&(identical(other.monthlyTrips, monthlyTrips) || other.monthlyTrips == monthlyTrips)&&(identical(other.cancelledTrips, cancelledTrips) || other.cancelledTrips == cancelledTrips)&&(identical(other.onlineHours, onlineHours) || other.onlineHours == onlineHours)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,todayEarnings,walletBalance,completedTrips,todayTrips,rating,acceptanceRate,cancellationRate,weeklyTrips,monthlyTrips,cancelledTrips,onlineHours,currentLocation);

@override
String toString() {
  return 'DashboardStats(todayEarnings: $todayEarnings, walletBalance: $walletBalance, completedTrips: $completedTrips, todayTrips: $todayTrips, rating: $rating, acceptanceRate: $acceptanceRate, cancellationRate: $cancellationRate, weeklyTrips: $weeklyTrips, monthlyTrips: $monthlyTrips, cancelledTrips: $cancelledTrips, onlineHours: $onlineHours, currentLocation: $currentLocation)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'today_earnings') double todayEarnings,@JsonKey(name: 'wallet_balance') double walletBalance,@JsonKey(name: 'completed_trips') int completedTrips,@JsonKey(name: 'today_trips') int todayTrips, double rating,@JsonKey(name: 'acceptance_rate') double acceptanceRate,@JsonKey(name: 'cancellation_rate') double cancellationRate,@JsonKey(name: 'weekly_trips') int weeklyTrips,@JsonKey(name: 'monthly_trips') int monthlyTrips,@JsonKey(name: 'cancelled_trips') int cancelledTrips,@JsonKey(name: 'online_hours') double onlineHours,@JsonKey(name: 'current_location') String? currentLocation
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todayEarnings = null,Object? walletBalance = null,Object? completedTrips = null,Object? todayTrips = null,Object? rating = null,Object? acceptanceRate = null,Object? cancellationRate = null,Object? weeklyTrips = null,Object? monthlyTrips = null,Object? cancelledTrips = null,Object? onlineHours = null,Object? currentLocation = freezed,}) {
  return _then(_DashboardStats(
todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as double,completedTrips: null == completedTrips ? _self.completedTrips : completedTrips // ignore: cast_nullable_to_non_nullable
as int,todayTrips: null == todayTrips ? _self.todayTrips : todayTrips // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,acceptanceRate: null == acceptanceRate ? _self.acceptanceRate : acceptanceRate // ignore: cast_nullable_to_non_nullable
as double,cancellationRate: null == cancellationRate ? _self.cancellationRate : cancellationRate // ignore: cast_nullable_to_non_nullable
as double,weeklyTrips: null == weeklyTrips ? _self.weeklyTrips : weeklyTrips // ignore: cast_nullable_to_non_nullable
as int,monthlyTrips: null == monthlyTrips ? _self.monthlyTrips : monthlyTrips // ignore: cast_nullable_to_non_nullable
as int,cancelledTrips: null == cancelledTrips ? _self.cancelledTrips : cancelledTrips // ignore: cast_nullable_to_non_nullable
as int,onlineHours: null == onlineHours ? _self.onlineHours : onlineHours // ignore: cast_nullable_to_non_nullable
as double,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SupportTicket {

 String get id; String get subject; String get status;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<SupportTicket> get copyWith => _$SupportTicketCopyWithImpl<SupportTicket>(this as SupportTicket, _$identity);

  /// Serializes this SupportTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,status,createdAt);

@override
String toString() {
  return 'SupportTicket(id: $id, subject: $subject, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupportTicketCopyWith<$Res>  {
  factory $SupportTicketCopyWith(SupportTicket value, $Res Function(SupportTicket) _then) = _$SupportTicketCopyWithImpl;
@useResult
$Res call({
 String id, String subject, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$SupportTicketCopyWithImpl<$Res>
    implements $SupportTicketCopyWith<$Res> {
  _$SupportTicketCopyWithImpl(this._self, this._then);

  final SupportTicket _self;
  final $Res Function(SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subject = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTicket].
extension SupportTicketPatterns on SupportTicket {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTicket value)  $default,){
final _that = this;
switch (_that) {
case _SupportTicket():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTicket value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subject,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.subject,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subject,  String status, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _SupportTicket():
return $default(_that.id,_that.subject,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subject,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.subject,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupportTicket implements SupportTicket {
  const _SupportTicket({required this.id, required this.subject, required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);

@override final  String id;
@override final  String subject;
@override final  String status;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTicketCopyWith<_SupportTicket> get copyWith => __$SupportTicketCopyWithImpl<_SupportTicket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportTicketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,status,createdAt);

@override
String toString() {
  return 'SupportTicket(id: $id, subject: $subject, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupportTicketCopyWith<$Res> implements $SupportTicketCopyWith<$Res> {
  factory _$SupportTicketCopyWith(_SupportTicket value, $Res Function(_SupportTicket) _then) = __$SupportTicketCopyWithImpl;
@override @useResult
$Res call({
 String id, String subject, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$SupportTicketCopyWithImpl<$Res>
    implements _$SupportTicketCopyWith<$Res> {
  __$SupportTicketCopyWithImpl(this._self, this._then);

  final _SupportTicket _self;
  final $Res Function(_SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subject = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_SupportTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FaqItem {

 String get id; String get question; String get answer; String? get category;
/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaqItemCopyWith<FaqItem> get copyWith => _$FaqItemCopyWithImpl<FaqItem>(this as FaqItem, _$identity);

  /// Serializes this FaqItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaqItem&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,answer,category);

@override
String toString() {
  return 'FaqItem(id: $id, question: $question, answer: $answer, category: $category)';
}


}

/// @nodoc
abstract mixin class $FaqItemCopyWith<$Res>  {
  factory $FaqItemCopyWith(FaqItem value, $Res Function(FaqItem) _then) = _$FaqItemCopyWithImpl;
@useResult
$Res call({
 String id, String question, String answer, String? category
});




}
/// @nodoc
class _$FaqItemCopyWithImpl<$Res>
    implements $FaqItemCopyWith<$Res> {
  _$FaqItemCopyWithImpl(this._self, this._then);

  final FaqItem _self;
  final $Res Function(FaqItem) _then;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? question = null,Object? answer = null,Object? category = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FaqItem].
extension FaqItemPatterns on FaqItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaqItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaqItem value)  $default,){
final _that = this;
switch (_that) {
case _FaqItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaqItem value)?  $default,){
final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String question,  String answer,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that.id,_that.question,_that.answer,_that.category);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String question,  String answer,  String? category)  $default,) {final _that = this;
switch (_that) {
case _FaqItem():
return $default(_that.id,_that.question,_that.answer,_that.category);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String question,  String answer,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _FaqItem() when $default != null:
return $default(_that.id,_that.question,_that.answer,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FaqItem implements FaqItem {
  const _FaqItem({required this.id, required this.question, required this.answer, this.category});
  factory _FaqItem.fromJson(Map<String, dynamic> json) => _$FaqItemFromJson(json);

@override final  String id;
@override final  String question;
@override final  String answer;
@override final  String? category;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaqItemCopyWith<_FaqItem> get copyWith => __$FaqItemCopyWithImpl<_FaqItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FaqItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaqItem&&(identical(other.id, id) || other.id == id)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,question,answer,category);

@override
String toString() {
  return 'FaqItem(id: $id, question: $question, answer: $answer, category: $category)';
}


}

/// @nodoc
abstract mixin class _$FaqItemCopyWith<$Res> implements $FaqItemCopyWith<$Res> {
  factory _$FaqItemCopyWith(_FaqItem value, $Res Function(_FaqItem) _then) = __$FaqItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String question, String answer, String? category
});




}
/// @nodoc
class __$FaqItemCopyWithImpl<$Res>
    implements _$FaqItemCopyWith<$Res> {
  __$FaqItemCopyWithImpl(this._self, this._then);

  final _FaqItem _self;
  final $Res Function(_FaqItem) _then;

/// Create a copy of FaqItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? question = null,Object? answer = null,Object? category = freezed,}) {
  return _then(_FaqItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EmergencyContact {

 String get id; String get name; String get phone; String? get relation;
/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmergencyContactCopyWith<EmergencyContact> get copyWith => _$EmergencyContactCopyWithImpl<EmergencyContact>(this as EmergencyContact, _$identity);

  /// Serializes this EmergencyContact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.relation, relation) || other.relation == relation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,relation);

@override
String toString() {
  return 'EmergencyContact(id: $id, name: $name, phone: $phone, relation: $relation)';
}


}

/// @nodoc
abstract mixin class $EmergencyContactCopyWith<$Res>  {
  factory $EmergencyContactCopyWith(EmergencyContact value, $Res Function(EmergencyContact) _then) = _$EmergencyContactCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone, String? relation
});




}
/// @nodoc
class _$EmergencyContactCopyWithImpl<$Res>
    implements $EmergencyContactCopyWith<$Res> {
  _$EmergencyContactCopyWithImpl(this._self, this._then);

  final EmergencyContact _self;
  final $Res Function(EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? relation = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,relation: freezed == relation ? _self.relation : relation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmergencyContact].
extension EmergencyContactPatterns on EmergencyContact {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmergencyContact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmergencyContact value)  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmergencyContact value)?  $default,){
final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? relation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.relation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? relation)  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact():
return $default(_that.id,_that.name,_that.phone,_that.relation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone,  String? relation)?  $default,) {final _that = this;
switch (_that) {
case _EmergencyContact() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.relation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmergencyContact implements EmergencyContact {
  const _EmergencyContact({required this.id, required this.name, required this.phone, this.relation});
  factory _EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);

@override final  String id;
@override final  String name;
@override final  String phone;
@override final  String? relation;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmergencyContactCopyWith<_EmergencyContact> get copyWith => __$EmergencyContactCopyWithImpl<_EmergencyContact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmergencyContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmergencyContact&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.relation, relation) || other.relation == relation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,relation);

@override
String toString() {
  return 'EmergencyContact(id: $id, name: $name, phone: $phone, relation: $relation)';
}


}

/// @nodoc
abstract mixin class _$EmergencyContactCopyWith<$Res> implements $EmergencyContactCopyWith<$Res> {
  factory _$EmergencyContactCopyWith(_EmergencyContact value, $Res Function(_EmergencyContact) _then) = __$EmergencyContactCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone, String? relation
});




}
/// @nodoc
class __$EmergencyContactCopyWithImpl<$Res>
    implements _$EmergencyContactCopyWith<$Res> {
  __$EmergencyContactCopyWithImpl(this._self, this._then);

  final _EmergencyContact _self;
  final $Res Function(_EmergencyContact) _then;

/// Create a copy of EmergencyContact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? relation = freezed,}) {
  return _then(_EmergencyContact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,relation: freezed == relation ? _self.relation : relation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
