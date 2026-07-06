import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';
import 'package:wavego_driver/core/utils/onboarding_navigation.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/media_capture_launcher.dart';
import 'package:wavego_driver/widgets/onboarding/onboarding_step_scaffold.dart';
import 'package:wavego_driver/widgets/onboarding/saved_document_preview.dart';

class LicenseUploadScreen extends ConsumerStatefulWidget {
  const LicenseUploadScreen({super.key});

  @override
  ConsumerState<LicenseUploadScreen> createState() =>
      _LicenseUploadScreenState();
}

class _LicenseUploadScreenState extends ConsumerState<LicenseUploadScreen> {
  String? _frontPath;
  String? _backPath;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;
    final data = ref.read(registrationViewModelProvider);
    setState(() {
      _frontPath = data.licenseFrontUrl;
      _backPath = data.licenseBackUrl;
      _loading = false;
    });
  }

  Future<void> _pick(bool front) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path == null) return;
    setState(() {
      if (front) {
        _frontPath = path;
      } else {
        _backPath = path;
      }
    });
  }

  Future<void> _continue() async {
    if (!hasUploadedMedia(_frontPath)) {
      context.showSnackBar(
        'Please upload the front side of your license',
        isError: true,
      );
      return;
    }
    if (!hasUploadedMedia(_backPath)) {
      context.showSnackBar(
        'Please upload the back side of your license',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (isLocalFilePath(_frontPath)) {
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

      if (isLocalFilePath(_backPath)) {
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

      if (!mounted) return;
      final registration = ref.read(registrationViewModelProvider);
      if (isProfileEditMode(context) &&
          (registration.licenseNumber ?? '').length >= 4) {
        context.pop();
        return;
      }
      finishOnboardingStep(
        context,
        defaultRoute: RouteNames.onboardingLicenseNumber,
      );
    } catch (e) {
      if (mounted) context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFront = hasUploadedMedia(_frontPath);
    final editing = isProfileEditMode(context);

    return OnboardingStepScaffold(
      title: editing ? 'Driving License' : 'Upload Driving License',
      subtitle: hasFront
          ? 'Your license is saved. Replace images or continue.'
          : 'One side of your DL',
      actionLabel: editing ? 'Save' : 'Continue',
      isLoading: _saving || _loading,
      actionEnabled: hasFront && hasUploadedMedia(_backPath) && !_loading,
      onAction: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else ...[
            SavedDocumentPreview(path: _frontPath, label: 'Front side'),
            if (hasFront) const SizedBox(height: 16),
            OnboardingUploadActions(
              onCamera: () => _pick(true),
              onGallery: () => _pick(true),
            ),
            if (hasFront) ...[
              const SizedBox(height: 16),
              SavedDocumentPreview(path: _backPath, label: 'Back side'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _pick(false),
                child: Text(
                  hasUploadedMedia(_backPath)
                      ? 'Replace back side'
                      : 'Upload back side (required)',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
