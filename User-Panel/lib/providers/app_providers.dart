import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/utils/view_state.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/services/places_service.dart';

class AuthState {
  const AuthState({
    this.otpState = const ViewStateInitial(),
    this.loginState = const ViewStateInitial(),
    this.phone = '',
    this.countryCode = '+91',
    this.devOtpHint,
  });

  final ViewState otpState;
  final ViewState loginState;
  final String phone;
  final String countryCode;
  final String? devOtpHint;

  AuthState copyWith({
    ViewState? otpState,
    ViewState? loginState,
    String? phone,
    String? countryCode,
    String? devOtpHint,
    bool clearDevOtpHint = false,
  }) =>
      AuthState(
        otpState: otpState ?? this.otpState,
        loginState: loginState ?? this.loginState,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        devOtpHint: clearDevOtpHint ? null : (devOtpHint ?? this.devOtpHint),
      );
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> sendOtp(String phone, String countryCode) async {
    state = state.copyWith(
      otpState: const ViewStateLoading(),
      phone: phone,
      countryCode: countryCode,
      clearDevOtpHint: true,
    );
    try {
      final result = await _repo.sendOtp(phone: phone, countryCode: countryCode);
      state = state.copyWith(
        otpState: const ViewStateSuccess(null),
        devOtpHint: result.devOtpHint,
      );
    } catch (e) {
      state = state.copyWith(otpState: ViewStateError(e.toString()));
    }
  }

  Future<LoginResponse?> verifyOtp(String otp) async {
    state = state.copyWith(loginState: const ViewStateLoading());
    try {
      final response = await _repo.verifyOtp(otp);
      state = state.copyWith(loginState: ViewStateSuccess(response));
      return response;
    } catch (e) {
      state = state.copyWith(loginState: ViewStateError(e.toString()));
      return null;
    }
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

final homeDashboardProvider = FutureProvider<HomeDashboard>((ref) async {
  return ref.watch(homeRepositoryProvider).getDashboard();
});

final activeRideProvider = FutureProvider<UserActiveRide?>((ref) async {
  final data = await ref.watch(rideBookingServiceProvider).getActiveRide();
  if (data == null) return null;
  return UserActiveRide.fromJson(data);
});

final walletProvider = FutureProvider<WalletSummary>((ref) async {
  return ref.watch(walletRepositoryProvider).getWallet();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final activitiesProvider =
    FutureProvider<Map<String, List<ActivityItem>>>((ref) async {
  return ref.watch(activityRepositoryProvider).getActivities();
});

final themeModeProvider = StateProvider<bool>((ref) => false);
