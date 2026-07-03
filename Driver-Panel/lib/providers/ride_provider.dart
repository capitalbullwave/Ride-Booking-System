import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/repositories/ride_repository.dart';

class RideViewModel extends StateNotifier<RideState> {
  RideViewModel(this._repository) : super(const RideState());

  final RideRepository _repository;

  Future<void> pollForRideRequest() async {
    state = state.copyWith(requestState: const ViewStateLoading());
    try {
      final request = await _repository.getIncomingRideRequest();
      if (request != null) {
        state = state.copyWith(
          requestState: ViewStateSuccess(request),
          incomingRequest: request,
        );
      } else {
        state = state.copyWith(requestState: const ViewStateInitial());
      }
    } catch (e) {
      state = state.copyWith(requestState: ViewStateError(e.toString()));
    }
  }

  Future<ActiveRide?> acceptRide(String rideId) async {
    state = state.copyWith(isAccepting: true);
    try {
      final ride = await _repository.acceptRide(rideId);
      state = state.copyWith(activeRide: ride, isAccepting: false);
      return ride;
    } catch (e) {
      state = state.copyWith(isAccepting: false);
      return null;
    }
  }

  Future<void> declineRide(String rideId, {String? reason}) async {
    await _repository.declineRide(rideId, reason: reason);
    state = state.copyWith(incomingRequest: null);
  }

  Future<ActiveRide?> restoreActiveRide() async {
    try {
      final ride = await _repository.getActiveRide();
      if (ride != null) {
        state = state.copyWith(activeRide: ride);
      }
      return ride;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String rideId, String status, {String? otp}) async {
    final ride = await _repository.updateRideStatus(
      rideId,
      status,
      otp: otp,
    );
    state = state.copyWith(activeRide: ride);
  }

  Future<PaymentBreakdown?> completeRide(String rideId) async {
    try {
      return await _repository.completeRide(rideId);
    } catch (e) {
      return null;
    }
  }

  Future<RideSummary?> getSummary(String rideId) async {
    try {
      return await _repository.getRideSummary(rideId);
    } catch (e) {
      return null;
    }
  }

  void clearRide() {
    state = const RideState();
  }
}

class RideState {
  const RideState({
    this.requestState = const ViewStateInitial<RideRequest>(),
    this.incomingRequest,
    this.activeRide,
    this.isAccepting = false,
  });

  final ViewState<RideRequest> requestState;
  final RideRequest? incomingRequest;
  final ActiveRide? activeRide;
  final bool isAccepting;

  RideState copyWith({
    ViewState<RideRequest>? requestState,
    RideRequest? incomingRequest,
    ActiveRide? activeRide,
    bool? isAccepting,
  }) {
    return RideState(
      requestState: requestState ?? this.requestState,
      incomingRequest: incomingRequest ?? this.incomingRequest,
      activeRide: activeRide ?? this.activeRide,
      isAccepting: isAccepting ?? this.isAccepting,
    );
  }
}

final rideViewModelProvider =
    StateNotifierProvider<RideViewModel, RideState>((ref) {
  return RideViewModel(ref.watch(rideRepositoryProvider));
});
