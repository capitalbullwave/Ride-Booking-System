import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';

class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({
    super.key,
    required this.photoPath,
    this.radius = 52,
    this.placeholderIcon = Icons.person,
  });

  final String? photoPath;
  final double radius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = hasUploadedMedia(photoPath);

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.muted,
      child: hasPhoto
          ? ClipOval(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: _ProfilePhotoImage(path: photoPath!),
              ),
            )
          : Icon(
              placeholderIcon,
              size: radius * 0.9,
              color: AppColors.textSecondary,
            ),
    );
  }
}

class _ProfilePhotoImage extends StatelessWidget {
  const _ProfilePhotoImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('data:image')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    if (isLocalFilePath(path)) {
      if (kIsWeb) {
        return const Center(child: Icon(Icons.image_outlined, size: 40));
      }
      return Image.file(File(path), fit: BoxFit.cover);
    }

    return CachedNetworkImage(
      imageUrl: resolveMediaUrl(path),
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }
}
