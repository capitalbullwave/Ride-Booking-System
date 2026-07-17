import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_model.freezed.dart';
part 'ride_model.g.dart';

class RideStop {
  const RideStop({
    required this.address,
    required this.lat,
    required this.lng,
    this.sequence = 1,
  });

  final String address;
  final double lat;
  final double lng;
  final int sequence;

  factory RideStop.fromJson(Map<String, dynamic> json) => RideStop(
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        sequence: (json['sequence'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'lat': lat,
        'lng': lng,
        'sequence': sequence,
      };
}

@freezed
abstract class RideRequest with _$RideRequest {
  const factory RideRequest({
    required String id,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    @JsonKey(name: 'pickup_lat') required double pickupLat,
    @JsonKey(name: 'pickup_lng') required double pickupLng,
    @JsonKey(name: 'destination_lat') required double destinationLat,
    @JsonKey(name: 'destination_lng') required double destinationLng,
    required double distance,
    @JsonKey(name: 'estimated_time') required int estimatedTime,
    @JsonKey(name: 'estimated_fare') required double estimatedFare,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'passenger_name') required String passengerName,
    @JsonKey(name: 'passenger_phone') String? passengerPhone,
    @JsonKey(name: 'passenger_rating') @Default(4.5) double passengerRating,
    @JsonKey(name: 'expires_in') @Default(15) int expiresIn,
    @JsonKey(name: 'stops') @Default(<RideStop>[]) List<RideStop> stops,
  }) = _RideRequest;

  factory RideRequest.fromJson(Map<String, dynamic> json) =>
      _$RideRequestFromJson(json);
}

@freezed
abstract class ActiveRide with _$ActiveRide {
  const factory ActiveRide({
    required String id,
    required String status,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    @JsonKey(name: 'pickup_lat') required double pickupLat,
    @JsonKey(name: 'pickup_lng') required double pickupLng,
    @JsonKey(name: 'destination_lat') required double destinationLat,
    @JsonKey(name: 'destination_lng') required double destinationLng,
    @JsonKey(name: 'passenger_name') required String passengerName,
    @JsonKey(name: 'passenger_phone') String? passengerPhone,
    @JsonKey(name: 'passenger_rating') @Default(4.5) double passengerRating,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'estimated_fare') required double estimatedFare,
    double? distance,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'stops') @Default(<RideStop>[]) List<RideStop> stops,
  }) = _ActiveRide;

  factory ActiveRide.fromJson(Map<String, dynamic> json) =>
      _$ActiveRideFromJson(json);
}

enum RideStatus {
  @JsonValue('heading_to_pickup')
  headingToPickup,
  @JsonValue('arrived')
  arrived,
  @JsonValue('started')
  started,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class RideSummary with _$RideSummary {
  const factory RideSummary({
    required String id,
    @JsonKey(name: 'pickup_address') required String pickupAddress,
    @JsonKey(name: 'destination_address') required String destinationAddress,
    required double distance,
    required int duration,
    required double fare,
    required double commission,
    @JsonKey(name: 'net_earnings') required double netEarnings,
    @JsonKey(name: 'passenger_rating') double? passengerRating,
    @JsonKey(name: 'driver_rating') double? driverRating,
    @JsonKey(name: 'payment_mode') required String paymentMode,
    @JsonKey(name: 'completed_at') String? completedAt,
    @JsonKey(name: 'stops') @Default(<RideStop>[]) List<RideStop> stops,
  }) = _RideSummary;

  factory RideSummary.fromJson(Map<String, dynamic> json) =>
      _$RideSummaryFromJson(json);
}

@freezed
abstract class PaymentBreakdown with _$PaymentBreakdown {
  const factory PaymentBreakdown({
    @JsonKey(name: 'trip_fare') required double tripFare,
    required double commission,
    @Default(0) double bonus,
    @JsonKey(name: 'total_earnings') required double totalEarnings,
    @JsonKey(name: 'payment_mode') required String paymentMode,
  }) = _PaymentBreakdown;

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) =>
      _$PaymentBreakdownFromJson(json);
}
