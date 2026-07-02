import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/models/registration_model.dart';

/// Maps the multi-step registration form to the backend complete-registration payload.
/// Images are embedded as base64 data URLs inside JSON (single API call).
Future<Map<String, dynamic>> buildCompleteRegistrationPayload({
  required DriverRegistration registration,
  required String vehicleTypeId,
}) async {
  final nameParts = registration.fullName.trim().split(' ');
  final firstName = nameParts.first;
  final lastName =
      nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

  final plate = (registration.vehicleNumber ?? '').trim().toUpperCase();

  final documents = <Map<String, dynamic>>[];

  Future<void> addDoc(String type, String? url, {String? number}) async {
    final dataUrl = await imagePathToDataUrl(url);
    if (dataUrl == null || dataUrl.isEmpty) return;
    documents.add({
      'document_type': type,
      'document_url': dataUrl,
      if (number != null && number.isNotEmpty) 'document_number': number,
    });
  }

  await addDoc('DRIVING_LICENSE', registration.licenseFrontUrl,
      number: registration.licenseNumber);
  await addDoc('DRIVING_LICENSE_BACK', registration.licenseBackUrl);
  await addDoc('VEHICLE_RC', registration.rcUrl);
  await addDoc('INSURANCE', registration.insuranceUrl);
  await addDoc('POLLUTION', registration.pollutionUrl);
  await addDoc('PERMIT', registration.permitUrl);
  await addDoc('FITNESS', registration.fitnessUrl);
  await addDoc('VEHICLE_FRONT', registration.vehicleFrontUrl);
  await addDoc('VEHICLE_BACK', registration.vehicleBackUrl);
  await addDoc('VEHICLE_SIDE', registration.vehicleSideUrl);
  await addDoc('VEHICLE_LEFT', registration.vehicleLeftUrl);
  await addDoc('VEHICLE_RIGHT', registration.vehicleRightUrl);
  await addDoc('AADHAAR', registration.aadhaarFrontUrl,
      number: registration.aadhaarNumber);
  await addDoc('AADHAAR_BACK', registration.aadhaarBackUrl);
  await addDoc('PAN', registration.panUrl, number: registration.panNumber);

  final profilePhoto = await imagePathToDataUrl(
    registration.profilePhotoUrl ?? registration.selfieUrl,
  );

  final brand = (registration.vehicleBrand ?? '').trim();
  final model = (registration.vehicleModel ?? '').trim();
  final color = (registration.vehicleColor ?? '').trim();
  final vehicleType = (registration.vehicleType ?? '').trim();

  final resolvedModel = model.isNotEmpty
      ? model
      : (brand.isNotEmpty
          ? brand
          : (vehicleType.isNotEmpty ? vehicleType : 'Standard'));
  final resolvedColor = color.isNotEmpty ? color : 'Not specified';

  final payload = <String, dynamic>{
    'first_name': firstName,
    'last_name': lastName,
    if (registration.email.trim().isNotEmpty) 'email': registration.email.trim(),
    if (DateFormatter.toApiDate(registration.dateOfBirth) != null)
      'date_of_birth': DateFormatter.toApiDate(registration.dateOfBirth),
    if (registration.gender != null) 'gender': registration.gender,
    if (registration.languagesSpoken != null &&
        registration.languagesSpoken!.trim().isNotEmpty)
      'languages_spoken': registration.languagesSpoken!.trim(),
    if (registration.alternatePhone != null &&
        registration.alternatePhone!.trim().isNotEmpty)
      'alternate_phone': registration.alternatePhone!.trim(),
    if (registration.currentAddress != null)
      'current_address': registration.currentAddress!.trim(),
    if (registration.city != null) 'city': registration.city!.trim(),
    if (registration.state != null) 'state': registration.state!.trim(),
    if (registration.country != null) 'country': registration.country!.trim(),
    if (registration.pinCode != null) 'pin_code': registration.pinCode!.trim(),
    'license_number': registration.licenseNumber?.trim() ?? '',
    if (DateFormatter.toApiDate(registration.licenseIssueDate) != null)
      'license_issue_date': DateFormatter.toApiDate(registration.licenseIssueDate),
    if (DateFormatter.toApiDate(registration.licenseExpiryDate) != null)
      'license_expiry_date': DateFormatter.toApiDate(registration.licenseExpiryDate),
    if (profilePhoto != null && profilePhoto.isNotEmpty)
      'profile_photo': profilePhoto,
    'vehicle': {
      'vehicle_type_id': vehicleTypeId,
      'license_plate': plate,
      'make': brand.isNotEmpty ? brand : resolvedModel,
      'model': resolvedModel,
      'color': resolvedColor,
      'year': registration.manufacturingYear ?? DateTime.now().year,
      if (registration.variant != null && registration.variant!.trim().isNotEmpty)
        'variant': registration.variant!.trim(),
      if (registration.fuelType != null) 'fuel_type': registration.fuelType,
      if (registration.transmission != null)
        'transmission': registration.transmission,
    },
    'documents': documents,
  };

  final holder = registration.accountHolder?.trim();
  final account = registration.accountNumber?.trim();
  final ifsc = registration.ifsc?.trim();
  final bankName = registration.bankName?.trim();
  if (holder != null &&
      holder.isNotEmpty &&
      account != null &&
      account.isNotEmpty &&
      ifsc != null &&
      ifsc.isNotEmpty &&
      bankName != null &&
      bankName.isNotEmpty) {
    payload['bank'] = {
      'account_holder_name': holder,
      'account_number': account,
      'ifsc_code': ifsc.toUpperCase(),
      'bank_name': bankName,
      if (registration.upiId != null && registration.upiId!.trim().isNotEmpty)
        'upi_id': registration.upiId!.trim(),
      if (registration.bankBranch != null &&
          registration.bankBranch!.trim().isNotEmpty)
        'branch': registration.bankBranch!.trim(),
    };
  }

  final emergencyName = registration.emergencyContactName?.trim();
  final emergencyPhone = registration.emergencyContactPhone?.trim();
  if (emergencyName != null &&
      emergencyName.isNotEmpty &&
      emergencyPhone != null &&
      emergencyPhone.isNotEmpty) {
    payload['emergency_contact'] = {
      'name': emergencyName,
      'phone': emergencyPhone,
      if (registration.emergencyContactRelation != null)
        'relationship': registration.emergencyContactRelation,
      if (registration.emergencySecondaryPhone != null &&
          registration.emergencySecondaryPhone!.trim().isNotEmpty)
        'secondary_phone': registration.emergencySecondaryPhone!.trim(),
    };
  }

  if (registration.referralCode != null &&
      registration.referralCode!.trim().isNotEmpty) {
    payload['referral_code'] = registration.referralCode!.trim();
  }

  return payload;
}
