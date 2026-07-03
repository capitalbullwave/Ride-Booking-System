import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/media_utils.dart';
import 'package:wavego_user/core/utils/rental_pricing.dart';
import 'package:wavego_user/core/utils/vehicle_utils.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/rental_booking_provider.dart';
import 'package:wavego_user/providers/trip_booking_provider.dart';
import 'package:wavego_user/services/places_service.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class RentalHoursScreen extends ConsumerStatefulWidget {
  const RentalHoursScreen({super.key});

  @override
  ConsumerState<RentalHoursScreen> createState() => _RentalHoursScreenState();
}

class _RentalHoursScreenState extends ConsumerState<RentalHoursScreen> {
  double? _hours;
  ProviderSubscription<AsyncValue<List<VehicleCategory>>>? _rentalCategoriesSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rentalBookingProvider.notifier).reset();
    });

    _rentalCategoriesSub = ref.listenManual<AsyncValue<List<VehicleCategory>>>(
      rentalCategoriesProvider,
      (previous, next) {
        next.whenData((categories) {
          final min = rentalMinHours(categories);
          // Safe: listener runs outside widget build.
          ref.read(rentalBookingProvider.notifier).setMinHours(min);
          if (!mounted) return;
          // Default hours to min hours on first load (or when admin raises min).
          final current = _hours;
          if (current == null || current < min) {
            setState(() => _hours = min);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _rentalCategoriesSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rentalAsync = ref.watch(rentalCategoriesProvider);
    final minHours = rentalAsync.maybeWhen(
      data: (cats) => rentalMinHours(cats),
      orElse: () => 4.0,
    );
    final hours = _hours ?? minHours;

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Duration')),
      body: rentalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _RentalErrorBody(message: e.toString()),
        data: (categories) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _RentalStepHeader(step: 1, total: 5, title: 'How many hours?'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${hours.round()} hours',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Minimum ${minHours.round()} hours',
                        style: TextStyle(color: AppColors.mutedForeground),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _HourButton(
                            icon: Icons.remove,
                            onTap: hours > minHours
                                ? () => setState(() => _hours = hours - 1)
                                : null,
                          ),
                          const SizedBox(width: 24),
                          _HourButton(
                            icon: Icons.add,
                            onTap: hours < 24
                                ? () => setState(() => _hours = hours + 1)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Slider(
                        value: hours.clamp(minHours, 24),
                        min: minHours,
                        max: 24,
                        divisions: (24 - minHours).round(),
                        label: '${hours.round()} hrs',
                        onChanged: (v) => setState(() => _hours = v),
                      ),
                      const Spacer(),
                      Text(
                        'Hourly rental only — no per-km charges in this flow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Continue',
                  onPressed: categories.isEmpty
                      ? null
                      : () {
                          ref.read(rentalBookingProvider.notifier).setHours(hours);
                          context.push(RouteNames.rentalVehicles);
                        },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class RentalVehiclesScreen extends ConsumerWidget {
  const RentalVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentalAsync = ref.watch(rentalCategoriesProvider);
    final booking = ref.watch(rentalBookingProvider);
    final hours = booking.selectedHours ?? booking.minHours;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Vehicle')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RentalStepHeader(step: 2, total: 5, title: 'Select rental vehicle'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'For ${hours.round()} hours',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: rentalAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _RentalErrorBody(message: e.toString()),
              data: (categories) {
                final items = categories.isNotEmpty
                    ? categories
                    : _fallbackCategories();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final category = items[index];
                    final fare = rentalFareForHours(category, hours);
                    final imageUrl = isMediaUrl(category.iconUrl)
                        ? resolveMediaUrl(category.iconUrl)
                        : null;

                    return _RentalVehicleTile(
                      title: category.name,
                      description: category.description ?? 'Hourly rental package',
                      price: '₹${fare.round()}',
                      subtitle:
                          '${(category.includedHours ?? 4).round()} hrs package · ₹${(category.perHourRate ?? 0).round()}/extra hr',
                      imageAsset: vehicleImageAssetForSlug(category.slug),
                      imageUrl: imageUrl,
                      onTap: () {
                        ref.read(rentalBookingProvider.notifier).setCategory(category);
                        context.push(RouteNames.rentalPickup);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<VehicleCategory> _fallbackCategories() => const [
        VehicleCategory(
          id: 'rental-bike',
          slug: 'rental-bike',
          name: 'Rental Bike',
          description: 'Rent a bike by the hour',
          baseFare: 199,
          perKmRate: 0,
          includedHours: 4,
          perHourRate: 50,
          serviceGroup: 'rental',
        ),
        VehicleCategory(
          id: 'rental-car',
          slug: 'rental-car',
          name: 'Rental Car',
          description: 'Flexible car rental',
          baseFare: 999,
          perKmRate: 0,
          includedHours: 4,
          perHourRate: 50,
          serviceGroup: 'rental',
        ),
      ];
}

class RentalPickupScreen extends ConsumerWidget {
  const RentalPickupScreen({super.key});

  Future<void> _pickLocation(BuildContext context, WidgetRef ref) async {
    final result = await context.push<SelectedPlace>(
      RouteNames.location,
      extra: 'pickup',
    );
    if (result == null) return;
    ref.read(rentalBookingProvider.notifier).setPickup(result);
    if (context.mounted) context.push(RouteNames.rentalDropoff);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(rentalBookingProvider);
    final pickup = booking.pickup;

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Location')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RentalStepHeader(
            step: 3,
            total: 5,
            title: 'Where should we deliver the vehicle?',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.primary),
                title: Text(pickup?.label ?? 'Select pickup location'),
                subtitle: const Text('Tap to search or use current location'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLocation(context, ref),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Continue',
              onPressed: pickup == null ? null : () => context.push(RouteNames.rentalDropoff),
            ),
          ),
        ],
      ),
    );
  }
}

class RentalDropoffScreen extends ConsumerWidget {
  const RentalDropoffScreen({super.key});

  Future<void> _pickLocation(BuildContext context, WidgetRef ref) async {
    final result = await context.push<SelectedPlace>(
      RouteNames.location,
      extra: 'dropoff',
    );
    if (result == null) return;
    ref.read(rentalBookingProvider.notifier).setDropoff(result);
    if (context.mounted) context.push(RouteNames.rentalConfirm);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(rentalBookingProvider);
    final dropoff = booking.dropoff;

    return Scaffold(
      appBar: AppBar(title: const Text('Return Location')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RentalStepHeader(
            step: 4,
            total: 5,
            title: 'Where will you return the vehicle?',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.flag, color: AppColors.primary),
                title: Text(dropoff?.label ?? 'Select return location'),
                subtitle: const Text('End point for your rental trip'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLocation(context, ref),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Continue',
              onPressed: dropoff == null ? null : () => context.push(RouteNames.rentalConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

class RentalConfirmScreen extends ConsumerStatefulWidget {
  const RentalConfirmScreen({super.key});

  @override
  ConsumerState<RentalConfirmScreen> createState() => _RentalConfirmScreenState();
}

class _RentalConfirmScreenState extends ConsumerState<RentalConfirmScreen> {
  bool _isBooking = false;

  Future<void> _confirm() async {
    final activeRide = await ref.read(activeRideProvider.future);
    if (activeRide != null) {
      if (mounted) {
        context.showSnackBar(
          'You already have an active ride. Please finish or cancel it before booking a new one.',
          isError: true,
        );
      }
      return;
    }

    final booking = ref.read(rentalBookingProvider);
    final category = booking.selectedCategory;
    final pickup = booking.pickup;
    final dropoff = booking.dropoff;
    final hours = booking.selectedHours ?? booking.minHours;

    if (category == null || pickup == null || dropoff == null) {
      context.showSnackBar('Please complete all rental steps', isError: true);
      return;
    }
    if (!pickup.hasCoordinates || !dropoff.hasCoordinates) {
      context.showSnackBar('Location coordinates are missing', isError: true);
      return;
    }

    setState(() => _isBooking = true);
    try {
      final result = await ref.read(rideBookingServiceProvider).bookRide(
            pickupAddress: pickup.label,
            dropoffAddress: dropoff.label,
            pickupLat: pickup.latitude!,
            pickupLng: pickup.longitude!,
            dropoffLat: dropoff.latitude!,
            dropoffLng: dropoff.longitude!,
            vehicleCategoryId: category.id,
            rentalHours: hours,
          );
      final rideId = result['id']?.toString();
      if (rideId != null && rideId.isNotEmpty) {
        ref.read(tripBookingProvider.notifier).setActiveRideId(rideId);
      }
      ref.read(rentalBookingProvider.notifier).reset();
      if (mounted) context.go(RouteNames.bookSearching);
    } catch (e) {
      if (mounted) context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(rentalBookingProvider);
    final category = booking.selectedCategory;
    final hours = booking.selectedHours ?? booking.minHours;
    final fare = category != null ? rentalFareForHours(category, hours) : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Rental')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RentalStepHeader(step: 5, total: 5, title: 'Review & confirm'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryRow(label: 'Vehicle', value: category?.name ?? '—'),
                _SummaryRow(label: 'Duration', value: '${hours.round()} hours'),
                _SummaryRow(label: 'Pickup', value: booking.pickup?.label ?? '—'),
                _SummaryRow(label: 'Return', value: booking.dropoff?.label ?? '—'),
                const Divider(height: 32),
                _SummaryRow(
                  label: 'Estimated fare',
                  value: '₹${fare.round()}',
                  emphasized: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Includes ${(category?.includedHours ?? 4).round()} hrs package. Extra hours charged as per admin rates.',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: _isBooking ? 'Searching...' : 'Confirm & Search Nearby',
              onPressed: _isBooking ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalStepHeader extends StatelessWidget {
  const _RentalStepHeader({
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $step of $total',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: step / total,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _HourButton extends StatelessWidget {
  const _HourButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap != null ? AppColors.primary.withValues(alpha: 0.1) : AppColors.muted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: onTap != null ? AppColors.primary : AppColors.mutedForeground),
        ),
      ),
    );
  }
}

class _RentalVehicleTile extends StatelessWidget {
  const _RentalVehicleTile({
    required this.title,
    required this.description,
    required this.price,
    required this.subtitle,
    required this.imageAsset,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String price;
  final String subtitle;
  final String imageAsset;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(imageAsset, width: 64, height: 64, fit: BoxFit.cover),
                      )
                    : Image.asset(imageAsset, width: 64, height: 64, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text(subtitle, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: AppColors.mutedForeground, fontSize: emphasized ? 15 : 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: emphasized ? FontWeight.bold : FontWeight.w600,
                fontSize: emphasized ? 18 : 14,
                color: emphasized ? AppColors.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RentalErrorBody extends StatelessWidget {
  const _RentalErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
