import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(WidgetRef ref, int index) {
    if (index == 0) {
      refreshVehicleCatalog(ref);
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(ref, 0),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Bookings',
                  isActive: navigationShell.currentIndex == 1,
                  onTap: () => _onTap(ref, 1),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  isActive: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(ref, 2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: navigationShell.currentIndex == 3,
                  onTap: () => _onTap(ref, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? Colors.white : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
