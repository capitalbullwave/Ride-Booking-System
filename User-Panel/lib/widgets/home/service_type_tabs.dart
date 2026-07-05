import 'package:flutter/material.dart';
import 'package:wavego_user/core/constants/home_booking_mode.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';

class ServiceTypeTabs extends StatelessWidget {
  const ServiceTypeTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HomeBookingMode selected;
  final ValueChanged<HomeBookingMode> onChanged;

  static const _modes = HomeBookingMode.values;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: _modes.map((mode) {
          final isSelected = mode == selected;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(mode),
                borderRadius: BorderRadius.circular(AppRadius.card - 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.card - 2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    mode.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.mutedForeground,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
