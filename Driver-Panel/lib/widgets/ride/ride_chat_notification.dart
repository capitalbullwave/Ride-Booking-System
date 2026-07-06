import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

void showRideChatNotification(
  BuildContext context, {
  required String senderName,
  required String message,
  VoidCallback? onTap,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentMaterialBanner();
  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            senderName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            messenger.hideCurrentMaterialBanner();
            onTap?.call();
          },
          child: const Text('Open', style: TextStyle(color: Colors.white)),
        ),
        IconButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
        ),
      ],
    ),
  );

  Future<void>.delayed(const Duration(seconds: 5), () {
    if (messenger.mounted) {
      messenger.hideCurrentMaterialBanner();
    }
  });
}
