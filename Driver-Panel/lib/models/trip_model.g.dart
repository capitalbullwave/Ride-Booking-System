// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Trip _$TripFromJson(Map<String, dynamic> json) => _Trip(
  id: json['id'] as String,
  status: json['status'] as String,
  pickupAddress: json['pickup_address'] as String,
  destinationAddress: json['destination_address'] as String,
  distance: (json['distance'] as num).toDouble(),
  duration: (json['duration'] as num).toInt(),
  fare: (json['fare'] as num).toDouble(),
  netEarnings: (json['net_earnings'] as num).toDouble(),
  paymentMode: json['payment_mode'] as String,
  passengerName: json['passenger_name'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$TripToJson(_Trip instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'pickup_address': instance.pickupAddress,
  'destination_address': instance.destinationAddress,
  'distance': instance.distance,
  'duration': instance.duration,
  'fare': instance.fare,
  'net_earnings': instance.netEarnings,
  'payment_mode': instance.paymentMode,
  'passenger_name': instance.passengerName,
  'created_at': instance.createdAt,
};

_TripDetail _$TripDetailFromJson(Map<String, dynamic> json) => _TripDetail(
  id: json['id'] as String,
  status: json['status'] as String,
  pickupAddress: json['pickup_address'] as String,
  destinationAddress: json['destination_address'] as String,
  distance: (json['distance'] as num).toDouble(),
  duration: (json['duration'] as num).toInt(),
  fare: (json['fare'] as num).toDouble(),
  commission: (json['commission'] as num).toDouble(),
  netEarnings: (json['net_earnings'] as num).toDouble(),
  paymentMode: json['payment_mode'] as String,
  passengerName: json['passenger_name'] as String?,
  passengerPhone: json['passenger_phone'] as String?,
  passengerRating: (json['passenger_rating'] as num?)?.toDouble(),
  driverRating: (json['driver_rating'] as num?)?.toDouble(),
  createdAt: json['created_at'] as String,
  completedAt: json['completed_at'] as String?,
  routePolyline: json['route_polyline'] as String?,
);

Map<String, dynamic> _$TripDetailToJson(_TripDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'pickup_address': instance.pickupAddress,
      'destination_address': instance.destinationAddress,
      'distance': instance.distance,
      'duration': instance.duration,
      'fare': instance.fare,
      'commission': instance.commission,
      'net_earnings': instance.netEarnings,
      'payment_mode': instance.paymentMode,
      'passenger_name': instance.passengerName,
      'passenger_phone': instance.passengerPhone,
      'passenger_rating': instance.passengerRating,
      'driver_rating': instance.driverRating,
      'created_at': instance.createdAt,
      'completed_at': instance.completedAt,
      'route_polyline': instance.routePolyline,
    };

_EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) =>
    _EarningsSummary(
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weekly_earnings'] as num?)?.toDouble() ?? 0,
      monthlyEarnings: (json['monthly_earnings'] as num?)?.toDouble() ?? 0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      todayTrips: (json['today_trips'] as num?)?.toInt() ?? 0,
      bonuses: (json['bonuses'] as num?)?.toDouble() ?? 0,
      incentives: (json['incentives'] as num?)?.toDouble() ?? 0,
      chart:
          (json['chart'] as List<dynamic>?)
              ?.map(
                (e) => EarningsDataPoint.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EarningsSummaryToJson(_EarningsSummary instance) =>
    <String, dynamic>{
      'today_earnings': instance.todayEarnings,
      'weekly_earnings': instance.weeklyEarnings,
      'monthly_earnings': instance.monthlyEarnings,
      'total_trips': instance.totalTrips,
      'today_trips': instance.todayTrips,
      'bonuses': instance.bonuses,
      'incentives': instance.incentives,
      'chart': instance.chart,
    };

_EarningsDataPoint _$EarningsDataPointFromJson(Map<String, dynamic> json) =>
    _EarningsDataPoint(
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningsDataPointToJson(_EarningsDataPoint instance) =>
    <String, dynamic>{'label': instance.label, 'amount': instance.amount};
