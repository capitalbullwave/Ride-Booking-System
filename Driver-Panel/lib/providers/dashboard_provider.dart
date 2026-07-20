import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/location_service.dart';
import 'package:wavego_driver/services/profile_service.dart';
import 'package:wavego_driver/services/selfie_verification_service.dart';

/// Returned by [DashboardViewModel.toggleOnline] when a live selfie is required.
const kSelfieRequired = 'SELFIE_REQUIRED';

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel(
    this._profileRepo,
    this._profileService,
    this._localStorage,
    this._locationService,
    this._selfieService,
  ) : super(const DashboardState());

  final ProfileRepository _profileRepo;
  final ProfileService _profileService;
  final LocalStorageService _localStorage;
  final LocationService _locationService;
  final SelfieVerificationService _selfieService;

  StreamSubscription<dynamic>? _locationSubscription;

  Future<void> refreshProfile() async {
    try {
      final profile = await _profileRepo.getProfile();
      await _localStorage.setJson(
        AppConstants.driverProfileKey,
        profile.toJson(),
      );
      state = state.copyWith(profile: profile);
    } catch (_) {}
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(statsState: const ViewStateLoading());
    try {
      final stats = await _profileRepo.getDashboardStats();
      final profile = await _profileRepo.getProfile();
      var isOnline = profile.isOnline;

      if (isOnline && !BackendMappers.isDriverVerified(profile)) {
        isOnline = false;
        try {
          await _profileRepo.setOnlineStatus(false);
        } catch (_) {}
      }

      await _localStorage.setBool(AppConstants.isOnlineKey, isOnline);
      state = state.copyWith(
        statsState: ViewStateSuccess(stats),
        profile: profile,
        isOnline: isOnline,
      );
      if (isOnline) {
        _startLocationSync();
      }
    } catch (e) {
      state = state.copyWith(
        statsState: ViewStateError(e.toString()),
      );
    }
  }

  Future<String?> toggleOnline(bool value) async {
    final profile = state.profile;
    if (value &&
        profile != null &&
        !BackendMappers.isDriverVerified(profile)) {
      return profile.verificationStatus == 'rejected'
          ? 'Your documents were rejected. Please update and resubmit.'
          : 'Account verification is pending. You can go online after admin approval.';
    }

    if (value) {
      try {
        final status = await _selfieService.getVerificationStatus();
        if (status.selfieRequired) {
          return kSelfieRequired;
        }
      } catch (e) {
        return e.userMessage;
      }
    }

    state = state.copyWith(isOnline: value, isTogglingOnline: true);
    try {
      if (value) {
        await _selfieService.goOnline();
      } else {
        await _selfieService.goOffline();
      }
      await _localStorage.setBool(AppConstants.isOnlineKey, value);
      if (value) {
        _startLocationSync();
      } else {
        _stopLocationSync();
      }
      state = state.copyWith(isTogglingOnline: false);
      return null;
    } catch (e) {
      final message = e.userMessage;
      if (value &&
          (message.toLowerCase().contains('selfie') ||
              message.toLowerCase().contains('verification required'))) {
        state = state.copyWith(isOnline: false, isTogglingOnline: false);
        return kSelfieRequired;
      }
      state = state.copyWith(isOnline: !value, isTogglingOnline: false);
      return message;
    }
  }

  /// Called after [SelfieVerificationScreen] successfully verifies + goes online.
  Future<void> markOnlineAfterSelfie() async {
    await _localStorage.setBool(AppConstants.isOnlineKey, true);
    _startLocationSync();
    state = state.copyWith(isOnline: true, isTogglingOnline: false);
  }

  void _startLocationSync() {
    _locationSubscription?.cancel();
    DateTime? lastPosted;
    _locationSubscription = _locationService.getPositionStream().listen(
      (position) {
        final now = DateTime.now();
        if (lastPosted != null &&
            now.difference(lastPosted!) < const Duration(seconds: 30)) {
          return;
        }
        lastPosted = now;
        _profileService
            .updateLocation(
              lat: position.latitude,
              lng: position.longitude,
              heading: position.heading,
              speed: position.speed,
            )
            .catchError((_) {});
      },
      onError: (_) {},
    );
  }

  void _stopLocationSync() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    _stopLocationSync();
    super.dispose();
  }
}

class DashboardState {
  const DashboardState({
    this.statsState = const ViewStateInitial<DashboardStats>(),
    this.profile,
    this.isOnline = false,
    this.isTogglingOnline = false,
  });

  final ViewState<DashboardStats> statsState;
  final DriverProfile? profile;
  final bool isOnline;
  final bool isTogglingOnline;

  DashboardState copyWith({
    ViewState<DashboardStats>? statsState,
    DriverProfile? profile,
    bool? isOnline,
    bool? isTogglingOnline,
  }) {
    return DashboardState(
      statsState: statsState ?? this.statsState,
      profile: profile ?? this.profile,
      isOnline: isOnline ?? this.isOnline,
      isTogglingOnline: isTogglingOnline ?? this.isTogglingOnline,
    );
  }

  bool get canGoOnline =>
      profile != null && BackendMappers.isDriverVerified(profile!);
}

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(profileServiceProvider),
    ref.watch(localStorageProvider),
    ref.watch(locationServiceProvider),
    ref.watch(selfieVerificationServiceProvider),
  );
});

