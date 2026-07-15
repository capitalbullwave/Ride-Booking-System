import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/media_capture_launcher.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';
import 'package:wavego_driver/widgets/profile/profile_photo_avatar.dart';

class PhotoNameScreen extends ConsumerStatefulWidget {
  const PhotoNameScreen({super.key});

  @override
  ConsumerState<PhotoNameScreen> createState() => _PhotoNameScreenState();
}

class _PhotoNameScreenState extends ConsumerState<PhotoNameScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  String? _photoPath;
  String? _dob;
  String? _gender;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;

    final data = ref.read(registrationViewModelProvider);
    final savedName = data.fullName.trim();
    final displayName =
        savedName.isEmpty || savedName.toLowerCase() == 'driver' ? '' : savedName;

    _nameController.text = displayName;
    _dob = data.dateOfBirth;
    _syncDobController();

    setState(() {
      _photoPath = data.profilePhotoUrl ?? data.selfieUrl;
      _gender = data.gender;
      _loading = false;
    });
  }

  void _syncDobController() {
    if (_dob == null || _dob!.isEmpty) {
      _dobController.clear();
      return;
    }
    try {
      final parsed = DateTime.parse(_dob!);
      _dobController.text = DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      _dobController.text = _dob!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  bool get _hasPhoto => _photoPath != null && _photoPath!.trim().isNotEmpty;

  bool get _canSubmit =>
      !_loading &&
      !_saving &&
      _hasPhoto &&
      _nameController.text.trim().isNotEmpty &&
      _dob != null &&
      _gender != null;

  Future<void> _pickPhoto() async {
    final path = await MediaCaptureLauncher.showImageSourceSheet(
      context,
      ref,
      lens: CameraLensPreference.front,
    );
    if (path == null) return;

    final preview = await imagePathToDataUrl(path) ?? path;
    if (!mounted) return;
    setState(() => _photoPath = preview);
  }

  Future<void> _pickDob() async {
    final initial = _dob != null
        ? DateTime.tryParse(_dob!) ?? DateTime(1995)
        : DateTime(1995);

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
      helpText: 'Select date of birth',
    );
    if (date == null) return;

    setState(() {
      _dob = date.toIso8601String().split('T').first;
      _syncDobController();
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Full name is required', isError: true);
      return;
    }
    if (!_hasPhoto) {
      context.showSnackBar('Profile photo is required', isError: true);
      return;
    }
    if (_dob == null || _gender == null) {
      context.showSnackBar('Date of birth and gender are required', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final parts = name.split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final registration = ref.read(registrationViewModelProvider);
      final photoUrl = await imagePathToDataUrl(_photoPath);

      final pendingReferral = (registration.referralCode ?? '').trim().isNotEmpty
          ? registration.referralCode!.trim()
          : ref
              .read(localStorageProvider)
              .getString(AppConstants.pendingReferralCodeKey);

      final saved = await ref.read(profileRepositoryProvider).saveProfileStep(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: _dob,
            gender: _gender,
            profilePhoto: photoUrl,
            city: registration.city,
            state: registration.state,
            country: registration.country,
            referralCode: pendingReferral,
          );

      if ((pendingReferral ?? '').trim().isNotEmpty) {
        await ref
            .read(localStorageProvider)
            .remove(AppConstants.pendingReferralCodeKey);
      }

      final serverPhoto = saved['profile_photo'] as String?;
      final resolvedPhoto = serverPhoto != null && serverPhoto.isNotEmpty
          ? resolveMediaUrl(serverPhoto)
          : _photoPath;

      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(
              fullName: name,
              dateOfBirth: _dob,
              gender: _gender,
              profilePhotoUrl: resolvedPhoto,
              selfieUrl: resolvedPhoto,
            ),
          );

      await ref.read(dashboardViewModelProvider.notifier).refreshProfile();

      if (!mounted) return;
      context.go(RouteNames.documentCentre);
    } catch (e) {
      if (mounted) context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Photo and name'),
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Take a selfie or choose from gallery',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: _ProfilePhotoPicker(
                            photoPath: _photoPath,
                            onTap: _pickPhoto,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _nameController,
                          label: 'Full name',
                          hint: 'Enter your full name',
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _dobController,
                          label: 'Date of birth',
                          hint: 'Select date',
                          readOnly: true,
                          onTap: _pickDob,
                          suffixIcon: const Icon(
                            Icons.calendar_month_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gender',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_gender ?? 'unset'),
                          initialValue: _gender,
                          hint: const Text('Select gender'),
                          decoration: const InputDecoration(),
                          items: AppConstants.genders
                              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomInset),
                  child: AppButton(
                    label: 'Submit',
                    height: 54,
                    isLoading: _saving,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfilePhotoPicker extends StatelessWidget {
  const _ProfilePhotoPicker({
    required this.photoPath,
    required this.onTap,
  });

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasPhoto ? AppColors.primary : AppColors.border,
                    width: hasPhoto ? 2.5 : 1.5,
                  ),
                ),
                child: ProfilePhotoAvatar(
                  photoPath: photoPath,
                  radius: 40,
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  hasPhoto ? Icons.edit_rounded : Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasPhoto ? 'Change photo' : 'Add profile photo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
