import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/utils/registration_hydration.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/providers/app_providers.dart';

class RegistrationViewModel extends StateNotifier<DriverRegistration> {
  RegistrationViewModel(
    this._profileRepository,
    this._authRepository,
    this._localStorage,
  ) : super(const DriverRegistration());

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  int currentStep = 0;
  static const int totalSteps = 9;
  bool isSubmitting = false;
  String? submitError;

  void updateRegistration(DriverRegistration Function(DriverRegistration) updater) {
    state = updater(state);
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) currentStep++;
  }

  void previousStep() {
    if (currentStep > 0) currentStep--;
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) currentStep = step;
  }

  Future<void> hydrateFromServer() async {
    try {
      final data = await _profileRepository.getRegistrationData();
      if (data.isEmpty) return;
      final hydrated = RegistrationHydration.fromSavedData(data);
      state = state.copyWith(
        fullName: hydrated.fullName.isNotEmpty ? hydrated.fullName : state.fullName,
        phone: hydrated.phone.isNotEmpty ? hydrated.phone : state.phone,
        email: hydrated.email.isNotEmpty ? hydrated.email : state.email,
        dateOfBirth: hydrated.dateOfBirth ?? state.dateOfBirth,
        gender: hydrated.gender ?? state.gender,
        city: hydrated.city ?? state.city,
        state: hydrated.state ?? state.state,
        country: hydrated.country ?? state.country,
        profilePhotoUrl: hydrated.profilePhotoUrl ?? state.profilePhotoUrl,
        licenseNumber: hydrated.licenseNumber ?? state.licenseNumber,
        licenseFrontUrl: hydrated.licenseFrontUrl ?? state.licenseFrontUrl,
        licenseBackUrl: hydrated.licenseBackUrl ?? state.licenseBackUrl,
        vehicleNumber: hydrated.vehicleNumber ?? state.vehicleNumber,
        vehicleType: hydrated.vehicleType ?? state.vehicleType,
        rcUrl: hydrated.rcUrl ?? state.rcUrl,
        aadhaarNumber: hydrated.aadhaarNumber ?? state.aadhaarNumber,
        aadhaarFrontUrl: hydrated.aadhaarFrontUrl ?? state.aadhaarFrontUrl,
        aadhaarBackUrl: hydrated.aadhaarBackUrl ?? state.aadhaarBackUrl,
        panNumber: hydrated.panNumber ?? state.panNumber,
        panUrl: hydrated.panUrl ?? state.panUrl,
      );
    } catch (_) {}
  }

  Future<void> hydrateVerifiedPhone({
    String? authPhone,
    Future<String?> Function()? fetchProfilePhone,
  }) async {
    if (state.phone.isNotEmpty) return;

    if (authPhone != null && authPhone.isNotEmpty) {
      state = state.copyWith(phone: authPhone);
      await _localStorage.setString(AppConstants.driverPhoneKey, authPhone);
      return;
    }

    final stored = await _authRepository.getVerifiedPhone();
    if (stored != null && stored.isNotEmpty) {
      state = state.copyWith(phone: stored);
      return;
    }

    if (fetchProfilePhone == null) return;
    final profilePhone = await fetchProfilePhone();
    if (profilePhone != null && profilePhone.isNotEmpty) {
      state = state.copyWith(phone: profilePhone);
      await _localStorage.setString(AppConstants.driverPhoneKey, profilePhone);
    }
  }

  Future<bool> submit() async {
    isSubmitting = true;
    submitError = null;
    try {
      if (!await _authRepository.isLoggedIn()) {
        submitError = 'Session expired. Please verify your phone number again.';
        isSubmitting = false;
        return false;
      }

      await _profileRepository.submitRegistration(state);
      await _localStorage.setBool(AppConstants.driverRegisteredKey, true);
      isSubmitting = false;
      return true;
    } catch (e) {
      submitError = e.userMessage;
      isSubmitting = false;
      return false;
    }
  }
}

final registrationViewModelProvider =
    StateNotifierProvider<RegistrationViewModel, DriverRegistration>((ref) {
  return RegistrationViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(localStorageProvider),
  );
});

final registrationStepProvider = StateProvider<int>((ref) => 0);

final registrationHubModeProvider = StateProvider<bool>((ref) => false);

final registrationHubPhotoNameFlowProvider = StateProvider<bool>((ref) => false);
