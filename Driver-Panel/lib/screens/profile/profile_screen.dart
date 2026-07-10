import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/account_verification_status.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/providers/auth_provider.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';
import 'package:wavego_driver/widgets/profile/profile_photo_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  AccountVerificationMap? _accountStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
      if (!mounted) return;
      await ref.read(dashboardViewModelProvider.notifier).refreshProfile();
      await _loadAccountStatus();
    });
  }

  Future<void> _loadAccountStatus() async {
    try {
      final progress =
          await ref.read(profileRepositoryProvider).getRegistrationProgress();
      if (!mounted) return;
      setState(() => _accountStatus = AccountVerificationMap.fromProgress(progress));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardViewModelProvider);
    final profile = dashboard.profile;
    final stats = switch (dashboard.statsState) {
      ViewStateSuccess(:final data) => data,
      _ => null,
    };
    final isOnline = dashboard.isOnline;
    final isVerified = profile?.verificationStatus == 'verified';
    final tripCount = stats?.completedTrips ?? profile?.totalTrips ?? 0;
    final ratingValue = stats?.rating ?? profile?.rating ?? 4.5;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                      AppColors.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white24,
                              child: ProfilePhotoAvatar(
                                photoPath: profile?.avatar,
                                radius: 48,
                              ),
                            ),
                            if (isVerified)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified, color: Colors.white, size: 18),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile?.name ?? 'Driver',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID · ${profile?.id.substring(0, 8).toUpperCase() ?? '—'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _HeaderChip(
                              icon: Icons.phone_outlined,
                              label: profile?.phone ?? '',
                            ),
                            const SizedBox(width: 8),
                            _HeaderChip(
                              icon: Icons.star_rounded,
                              label: ratingValue.toStringAsFixed(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(RouteNames.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Trips',
                          value: '$tripCount',
                          icon: Icons.local_taxi_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Rating',
                          value: ratingValue.toStringAsFixed(1),
                          icon: Icons.star_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Availability',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isOnline ? AppColors.success : AppColors.textSecondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(isOnline ? 'Online' : 'Offline'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              OnlineToggle(
                                isOnline: isOnline,
                                isLoading: dashboard.isTogglingOnline,
                                canGoOnline: dashboard.canGoOnline,
                                onBlockedGoOnline: () => context.showSnackBar(
                                  profile?.verificationStatus == 'rejected'
                                      ? 'Your documents were rejected. Please update and resubmit.'
                                      : 'Account verification is pending. You can go online after admin approval.',
                                  isError: true,
                                ),
                                onChanged: (v) async {
                                  final error = await ref
                                      .read(dashboardViewModelProvider.notifier)
                                      .toggleOnline(v);
                                  if (error != null && context.mounted) {
                                    context.showSnackBar(error, isError: true);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Account'),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _ProfileMenuItem(
                        Icons.person_outline,
                        'Personal Information',
                        RouteNames.editProfile,
                      ),
                      _ProfileMenuItem(
                        Icons.directions_car_outlined,
                        'Vehicle Details',
                        RouteNames.onboardingVehicleNumber,
                        statusId: 'vehicle',
                        fromProfile: true,
                      ),
                      _ProfileMenuItem(
                        Icons.badge_outlined,
                        'Driving License',
                        RouteNames.onboardingLicenseUpload,
                        statusId: 'license',
                        fromProfile: true,
                      ),
                      _ProfileMenuItem(
                        Icons.fingerprint_outlined,
                        'Aadhaar Card',
                        RouteNames.onboardingKyc,
                        statusId: 'aadhaar',
                        fromProfile: true,
                        docType: 'aadhaar',
                      ),
                      _ProfileMenuItem(
                        Icons.credit_card_outlined,
                        'PAN Card',
                        RouteNames.onboardingKyc,
                        statusId: 'pan',
                        fromProfile: true,
                        docType: 'pan',
                      ),
                      _ProfileMenuItem(
                        Icons.description_outlined,
                        'Vehicle RC',
                        RouteNames.onboardingVehicleNumber,
                        statusId: 'vehicle_rc',
                        fromProfile: true,
                      ),
                      _ProfileMenuItem(
                        Icons.account_balance_outlined,
                        'Bank Details',
                        RouteNames.wallet,
                        statusId: 'bank',
                      ),
                      _ProfileMenuItem(
                        Icons.contact_emergency_outlined,
                        'Emergency Contact',
                        RouteNames.emergencyContacts,
                      ),
                    ],
                    accountStatus: _accountStatus,
                    onItemTap: () => _loadAccountStatus(),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Performance'),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _ProfileMenuItem(Icons.analytics_outlined, 'Ride Statistics', RouteNames.rideStatistics),
                      _ProfileMenuItem(Icons.payments_outlined, 'Earnings', RouteNames.earnings),
                      _ProfileMenuItem(Icons.account_balance_wallet_outlined, 'Wallet', RouteNames.wallet),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Support & Safety'),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _ProfileMenuItem(Icons.help_center_outlined, 'Help Center', RouteNames.support),
                      _ProfileMenuItem(Icons.emergency_outlined, 'SOS', RouteNames.sos, color: AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Logout',
                    variant: AppButtonVariant.danger,
                    icon: Icons.logout,
                    onPressed: () async {
                      final confirmed = await AppDialog.showConfirm(
                        context: context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        confirmVariant: AppButtonVariant.danger,
                      );
                      if (confirmed == true) {
                        await ref.read(authViewModelProvider.notifier).logout();
                        if (context.mounted) context.go(RouteNames.phoneLogin);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem(
    this.icon,
    this.label,
    this.route, {
    this.color,
    this.statusId,
    this.fromProfile = false,
    this.docType,
  });

  final IconData icon;
  final String label;
  final String route;
  final Color? color;
  final String? statusId;
  final bool fromProfile;
  final String? docType;

  String get navigationRoute {
    final params = <String, String>{};
    if (fromProfile) params['from'] = 'profile';
    if (docType != null) params['type'] = docType!;
    if (params.isEmpty) return route;
    return Uri(path: route, queryParameters: params).toString();
  }
}

class _AccountStatusIndicator extends StatelessWidget {
  const _AccountStatusIndicator({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 22,
      );
    }

    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.items,
    this.accountStatus,
    this.onItemTap,
  });

  final List<_ProfileMenuItem> items;
  final AccountVerificationMap? accountStatus;
  final VoidCallback? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon, color: items[i].color ?? AppColors.primary),
              title: Text(items[i].label),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (items[i].statusId != null && accountStatus != null)
                    _AccountStatusIndicator(
                      verified: accountStatus!.isVerified(items[i].statusId!),
                    ),
                  if (items[i].statusId != null && accountStatus != null)
                    const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              onTap: () async {
                await context.push(items[i].navigationRoute);
                onItemTap?.call();
              },
            ),
            if (i < items.length - 1)
              Divider(height: 1, indent: 56, color: AppColors.border.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }
}
