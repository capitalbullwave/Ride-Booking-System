import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';

class CaptainWelcomeScreen extends ConsumerStatefulWidget {
  const CaptainWelcomeScreen({super.key});

  @override
  ConsumerState<CaptainWelcomeScreen> createState() =>
      _CaptainWelcomeScreenState();
}

class _CaptainWelcomeScreenState extends ConsumerState<CaptainWelcomeScreen> {
  bool _whatsappUpdates = true;
  bool _showReferralField = false;
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  String _displayName(AuthState auth) {
    final loginState = auth.loginState;
    if (loginState is ViewStateSuccess<LoginResponse>) {
      final name = loginState.data.driver?.name.trim();
      if (name != null && name.isNotEmpty) return name.split(' ').first;
    }
    return 'Captain';
  }

  String _formattedPhone(AuthState auth) {
    final local = auth.phone.trim();
    if (local.isEmpty) return '${auth.countryCode} —';
    if (local.length == 10) {
      return '${auth.countryCode} ${local.substring(0, 5)} ${local.substring(5)}';
    }
    return '${auth.countryCode} $local';
  }

  void _startRegistration() {
    final referral = _referralController.text.trim();
    if (referral.isNotEmpty) {
      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(referralCode: referral),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authViewModelProvider);
    final padding = Responsive.pagePadding(context);
    final displayName = _displayName(auth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(RouteNames.phoneLogin),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(RouteNames.support),
            icon: const Icon(Icons.headset_mic_outlined, size: 20),
            label: const Text('Help'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: padding.copyWith(top: 8, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hello $displayName',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please register yourself as a Fast Bull Captain',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 28),
                    InkWell(
                      onTap: () =>
                          setState(() => _whatsappUpdates = !_whatsappUpdates),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _whatsappUpdates,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  setState(() => _whatsappUpdates = v ?? true),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Receive account updates on WhatsApp',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chat,
                            color: const Color(0xFF25D366),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _formattedPhone(auth),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showReferralField = !_showReferralField),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Have a Referral Code?'),
                    ),
                    if (_showReferralField) ...[
                      const SizedBox(height: 4),
                      AppTextField(
                        controller: _referralController,
                        label: 'Referral code',
                        hint: 'Enter referral code',
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: padding.copyWith(top: 0, bottom: 16),
              child: AppButton(
                label: 'Register as a Captain',
                variant: AppButtonVariant.secondary,
                height: 56,
                onPressed: () {
                  _startRegistration();
                  context.go(RouteNames.captainCitySelection);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
