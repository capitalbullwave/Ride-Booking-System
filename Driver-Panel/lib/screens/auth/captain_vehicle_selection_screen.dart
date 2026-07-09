import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/auth/post_auth_navigation.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/data/captain_vehicle_options.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class CaptainVehicleSelectionScreen extends ConsumerStatefulWidget {
  const CaptainVehicleSelectionScreen({super.key});

  @override
  ConsumerState<CaptainVehicleSelectionScreen> createState() =>
      _CaptainVehicleSelectionScreenState();
}

class _CaptainVehicleSelectionScreenState
    extends ConsumerState<CaptainVehicleSelectionScreen> {
  String? _selectedId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAlreadyRegistered();
      _loadSaved();
    });
  }

  Future<void> _redirectIfAlreadyRegistered() async {
    final route = await PostAuthNavigation.resolveRoute(
      profileRepo: ref.read(profileRepositoryProvider),
      localStorage: ref.read(localStorageProvider),
    );
    if (!mounted) return;
    if (PostAuthNavigation.shouldLeaveEarlyOnboarding(route)) {
      context.go(route);
    }
  }

  Future<void> _loadSaved() async {
    await ref.read(registrationViewModelProvider.notifier).hydrateFromServer();
    if (!mounted) return;
    final saved = ref.read(registrationViewModelProvider).vehicleType;
    setState(() {
      _selectedId = CaptainVehicleOptions.byRegistrationType(saved)?.id;
    });
  }

  Future<void> _confirmVehicle() async {
    final selectedId = _selectedId;
    if (selectedId == null) return;

    final option =
        CaptainVehicleOptions.all.firstWhere((o) => o.id == selectedId);

    setState(() => _saving = true);
    try {
      final vehicleTypeId =
          await ref.read(profileRepositoryProvider).resolveVehicleTypeId(
                option.registrationType,
              );
      if (vehicleTypeId == null) {
        throw const ValidationException(
          'Could not match this vehicle type on the server. Please try another option or contact support.',
        );
      }

      await ref.read(profileRepositoryProvider).saveVehicleType(
            vehicleTypeId: vehicleTypeId,
          );

      ref.read(registrationViewModelProvider.notifier).updateRegistration(
            (r) => r.copyWith(vehicleType: option.registrationType),
          );

      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.documentCentre);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.userMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    final hasSelection = _selectedId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Vehicle',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => context.push(RouteNames.support),
              icon: const Icon(Icons.headset_mic_outlined, size: 20),
              label: const Text('Help'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                padding: padding.copyWith(top: 12, bottom: 24),
                itemCount: CaptainVehicleOptions.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final option = CaptainVehicleOptions.all[index];
                  final isSelected = _selectedId == option.id;
                  return _VehicleOptionCard(
                    option: option,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedId = option.id),
                  );
                },
              ),
            ),
            Padding(
              padding: padding.copyWith(top: 0, bottom: 16),
              child: AppButton(
                label: 'Confirm Vehicle',
                variant: AppButtonVariant.secondary,
                height: 56,
                isLoading: _saving,
                onPressed: hasSelection && !_saving ? _confirmVehicle : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleOptionCard extends StatelessWidget {
  const _VehicleOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CaptainVehicleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 72,
                  decoration: BoxDecoration(
                    color: option.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    option.icon,
                    size: 44,
                    color: option.iconColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
