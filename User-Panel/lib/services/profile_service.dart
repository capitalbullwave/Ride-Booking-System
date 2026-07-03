import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/backend_mappers.dart';
import 'package:wavego_user/models/saved_place.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

class ProfileService extends BaseApiService {
  ProfileService(super.dio);

  Future<UserProfile> getProfile() async {
    if (useMock) {
      final data = await loadMockJson('login_response.json');
      return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
    }

    return get(
      ApiEndpoints.userProfile,
      parser: (data) =>
          BackendMappers.profileFromApi(data as Map<String, dynamic>),
    );
  }

  Future<UserProfile> updateProfile({
    String? fullName,
    String? email,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    if (useMock) {
      final current = await getProfile();
      final name = fullName ?? current.name;
      return UserProfile(
        id: current.id,
        name: name,
        phone: current.phone,
        email: email ?? current.email,
        rating: current.rating,
        totalRides: current.totalRides,
        initial: name.isNotEmpty ? name[0].toUpperCase() : current.initial,
      );
    }

    return put(
      ApiEndpoints.userProfile,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (email != null) 'email': email,
        if (emergencyContactName != null)
          'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null)
          'emergency_contact_phone': emergencyContactPhone,
      },
      parser: (data) =>
          BackendMappers.profileFromApi(data as Map<String, dynamic>),
    );
  }

  Future<List<SavedPlace>> getAddresses() async {
    if (useMock) return [];

    return get(
      ApiEndpoints.userProfileAddresses,
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map((e) =>
                BackendMappers.savedPlaceFromApi(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<SavedPlace> addAddress({
    required String label,
    required String addressLine,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (useMock) {
      return SavedPlace(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        title: label,
        address: addressLine,
        latitude: latitude,
        longitude: longitude,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
    }

    return post(
      ApiEndpoints.userProfileAddresses,
      data: {
        'label': label,
        'address_line': addressLine,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_default': isDefault,
      },
      parser: (data) =>
          BackendMappers.savedPlaceFromApi(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteAddress(String id) async {
    if (useMock) return;
    await delete('${ApiEndpoints.userProfileAddresses}/$id');
  }
}
