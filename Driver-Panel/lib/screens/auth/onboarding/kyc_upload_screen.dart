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
    _numberController.addListener(() => setState(() {}));
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

  bool get _hasFront => hasUploadedMedia(_frontPath);

  bool get _hasBack => hasUploadedMedia(_backPath);

  bool get _hasValidNumber => _numberController.text.trim().length >= 4;

  bool get _canSubmit {
    if (!_hasFront || !_hasValidNumber) return false;
    if (_idType == KycIdType.aadhaar && !_hasBack) return false;
    return true;
  }

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

  Future<String?> _payloadFor(String? path) async {
    if (!hasUploadedMedia(path)) return null;
    if (isLocalFilePath(path) || (path?.startsWith('data:image') ?? false)) {
      return imagePathToDataUrl(path);
    }
    return path;
  }

  Future<void> _submit() async {
    final number = _numberController.text.trim();
    if (!_hasFront) {
      context.showSnackBar('Upload document photo', isError: true);
      return;
    }
    if (number.length < 4) {
      context.showSnackBar('Enter document number', isError: true);
      return;
    }
    if (_idType == KycIdType.aadhaar && !_hasBack) {
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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                          const SizedBox(height: 16),
                        ],
                        Text(
                          isAadhaar
                              ? 'Upload front and back of your Aadhaar card.'
                              : 'Upload front side of your PAN card.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _KycUploadSection(
                          title: 'Front side',
                          required: true,
                          path: _frontPath,
                          uploaded: _hasFront,
                          onUpload: () => _pick(true),
                        ),
                        if (isAadhaar) ...[
                          const SizedBox(height: 10),
                          _KycUploadSection(
                            title: 'Back side',
                            required: true,
                            path: _backPath,
                            uploaded: _hasBack,
                            onUpload: () => _pick(false),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _numberController,
                          label: isAadhaar ? 'Aadhaar number' : 'PAN number',
                          hint: isAadhaar
                              ? 'Enter 12-digit Aadhaar number'
                              : 'Enter PAN number',
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
                  child: AppButton(
                    label: editing ? 'Save changes' : 'Submit',
                    height: 54,
                    isLoading: _saving,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ],
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

class _KycUploadSection extends StatelessWidget {
  const _KycUploadSection({
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
                Icons.credit_card_outlined,
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
