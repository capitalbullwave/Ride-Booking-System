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

enum KycIdType { aadhaar, pan }

class KycUploadScreen extends ConsumerStatefulWidget {
  const KycUploadScreen({super.key});

  @override
  ConsumerState<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends ConsumerState<KycUploadScreen> {
  KycIdType _idType = KycIdType.aadhaar;
  late final TextEditingController _numberController;
  String? _frontPath;
  String? _backPath;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    final forcedType = onboardingDocType(context);
    _idType = KycIdType.aadhaar;
    if (forcedType == 'pan') {
      _idType = KycIdType.pan;
    }

    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;

    final data = ref.read(registrationViewModelProvider);
    if (forcedType == null && isProfileEditMode(context)) {
      if ((data.panNumber ?? '').isNotEmpty &&
          (data.aadhaarNumber ?? '').isEmpty &&
          hasUploadedMedia(data.panUrl)) {
        _idType = KycIdType.pan;
      }
    }

    if (_idType == KycIdType.aadhaar) {
      _numberController.text = data.aadhaarNumber ?? '';
      _frontPath = data.aadhaarFrontUrl;
      _backPath = data.aadhaarBackUrl;
    } else {
      _numberController.text = data.panNumber ?? '';
      _frontPath = data.panUrl;
      _backPath = null;
    }

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
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

  Future<String?> _payloadFor(String? path) async {
    if (!hasUploadedMedia(path)) return null;
    if (isLocalFilePath(path)) return imagePathToDataUrl(path);
    return path;
  }

  Future<void> _submit() async {
    final number = _numberController.text.trim();
    if (!hasUploadedMedia(_frontPath)) {
      context.showSnackBar('Upload document photo', isError: true);
      return;
    }
    if (number.length < 4) {
      context.showSnackBar('Enter document number', isError: true);
      return;
    }
    if (_idType == KycIdType.aadhaar && !hasUploadedMedia(_backPath)) {
      context.showSnackBar('Upload back side of Aadhaar', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final frontPayload = await _payloadFor(_frontPath);
      if (frontPayload == null) throw Exception('Could not read document image');

      final idType = _idType == KycIdType.aadhaar ? 'AADHAAR' : 'PAN';
      await ref.read(profileRepositoryProvider).saveKyc(
            idType: idType,
            frontUrl: frontPayload,
            backUrl: await _payloadFor(_backPath),
            documentNumber: number,
          );

      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => _idType == KycIdType.aadhaar
                ? r.copyWith(
                    aadhaarNumber: number,
                    aadhaarFrontUrl: _frontPath,
                    aadhaarBackUrl: _backPath,
                  )
                : r.copyWith(panNumber: number, panUrl: _frontPath),
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
    final isAadhaar = _idType == KycIdType.aadhaar;
    final forcedType = onboardingDocType(context);
    final editing = isProfileEditMode(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAadhaar ? 'Aadhaar Card' : 'PAN Card'),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (forcedType == null && editing) ...[
                    const Text(
                      'Select ID to upload',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _IdChoiceCard(
                            label: 'Aadhaar',
                            selected: isAadhaar,
                            onTap: () => _switchType(KycIdType.aadhaar),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _IdChoiceCard(
                            label: 'PAN Card',
                            selected: !isAadhaar,
                            onTap: () => _switchType(KycIdType.pan),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  SavedDocumentPreview(
                    path: _frontPath,
                    label: 'Front side',
                  ),
                  const SizedBox(height: 12),
                  _UploadCard(
                    title: hasUploadedMedia(_frontPath)
                        ? 'Replace front photo'
                        : 'Front side of your ${isAadhaar ? 'Aadhaar' : 'PAN'}',
                    done: hasUploadedMedia(_frontPath),
                    primary: true,
                    onTap: () => _pick(true),
                  ),
                  if (isAadhaar) ...[
                    const SizedBox(height: 16),
                    SavedDocumentPreview(path: _backPath, label: 'Back side'),
                    const SizedBox(height: 12),
                    _UploadCard(
                      title: hasUploadedMedia(_backPath)
                          ? 'Replace back photo'
                          : 'Back side of your Aadhaar',
                      done: hasUploadedMedia(_backPath),
                      primary: false,
                      onTap: () => _pick(false),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _numberController,
                    label: isAadhaar ? 'Aadhaar number' : 'PAN number',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: editing ? 'Save changes' : 'Submit',
                    variant: AppButtonVariant.secondary,
                    isLoading: _saving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _switchType(KycIdType type) async {
    if (_idType == type) return;
    setState(() => _loading = true);
    _idType = type;
    await _hydrate();
  }
}

class _IdChoiceCard extends StatelessWidget {
  const _IdChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.done,
    required this.primary,
    required this.onTap,
  });

  final String title;
  final bool done;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: done ? AppColors.success : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          AppButton(
            label: done ? 'Replace photo' : 'Upload photo',
            icon: Icons.add_photo_alternate_outlined,
            variant: primary ? AppButtonVariant.secondary : AppButtonVariant.outline,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
