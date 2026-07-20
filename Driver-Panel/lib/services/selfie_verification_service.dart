import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/models/selfie_verification_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class SelfieVerificationService extends BaseApiService {
  SelfieVerificationService(Dio dio, AuthTokenStore tokenStore)
      : super(dio, tokenStore);

  Future<VerificationStatus> getVerificationStatus() async {
    if (useMock) {
      return const VerificationStatus(
        canGoOnline: false,
        selfieRequired: true,
        hasActiveShift: false,
        message: 'Selfie verification required before going online.',
      );
    }
    return get(
      ApiEndpoints.verificationStatus,
      parser: (data) =>
          VerificationStatus.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<LivenessChallenge> issueLivenessChallenge() async {
    if (useMock) {
      return LivenessChallenge(
        challengeId: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        actions: const ['blink', 'smile', 'head_turn'],
        expiresAt: DateTime.now().add(const Duration(minutes: 2)).toIso8601String(),
      );
    }
    return get(
      ApiEndpoints.livenessChallenge,
      parser: (data) =>
          LivenessChallenge.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<SelfieVerifyResult> verifySelfie({
    required String selfieBase64,
    required String challengeId,
    required Map<String, dynamic> liveness,
    String? deviceId,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return const SelfieVerifyResult(
        verified: true,
        matched: true,
        livenessPassed: true,
        message: 'Identity verified. You can go online.',
        confidenceScore: 92,
        steps: {'liveness': true, 'face_match': true, 'verified': true},
      );
    }
    return post(
      ApiEndpoints.selfieVerify,
      data: {
        'selfie_base64': selfieBase64,
        'challenge_id': challengeId,
        'liveness': liveness,
        'source': 'live_camera',
        if (deviceId != null) 'device_id': deviceId,
      },
      parser: (data) =>
          SelfieVerifyResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> goOnline() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await post(ApiEndpoints.goOnlinePost);
  }

  Future<void> goOffline() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await post(ApiEndpoints.goOfflinePost);
  }
}

final selfieVerificationServiceProvider =
    Provider<SelfieVerificationService>((ref) {
  return SelfieVerificationService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
