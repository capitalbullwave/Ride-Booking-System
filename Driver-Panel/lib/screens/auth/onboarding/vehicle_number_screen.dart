import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
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
      _rcBack = docUrl('VEHICLE_RC_BACK');
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
    setState(() {
      if (front) {
        _rcFront = path;
      } else {
        _rcBack = path;
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
                  const SizedBox(height: 24),
                  Text(
                    'RC Images',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SavedDocumentPreview(path: _rcFront, label: 'RC Front'),
                  const SizedBox(height: 12),
                  _RcUploadBox(
                    label: 'FRONT',
                    done: hasUploadedMedia(_rcFront),
                    onTap: () => _pickRc(true),
                  ),
                  const SizedBox(height: 16),
                  SavedDocumentPreview(path: _rcBack, label: 'RC Back'),
                  const SizedBox(height: 12),
                  _RcUploadBox(
                    label: 'BACK',
                    done: hasUploadedMedia(_rcBack),
                    onTap: () => _pickRc(false),
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
}

class _RcUploadBox extends StatelessWidget {
  const _RcUploadBox({
    required this.label,
    required this.done,
    required this.onTap,
  });

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? AppColors.success : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle_outline : Icons.add_photo_alternate_outlined,
              color: done ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              done ? 'Replace $label' : 'Upload $label',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
