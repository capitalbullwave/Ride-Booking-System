import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/responsive.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.directions_bike_rounded,
      color: AppColors.primary,
      title: 'Book Rides Instantly',
      subtitle:
          'Bike, auto, cab and parcel — get matched with nearby captains in seconds.',
    ),
    _OnboardingPageData(
      icon: Icons.local_shipping_rounded,
      color: AppColors.secondary,
      title: 'Send Parcels Safely',
      subtitle: 'Quick, secure deliveries with live tracking and insured packages.',
    ),
    _OnboardingPageData(
      icon: Icons.medical_services_rounded,
      color: AppColors.error,
      title: 'Emergency Ambulance',
      subtitle: '24/7 medical transport when every minute counts.',
    ),
    _OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primary,
      title: 'All Mobility, One App',
      subtitle: 'Join Bull Wave Rides and move smarter across your city.',
    ),
  ];

  Future<void> _complete() async {
    await ref.read(authRepositoryProvider).setOnboardingComplete();
    if (mounted) context.go(RouteNames.phoneLogin);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _complete, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: padding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 100, color: page.color),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: 48),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            _PageIndicator(count: _pages.length, currentIndex: _currentPage),
            const SizedBox(height: 32),
            Padding(
              padding: padding,
              child: isLastPage
                  ? AppButton(label: 'Get Started', onPressed: _complete)
                  : AppButton(
                      label: 'Next',
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.muted,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
