import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/providers/profile_display_provider.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/services/membership_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshUserProfile(ref);
      ref.invalidate(studentPassProvider);
      refreshActiveMembershipPlan(ref);
    });
  }

  static const _menuItems = [
    _ProfileMenuItem(
      icon: Icons.settings_outlined,
      label: 'Account Settings',
      route: RouteNames.profileSettings,
    ),
    _ProfileMenuItem(
      icon: Icons.place_outlined,
      label: 'Saved Places',
      route: RouteNames.profileSavedPlaces,
    ),
    _ProfileMenuItem(
      icon: Icons.workspace_premium_outlined,
      label: 'Subscriptions',
      route: RouteNames.profileSubscription,
    ),
    _ProfileMenuItem(
      icon: Icons.school_outlined,
      label: 'Student Pass',
      route: RouteNames.profileStudentPass,
    ),
    _ProfileMenuItem(
      icon: Icons.help_outline,
      label: 'Help & Support',
      route: RouteNames.profileHelp,
    ),
    _ProfileMenuItem(
      icon: Icons.info_outline,
      label: 'About Fast Bull',
      route: RouteNames.profileAbout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final labelAsync = ref.watch(resolvedProfileLabelProvider);
    final activePlanAsync = ref.watch(resolvedActiveMembershipPlanProvider);
    final studentPassAsync = ref.watch(studentPassProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () async => refreshUserProfile(ref),
        child: labelAsync.when(
          loading: () => ListView(
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (_, __) => ListView(
            children: [
              const SizedBox(height: 120),
              const Center(child: Text('Unable to load profile')),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => refreshUserProfile(ref),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
          data: (resolved) {
          final name = resolved.name;
          final phone = resolved.phone;
          final initial = resolved.initial;
          final rating = resolved.rating;
          final totalRides = resolved.totalRides;
          final badgeLabel = totalRides > 0
              ? '$totalRides Trips'
              : '${rating.toStringAsFixed(rating == rating.roundToDouble() ? 0 : 1)} Rating';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => context.push(RouteNames.profileSettings),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                phone,
                                style: TextStyle(color: AppColors.mutedForeground),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      badgeLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SubscriptionSection(
                plan: activePlanAsync.valueOrNull,
                onOpenSubscription: () async {
                  final updated = await context.push<bool>(RouteNames.profileSubscription);
                  if (updated == true) {
                    await refreshActiveMembershipPlan(ref);
                  }
                },
              ),
              if (studentPassAsync.valueOrNull != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _StudentPassStatusChip(application: studentPassAsync.value!),
                ),
              const SizedBox(height: 16),
              ..._menuItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MenuTile(
                    item: item,
                    onTap: item.route == RouteNames.profileSubscription
                        ? () async {
                            final updated =
                                await context.push<bool>(RouteNames.profileSubscription);
                            if (updated == true) {
                              await refreshActiveMembershipPlan(ref);
                            }
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: AppColors.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  onTap: () async {
                    await ref.read(authRepositoryProvider).logout();
                    if (context.mounted) context.go(RouteNames.phoneLogin);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.error),
                        SizedBox(width: 12),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({
    required this.plan,
    required this.onOpenSubscription,
  });

  final SubscriptionPlanModel? plan;
  final Future<void> Function() onOpenSubscription;

  @override
  Widget build(BuildContext context) {
    final isFree = plan == null || plan!.slug == 'free';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenSubscription,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFree ? 'Upgrade to Fast Bull Plus' : '${plan!.name} Member',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFree
                            ? 'Priority rides, ride discounts & more'
                            : plan!.benefits.isNotEmpty
                                ? plan!.benefits.first
                                : 'Member benefits active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentPassStatusChip extends StatelessWidget {
  const _StudentPassStatusChip({required this.application});

  final StudentPassApplication application;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (application.status) {
      'approved' => ('Student Pass verified • 20% off', AppColors.success),
      'rejected' => ('Student Pass rejected', AppColors.error),
      _ => ('Student Pass pending verification', AppColors.warning),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => context.push(RouteNames.profileStudentPass),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.school_outlined, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    this.onTap,
  });

  final _ProfileMenuItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap ?? () => context.push(item.route),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppColors.mutedForeground),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
