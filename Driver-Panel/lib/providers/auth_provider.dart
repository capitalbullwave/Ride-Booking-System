import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/providers/auth_session_provider.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/push_notification_service.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._repository, this._ref) : super(const AuthState());

  final AuthRepository _repository;
  final Ref _ref;

  Future<void> sendOtp(String phone, String countryCode) async {
    state = state.copyWith(otpState: const ViewStateLoading());
    try {
      final result = await _repository.sendOtp(
        phone: phone,
        countryCode: countryCode,
      );
      state = state.copyWith(
        otpState: ViewStateSuccess(result.response),
        phone: phone,
        countryCode: countryCode,
        devOtpHint: result.devOtpHint,
      );
    } catch (e) {
      state = state.copyWith(
        otpState: ViewStateError(e.userMessage),
      );
    }
  }

  Future<LoginResponse?> verifyOtp(String otp) async {
    state = state.copyWith(loginState: const ViewStateLoading());
    try {
      final response = await _repository.verifyOtp(
        phone: state.phone,
        otp: otp,
        countryCode: state.countryCode,
      );
      state = state.copyWith(
        loginState: ViewStateSuccess(response),
        isAuthenticated: true,
        isRegistered: response.isRegistered,
        isVerified: response.isVerified,
      );
      _ref.read(authSessionProvider.notifier).setAuthenticated(true);
      // Sync FCM token after login (best-effort; never block auth).
      Future.microtask(() async {
        try {
          await _ref.read(pushNotificationServiceProvider).refreshAndSyncToken();
        } catch (_) {}
      });
      return response;
    } catch (e) {
      state = state.copyWith(
        loginState: ViewStateError(e.userMessage),
      );
      return null;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _ref.read(authSessionProvider.notifier).setAuthenticated(false);
    state = const AuthState();
  }
}

class AuthState {
  const AuthState({
    this.phone = '',
    this.countryCode = '+91',
    this.devOtpHint,
    this.otpState = const ViewStateInitial<OtpResponse>(),
    this.loginState = const ViewStateInitial<LoginResponse>(),
    this.isAuthenticated = false,
    this.isRegistered = false,
    this.isVerified = false,
  });

  final String phone;
  final String countryCode;
  final String? devOtpHint;
  final ViewState<OtpResponse> otpState;
  final ViewState<LoginResponse> loginState;
  final bool isAuthenticated;
  final bool isRegistered;
  final bool isVerified;

  AuthState copyWith({
    String? phone,
    String? countryCode,
    String? devOtpHint,
    ViewState<OtpResponse>? otpState,
    ViewState<LoginResponse>? loginState,
    bool? isAuthenticated,
    bool? isRegistered,
    bool? isVerified,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      devOtpHint: devOtpHint ?? this.devOtpHint,
      otpState: otpState ?? this.otpState,
      loginState: loginState ?? this.loginState,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isRegistered: isRegistered ?? this.isRegistered,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider), ref);
});
