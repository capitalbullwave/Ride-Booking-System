import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
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
      return _DataUrlImage(dataUrl: path);
    }

    if (path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BrokenImage(),
      );
    }

    if (isLocalFilePath(path)) {
      return _LocalFileImage(path: path);
    }

    return CachedNetworkImage(
      imageUrl: resolveMediaUrl(path),
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => const _BrokenImage(),
    );
  }
}

class _DataUrlImage extends StatelessWidget {
  const _DataUrlImage({required this.dataUrl});

  final String dataUrl;

  @override
  Widget build(BuildContext context) {
    try {
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex < 0) return const _BrokenImage();
      final bytes = base64Decode(dataUrl.substring(commaIndex + 1));
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _BrokenImage(),
      );
    } catch (_) {
      return const _BrokenImage();
    }
  }
}

class _LocalFileImage extends StatelessWidget {
  const _LocalFileImage({required this.path});

  final String path;

  Future<Uint8List?> _loadBytes() async {
    try {
      final bytes = await XFile(path).readAsBytes();
      return bytes.isEmpty ? null : bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _loadBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final bytes = snapshot.data;
        if (bytes == null) return const _BrokenImage();

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _BrokenImage(),
        );
      },
    );
  }
}

class _BrokenImage extends StatelessWidget {
  const _BrokenImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.broken_image_outlined, size: 40),
    );
  }
}
