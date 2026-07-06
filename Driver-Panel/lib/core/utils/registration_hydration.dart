import 'package:wavego_driver/core/utils/media_url_resolver.dart';
import 'package:wavego_driver/models/registration_model.dart';

class RegistrationHydration {
  RegistrationHydration._();

  static DriverRegistration fromSavedData(Map<String, dynamic> json) {
    final docs = json['documents'] as Map<String, dynamic>? ?? {};

    String? docUrl(String type) {
      final entry = docs[type];
      if (entry is! Map<String, dynamic>) return null;
      final url = entry['url'] as String?;
      return url == null ? null : resolveMediaUrl(url);
    }

    String? docNumber(String type) {
      final entry = docs[type];
      if (entry is! Map<String, dynamic>) return null;
      return entry['number'] as String?;
    }

    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();

    return DriverRegistration(
      fullName: fullName.isEmpty ? '' : fullName,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      profilePhotoUrl: resolveMediaUrl(json['profile_photo'] as String?),
      licenseNumber: json['license_number'] as String?,
      licenseFrontUrl: docUrl('DRIVING_LICENSE'),
      licenseBackUrl: docUrl('DRIVING_LICENSE_BACK'),
      vehicleNumber: json['vehicle_number'] as String?,
      vehicleType: json['vehicle_type_name'] as String?,
      rcUrl: docUrl('VEHICLE_RC'),
      rcBackUrl: docUrl('VEHICLE_RC_BACK'),
      insuranceUrl: docUrl('INSURANCE'),
      pollutionUrl: docUrl('POLLUTION'),
      permitUrl: docUrl('PERMIT'),
      fitnessUrl: docUrl('FITNESS'),
      vehicleFrontUrl: docUrl('VEHICLE_FRONT'),
      vehicleBackUrl: docUrl('VEHICLE_BACK'),
      vehicleSideUrl: docUrl('VEHICLE_SIDE'),
      aadhaarNumber: docNumber('AADHAAR'),
      aadhaarFrontUrl: docUrl('AADHAAR'),
      aadhaarBackUrl: docUrl('AADHAAR_BACK'),
      panNumber: docNumber('PAN'),
      panUrl: docUrl('PAN'),
    );
  }
}
