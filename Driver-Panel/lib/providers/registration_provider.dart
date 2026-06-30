import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';

class RegistrationViewModel extends StateNotifier<DriverRegistration> {
  RegistrationViewModel(this._repository) : super(const DriverRegistration());

  final ProfileRepository _repository;

  int currentStep = 0;
  static const int totalSteps = 8;
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

  Future<bool> submit() async {
    isSubmitting = true;
    submitError = null;
    try {
      await _repository.submitRegistration(state);
      isSubmitting = false;
      return true;
    } catch (e) {
      submitError = e.toString();
      isSubmitting = false;
      return false;
    }
  }
}

final registrationViewModelProvider =
    StateNotifierProvider<RegistrationViewModel, DriverRegistration>((ref) {
  return RegistrationViewModel(ref.watch(profileRepositoryProvider));
});

final registrationStepProvider = StateProvider<int>((ref) => 0);
