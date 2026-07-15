import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/media_utils.dart';

/// Circular captain photo with rating chip overlaid at the bottom.
class DriverAvatarWithRating extends StatelessWidget {
  const DriverAvatarWithRating({
    super.key,
    required this.name,
    this.photoUrl,
    this.rating,
    this.radius = 20,
  });

  final String name;
  final String? photoUrl;
  final double? rating;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'C';
    final resolved = resolveMediaUrl(photoUrl);
    final hasRating = rating != null && rating! > 0;
    final size = radius * 2;

    return SizedBox(
      width: size,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            clipBehavior: Clip.antiAlias,
            child: resolved != null
                ? Image.network(
                    resolved,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Initial(initial: initial, radius: radius),
                  )
                : _Initial(initial: initial, radius: radius),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasRating ? rating!.toStringAsFixed(1) : 'New',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.star_rounded,
                    size: 10,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.initial, required this.radius});

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
