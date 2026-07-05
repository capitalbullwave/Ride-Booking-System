import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/services/membership_service.dart';
import 'package:wavego_user/services/subscription_payment_service.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _selectingPlanSlug;

  Future<void> _selectPlan(SubscriptionPlanModel plan) async {
    if (_selectingPlanSlug != null) return;

    setState(() => _selectingPlanSlug = plan.slug);
    try {
      final activated = await ref.read(subscriptionPaymentControllerProvider).purchasePlan(
            plan,
            onCheckoutOpened: () {
              if (mounted) setState(() => _selectingPlanSlug = null);
            },
          );
      applyActiveMembershipPlan(ref, activated);
      await refreshActiveMembershipPlan(ref);
      if (!mounted) return;
      context.showSnackBar(
        plan.isFree ? 'Switched to Free plan' : '${activated.name} plan activated',
      );
      if (!plan.isFree) context.pop(true);
    } catch (error) {
      if (mounted) {
        final message = error.toString().replaceFirst('Exception: ', '');
        context.showSnackBar(
          message.contains('MissingPlugin')
              ? 'Payment is not supported here. Use the mobile app or website.'
              : message,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _selectingPlanSlug = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(membershipPlansProvider);
    final activePlanAsync = ref.watch(resolvedActiveMembershipPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Subscriptions')),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(membershipPlansProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (plans) {
          final activeSlug = activePlanAsync.valueOrNull?.slug ?? 'free';
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fast Bull Membership',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current plan: ${activePlanAsync.valueOrNull?.name ?? 'Free'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose your plan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...plans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(
                    plan: plan,
                    isActive: plan.slug == activeSlug,
                    isLoading: _selectingPlanSlug == plan.slug,
                    onSelect: () => _selectPlan(plan),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.isLoading,
    required this.onSelect,
  });

  final SubscriptionPlanModel plan;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : plan.isPopular
                    ? AppColors.secondary.withValues(alpha: 0.5)
                    : AppColors.border,
            width: isActive || plan.isPopular ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (plan.isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Popular',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(plan.description, style: TextStyle(color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.priceLabel,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      Text(
                        plan.periodLabel,
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...plan.benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(benefit)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                label: isActive
                    ? 'Current plan'
                    : plan.isFree
                        ? 'Switch to Free'
                        : 'Pay & Subscribe',
                isLoading: isLoading,
                onPressed: isActive ? null : onSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
