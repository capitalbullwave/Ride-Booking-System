import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/validators.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  Country _country = Country.parse('IN');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authViewModelProvider.notifier).sendOtp(
          _phoneController.text.trim(),
          '+${_country.phoneCode}',
        );

    final state = ref.read(authViewModelProvider);
    if (state.otpState is ViewStateSuccess && mounted) {
      final devOtp = state.devOtpHint;
      if (devOtp != null && devOtp.isNotEmpty) {
        context.showSnackBar(
          'Dev OTP: $devOtp — SMS is not configured on the server.',
        );
      }
      context.push(RouteNames.otpVerification);
    } else if (state.otpState is ViewStateError && mounted) {
      context.showSnackBar(
        (state.otpState as ViewStateError).message,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.otpState is ViewStateLoading;
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Icon(Icons.phone_android, color: AppColors.primary, size: 40),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter your phone number',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send you a verification code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (country) => setState(() => _country = country),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(_country.flagEmoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text('+${_country.phoneCode}'),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _phoneController,
                        hint: 'Phone number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: Validators.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Continue',
                  isLoading: isLoading,
                  onPressed: _sendOtp,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
