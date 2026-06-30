import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/api_exception.dart';
import 'package:wavego_user/core/network/backend_mappers.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/core/utils/phone_utils.dart';
import 'package:wavego_user/models/otp_send_result.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/services/base_api_service.dart';

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
        'role': 'user',
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
    required String countryCode,
    required String otp,
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
        'role': 'user',
        'phone': normalizedPhone,
        'otp': otp.trim(),
        'purpose': 'login',
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    try {
      final profile = await get<Map<String, dynamic>>(
        '/auth/me',
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
    } catch (_) {}
  }
}

class HomeService extends BaseApiService {
  HomeService(super.dio);

  Future<HomeDashboard> getDashboard() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return HomeDashboard.fromJson(await loadMockJson('home_dashboard.json'));
    }
    return get(
      ApiEndpoints.dashboard,
      parser: (data) => HomeDashboard.fromJson(data as Map<String, dynamic>),
    );
  }
}

class WalletService extends BaseApiService {
  WalletService(super.dio);

  Future<WalletSummary> getWallet() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return WalletSummary.fromJson(await loadMockJson('wallet.json'));
    }
    return get(
      ApiEndpoints.wallet,
      parser: (data) => WalletSummary.fromJson(data as Map<String, dynamic>),
    );
  }
}

class NotificationService extends BaseApiService {
  NotificationService(super.dio);

  Future<List<AppNotification>> getNotifications() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final list = await loadMockJsonList('notifications.json');
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return get(
      ApiEndpoints.notifications,
      parser: (data) => (data as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivityService extends BaseApiService {
  ActivityService(super.dio);

  Future<Map<String, List<ActivityItem>>> getActivities() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final data = await loadMockJson('activities.json');
      return data.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
    }
    return get(
      ApiEndpoints.rides,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return map.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>)
                .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
      },
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioClientProvider).dio);
});

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(dioClientProvider).dio);
});

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(ref.watch(dioClientProvider).dio);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(dioClientProvider).dio);
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(ref.watch(dioClientProvider).dio);
});
