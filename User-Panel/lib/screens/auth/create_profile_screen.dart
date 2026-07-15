import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';
import 'package:wavego_user/core/utils/responsive.dart';
import 'package:wavego_user/core/utils/validators.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/widgets/common/app_button.dart';
import 'package:wavego_user/widgets/forms/app_text_field.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  bool _isSubmitting = false;
  String? _verifiedPhone;
  String? _selectedGender;
  bool _showReferralField = false;

  static const _genderOptions = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
  ];

  bool _isPlaceholderEmail(String? email) {
    if (email == null || email.trim().isEmpty) return true;
    return email.trim().toLowerCase().endsWith('@ridebook.app');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final authRepo = ref.read(authRepositoryProvider);
    final loggedIn = await authRepo.isLoggedIn();
    if (!loggedIn && mounted) {
      context.go(RouteNames.phoneLogin);
      return;
    }

    final needsSetup = await authRepo.needsProfileSetup();
    if (!needsSetup && mounted) {
      context.go(RouteNames.home);
      return;
    }

    final profile = await authRepo.getProfile();
    if (!mounted) return;

    setState(() {
      _verifiedPhone = profile?.phone ?? '';
      if (profile != null && !profile.isPlaceholderName) {
        _nameController.text = profile.name.trim();
      }
      if (!_isPlaceholderEmail(profile?.email)) {
        _emailController.text = profile!.email!.trim();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  String? _optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.email(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      context.showSnackBar('Please select your gender', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      await ref.read(authRepositoryProvider).updateProfile(
            fullName: name,
            email: email.isEmpty ? null : email,
            gender: _selectedGender,
            referralCode: _referralController.text.trim().isEmpty
                ? null
                : _referralController.text.trim(),
          );
      refreshUserProfile(ref);

      if (!mounted) return;
      context.go(RouteNames.home);
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Complete your profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us a bit about yourself to finish setting up your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (_verifiedPhone != null && _verifiedPhone!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERIFIED MOBILE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.6,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _verifiedPhone!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameController,
                  hint: 'Enter your full name',
                  label: 'Full name',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    final requiredError = Validators.required(value, 'Full name');
                    if (requiredError != null) return requiredError;
                    if (value!.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  label: 'Email (optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: _optionalEmail,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _genderOptions.map((option) {
                    final selected = _selectedGender == option.$1;
                    return ChoiceChip(
                      label: Text(option.$2),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedGender = option.$1),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      setState(() => _showReferralField = !_showReferralField),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    _showReferralField
                        ? 'Hide referral code'
                        : 'Have a referral code? (optional)',
                  ),
                ),
                if (_showReferralField) ...[
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _referralController,
                    hint: 'Enter referral code',
                    label: 'Referral code (optional)',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You can also apply a code later from Refer & Earn.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
                const SizedBox(height: 32),
                AppButton(
                  label: 'Continue to home',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
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
