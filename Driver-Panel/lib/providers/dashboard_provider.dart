import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/api_response.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';
import 'package:wavego_driver/services/location_service.dart';
import 'package:wavego_driver/services/profile_service.dart';

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel(
    this._profileRepo,
    this._profileService,
    this._localStorage,
    this._locationService,
  ) : super(const DashboardState());

  final ProfileRepository _profileRepo;
  final ProfileService _profileService;
  final LocalStorageService _localStorage;
  final LocationService _locationService;

  StreamSubscription<dynamic>? _locationSubscription;

  Future<void> loadDashboard() async {
    state = state.copyWith(statsState: const ViewStateLoading());
    try {
      final stats = await _profileRepo.getDashboardStats();
      final profile = await _profileRepo.getProfile();
      final isOnline = profile.isOnline;
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

  Future<void> toggleOnline(bool value) async {
    state = state.copyWith(isOnline: value, isTogglingOnline: true);
    try {
      await _profileRepo.setOnlineStatus(value);
      await _localStorage.setBool(AppConstants.isOnlineKey, value);
      if (value) {
        _startLocationSync();
      } else {
        _stopLocationSync();
      }
      state = state.copyWith(isTogglingOnline: false);
    } catch (e) {
      state = state.copyWith(isOnline: !value, isTogglingOnline: false);
    }
  }

  void _startLocationSync() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getPositionStream().listen(
      (position) {
        _profileService.updateLocation(
          lat: position.latitude,
          lng: position.longitude,
          heading: position.heading,
          speed: position.speed,
        );
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
}

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(profileServiceProvider),
    ref.watch(localStorageProvider),
    ref.watch(locationServiceProvider),
  );
});

final themeModeProvider = StateProvider<bool>((ref) => false);
