import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDevOtpHint());
  }

  void _applyDevOtpHint() {
    final devHint = ref.read(authViewModelProvider).devOtpHint;
    if (!mounted || devHint == null || devHint.isEmpty) return;

    if (kDebugMode) {
      _otpController.text = devHint;
    }
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
    final response =
        await ref.read(authViewModelProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    final loginState = ref.read(authViewModelProvider).loginState;
    if (loginState is ViewStateError<LoginResponse>) {
      setState(() {
        _errorMessage = loginState.message;
        _isLoading = false;
      });
      return;
    }

    if (response == null) {
      setState(() => _isLoading = false);
      return;
    }

    final hasToken = await ref.read(authRepositoryProvider).isLoggedIn();
    if (!mounted) return;
    if (!hasToken) {
      setState(() {
        _errorMessage = 'Login failed to save your session. Please try again.';
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);

    if (!response.isRegistered) {
      context.go(RouteNames.captainWelcome);
    } else if (!response.isVerified) {
      context.go(RouteNames.verificationPending);
    } else {
      context.go(RouteNames.dashboard);
    }
  }

  Future<void> _resendOtp() async {
    final authState = ref.read(authViewModelProvider);
    await ref.read(authViewModelProvider.notifier).sendOtp(
          authState.phone,
          authState.countryCode,
        );
    _startTimer();
    _applyDevOtpHint();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // PinCodeTextField disposes the controller when unmounted.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final padding = Responsive.pagePadding(context);
    final devHint = authState.devOtpHint;

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final hint = next.devOtpHint;
      if (hint == null || hint.isEmpty || hint == previous?.devOtpHint) return;
      if (kDebugMode) {
        _otpController.text = hint;
      }
      if (mounted) {
        context.showSnackBar('Dev OTP: $hint (SMS not configured locally)');
      }
    });

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
              if (devHint != null && devHint.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sms_failed_outlined,
                        color: AppColors.warning,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppConfig.enableMockApi
                              ? 'Mock mode — use OTP: $devHint'
                              : 'SMS is not configured on the server. '
                                  'Use this code to continue: $devHint',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.foreground,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            ],
          ),
        ),
      ),
    );
  }
}
