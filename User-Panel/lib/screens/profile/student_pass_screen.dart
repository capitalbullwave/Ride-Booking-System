import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/image_data_url.dart';
import 'package:wavego_user/core/utils/image_pick_utils.dart';
import 'package:wavego_user/core/utils/responsive.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/services/membership_service.dart';
import 'package:wavego_user/widgets/common/app_button.dart';
import 'package:wavego_user/widgets/forms/app_text_field.dart';

class StudentPassScreen extends ConsumerStatefulWidget {
  const StudentPassScreen({super.key});

  @override
  ConsumerState<StudentPassScreen> createState() => _StudentPassScreenState();
}

class _StudentPassScreenState extends ConsumerState<StudentPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadharController = TextEditingController();
  final _collegeController = TextEditingController();

  XFile? _aadharPhoto;
  XFile? _studentIdPhoto;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _aadharController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAadhar) async {
    final file = await ImagePickUtils.pickImage(context);
    if (file == null || !mounted) return;
    setState(() {
      if (isAadhar) {
        _aadharPhoto = file;
      } else {
        _studentIdPhoto = file;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_aadharPhoto == null || _studentIdPhoto == null) {
      context.showSnackBar('Please upload both Aadhar and student ID photos', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final aadharDataUrl = await imageXFileToDataUrl(_aadharPhoto);
      final studentIdDataUrl = await imageXFileToDataUrl(_studentIdPhoto);
      if (aadharDataUrl == null || studentIdDataUrl == null) {
        throw Exception('Unable to process uploaded images');
      }

      await ref.read(studentPassServiceProvider).submitApplication(
            aadharNumber: _aadharController.text.trim(),
            collegeName: _collegeController.text.trim(),
            aadharPhoto: aadharDataUrl,
            studentIdPhoto: studentIdDataUrl,
          );

      ref.invalidate(studentPassProvider);
      if (!mounted) return;
      context.showSnackBar('Application submitted. Verification is pending.');
      context.pop();
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationAsync = ref.watch(studentPassProvider);
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Student Pass')),
      body: applicationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(studentPassProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (application) {
          if (application != null && application.isApproved) {
            return _ApprovedView(application: application);
          }
          if (application != null && application.isPending) {
            return _PendingView(application: application);
          }
          if (application != null && application.isRejected) {
            return _RejectedView(
              application: application,
              child: _buildForm(padding, application),
            );
          }
          return _buildForm(padding, application);
        },
      ),
    );
  }

  Widget _buildForm(EdgeInsets padding, StudentPassApplication? application) {
    if (application != null && application.isRejected) {
      _collegeController.text = application.collegeName;
    }

    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get 20% off every ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Submit your student details for admin verification.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _aadharController,
              label: 'Aadhar number',
              hint: 'Enter 12-digit Aadhar number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (value) {
                if (value == null || value.trim().length != 12) {
                  return 'Enter a valid 12-digit Aadhar number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _collegeController,
              label: 'College name',
              hint: 'Enter your college or university name',
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Enter your college name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _UploadTile(
              label: 'Aadhar card photo',
              fileName: _aadharPhoto?.name,
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 12),
            _UploadTile(
              label: 'Student ID card photo',
              fileName: _studentIdPhoto?.name,
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: application?.isRejected == true ? 'Resubmit application' : 'Submit for verification',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.onTap,
    this.fileName,
  });

  final String label;
  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.upload_file, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    fileName ?? 'Tap to upload image',
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView({required this.application});

  final StudentPassApplication application;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top, color: AppColors.warning, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              'Verification pending',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your student pass application for ${application.collegeName} is under review. Admin will verify your documents soon.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovedView extends StatelessWidget {
  const _ApprovedView({required this.application});

  final StudentPassApplication application;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: AppColors.success, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              'Student pass verified',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You now get ${application.discountPercent.toStringAsFixed(0)}% off on every ride.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedView extends StatelessWidget {
  const _RejectedView({required this.application, required this.child});

  final StudentPassApplication application;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
          ),
          child: Text(
            application.rejectionReason ?? 'Your application was rejected. Please resubmit.',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
