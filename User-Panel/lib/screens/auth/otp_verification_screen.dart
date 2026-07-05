import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/responsive.dart';
import 'package:wavego_user/core/utils/view_state.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = AppConfig.otpResendSeconds;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = AppConfig.otpResendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _verifyOtp(String otp) async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await ref.read(authViewModelProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    final loginState = ref.read(authViewModelProvider).loginState;
    if (loginState is ViewStateError) {
      setState(() {
        _errorMessage = loginState.message;
        _isLoading = false;
      });
      return;
    }

    if (loginState is ViewStateSuccess && mounted) {
      refreshUserProfile(ref);

      final response = (loginState as ViewStateSuccess<LoginResponse?>).data;
      final needsSetup = response?.user?.isPlaceholderName ?? true;

      context.go(needsSetup ? RouteNames.createProfile : RouteNames.home);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    final authState = ref.read(authViewModelProvider);
    await ref.read(authViewModelProvider.notifier).sendOtp(
          authState.phone,
          authState.countryCode,
        );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final padding = Responsive.pagePadding(context);
    final devOtpHint = authState.devOtpHint;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to\n${authState.countryCode} ${authState.phone}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: AppConfig.otpLength,
                controller: _otpController,
                autoFocus: true,
                keyboardType: TextInputType.number,
                enableActiveFill: true,
                onCompleted: _verifyOtp,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: Theme.of(context).colorScheme.surface,
                  inactiveFillColor: Theme.of(context).colorScheme.surface,
                  selectedFillColor: Theme.of(context).colorScheme.surface,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Verify',
                isLoading: _isLoading,
                onPressed: () => _verifyOtp(_otpController.text),
              ),
              const SizedBox(height: 16),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend OTP in ${_secondsRemaining}s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Resend OTP'),
                      ),
              ),
              const Spacer(),
              if (devOtpHint != null && devOtpHint.isNotEmpty)
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Development OTP: $devOtpHint',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
              else if (AppConfig.enableMockApi)
                Center(
                  child: Text(
                    'Mock mode OTP: ${AppConfig.mockOtp}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
