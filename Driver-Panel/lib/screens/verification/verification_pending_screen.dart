import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Submitted!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Verification Pending',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Our team is reviewing your documents. This usually takes up to ${AppConfig.verificationEstimateHours} hours.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'You\'ll receive a notification once your account is approved.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Back to Home',
                onPressed: () => context.go(RouteNames.dashboard),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Contact Support',
                variant: AppButtonVariant.outline,
                icon: Icons.support_agent,
                onPressed: () => context.push(RouteNames.support),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
