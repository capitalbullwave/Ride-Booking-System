import 'package:flutter/material.dart';
import 'package:wavego_user/core/constants/services.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  final HomeServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmergency = service.isEmergency;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isEmergency
                  ? AppColors.error.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isEmergency
                      ? AppColors.error.withValues(alpha: 0.08)
                      : AppColors.secondary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    service.imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      isEmergency ? Icons.medical_services : Icons.directions_car,
                      color: isEmergency ? AppColors.error : AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isEmergency ? AppColors.error : AppColors.foreground,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isEmergency
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.mutedForeground.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
