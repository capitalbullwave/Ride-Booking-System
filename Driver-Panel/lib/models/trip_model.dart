import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
abstract class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String status,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    required double distance,
    required int duration,
    required double fare,
    @JsonKey(name: 'net_earnings') required double netEarnings,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'passenger_name') String? passengerName,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}

@freezed
abstract class TripDetail with _$TripDetail {
  const factory TripDetail({
    required String id,
    required String status,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    required double distance,
    required int duration,
    required double fare,
    required double commission,
    @JsonKey(name: 'net_earnings') required double netEarnings,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'passenger_name') String? passengerName,
    @JsonKey(name: 'passenger_phone') String? passengerPhone,
    @JsonKey(name: 'passenger_rating') double? passengerRating,
    @JsonKey(name: 'driver_rating') double? driverRating,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'completed_at') String? completedAt,
    @JsonKey(name: 'route_polyline') String? routePolyline,
  }) = _TripDetail;

  factory TripDetail.fromJson(Map<String, dynamic> json) =>
      _$TripDetailFromJson(json);
}

@freezed
abstract class EarningsSummary with _$EarningsSummary {
  const factory EarningsSummary({
    @JsonKey(name: 'today_earnings') @Default(0) double todayEarnings,
    @JsonKey(name: 'weekly_earnings') @Default(0) double weeklyEarnings,
    @JsonKey(name: 'monthly_earnings') @Default(0) double monthlyEarnings,
    @JsonKey(name: 'total_trips') @Default(0) int totalTrips,
    @JsonKey(name: 'today_trips') @Default(0) int todayTrips,
    @JsonKey(name: 'bonuses') @Default(0) double bonuses,
    @JsonKey(name: 'incentives') @Default(0) double incentives,
    @Default([]) List<EarningsDataPoint> chart,
  }) = _EarningsSummary;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);
}

@freezed
abstract class EarningsDataPoint with _$EarningsDataPoint {
  const factory EarningsDataPoint({
    required String label,
    required double amount,
  }) = _EarningsDataPoint;

  factory EarningsDataPoint.fromJson(Map<String, dynamic> json) =>
      _$EarningsDataPointFromJson(json);
}

class EarningsRideItem {
  const EarningsRideItem({
    required this.rideId,
    required this.rideFare,
    required this.driverCommissionPercentage,
    required this.driverEarning,
    this.rideDate,
    required this.status,
  });

  final String rideId;
  final double rideFare;
  final double driverCommissionPercentage;
  final double driverEarning;
  final String? rideDate;
  final String status;
}
