import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class AppDialog {
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppButtonVariant confirmVariant = AppButtonVariant.primary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          AppButton(
            label: confirmLabel,
            expand: false,
            variant: confirmVariant,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: 'OK',
            expand: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          AppButton(
            label: 'OK',
            expand: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
