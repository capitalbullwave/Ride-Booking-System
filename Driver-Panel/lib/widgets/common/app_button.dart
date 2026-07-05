import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expand = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: variant == AppButtonVariant.outline ||
                          variant == AppButtonVariant.ghost
                      ? AppColors.primary
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final minSize = Size(0, height);

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: minSize,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: child,
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.foreground,
            minimumSize: minSize,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: minSize,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            minimumSize: minSize,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };

    return SizedBox(
      width: expand ? double.infinity : null,
      child: button,
    );
  }
}
