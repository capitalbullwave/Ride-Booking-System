// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WalletInfo {

@JsonKey(name: 'current_balance') double get currentBalance;@JsonKey(name: 'pending_balance') double get pendingBalance;@JsonKey(name: 'total_earnings') double get totalEarnings;@JsonKey(name: 'total_withdrawn') double get totalWithdrawn; BankInfo? get bank;
/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletInfoCopyWith<WalletInfo> get copyWith => _$WalletInfoCopyWithImpl<WalletInfo>(this as WalletInfo, _$identity);

  /// Serializes this WalletInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletInfo&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalWithdrawn, totalWithdrawn) || other.totalWithdrawn == totalWithdrawn)&&(identical(other.bank, bank) || other.bank == bank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentBalance,pendingBalance,totalEarnings,totalWithdrawn,bank);

@override
String toString() {
  return 'WalletInfo(currentBalance: $currentBalance, pendingBalance: $pendingBalance, totalEarnings: $totalEarnings, totalWithdrawn: $totalWithdrawn, bank: $bank)';
}


}

/// @nodoc
abstract mixin class $WalletInfoCopyWith<$Res>  {
  factory $WalletInfoCopyWith(WalletInfo value, $Res Function(WalletInfo) _then) = _$WalletInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'current_balance') double currentBalance,@JsonKey(name: 'pending_balance') double pendingBalance,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'total_withdrawn') double totalWithdrawn, BankInfo? bank
});


$BankInfoCopyWith<$Res>? get bank;

}
/// @nodoc
class _$WalletInfoCopyWithImpl<$Res>
    implements $WalletInfoCopyWith<$Res> {
  _$WalletInfoCopyWithImpl(this._self, this._then);

  final WalletInfo _self;
  final $Res Function(WalletInfo) _then;

/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentBalance = null,Object? pendingBalance = null,Object? totalEarnings = null,Object? totalWithdrawn = null,Object? bank = freezed,}) {
  return _then(_self.copyWith(
currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawn: null == totalWithdrawn ? _self.totalWithdrawn : totalWithdrawn // ignore: cast_nullable_to_non_nullable
as double,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as BankInfo?,
  ));
}
/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankInfoCopyWith<$Res>? get bank {
    if (_self.bank == null) {
    return null;
  }

  return $BankInfoCopyWith<$Res>(_self.bank!, (value) {
    return _then(_self.copyWith(bank: value));
  });
}
}


/// Adds pattern-matching-related methods to [WalletInfo].
extension WalletInfoPatterns on WalletInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletInfo value)  $default,){
final _that = this;
switch (_that) {
case _WalletInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletInfo value)?  $default,){
final _that = this;
switch (_that) {
case _WalletInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_balance')  double currentBalance, @JsonKey(name: 'pending_balance')  double pendingBalance, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_withdrawn')  double totalWithdrawn,  BankInfo? bank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletInfo() when $default != null:
return $default(_that.currentBalance,_that.pendingBalance,_that.totalEarnings,_that.totalWithdrawn,_that.bank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'current_balance')  double currentBalance, @JsonKey(name: 'pending_balance')  double pendingBalance, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_withdrawn')  double totalWithdrawn,  BankInfo? bank)  $default,) {final _that = this;
switch (_that) {
case _WalletInfo():
return $default(_that.currentBalance,_that.pendingBalance,_that.totalEarnings,_that.totalWithdrawn,_that.bank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'current_balance')  double currentBalance, @JsonKey(name: 'pending_balance')  double pendingBalance, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_withdrawn')  double totalWithdrawn,  BankInfo? bank)?  $default,) {final _that = this;
switch (_that) {
case _WalletInfo() when $default != null:
return $default(_that.currentBalance,_that.pendingBalance,_that.totalEarnings,_that.totalWithdrawn,_that.bank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletInfo implements WalletInfo {
  const _WalletInfo({@JsonKey(name: 'current_balance') this.currentBalance = 0, @JsonKey(name: 'pending_balance') this.pendingBalance = 0, @JsonKey(name: 'total_earnings') this.totalEarnings = 0, @JsonKey(name: 'total_withdrawn') this.totalWithdrawn = 0, this.bank});
  factory _WalletInfo.fromJson(Map<String, dynamic> json) => _$WalletInfoFromJson(json);

@override@JsonKey(name: 'current_balance') final  double currentBalance;
@override@JsonKey(name: 'pending_balance') final  double pendingBalance;
@override@JsonKey(name: 'total_earnings') final  double totalEarnings;
@override@JsonKey(name: 'total_withdrawn') final  double totalWithdrawn;
@override final  BankInfo? bank;

/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletInfoCopyWith<_WalletInfo> get copyWith => __$WalletInfoCopyWithImpl<_WalletInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletInfo&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalWithdrawn, totalWithdrawn) || other.totalWithdrawn == totalWithdrawn)&&(identical(other.bank, bank) || other.bank == bank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentBalance,pendingBalance,totalEarnings,totalWithdrawn,bank);

@override
String toString() {
  return 'WalletInfo(currentBalance: $currentBalance, pendingBalance: $pendingBalance, totalEarnings: $totalEarnings, totalWithdrawn: $totalWithdrawn, bank: $bank)';
}


}

/// @nodoc
abstract mixin class _$WalletInfoCopyWith<$Res> implements $WalletInfoCopyWith<$Res> {
  factory _$WalletInfoCopyWith(_WalletInfo value, $Res Function(_WalletInfo) _then) = __$WalletInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'current_balance') double currentBalance,@JsonKey(name: 'pending_balance') double pendingBalance,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'total_withdrawn') double totalWithdrawn, BankInfo? bank
});


@override $BankInfoCopyWith<$Res>? get bank;

}
/// @nodoc
class __$WalletInfoCopyWithImpl<$Res>
    implements _$WalletInfoCopyWith<$Res> {
  __$WalletInfoCopyWithImpl(this._self, this._then);

  final _WalletInfo _self;
  final $Res Function(_WalletInfo) _then;

/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentBalance = null,Object? pendingBalance = null,Object? totalEarnings = null,Object? totalWithdrawn = null,Object? bank = freezed,}) {
  return _then(_WalletInfo(
currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalWithdrawn: null == totalWithdrawn ? _self.totalWithdrawn : totalWithdrawn // ignore: cast_nullable_to_non_nullable
as double,bank: freezed == bank ? _self.bank : bank // ignore: cast_nullable_to_non_nullable
as BankInfo?,
  ));
}

/// Create a copy of WalletInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BankInfoCopyWith<$Res>? get bank {
    if (_self.bank == null) {
    return null;
  }

  return $BankInfoCopyWith<$Res>(_self.bank!, (value) {
    return _then(_self.copyWith(bank: value));
  });
}
}


/// @nodoc
mixin _$BankInfo {

@JsonKey(name: 'account_holder') String? get accountHolder;@JsonKey(name: 'account_number') String? get accountNumber; String? get ifsc;@JsonKey(name: 'bank_name') String? get bankName;@JsonKey(name: 'upi_id') String? get upiId;
/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BankInfoCopyWith<BankInfo> get copyWith => _$BankInfoCopyWithImpl<BankInfo>(this as BankInfo, _$identity);

  /// Serializes this BankInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BankInfo&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.upiId, upiId) || other.upiId == upiId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,accountNumber,ifsc,bankName,upiId);

@override
String toString() {
  return 'BankInfo(accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, upiId: $upiId)';
}


}

/// @nodoc
abstract mixin class $BankInfoCopyWith<$Res>  {
  factory $BankInfoCopyWith(BankInfo value, $Res Function(BankInfo) _then) = _$BankInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'upi_id') String? upiId
});




}
/// @nodoc
class _$BankInfoCopyWithImpl<$Res>
    implements $BankInfoCopyWith<$Res> {
  _$BankInfoCopyWithImpl(this._self, this._then);

  final BankInfo _self;
  final $Res Function(BankInfo) _then;

/// Create a copy of BankInfo
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


/// Adds pattern-matching-related methods to [BankInfo].
extension BankInfoPatterns on BankInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BankInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BankInfo value)  $default,){
final _that = this;
switch (_that) {
case _BankInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BankInfo value)?  $default,){
final _that = this;
switch (_that) {
case _BankInfo() when $default != null:
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
case _BankInfo() when $default != null:
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
case _BankInfo():
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
case _BankInfo() when $default != null:
return $default(_that.accountHolder,_that.accountNumber,_that.ifsc,_that.bankName,_that.upiId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BankInfo implements BankInfo {
  const _BankInfo({@JsonKey(name: 'account_holder') this.accountHolder, @JsonKey(name: 'account_number') this.accountNumber, this.ifsc, @JsonKey(name: 'bank_name') this.bankName, @JsonKey(name: 'upi_id') this.upiId});
  factory _BankInfo.fromJson(Map<String, dynamic> json) => _$BankInfoFromJson(json);

@override@JsonKey(name: 'account_holder') final  String? accountHolder;
@override@JsonKey(name: 'account_number') final  String? accountNumber;
@override final  String? ifsc;
@override@JsonKey(name: 'bank_name') final  String? bankName;
@override@JsonKey(name: 'upi_id') final  String? upiId;

/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BankInfoCopyWith<_BankInfo> get copyWith => __$BankInfoCopyWithImpl<_BankInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BankInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BankInfo&&(identical(other.accountHolder, accountHolder) || other.accountHolder == accountHolder)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.ifsc, ifsc) || other.ifsc == ifsc)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.upiId, upiId) || other.upiId == upiId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountHolder,accountNumber,ifsc,bankName,upiId);

@override
String toString() {
  return 'BankInfo(accountHolder: $accountHolder, accountNumber: $accountNumber, ifsc: $ifsc, bankName: $bankName, upiId: $upiId)';
}


}

/// @nodoc
abstract mixin class _$BankInfoCopyWith<$Res> implements $BankInfoCopyWith<$Res> {
  factory _$BankInfoCopyWith(_BankInfo value, $Res Function(_BankInfo) _then) = __$BankInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'account_holder') String? accountHolder,@JsonKey(name: 'account_number') String? accountNumber, String? ifsc,@JsonKey(name: 'bank_name') String? bankName,@JsonKey(name: 'upi_id') String? upiId
});




}
/// @nodoc
class __$BankInfoCopyWithImpl<$Res>
    implements _$BankInfoCopyWith<$Res> {
  __$BankInfoCopyWithImpl(this._self, this._then);

  final _BankInfo _self;
  final $Res Function(_BankInfo) _then;

/// Create a copy of BankInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountHolder = freezed,Object? accountNumber = freezed,Object? ifsc = freezed,Object? bankName = freezed,Object? upiId = freezed,}) {
  return _then(_BankInfo(
accountHolder: freezed == accountHolder ? _self.accountHolder : accountHolder // ignore: cast_nullable_to_non_nullable
as String?,accountNumber: freezed == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String?,ifsc: freezed == ifsc ? _self.ifsc : ifsc // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$WalletTransaction {

 String get id; String get type; double get amount; String get status; String? get description;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletTransactionCopyWith<WalletTransaction> get copyWith => _$WalletTransactionCopyWithImpl<WalletTransaction>(this as WalletTransaction, _$identity);

  /// Serializes this WalletTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,status,description,createdAt);

@override
String toString() {
  return 'WalletTransaction(id: $id, type: $type, amount: $amount, status: $status, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WalletTransactionCopyWith<$Res>  {
  factory $WalletTransactionCopyWith(WalletTransaction value, $Res Function(WalletTransaction) _then) = _$WalletTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String type, double amount, String status, String? description,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$WalletTransactionCopyWithImpl<$Res>
    implements $WalletTransactionCopyWith<$Res> {
  _$WalletTransactionCopyWithImpl(this._self, this._then);

  final WalletTransaction _self;
  final $Res Function(WalletTransaction) _then;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? status = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletTransaction].
extension WalletTransactionPatterns on WalletTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletTransaction value)  $default,){
final _that = this;
switch (_that) {
case _WalletTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String status,  String? description, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.status,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String status,  String? description, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _WalletTransaction():
return $default(_that.id,_that.type,_that.amount,_that.status,_that.description,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  double amount,  String status,  String? description, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WalletTransaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.status,_that.description,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletTransaction implements WalletTransaction {
  const _WalletTransaction({required this.id, required this.type, required this.amount, required this.status, this.description, @JsonKey(name: 'created_at') required this.createdAt});
  factory _WalletTransaction.fromJson(Map<String, dynamic> json) => _$WalletTransactionFromJson(json);

@override final  String id;
@override final  String type;
@override final  double amount;
@override final  String status;
@override final  String? description;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletTransactionCopyWith<_WalletTransaction> get copyWith => __$WalletTransactionCopyWithImpl<_WalletTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,status,description,createdAt);

@override
String toString() {
  return 'WalletTransaction(id: $id, type: $type, amount: $amount, status: $status, description: $description, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WalletTransactionCopyWith<$Res> implements $WalletTransactionCopyWith<$Res> {
  factory _$WalletTransactionCopyWith(_WalletTransaction value, $Res Function(_WalletTransaction) _then) = __$WalletTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, double amount, String status, String? description,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$WalletTransactionCopyWithImpl<$Res>
    implements _$WalletTransactionCopyWith<$Res> {
  __$WalletTransactionCopyWithImpl(this._self, this._then);

  final _WalletTransaction _self;
  final $Res Function(_WalletTransaction) _then;

/// Create a copy of WalletTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? status = null,Object? description = freezed,Object? createdAt = null,}) {
  return _then(_WalletTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WithdrawRequest {

 double get amount;@JsonKey(name: 'payment_method') String get paymentMethod;
/// Create a copy of WithdrawRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WithdrawRequestCopyWith<WithdrawRequest> get copyWith => _$WithdrawRequestCopyWithImpl<WithdrawRequest>(this as WithdrawRequest, _$identity);

  /// Serializes this WithdrawRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WithdrawRequest&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,paymentMethod);

@override
String toString() {
  return 'WithdrawRequest(amount: $amount, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class $WithdrawRequestCopyWith<$Res>  {
  factory $WithdrawRequestCopyWith(WithdrawRequest value, $Res Function(WithdrawRequest) _then) = _$WithdrawRequestCopyWithImpl;
@useResult
$Res call({
 double amount,@JsonKey(name: 'payment_method') String paymentMethod
});




}
/// @nodoc
class _$WithdrawRequestCopyWithImpl<$Res>
    implements $WithdrawRequestCopyWith<$Res> {
  _$WithdrawRequestCopyWithImpl(this._self, this._then);

  final WithdrawRequest _self;
  final $Res Function(WithdrawRequest) _then;

/// Create a copy of WithdrawRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? paymentMethod = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WithdrawRequest].
extension WithdrawRequestPatterns on WithdrawRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WithdrawRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WithdrawRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WithdrawRequest value)  $default,){
final _that = this;
switch (_that) {
case _WithdrawRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WithdrawRequest value)?  $default,){
final _that = this;
switch (_that) {
case _WithdrawRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double amount, @JsonKey(name: 'payment_method')  String paymentMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WithdrawRequest() when $default != null:
return $default(_that.amount,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double amount, @JsonKey(name: 'payment_method')  String paymentMethod)  $default,) {final _that = this;
switch (_that) {
case _WithdrawRequest():
return $default(_that.amount,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double amount, @JsonKey(name: 'payment_method')  String paymentMethod)?  $default,) {final _that = this;
switch (_that) {
case _WithdrawRequest() when $default != null:
return $default(_that.amount,_that.paymentMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WithdrawRequest implements WithdrawRequest {
  const _WithdrawRequest({required this.amount, @JsonKey(name: 'payment_method') required this.paymentMethod});
  factory _WithdrawRequest.fromJson(Map<String, dynamic> json) => _$WithdrawRequestFromJson(json);

@override final  double amount;
@override@JsonKey(name: 'payment_method') final  String paymentMethod;

/// Create a copy of WithdrawRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WithdrawRequestCopyWith<_WithdrawRequest> get copyWith => __$WithdrawRequestCopyWithImpl<_WithdrawRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WithdrawRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WithdrawRequest&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,paymentMethod);

@override
String toString() {
  return 'WithdrawRequest(amount: $amount, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class _$WithdrawRequestCopyWith<$Res> implements $WithdrawRequestCopyWith<$Res> {
  factory _$WithdrawRequestCopyWith(_WithdrawRequest value, $Res Function(_WithdrawRequest) _then) = __$WithdrawRequestCopyWithImpl;
@override @useResult
$Res call({
 double amount,@JsonKey(name: 'payment_method') String paymentMethod
});




}
/// @nodoc
class __$WithdrawRequestCopyWithImpl<$Res>
    implements _$WithdrawRequestCopyWith<$Res> {
  __$WithdrawRequestCopyWithImpl(this._self, this._then);

  final _WithdrawRequest _self;
  final $Res Function(_WithdrawRequest) _then;

/// Create a copy of WithdrawRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? paymentMethod = null,}) {
  return _then(_WithdrawRequest(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
