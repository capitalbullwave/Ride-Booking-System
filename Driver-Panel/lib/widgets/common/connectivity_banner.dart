import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/services/connectivity_service.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);

    return connectivity.when(
      data: (isOnline) => Stack(
        children: [
          child,
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: isOnline ? const Offset(0, -1) : Offset.zero,
            child: Material(
              color: AppColors.error,
              elevation: 4,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'re offline. Some features may be unavailable.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
