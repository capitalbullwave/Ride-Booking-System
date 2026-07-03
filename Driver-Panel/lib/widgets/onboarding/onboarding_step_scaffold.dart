import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actionLabel = 'Continue',
    this.onAction,
    this.isLoading = false,
    this.actionEnabled = true,
    this.showHero = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;
  final bool actionEnabled;
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (showHero) const _HeroPanel(),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push(RouteNames.support),
                  icon: const Icon(Icons.headset_mic_outlined, size: 18),
                  label: const Text('Help'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.62,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Flexible(child: SingleChildScrollView(child: child)),
                  const SizedBox(height: 16),
                  AppButton(
                    label: actionLabel,
                    height: 54,
                    variant: AppButtonVariant.secondary,
                    isLoading: isLoading,
                    onPressed: actionEnabled ? onAction : null,
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F3344), Color(0xFF31526E)],
        ),
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.25),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary, width: 3),
          ),
          child: const Icon(Icons.person_rounded, size: 58, color: Colors.white),
        ),
      ),
    );
  }
}

class OnboardingUploadActions extends StatelessWidget {
  const OnboardingUploadActions({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.cameraLabel = 'Take photo',
    this.galleryLabel = 'Upload from gallery',
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final String cameraLabel;
  final String galleryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: cameraLabel,
          icon: Icons.photo_camera_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: onCamera,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onGallery,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(galleryLabel),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
          ),
        ),
      ],
    );
  }
}
