import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/models/corporate_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

class CorporateService extends BaseApiService {
  CorporateService(super.dio);

  Future<CorporateMembership> getMembership() async {
    if (useMock) return CorporateMembership.empty;
    try {
      final data = await get<Map<String, dynamic>>(
        ApiEndpoints.corporateMembership,
        parser: (raw) => raw as Map<String, dynamic>,
      );
      return CorporateMembership.fromJson(data);
    } catch (_) {
      return CorporateMembership.empty;
    }
  }
}

final corporateServiceProvider = Provider<CorporateService>((ref) {
  return CorporateService(ref.watch(dioClientProvider).dio);
});

final corporateMembershipProvider =
    FutureProvider<CorporateMembership>((ref) async {
  return ref.watch(corporateServiceProvider).getMembership();
});

/// When true, the next ride book uses ride_type=CORPORATE.
final corporateRideModeProvider = StateProvider<bool>((ref) => false);
