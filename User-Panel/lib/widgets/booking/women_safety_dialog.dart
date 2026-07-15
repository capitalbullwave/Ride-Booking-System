import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

Future<bool?> showWomenSafetyDialog(
  BuildContext context, {
  String? emergencyPhone,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => WomenSafetyDialog(emergencyPhone: emergencyPhone),
  );
}

class WomenSafetyDialog extends StatelessWidget {
  const WomenSafetyDialog({super.key, this.emergencyPhone});

  final String? emergencyPhone;

  @override
  Widget build(BuildContext context) {
    final phone = emergencyPhone?.trim();
    final phoneHint = phone != null && phone.isNotEmpty ? ' ($phone)' : '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enable Women Safety?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Turn on Women Safety to alert your emergency contact$phoneHint '
              'and our admin team about this ride. You will also receive a '
              'confirmation on your phone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Enable & book ride',
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue without safety'),
            ),
          ],
        ),
      ),
    );
  }
}
