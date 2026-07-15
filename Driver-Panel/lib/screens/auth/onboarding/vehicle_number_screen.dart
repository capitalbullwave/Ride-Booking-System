import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
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

class VehicleNumberScreen extends ConsumerStatefulWidget {
  const VehicleNumberScreen({super.key});

  @override
  ConsumerState<VehicleNumberScreen> createState() =>
      _VehicleNumberScreenState();
}

class _VehicleNumberScreenState extends ConsumerState<VehicleNumberScreen> {
  late final TextEditingController _plateController;
  String? _rcFront;
  String? _rcBack;
  String? _vehicleTypeName;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    final raw = await ref.read(profileRepositoryProvider).getRegistrationData();
    if (!mounted) return;

    final docs = raw['documents'] as Map<String, dynamic>? ?? {};
    String? docUrl(String type) {
      final entry = docs[type];
      if (entry is! Map<String, dynamic>) return null;
      return resolveMediaUrl(entry['url'] as String?);
    }

    final data = ref.read(registrationViewModelProvider);
    _plateController.text = data.vehicleNumber ?? '';
    setState(() {
      _rcFront = data.rcUrl ?? docUrl('VEHICLE_RC');
      _rcBack = data.rcBackUrl ?? docUrl('VEHICLE_RC_BACK');
      _vehicleTypeName = data.vehicleType ?? raw['vehicle_type_name'] as String?;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickRc(bool front) async {
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
        _rcFront = preview;
      } else {
        _rcBack = preview;
      }
    });
  }

  Future<String?> _payloadFor(String? path) async {
    if (!hasUploadedMedia(path)) return null;
    if (isLocalFilePath(path)) return imagePathToDataUrl(path);
    return path;
  }

  Future<void> _submit() async {
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      context.showSnackBar('Enter vehicle number', isError: true);
      return;
    }
    if (!hasUploadedMedia(_rcFront) || !hasUploadedMedia(_rcBack)) {
      context.showSnackBar('Upload RC front and back photos', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final registration = ref.read(registrationViewModelProvider);
      final vehicleTypeId =
          await ref.read(profileRepositoryProvider).resolveVehicleTypeId(
                registration.vehicleType ?? _vehicleTypeName,
              );

      await ref.read(profileRepositoryProvider).saveVehicleNumber(
            licensePlate: plate,
            vehicleTypeId: vehicleTypeId,
            rcFrontUrl: await _payloadFor(_rcFront),
            rcBackUrl: await _payloadFor(_rcBack),
          );

      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(
              vehicleNumber: plate,
              rcUrl: _rcFront,
              rcBackUrl: _rcBack,
              vehicleBrand: r.vehicleBrand ?? 'Standard',
              vehicleModel: r.vehicleModel ?? 'Standard',
              vehicleColor: r.vehicleColor ?? 'Unknown',
              manufacturingYear: r.manufacturingYear ?? DateTime.now().year,
            ),
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
    final editing = isProfileEditMode(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(editing ? 'Vehicle Details' : 'Vehicle Number'),
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
                  if (_vehicleTypeName != null && _vehicleTypeName!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car_outlined,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vehicle type: $_vehicleTypeName',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    controller: _plateController,
                    label: 'Vehicle number',
                    hint: 'KA 12 EZ 4231',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RC images',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _RcUploadSection(
                    title: 'RC Front',
                    path: _rcFront,
                    uploaded: hasUploadedMedia(_rcFront),
                    onUpload: () => _pickRc(true),
                  ),
                  const SizedBox(height: 10),
                  _RcUploadSection(
                    title: 'RC Back',
                    path: _rcBack,
                    uploaded: hasUploadedMedia(_rcBack),
                    onUpload: () => _pickRc(false),
                  ),
                  const SizedBox(height: 20),
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
}

class _RcUploadSection extends StatelessWidget {
  const _RcUploadSection({
    required this.title,
    required this.path,
    required this.uploaded,
    required this.onUpload,
  });

  final String title;
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
                Icons.description_outlined,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  uploaded ? 'Photo added' : 'Required',
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
