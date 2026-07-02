import 'package:flutter/material.dart';
import 'package:wavego_driver/core/constants/camera_strings.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/services/camera_exception_handler.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class CameraErrorPanel extends StatelessWidget {
  const CameraErrorPanel({
    super.key,
    required this.reason,
    required this.onRetry,
    required this.onClose,
    required this.onOpenSettings,
  });

  final CameraFailureReason reason;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final canOpenSettings = CameraExceptionHandler.canOpenSettings(reason);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _iconFor(reason),
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Text(
            CameraExceptionHandler.messageFor(reason),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          AppButton(label: CameraStrings.retry, onPressed: onRetry),
          if (canOpenSettings) ...[
            const SizedBox(height: 12),
            AppButton(
              label: CameraStrings.openSettings,
              variant: AppButtonVariant.outline,
              onPressed: onOpenSettings,
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: CameraStrings.close,
            variant: AppButtonVariant.ghost,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(CameraFailureReason reason) {
    return switch (reason) {
      CameraFailureReason.noCamera => Icons.videocam_off_outlined,
      CameraFailureReason.permissionDenied ||
      CameraFailureReason.permissionPermanentlyDenied ||
      CameraFailureReason.permissionRestricted ||
      CameraFailureReason.permissionLimited =>
        Icons.lock_outline,
      CameraFailureReason.cameraInUse => Icons.cameraswitch_outlined,
      CameraFailureReason.unavailableOnPlatform ||
      CameraFailureReason.browserUnsupported =>
        Icons.desktop_windows_outlined,
      _ => Icons.error_outline,
    };
  }
}

class CameraLoadingPanel extends StatelessWidget {
  const CameraLoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          SizedBox(height: 16),
          Text(
            CameraStrings.initializingCamera,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
