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
import 'package:wavego_driver/data/vehicle_document_requirements.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/media_capture_launcher.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/onboarding/saved_document_preview.dart';

class VehicleDocumentsScreen extends ConsumerStatefulWidget {
  const VehicleDocumentsScreen({super.key});

  @override
  ConsumerState<VehicleDocumentsScreen> createState() =>
      _VehicleDocumentsScreenState();
}

class _VehicleDocumentsScreenState extends ConsumerState<VehicleDocumentsScreen> {
  final Map<String, String?> _paths = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;

    final data = ref.read(registrationViewModelProvider);
    final specs = VehicleDocumentRequirements.specsFor(data.vehicleType);
    for (final spec in specs) {
      _paths[spec.type] = spec.fieldGetter(data);
    }

    setState(() => _loading = false);
  }

  Future<void> _pick(String type) async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.back,
    );
    if (path == null) return;

    final preview = await imagePathToDataUrl(path) ?? path;
    if (!mounted) return;
    setState(() => _paths[type] = preview);
  }

  Future<String?> _payloadFor(String? path) async {
    if (!hasUploadedMedia(path)) return null;
    if (isLocalFilePath(path) || (path?.startsWith('data:image') ?? false)) {
      return imagePathToDataUrl(path);
    }
    return path;
  }

  bool _allUploaded() {
    final data = ref.read(registrationViewModelProvider);
    final specs = VehicleDocumentRequirements.specsFor(data.vehicleType);
    for (final spec in specs) {
      if (!hasUploadedMedia(_paths[spec.type])) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_allUploaded()) {
      context.showSnackBar('Upload all required documents', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final registration = ref.read(registrationViewModelProvider);
      final specs = VehicleDocumentRequirements.specsFor(registration.vehicleType);

      await ref.read(profileRepositoryProvider).saveVehicleDocuments(
            insuranceUrl: await _payloadFor(_paths[VehicleDocumentRequirements.insurance]),
            pollutionUrl: await _payloadFor(_paths[VehicleDocumentRequirements.pollution]),
            permitUrl: await _payloadFor(_paths[VehicleDocumentRequirements.permit]),
            fitnessUrl: await _payloadFor(_paths[VehicleDocumentRequirements.fitness]),
            vehicleFrontUrl:
                await _payloadFor(_paths[VehicleDocumentRequirements.vehicleFront]),
            vehicleBackUrl:
                await _payloadFor(_paths[VehicleDocumentRequirements.vehicleBack]),
            vehicleSideUrl:
                await _payloadFor(_paths[VehicleDocumentRequirements.vehicleSide]),
          );

      var updated = registration;
      for (final spec in specs) {
        final path = _paths[spec.type];
        if (path != null) {
          updated = spec.fieldSetter(updated, path);
        }
      }
      ref.read(registrationViewModelProvider.notifier).updateRegistration((_) => updated);

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
    final registration = ref.watch(registrationViewModelProvider);
    final vehicleType = registration.vehicleType ?? 'Vehicle';
    final specs = VehicleDocumentRequirements.specsFor(registration.vehicleType);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$vehicleType Documents'),
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    children: [
                      Text(
                        'Upload all documents required for your $vehicleType.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...specs.map((spec) {
                        final path = _paths[spec.type];
                        final uploaded = hasUploadedMedia(path);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _VehicleDocUploadSection(
                            title: spec.label,
                            path: path,
                            uploaded: uploaded,
                            onUpload: () => _pick(spec.type),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
                  child: AppButton(
                    label: 'Save & Continue',
                    height: 54,
                    isLoading: _saving,
                    onPressed: _allUploaded() ? _submit : null,
                  ),
                ),
              ],
            ),
    );
  }
}

class _VehicleDocUploadSection extends StatelessWidget {
  const _VehicleDocUploadSection({
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
                Icons.directions_car_outlined,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Required',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        uploaded ? 'Photo added' : 'No photo yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: uploaded
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
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
