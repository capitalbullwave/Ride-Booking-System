import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
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

  Future<PaymentBreakdown> collectCashPayment(String rideId) async {
    final response = await _service.collectCashPayment(rideId);
    return BackendMappers.paymentFromRide(response);
  }

  Future<Map<String, dynamic>> createOnlinePaymentQr(String rideId) =>
      _service.createOnlinePaymentQr(rideId);

  Future<bool> checkOnlinePaymentStatus(String rideId) async {
    final response = await _service.checkOnlinePaymentStatus(rideId);
    return response['payment_collected'] == true ||
        response['payment_status']?.toString().toUpperCase() == 'COMPLETED';
  }

  Future<void> ratePassenger(
    String rideId, {
    required int rating,
    String? comment,
  }) =>
      _service.ratePassenger(rideId, rating: rating, comment: comment);

  Future<RideSummary> getRideSummary(String rideId) =>
      _service.getRideSummary(rideId);
}

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepository(ref.watch(rideServiceProvider));
});
