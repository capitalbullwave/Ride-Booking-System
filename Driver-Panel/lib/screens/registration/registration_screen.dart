import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/picked_image.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/validators.dart';
import 'package:wavego_driver/data/location_data.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/media_capture_launcher.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';
import 'package:wavego_driver/widgets/forms/searchable_dropdown_field.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _stepTitles = [
    'Personal Information',
    'Profile Photo',
    'Driving License',
    'Vehicle Information',
    'Vehicle Documents',
    'Identity Verification',
    'Bank Details',
    'Emergency Contact',
    'Review & Submit',
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureAuthenticated();
      _hydrateVerifiedPhone();
    });
  }

  Future<void> _hydrateVerifiedPhone() async {
    final authPhone = ref.read(authViewModelProvider).phone;
    await ref.read(registrationViewModelProvider.notifier).hydrateVerifiedPhone(
          authPhone: authPhone,
          fetchProfilePhone: () async {
            try {
              final profile =
                  await ref.read(profileRepositoryProvider).getProfile();
              return profile.phone;
            } catch (_) {
              return null;
            }
          },
        );
  }

  Future<void> _ensureAuthenticated() async {
    final isLoggedIn = await ref.read(authRepositoryProvider).isLoggedIn();
    if (!mounted || isLoggedIn) return;

    context.go(RouteNames.phoneLogin);
    context.showSnackBar(
      'Please verify your phone number before completing registration.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(registrationStepProvider);
    final hubMode = ref.watch(registrationHubModeProvider);
    final registration = ref.watch(registrationViewModelProvider);
    final vm = ref.read(registrationViewModelProvider.notifier);
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hubMode ? _stepTitles[step] : 'Step ${step + 2}/10 · ${_stepTitles[step]}',
        ),
        leading: hubMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(registrationHubModeProvider.notifier).state = false;
                  ref.read(registrationHubPhotoNameFlowProvider.notifier).state =
                      false;
                  context.pop();
                },
              )
            : step > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      ref.read(registrationStepProvider.notifier).state = step - 1;
                    },
                  )
                : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepIndicator(
                  currentStep: step,
                  totalSteps: _stepTitles.length,
                  displayOffset: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  _stepTitles[step],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: padding,
                child: _buildStep(step, registration, vm, context, ref),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: Row(
              children: [
                if (!hubMode && step > 0)
                  Expanded(
                    child: AppButton(
                      label: 'Back',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        ref.read(registrationStepProvider.notifier).state =
                            step - 1;
                      },
                    ),
                  ),
                if (!hubMode && step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: hubMode ? 1 : 2,
                  child: AppButton(
                    label: _nextButtonLabel(step, hubMode),
                    isLoading: vm.isSubmitting,
                    onPressed: () => _handleNext(step, vm, hubMode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _nextButtonLabel(int step, bool hubMode) {
    if (hubMode) {
      final photoFlow = ref.read(registrationHubPhotoNameFlowProvider);
      if (photoFlow && step == 0) return 'Continue';
      return 'Save';
    }
    return step == _stepTitles.length - 1 ? 'Submit' : 'Next';
  }

  Future<void> _handleNext(int step, RegistrationViewModel vm, bool hubMode) async {
    if (!_formKey.currentState!.validate()) return;

    if (hubMode) {
      final photoFlow = ref.read(registrationHubPhotoNameFlowProvider);
      if (photoFlow && step == 0) {
        ref.read(registrationStepProvider.notifier).state = 1;
        ref.read(registrationHubPhotoNameFlowProvider.notifier).state = false;
        return;
      }

      ref.read(registrationHubModeProvider.notifier).state = false;
      ref.read(registrationHubPhotoNameFlowProvider.notifier).state = false;
      if (mounted) context.pop();
      return;
    }

    if (step < _stepTitles.length - 1) {
      ref.read(registrationStepProvider.notifier).state = step + 1;
      return;
    }

    final success = await vm.submit();
    if (!mounted) return;

    if (success) {
      context.go(RouteNames.verificationPending);
    } else {
      final message = vm.submitError ?? 'Submission failed';
      context.showSnackBar(message, isError: true);
      if (message.contains('Session expired') ||
          message.contains('Authentication required')) {
        context.go(RouteNames.phoneLogin);
      }
    }
  }

  Widget _buildStep(
    int step,
    DriverRegistration data,
    RegistrationViewModel vm,
    BuildContext context,
    WidgetRef ref,
  ) {
    return switch (step) {
      0 => _PersonalStep(data: data, vm: vm),
      1 => _ProfilePhotoStep(data: data, vm: vm, context: context, ref: ref),
      2 => _LicenseStep(data: data, vm: vm, context: context, ref: ref),
      3 => _VehicleStep(data: data, vm: vm, context: context, ref: ref),
      4 => _VehicleDocumentsStep(data: data, vm: vm, context: context, ref: ref),
      5 => _KycStep(data: data, vm: vm, context: context, ref: ref),
      6 => _BankStep(data: data, vm: vm),
      7 => _EmergencyContactStep(data: data, vm: vm),
      8 => _ReviewStep(data: data, onEdit: (s) {
          ref.read(registrationStepProvider.notifier).state = s;
        }),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PersonalStep extends StatefulWidget {
  const _PersonalStep({required this.data, required this.vm});

  final DriverRegistration data;
  final RegistrationViewModel vm;

  @override
  State<_PersonalStep> createState() => _PersonalStepState();
}

class _PersonalStepState extends State<_PersonalStep> {
  @override
  void initState() {
    super.initState();
    if (widget.data.country == null || widget.data.country!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.vm.updateRegistration(
          (r) => r.copyWith(country: LocationData.defaultCountry),
        );
      });
    }
  }

  String get _country =>
      (widget.data.country != null && widget.data.country!.isNotEmpty)
          ? widget.data.country!
          : LocationData.defaultCountry;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final vm = widget.vm;
    final states = LocationData.statesForCountry(_country);
    final cities = LocationData.citiesFor(_country, data.state);

    return Column(
      children: [
        _StepTextField(
          value: data.fullName,
          label: 'Full Name',
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, 'Full name'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(fullName: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.phone,
          label: 'Phone (verified)',
          keyboardType: TextInputType.phone,
          readOnly: true,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Phone not verified. Please log in again.' : null,
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.email,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(email: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.dateOfBirth,
          label: 'Date of Birth',
          readOnly: true,
          validator: (v) => Validators.required(v, 'Date of birth'),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1960),
              lastDate: DateTime.now().subtract(const Duration(days: 6570)),
            );
            if (date != null) {
              vm.updateRegistration(
                (r) => r.copyWith(
                  dateOfBirth: date.toIso8601String().split('T').first,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: data.gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: AppConstants.genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(gender: v)),
          validator: (v) => Validators.required(v, 'Gender'),
        ),
        const SizedBox(height: 16),
        SearchableDropdownField(
          label: 'Country',
          value: _country,
          options: LocationData.countries,
          searchHint: 'Search country...',
          validator: (v) => Validators.required(v, 'Country'),
          onChanged: (country) => vm.updateRegistration(
            (r) => r.copyWith(country: country, state: null, city: null),
          ),
        ),
        const SizedBox(height: 16),
        if (states.isNotEmpty)
          SearchableDropdownField(
            label: 'State',
            value: data.state,
            options: states,
            hint: 'Select state',
            searchHint: 'Search state...',
            validator: (v) => Validators.required(v, 'State'),
            onChanged: (state) => vm.updateRegistration(
              (r) => r.copyWith(state: state, city: null),
            ),
          )
        else
          _StepTextField(
            value: data.state,
            label: 'State',
            validator: (v) => Validators.required(v, 'State'),
            onChanged: (v) => vm.updateRegistration((r) => r.copyWith(state: v)),
          ),
        const SizedBox(height: 16),
        if (cities.isNotEmpty)
          SearchableDropdownField(
            label: 'City',
            value: data.city,
            options: cities,
            enabled: data.state != null && data.state!.isNotEmpty,
            hint: data.state == null ? 'Select state first' : 'Select city',
            searchHint: 'Search city...',
            validator: (v) => Validators.required(v, 'City'),
            onChanged: (city) => vm.updateRegistration((r) => r.copyWith(city: city)),
          )
        else
          _StepTextField(
            value: data.city,
            label: 'City',
            validator: (v) => Validators.required(v, 'City'),
            onChanged: (v) => vm.updateRegistration((r) => r.copyWith(city: v)),
          ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.pinCode,
          label: 'PIN Code',
          keyboardType: TextInputType.number,
          validator: Validators.pinCode,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(pinCode: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.currentAddress,
          label: 'Current Address',
          maxLines: 3,
          validator: (v) => Validators.required(v, 'Address'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(currentAddress: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.alternatePhone,
          label: 'Alternate Number (Optional)',
          keyboardType: TextInputType.phone,
          validator: (_) => null,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(alternatePhone: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.languagesSpoken,
          label: 'Languages Spoken (comma separated)',
          validator: (v) => Validators.required(v, 'Languages'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(languagesSpoken: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.referralCode,
          label: 'Referral Code (Optional)',
          validator: (_) => null,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(referralCode: v)),
        ),
      ],
    );
  }
}

class _LicenseStep extends StatelessWidget {
  const _LicenseStep({
    required this.data,
    required this.vm,
    required this.context,
    required this.ref,
  });
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field('License Number', data.licenseNumber, (v) => vm.updateRegistration((r) => r.copyWith(licenseNumber: v)), Validators.licenseNumber),
        _dateField(
          context,
          label: 'Issue Date',
          value: data.licenseIssueDate,
          onSelected: (iso) => vm.updateRegistration((r) => r.copyWith(licenseIssueDate: iso)),
        ),
        _dateField(
          context,
          label: 'Expiry Date',
          value: data.licenseExpiryDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
          onSelected: (iso) => vm.updateRegistration((r) => r.copyWith(licenseExpiryDate: iso)),
        ),
        const SizedBox(height: 16),
        _UploadTile(label: 'License Front', uploaded: data.licenseFrontUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(licenseFrontUrl: url)))),
        _UploadTile(label: 'License Back', uploaded: data.licenseBackUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(licenseBackUrl: url)))),
      ],
    );
  }

  Widget _field(String label, String? value, ValueChanged<String> onChanged, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StepTextField(
        value: value,
        label: label,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }

  Widget _dateField(
    BuildContext context, {
    required String label,
    required String? value,
    required ValueChanged<String> onSelected,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final display = value != null && value.isNotEmpty
        ? (DateFormatter.toApiDate(value) != null
            ? DateFormatter.date(DateTime.parse(DateFormatter.toApiDate(value)!))
            : value)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StepTextField(
        value: display,
        label: label,
        readOnly: true,
        validator: (v) => Validators.required(v, label),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate ?? DateTime(1980),
            lastDate: lastDate ?? DateTime.now(),
          );
          if (date != null) {
            onSelected(date.toIso8601String().split('T').first);
          }
        },
      ),
    );
  }

  Future<void> _pick(ValueChanged<String> onUrl) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path != null) onUrl(path);
  }
}

class _VehicleStep extends StatelessWidget {
  const _VehicleStep({
    required this.data,
    required this.vm,
    required this.context,
    required this.ref,
  });
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: data.vehicleType,
          decoration: const InputDecoration(labelText: 'Vehicle Type'),
          items: AppConstants.vehicleTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(vehicleType: v)),
          validator: (v) => Validators.required(v, 'Vehicle type'),
        ),
        const SizedBox(height: 16),
        _f('Registration Number', data.vehicleNumber, (v) => vm.updateRegistration((r) => r.copyWith(vehicleNumber: v)), Validators.vehicleNumber),
        _f('Brand', data.vehicleBrand, (v) => vm.updateRegistration((r) => r.copyWith(vehicleBrand: v)), (v) => Validators.required(v, 'Brand')),
        _f('Model', data.vehicleModel, (v) => vm.updateRegistration((r) => r.copyWith(vehicleModel: v)), (v) => Validators.required(v, 'Model')),
        _f('Variant', data.variant, (v) => vm.updateRegistration((r) => r.copyWith(variant: v)), (_) => null),
        _f('Manufacturing Year', data.manufacturingYear?.toString(), (v) => vm.updateRegistration((r) => r.copyWith(manufacturingYear: int.tryParse(v)))),
        _f('Color', data.vehicleColor, (v) => vm.updateRegistration((r) => r.copyWith(vehicleColor: v)), (v) => Validators.required(v, 'Color')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: data.fuelType,
          decoration: const InputDecoration(labelText: 'Fuel Type'),
          items: AppConstants.fuelTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(fuelType: v)),
          validator: (v) => Validators.required(v, 'Fuel type'),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: data.transmission,
          decoration: const InputDecoration(labelText: 'Transmission'),
          items: AppConstants.transmissionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(transmission: v)),
          validator: (v) => Validators.required(v, 'Transmission'),
        ),
        const SizedBox(height: 16),
        Text('Vehicle Photos', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _UploadTile(label: 'Front', uploaded: data.vehicleFrontUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(vehicleFrontUrl: url)))),
        _UploadTile(label: 'Back', uploaded: data.vehicleBackUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(vehicleBackUrl: url)))),
        _UploadTile(label: 'Left Side', uploaded: data.vehicleLeftUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(vehicleLeftUrl: url)))),
        _UploadTile(label: 'Right Side', uploaded: data.vehicleRightUrl != null, onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(vehicleRightUrl: url)))),
      ],
    );
  }

  Future<void> _pick(ValueChanged<String> onUrl) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path != null) onUrl(path);
  }

  Widget _f(String label, String? value, ValueChanged<String> onChanged, [String? Function(String?)? validator]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StepTextField(
        value: value,
        label: label,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }
}

class _VehicleDocumentsStep extends StatelessWidget {
  const _VehicleDocumentsStep({
    required this.data,
    required this.vm,
    required this.context,
    required this.ref,
  });
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('Registration Certificate', data.rcUrl, (String u) => vm.updateRegistration((r) => r.copyWith(rcUrl: u))),
      ('Insurance', data.insuranceUrl, (String u) => vm.updateRegistration((r) => r.copyWith(insuranceUrl: u))),
      ('Fitness Certificate', data.fitnessUrl, (String u) => vm.updateRegistration((r) => r.copyWith(fitnessUrl: u))),
      ('Permit', data.permitUrl, (String u) => vm.updateRegistration((r) => r.copyWith(permitUrl: u))),
      ('Pollution Certificate', data.pollutionUrl, (String u) => vm.updateRegistration((r) => r.copyWith(pollutionUrl: u))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload clear photos of each document. You can replace them before submitting.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...docs.map((d) => _UploadTile(
          label: d.$1,
          uploaded: d.$2 != null,
          onTap: () async {
            final path = await MediaCaptureLauncher.showImageSourceSheet(
              context,
              ref,
              lens: CameraLensPreference.back,
            );
            if (path != null) d.$3(path);
          },
        )),
      ],
    );
  }
}

class _KycStep extends StatelessWidget {
  const _KycStep({
    required this.data,
    required this.vm,
    required this.context,
    required this.ref,
  });
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final BuildContext context;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTextField(
          value: data.aadhaarNumber,
          label: 'Aadhaar Number',
          keyboardType: TextInputType.number,
          validator: (v) => Validators.required(v, 'Aadhaar number'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(aadhaarNumber: v)),
        ),
        const SizedBox(height: 16),
        _UploadTile(
          label: 'Aadhaar Front',
          uploaded: data.aadhaarFrontUrl != null,
          onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(aadhaarFrontUrl: url))),
        ),
        _UploadTile(
          label: 'Aadhaar Back',
          uploaded: data.aadhaarBackUrl != null,
          onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(aadhaarBackUrl: url))),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.panNumber,
          label: 'PAN Number',
          textCapitalization: TextCapitalization.characters,
          validator: (v) => Validators.required(v, 'PAN number'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(panNumber: v.toUpperCase())),
        ),
        const SizedBox(height: 16),
        _UploadTile(
          label: 'PAN Card',
          uploaded: data.panUrl != null,
          onTap: () => _pick((url) => vm.updateRegistration((r) => r.copyWith(panUrl: url))),
        ),
      ],
    );
  }

  Future<void> _pick(ValueChanged<String> onUrl) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path != null) onUrl(path);
  }
}

class _EmergencyContactStep extends StatelessWidget {
  const _EmergencyContactStep({required this.data, required this.vm});
  final DriverRegistration data;
  final RegistrationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepTextField(
          value: data.emergencyContactName,
          label: 'Contact Name',
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, 'Contact name'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(emergencyContactName: v)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: data.emergencyContactRelation,
          decoration: const InputDecoration(labelText: 'Relationship'),
          items: AppConstants.relationships
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(emergencyContactRelation: v)),
          validator: (v) => Validators.required(v, 'Relationship'),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.emergencyContactPhone,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(emergencyContactPhone: v)),
        ),
        const SizedBox(height: 16),
        _StepTextField(
          value: data.emergencySecondaryPhone,
          label: 'Secondary Contact (Optional)',
          keyboardType: TextInputType.phone,
          validator: (_) => null,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(emergencySecondaryPhone: v)),
        ),
      ],
    );
  }
}

class _ProfilePhotoStep extends StatelessWidget {
  const _ProfilePhotoStep({
    required this.data,
    required this.vm,
    required this.context,
    required this.ref,
  });
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final BuildContext context;
  final WidgetRef ref;

  String? get _photoUrl => data.profilePhotoUrl ?? data.selfieUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: _photoUrl != null
              ? ClipOval(
                  child: pickedImage(
                    _photoUrl!,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.person, size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text('Profile Photo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Take a clear photo or choose from gallery. This will be shown to riders.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: _photoUrl != null ? 'Retake Photo' : 'Add Profile Photo',
          icon: Icons.camera_alt,
          onPressed: () async {
            final path = await MediaCaptureLauncher.showImageSourceSheet(
              context,
              ref,
              lens: CameraLensPreference.front,
            );
            if (path != null) {
              vm.updateRegistration(
                (r) => r.copyWith(profilePhotoUrl: path, selfieUrl: path),
              );
            }
          },
        ),
      ],
    );
  }
}

class _BankStep extends StatelessWidget {
  const _BankStep({required this.data, required this.vm});
  final DriverRegistration data;
  final RegistrationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _f('Account Holder Name', data.accountHolder, (v) => vm.updateRegistration((r) => r.copyWith(accountHolder: v))),
        _f('Bank Name', data.bankName, (v) => vm.updateRegistration((r) => r.copyWith(bankName: v))),
        _f('Account Number', data.accountNumber, (v) => vm.updateRegistration((r) => r.copyWith(accountNumber: v)), Validators.accountNumber),
        _f('Confirm Account Number', data.confirmAccountNumber, (v) => vm.updateRegistration((r) => r.copyWith(confirmAccountNumber: v)), (v) {
          if (v == null || v.isEmpty) return 'Please confirm account number';
          if (v != data.accountNumber) return 'Account numbers do not match';
          return null;
        }),
        _f('IFSC Code', data.ifsc, (v) => vm.updateRegistration((r) => r.copyWith(ifsc: v.toUpperCase())), Validators.ifsc),
        _f('Branch', data.bankBranch, (v) => vm.updateRegistration((r) => r.copyWith(bankBranch: v))),
        _f('UPI ID (Optional)', data.upiId, (v) => vm.updateRegistration((r) => r.copyWith(upiId: v)), (_) => null),
      ],
    );
  }

  Widget _f(String label, String? value, ValueChanged<String> onChanged, [String? Function(String?)? validator]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _StepTextField(
        value: value,
        label: label,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.data, required this.onEdit});
  final DriverRegistration data;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final sections = [
      (0, 'Personal', '${data.fullName}\n${data.phone}\n${data.email}\n${data.city}, ${data.state}'),
      (1, 'Profile Photo', (data.profilePhotoUrl ?? data.selfieUrl) != null ? 'Photo added' : 'Missing'),
      (2, 'License', data.licenseNumber ?? '-'),
      (3, 'Vehicle', '${data.vehicleType} · ${data.vehicleNumber}'),
      (4, 'Documents', 'RC, Insurance & certificates'),
      (5, 'KYC', 'Aadhaar · ${data.aadhaarNumber ?? '-'}'),
      (6, 'Bank', '${data.accountHolder}\n${data.bankName}'),
      (7, 'Emergency', '${data.emergencyContactName}\n${data.emergencyContactPhone}'),
    ];

    return Column(
      children: sections.map((s) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(s.$3),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => onEdit(s.$1),
          ),
        ),
      )).toList(),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.uploaded, required this.onTap});
  final String label;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(uploaded ? Icons.check_circle : Icons.upload_file, color: uploaded ? AppColors.success : AppColors.primary),
        title: Text(label),
        subtitle: Text(uploaded ? 'Uploaded' : 'Tap to upload'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Keeps a stable [TextEditingController] across parent rebuilds so typing
/// does not reset the cursor (fixes reversed/garbled text on web).
class _StepTextField extends StatefulWidget {
  const _StepTextField({
    required this.value,
    required this.label,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? value;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;

  @override
  State<_StepTextField> createState() => _StepTextFieldState();
}

class _StepTextFieldState extends State<_StepTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant _StepTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextValue = widget.value ?? '';
    if (nextValue != oldWidget.value && nextValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      label: widget.label,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly || widget.onChanged == null,
      onTap: widget.onTap,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textCapitalization: widget.textCapitalization,
    );
  }
}
