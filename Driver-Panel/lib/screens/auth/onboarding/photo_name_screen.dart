import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';
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
  String? _photoPath;
  String? _dob;
  String? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;
    final data = ref.read(registrationViewModelProvider);
    _nameController.text = data.fullName;
    setState(() {
      _photoPath = data.profilePhotoUrl ?? data.selfieUrl;
      _dob = data.dateOfBirth;
      _gender = data.gender;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await MediaCaptureLauncher.captureSelfie(context, ref);
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _pickDob() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
    );
    if (date != null) {
      setState(() => _dob = date.toIso8601String().split('T').first);
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Full name is required', isError: true);
      return;
    }
    if (_photoPath == null) {
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

      final saved = await ref.read(profileRepositoryProvider).saveProfileStep(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: _dob,
            gender: _gender,
            profilePhoto: photoUrl,
            city: registration.city,
            state: registration.state,
            country: registration.country,
          );

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
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: ProfilePhotoAvatar(
                photoPath: _photoPath,
                radius: 52,
              ),
            ),
            TextButton(
              onPressed: _pickPhoto,
              child: const Text('Edit Profile Photo'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of Birth'),
              subtitle: Text(_dob ?? 'Select date'),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: _pickDob,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: AppConstants.genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Submit',
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
