import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/models/trip_model.dart';
import 'package:wavego_driver/services/trip_service.dart';

class TripRepository {
  TripRepository(this._service);

  final TripService _service;

  Future<List<Trip>> getTrips({
    int page = 1,
    String? status,
    String? search,
  }) =>
      _service.getTrips(page: page, status: status, search: search);

  Future<TripDetail> getTripDetail(String id) => _service.getTripDetail(id);

  Future<EarningsSummary> getEarnings({String period = 'weekly'}) =>
      _service.getEarnings(period: period);

  Future<EarningsSummary> getEarningsSummary() => _service.getEarningsSummary();

  Future<({EarningsSummary summary, List<EarningsRideItem> rides})>
      getEarningsBundle({String period = 'weekly'}) =>
          _service.getEarningsBundle(period: period);
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(ref.watch(tripServiceProvider));
});
