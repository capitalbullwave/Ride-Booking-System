class HomeServiceItem {
  const HomeServiceItem({
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.route,
    this.isEmergency = false,
    this.imageUrl,
  });

  final String name;
  final String description;
  final String imageAsset;
  final String route;
  final bool isEmergency;
  final String? imageUrl;
}

class AppServices {
  AppServices._();

  static const List<HomeServiceItem> homeServices = [
    HomeServiceItem(
      name: 'Bike-Taxi',
      description: 'Beat the traffic, save money',
      imageAsset: 'assets/images/services/bike.png',
      route: '/book',
    ),
    HomeServiceItem(
      name: 'Electric Auto',
      description: 'No haggling, just easy rides',
      imageAsset: 'assets/images/services/auto.png',
      route: '/book',
    ),
    HomeServiceItem(
      name: 'Cab',
      description: 'Comfortable rides for you',
      imageAsset: 'assets/images/services/car.png',
      route: '/book',
    ),
    HomeServiceItem(
      name: 'Parcel',
      description: 'Quick, secure & insured deliveries',
      imageAsset: 'assets/images/services/parcel.png',
      route: '/book',
    ),
    HomeServiceItem(
      name: 'Travel and Stay',
      description: 'One app, all solutions',
      imageAsset: 'assets/images/services/travel.png',
      route: '/book',
    ),
    HomeServiceItem(
      name: 'Ambulance',
      description: 'Emergency medical transport',
      imageAsset: 'assets/images/services/ambulance.png',
      route: '/ambulance',
      isEmergency: true,
    ),
  ];
}
