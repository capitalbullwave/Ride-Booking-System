import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: cardColor),
                  ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cardColor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        gradient: AppColors.glassGradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: child,
    );
  }
}
