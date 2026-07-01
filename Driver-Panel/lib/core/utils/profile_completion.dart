import 'package:wavego_driver/models/registration_model.dart';

/// Estimates how complete a driver's profile/registration is (0–100).
int calculateProfileCompletion({
  DriverRegistration? registration,
  bool hasAvatar = false,
  bool isVerified = false,
}) {
  if (registration == null) return 0;

  var score = 0.0;
  const total = 12.0;

  if (registration.fullName.trim().isNotEmpty) score++;
  if (registration.email.trim().isNotEmpty) score++;
  if (registration.dateOfBirth != null) score++;
  if (registration.currentAddress != null && registration.currentAddress!.isNotEmpty) score++;
  if ((registration.profilePhotoUrl ?? registration.selfieUrl) != null) score++;
  if (registration.licenseNumber != null && registration.licenseFrontUrl != null) score++;
  if (registration.vehicleNumber != null && registration.vehicleType != null) score++;
  if (registration.rcUrl != null && registration.insuranceUrl != null) score++;
  if (registration.aadhaarNumber != null && registration.panNumber != null) score++;
  if (registration.accountNumber != null && registration.ifsc != null) score++;
  if (registration.emergencyContactPhone != null) score++;
  if (isVerified) score++;

  return ((score / total) * 100).round().clamp(0, 100);
}
