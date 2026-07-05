import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/online_toggle.dart';

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
      icon: Icons.directions_car_rounded,
      color: AppColors.primary,
      title: 'Drive With Freedom',
      subtitle: 'Be your own boss. Choose when and where you want to drive with complete flexibility.',
    ),
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.secondary,
      title: 'Earn More Every Day',
      subtitle: 'Maximize your earnings with surge pricing, bonuses, and weekly incentives.',
    ),
    _OnboardingPageData(
      icon: Icons.emergency_rounded,
      color: AppColors.info,
      title: 'Safe & Secure Platform',
      subtitle: 'Drive with confidence. SOS support, verified passengers, and 24/7 assistance.',
    ),
    _OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primary,
      title: 'Start Driving Today',
      subtitle: 'Join thousands of captains earning with Fast Bull. Register in minutes.',
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
              child: TextButton(
                onPressed: _complete,
                child: const Text('Skip'),
              ),
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
            PageIndicator(count: _pages.length, currentIndex: _currentPage),
            const SizedBox(height: 32),
            Padding(
              padding: padding,
              child: isLastPage
                  ? AppButton(
                      label: 'Get Started',
                      onPressed: _complete,
                    )
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
