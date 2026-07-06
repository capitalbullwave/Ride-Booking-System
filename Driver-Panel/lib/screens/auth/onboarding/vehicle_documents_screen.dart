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
    if (path != null) {
      setState(() => _paths[type] = path);
    }
  }

  Future<String?> _payloadFor(String? path) async {
    if (!hasUploadedMedia(path)) return null;
    if (isLocalFilePath(path)) return imagePathToDataUrl(path);
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

    return Scaffold(
      backgroundColor: AppColors.background,
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
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Upload all documents required for your $vehicleType. You cannot submit your application until every document is uploaded.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      ...specs.map((spec) {
                        final path = _paths[spec.type];
                        final uploaded = hasUploadedMedia(path);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: InkWell(
                              onTap: () => _pick(spec.type),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.card),
                                  border: Border.all(
                                    color: uploaded
                                        ? AppColors.success
                                        : AppColors.border,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              spec.label,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              uploaded ? 'Uploaded' : 'Required',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: uploaded
                                                        ? AppColors.success
                                                        : AppColors.error,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (uploaded && path != null)
                                        SavedDocumentPreview(path: path)
                                      else
                                        const Icon(
                                          Icons.upload_file_outlined,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: AppButton(
                    label: 'Save & Continue',
                    variant: AppButtonVariant.secondary,
                    height: 56,
                    isLoading: _saving,
                    onPressed: _allUploaded() ? _submit : null,
                  ),
                ),
              ],
            ),
    );
  }
}
