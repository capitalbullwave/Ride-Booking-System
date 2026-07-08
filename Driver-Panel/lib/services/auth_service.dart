import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/api_exception.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/utils/phone_utils.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/otp_send_result.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class AuthService extends BaseApiService {
  AuthService(AuthTokenStore tokenStore, Dio dio)
      : _tokenStore = tokenStore,
        _dio = dio,
        super(dio, tokenStore);

  final AuthTokenStore _tokenStore;
  final Dio _dio;

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
      final mockResponse = LoginResponse.fromJson(
        await loadMockJson('login_response.json'),
      );
      await _tokenStore.setTokens(
        accessToken: mockResponse.tokens.accessToken,
        refreshToken: mockResponse.tokens.refreshToken,
      );
      return mockResponse;
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

    final accessToken = tokens['access_token'] as String?;
    final refreshToken = tokens['refresh_token'] as String?;
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const UnauthorizedException('Login failed. Please try again.');
    }

    await _tokenStore.setTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
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

  /// Revokes the session on the server. Skips the call when [accessToken] is empty.
  Future<void> logout({String? accessToken}) async {
    if (useMock) return;
    final token = (accessToken ??
            _tokenStore.accessToken ??
            await _tokenStore.readAccessToken())
        ?.trim();
    if (token == null || token.isEmpty) return;

    try {
      await _dio.post<dynamic>(
        ApiEndpoints.logout,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          // Prevent interceptor session handling from touching logout.
          extra: {'skip_session_expire': true},
        ),
      );
    } catch (_) {
      // Best-effort revoke — local logout always continues.
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(authTokenStoreProvider),
    ref.watch(dioClientProvider).dio,
  );
});
