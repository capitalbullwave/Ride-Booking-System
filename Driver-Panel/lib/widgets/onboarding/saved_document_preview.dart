import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';

class SavedDocumentPreview extends StatelessWidget {
  const SavedDocumentPreview({
    super.key,
    required this.path,
    this.label,
    this.height = 120,
    this.fit = BoxFit.cover,
    this.showStatus = true,
  });

  final String? path;
  final String? label;
  final double height;
  final BoxFit fit;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    if (!hasUploadedMedia(path)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: height,
            color: AppColors.muted,
            child: DocumentPreviewImage(path: path!, fit: fit),
          ),
        ),
        if (showStatus) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Uploaded — tap below to replace',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail({
    super.key,
    required this.path,
    this.width = 88,
    this.height = 58,
    this.fit = BoxFit.cover,
  });

  final String path;
  final double width;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        color: AppColors.muted,
        child: DocumentPreviewImage(path: path, fit: fit),
      ),
    );
  }
}

class DocumentPreviewImage extends StatelessWidget {
  const DocumentPreviewImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('data:image')) {
      return _DataUrlImage(dataUrl: path, fit: fit);
    }

    if (path.startsWith('blob:')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _BrokenImage(),
      );
    }

    if (isLocalFilePath(path)) {
      return _LocalFileImage(path: path, fit: fit);
    }

    return CachedNetworkImage(
      imageUrl: resolveMediaUrl(path),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => const _BrokenImage(),
    );
  }
}

class _DataUrlImage extends StatelessWidget {
  const _DataUrlImage({required this.dataUrl, required this.fit});

  final String dataUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    try {
      final commaIndex = dataUrl.indexOf(',');
      if (commaIndex < 0) return const _BrokenImage();
      final bytes = base64Decode(dataUrl.substring(commaIndex + 1));
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const _BrokenImage(),
      );
    } catch (_) {
      return const _BrokenImage();
    }
  }
}

class _LocalFileImage extends StatelessWidget {
  const _LocalFileImage({required this.path, required this.fit});

  final String path;
  final BoxFit fit;

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
          return const Center(child: CircularProgressIndicator());
        }

        final bytes = snapshot.data;
        if (bytes == null) return const _BrokenImage();

        return Image.memory(
          bytes,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
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
