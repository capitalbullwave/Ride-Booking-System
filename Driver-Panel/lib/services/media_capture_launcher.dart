import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wavego_driver/core/constants/camera_strings.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/services/camera_exception_handler.dart';
import 'package:wavego_driver/widgets/camera/camera_capture_screen.dart';

/// Entry point for camera/gallery capture across the app.
class MediaCaptureLauncher {
  MediaCaptureLauncher._();

  static Future<String?> captureSelfie(BuildContext context, WidgetRef ref) {
    return openCamera(
      context,
      ref,
      lens: CameraLensPreference.front,
      title: CameraStrings.takeSelfieTitle,
      hint: CameraStrings.positionFaceHint,
    );
  }

  static Future<String?> captureDocument(BuildContext context, WidgetRef ref) {
    return openCamera(
      context,
      ref,
      lens: CameraLensPreference.back,
      title: CameraStrings.captureDocumentTitle,
      hint: CameraStrings.alignDocumentHint,
    );
  }

  static Future<String?> openCamera(
    BuildContext context,
    WidgetRef ref, {
    required CameraLensPreference lens,
    required String title,
    required String hint,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CameraCaptureScreen(
          lens: lens,
          title: title,
          hint: hint,
        ),
      ),
    );
  }

  static Future<String?> pickFromGallery(WidgetRef ref) async {
    final permission = await ref.read(permissionServiceProvider).ensureGalleryAccess();
    if (!permission.granted) return null;

    final file = await ref.read(imagePickerProvider).pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
    return file?.path;
  }

  static Future<String?> showImageSourceSheet(
    BuildContext context,
    WidgetRef ref, {
    CameraLensPreference lens = CameraLensPreference.back,
    bool allowGallery = true,
  }) async {
    final action = await showModalBottomSheet<_MediaSourceAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                CameraStrings.chooseSourceTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text(CameraStrings.takePhoto),
                onTap: () => Navigator.pop(context, _MediaSourceAction.camera),
              ),
              if (allowGallery)
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text(CameraStrings.chooseFromGallery),
                  onTap: () => Navigator.pop(context, _MediaSourceAction.gallery),
                ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return null;

    return switch (action) {
      _MediaSourceAction.camera => openCamera(
          context,
          ref,
          lens: lens,
          title: lens == CameraLensPreference.front
              ? CameraStrings.takeSelfieTitle
              : CameraStrings.captureDocumentTitle,
          hint: lens == CameraLensPreference.front
              ? CameraStrings.positionFaceHint
              : CameraStrings.alignDocumentHint,
        ),
      _MediaSourceAction.gallery => pickFromGallery(ref),
    };
  }

  static String? permissionMessage(CameraFailureReason? reason) {
    if (reason == null) return null;
    return CameraExceptionHandler.messageFor(reason);
  }
}

enum _MediaSourceAction { camera, gallery }
