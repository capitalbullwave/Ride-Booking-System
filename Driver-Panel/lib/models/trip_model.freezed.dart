// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trip {

 String get id; String get status;@JsonKey(name: 'pickup_address') String get pickupAddress;@JsonKey(name: 'destination_address') String get destinationAddress; double get distance; int get duration; double get fare;@JsonKey(name: 'net_earnings') double get netEarnings;@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'passenger_name') String? get passengerName;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,distance,duration,fare,netEarnings,paymentMode,passengerName,createdAt);

@override
String toString() {
  return 'Trip(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, netEarnings: $netEarnings, paymentMode: $paymentMode, passengerName: $passengerName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String? passengerName,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? netEarnings = null,Object? paymentMode = null,Object? passengerName = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trip implements Trip {
  const _Trip({required this.id, required this.status, @JsonKey(name: 'pickup_address') required this.pickupAddress, @JsonKey(name: 'destination_address') required this.destinationAddress, required this.distance, required this.duration, required this.fare, @JsonKey(name: 'net_earnings') required this.netEarnings, @JsonKey(name: 'payment_mode') required this.paymentMode, @JsonKey(name: 'passenger_name') this.passengerName, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey(name: 'pickup_address') final  String pickupAddress;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override final  double distance;
@override final  int duration;
@override final  double fare;
@override@JsonKey(name: 'net_earnings') final  double netEarnings;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'passenger_name') final  String? passengerName;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,distance,duration,fare,netEarnings,paymentMode,passengerName,createdAt);

@override
String toString() {
  return 'Trip(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, netEarnings: $netEarnings, paymentMode: $paymentMode, passengerName: $passengerName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String? passengerName,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? netEarnings = null,Object? paymentMode = null,Object? passengerName = freezed,Object? createdAt = null,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TripDetail {

 String get id; String get status;@JsonKey(name: 'pickup_address') String get pickupAddress;@JsonKey(name: 'destination_address') String get destinationAddress; double get distance; int get duration; double get fare; double get commission;@JsonKey(name: 'net_earnings') double get netEarnings;@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'passenger_name') String? get passengerName;@JsonKey(name: 'passenger_phone') String? get passengerPhone;@JsonKey(name: 'passenger_rating') double? get passengerRating;@JsonKey(name: 'driver_rating') double? get driverRating;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'completed_at') String? get completedAt;@JsonKey(name: 'route_polyline') String? get routePolyline;
/// Create a copy of TripDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripDetailCopyWith<TripDetail> get copyWith => _$TripDetailCopyWithImpl<TripDetail>(this as TripDetail, _$identity);

  /// Serializes this TripDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.routePolyline, routePolyline) || other.routePolyline == routePolyline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,distance,duration,fare,commission,netEarnings,paymentMode,passengerName,passengerPhone,passengerRating,driverRating,createdAt,completedAt,routePolyline);

@override
String toString() {
  return 'TripDetail(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, commission: $commission, netEarnings: $netEarnings, paymentMode: $paymentMode, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, driverRating: $driverRating, createdAt: $createdAt, completedAt: $completedAt, routePolyline: $routePolyline)';
}


}

/// @nodoc
abstract mixin class $TripDetailCopyWith<$Res>  {
  factory $TripDetailCopyWith(TripDetail value, $Res Function(TripDetail) _then) = _$TripDetailCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare, double commission,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String? passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double? passengerRating,@JsonKey(name: 'driver_rating') double? driverRating,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'completed_at') String? completedAt,@JsonKey(name: 'route_polyline') String? routePolyline
});




}
/// @nodoc
class _$TripDetailCopyWithImpl<$Res>
    implements $TripDetailCopyWith<$Res> {
  _$TripDetailCopyWithImpl(this._self, this._then);

  final TripDetail _self;
  final $Res Function(TripDetail) _then;

/// Create a copy of TripDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? commission = null,Object? netEarnings = null,Object? paymentMode = null,Object? passengerName = freezed,Object? passengerPhone = freezed,Object? passengerRating = freezed,Object? driverRating = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? routePolyline = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: freezed == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,routePolyline: freezed == routePolyline ? _self.routePolyline : routePolyline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TripDetail].
extension TripDetailPatterns on TripDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripDetail value)  $default,){
final _that = this;
switch (_that) {
case _TripDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TripDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'route_polyline')  String? routePolyline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripDetail() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.driverRating,_that.createdAt,_that.completedAt,_that.routePolyline);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'route_polyline')  String? routePolyline)  $default,) {final _that = this;
switch (_that) {
case _TripDetail():
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.driverRating,_that.createdAt,_that.completedAt,_that.routePolyline);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String? passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'route_polyline')  String? routePolyline)?  $default,) {final _that = this;
switch (_that) {
case _TripDetail() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.driverRating,_that.createdAt,_that.completedAt,_that.routePolyline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripDetail implements TripDetail {
  const _TripDetail({required this.id, required this.status, @JsonKey(name: 'pickup_address') required this.pickupAddress, @JsonKey(name: 'destination_address') required this.destinationAddress, required this.distance, required this.duration, required this.fare, required this.commission, @JsonKey(name: 'net_earnings') required this.netEarnings, @JsonKey(name: 'payment_mode') required this.paymentMode, @JsonKey(name: 'passenger_name') this.passengerName, @JsonKey(name: 'passenger_phone') this.passengerPhone, @JsonKey(name: 'passenger_rating') this.passengerRating, @JsonKey(name: 'driver_rating') this.driverRating, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'completed_at') this.completedAt, @JsonKey(name: 'route_polyline') this.routePolyline});
  factory _TripDetail.fromJson(Map<String, dynamic> json) => _$TripDetailFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey(name: 'pickup_address') final  String pickupAddress;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override final  double distance;
@override final  int duration;
@override final  double fare;
@override final  double commission;
@override@JsonKey(name: 'net_earnings') final  double netEarnings;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'passenger_name') final  String? passengerName;
@override@JsonKey(name: 'passenger_phone') final  String? passengerPhone;
@override@JsonKey(name: 'passenger_rating') final  double? passengerRating;
@override@JsonKey(name: 'driver_rating') final  double? driverRating;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'completed_at') final  String? completedAt;
@override@JsonKey(name: 'route_polyline') final  String? routePolyline;

/// Create a copy of TripDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripDetailCopyWith<_TripDetail> get copyWith => __$TripDetailCopyWithImpl<_TripDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.routePolyline, routePolyline) || other.routePolyline == routePolyline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,distance,duration,fare,commission,netEarnings,paymentMode,passengerName,passengerPhone,passengerRating,driverRating,createdAt,completedAt,routePolyline);

@override
String toString() {
  return 'TripDetail(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, commission: $commission, netEarnings: $netEarnings, paymentMode: $paymentMode, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, driverRating: $driverRating, createdAt: $createdAt, completedAt: $completedAt, routePolyline: $routePolyline)';
}


}

/// @nodoc
abstract mixin class _$TripDetailCopyWith<$Res> implements $TripDetailCopyWith<$Res> {
  factory _$TripDetailCopyWith(_TripDetail value, $Res Function(_TripDetail) _then) = __$TripDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare, double commission,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String? passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double? passengerRating,@JsonKey(name: 'driver_rating') double? driverRating,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'completed_at') String? completedAt,@JsonKey(name: 'route_polyline') String? routePolyline
});




}
/// @nodoc
class __$TripDetailCopyWithImpl<$Res>
    implements _$TripDetailCopyWith<$Res> {
  __$TripDetailCopyWithImpl(this._self, this._then);

  final _TripDetail _self;
  final $Res Function(_TripDetail) _then;

/// Create a copy of TripDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? commission = null,Object? netEarnings = null,Object? paymentMode = null,Object? passengerName = freezed,Object? passengerPhone = freezed,Object? passengerRating = freezed,Object? driverRating = freezed,Object? createdAt = null,Object? completedAt = freezed,Object? routePolyline = freezed,}) {
  return _then(_TripDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: freezed == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,routePolyline: freezed == routePolyline ? _self.routePolyline : routePolyline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EarningsSummary {

@JsonKey(name: 'today_earnings') double get todayEarnings;@JsonKey(name: 'weekly_earnings') double get weeklyEarnings;@JsonKey(name: 'monthly_earnings') double get monthlyEarnings;@JsonKey(name: 'total_trips') int get totalTrips;@JsonKey(name: 'today_trips') int get todayTrips;@JsonKey(name: 'bonuses') double get bonuses;@JsonKey(name: 'incentives') double get incentives; List<EarningsDataPoint> get chart;
/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsSummaryCopyWith<EarningsSummary> get copyWith => _$EarningsSummaryCopyWithImpl<EarningsSummary>(this as EarningsSummary, _$identity);

  /// Serializes this EarningsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsSummary&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.weeklyEarnings, weeklyEarnings) || other.weeklyEarnings == weeklyEarnings)&&(identical(other.monthlyEarnings, monthlyEarnings) || other.monthlyEarnings == monthlyEarnings)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.todayTrips, todayTrips) || other.todayTrips == todayTrips)&&(identical(other.bonuses, bonuses) || other.bonuses == bonuses)&&(identical(other.incentives, incentives) || other.incentives == incentives)&&const DeepCollectionEquality().equals(other.chart, chart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,todayEarnings,weeklyEarnings,monthlyEarnings,totalTrips,todayTrips,bonuses,incentives,const DeepCollectionEquality().hash(chart));

@override
String toString() {
  return 'EarningsSummary(todayEarnings: $todayEarnings, weeklyEarnings: $weeklyEarnings, monthlyEarnings: $monthlyEarnings, totalTrips: $totalTrips, todayTrips: $todayTrips, bonuses: $bonuses, incentives: $incentives, chart: $chart)';
}


}

/// @nodoc
abstract mixin class $EarningsSummaryCopyWith<$Res>  {
  factory $EarningsSummaryCopyWith(EarningsSummary value, $Res Function(EarningsSummary) _then) = _$EarningsSummaryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'today_earnings') double todayEarnings,@JsonKey(name: 'weekly_earnings') double weeklyEarnings,@JsonKey(name: 'monthly_earnings') double monthlyEarnings,@JsonKey(name: 'total_trips') int totalTrips,@JsonKey(name: 'today_trips') int todayTrips,@JsonKey(name: 'bonuses') double bonuses,@JsonKey(name: 'incentives') double incentives, List<EarningsDataPoint> chart
});




}
/// @nodoc
class _$EarningsSummaryCopyWithImpl<$Res>
    implements $EarningsSummaryCopyWith<$Res> {
  _$EarningsSummaryCopyWithImpl(this._self, this._then);

  final EarningsSummary _self;
  final $Res Function(EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todayEarnings = null,Object? weeklyEarnings = null,Object? monthlyEarnings = null,Object? totalTrips = null,Object? todayTrips = null,Object? bonuses = null,Object? incentives = null,Object? chart = null,}) {
  return _then(_self.copyWith(
todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,weeklyEarnings: null == weeklyEarnings ? _self.weeklyEarnings : weeklyEarnings // ignore: cast_nullable_to_non_nullable
as double,monthlyEarnings: null == monthlyEarnings ? _self.monthlyEarnings : monthlyEarnings // ignore: cast_nullable_to_non_nullable
as double,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,todayTrips: null == todayTrips ? _self.todayTrips : todayTrips // ignore: cast_nullable_to_non_nullable
as int,bonuses: null == bonuses ? _self.bonuses : bonuses // ignore: cast_nullable_to_non_nullable
as double,incentives: null == incentives ? _self.incentives : incentives // ignore: cast_nullable_to_non_nullable
as double,chart: null == chart ? _self.chart : chart // ignore: cast_nullable_to_non_nullable
as List<EarningsDataPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsSummary].
extension EarningsSummaryPatterns on EarningsSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsSummary value)  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'weekly_earnings')  double weeklyEarnings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'today_trips')  int todayTrips, @JsonKey(name: 'bonuses')  double bonuses, @JsonKey(name: 'incentives')  double incentives,  List<EarningsDataPoint> chart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.todayEarnings,_that.weeklyEarnings,_that.monthlyEarnings,_that.totalTrips,_that.todayTrips,_that.bonuses,_that.incentives,_that.chart);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'weekly_earnings')  double weeklyEarnings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'today_trips')  int todayTrips, @JsonKey(name: 'bonuses')  double bonuses, @JsonKey(name: 'incentives')  double incentives,  List<EarningsDataPoint> chart)  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary():
return $default(_that.todayEarnings,_that.weeklyEarnings,_that.monthlyEarnings,_that.totalTrips,_that.todayTrips,_that.bonuses,_that.incentives,_that.chart);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'today_earnings')  double todayEarnings, @JsonKey(name: 'weekly_earnings')  double weeklyEarnings, @JsonKey(name: 'monthly_earnings')  double monthlyEarnings, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'today_trips')  int todayTrips, @JsonKey(name: 'bonuses')  double bonuses, @JsonKey(name: 'incentives')  double incentives,  List<EarningsDataPoint> chart)?  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.todayEarnings,_that.weeklyEarnings,_that.monthlyEarnings,_that.totalTrips,_that.todayTrips,_that.bonuses,_that.incentives,_that.chart);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsSummary implements EarningsSummary {
  const _EarningsSummary({@JsonKey(name: 'today_earnings') this.todayEarnings = 0, @JsonKey(name: 'weekly_earnings') this.weeklyEarnings = 0, @JsonKey(name: 'monthly_earnings') this.monthlyEarnings = 0, @JsonKey(name: 'total_trips') this.totalTrips = 0, @JsonKey(name: 'today_trips') this.todayTrips = 0, @JsonKey(name: 'bonuses') this.bonuses = 0, @JsonKey(name: 'incentives') this.incentives = 0, final  List<EarningsDataPoint> chart = const []}): _chart = chart;
  factory _EarningsSummary.fromJson(Map<String, dynamic> json) => _$EarningsSummaryFromJson(json);

@override@JsonKey(name: 'today_earnings') final  double todayEarnings;
@override@JsonKey(name: 'weekly_earnings') final  double weeklyEarnings;
@override@JsonKey(name: 'monthly_earnings') final  double monthlyEarnings;
@override@JsonKey(name: 'total_trips') final  int totalTrips;
@override@JsonKey(name: 'today_trips') final  int todayTrips;
@override@JsonKey(name: 'bonuses') final  double bonuses;
@override@JsonKey(name: 'incentives') final  double incentives;
 final  List<EarningsDataPoint> _chart;
@override@JsonKey() List<EarningsDataPoint> get chart {
  if (_chart is EqualUnmodifiableListView) return _chart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chart);
}


/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsSummaryCopyWith<_EarningsSummary> get copyWith => __$EarningsSummaryCopyWithImpl<_EarningsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsSummary&&(identical(other.todayEarnings, todayEarnings) || other.todayEarnings == todayEarnings)&&(identical(other.weeklyEarnings, weeklyEarnings) || other.weeklyEarnings == weeklyEarnings)&&(identical(other.monthlyEarnings, monthlyEarnings) || other.monthlyEarnings == monthlyEarnings)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.todayTrips, todayTrips) || other.todayTrips == todayTrips)&&(identical(other.bonuses, bonuses) || other.bonuses == bonuses)&&(identical(other.incentives, incentives) || other.incentives == incentives)&&const DeepCollectionEquality().equals(other._chart, _chart));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,todayEarnings,weeklyEarnings,monthlyEarnings,totalTrips,todayTrips,bonuses,incentives,const DeepCollectionEquality().hash(_chart));

@override
String toString() {
  return 'EarningsSummary(todayEarnings: $todayEarnings, weeklyEarnings: $weeklyEarnings, monthlyEarnings: $monthlyEarnings, totalTrips: $totalTrips, todayTrips: $todayTrips, bonuses: $bonuses, incentives: $incentives, chart: $chart)';
}


}

/// @nodoc
abstract mixin class _$EarningsSummaryCopyWith<$Res> implements $EarningsSummaryCopyWith<$Res> {
  factory _$EarningsSummaryCopyWith(_EarningsSummary value, $Res Function(_EarningsSummary) _then) = __$EarningsSummaryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'today_earnings') double todayEarnings,@JsonKey(name: 'weekly_earnings') double weeklyEarnings,@JsonKey(name: 'monthly_earnings') double monthlyEarnings,@JsonKey(name: 'total_trips') int totalTrips,@JsonKey(name: 'today_trips') int todayTrips,@JsonKey(name: 'bonuses') double bonuses,@JsonKey(name: 'incentives') double incentives, List<EarningsDataPoint> chart
});




}
/// @nodoc
class __$EarningsSummaryCopyWithImpl<$Res>
    implements _$EarningsSummaryCopyWith<$Res> {
  __$EarningsSummaryCopyWithImpl(this._self, this._then);

  final _EarningsSummary _self;
  final $Res Function(_EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todayEarnings = null,Object? weeklyEarnings = null,Object? monthlyEarnings = null,Object? totalTrips = null,Object? todayTrips = null,Object? bonuses = null,Object? incentives = null,Object? chart = null,}) {
  return _then(_EarningsSummary(
todayEarnings: null == todayEarnings ? _self.todayEarnings : todayEarnings // ignore: cast_nullable_to_non_nullable
as double,weeklyEarnings: null == weeklyEarnings ? _self.weeklyEarnings : weeklyEarnings // ignore: cast_nullable_to_non_nullable
as double,monthlyEarnings: null == monthlyEarnings ? _self.monthlyEarnings : monthlyEarnings // ignore: cast_nullable_to_non_nullable
as double,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,todayTrips: null == todayTrips ? _self.todayTrips : todayTrips // ignore: cast_nullable_to_non_nullable
as int,bonuses: null == bonuses ? _self.bonuses : bonuses // ignore: cast_nullable_to_non_nullable
as double,incentives: null == incentives ? _self.incentives : incentives // ignore: cast_nullable_to_non_nullable
as double,chart: null == chart ? _self._chart : chart // ignore: cast_nullable_to_non_nullable
as List<EarningsDataPoint>,
  ));
}


}


/// @nodoc
mixin _$EarningsDataPoint {

 String get label; double get amount;
/// Create a copy of EarningsDataPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsDataPointCopyWith<EarningsDataPoint> get copyWith => _$EarningsDataPointCopyWithImpl<EarningsDataPoint>(this as EarningsDataPoint, _$identity);

  /// Serializes this EarningsDataPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsDataPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,amount);

@override
String toString() {
  return 'EarningsDataPoint(label: $label, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $EarningsDataPointCopyWith<$Res>  {
  factory $EarningsDataPointCopyWith(EarningsDataPoint value, $Res Function(EarningsDataPoint) _then) = _$EarningsDataPointCopyWithImpl;
@useResult
$Res call({
 String label, double amount
});




}
/// @nodoc
class _$EarningsDataPointCopyWithImpl<$Res>
    implements $EarningsDataPointCopyWith<$Res> {
  _$EarningsDataPointCopyWithImpl(this._self, this._then);

  final EarningsDataPoint _self;
  final $Res Function(EarningsDataPoint) _then;

/// Create a copy of EarningsDataPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? amount = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsDataPoint].
extension EarningsDataPointPatterns on EarningsDataPoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsDataPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsDataPoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsDataPoint value)  $default,){
final _that = this;
switch (_that) {
case _EarningsDataPoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsDataPoint value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsDataPoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsDataPoint() when $default != null:
return $default(_that.label,_that.amount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double amount)  $default,) {final _that = this;
switch (_that) {
case _EarningsDataPoint():
return $default(_that.label,_that.amount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _EarningsDataPoint() when $default != null:
return $default(_that.label,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsDataPoint implements EarningsDataPoint {
  const _EarningsDataPoint({required this.label, required this.amount});
  factory _EarningsDataPoint.fromJson(Map<String, dynamic> json) => _$EarningsDataPointFromJson(json);

@override final  String label;
@override final  double amount;

/// Create a copy of EarningsDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsDataPointCopyWith<_EarningsDataPoint> get copyWith => __$EarningsDataPointCopyWithImpl<_EarningsDataPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsDataPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsDataPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,amount);

@override
String toString() {
  return 'EarningsDataPoint(label: $label, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$EarningsDataPointCopyWith<$Res> implements $EarningsDataPointCopyWith<$Res> {
  factory _$EarningsDataPointCopyWith(_EarningsDataPoint value, $Res Function(_EarningsDataPoint) _then) = __$EarningsDataPointCopyWithImpl;
@override @useResult
$Res call({
 String label, double amount
});




}
/// @nodoc
class __$EarningsDataPointCopyWithImpl<$Res>
    implements _$EarningsDataPointCopyWith<$Res> {
  __$EarningsDataPointCopyWithImpl(this._self, this._then);

  final _EarningsDataPoint _self;
  final $Res Function(_EarningsDataPoint) _then;

/// Create a copy of EarningsDataPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? amount = null,}) {
  return _then(_EarningsDataPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
