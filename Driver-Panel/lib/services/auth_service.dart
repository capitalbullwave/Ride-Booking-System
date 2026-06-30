import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/utils/phone_utils.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/otp_send_result.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class AuthService extends BaseApiService {
  AuthService(super.dio);

  Future<OtpSendResult> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return const OtpSendResult(
        response: OtpResponse(
          success: true,
          message: 'OTP sent successfully (mock mode)',
        ),
        devOtpHint: '123456',
      );
    }

    final normalizedPhone = PhoneUtils.normalize(phone, countryCode);

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: {
        'role': 'driver',
        'phone': normalizedPhone,
        'purpose': 'login',
      },
      parser: (raw) => raw as Map<String, dynamic>,
    );

    return OtpSendResult(
      response: BackendMappers.otpFromMessage(data),
      devOtpHint: BackendMappers.devOtpHintFromMessage(data),
    );
  }

  Future<LoginResponse> verifyOtp({
    required String phone,
    required String otp,
    required String countryCode,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      return LoginResponse.fromJson(
        await loadMockJson('login_response.json'),
      );
    }

    if (otp.trim().length < 4) {
      throw const ValidationException('Enter the OTP sent to your phone.');
    }

    final normalizedPhone = PhoneUtils.normalize(phone, countryCode);

    final tokens = await post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: {
        'role': 'driver',
        'phone': normalizedPhone,
        'otp': otp.trim(),
        'purpose': 'login',
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    try {
      final profile = await get<Map<String, dynamic>>(
        ApiEndpoints.profile,
        parser: (data) => data as Map<String, dynamic>,
      );
      return BackendMappers.loginWithProfile(tokens, profile);
    } catch (_) {
      return BackendMappers.loginFromToken(tokens);
    }
  }

  Future<void> logout() async {
    if (useMock) return;
    try {
      await post(ApiEndpoints.logout);
    } catch (_) {
      // Token may already be invalid; local cleanup still proceeds.
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider).dio);
});
