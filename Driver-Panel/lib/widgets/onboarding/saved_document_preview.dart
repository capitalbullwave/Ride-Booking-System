import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/media_url_resolver.dart';

class SavedDocumentPreview extends StatelessWidget {
  const SavedDocumentPreview({
    super.key,
    required this.path,
    this.label,
    this.height = 140,
  });

  final String? path;
  final String? label;
  final double height;

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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: height,
            color: AppColors.muted,
            child: _buildImage(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
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
    );
  }

  Widget _buildImage() {
    final value = path!;
    if (isLocalFilePath(value)) {
      if (kIsWeb) {
        return const Center(child: Icon(Icons.image_outlined, size: 40));
      }
      return Image.file(File(value), fit: BoxFit.cover, width: double.infinity);
    }

    final url = resolveMediaUrl(value);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }
}
