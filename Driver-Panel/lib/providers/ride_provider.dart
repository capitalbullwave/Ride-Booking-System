import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/app_constants.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/utils/view_state.dart';
import 'package:wavego_driver/models/payment_completion_data.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/repositories/ride_repository.dart';

class RideViewModel extends StateNotifier<RideState> {
  RideViewModel(this._repository, this._localStorage) : super(const RideState()) {
    _loadDismissedRideIds();
  }

  final RideRepository _repository;
  final LocalStorageService _localStorage;
  final Set<String> _dismissedRideIds = {};

  void _loadDismissedRideIds() {
    _dismissedRideIds.addAll(
      _localStorage.getStringList(AppConstants.dismissedRideIdsKey),
    );
  }

  Future<void> _persistDismissed(String rideId) async {
    _dismissedRideIds.add(rideId);
    await _localStorage.setStringList(
      AppConstants.dismissedRideIdsKey,
      _dismissedRideIds.toList(),
    );
  }

  Future<void> pollForRideRequest({bool silent = true}) async {
    if (!silent) {
      state = state.copyWith(requestState: const ViewStateLoading());
    }
    try {
      final request = await _repository.getIncomingRideRequest();
      if (request != null && _dismissedRideIds.contains(request.id)) {
        if (state.incomingRequest?.id == request.id) {
          state = state.copyWith(clearIncomingRequest: true);
        }
        return;
      }
      if (request != null) {
        if (state.incomingRequest?.id == request.id) return;
        state = state.copyWith(
          requestState: ViewStateSuccess(request),
          incomingRequest: request,
        );
      } else if (state.incomingRequest != null) {
        state = state.copyWith(
          requestState: const ViewStateInitial(),
          clearIncomingRequest: true,
        );
      } else if (!silent) {
        state = state.copyWith(requestState: const ViewStateInitial());
      }
    } catch (e) {
      if (!silent) {
        state = state.copyWith(requestState: ViewStateError(e.toString()));
      }
    }
  }

  void setIncomingRequest(RideRequest request) {
    if (_dismissedRideIds.contains(request.id)) return;
    state = state.copyWith(
      requestState: ViewStateSuccess(request),
      incomingRequest: request,
    );
  }

  void primeActiveTripFromRequest(RideRequest request) {
    state = state.copyWith(
      incomingRequest: request,
      isAccepting: true,
      activeRide: ActiveRide(
        id: request.id,
        status: 'heading_to_pickup',
        pickupAddress: request.pickupAddress,
        destinationAddress: request.destinationAddress,
        pickupLat: request.pickupLat,
        pickupLng: request.pickupLng,
        destinationLat: request.destinationLat,
        destinationLng: request.destinationLng,
        passengerName: request.passengerName,
        passengerPhone: request.passengerPhone,
        paymentMode: request.paymentMode,
        estimatedFare: request.estimatedFare,
        distance: request.distance,
        stops: request.stops,
      ),
    );
  }

  Future<ActiveRide> acceptRide(String rideId) async {
    final incoming = state.incomingRequest;
    if (incoming != null && incoming.id == rideId && state.activeRide == null) {
      primeActiveTripFromRequest(incoming);
    } else {
      state = state.copyWith(isAccepting: true);
    }

    try {
      final accepted = await _repository.acceptRide(rideId);
      final ride = _enrichFromIncoming(accepted, rideId);

      _dismissedRideIds.remove(rideId);
      state = state.copyWith(
        activeRide: ride,
        isAccepting: false,
        clearIncomingRequest: true,
      );
      return ride;
    } catch (e) {
      state = state.copyWith(isAccepting: false, clearActiveRide: true);
      rethrow;
    }
  }

  ActiveRide _enrichFromIncoming(ActiveRide ride, String rideId) {
    final incoming = state.incomingRequest;
    if (incoming == null || incoming.id != rideId) return ride;

    return ride.copyWith(
      pickupAddress:
          ride.pickupAddress.isEmpty ? incoming.pickupAddress : ride.pickupAddress,
      destinationAddress: ride.destinationAddress.isEmpty
          ? incoming.destinationAddress
          : ride.destinationAddress,
      pickupLat: ride.pickupLat == 0 ? incoming.pickupLat : ride.pickupLat,
      pickupLng: ride.pickupLng == 0 ? incoming.pickupLng : ride.pickupLng,
      destinationLat:
          ride.destinationLat == 0 ? incoming.destinationLat : ride.destinationLat,
      destinationLng:
          ride.destinationLng == 0 ? incoming.destinationLng : ride.destinationLng,
      passengerName: ride.passengerName == 'Passenger'
          ? incoming.passengerName
          : ride.passengerName,
      passengerPhone: ride.passengerPhone ?? incoming.passengerPhone,
      estimatedFare:
          ride.estimatedFare == 0 ? incoming.estimatedFare : ride.estimatedFare,
      distance: ride.distance ?? incoming.distance,
      stops: ride.stops.isEmpty ? incoming.stops : ride.stops,
    );
  }

  /// Keep passenger/route fields (especially stops) when API omits them.
  ActiveRide _mergeWithPrevious(ActiveRide ride, ActiveRide? previous) {
    if (previous == null) return ride;
    return ride.copyWith(
      passengerName: ride.passengerName == 'Passenger'
          ? previous.passengerName
          : ride.passengerName,
      passengerPhone: ride.passengerPhone ?? previous.passengerPhone,
      pickupAddress:
          ride.pickupAddress.isEmpty ? previous.pickupAddress : ride.pickupAddress,
      destinationAddress: ride.destinationAddress.isEmpty
          ? previous.destinationAddress
          : ride.destinationAddress,
      pickupLat: ride.pickupLat == 0 ? previous.pickupLat : ride.pickupLat,
      pickupLng: ride.pickupLng == 0 ? previous.pickupLng : ride.pickupLng,
      destinationLat:
          ride.destinationLat == 0 ? previous.destinationLat : ride.destinationLat,
      destinationLng:
          ride.destinationLng == 0 ? previous.destinationLng : ride.destinationLng,
      estimatedFare:
          ride.estimatedFare == 0 ? previous.estimatedFare : ride.estimatedFare,
      distance: ride.distance ?? previous.distance,
      stops: ride.stops.isEmpty ? previous.stops : ride.stops,
    );
  }

  Future<void> declineRide(String rideId, {String? reason}) async {
    await _repository.declineRide(rideId, reason: reason);
    await _persistDismissed(rideId);
    state = state.copyWith(clearIncomingRequest: true);
  }

  Future<ActiveRide?> restoreActiveRide() async {
    try {
      final ride = await _repository.getActiveRide();
      if (ride != null) {
        state = state.copyWith(
          activeRide: _mergeWithPrevious(ride, state.activeRide),
        );
      }
      return state.activeRide;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String rideId, String status, {String? otp}) async {
    final previous = state.activeRide;
    try {
      var ride = await _repository.updateRideStatus(
        rideId,
        status,
        otp: otp,
      );
      ride = _mergeWithPrevious(ride, previous);
      state = state.copyWith(activeRide: ride);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startRideWithOtp(String rideId, String otp) async {
    final previous = state.activeRide;
    state = state.copyWith(isAccepting: true);
    try {
      var ride = await _repository.updateRideStatus(
        rideId,
        'started',
        otp: otp.trim(),
      );
      ride = _mergeWithPrevious(ride, previous);
      state = state.copyWith(activeRide: ride, isAccepting: false);
    } catch (e) {
      state = state.copyWith(isAccepting: false);
      rethrow;
    }
  }

  void patchActiveRideStatus(String status) {
    final ride = state.activeRide;
    if (ride == null) return;
    state = state.copyWith(activeRide: ride.copyWith(status: status));
  }

  /// Returns null when ride is no longer active (e.g. cancelled).
  /// Keeps local state on network errors and while accept is still in flight.
  Future<ActiveRide?> refreshActiveRideStatus() async {
    try {
      final ride = await _repository.getActiveRide();
      if (ride == null || ride.status == 'cancelled') {
        // Accept flow primes a local ride and navigates before the API finishes.
        // A null active-ride response during that window is not a cancellation.
        if (state.isAccepting && state.activeRide != null) {
          return state.activeRide;
        }
        state = state.copyWith(clearActiveRide: true, clearIncomingRequest: true);
        return null;
      }
      state = state.copyWith(
        activeRide: _mergeWithPrevious(ride, state.activeRide),
        isAccepting: false,
      );
      return state.activeRide;
    } catch (_) {
      return state.activeRide;
    }
  }

  Future<PaymentBreakdown?> completeRide(String rideId) async {
    final active = state.activeRide;
    try {
      final payment = await _repository.completeRide(rideId);
      state = state.copyWith(
        clearActiveRide: true,
        clearIncomingRequest: true,
        pendingPayment: active != null
            ? PaymentCompletionData(
                payment: payment,
                rideId: rideId,
                passengerName: active.passengerName,
              )
            : null,
      );
      return payment;
    } catch (e) {
      return null;
    }
  }

  void clearPendingPayment() {
    if (state.pendingPayment == null) return;
    state = state.copyWith(clearPendingPayment: true);
  }

  Future<PaymentBreakdown?> collectCashPayment(String rideId) =>
      _repository.collectCashPayment(rideId);

  Future<Map<String, dynamic>> createOnlinePaymentQr(String rideId) =>
      _repository.createOnlinePaymentQr(rideId);

  Future<bool> checkOnlinePaymentStatus(String rideId) =>
      _repository.checkOnlinePaymentStatus(rideId);

  Future<void> ratePassenger(
    String rideId, {
    required int rating,
    String? comment,
  }) async {
    await _repository.ratePassenger(rideId, rating: rating, comment: comment);
  }

  Future<RideSummary?> getSummary(String rideId) async {
    try {
      return await _repository.getRideSummary(rideId);
    } catch (e) {
      return null;
    }
  }

  void dismissRideRequest(String rideId) {
    _persistDismissed(rideId);
    if (state.incomingRequest?.id == rideId) {
      state = state.copyWith(clearIncomingRequest: true);
    }
  }

  bool isDismissed(String rideId) => _dismissedRideIds.contains(rideId);

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
    this.pendingPayment,
  });

  final ViewState<RideRequest> requestState;
  final RideRequest? incomingRequest;
  final ActiveRide? activeRide;
  final bool isAccepting;
  final PaymentCompletionData? pendingPayment;

  RideState copyWith({
    ViewState<RideRequest>? requestState,
    RideRequest? incomingRequest,
    ActiveRide? activeRide,
    bool? isAccepting,
    PaymentCompletionData? pendingPayment,
    bool clearIncomingRequest = false,
    bool clearActiveRide = false,
    bool clearPendingPayment = false,
  }) {
    return RideState(
      requestState: requestState ?? this.requestState,
      incomingRequest:
          clearIncomingRequest ? null : (incomingRequest ?? this.incomingRequest),
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      isAccepting: isAccepting ?? this.isAccepting,
      pendingPayment: clearPendingPayment
          ? null
          : (pendingPayment ?? this.pendingPayment),
    );
  }
}

final rideViewModelProvider =
    StateNotifierProvider<RideViewModel, RideState>((ref) {
  return RideViewModel(
    ref.watch(rideRepositoryProvider),
    ref.watch(localStorageProvider),
  );
});
