// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiResponse<T> {

 bool get success; String? get message; T? get data;@JsonKey(name: 'meta') Map<String, dynamic>? get meta;
/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResponseCopyWith<T, ApiResponse<T>> get copyWith => _$ApiResponseCopyWithImpl<T, ApiResponse<T>>(this as ApiResponse<T>, _$identity);

  /// Serializes this ApiResponse to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResponse<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other.meta, meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(meta));

@override
String toString() {
  return 'ApiResponse<$T>(success: $success, message: $message, data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $ApiResponseCopyWith<T,$Res>  {
  factory $ApiResponseCopyWith(ApiResponse<T> value, $Res Function(ApiResponse<T>) _then) = _$ApiResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String? message, T? data,@JsonKey(name: 'meta') Map<String, dynamic>? meta
});




}
/// @nodoc
class _$ApiResponseCopyWithImpl<T,$Res>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._self, this._then);

  final ApiResponse<T> _self;
  final $Res Function(ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = freezed,Object? data = freezed,Object? meta = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiResponse].
extension ApiResponsePatterns<T> on ApiResponse<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiResponse<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiResponse<T> value)  $default,){
final _that = this;
switch (_that) {
case _ApiResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiResponse<T> value)?  $default,){
final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? message,  T? data, @JsonKey(name: 'meta')  Map<String, dynamic>? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.message,_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? message,  T? data, @JsonKey(name: 'meta')  Map<String, dynamic>? meta)  $default,) {final _that = this;
switch (_that) {
case _ApiResponse():
return $default(_that.success,_that.message,_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? message,  T? data, @JsonKey(name: 'meta')  Map<String, dynamic>? meta)?  $default,) {final _that = this;
switch (_that) {
case _ApiResponse() when $default != null:
return $default(_that.success,_that.message,_that.data,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)

class _ApiResponse<T> implements ApiResponse<T> {
  const _ApiResponse({required this.success, this.message, this.data, @JsonKey(name: 'meta') final  Map<String, dynamic>? meta}): _meta = meta;
  factory _ApiResponse.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$ApiResponseFromJson(json,fromJsonT);

@override final  bool success;
@override final  String? message;
@override final  T? data;
 final  Map<String, dynamic>? _meta;
@override@JsonKey(name: 'meta') Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiResponseCopyWith<T, _ApiResponse<T>> get copyWith => __$ApiResponseCopyWithImpl<T, _ApiResponse<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$ApiResponseToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiResponse<T>&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data)&&const DeepCollectionEquality().equals(other._meta, _meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,const DeepCollectionEquality().hash(data),const DeepCollectionEquality().hash(_meta));

@override
String toString() {
  return 'ApiResponse<$T>(success: $success, message: $message, data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$ApiResponseCopyWith<T,$Res> implements $ApiResponseCopyWith<T, $Res> {
  factory _$ApiResponseCopyWith(_ApiResponse<T> value, $Res Function(_ApiResponse<T>) _then) = __$ApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? message, T? data,@JsonKey(name: 'meta') Map<String, dynamic>? meta
});




}
/// @nodoc
class __$ApiResponseCopyWithImpl<T,$Res>
    implements _$ApiResponseCopyWith<T, $Res> {
  __$ApiResponseCopyWithImpl(this._self, this._then);

  final _ApiResponse<T> _self;
  final $Res Function(_ApiResponse<T>) _then;

/// Create a copy of ApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = freezed,Object? data = freezed,Object? meta = freezed,}) {
  return _then(_ApiResponse<T>(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$AuthTokens {

@JsonKey(name: 'access_token') String get accessToken;@JsonKey(name: 'refresh_token') String get refreshToken;@JsonKey(name: 'expires_in') int? get expiresIn;
/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<AuthTokens> get copyWith => _$AuthTokensCopyWithImpl<AuthTokens>(this as AuthTokens, _$identity);

  /// Serializes this AuthTokens to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class $AuthTokensCopyWith<$Res>  {
  factory $AuthTokensCopyWith(AuthTokens value, $Res Function(AuthTokens) _then) = _$AuthTokensCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'expires_in') int? expiresIn
});




}
/// @nodoc
class _$AuthTokensCopyWithImpl<$Res>
    implements $AuthTokensCopyWith<$Res> {
  _$AuthTokensCopyWithImpl(this._self, this._then);

  final AuthTokens _self;
  final $Res Function(AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = freezed,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthTokens].
extension AuthTokensPatterns on AuthTokens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthTokens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthTokens value)  $default,){
final _that = this;
switch (_that) {
case _AuthTokens():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthTokens value)?  $default,){
final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'expires_in')  int? expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'expires_in')  int? expiresIn)  $default,) {final _that = this;
switch (_that) {
case _AuthTokens():
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'expires_in')  int? expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _AuthTokens() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthTokens implements AuthTokens {
  const _AuthTokens({@JsonKey(name: 'access_token') required this.accessToken, @JsonKey(name: 'refresh_token') required this.refreshToken, @JsonKey(name: 'expires_in') this.expiresIn});
  factory _AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);

@override@JsonKey(name: 'access_token') final  String accessToken;
@override@JsonKey(name: 'refresh_token') final  String refreshToken;
@override@JsonKey(name: 'expires_in') final  int? expiresIn;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthTokensCopyWith<_AuthTokens> get copyWith => __$AuthTokensCopyWithImpl<_AuthTokens>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthTokensToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthTokens&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,expiresIn);

@override
String toString() {
  return 'AuthTokens(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
}


}

/// @nodoc
abstract mixin class _$AuthTokensCopyWith<$Res> implements $AuthTokensCopyWith<$Res> {
  factory _$AuthTokensCopyWith(_AuthTokens value, $Res Function(_AuthTokens) _then) = __$AuthTokensCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'expires_in') int? expiresIn
});




}
/// @nodoc
class __$AuthTokensCopyWithImpl<$Res>
    implements _$AuthTokensCopyWith<$Res> {
  __$AuthTokensCopyWithImpl(this._self, this._then);

  final _AuthTokens _self;
  final $Res Function(_AuthTokens) _then;

/// Create a copy of AuthTokens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? expiresIn = freezed,}) {
  return _then(_AuthTokens(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$OtpResponse {

 bool get success; String? get message;@JsonKey(name: 'session_id') String? get sessionId;
/// Create a copy of OtpResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpResponseCopyWith<OtpResponse> get copyWith => _$OtpResponseCopyWithImpl<OtpResponse>(this as OtpResponse, _$identity);

  /// Serializes this OtpResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,sessionId);

@override
String toString() {
  return 'OtpResponse(success: $success, message: $message, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $OtpResponseCopyWith<$Res>  {
  factory $OtpResponseCopyWith(OtpResponse value, $Res Function(OtpResponse) _then) = _$OtpResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String? message,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class _$OtpResponseCopyWithImpl<$Res>
    implements $OtpResponseCopyWith<$Res> {
  _$OtpResponseCopyWithImpl(this._self, this._then);

  final OtpResponse _self;
  final $Res Function(OtpResponse) _then;

/// Create a copy of OtpResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpResponse].
extension OtpResponsePatterns on OtpResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpResponse value)  $default,){
final _that = this;
switch (_that) {
case _OtpResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OtpResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String? message, @JsonKey(name: 'session_id')  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpResponse() when $default != null:
return $default(_that.success,_that.message,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String? message, @JsonKey(name: 'session_id')  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _OtpResponse():
return $default(_that.success,_that.message,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String? message, @JsonKey(name: 'session_id')  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _OtpResponse() when $default != null:
return $default(_that.success,_that.message,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpResponse implements OtpResponse {
  const _OtpResponse({required this.success, this.message, @JsonKey(name: 'session_id') this.sessionId});
  factory _OtpResponse.fromJson(Map<String, dynamic> json) => _$OtpResponseFromJson(json);

@override final  bool success;
@override final  String? message;
@override@JsonKey(name: 'session_id') final  String? sessionId;

/// Create a copy of OtpResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpResponseCopyWith<_OtpResponse> get copyWith => __$OtpResponseCopyWithImpl<_OtpResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,sessionId);

@override
String toString() {
  return 'OtpResponse(success: $success, message: $message, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$OtpResponseCopyWith<$Res> implements $OtpResponseCopyWith<$Res> {
  factory _$OtpResponseCopyWith(_OtpResponse value, $Res Function(_OtpResponse) _then) = __$OtpResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String? message,@JsonKey(name: 'session_id') String? sessionId
});




}
/// @nodoc
class __$OtpResponseCopyWithImpl<$Res>
    implements _$OtpResponseCopyWith<$Res> {
  __$OtpResponseCopyWithImpl(this._self, this._then);

  final _OtpResponse _self;
  final $Res Function(_OtpResponse) _then;

/// Create a copy of OtpResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = freezed,Object? sessionId = freezed,}) {
  return _then(_OtpResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LoginResponse {

 AuthTokens get tokens; DriverProfile? get driver;@JsonKey(name: 'is_registered') bool get isRegistered;@JsonKey(name: 'is_verified') bool get isVerified;
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<LoginResponse> get copyWith => _$LoginResponseCopyWithImpl<LoginResponse>(this as LoginResponse, _$identity);

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokens,driver,isRegistered,isVerified);

@override
String toString() {
  return 'LoginResponse(tokens: $tokens, driver: $driver, isRegistered: $isRegistered, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $LoginResponseCopyWith<$Res>  {
  factory $LoginResponseCopyWith(LoginResponse value, $Res Function(LoginResponse) _then) = _$LoginResponseCopyWithImpl;
@useResult
$Res call({
 AuthTokens tokens, DriverProfile? driver,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'is_verified') bool isVerified
});


$AuthTokensCopyWith<$Res> get tokens;$DriverProfileCopyWith<$Res>? get driver;

}
/// @nodoc
class _$LoginResponseCopyWithImpl<$Res>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._self, this._then);

  final LoginResponse _self;
  final $Res Function(LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokens = null,Object? driver = freezed,Object? isRegistered = null,Object? isVerified = null,}) {
  return _then(_self.copyWith(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AuthTokens,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverProfile?,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<$Res> get tokens {
  
  return $AuthTokensCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverProfileCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthTokens tokens,  DriverProfile? driver, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.tokens,_that.driver,_that.isRegistered,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthTokens tokens,  DriverProfile? driver, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'is_verified')  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that.tokens,_that.driver,_that.isRegistered,_that.isVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthTokens tokens,  DriverProfile? driver, @JsonKey(name: 'is_registered')  bool isRegistered, @JsonKey(name: 'is_verified')  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.tokens,_that.driver,_that.isRegistered,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponse implements LoginResponse {
  const _LoginResponse({required this.tokens, this.driver, @JsonKey(name: 'is_registered') this.isRegistered = false, @JsonKey(name: 'is_verified') this.isVerified = false});
  factory _LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

@override final  AuthTokens tokens;
@override final  DriverProfile? driver;
@override@JsonKey(name: 'is_registered') final  bool isRegistered;
@override@JsonKey(name: 'is_verified') final  bool isVerified;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseCopyWith<_LoginResponse> get copyWith => __$LoginResponseCopyWithImpl<_LoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponse&&(identical(other.tokens, tokens) || other.tokens == tokens)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokens,driver,isRegistered,isVerified);

@override
String toString() {
  return 'LoginResponse(tokens: $tokens, driver: $driver, isRegistered: $isRegistered, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory _$LoginResponseCopyWith(_LoginResponse value, $Res Function(_LoginResponse) _then) = __$LoginResponseCopyWithImpl;
@override @useResult
$Res call({
 AuthTokens tokens, DriverProfile? driver,@JsonKey(name: 'is_registered') bool isRegistered,@JsonKey(name: 'is_verified') bool isVerified
});


@override $AuthTokensCopyWith<$Res> get tokens;@override $DriverProfileCopyWith<$Res>? get driver;

}
/// @nodoc
class __$LoginResponseCopyWithImpl<$Res>
    implements _$LoginResponseCopyWith<$Res> {
  __$LoginResponseCopyWithImpl(this._self, this._then);

  final _LoginResponse _self;
  final $Res Function(_LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokens = null,Object? driver = freezed,Object? isRegistered = null,Object? isVerified = null,}) {
  return _then(_LoginResponse(
tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as AuthTokens,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverProfile?,isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthTokensCopyWith<$Res> get tokens {
  
  return $AuthTokensCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverProfileCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}
}


/// @nodoc
mixin _$DriverProfile {

 String get id; String get name; String get phone; String? get email; String? get avatar;@JsonKey(name: 'date_of_birth') String? get dateOfBirth; String? get gender; double? get rating;@JsonKey(name: 'total_trips') int get totalTrips;@JsonKey(name: 'is_online') bool get isOnline;@JsonKey(name: 'verification_status') String get verificationStatus; VehicleInfo? get vehicle; BankDetails? get bankDetails;
/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<DriverProfile> get copyWith => _$DriverProfileCopyWithImpl<DriverProfile>(this as DriverProfile, _$identity);

  /// Serializes this DriverProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.bankDetails, bankDetails) || other.bankDetails == bankDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,email,avatar,dateOfBirth,gender,rating,totalTrips,isOnline,verificationStatus,vehicle,bankDetails);

@override
String toString() {
  return 'DriverProfile(id: $id, name: $name, phone: $phone, email: $email, avatar: $avatar, dateOfBirth: $dateOfBirth, gender: $gender, rating: $rating, totalTrips: $totalTrips, isOnline: $isOnline, verificationStatus: $verificationStatus, vehicle: $vehicle, bankDetails: $bankDetails)';
}


}

/// @nodoc
abstract mixin class $DriverProfileCopyWith<$Res>  {
  factory $DriverProfileCopyWith(DriverProfile value, $Res Function(DriverProfile) _then) = _$DriverProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone, String? email, String? avatar,@JsonKey(name: 'date_of_birth') String? dateOfBirth, String? gender, double? rating,@JsonKey(name: 'total_trips') int totalTrips,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'verification_status') String verificationStatus, VehicleInfo? vehicle, BankDetails? bankDetails
});


$VehicleInfoCopyWith<$Res>? get vehicle;$BankDetailsCopyWith<$Res>? get bankDetails;

}
/// @nodoc
class _$DriverProfileCopyWithImpl<$Res>
    implements $DriverProfileCopyWith<$Res> {
  _$DriverProfileCopyWithImpl(this._self, this._then);

  final DriverProfile _self;
  final $Res Function(DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? email = freezed,Object? avatar = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? rating = freezed,Object? totalTrips = null,Object? isOnline = null,Object? verificationStatus = null,Object? vehicle = freezed,Object? bankDetails = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleInfo?,bankDetails: freezed == bankDetails ? _self.bankDetails : bankDetails // ignore: cast_nullable_to_non_nullable
as BankDetails?,
  ));
}
/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleInfoCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankDetailsCopyWith<$Res>? get bankDetails {
    if (_self.bankDetails == null) {
    return null;
  }

  return $BankDetailsCopyWith<$Res>(_self.bankDetails!, (value) {
    return _then(_self.copyWith(bankDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriverProfile].
extension DriverProfilePatterns on DriverProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverProfile value)  $default,){
final _that = this;
switch (_that) {
case _DriverProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverProfile value)?  $default,){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? email,  String? avatar, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender,  double? rating, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'verification_status')  String verificationStatus,  VehicleInfo? vehicle,  BankDetails? bankDetails)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.email,_that.avatar,_that.dateOfBirth,_that.gender,_that.rating,_that.totalTrips,_that.isOnline,_that.verificationStatus,_that.vehicle,_that.bankDetails);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String? email,  String? avatar, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender,  double? rating, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'verification_status')  String verificationStatus,  VehicleInfo? vehicle,  BankDetails? bankDetails)  $default,) {final _that = this;
switch (_that) {
case _DriverProfile():
return $default(_that.id,_that.name,_that.phone,_that.email,_that.avatar,_that.dateOfBirth,_that.gender,_that.rating,_that.totalTrips,_that.isOnline,_that.verificationStatus,_that.vehicle,_that.bankDetails);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone,  String? email,  String? avatar, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  String? gender,  double? rating, @JsonKey(name: 'total_trips')  int totalTrips, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'verification_status')  String verificationStatus,  VehicleInfo? vehicle,  BankDetails? bankDetails)?  $default,) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.email,_that.avatar,_that.dateOfBirth,_that.gender,_that.rating,_that.totalTrips,_that.isOnline,_that.verificationStatus,_that.vehicle,_that.bankDetails);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverProfile implements DriverProfile {
  const _DriverProfile({required this.id, required this.name, required this.phone, this.email, this.avatar, @JsonKey(name: 'date_of_birth') this.dateOfBirth, this.gender, this.rating, @JsonKey(name: 'total_trips') this.totalTrips = 0, @JsonKey(name: 'is_online') this.isOnline = false, @JsonKey(name: 'verification_status') this.verificationStatus = 'pending', this.vehicle, this.bankDetails});
  factory _DriverProfile.fromJson(Map<String, dynamic> json) => _$DriverProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String phone;
@override final  String? email;
@override final  String? avatar;
@override@JsonKey(name: 'date_of_birth') final  String? dateOfBirth;
@override final  String? gender;
@override final  double? rating;
@override@JsonKey(name: 'total_trips') final  int totalTrips;
@override@JsonKey(name: 'is_online') final  bool isOnline;
@override@JsonKey(name: 'verification_status') final  String verificationStatus;
@override final  VehicleInfo? vehicle;
@override final  BankDetails? bankDetails;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverProfileCopyWith<_DriverProfile> get copyWith => __$DriverProfileCopyWithImpl<_DriverProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalTrips, totalTrips) || other.totalTrips == totalTrips)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.bankDetails, bankDetails) || other.bankDetails == bankDetails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,email,avatar,dateOfBirth,gender,rating,totalTrips,isOnline,verificationStatus,vehicle,bankDetails);

@override
String toString() {
  return 'DriverProfile(id: $id, name: $name, phone: $phone, email: $email, avatar: $avatar, dateOfBirth: $dateOfBirth, gender: $gender, rating: $rating, totalTrips: $totalTrips, isOnline: $isOnline, verificationStatus: $verificationStatus, vehicle: $vehicle, bankDetails: $bankDetails)';
}


}

/// @nodoc
abstract mixin class _$DriverProfileCopyWith<$Res> implements $DriverProfileCopyWith<$Res> {
  factory _$DriverProfileCopyWith(_DriverProfile value, $Res Function(_DriverProfile) _then) = __$DriverProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone, String? email, String? avatar,@JsonKey(name: 'date_of_birth') String? dateOfBirth, String? gender, double? rating,@JsonKey(name: 'total_trips') int totalTrips,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'verification_status') String verificationStatus, VehicleInfo? vehicle, BankDetails? bankDetails
});


@override $VehicleInfoCopyWith<$Res>? get vehicle;@override $BankDetailsCopyWith<$Res>? get bankDetails;

}
/// @nodoc
class __$DriverProfileCopyWithImpl<$Res>
    implements _$DriverProfileCopyWith<$Res> {
  __$DriverProfileCopyWithImpl(this._self, this._then);

  final _DriverProfile _self;
  final $Res Function(_DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? email = freezed,Object? avatar = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? rating = freezed,Object? totalTrips = null,Object? isOnline = null,Object? verificationStatus = null,Object? vehicle = freezed,Object? bankDetails = freezed,}) {
  return _then(_DriverProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,totalTrips: null == totalTrips ? _self.totalTrips : totalTrips // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleInfo?,bankDetails: freezed == bankDetails ? _self.bankDetails : bankDetails // ignore: cast_nullable_to_non_nullable
as BankDetails?,
  ));
}

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleInfoCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankDetailsCopyWith<$Res>? get bankDetails {
    if (_self.bankDetails == null) {
    return null;
  }

  return $BankDetailsCopyWith<$Res>(_self.bankDetails!, (value) {
    return _then(_self.copyWith(bankDetails: value));
  });
}
}


/// @nodoc
mixin _$VehicleInfo {

 String? get id;@JsonKey(name: 'vehicle_type') String? get vehicleType;@JsonKey(name: 'vehicle_number') String? get vehicleNumber; String? get brand; String? get model; String? get color;@JsonKey(name: 'manufacturing_year') int? get manufacturingYear;
/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<VehicleInfo> get copyWith => _$VehicleInfoCopyWithImpl<VehicleInfo>(this as VehicleInfo, _$identity);

  /// Serializes this VehicleInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vehicleType,vehicleNumber,brand,model,color,manufacturingYear);

@override
String toString() {
  return 'VehicleInfo(id: $id, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, brand: $brand, model: $model, color: $color, manufacturingYear: $manufacturingYear)';
}


}

/// @nodoc
abstract mixin class $VehicleInfoCopyWith<$Res>  {
  factory $VehicleInfoCopyWith(VehicleInfo value, $Res Function(VehicleInfo) _then) = _$VehicleInfoCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber, String? brand, String? model, String? color,@JsonKey(name: 'manufacturing_year') int? manufacturingYear
});




}
/// @nodoc
class _$VehicleInfoCopyWithImpl<$Res>
    implements $VehicleInfoCopyWith<$Res> {
  _$VehicleInfoCopyWithImpl(this._self, this._then);

  final VehicleInfo _self;
  final $Res Function(VehicleInfo) _then;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? brand = freezed,Object? model = freezed,Object? color = freezed,Object? manufacturingYear = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleInfo].
extension VehicleInfoPatterns on VehicleInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleInfo value)  $default,){
final _that = this;
switch (_that) {
case _VehicleInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? brand,  String? model,  String? color, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
return $default(_that.id,_that.vehicleType,_that.vehicleNumber,_that.brand,_that.model,_that.color,_that.manufacturingYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? brand,  String? model,  String? color, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear)  $default,) {final _that = this;
switch (_that) {
case _VehicleInfo():
return $default(_that.id,_that.vehicleType,_that.vehicleNumber,_that.brand,_that.model,_that.color,_that.manufacturingYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'vehicle_type')  String? vehicleType, @JsonKey(name: 'vehicle_number')  String? vehicleNumber,  String? brand,  String? model,  String? color, @JsonKey(name: 'manufacturing_year')  int? manufacturingYear)?  $default,) {final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
return $default(_that.id,_that.vehicleType,_that.vehicleNumber,_that.brand,_that.model,_that.color,_that.manufacturingYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleInfo implements VehicleInfo {
  const _VehicleInfo({this.id, @JsonKey(name: 'vehicle_type') this.vehicleType, @JsonKey(name: 'vehicle_number') this.vehicleNumber, this.brand, this.model, this.color, @JsonKey(name: 'manufacturing_year') this.manufacturingYear});
  factory _VehicleInfo.fromJson(Map<String, dynamic> json) => _$VehicleInfoFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'vehicle_type') final  String? vehicleType;
@override@JsonKey(name: 'vehicle_number') final  String? vehicleNumber;
@override final  String? brand;
@override final  String? model;
@override final  String? color;
@override@JsonKey(name: 'manufacturing_year') final  int? manufacturingYear;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleInfoCopyWith<_VehicleInfo> get copyWith => __$VehicleInfoCopyWithImpl<_VehicleInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.color, color) || other.color == color)&&(identical(other.manufacturingYear, manufacturingYear) || other.manufacturingYear == manufacturingYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,vehicleType,vehicleNumber,brand,model,color,manufacturingYear);

@override
String toString() {
  return 'VehicleInfo(id: $id, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, brand: $brand, model: $model, color: $color, manufacturingYear: $manufacturingYear)';
}


}

/// @nodoc
abstract mixin class _$VehicleInfoCopyWith<$Res> implements $VehicleInfoCopyWith<$Res> {
  factory _$VehicleInfoCopyWith(_VehicleInfo value, $Res Function(_VehicleInfo) _then) = __$VehicleInfoCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'vehicle_type') String? vehicleType,@JsonKey(name: 'vehicle_number') String? vehicleNumber, String? brand, String? model, String? color,@JsonKey(name: 'manufacturing_year') int? manufacturingYear
});




}
/// @nodoc
class __$VehicleInfoCopyWithImpl<$Res>
    implements _$VehicleInfoCopyWith<$Res> {
  __$VehicleInfoCopyWithImpl(this._self, this._then);

  final _VehicleInfo _self;
  final $Res Function(_VehicleInfo) _then;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? brand = freezed,Object? model = freezed,Object? color = freezed,Object? manufacturingYear = freezed,}) {
  return _then(_VehicleInfo(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,manufacturingYear: freezed == manufacturingYear ? _self.manufacturingYear : manufacturingYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BankDetails {

@JsonKey(name: 'account_holder') String? get accountHolder;@JsonKey(name: 'account_number') String? get accountNumber; String? get ifsc;@JsonKey(name: 'bank_name') String? get bankName;@JsonKey(name: 'upi_id') String? get upiId;
/// Create a copy of BankDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankDetailsCopyWith<BankDetails> get copyWith => _$BankDetailsCopyWithImpl<BankDetails>(this as BankDetails, _$identity);

  /// Serializes this BankDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankDetails&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.upiId, upiId) || other.upiId == upiId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,accountNumber,ifsc,bankName,upiId);

@override
String toString() {
  return 'BankDetails(accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, upiId: $upiId)';
}


}

/// @nodoc
abstract mixin class $BankDetailsCopyWith<$Res>  {
  factory $BankDetailsCopyWith(BankDetails value, $Res Function(BankDetails) _then) = _$BankDetailsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'upi_id') String? upiId
});




}
/// @nodoc
class _$BankDetailsCopyWithImpl<$Res>
    implements $BankDetailsCopyWith<$Res> {
  _$BankDetailsCopyWithImpl(this._self, this._then);

  final BankDetails _self;
  final $Res Function(BankDetails) _then;

/// Create a copy of BankDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountHolder = freezed,Object? accountNumber = freezed,Object? ifsc = freezed,Object? bankName = freezed,Object? upiId = freezed,}) {
  return _then(_self.copyWith(
accountHolder: freezed == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,ifsc: freezed == ifsc ? _self.ifsc : ifsc // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BankDetails].
extension BankDetailsPatterns on BankDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankDetails value)  $default,){
final _that = this;
switch (_that) {
case _BankDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankDetails value)?  $default,){
final _that = this;
switch (_that) {
case _BankDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'upi_id')  String? upiId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BankDetails() when $default != null:
return $default(_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.upiId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'upi_id')  String? upiId)  $default,) {final _that = this;
switch (_that) {
case _BankDetails():
return $default(_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.upiId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'account_holder')  String? accountHolder, @JsonKey(name: 'account_number')  String? accountNumber,  String? ifsc, @JsonKey(name: 'bank_name')  String? bankName, @JsonKey(name: 'upi_id')  String? upiId)?  $default,) {final _that = this;
switch (_that) {
case _BankDetails() when $default != null:
return $default(_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.upiId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BankDetails implements BankDetails {
  const _BankDetails({@JsonKey(name: 'account_holder') this.accountHolder, @JsonKey(name: 'account_number') this.accountNumber, this.ifsc, @JsonKey(name: 'bank_name') this.bankName, @JsonKey(name: 'upi_id') this.upiId});
  factory _BankDetails.fromJson(Map<String, dynamic> json) => _$BankDetailsFromJson(json);

@override@JsonKey(name: 'account_holder') final  String? accountHolder;
@override@JsonKey(name: 'account_number') final  String? accountNumber;
@override final  String? ifsc;
@override@JsonKey(name: 'bank_name') final  String? bankName;
@override@JsonKey(name: 'upi_id') final  String? upiId;

/// Create a copy of BankDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankDetailsCopyWith<_BankDetails> get copyWith => __$BankDetailsCopyWithImpl<_BankDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankDetails&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.upiId, upiId) || other.upiId == upiId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,accountNumber,ifsc,bankName,upiId);

@override
String toString() {
  return 'BankDetails(accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, upiId: $upiId)';
}


}

/// @nodoc
abstract mixin class _$BankDetailsCopyWith<$Res> implements $BankDetailsCopyWith<$Res> {
  factory _$BankDetailsCopyWith(_BankDetails value, $Res Function(_BankDetails) _then) = __$BankDetailsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'upi_id') String? upiId
});




}
/// @nodoc
class __$BankDetailsCopyWithImpl<$Res>
    implements _$BankDetailsCopyWith<$Res> {
  __$BankDetailsCopyWithImpl(this._self, this._then);

  final _BankDetails _self;
  final $Res Function(_BankDetails) _then;

/// Create a copy of BankDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountHolder = freezed,Object? accountNumber = freezed,Object? ifsc = freezed,Object? bankName = freezed,Object? upiId = freezed,}) {
  return _then(_BankDetails(
accountHolder: freezed == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,ifsc: freezed == ifsc ? _self.ifsc : ifsc // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
