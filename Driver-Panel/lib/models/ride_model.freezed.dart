// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideRequest {

 String get id;@JsonKey(name: 'pickup_address') String get pickupAddress;@JsonKey(name: 'destination_address') String get destinationAddress;@JsonKey(name: 'pickup_lat') double get pickupLat;@JsonKey(name: 'pickup_lng') double get pickupLng;@JsonKey(name: 'destination_lat') double get destinationLat;@JsonKey(name: 'destination_lng') double get destinationLng; double get distance;@JsonKey(name: 'estimated_time') int get estimatedTime;@JsonKey(name: 'estimated_fare') double get estimatedFare;@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'passenger_name') String get passengerName;@JsonKey(name: 'passenger_phone') String? get passengerPhone;@JsonKey(name: 'passenger_rating') double get passengerRating;@JsonKey(name: 'expires_in') int get expiresIn;@JsonKey(name: 'stops') List<RideStop> get stops;
/// Create a copy of RideRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideRequestCopyWith<RideRequest> get copyWith => _$RideRequestCopyWithImpl<RideRequest>(this as RideRequest, _$identity);

  /// Serializes this RideRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.estimatedFare, estimatedFare) || other.estimatedFare == estimatedFare)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&const DeepCollectionEquality().equals(other.stops, stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pickupAddress,destinationAddress,pickupLat,pickupLng,destinationLat,destinationLng,distance,estimatedTime,estimatedFare,paymentMode,passengerName,passengerPhone,passengerRating,expiresIn,const DeepCollectionEquality().hash(stops));

@override
String toString() {
  return 'RideRequest(id: $id, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, pickupLat: $pickupLat, pickupLng: $pickupLng, destinationLat: $destinationLat, destinationLng: $destinationLng, distance: $distance, estimatedTime: $estimatedTime, estimatedFare: $estimatedFare, paymentMode: $paymentMode, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, expiresIn: $expiresIn, stops: $stops)';
}


}

/// @nodoc
abstract mixin class $RideRequestCopyWith<$Res>  {
  factory $RideRequestCopyWith(RideRequest value, $Res Function(RideRequest) _then) = _$RideRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'pickup_lat') double pickupLat,@JsonKey(name: 'pickup_lng') double pickupLng,@JsonKey(name: 'destination_lat') double destinationLat,@JsonKey(name: 'destination_lng') double destinationLng, double distance,@JsonKey(name: 'estimated_time') int estimatedTime,@JsonKey(name: 'estimated_fare') double estimatedFare,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double passengerRating,@JsonKey(name: 'expires_in') int expiresIn,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class _$RideRequestCopyWithImpl<$Res>
    implements $RideRequestCopyWith<$Res> {
  _$RideRequestCopyWithImpl(this._self, this._then);

  final RideRequest _self;
  final $Res Function(RideRequest) _then;

/// Create a copy of RideRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? pickupLat = null,Object? pickupLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? distance = null,Object? estimatedTime = null,Object? estimatedFare = null,Object? paymentMode = null,Object? passengerName = null,Object? passengerPhone = freezed,Object? passengerRating = null,Object? expiresIn = null,Object? stops = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,pickupLat: null == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double,pickupLng: null == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,estimatedTime: null == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}

}


/// Adds pattern-matching-related methods to [RideRequest].
extension RideRequestPatterns on RideRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideRequest value)  $default,){
final _that = this;
switch (_that) {
case _RideRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RideRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng,  double distance, @JsonKey(name: 'estimated_time')  int estimatedTime, @JsonKey(name: 'estimated_fare')  double estimatedFare, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'expires_in')  int expiresIn, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideRequest() when $default != null:
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.distance,_that.estimatedTime,_that.estimatedFare,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.expiresIn,_that.stops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng,  double distance, @JsonKey(name: 'estimated_time')  int estimatedTime, @JsonKey(name: 'estimated_fare')  double estimatedFare, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'expires_in')  int expiresIn, @JsonKey(name: 'stops')  List<RideStop> stops)  $default,) {final _that = this;
switch (_that) {
case _RideRequest():
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.distance,_that.estimatedTime,_that.estimatedFare,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.expiresIn,_that.stops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng,  double distance, @JsonKey(name: 'estimated_time')  int estimatedTime, @JsonKey(name: 'estimated_fare')  double estimatedFare, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'expires_in')  int expiresIn, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,) {final _that = this;
switch (_that) {
case _RideRequest() when $default != null:
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.distance,_that.estimatedTime,_that.estimatedFare,_that.paymentMode,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.expiresIn,_that.stops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideRequest implements RideRequest {
  const _RideRequest({required this.id, @JsonKey(name: 'pickup_address') required this.pickupAddress, @JsonKey(name: 'destination_address') required this.destinationAddress, @JsonKey(name: 'pickup_lat') required this.pickupLat, @JsonKey(name: 'pickup_lng') required this.pickupLng, @JsonKey(name: 'destination_lat') required this.destinationLat, @JsonKey(name: 'destination_lng') required this.destinationLng, required this.distance, @JsonKey(name: 'estimated_time') required this.estimatedTime, @JsonKey(name: 'estimated_fare') required this.estimatedFare, @JsonKey(name: 'payment_mode') required this.paymentMode, @JsonKey(name: 'passenger_name') required this.passengerName, @JsonKey(name: 'passenger_phone') this.passengerPhone, @JsonKey(name: 'passenger_rating') this.passengerRating = 4.5, @JsonKey(name: 'expires_in') this.expiresIn = 15, @JsonKey(name: 'stops') final  List<RideStop> stops = const <RideStop>[]}): _stops = stops;
  factory _RideRequest.fromJson(Map<String, dynamic> json) => _$RideRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'pickup_address') final  String pickupAddress;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override@JsonKey(name: 'pickup_lat') final  double pickupLat;
@override@JsonKey(name: 'pickup_lng') final  double pickupLng;
@override@JsonKey(name: 'destination_lat') final  double destinationLat;
@override@JsonKey(name: 'destination_lng') final  double destinationLng;
@override final  double distance;
@override@JsonKey(name: 'estimated_time') final  int estimatedTime;
@override@JsonKey(name: 'estimated_fare') final  double estimatedFare;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'passenger_name') final  String passengerName;
@override@JsonKey(name: 'passenger_phone') final  String? passengerPhone;
@override@JsonKey(name: 'passenger_rating') final  double passengerRating;
@override@JsonKey(name: 'expires_in') final  int expiresIn;
 final  List<RideStop> _stops;
@override@JsonKey(name: 'stops') List<RideStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


/// Create a copy of RideRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideRequestCopyWith<_RideRequest> get copyWith => __$RideRequestCopyWithImpl<_RideRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.estimatedFare, estimatedFare) || other.estimatedFare == estimatedFare)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&const DeepCollectionEquality().equals(other._stops, _stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pickupAddress,destinationAddress,pickupLat,pickupLng,destinationLat,destinationLng,distance,estimatedTime,estimatedFare,paymentMode,passengerName,passengerPhone,passengerRating,expiresIn,const DeepCollectionEquality().hash(_stops));

@override
String toString() {
  return 'RideRequest(id: $id, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, pickupLat: $pickupLat, pickupLng: $pickupLng, destinationLat: $destinationLat, destinationLng: $destinationLng, distance: $distance, estimatedTime: $estimatedTime, estimatedFare: $estimatedFare, paymentMode: $paymentMode, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, expiresIn: $expiresIn, stops: $stops)';
}


}

/// @nodoc
abstract mixin class _$RideRequestCopyWith<$Res> implements $RideRequestCopyWith<$Res> {
  factory _$RideRequestCopyWith(_RideRequest value, $Res Function(_RideRequest) _then) = __$RideRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'pickup_lat') double pickupLat,@JsonKey(name: 'pickup_lng') double pickupLng,@JsonKey(name: 'destination_lat') double destinationLat,@JsonKey(name: 'destination_lng') double destinationLng, double distance,@JsonKey(name: 'estimated_time') int estimatedTime,@JsonKey(name: 'estimated_fare') double estimatedFare,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'passenger_name') String passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double passengerRating,@JsonKey(name: 'expires_in') int expiresIn,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class __$RideRequestCopyWithImpl<$Res>
    implements _$RideRequestCopyWith<$Res> {
  __$RideRequestCopyWithImpl(this._self, this._then);

  final _RideRequest _self;
  final $Res Function(_RideRequest) _then;

/// Create a copy of RideRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? pickupLat = null,Object? pickupLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? distance = null,Object? estimatedTime = null,Object? estimatedFare = null,Object? paymentMode = null,Object? passengerName = null,Object? passengerPhone = freezed,Object? passengerRating = null,Object? expiresIn = null,Object? stops = null,}) {
  return _then(_RideRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,pickupLat: null == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double,pickupLng: null == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,estimatedTime: null == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as int,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}


}


/// @nodoc
mixin _$ActiveRide {

 String get id; String get status;@JsonKey(name: 'pickup_address') String get pickupAddress;@JsonKey(name: 'destination_address') String get destinationAddress;@JsonKey(name: 'pickup_lat') double get pickupLat;@JsonKey(name: 'pickup_lng') double get pickupLng;@JsonKey(name: 'destination_lat') double get destinationLat;@JsonKey(name: 'destination_lng') double get destinationLng;@JsonKey(name: 'passenger_name') String get passengerName;@JsonKey(name: 'passenger_phone') String? get passengerPhone;@JsonKey(name: 'passenger_rating') double get passengerRating;@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'estimated_fare') double get estimatedFare; double? get distance;@JsonKey(name: 'started_at') String? get startedAt;@JsonKey(name: 'stops') List<RideStop> get stops;
/// Create a copy of ActiveRide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActiveRideCopyWith<ActiveRide> get copyWith => _$ActiveRideCopyWithImpl<ActiveRide>(this as ActiveRide, _$identity);

  /// Serializes this ActiveRide to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActiveRide&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.estimatedFare, estimatedFare) || other.estimatedFare == estimatedFare)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.stops, stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,pickupLat,pickupLng,destinationLat,destinationLng,passengerName,passengerPhone,passengerRating,paymentMode,estimatedFare,distance,startedAt,const DeepCollectionEquality().hash(stops));

@override
String toString() {
  return 'ActiveRide(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, pickupLat: $pickupLat, pickupLng: $pickupLng, destinationLat: $destinationLat, destinationLng: $destinationLng, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, paymentMode: $paymentMode, estimatedFare: $estimatedFare, distance: $distance, startedAt: $startedAt, stops: $stops)';
}


}

/// @nodoc
abstract mixin class $ActiveRideCopyWith<$Res>  {
  factory $ActiveRideCopyWith(ActiveRide value, $Res Function(ActiveRide) _then) = _$ActiveRideCopyWithImpl;
@useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'pickup_lat') double pickupLat,@JsonKey(name: 'pickup_lng') double pickupLng,@JsonKey(name: 'destination_lat') double destinationLat,@JsonKey(name: 'destination_lng') double destinationLng,@JsonKey(name: 'passenger_name') String passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double passengerRating,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'estimated_fare') double estimatedFare, double? distance,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class _$ActiveRideCopyWithImpl<$Res>
    implements $ActiveRideCopyWith<$Res> {
  _$ActiveRideCopyWithImpl(this._self, this._then);

  final ActiveRide _self;
  final $Res Function(ActiveRide) _then;

/// Create a copy of ActiveRide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? pickupLat = null,Object? pickupLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? passengerName = null,Object? passengerPhone = freezed,Object? passengerRating = null,Object? paymentMode = null,Object? estimatedFare = null,Object? distance = freezed,Object? startedAt = freezed,Object? stops = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,pickupLat: null == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double,pickupLng: null == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActiveRide].
extension ActiveRidePatterns on ActiveRide {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActiveRide value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActiveRide() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActiveRide value)  $default,){
final _that = this;
switch (_that) {
case _ActiveRide():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActiveRide value)?  $default,){
final _that = this;
switch (_that) {
case _ActiveRide() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'estimated_fare')  double estimatedFare,  double? distance, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActiveRide() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.paymentMode,_that.estimatedFare,_that.distance,_that.startedAt,_that.stops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'estimated_fare')  double estimatedFare,  double? distance, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'stops')  List<RideStop> stops)  $default,) {final _that = this;
switch (_that) {
case _ActiveRide():
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.paymentMode,_that.estimatedFare,_that.distance,_that.startedAt,_that.stops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress, @JsonKey(name: 'pickup_lat')  double pickupLat, @JsonKey(name: 'pickup_lng')  double pickupLng, @JsonKey(name: 'destination_lat')  double destinationLat, @JsonKey(name: 'destination_lng')  double destinationLng, @JsonKey(name: 'passenger_name')  String passengerName, @JsonKey(name: 'passenger_phone')  String? passengerPhone, @JsonKey(name: 'passenger_rating')  double passengerRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'estimated_fare')  double estimatedFare,  double? distance, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,) {final _that = this;
switch (_that) {
case _ActiveRide() when $default != null:
return $default(_that.id,_that.status,_that.pickupAddress,_that.destinationAddress,_that.pickupLat,_that.pickupLng,_that.destinationLat,_that.destinationLng,_that.passengerName,_that.passengerPhone,_that.passengerRating,_that.paymentMode,_that.estimatedFare,_that.distance,_that.startedAt,_that.stops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActiveRide implements ActiveRide {
  const _ActiveRide({required this.id, required this.status, @JsonKey(name: 'pickup_address') required this.pickupAddress, @JsonKey(name: 'destination_address') required this.destinationAddress, @JsonKey(name: 'pickup_lat') required this.pickupLat, @JsonKey(name: 'pickup_lng') required this.pickupLng, @JsonKey(name: 'destination_lat') required this.destinationLat, @JsonKey(name: 'destination_lng') required this.destinationLng, @JsonKey(name: 'passenger_name') required this.passengerName, @JsonKey(name: 'passenger_phone') this.passengerPhone, @JsonKey(name: 'passenger_rating') this.passengerRating = 4.5, @JsonKey(name: 'payment_mode') required this.paymentMode, @JsonKey(name: 'estimated_fare') required this.estimatedFare, this.distance, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'stops') final  List<RideStop> stops = const <RideStop>[]}): _stops = stops;
  factory _ActiveRide.fromJson(Map<String, dynamic> json) => _$ActiveRideFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey(name: 'pickup_address') final  String pickupAddress;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override@JsonKey(name: 'pickup_lat') final  double pickupLat;
@override@JsonKey(name: 'pickup_lng') final  double pickupLng;
@override@JsonKey(name: 'destination_lat') final  double destinationLat;
@override@JsonKey(name: 'destination_lng') final  double destinationLng;
@override@JsonKey(name: 'passenger_name') final  String passengerName;
@override@JsonKey(name: 'passenger_phone') final  String? passengerPhone;
@override@JsonKey(name: 'passenger_rating') final  double passengerRating;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'estimated_fare') final  double estimatedFare;
@override final  double? distance;
@override@JsonKey(name: 'started_at') final  String? startedAt;
 final  List<RideStop> _stops;
@override@JsonKey(name: 'stops') List<RideStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


/// Create a copy of ActiveRide
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActiveRideCopyWith<_ActiveRide> get copyWith => __$ActiveRideCopyWithImpl<_ActiveRide>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActiveRideToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActiveRide&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.destinationLat, destinationLat) || other.destinationLat == destinationLat)&&(identical(other.destinationLng, destinationLng) || other.destinationLng == destinationLng)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhone, passengerPhone) || other.passengerPhone == passengerPhone)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.estimatedFare, estimatedFare) || other.estimatedFare == estimatedFare)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other._stops, _stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,pickupAddress,destinationAddress,pickupLat,pickupLng,destinationLat,destinationLng,passengerName,passengerPhone,passengerRating,paymentMode,estimatedFare,distance,startedAt,const DeepCollectionEquality().hash(_stops));

@override
String toString() {
  return 'ActiveRide(id: $id, status: $status, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, pickupLat: $pickupLat, pickupLng: $pickupLng, destinationLat: $destinationLat, destinationLng: $destinationLng, passengerName: $passengerName, passengerPhone: $passengerPhone, passengerRating: $passengerRating, paymentMode: $paymentMode, estimatedFare: $estimatedFare, distance: $distance, startedAt: $startedAt, stops: $stops)';
}


}

/// @nodoc
abstract mixin class _$ActiveRideCopyWith<$Res> implements $ActiveRideCopyWith<$Res> {
  factory _$ActiveRideCopyWith(_ActiveRide value, $Res Function(_ActiveRide) _then) = __$ActiveRideCopyWithImpl;
@override @useResult
$Res call({
 String id, String status,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress,@JsonKey(name: 'pickup_lat') double pickupLat,@JsonKey(name: 'pickup_lng') double pickupLng,@JsonKey(name: 'destination_lat') double destinationLat,@JsonKey(name: 'destination_lng') double destinationLng,@JsonKey(name: 'passenger_name') String passengerName,@JsonKey(name: 'passenger_phone') String? passengerPhone,@JsonKey(name: 'passenger_rating') double passengerRating,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'estimated_fare') double estimatedFare, double? distance,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class __$ActiveRideCopyWithImpl<$Res>
    implements _$ActiveRideCopyWith<$Res> {
  __$ActiveRideCopyWithImpl(this._self, this._then);

  final _ActiveRide _self;
  final $Res Function(_ActiveRide) _then;

/// Create a copy of ActiveRide
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? pickupLat = null,Object? pickupLng = null,Object? destinationLat = null,Object? destinationLng = null,Object? passengerName = null,Object? passengerPhone = freezed,Object? passengerRating = null,Object? paymentMode = null,Object? estimatedFare = null,Object? distance = freezed,Object? startedAt = freezed,Object? stops = null,}) {
  return _then(_ActiveRide(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,pickupLat: null == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double,pickupLng: null == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double,destinationLat: null == destinationLat ? _self.destinationLat : destinationLat // ignore: cast_nullable_to_non_nullable
as double,destinationLng: null == destinationLng ? _self.destinationLng : destinationLng // ignore: cast_nullable_to_non_nullable
as double,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhone: freezed == passengerPhone ? _self.passengerPhone : passengerPhone // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,estimatedFare: null == estimatedFare ? _self.estimatedFare : estimatedFare // ignore: cast_nullable_to_non_nullable
as double,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}


}


/// @nodoc
mixin _$RideSummary {

 String get id;@JsonKey(name: 'pickup_address') String get pickupAddress;@JsonKey(name: 'destination_address') String get destinationAddress; double get distance; int get duration; double get fare; double get commission;@JsonKey(name: 'net_earnings') double get netEarnings;@JsonKey(name: 'passenger_rating') double? get passengerRating;@JsonKey(name: 'driver_rating') double? get driverRating;@JsonKey(name: 'payment_mode') String get paymentMode;@JsonKey(name: 'completed_at') String? get completedAt;@JsonKey(name: 'stops') List<RideStop> get stops;
/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSummaryCopyWith<RideSummary> get copyWith => _$RideSummaryCopyWithImpl<RideSummary>(this as RideSummary, _$identity);

  /// Serializes this RideSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other.stops, stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pickupAddress,destinationAddress,distance,duration,fare,commission,netEarnings,passengerRating,driverRating,paymentMode,completedAt,const DeepCollectionEquality().hash(stops));

@override
String toString() {
  return 'RideSummary(id: $id, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, commission: $commission, netEarnings: $netEarnings, passengerRating: $passengerRating, driverRating: $driverRating, paymentMode: $paymentMode, completedAt: $completedAt, stops: $stops)';
}


}

/// @nodoc
abstract mixin class $RideSummaryCopyWith<$Res>  {
  factory $RideSummaryCopyWith(RideSummary value, $Res Function(RideSummary) _then) = _$RideSummaryCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare, double commission,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'passenger_rating') double? passengerRating,@JsonKey(name: 'driver_rating') double? driverRating,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'completed_at') String? completedAt,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class _$RideSummaryCopyWithImpl<$Res>
    implements $RideSummaryCopyWith<$Res> {
  _$RideSummaryCopyWithImpl(this._self, this._then);

  final RideSummary _self;
  final $Res Function(RideSummary) _then;

/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? commission = null,Object? netEarnings = null,Object? passengerRating = freezed,Object? driverRating = freezed,Object? paymentMode = null,Object? completedAt = freezed,Object? stops = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,passengerRating: freezed == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self.stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}

}


/// Adds pattern-matching-related methods to [RideSummary].
extension RideSummaryPatterns on RideSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSummary value)  $default,){
final _that = this;
switch (_that) {
case _RideSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.passengerRating,_that.driverRating,_that.paymentMode,_that.completedAt,_that.stops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'stops')  List<RideStop> stops)  $default,) {final _that = this;
switch (_that) {
case _RideSummary():
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.passengerRating,_that.driverRating,_that.paymentMode,_that.completedAt,_that.stops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'pickup_address')  String pickupAddress, @JsonKey(name: 'destination_address')  String destinationAddress,  double distance,  int duration,  double fare,  double commission, @JsonKey(name: 'net_earnings')  double netEarnings, @JsonKey(name: 'passenger_rating')  double? passengerRating, @JsonKey(name: 'driver_rating')  double? driverRating, @JsonKey(name: 'payment_mode')  String paymentMode, @JsonKey(name: 'completed_at')  String? completedAt, @JsonKey(name: 'stops')  List<RideStop> stops)?  $default,) {final _that = this;
switch (_that) {
case _RideSummary() when $default != null:
return $default(_that.id,_that.pickupAddress,_that.destinationAddress,_that.distance,_that.duration,_that.fare,_that.commission,_that.netEarnings,_that.passengerRating,_that.driverRating,_that.paymentMode,_that.completedAt,_that.stops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideSummary implements RideSummary {
  const _RideSummary({required this.id, @JsonKey(name: 'pickup_address') required this.pickupAddress, @JsonKey(name: 'destination_address') required this.destinationAddress, required this.distance, required this.duration, required this.fare, required this.commission, @JsonKey(name: 'net_earnings') required this.netEarnings, @JsonKey(name: 'passenger_rating') this.passengerRating, @JsonKey(name: 'driver_rating') this.driverRating, @JsonKey(name: 'payment_mode') required this.paymentMode, @JsonKey(name: 'completed_at') this.completedAt, @JsonKey(name: 'stops') final  List<RideStop> stops = const <RideStop>[]}): _stops = stops;
  factory _RideSummary.fromJson(Map<String, dynamic> json) => _$RideSummaryFromJson(json);

@override final  String id;
@override@JsonKey(name: 'pickup_address') final  String pickupAddress;
@override@JsonKey(name: 'destination_address') final  String destinationAddress;
@override final  double distance;
@override final  int duration;
@override final  double fare;
@override final  double commission;
@override@JsonKey(name: 'net_earnings') final  double netEarnings;
@override@JsonKey(name: 'passenger_rating') final  double? passengerRating;
@override@JsonKey(name: 'driver_rating') final  double? driverRating;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;
@override@JsonKey(name: 'completed_at') final  String? completedAt;
 final  List<RideStop> _stops;
@override@JsonKey(name: 'stops') List<RideStop> get stops {
  if (_stops is EqualUnmodifiableListView) return _stops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stops);
}


/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSummaryCopyWith<_RideSummary> get copyWith => __$RideSummaryCopyWithImpl<_RideSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.pickupAddress, pickupAddress) || other.pickupAddress == pickupAddress)&&(identical(other.destinationAddress, destinationAddress) || other.destinationAddress == destinationAddress)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.netEarnings, netEarnings) || other.netEarnings == netEarnings)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&const DeepCollectionEquality().equals(other._stops, _stops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pickupAddress,destinationAddress,distance,duration,fare,commission,netEarnings,passengerRating,driverRating,paymentMode,completedAt,const DeepCollectionEquality().hash(_stops));

@override
String toString() {
  return 'RideSummary(id: $id, pickupAddress: $pickupAddress, destinationAddress: $destinationAddress, distance: $distance, duration: $duration, fare: $fare, commission: $commission, netEarnings: $netEarnings, passengerRating: $passengerRating, driverRating: $driverRating, paymentMode: $paymentMode, completedAt: $completedAt, stops: $stops)';
}


}

/// @nodoc
abstract mixin class _$RideSummaryCopyWith<$Res> implements $RideSummaryCopyWith<$Res> {
  factory _$RideSummaryCopyWith(_RideSummary value, $Res Function(_RideSummary) _then) = __$RideSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'pickup_address') String pickupAddress,@JsonKey(name: 'destination_address') String destinationAddress, double distance, int duration, double fare, double commission,@JsonKey(name: 'net_earnings') double netEarnings,@JsonKey(name: 'passenger_rating') double? passengerRating,@JsonKey(name: 'driver_rating') double? driverRating,@JsonKey(name: 'payment_mode') String paymentMode,@JsonKey(name: 'completed_at') String? completedAt,@JsonKey(name: 'stops') List<RideStop> stops
});




}
/// @nodoc
class __$RideSummaryCopyWithImpl<$Res>
    implements _$RideSummaryCopyWith<$Res> {
  __$RideSummaryCopyWithImpl(this._self, this._then);

  final _RideSummary _self;
  final $Res Function(_RideSummary) _then;

/// Create a copy of RideSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pickupAddress = null,Object? destinationAddress = null,Object? distance = null,Object? duration = null,Object? fare = null,Object? commission = null,Object? netEarnings = null,Object? passengerRating = freezed,Object? driverRating = freezed,Object? paymentMode = null,Object? completedAt = freezed,Object? stops = null,}) {
  return _then(_RideSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pickupAddress: null == pickupAddress ? _self.pickupAddress : pickupAddress // ignore: cast_nullable_to_non_nullable
as String,destinationAddress: null == destinationAddress ? _self.destinationAddress : destinationAddress // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,fare: null == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,netEarnings: null == netEarnings ? _self.netEarnings : netEarnings // ignore: cast_nullable_to_non_nullable
as double,passengerRating: freezed == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,stops: null == stops ? _self._stops : stops // ignore: cast_nullable_to_non_nullable
as List<RideStop>,
  ));
}


}


/// @nodoc
mixin _$PaymentBreakdown {

@JsonKey(name: 'trip_fare') double get tripFare; double get commission; double get bonus;@JsonKey(name: 'total_earnings') double get totalEarnings;@JsonKey(name: 'payment_mode') String get paymentMode;
/// Create a copy of PaymentBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentBreakdownCopyWith<PaymentBreakdown> get copyWith => _$PaymentBreakdownCopyWithImpl<PaymentBreakdown>(this as PaymentBreakdown, _$identity);

  /// Serializes this PaymentBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentBreakdown&&(identical(other.tripFare, tripFare) || other.tripFare == tripFare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tripFare,commission,bonus,totalEarnings,paymentMode);

@override
String toString() {
  return 'PaymentBreakdown(tripFare: $tripFare, commission: $commission, bonus: $bonus, totalEarnings: $totalEarnings, paymentMode: $paymentMode)';
}


}

/// @nodoc
abstract mixin class $PaymentBreakdownCopyWith<$Res>  {
  factory $PaymentBreakdownCopyWith(PaymentBreakdown value, $Res Function(PaymentBreakdown) _then) = _$PaymentBreakdownCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trip_fare') double tripFare, double commission, double bonus,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'payment_mode') String paymentMode
});




}
/// @nodoc
class _$PaymentBreakdownCopyWithImpl<$Res>
    implements $PaymentBreakdownCopyWith<$Res> {
  _$PaymentBreakdownCopyWithImpl(this._self, this._then);

  final PaymentBreakdown _self;
  final $Res Function(PaymentBreakdown) _then;

/// Create a copy of PaymentBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tripFare = null,Object? commission = null,Object? bonus = null,Object? totalEarnings = null,Object? paymentMode = null,}) {
  return _then(_self.copyWith(
tripFare: null == tripFare ? _self.tripFare : tripFare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentBreakdown].
extension PaymentBreakdownPatterns on PaymentBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _PaymentBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trip_fare')  double tripFare,  double commission,  double bonus, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'payment_mode')  String paymentMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentBreakdown() when $default != null:
return $default(_that.tripFare,_that.commission,_that.bonus,_that.totalEarnings,_that.paymentMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trip_fare')  double tripFare,  double commission,  double bonus, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'payment_mode')  String paymentMode)  $default,) {final _that = this;
switch (_that) {
case _PaymentBreakdown():
return $default(_that.tripFare,_that.commission,_that.bonus,_that.totalEarnings,_that.paymentMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trip_fare')  double tripFare,  double commission,  double bonus, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'payment_mode')  String paymentMode)?  $default,) {final _that = this;
switch (_that) {
case _PaymentBreakdown() when $default != null:
return $default(_that.tripFare,_that.commission,_that.bonus,_that.totalEarnings,_that.paymentMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentBreakdown implements PaymentBreakdown {
  const _PaymentBreakdown({@JsonKey(name: 'trip_fare') required this.tripFare, required this.commission, this.bonus = 0, @JsonKey(name: 'total_earnings') required this.totalEarnings, @JsonKey(name: 'payment_mode') required this.paymentMode});
  factory _PaymentBreakdown.fromJson(Map<String, dynamic> json) => _$PaymentBreakdownFromJson(json);

@override@JsonKey(name: 'trip_fare') final  double tripFare;
@override final  double commission;
@override@JsonKey() final  double bonus;
@override@JsonKey(name: 'total_earnings') final  double totalEarnings;
@override@JsonKey(name: 'payment_mode') final  String paymentMode;

/// Create a copy of PaymentBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentBreakdownCopyWith<_PaymentBreakdown> get copyWith => __$PaymentBreakdownCopyWithImpl<_PaymentBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentBreakdown&&(identical(other.tripFare, tripFare) || other.tripFare == tripFare)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.bonus, bonus) || other.bonus == bonus)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tripFare,commission,bonus,totalEarnings,paymentMode);

@override
String toString() {
  return 'PaymentBreakdown(tripFare: $tripFare, commission: $commission, bonus: $bonus, totalEarnings: $totalEarnings, paymentMode: $paymentMode)';
}


}

/// @nodoc
abstract mixin class _$PaymentBreakdownCopyWith<$Res> implements $PaymentBreakdownCopyWith<$Res> {
  factory _$PaymentBreakdownCopyWith(_PaymentBreakdown value, $Res Function(_PaymentBreakdown) _then) = __$PaymentBreakdownCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trip_fare') double tripFare, double commission, double bonus,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'payment_mode') String paymentMode
});




}
/// @nodoc
class __$PaymentBreakdownCopyWithImpl<$Res>
    implements _$PaymentBreakdownCopyWith<$Res> {
  __$PaymentBreakdownCopyWithImpl(this._self, this._then);

  final _PaymentBreakdown _self;
  final $Res Function(_PaymentBreakdown) _then;

/// Create a copy of PaymentBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tripFare = null,Object? commission = null,Object? bonus = null,Object? totalEarnings = null,Object? paymentMode = null,}) {
  return _then(_PaymentBreakdown(
tripFare: null == tripFare ? _self.tripFare : tripFare // ignore: cast_nullable_to_non_nullable
as double,commission: null == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double,bonus: null == bonus ? _self.bonus : bonus // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
