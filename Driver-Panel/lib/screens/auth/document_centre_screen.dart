import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/models/document_centre_steps.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class DocumentCentreScreen extends ConsumerStatefulWidget {
  const DocumentCentreScreen({super.key});

  @override
  ConsumerState<DocumentCentreScreen> createState() =>
      _DocumentCentreScreenState();
}

class _DocumentCentreScreenState extends ConsumerState<DocumentCentreScreen> {
  bool _submitted = false;
  Map<String, String> _serverStepStatus = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydratePhone();
      _syncProgress();
    });
  }

  Future<void> _syncProgress() async {
    try {
      final data =
          await ref.read(profileRepositoryProvider).getRegistrationProgress();
      final steps = (data['steps'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final statusMap = <String, String>{};
      for (final step in steps) {
        final id = step['id'] as String?;
        final status = step['status'] as String?;
        if (id != null && status != null) statusMap[id] = status;
      }
      if (!mounted) return;
      setState(() {
        _submitted = data['submitted'] == true;
        _serverStepStatus = statusMap;
      });
    } catch (_) {}
  }

  Future<void> _hydratePhone() async {
    final authPhone = ref.read(authViewModelProvider).phone;
    await ref.read(registrationViewModelProvider.notifier).hydrateVerifiedPhone(
          authPhone: authPhone,
          fetchProfilePhone: () async {
            try {
              final profile =
                  await ref.read(profileRepositoryProvider).getProfile();
              return profile.phone;
            } catch (_) {
              return null;
            }
          },
        );
  }

  void _openStep(DocumentCentreItem item) {
    if (item.isPermissions) {
      _openPermissionsSheet();
      return;
    }

    if (item.status == DocumentStepStatus.locked ||
        item.status == DocumentStepStatus.underVerification) {
      return;
    }

    switch (item.id) {
      case 'vehicle':
        context.push(RouteNames.captainVehicleSelection);
      case 'license':
        if (item.status == DocumentStepStatus.completed) {
          context.push(RouteNames.onboardingLicenseUpload);
        } else {
          context.push(RouteNames.drivingLicenseQuestion);
        }
      case 'photo_name':
        context.push(RouteNames.onboardingPhotoName);
      case 'vehicle_number':
        context.push(RouteNames.onboardingVehicleNumber);
      case 'kyc':
        context.push(RouteNames.onboardingKyc);
    }
  }

  Future<void> _openPermissionsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PermissionsSheet(),
    );
  }

  Future<void> _submitApplication() async {
    setState(() => _submitting = true);
    try {
      await ref.read(profileRepositoryProvider).submitRegistrationProgress();
      if (!mounted) return;
      context.go(RouteNames.verificationPending);
    } catch (e) {
      if (mounted) context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationViewModelProvider);
    final progress = DocumentCentreProgress.fromRegistration(
      registration,
      submitted: _submitted,
      serverStepStatus: _serverStepStatus,
    );
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Document Centre',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => context.push(RouteNames.support),
              icon: const Icon(Icons.headset_mic_outlined, size: 20),
              label: const Text('Help'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: padding.copyWith(top: 4, bottom: 16),
                children: [
                  if (progress.submitted) const _VerificationBanner(),
                  if (progress.submitted) const SizedBox(height: 16),
                  if (!progress.submitted) _UploadBanner(),
                  if (!progress.submitted) const SizedBox(height: 20),
                  _InfoChipRow(
                    onSupport: () => context.push(RouteNames.support),
                  ),
                  const SizedBox(height: 20),
                  ...progress.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DocumentStepTile(
                        item: item,
                        onTap: () => _openStep(item),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress.canSubmit)
              Padding(
                padding: padding.copyWith(bottom: 16),
                child: AppButton(
                  label: 'Submit Application',
                  variant: AppButtonVariant.secondary,
                  height: 56,
                  isLoading: _submitting,
                  onPressed: _submitApplication,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload the documents to start earning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete all steps to get activated',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documents under verification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.foreground,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This will take only 10 mins. Please wait!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.badge_outlined, size: 40, color: AppColors.warning),
        ],
      ),
    );
  }
}

class _InfoChipRow extends StatelessWidget {
  const _InfoChipRow({required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('Learn to upload', Icons.badge_outlined),
      ('Questions', Icons.chat_bubble_outline_rounded),
      ('Why Fast Bull', Icons.waves_rounded),
      ('Earnings', Icons.account_balance_wallet_outlined),
      ('Timings', Icons.schedule_rounded),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (label, icon) = chips[index];
          return InkWell(
            onTap: onSupport,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.lightSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentStepTile extends StatelessWidget {
  const _DocumentStepTile({
    required this.item,
    required this.onTap,
  });

  final DocumentCentreItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (item.status) {
      DocumentStepStatus.active => _ActiveStepCard(item: item, onTap: onTap),
      DocumentStepStatus.completed =>
        _CompletedStepCard(item: item, onTap: onTap),
      DocumentStepStatus.underVerification =>
        _VerificationStepCard(item: item),
      DocumentStepStatus.optional =>
        _OptionalStepCard(item: item, onTap: onTap),
      DocumentStepStatus.locked => _LockedStepCard(item: item),
    };
  }
}

class _ActiveStepCard extends StatelessWidget {
  const _ActiveStepCard({required this.item, required this.onTap});

  final DocumentCentreItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedStepCard extends StatelessWidget {
  const _CompletedStepCard({required this.item, required this.onTap});

  final DocumentCentreItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationStepCard extends StatelessWidget {
  const _VerificationStepCard({required this.item});

  final DocumentCentreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedStepCard extends StatelessWidget {
  const _LockedStepCard({required this.item});

  final DocumentCentreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: AppColors.textLight, size: 22),
        ],
      ),
    );
  }
}

class _OptionalStepCard extends StatelessWidget {
  const _OptionalStepCard({required this.item, required this.onTap});

  final DocumentCentreItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionsSheet extends StatelessWidget {
  const _PermissionsSheet();

  Future<void> _request(permission_handler.Permission permission) async {
    await permission.request();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'App Permissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Allow permissions for a smoother captain experience.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          _PermissionRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            onTap: () => _request(permission_handler.Permission.location),
          ),
          _PermissionRow(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            onTap: () => _request(permission_handler.Permission.camera),
          ),
          _PermissionRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => _request(permission_handler.Permission.notification),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Done',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: TextButton(onPressed: onTap, child: const Text('Allow')),
    );
  }
}
