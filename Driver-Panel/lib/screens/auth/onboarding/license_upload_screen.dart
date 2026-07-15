import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';
import 'package:wavego_driver/core/utils/onboarding_navigation.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/media_capture_launcher.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';
import 'package:wavego_driver/widgets/onboarding/saved_document_preview.dart';

class LicenseUploadScreen extends ConsumerStatefulWidget {
  const LicenseUploadScreen({super.key});

  @override
  ConsumerState<LicenseUploadScreen> createState() =>
      _LicenseUploadScreenState();
}

class _LicenseUploadScreenState extends ConsumerState<LicenseUploadScreen> {
  late final TextEditingController _licenseNumberController;
  String? _frontPath;
  String? _backPath;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _licenseNumberController = TextEditingController();
    _licenseNumberController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;
    final data = ref.read(registrationViewModelProvider);
    _licenseNumberController.text = data.licenseNumber ?? '';
    setState(() {
      _frontPath = data.licenseFrontUrl;
      _backPath = data.licenseBackUrl;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _licenseNumberController.dispose();
    super.dispose();
  }

  bool get _hasFront => hasUploadedMedia(_frontPath);

  bool get _hasValidLicenseNumber =>
      _licenseNumberController.text.trim().length >= 4;

  bool get _canContinue => !_loading && _hasFront && _hasValidLicenseNumber;

  Future<void> _pick(bool front) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path == null) return;

    final preview = await imagePathToDataUrl(path) ?? path;
    if (!mounted) return;
    setState(() {
      if (front) {
        _frontPath = preview;
      } else {
        _backPath = preview;
      }
    });
  }

  Future<void> _continue() async {
    if (!_hasFront) {
      context.showSnackBar(
        'Please upload the front side of your license',
        isError: true,
      );
      return;
    }

    final licenseNumber = _licenseNumberController.text.trim().toUpperCase();
    if (licenseNumber.length < 4) {
      context.showSnackBar('Enter a valid license number', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      if (isLocalFilePath(_frontPath) ||
          (_frontPath?.startsWith('data:image') ?? false)) {
        final frontUrl = await imagePathToDataUrl(_frontPath);
        if (frontUrl == null) throw Exception('Could not read license image');
        await ref.read(profileRepositoryProvider).saveLicenseUpload(
              documentUrl: frontUrl,
              side: 'front',
            );
      }

      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(licenseFrontUrl: _frontPath),
          );

      if (hasUploadedMedia(_backPath) &&
          (isLocalFilePath(_backPath) ||
              (_backPath?.startsWith('data:image') ?? false))) {
        final backUrl = await imagePathToDataUrl(_backPath);
        if (backUrl != null) {
          await ref.read(profileRepositoryProvider).saveLicenseUpload(
                documentUrl: backUrl,
                side: 'back',
              );
          ref.read(registrationViewModelProvider.notifier).updateRegistration(
                (r) => r.copyWith(licenseBackUrl: _backPath),
              );
        }
      }

      await ref.read(profileRepositoryProvider).saveLicenseNumber(
            licenseNumber: licenseNumber,
          );
      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(licenseNumber: licenseNumber),
          );

      if (!mounted) return;
      if (isProfileEditMode(context)) {
        context.pop();
        return;
      }
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
    final hasFront = _hasFront;
    final hasBack = hasUploadedMedia(_backPath);
    final editing = isProfileEditMode(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(editing ? 'Driving License' : 'Upload Driving License'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(RouteNames.support),
            icon: const Icon(Icons.headset_mic_outlined, size: 20),
            label: const Text('Help'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          hasFront
                              ? 'License saved. Replace or continue.'
                              : 'Upload front and back of your driving license.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _LicenseUploadSection(
                          title: 'Front side',
                          required: true,
                          path: _frontPath,
                          uploaded: hasFront,
                          onUpload: () => _pick(true),
                        ),
                        const SizedBox(height: 10),
                        _LicenseUploadSection(
                          title: 'Back side',
                          required: false,
                          path: _backPath,
                          uploaded: hasBack,
                          onUpload: () => _pick(false),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _licenseNumberController,
                          label: 'License number',
                          hint: 'Enter number printed on your license',
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
                  child: AppButton(
                    label: editing ? 'Save' : 'Continue',
                    height: 54,
                    isLoading: _saving,
                    onPressed: _canContinue ? _continue : null,
                  ),
                ),
              ],
            ),
    );
  }
}

class _LicenseUploadSection extends StatelessWidget {
  const _LicenseUploadSection({
    required this.title,
    required this.required,
    required this.path,
    required this.uploaded,
    required this.onUpload,
  });

  final String title;
  final bool required;
  final String? path;
  final bool uploaded;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.muted.withValues(alpha: 0.35),
        border: Border.all(
          color: uploaded ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (uploaded && path != null)
            DocumentThumbnail(path: path!)
          else
            Container(
              width: 88,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.badge_outlined,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: required
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        required ? 'Required' : 'Optional',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: required
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  uploaded ? 'Photo added' : 'No photo yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: uploaded ? AppColors.success : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onUpload,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(uploaded ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }
}
