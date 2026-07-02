import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

class OnlineToggle extends StatelessWidget {
  const OnlineToggle({
    super.key,
    required this.isOnline,
    required this.onChanged,
    this.isLoading = false,
    this.canGoOnline = true,
    this.onBlockedGoOnline,
  });

  final bool isOnline;
  final ValueChanged<bool> onChanged;
  final bool isLoading;
  final bool canGoOnline;
  final VoidCallback? onBlockedGoOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.online.withValues(alpha: 0.12)
            : AppColors.offline.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOnline ? AppColors.online : AppColors.offline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isOnline ? AppColors.online : AppColors.offline,
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: isOnline,
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value && !canGoOnline) {
                        onBlockedGoOnline?.call();
                        return;
                      }
                      onChanged(value);
                    },
              activeColor: AppColors.online,
            ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.displayOffset = 1,
  });

  final int currentStep;
  final int totalSteps;
  /// When registration starts after OTP (step 1), pass `displayOffset: 2`.
  final int displayOffset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
