import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/validators.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const _stepTitles = [
    'Personal Info',
    'Address',
    'Driving License',
    'Vehicle Info',
    'Documents',
    'Selfie',
    'Bank Details',
    'Review',
  ];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(registrationStepProvider);
    final registration = ref.watch(registrationViewModelProvider);
    final vm = ref.read(registrationViewModelProvider.notifier);
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Registration (${step + 1}/${_stepTitles.length})'),
        leading: step > 0
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
                StepIndicator(currentStep: step, totalSteps: _stepTitles.length),
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
                child: _buildStep(step, registration, vm),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: Row(
              children: [
                if (step > 0)
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
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: step == _stepTitles.length - 1 ? 'Submit' : 'Next',
                    isLoading: vm.isSubmitting,
                    onPressed: () => _handleNext(step, vm),
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

  Future<void> _handleNext(int step, RegistrationViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    if (step < _stepTitles.length - 1) {
      ref.read(registrationStepProvider.notifier).state = step + 1;
      return;
    }

    final success = await vm.submit();
    if (!mounted) return;

    if (success) {
      context.go(RouteNames.verificationPending);
    } else {
      context.showSnackBar(vm.submitError ?? 'Submission failed', isError: true);
    }
  }

  Widget _buildStep(
    int step,
    DriverRegistration data,
    RegistrationViewModel vm,
  ) {
    return switch (step) {
      0 => _PersonalStep(data: data, vm: vm),
      1 => _AddressStep(data: data, vm: vm),
      2 => _LicenseStep(data: data, vm: vm, picker: _picker),
      3 => _VehicleStep(data: data, vm: vm),
      4 => _DocumentsStep(data: data, vm: vm, picker: _picker),
      5 => _SelfieStep(data: data, vm: vm, picker: _picker),
      6 => _BankStep(data: data, vm: vm),
      7 => _ReviewStep(data: data, onEdit: (s) {
          ref.read(registrationStepProvider.notifier).state = s;
        }),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PersonalStep extends StatelessWidget {
  const _PersonalStep({required this.data, required this.vm});

  final DriverRegistration data;
  final RegistrationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: data.fullName);
    final phoneCtrl = TextEditingController(text: data.phone);
    final emailCtrl = TextEditingController(text: data.email);
    final referralCtrl = TextEditingController(text: data.referralCode);
    String? gender = data.gender;

    return Column(
      children: [
        AppTextField(
          controller: nameCtrl,
          label: 'Full Name',
          validator: (v) => Validators.required(v, 'Full name'),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(fullName: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneCtrl,
          label: 'Phone',
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(phone: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailCtrl,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(email: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: TextEditingController(text: data.dateOfBirth),
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
                (r) => r.copyWith(dateOfBirth: date.toIso8601String().split('T').first),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: gender,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: AppConstants.genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(gender: v)),
          validator: (v) => Validators.required(v, 'Gender'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: referralCtrl,
          label: 'Referral Code (Optional)',
          onChanged: (v) => vm.updateRegistration((r) => r.copyWith(referralCode: v)),
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({required this.data, required this.vm});
  final DriverRegistration data;
  final RegistrationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field('Country', data.country, (v) => vm.updateRegistration((r) => r.copyWith(country: v))),
        _field('State', data.state, (v) => vm.updateRegistration((r) => r.copyWith(state: v))),
        _field('City', data.city, (v) => vm.updateRegistration((r) => r.copyWith(city: v))),
        _field('Pin Code', data.pinCode, (v) => vm.updateRegistration((r) => r.copyWith(pinCode: v)), validator: Validators.pinCode),
        _field('Current Address', data.currentAddress, (v) => vm.updateRegistration((r) => r.copyWith(currentAddress: v)), maxLines: 3),
      ],
    );
  }

  Widget _field(String label, String? value, ValueChanged<String> onChanged, {String? Function(String?)? validator, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        controller: TextEditingController(text: value),
        label: label,
        maxLines: maxLines,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }
}

class _LicenseStep extends StatelessWidget {
  const _LicenseStep({required this.data, required this.vm, required this.picker});
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final ImagePicker picker;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field('License Number', data.licenseNumber, (v) => vm.updateRegistration((r) => r.copyWith(licenseNumber: v)), Validators.licenseNumber),
        _field('Issue Date', data.licenseIssueDate, (v) => vm.updateRegistration((r) => r.copyWith(licenseIssueDate: v)), null),
        _field('Expiry Date', data.licenseExpiryDate, (v) => vm.updateRegistration((r) => r.copyWith(licenseExpiryDate: v)), null),
        const SizedBox(height: 16),
        _UploadTile(label: 'License Front', uploaded: data.licenseFrontUrl != null, onTap: () => _pick(vm, picker, (url) => vm.updateRegistration((r) => r.copyWith(licenseFrontUrl: url)))),
        _UploadTile(label: 'License Back', uploaded: data.licenseBackUrl != null, onTap: () => _pick(vm, picker, (url) => vm.updateRegistration((r) => r.copyWith(licenseBackUrl: url)))),
      ],
    );
  }

  Widget _field(String label, String? value, ValueChanged<String> onChanged, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        controller: TextEditingController(text: value),
        label: label,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _pick(RegistrationViewModel vm, ImagePicker picker, ValueChanged<String> onUrl) async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) onUrl(file.path);
  }
}

class _VehicleStep extends StatelessWidget {
  const _VehicleStep({required this.data, required this.vm});
  final DriverRegistration data;
  final RegistrationViewModel vm;

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
        _f('Vehicle Number', data.vehicleNumber, (v) => vm.updateRegistration((r) => r.copyWith(vehicleNumber: v)), Validators.vehicleNumber),
        _f('Brand', data.vehicleBrand, (v) => vm.updateRegistration((r) => r.copyWith(vehicleBrand: v))),
        _f('Model', data.vehicleModel, (v) => vm.updateRegistration((r) => r.copyWith(vehicleModel: v))),
        _f('Color', data.vehicleColor, (v) => vm.updateRegistration((r) => r.copyWith(vehicleColor: v))),
        _f('Manufacturing Year', data.manufacturingYear?.toString(), (v) => vm.updateRegistration((r) => r.copyWith(manufacturingYear: int.tryParse(v)))),
      ],
    );
  }

  Widget _f(String label, String? value, ValueChanged<String> onChanged, [String? Function(String?)? validator]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        controller: TextEditingController(text: value),
        label: label,
        validator: validator ?? (v) => Validators.required(v, label),
        onChanged: onChanged,
      ),
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep({required this.data, required this.vm, required this.picker});
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final ImagePicker picker;

  @override
  Widget build(BuildContext context) {
    final docs = [
      ('RC', data.rcUrl, (String u) => vm.updateRegistration((r) => r.copyWith(rcUrl: u))),
      ('Insurance', data.insuranceUrl, (String u) => vm.updateRegistration((r) => r.copyWith(insuranceUrl: u))),
      ('Pollution Certificate', data.pollutionUrl, (String u) => vm.updateRegistration((r) => r.copyWith(pollutionUrl: u))),
      ('Permit', data.permitUrl, (String u) => vm.updateRegistration((r) => r.copyWith(permitUrl: u))),
      ('Fitness Certificate', data.fitnessUrl, (String u) => vm.updateRegistration((r) => r.copyWith(fitnessUrl: u))),
      ('Vehicle Front', data.vehicleFrontUrl, (String u) => vm.updateRegistration((r) => r.copyWith(vehicleFrontUrl: u))),
      ('Vehicle Back', data.vehicleBackUrl, (String u) => vm.updateRegistration((r) => r.copyWith(vehicleBackUrl: u))),
      ('Vehicle Side', data.vehicleSideUrl, (String u) => vm.updateRegistration((r) => r.copyWith(vehicleSideUrl: u))),
    ];

    return Column(
      children: docs.map((d) => _UploadTile(
        label: d.$1,
        uploaded: d.$2 != null,
        onTap: () async {
          final file = await picker.pickImage(source: ImageSource.gallery);
          if (file != null) d.$3(file.path);
        },
      )).toList(),
    );
  }
}

class _SelfieStep extends StatelessWidget {
  const _SelfieStep({required this.data, required this.vm, required this.picker});
  final DriverRegistration data;
  final RegistrationViewModel vm;
  final ImagePicker picker;

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
          child: data.selfieUrl != null
              ? ClipOval(child: Image.asset(data.selfieUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 64)))
              : const Icon(Icons.face, size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text('Face Verification', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Take a clear selfie for identity verification', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        AppButton(
          label: data.selfieUrl != null ? 'Retake Selfie' : 'Capture Selfie',
          icon: Icons.camera_alt,
          onPressed: () async {
            final file = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
            if (file != null) vm.updateRegistration((r) => r.copyWith(selfieUrl: file.path));
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
        _f('Account Holder', data.accountHolder, (v) => vm.updateRegistration((r) => r.copyWith(accountHolder: v))),
        _f('Account Number', data.accountNumber, (v) => vm.updateRegistration((r) => r.copyWith(accountNumber: v)), Validators.accountNumber),
        _f('IFSC Code', data.ifsc, (v) => vm.updateRegistration((r) => r.copyWith(ifsc: v.toUpperCase())), Validators.ifsc),
        _f('Bank Name', data.bankName, (v) => vm.updateRegistration((r) => r.copyWith(bankName: v))),
        _f('UPI ID (Optional)', data.upiId, (v) => vm.updateRegistration((r) => r.copyWith(upiId: v)), (_) => null),
      ],
    );
  }

  Widget _f(String label, String? value, ValueChanged<String> onChanged, [String? Function(String?)? validator]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTextField(
        controller: TextEditingController(text: value),
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
      (0, 'Personal', '${data.fullName}\n${data.phone}\n${data.email}'),
      (1, 'Address', '${data.currentAddress}\n${data.city}, ${data.state} ${data.pinCode}'),
      (2, 'License', data.licenseNumber ?? '-'),
      (3, 'Vehicle', '${data.vehicleType} - ${data.vehicleNumber}'),
      (6, 'Bank', '${data.accountHolder}\n${data.bankName}'),
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
