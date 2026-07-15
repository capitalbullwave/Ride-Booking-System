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
