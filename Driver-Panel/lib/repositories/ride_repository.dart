import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/services/ride_service.dart';

class RideRepository {
  RideRepository(this._service);

  final RideService _service;

  Future<RideRequest?> getIncomingRideRequest() =>
      _service.getIncomingRideRequest();

  Future<ActiveRide> acceptRide(String rideId) =>
      _service.acceptRide(rideId);

  Future<void> declineRide(String rideId, {String? reason}) =>
      _service.declineRide(rideId, reason: reason);

  Future<ActiveRide?> getActiveRide() => _service.getActiveRide();

  Future<ActiveRide> updateRideStatus(
    String rideId,
    String status, {
    String? otp,
  }) =>
      _service.updateRideStatus(rideId, status, otp: otp);

  Future<PaymentBreakdown> completeRide(String rideId) =>
      _service.completeRide(rideId);

  Future<RideSummary> getRideSummary(String rideId) =>
      _service.getRideSummary(rideId);
}

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(ref.watch(rideServiceProvider));
});
