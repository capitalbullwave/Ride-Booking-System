import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/saved_place.dart';
import 'package:wavego_user/services/user_services.dart';

class SavedPlacesService {
  SavedPlacesService(this._storage);

  final LocalStorageService _storage;

  List<SavedPlace> getAll() {
    final raw = _storage.getString(AppConstants.savedPlacesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => SavedPlace.fromJson(e.cast<String, dynamic>()))
          .where((p) => p.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SavedPlace> places) async {
    final payload = places.map((e) => e.toJson()).toList();
    await _storage.setString(AppConstants.savedPlacesKey, jsonEncode(payload));
  }

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = Random().nextInt(1 << 20);
    return 'sp_${now}_$rand';
  }

  Future<SavedPlace> add({
    required String title,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final place = SavedPlace(
      id: _newId(),
      title: title.trim(),
      address: address.trim(),
      latitude: latitude,
      longitude: longitude,
      updatedAtMs: now,
    );
    final all = getAll();
    all.removeWhere((p) => p.title.toLowerCase() == place.title.toLowerCase());
    all.insert(0, place);
    await _saveAll(all);
    return place;
  }

  Future<void> remove(String id) async {
    final all = getAll()..removeWhere((p) => p.id == id);
    await _saveAll(all);
  }

  Future<void> toggleFavorite(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final all = getAll();
    final idx = all.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    all[idx] = all[idx].copyWith(isFavorite: !all[idx].isFavorite, updatedAtMs: now);
    await _saveAll(all);
  }

  SelectedPlace toSelectedPlace(SavedPlace p) => SelectedPlace(
        label: p.address.isNotEmpty ? p.address : p.title,
        latitude: p.latitude,
        longitude: p.longitude,
      );
}

final savedPlacesServiceProvider = Provider<SavedPlacesService>((ref) {
  return SavedPlacesService(ref.watch(localStorageProvider));
});

final savedAddressesProvider = FutureProvider<List<SavedPlace>>((ref) async {
  if (AppConfig.enableMockApi) {
    return ref.watch(savedPlacesServiceProvider).getAll();
  }
  try {
    return ref.watch(profileServiceProvider).getAddresses();
  } catch (_) {
    return ref.watch(savedPlacesServiceProvider).getAll();
  }
});

void refreshSavedAddresses(WidgetRef ref) {
  ref.invalidate(savedAddressesProvider);
}

final savedPlacesProvider = Provider<List<SavedPlace>>((ref) {
  return ref.watch(savedAddressesProvider).maybeWhen(
        data: (places) => places,
        orElse: () => ref.watch(savedPlacesServiceProvider).getAll(),
      );
});

