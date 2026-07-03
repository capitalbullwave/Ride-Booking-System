class SavedPlace {
  const SavedPlace({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
    this.isFavorite = false,
    required this.updatedAtMs,
  });

  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isFavorite;
  final int updatedAtMs;

  bool get hasCoordinates => latitude != null && longitude != null;

  SavedPlace copyWith({
    String? title,
    String? address,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    int? updatedAtMs,
  }) {
    return SavedPlace(
      id: id,
      title: title ?? this.title,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_favorite': isFavorite,
        'updated_at_ms': updatedAtMs,
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) => SavedPlace(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isFavorite: json['is_favorite'] as bool? ?? false,
        updatedAtMs: json['updated_at_ms'] as int? ?? 0,
      );
}

