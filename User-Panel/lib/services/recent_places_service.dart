import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/models/place_models.dart';

class RecentPlace {
  const RecentPlace({
    required this.label,
    this.latitude,
    this.longitude,
    required this.updatedAtMs,
  });

  final String label;
  final double? latitude;
  final double? longitude;
  final int updatedAtMs;

  Map<String, dynamic> toJson() => {
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at_ms': updatedAtMs,
      };

  factory RecentPlace.fromJson(Map<String, dynamic> json) => RecentPlace(
        label: json['label'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        updatedAtMs: json['updated_at_ms'] as int? ?? 0,
      );

  SelectedPlace toSelected() => SelectedPlace(
        label: label,
        latitude: latitude,
        longitude: longitude,
      );
}

class RecentPlacesService {
  RecentPlacesService(this._storage);

  final LocalStorageService _storage;

  List<RecentPlace> getAll() {
    final raw = _storage.getString(AppConstants.recentPlacesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final list = decoded
          .whereType<Map>()
          .map((e) => RecentPlace.fromJson(e.cast<String, dynamic>()))
          .where((p) => p.label.trim().isNotEmpty)
          .toList();
      list.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<RecentPlace> places) async {
    await _storage.setString(
      AppConstants.recentPlacesKey,
      jsonEncode(places.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> add(SelectedPlace place) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final label = place.label.trim();
    if (label.isEmpty) return;

    final all = getAll();
    all.removeWhere((p) => p.label.toLowerCase() == label.toLowerCase());
    all.insert(
      0,
      RecentPlace(
        label: label,
        latitude: place.latitude,
        longitude: place.longitude,
        updatedAtMs: now,
      ),
    );
    if (all.length > 12) all.removeRange(12, all.length);
    await _saveAll(all);
  }
}

final recentPlacesServiceProvider = Provider<RecentPlacesService>((ref) {
  return RecentPlacesService(ref.watch(localStorageProvider));
});

final recentPlacesProvider = StateProvider<List<RecentPlace>>((ref) {
  return ref.watch(recentPlacesServiceProvider).getAll();
});

