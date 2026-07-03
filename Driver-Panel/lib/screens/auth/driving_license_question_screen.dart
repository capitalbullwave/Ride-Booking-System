import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

enum DrivingLicenseChoice { yes, no }

final drivingLicenseChoiceProvider =
    StateProvider<DrivingLicenseChoice?>((ref) => null);

class DrivingLicenseQuestionScreen extends ConsumerStatefulWidget {
  const DrivingLicenseQuestionScreen({super.key});

  @override
  ConsumerState<DrivingLicenseQuestionScreen> createState() =>
      _DrivingLicenseQuestionScreenState();
}

class _DrivingLicenseQuestionScreenState
    extends ConsumerState<DrivingLicenseQuestionScreen> {
  bool _muted = true;

  void _continue() {
    final choice = ref.read(drivingLicenseChoiceProvider);
    if (choice == null) return;

    if (choice == DrivingLicenseChoice.no) {
      context.showSnackBar(
        'A valid driving license is required for WaveGo Captain rides.',
        isError: true,
      );
      return;
    }

    context.push(RouteNames.onboardingLicenseUpload);
  }

  @override
  Widget build(BuildContext context) {
    final choice = ref.watch(drivingLicenseChoiceProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _HeroBackground(),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'अ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 72,
            right: 16,
            child: Column(
              children: [
                _OverlayIconButton(
                  icon: _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  onTap: () => setState(() => _muted = !_muted),
                ),
                const SizedBox(height: 10),
                _OverlayIconButton(
                  icon: Icons.replay_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
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
                    'Do you have a Driving License?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _LicenseOptionTile(
                    title: 'Yes',
                    subtitle: 'Bike Taxi + Delivery orders',
                    value: DrivingLicenseChoice.yes,
                    groupValue: choice,
                    onChanged: (value) => ref
                        .read(drivingLicenseChoiceProvider.notifier)
                        .state = value,
                  ),
                  const SizedBox(height: 12),
                  _LicenseOptionTile(
                    title: 'No',
                    subtitle: 'For Parcel & Food Deliveries',
                    value: DrivingLicenseChoice.no,
                    groupValue: choice,
                    onChanged: (value) => ref
                        .read(drivingLicenseChoiceProvider.notifier)
                        .state = value,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Continue',
                    height: 54,
                    variant: choice == null
                        ? AppButtonVariant.outline
                        : AppButtonVariant.secondary,
                    onPressed: choice == null ? null : _continue,
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

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1F3344),
            Color(0xFF31526E),
            Color(0xFF4A6B87),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 120,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'WaveGo Captain',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _LicenseOptionTile extends StatelessWidget {
  const _LicenseOptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final DrivingLicenseChoice value;
  final DrivingLicenseChoice? groupValue;
  final ValueChanged<DrivingLicenseChoice?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;

    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Radio<DrivingLicenseChoice>(
                  value: value,
                  groupValue: groupValue,
                  activeColor: AppColors.primary,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
