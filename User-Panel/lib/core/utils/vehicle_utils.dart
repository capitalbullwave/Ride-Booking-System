import 'package:flutter/material.dart';
import 'package:wavego_user/core/constants/home_booking_mode.dart';
import 'package:wavego_user/core/constants/services.dart';
import 'package:wavego_user/core/utils/media_utils.dart';
import 'package:wavego_user/models/user_models.dart';

class BookableVehicle {
  const BookableVehicle({
    required this.id,
    required this.name,
    required this.slug,
    required this.baseFare,
    required this.perKmRate,
    required this.icon,
    required this.imageAsset,
    this.description,
    this.imageUrl,
    this.capacity = 4,
  });

  final String id;
  final String name;
  final String slug;
  final double baseFare;
  final double perKmRate;
  final IconData icon;
  final String imageAsset;
  final String? description;
  final String? imageUrl;
  final int capacity;

  String fareForDistanceKm(double distanceKm) {
    return '₹${(baseFare + perKmRate * distanceKm).round()}';
  }

  String etaLabel(int index) => '${3 + index} min';

  String tripSubtitle(double distanceKm, int index) {
    final dist = distanceKm.toStringAsFixed(1);
    return '$dist km • ${etaLabel(index)} away';
  }
}

String vehicleImageAssetForSlug(String slug) {
  final normalized = slug.toLowerCase();
  if (normalized.contains('bike')) return 'assets/images/services/bike.png';
  if (normalized.contains('auto')) return 'assets/images/services/auto.png';
  if (normalized.contains('parcel')) return 'assets/images/services/parcel.png';
  if (normalized.contains('travel')) return 'assets/images/services/travel.png';
  if (normalized.contains('ambulance')) return 'assets/images/services/ambulance.png';
  return 'assets/images/services/car.png';
}

IconData vehicleIconForSlug(String slug) {
  final normalized = slug.toLowerCase();
  if (normalized.contains('bike')) return Icons.two_wheeler;
  if (normalized.contains('auto')) return Icons.electric_rickshaw;
  if (normalized.contains('ambulance')) return Icons.medical_services;
  if (normalized.contains('parcel')) return Icons.inventory_2_outlined;
  return Icons.directions_car;
}

BookableVehicle bookableVehicleFromCategory(VehicleCategory category, int index) {
  final uploadedImage = isMediaUrl(category.iconUrl)
      ? resolveMediaUrl(category.iconUrl)
      : null;

  return BookableVehicle(
    id: category.id,
    name: category.name,
    slug: category.slug,
    baseFare: category.baseFare,
    perKmRate: category.perKmRate,
    icon: vehicleIconForSlug(category.slug),
    imageAsset: vehicleImageAssetForSlug(category.slug),
    description: category.description,
    imageUrl: uploadedImage,
    capacity: category.capacity,
  );
}

HomeServiceItem homeServiceFromCategory(VehicleCategory category) {
  final slug = category.slug.toLowerCase();
  final isAmbulance = slug.contains('ambulance');
  final isRental = category.serviceGroup == 'rental';
  final uploadedImage = isMediaUrl(category.iconUrl)
      ? resolveMediaUrl(category.iconUrl)
      : null;

  return HomeServiceItem(
    name: category.name,
    description: category.description ?? 'Book ${category.name} instantly',
    imageAsset: vehicleImageAssetForSlug(category.slug),
    imageUrl: uploadedImage,
    route: isAmbulance ? '/ambulance' : (isRental ? '/rental' : '/book'),
    isEmergency: isAmbulance,
  );
}

List<HomeServiceItem> fallbackRentalServices() => const [
      HomeServiceItem(
        name: 'Rental Bike',
        description: 'Rent a bike by the day',
        imageAsset: 'assets/images/services/bike.png',
        route: '/rental',
      ),
      HomeServiceItem(
        name: 'Rental Car',
        description: 'Flexible car rental packages',
        imageAsset: 'assets/images/services/car.png',
        route: '/rental',
      ),
    ];

List<HomeServiceItem> fallbackHomeServices() => AppServices.homeServices;

bool isParcelCategorySlug(String slug) => slug.toLowerCase().contains('parcel');

String? bookedVehicleSlugForTrip(HomeBookingMode mode, String? bookedSlug) {
  if (bookedSlug != null && bookedSlug.isNotEmpty) return bookedSlug;
  if (mode == HomeBookingMode.parcel) return 'parcel';
  return null;
}

bool isParcelCategory(VehicleCategory category) => isParcelCategorySlug(category.slug);

List<VehicleCategory> filterCategoriesForMode(
  List<VehicleCategory> categories,
  HomeBookingMode mode,
) {
  switch (mode) {
    case HomeBookingMode.ride:
      return categories
          .where(
            (c) => c.serviceGroup != 'rental' && !isParcelCategory(c),
          )
          .toList();
    case HomeBookingMode.parcel:
      return categories.where(isParcelCategory).toList();
    case HomeBookingMode.rental:
      return categories.where((c) => c.serviceGroup == 'rental').toList();
  }
}

List<BookableVehicle> filterBookableVehiclesForMode(
  List<BookableVehicle> vehicles,
  HomeBookingMode mode,
) {
  switch (mode) {
    case HomeBookingMode.ride:
      return vehicles.where((v) => !isParcelCategorySlug(v.slug)).toList();
    case HomeBookingMode.parcel:
      return vehicles.where((v) => isParcelCategorySlug(v.slug)).toList();
    case HomeBookingMode.rental:
      return vehicles;
  }
}

List<HomeServiceItem> homeServicesForMode(
  List<HomeServiceItem> services,
  HomeBookingMode mode,
) {
  switch (mode) {
    case HomeBookingMode.ride:
      return services
          .where(
            (s) =>
                !s.name.toLowerCase().contains('parcel') &&
                !s.name.toLowerCase().contains('rental') &&
                !s.isEmergency,
          )
          .toList();
    case HomeBookingMode.parcel:
      return services
          .where((s) => s.name.toLowerCase().contains('parcel'))
          .toList();
    case HomeBookingMode.rental:
      return fallbackRentalServices();
  }
}

List<BookableVehicle> fallbackBookableVehicles() => const [
      BookableVehicle(
        id: 'bike',
        name: 'Bike',
        slug: 'bike',
        baseFare: 25,
        perKmRate: 8,
        icon: Icons.two_wheeler,
        imageAsset: 'assets/images/services/bike.png',
        capacity: 1,
      ),
      BookableVehicle(
        id: 'auto',
        name: 'Auto',
        slug: 'auto',
        baseFare: 35,
        perKmRate: 12,
        icon: Icons.electric_rickshaw,
        imageAsset: 'assets/images/services/auto.png',
        capacity: 3,
      ),
      BookableVehicle(
        id: 'cab',
        name: 'Cab',
        slug: 'cab',
        baseFare: 50,
        perKmRate: 15,
        icon: Icons.directions_car,
        imageAsset: 'assets/images/services/car.png',
        capacity: 4,
      ),
    ];

List<BookableVehicle> fallbackParcelVehicles() => const [
      BookableVehicle(
        id: 'parcel',
        name: 'Parcel',
        slug: 'parcel',
        baseFare: 30,
        perKmRate: 10,
        icon: Icons.inventory_2_outlined,
        imageAsset: 'assets/images/services/parcel.png',
        description: 'Quick, secure deliveries',
      ),
    ];
