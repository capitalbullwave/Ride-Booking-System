import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/onboarding_navigation.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';
import 'package:wavego_driver/widgets/onboarding/onboarding_step_scaffold.dart';

class LicenseNumberScreen extends ConsumerStatefulWidget {
  const LicenseNumberScreen({super.key});

  @override
  ConsumerState<LicenseNumberScreen> createState() =>
      _LicenseNumberScreenState();
}

class _LicenseNumberScreenState extends ConsumerState<LicenseNumberScreen> {
  late final TextEditingController _controller;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;
    final data = ref.read(registrationViewModelProvider);
    _controller.text = data.licenseNumber ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    final number = _controller.text.trim().toUpperCase();
    if (number.length < 4) {
      context.showSnackBar('Enter a valid license number', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .saveLicenseNumber(licenseNumber: number);
      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(licenseNumber: number),
          );
      if (!mounted) return;
      finishOnboardingStep(
        context,
        defaultRoute: RouteNames.documentCentre,
        useGo: true,
      );
    } catch (e) {
      if (mounted) context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: 'Driving License Number',
      subtitle: 'Enter the number printed on your license',
      actionLabel: isProfileEditMode(context) ? 'Save' : 'Continue',
      isLoading: _saving || _loading,
      actionEnabled: !_loading,
      onAction: _proceed,
      child: AppTextField(
        controller: _controller,
        label: 'License number',
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }
}
