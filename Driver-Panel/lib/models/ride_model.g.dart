// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideRequest _$RideRequestFromJson(Map<String, dynamic> json) => _RideRequest(
  id: json['id'] as String,
  pickupAddress: json['pickup_address'] as String,
  destinationAddress: json['destination_address'] as String,
  pickupLat: (json['pickup_lat'] as num).toDouble(),
  pickupLng: (json['pickup_lng'] as num).toDouble(),
  destinationLat: (json['destination_lat'] as num).toDouble(),
  destinationLng: (json['destination_lng'] as num).toDouble(),
  distance: (json['distance'] as num).toDouble(),
  estimatedTime: (json['estimated_time'] as num).toInt(),
  estimatedFare: (json['estimated_fare'] as num).toDouble(),
  paymentMode: json['payment_mode'] as String,
  passengerName: json['passenger_name'] as String,
  passengerPhone: json['passenger_phone'] as String?,
  passengerRating: (json['passenger_rating'] as num?)?.toDouble() ?? 4.5,
  expiresIn: (json['expires_in'] as num?)?.toInt() ?? 15,
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => RideStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RideStop>[],
);

Map<String, dynamic> _$RideRequestToJson(_RideRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pickup_address': instance.pickupAddress,
      'destination_address': instance.destinationAddress,
      'pickup_lat': instance.pickupLat,
      'pickup_lng': instance.pickupLng,
      'destination_lat': instance.destinationLat,
      'destination_lng': instance.destinationLng,
      'distance': instance.distance,
      'estimated_time': instance.estimatedTime,
      'estimated_fare': instance.estimatedFare,
      'payment_mode': instance.paymentMode,
      'passenger_name': instance.passengerName,
      'passenger_phone': instance.passengerPhone,
      'passenger_rating': instance.passengerRating,
      'expires_in': instance.expiresIn,
      'stops': instance.stops,
    };

_ActiveRide _$ActiveRideFromJson(Map<String, dynamic> json) => _ActiveRide(
  id: json['id'] as String,
  status: json['status'] as String,
  pickupAddress: json['pickup_address'] as String,
  destinationAddress: json['destination_address'] as String,
  pickupLat: (json['pickup_lat'] as num).toDouble(),
  pickupLng: (json['pickup_lng'] as num).toDouble(),
  destinationLat: (json['destination_lat'] as num).toDouble(),
  destinationLng: (json['destination_lng'] as num).toDouble(),
  passengerName: json['passenger_name'] as String,
  passengerPhone: json['passenger_phone'] as String?,
  passengerRating: (json['passenger_rating'] as num?)?.toDouble() ?? 4.5,
  paymentMode: json['payment_mode'] as String,
  estimatedFare: (json['estimated_fare'] as num).toDouble(),
  distance: (json['distance'] as num?)?.toDouble(),
  startedAt: json['started_at'] as String?,
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => RideStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RideStop>[],
);

Map<String, dynamic> _$ActiveRideToJson(_ActiveRide instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'pickup_address': instance.pickupAddress,
      'destination_address': instance.destinationAddress,
      'pickup_lat': instance.pickupLat,
      'pickup_lng': instance.pickupLng,
      'destination_lat': instance.destinationLat,
      'destination_lng': instance.destinationLng,
      'passenger_name': instance.passengerName,
      'passenger_phone': instance.passengerPhone,
      'passenger_rating': instance.passengerRating,
      'payment_mode': instance.paymentMode,
      'estimated_fare': instance.estimatedFare,
      'distance': instance.distance,
      'started_at': instance.startedAt,
      'stops': instance.stops,
    };

_RideSummary _$RideSummaryFromJson(Map<String, dynamic> json) => _RideSummary(
  id: json['id'] as String,
  pickupAddress: json['pickup_address'] as String,
  destinationAddress: json['destination_address'] as String,
  distance: (json['distance'] as num).toDouble(),
  duration: (json['duration'] as num).toInt(),
  fare: (json['fare'] as num).toDouble(),
  commission: (json['commission'] as num).toDouble(),
  netEarnings: (json['net_earnings'] as num).toDouble(),
  passengerRating: (json['passenger_rating'] as num?)?.toDouble(),
  driverRating: (json['driver_rating'] as num?)?.toDouble(),
  paymentMode: json['payment_mode'] as String,
  completedAt: json['completed_at'] as String?,
  stops:
      (json['stops'] as List<dynamic>?)
          ?.map((e) => RideStop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RideStop>[],
);

Map<String, dynamic> _$RideSummaryToJson(_RideSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pickup_address': instance.pickupAddress,
      'destination_address': instance.destinationAddress,
      'distance': instance.distance,
      'duration': instance.duration,
      'fare': instance.fare,
      'commission': instance.commission,
      'net_earnings': instance.netEarnings,
      'passenger_rating': instance.passengerRating,
      'driver_rating': instance.driverRating,
      'payment_mode': instance.paymentMode,
      'completed_at': instance.completedAt,
      'stops': instance.stops,
    };

_PaymentBreakdown _$PaymentBreakdownFromJson(Map<String, dynamic> json) =>
    _PaymentBreakdown(
      tripFare: (json['trip_fare'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      paymentMode: json['payment_mode'] as String,
    );

Map<String, dynamic> _$PaymentBreakdownToJson(_PaymentBreakdown instance) =>
    <String, dynamic>{
      'trip_fare': instance.tripFare,
      'commission': instance.commission,
      'bonus': instance.bonus,
      'total_earnings': instance.totalEarnings,
      'payment_mode': instance.paymentMode,
    };
