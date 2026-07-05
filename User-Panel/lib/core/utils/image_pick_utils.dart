import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum _ImagePickAction { gallery, camera }

/// Picks an image after optional source selection and runtime permission checks.
class ImagePickUtils {
  ImagePickUtils._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage(BuildContext context) async {
    final action = await showModalBottomSheet<_ImagePickAction>(
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
                'Upload document',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, _ImagePickAction.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, _ImagePickAction.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || action == null) return null;

    final granted = await _ensurePermission(action);
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo permission is required. Enable it in app settings.'),
          ),
        );
      }
      return null;
    }

    try {
      return await _picker.pickImage(
        source: action == _ImagePickAction.gallery
            ? ImageSource.gallery
            : ImageSource.camera,
        imageQuality: 80,
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open image picker: $error')),
        );
      }
      return null;
    }
  }

  static Future<bool> _ensurePermission(_ImagePickAction action) async {
    if (kIsWeb) return true;

    if (action == _ImagePickAction.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }

    if (!kIsWeb && Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }

    final photos = await Permission.photos.request();
    return photos.isGranted || photos.isLimited;
  }
}
