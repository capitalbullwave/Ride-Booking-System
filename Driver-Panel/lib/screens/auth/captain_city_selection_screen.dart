import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/auth/post_auth_navigation.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/responsive.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/data/location_data.dart';
import 'package:wavego_driver/providers/registration_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class CaptainCitySelectionScreen extends ConsumerStatefulWidget {
  const CaptainCitySelectionScreen({super.key});

  @override
  ConsumerState<CaptainCitySelectionScreen> createState() =>
      _CaptainCitySelectionScreenState();
}

class _CaptainCitySelectionScreenState
    extends ConsumerState<CaptainCitySelectionScreen> {
  late String _selectedCity;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(registrationViewModelProvider).city?.trim();
    _selectedCity = (saved != null && saved.isNotEmpty)
        ? saved
        : LocationData.defaultServiceCity;
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfAlreadyRegistered());
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

  Future<void> _openCityPicker() async {
    final cities = LocationData.allServiceCities;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityPickerSheet(
        cities: cities,
        selected: _selectedCity,
      ),
    );
    if (picked != null && picked != _selectedCity) {
      setState(() => _selectedCity = picked);
    }
  }

  void _confirmCity() {
    final state = LocationData.stateForCity(_selectedCity);
    ref.read(registrationViewModelProvider.notifier).updateRegistration(
          (r) => r.copyWith(
            country: LocationData.defaultCountry,
            state: state,
            city: _selectedCity,
          ),
        );
    context.go(RouteNames.captainVehicleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(RouteNames.support),
            icon: const Icon(Icons.headset_mic_outlined, size: 20),
            label: const Text('Help'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: padding.copyWith(top: 8, bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _LocationIllustration(),
                    const SizedBox(height: 32),
                    Text(
                      'Which city do you want to ride?',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You will ride in',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _selectedCity,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _openCityPicker,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            child: const Text(
                              'CHANGE',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: padding.copyWith(top: 0, bottom: 16),
              child: AppButton(
                label: 'Confirm City',
                variant: AppButtonVariant.secondary,
                height: 56,
                onPressed: _confirmCity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 28,
            bottom: 24,
            child: Icon(
              Icons.back_hand_outlined,
              size: 36,
              color: AppColors.secondaryDark.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.cities,
    required this.selected,
  });

  final List<String> cities;
  final String selected;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.trim().isEmpty) return widget.cities;
    final q = _query.trim().toLowerCase();
    return widget.cities
        .where((city) => city.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select your city',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No cities found',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final city = filtered[index];
                        final isSelected = city == widget.selected;
                        return ListTile(
                          title: Text(city),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () => Navigator.pop(context, city),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
