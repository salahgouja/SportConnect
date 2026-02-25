// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentTransaction {

 String get id; String get rideId; String get riderId; String get riderName; String get driverId; String get driverName;// Payment details
 double get amount;// Total amount in dollars
 String get currency; PaymentStatus get status; PaymentMethodType? get paymentMethodType; String? get paymentMethodLast4;// Stripe IDs
 String? get stripePaymentIntentId; String? get stripeCustomerId; String? get stripeChargeId;// Fee breakdown
 double get platformFee; double get stripeFee; double get driverEarnings; int? get seatsBooked;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get completedAt;@TimestampConverter() DateTime? get refundedAt;// Additional info
 String? get failureReason; String? get refundReason; Map<String, dynamic> get metadata;
/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentTransactionCopyWith<PaymentTransaction> get copyWith => _$PaymentTransactionCopyWithImpl<PaymentTransaction>(this as PaymentTransaction, _$identity);

  /// Serializes this PaymentTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.riderName, riderName) || other.riderName == riderName)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethodType, paymentMethodType) || other.paymentMethodType == paymentMethodType)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeChargeId, stripeChargeId) || other.stripeChargeId == stripeChargeId)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.stripeFee, stripeFee) || other.stripeFee == stripeFee)&&(identical(other.driverEarnings, driverEarnings) || other.driverEarnings == driverEarnings)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,riderId,riderName,driverId,driverName,amount,currency,status,paymentMethodType,paymentMethodLast4,stripePaymentIntentId,stripeCustomerId,stripeChargeId,platformFee,stripeFee,driverEarnings,seatsBooked,createdAt,updatedAt,completedAt,refundedAt,failureReason,refundReason,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'PaymentTransaction(id: $id, rideId: $rideId, riderId: $riderId, riderName: $riderName, driverId: $driverId, driverName: $driverName, amount: $amount, currency: $currency, status: $status, paymentMethodType: $paymentMethodType, paymentMethodLast4: $paymentMethodLast4, stripePaymentIntentId: $stripePaymentIntentId, stripeCustomerId: $stripeCustomerId, stripeChargeId: $stripeChargeId, platformFee: $platformFee, stripeFee: $stripeFee, driverEarnings: $driverEarnings, seatsBooked: $seatsBooked, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, refundedAt: $refundedAt, failureReason: $failureReason, refundReason: $refundReason, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PaymentTransactionCopyWith<$Res>  {
  factory $PaymentTransactionCopyWith(PaymentTransaction value, $Res Function(PaymentTransaction) _then) = _$PaymentTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, String riderId, String riderName, String driverId, String driverName, double amount, String currency, PaymentStatus status, PaymentMethodType? paymentMethodType, String? paymentMethodLast4, String? stripePaymentIntentId, String? stripeCustomerId, String? stripeChargeId, double platformFee, double stripeFee, double driverEarnings, int? seatsBooked,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? refundedAt, String? failureReason, String? refundReason, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$PaymentTransactionCopyWithImpl<$Res>
    implements $PaymentTransactionCopyWith<$Res> {
  _$PaymentTransactionCopyWithImpl(this._self, this._then);

  final PaymentTransaction _self;
  final $Res Function(PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? riderId = null,Object? riderName = null,Object? driverId = null,Object? driverName = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentMethodType = freezed,Object? paymentMethodLast4 = freezed,Object? stripePaymentIntentId = freezed,Object? stripeCustomerId = freezed,Object? stripeChargeId = freezed,Object? platformFee = null,Object? stripeFee = null,Object? driverEarnings = null,Object? seatsBooked = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? refundedAt = freezed,Object? failureReason = freezed,Object? refundReason = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,riderName: null == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethodType: freezed == paymentMethodType ? _self.paymentMethodType : paymentMethodType // ignore: cast_nullable_to_non_nullable
as PaymentMethodType?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeChargeId: freezed == stripeChargeId ? _self.stripeChargeId : stripeChargeId // ignore: cast_nullable_to_non_nullable
as String?,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,stripeFee: null == stripeFee ? _self.stripeFee : stripeFee // ignore: cast_nullable_to_non_nullable
as double,driverEarnings: null == driverEarnings ? _self.driverEarnings : driverEarnings // ignore: cast_nullable_to_non_nullable
as double,seatsBooked: freezed == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentTransaction].
extension PaymentTransactionPatterns on PaymentTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  double amount,  String currency,  PaymentStatus status,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  double platformFee,  double stripeFee,  double driverEarnings,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amount,_that.currency,_that.status,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.platformFee,_that.stripeFee,_that.driverEarnings,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  double amount,  String currency,  PaymentStatus status,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  double platformFee,  double stripeFee,  double driverEarnings,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction():
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amount,_that.currency,_that.status,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.platformFee,_that.stripeFee,_that.driverEarnings,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  String riderId,  String riderName,  String driverId,  String driverName,  double amount,  String currency,  PaymentStatus status,  PaymentMethodType? paymentMethodType,  String? paymentMethodLast4,  String? stripePaymentIntentId,  String? stripeCustomerId,  String? stripeChargeId,  double platformFee,  double stripeFee,  double driverEarnings,  int? seatsBooked, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? completedAt, @TimestampConverter()  DateTime? refundedAt,  String? failureReason,  String? refundReason,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _PaymentTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.riderId,_that.riderName,_that.driverId,_that.driverName,_that.amount,_that.currency,_that.status,_that.paymentMethodType,_that.paymentMethodLast4,_that.stripePaymentIntentId,_that.stripeCustomerId,_that.stripeChargeId,_that.platformFee,_that.stripeFee,_that.driverEarnings,_that.seatsBooked,_that.createdAt,_that.updatedAt,_that.completedAt,_that.refundedAt,_that.failureReason,_that.refundReason,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentTransaction extends PaymentTransaction {
  const _PaymentTransaction({required this.id, required this.rideId, required this.riderId, required this.riderName, required this.driverId, required this.driverName, required this.amount, required this.currency, required this.status, this.paymentMethodType, this.paymentMethodLast4, this.stripePaymentIntentId, this.stripeCustomerId, this.stripeChargeId, required this.platformFee, this.stripeFee = 0, required this.driverEarnings, this.seatsBooked, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.completedAt, @TimestampConverter() this.refundedAt, this.failureReason, this.refundReason, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _PaymentTransaction.fromJson(Map<String, dynamic> json) => _$PaymentTransactionFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  String riderId;
@override final  String riderName;
@override final  String driverId;
@override final  String driverName;
// Payment details
@override final  double amount;
// Total amount in dollars
@override final  String currency;
@override final  PaymentStatus status;
@override final  PaymentMethodType? paymentMethodType;
@override final  String? paymentMethodLast4;
// Stripe IDs
@override final  String? stripePaymentIntentId;
@override final  String? stripeCustomerId;
@override final  String? stripeChargeId;
// Fee breakdown
@override final  double platformFee;
@override@JsonKey() final  double stripeFee;
@override final  double driverEarnings;
@override final  int? seatsBooked;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? completedAt;
@override@TimestampConverter() final  DateTime? refundedAt;
// Additional info
@override final  String? failureReason;
@override final  String? refundReason;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentTransactionCopyWith<_PaymentTransaction> get copyWith => __$PaymentTransactionCopyWithImpl<_PaymentTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.riderName, riderName) || other.riderName == riderName)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethodType, paymentMethodType) || other.paymentMethodType == paymentMethodType)&&(identical(other.paymentMethodLast4, paymentMethodLast4) || other.paymentMethodLast4 == paymentMethodLast4)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripeChargeId, stripeChargeId) || other.stripeChargeId == stripeChargeId)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.stripeFee, stripeFee) || other.stripeFee == stripeFee)&&(identical(other.driverEarnings, driverEarnings) || other.driverEarnings == driverEarnings)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,riderId,riderName,driverId,driverName,amount,currency,status,paymentMethodType,paymentMethodLast4,stripePaymentIntentId,stripeCustomerId,stripeChargeId,platformFee,stripeFee,driverEarnings,seatsBooked,createdAt,updatedAt,completedAt,refundedAt,failureReason,refundReason,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'PaymentTransaction(id: $id, rideId: $rideId, riderId: $riderId, riderName: $riderName, driverId: $driverId, driverName: $driverName, amount: $amount, currency: $currency, status: $status, paymentMethodType: $paymentMethodType, paymentMethodLast4: $paymentMethodLast4, stripePaymentIntentId: $stripePaymentIntentId, stripeCustomerId: $stripeCustomerId, stripeChargeId: $stripeChargeId, platformFee: $platformFee, stripeFee: $stripeFee, driverEarnings: $driverEarnings, seatsBooked: $seatsBooked, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, refundedAt: $refundedAt, failureReason: $failureReason, refundReason: $refundReason, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PaymentTransactionCopyWith<$Res> implements $PaymentTransactionCopyWith<$Res> {
  factory _$PaymentTransactionCopyWith(_PaymentTransaction value, $Res Function(_PaymentTransaction) _then) = __$PaymentTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, String riderId, String riderName, String driverId, String driverName, double amount, String currency, PaymentStatus status, PaymentMethodType? paymentMethodType, String? paymentMethodLast4, String? stripePaymentIntentId, String? stripeCustomerId, String? stripeChargeId, double platformFee, double stripeFee, double driverEarnings, int? seatsBooked,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? completedAt,@TimestampConverter() DateTime? refundedAt, String? failureReason, String? refundReason, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$PaymentTransactionCopyWithImpl<$Res>
    implements _$PaymentTransactionCopyWith<$Res> {
  __$PaymentTransactionCopyWithImpl(this._self, this._then);

  final _PaymentTransaction _self;
  final $Res Function(_PaymentTransaction) _then;

/// Create a copy of PaymentTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? riderId = null,Object? riderName = null,Object? driverId = null,Object? driverName = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentMethodType = freezed,Object? paymentMethodLast4 = freezed,Object? stripePaymentIntentId = freezed,Object? stripeCustomerId = freezed,Object? stripeChargeId = freezed,Object? platformFee = null,Object? stripeFee = null,Object? driverEarnings = null,Object? seatsBooked = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,Object? refundedAt = freezed,Object? failureReason = freezed,Object? refundReason = freezed,Object? metadata = null,}) {
  return _then(_PaymentTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,riderName: null == riderName ? _self.riderName : riderName // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paymentMethodType: freezed == paymentMethodType ? _self.paymentMethodType : paymentMethodType // ignore: cast_nullable_to_non_nullable
as PaymentMethodType?,paymentMethodLast4: freezed == paymentMethodLast4 ? _self.paymentMethodLast4 : paymentMethodLast4 // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,stripeChargeId: freezed == stripeChargeId ? _self.stripeChargeId : stripeChargeId // ignore: cast_nullable_to_non_nullable
as String?,platformFee: null == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as double,stripeFee: null == stripeFee ? _self.stripeFee : stripeFee // ignore: cast_nullable_to_non_nullable
as double,driverEarnings: null == driverEarnings ? _self.driverEarnings : driverEarnings // ignore: cast_nullable_to_non_nullable
as double,seatsBooked: freezed == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DriverPayout {

 String get id; String get driverId; String get driverName; String get connectedAccountId;// Payout details
 double get amount;// Amount in dollars
 String get currency; PayoutStatus get status;// Stripe IDs
 String? get stripePayoutId; String? get stripeTransferId;// Related transactions
 List<String> get transactionIds;// Bank details (last 4 digits)
 String? get bankAccountLast4; String? get bankName;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get expectedArrivalDate;@TimestampConverter() DateTime? get arrivedAt;// Additional info
 String? get failureReason; bool? get isInstantPayout; Map<String, dynamic> get metadata;
/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverPayoutCopyWith<DriverPayout> get copyWith => _$DriverPayoutCopyWithImpl<DriverPayout>(this as DriverPayout, _$identity);

  /// Serializes this DriverPayout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverPayout&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.connectedAccountId, connectedAccountId) || other.connectedAccountId == connectedAccountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePayoutId, stripePayoutId) || other.stripePayoutId == stripePayoutId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&const DeepCollectionEquality().equals(other.transactionIds, transactionIds)&&(identical(other.bankAccountLast4, bankAccountLast4) || other.bankAccountLast4 == bankAccountLast4)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expectedArrivalDate, expectedArrivalDate) || other.expectedArrivalDate == expectedArrivalDate)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.isInstantPayout, isInstantPayout) || other.isInstantPayout == isInstantPayout)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,driverName,connectedAccountId,amount,currency,status,stripePayoutId,stripeTransferId,const DeepCollectionEquality().hash(transactionIds),bankAccountLast4,bankName,createdAt,expectedArrivalDate,arrivedAt,failureReason,isInstantPayout,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DriverPayout(id: $id, driverId: $driverId, driverName: $driverName, connectedAccountId: $connectedAccountId, amount: $amount, currency: $currency, status: $status, stripePayoutId: $stripePayoutId, stripeTransferId: $stripeTransferId, transactionIds: $transactionIds, bankAccountLast4: $bankAccountLast4, bankName: $bankName, createdAt: $createdAt, expectedArrivalDate: $expectedArrivalDate, arrivedAt: $arrivedAt, failureReason: $failureReason, isInstantPayout: $isInstantPayout, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DriverPayoutCopyWith<$Res>  {
  factory $DriverPayoutCopyWith(DriverPayout value, $Res Function(DriverPayout) _then) = _$DriverPayoutCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String driverName, String connectedAccountId, double amount, String currency, PayoutStatus status, String? stripePayoutId, String? stripeTransferId, List<String> transactionIds, String? bankAccountLast4, String? bankName,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? expectedArrivalDate,@TimestampConverter() DateTime? arrivedAt, String? failureReason, bool? isInstantPayout, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DriverPayoutCopyWithImpl<$Res>
    implements $DriverPayoutCopyWith<$Res> {
  _$DriverPayoutCopyWithImpl(this._self, this._then);

  final DriverPayout _self;
  final $Res Function(DriverPayout) _then;

/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? connectedAccountId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? stripePayoutId = freezed,Object? stripeTransferId = freezed,Object? transactionIds = null,Object? bankAccountLast4 = freezed,Object? bankName = freezed,Object? createdAt = freezed,Object? expectedArrivalDate = freezed,Object? arrivedAt = freezed,Object? failureReason = freezed,Object? isInstantPayout = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,connectedAccountId: null == connectedAccountId ? _self.connectedAccountId : connectedAccountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,stripePayoutId: freezed == stripePayoutId ? _self.stripePayoutId : stripePayoutId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,transactionIds: null == transactionIds ? _self.transactionIds : transactionIds // ignore: cast_nullable_to_non_nullable
as List<String>,bankAccountLast4: freezed == bankAccountLast4 ? _self.bankAccountLast4 : bankAccountLast4 // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedArrivalDate: freezed == expectedArrivalDate ? _self.expectedArrivalDate : expectedArrivalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,isInstantPayout: freezed == isInstantPayout ? _self.isInstantPayout : isInstantPayout // ignore: cast_nullable_to_non_nullable
as bool?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverPayout].
extension DriverPayoutPatterns on DriverPayout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverPayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverPayout value)  $default,){
final _that = this;
switch (_that) {
case _DriverPayout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverPayout value)?  $default,){
final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String connectedAccountId,  double amount,  String currency,  PayoutStatus status,  String? stripePayoutId,  String? stripeTransferId,  List<String> transactionIds,  String? bankAccountLast4,  String? bankName, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  bool? isInstantPayout,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amount,_that.currency,_that.status,_that.stripePayoutId,_that.stripeTransferId,_that.transactionIds,_that.bankAccountLast4,_that.bankName,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.isInstantPayout,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String connectedAccountId,  double amount,  String currency,  PayoutStatus status,  String? stripePayoutId,  String? stripeTransferId,  List<String> transactionIds,  String? bankAccountLast4,  String? bankName, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  bool? isInstantPayout,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DriverPayout():
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amount,_that.currency,_that.status,_that.stripePayoutId,_that.stripeTransferId,_that.transactionIds,_that.bankAccountLast4,_that.bankName,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.isInstantPayout,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String driverName,  String connectedAccountId,  double amount,  String currency,  PayoutStatus status,  String? stripePayoutId,  String? stripeTransferId,  List<String> transactionIds,  String? bankAccountLast4,  String? bankName, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? expectedArrivalDate, @TimestampConverter()  DateTime? arrivedAt,  String? failureReason,  bool? isInstantPayout,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DriverPayout() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.connectedAccountId,_that.amount,_that.currency,_that.status,_that.stripePayoutId,_that.stripeTransferId,_that.transactionIds,_that.bankAccountLast4,_that.bankName,_that.createdAt,_that.expectedArrivalDate,_that.arrivedAt,_that.failureReason,_that.isInstantPayout,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverPayout extends DriverPayout {
  const _DriverPayout({required this.id, required this.driverId, required this.driverName, required this.connectedAccountId, required this.amount, required this.currency, required this.status, this.stripePayoutId, this.stripeTransferId, final  List<String> transactionIds = const [], this.bankAccountLast4, this.bankName, @TimestampConverter() this.createdAt, @TimestampConverter() this.expectedArrivalDate, @TimestampConverter() this.arrivedAt, this.failureReason, this.isInstantPayout, final  Map<String, dynamic> metadata = const {}}): _transactionIds = transactionIds,_metadata = metadata,super._();
  factory _DriverPayout.fromJson(Map<String, dynamic> json) => _$DriverPayoutFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String driverName;
@override final  String connectedAccountId;
// Payout details
@override final  double amount;
// Amount in dollars
@override final  String currency;
@override final  PayoutStatus status;
// Stripe IDs
@override final  String? stripePayoutId;
@override final  String? stripeTransferId;
// Related transactions
 final  List<String> _transactionIds;
// Related transactions
@override@JsonKey() List<String> get transactionIds {
  if (_transactionIds is EqualUnmodifiableListView) return _transactionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactionIds);
}

// Bank details (last 4 digits)
@override final  String? bankAccountLast4;
@override final  String? bankName;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? expectedArrivalDate;
@override@TimestampConverter() final  DateTime? arrivedAt;
// Additional info
@override final  String? failureReason;
@override final  bool? isInstantPayout;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverPayoutCopyWith<_DriverPayout> get copyWith => __$DriverPayoutCopyWithImpl<_DriverPayout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverPayoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverPayout&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.connectedAccountId, connectedAccountId) || other.connectedAccountId == connectedAccountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePayoutId, stripePayoutId) || other.stripePayoutId == stripePayoutId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&const DeepCollectionEquality().equals(other._transactionIds, _transactionIds)&&(identical(other.bankAccountLast4, bankAccountLast4) || other.bankAccountLast4 == bankAccountLast4)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expectedArrivalDate, expectedArrivalDate) || other.expectedArrivalDate == expectedArrivalDate)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason)&&(identical(other.isInstantPayout, isInstantPayout) || other.isInstantPayout == isInstantPayout)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driverId,driverName,connectedAccountId,amount,currency,status,stripePayoutId,stripeTransferId,const DeepCollectionEquality().hash(_transactionIds),bankAccountLast4,bankName,createdAt,expectedArrivalDate,arrivedAt,failureReason,isInstantPayout,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DriverPayout(id: $id, driverId: $driverId, driverName: $driverName, connectedAccountId: $connectedAccountId, amount: $amount, currency: $currency, status: $status, stripePayoutId: $stripePayoutId, stripeTransferId: $stripeTransferId, transactionIds: $transactionIds, bankAccountLast4: $bankAccountLast4, bankName: $bankName, createdAt: $createdAt, expectedArrivalDate: $expectedArrivalDate, arrivedAt: $arrivedAt, failureReason: $failureReason, isInstantPayout: $isInstantPayout, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DriverPayoutCopyWith<$Res> implements $DriverPayoutCopyWith<$Res> {
  factory _$DriverPayoutCopyWith(_DriverPayout value, $Res Function(_DriverPayout) _then) = __$DriverPayoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String driverName, String connectedAccountId, double amount, String currency, PayoutStatus status, String? stripePayoutId, String? stripeTransferId, List<String> transactionIds, String? bankAccountLast4, String? bankName,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? expectedArrivalDate,@TimestampConverter() DateTime? arrivedAt, String? failureReason, bool? isInstantPayout, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DriverPayoutCopyWithImpl<$Res>
    implements _$DriverPayoutCopyWith<$Res> {
  __$DriverPayoutCopyWithImpl(this._self, this._then);

  final _DriverPayout _self;
  final $Res Function(_DriverPayout) _then;

/// Create a copy of DriverPayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? connectedAccountId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? stripePayoutId = freezed,Object? stripeTransferId = freezed,Object? transactionIds = null,Object? bankAccountLast4 = freezed,Object? bankName = freezed,Object? createdAt = freezed,Object? expectedArrivalDate = freezed,Object? arrivedAt = freezed,Object? failureReason = freezed,Object? isInstantPayout = freezed,Object? metadata = null,}) {
  return _then(_DriverPayout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,connectedAccountId: null == connectedAccountId ? _self.connectedAccountId : connectedAccountId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,stripePayoutId: freezed == stripePayoutId ? _self.stripePayoutId : stripePayoutId // ignore: cast_nullable_to_non_nullable
as String?,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,transactionIds: null == transactionIds ? _self._transactionIds : transactionIds // ignore: cast_nullable_to_non_nullable
as List<String>,bankAccountLast4: freezed == bankAccountLast4 ? _self.bankAccountLast4 : bankAccountLast4 // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedArrivalDate: freezed == expectedArrivalDate ? _self.expectedArrivalDate : expectedArrivalDate // ignore: cast_nullable_to_non_nullable
as DateTime?,arrivedAt: freezed == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,isInstantPayout: freezed == isInstantPayout ? _self.isInstantPayout : isInstantPayout // ignore: cast_nullable_to_non_nullable
as bool?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DriverConnectedAccount {

 String get id; String get driverId; String get stripeAccountId;// Account details
 String get email; String get country; bool get chargesEnabled; bool get payoutsEnabled; bool get detailsSubmitted;// Onboarding
 bool? get onboardingCompleted;@TimestampConverter() DateTime? get onboardingCompletedAt; String? get onboardingUrl;// Bank account info (masked)
 String? get bankAccountLast4; String? get bankName; String? get accountHolderName;// Earnings summary
 double get totalEarnings; double get availableBalance; double get pendingBalance;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get lastPayoutAt;// Additional info
 Map<String, dynamic> get requirements; Map<String, dynamic> get metadata;
/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverConnectedAccountCopyWith<DriverConnectedAccount> get copyWith => _$DriverConnectedAccountCopyWithImpl<DriverConnectedAccount>(this as DriverConnectedAccount, _$identity);

  /// Serializes this DriverConnectedAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverConnectedAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&(identical(other.onboardingUrl, onboardingUrl) || other.onboardingUrl == onboardingUrl)&&(identical(other.bankAccountLast4, bankAccountLast4) || other.bankAccountLast4 == bankAccountLast4)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.availableBalance, availableBalance) || other.availableBalance == availableBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastPayoutAt, lastPayoutAt) || other.lastPayoutAt == lastPayoutAt)&&const DeepCollectionEquality().equals(other.requirements, requirements)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,stripeAccountId,email,country,chargesEnabled,payoutsEnabled,detailsSubmitted,onboardingCompleted,onboardingCompletedAt,onboardingUrl,bankAccountLast4,bankName,accountHolderName,totalEarnings,availableBalance,pendingBalance,createdAt,updatedAt,lastPayoutAt,const DeepCollectionEquality().hash(requirements),const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'DriverConnectedAccount(id: $id, driverId: $driverId, stripeAccountId: $stripeAccountId, email: $email, country: $country, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, onboardingCompleted: $onboardingCompleted, onboardingCompletedAt: $onboardingCompletedAt, onboardingUrl: $onboardingUrl, bankAccountLast4: $bankAccountLast4, bankName: $bankName, accountHolderName: $accountHolderName, totalEarnings: $totalEarnings, availableBalance: $availableBalance, pendingBalance: $pendingBalance, createdAt: $createdAt, updatedAt: $updatedAt, lastPayoutAt: $lastPayoutAt, requirements: $requirements, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DriverConnectedAccountCopyWith<$Res>  {
  factory $DriverConnectedAccountCopyWith(DriverConnectedAccount value, $Res Function(DriverConnectedAccount) _then) = _$DriverConnectedAccountCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String stripeAccountId, String email, String country, bool chargesEnabled, bool payoutsEnabled, bool detailsSubmitted, bool? onboardingCompleted,@TimestampConverter() DateTime? onboardingCompletedAt, String? onboardingUrl, String? bankAccountLast4, String? bankName, String? accountHolderName, double totalEarnings, double availableBalance, double pendingBalance,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastPayoutAt, Map<String, dynamic> requirements, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DriverConnectedAccountCopyWithImpl<$Res>
    implements $DriverConnectedAccountCopyWith<$Res> {
  _$DriverConnectedAccountCopyWithImpl(this._self, this._then);

  final DriverConnectedAccount _self;
  final $Res Function(DriverConnectedAccount) _then;

/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? stripeAccountId = null,Object? email = null,Object? country = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? onboardingCompleted = freezed,Object? onboardingCompletedAt = freezed,Object? onboardingUrl = freezed,Object? bankAccountLast4 = freezed,Object? bankName = freezed,Object? accountHolderName = freezed,Object? totalEarnings = null,Object? availableBalance = null,Object? pendingBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastPayoutAt = freezed,Object? requirements = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: null == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,onboardingCompleted: freezed == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onboardingUrl: freezed == onboardingUrl ? _self.onboardingUrl : onboardingUrl // ignore: cast_nullable_to_non_nullable
as String?,bankAccountLast4: freezed == bankAccountLast4 ? _self.bankAccountLast4 : bankAccountLast4 // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,accountHolderName: freezed == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String?,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,availableBalance: null == availableBalance ? _self.availableBalance : availableBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutAt: freezed == lastPayoutAt ? _self.lastPayoutAt : lastPayoutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requirements: null == requirements ? _self.requirements : requirements // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverConnectedAccount].
extension DriverConnectedAccountPatterns on DriverConnectedAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverConnectedAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverConnectedAccount value)  $default,){
final _that = this;
switch (_that) {
case _DriverConnectedAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverConnectedAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? onboardingUrl,  String? bankAccountLast4,  String? bankName,  String? accountHolderName,  double totalEarnings,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> requirements,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.onboardingUrl,_that.bankAccountLast4,_that.bankName,_that.accountHolderName,_that.totalEarnings,_that.availableBalance,_that.pendingBalance,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.requirements,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? onboardingUrl,  String? bankAccountLast4,  String? bankName,  String? accountHolderName,  double totalEarnings,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> requirements,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DriverConnectedAccount():
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.onboardingUrl,_that.bankAccountLast4,_that.bankName,_that.accountHolderName,_that.totalEarnings,_that.availableBalance,_that.pendingBalance,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.requirements,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String stripeAccountId,  String email,  String country,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  bool? onboardingCompleted, @TimestampConverter()  DateTime? onboardingCompletedAt,  String? onboardingUrl,  String? bankAccountLast4,  String? bankName,  String? accountHolderName,  double totalEarnings,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastPayoutAt,  Map<String, dynamic> requirements,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DriverConnectedAccount() when $default != null:
return $default(_that.id,_that.driverId,_that.stripeAccountId,_that.email,_that.country,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.onboardingCompleted,_that.onboardingCompletedAt,_that.onboardingUrl,_that.bankAccountLast4,_that.bankName,_that.accountHolderName,_that.totalEarnings,_that.availableBalance,_that.pendingBalance,_that.createdAt,_that.updatedAt,_that.lastPayoutAt,_that.requirements,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverConnectedAccount extends DriverConnectedAccount {
  const _DriverConnectedAccount({required this.id, required this.driverId, required this.stripeAccountId, required this.email, required this.country, required this.chargesEnabled, required this.payoutsEnabled, required this.detailsSubmitted, this.onboardingCompleted, @TimestampConverter() this.onboardingCompletedAt, this.onboardingUrl, this.bankAccountLast4, this.bankName, this.accountHolderName, this.totalEarnings = 0.0, this.availableBalance = 0.0, this.pendingBalance = 0.0, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastPayoutAt, final  Map<String, dynamic> requirements = const {}, final  Map<String, dynamic> metadata = const {}}): _requirements = requirements,_metadata = metadata,super._();
  factory _DriverConnectedAccount.fromJson(Map<String, dynamic> json) => _$DriverConnectedAccountFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String stripeAccountId;
// Account details
@override final  String email;
@override final  String country;
@override final  bool chargesEnabled;
@override final  bool payoutsEnabled;
@override final  bool detailsSubmitted;
// Onboarding
@override final  bool? onboardingCompleted;
@override@TimestampConverter() final  DateTime? onboardingCompletedAt;
@override final  String? onboardingUrl;
// Bank account info (masked)
@override final  String? bankAccountLast4;
@override final  String? bankName;
@override final  String? accountHolderName;
// Earnings summary
@override@JsonKey() final  double totalEarnings;
@override@JsonKey() final  double availableBalance;
@override@JsonKey() final  double pendingBalance;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastPayoutAt;
// Additional info
 final  Map<String, dynamic> _requirements;
// Additional info
@override@JsonKey() Map<String, dynamic> get requirements {
  if (_requirements is EqualUnmodifiableMapView) return _requirements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requirements);
}

 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverConnectedAccountCopyWith<_DriverConnectedAccount> get copyWith => __$DriverConnectedAccountCopyWithImpl<_DriverConnectedAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverConnectedAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverConnectedAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.email, email) || other.email == email)&&(identical(other.country, country) || other.country == country)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&(identical(other.onboardingCompleted, onboardingCompleted) || other.onboardingCompleted == onboardingCompleted)&&(identical(other.onboardingCompletedAt, onboardingCompletedAt) || other.onboardingCompletedAt == onboardingCompletedAt)&&(identical(other.onboardingUrl, onboardingUrl) || other.onboardingUrl == onboardingUrl)&&(identical(other.bankAccountLast4, bankAccountLast4) || other.bankAccountLast4 == bankAccountLast4)&&(identical(other.bankName, bankName) || other.bankName == bankName)&&(identical(other.accountHolderName, accountHolderName) || other.accountHolderName == accountHolderName)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.availableBalance, availableBalance) || other.availableBalance == availableBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastPayoutAt, lastPayoutAt) || other.lastPayoutAt == lastPayoutAt)&&const DeepCollectionEquality().equals(other._requirements, _requirements)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,stripeAccountId,email,country,chargesEnabled,payoutsEnabled,detailsSubmitted,onboardingCompleted,onboardingCompletedAt,onboardingUrl,bankAccountLast4,bankName,accountHolderName,totalEarnings,availableBalance,pendingBalance,createdAt,updatedAt,lastPayoutAt,const DeepCollectionEquality().hash(_requirements),const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'DriverConnectedAccount(id: $id, driverId: $driverId, stripeAccountId: $stripeAccountId, email: $email, country: $country, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, onboardingCompleted: $onboardingCompleted, onboardingCompletedAt: $onboardingCompletedAt, onboardingUrl: $onboardingUrl, bankAccountLast4: $bankAccountLast4, bankName: $bankName, accountHolderName: $accountHolderName, totalEarnings: $totalEarnings, availableBalance: $availableBalance, pendingBalance: $pendingBalance, createdAt: $createdAt, updatedAt: $updatedAt, lastPayoutAt: $lastPayoutAt, requirements: $requirements, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DriverConnectedAccountCopyWith<$Res> implements $DriverConnectedAccountCopyWith<$Res> {
  factory _$DriverConnectedAccountCopyWith(_DriverConnectedAccount value, $Res Function(_DriverConnectedAccount) _then) = __$DriverConnectedAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String stripeAccountId, String email, String country, bool chargesEnabled, bool payoutsEnabled, bool detailsSubmitted, bool? onboardingCompleted,@TimestampConverter() DateTime? onboardingCompletedAt, String? onboardingUrl, String? bankAccountLast4, String? bankName, String? accountHolderName, double totalEarnings, double availableBalance, double pendingBalance,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastPayoutAt, Map<String, dynamic> requirements, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DriverConnectedAccountCopyWithImpl<$Res>
    implements _$DriverConnectedAccountCopyWith<$Res> {
  __$DriverConnectedAccountCopyWithImpl(this._self, this._then);

  final _DriverConnectedAccount _self;
  final $Res Function(_DriverConnectedAccount) _then;

/// Create a copy of DriverConnectedAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? stripeAccountId = null,Object? email = null,Object? country = null,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? onboardingCompleted = freezed,Object? onboardingCompletedAt = freezed,Object? onboardingUrl = freezed,Object? bankAccountLast4 = freezed,Object? bankName = freezed,Object? accountHolderName = freezed,Object? totalEarnings = null,Object? availableBalance = null,Object? pendingBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastPayoutAt = freezed,Object? requirements = null,Object? metadata = null,}) {
  return _then(_DriverConnectedAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,stripeAccountId: null == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,onboardingCompleted: freezed == onboardingCompleted ? _self.onboardingCompleted : onboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool?,onboardingCompletedAt: freezed == onboardingCompletedAt ? _self.onboardingCompletedAt : onboardingCompletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onboardingUrl: freezed == onboardingUrl ? _self.onboardingUrl : onboardingUrl // ignore: cast_nullable_to_non_nullable
as String?,bankAccountLast4: freezed == bankAccountLast4 ? _self.bankAccountLast4 : bankAccountLast4 // ignore: cast_nullable_to_non_nullable
as String?,bankName: freezed == bankName ? _self.bankName : bankName // ignore: cast_nullable_to_non_nullable
as String?,accountHolderName: freezed == accountHolderName ? _self.accountHolderName : accountHolderName // ignore: cast_nullable_to_non_nullable
as String?,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,availableBalance: null == availableBalance ? _self.availableBalance : availableBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutAt: freezed == lastPayoutAt ? _self.lastPayoutAt : lastPayoutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,requirements: null == requirements ? _self._requirements : requirements // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$RiderPaymentMethod {

 String get id; String get riderId; String get stripeCustomerId; String get stripePaymentMethodId;// Card details
 String get brand;// visa, mastercard, amex, etc.
 String get last4; int get exMonth; int get exYear;// Flags
 bool get isDefault;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderPaymentMethodCopyWith<RiderPaymentMethod> get copyWith => _$RiderPaymentMethodCopyWithImpl<RiderPaymentMethod>(this as RiderPaymentMethod, _$identity);

  /// Serializes this RiderPaymentMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripePaymentMethodId, stripePaymentMethodId) || other.stripePaymentMethodId == stripePaymentMethodId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.exMonth, exMonth) || other.exMonth == exMonth)&&(identical(other.exYear, exYear) || other.exYear == exYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,stripeCustomerId,stripePaymentMethodId,brand,last4,exMonth,exYear,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'RiderPaymentMethod(id: $id, riderId: $riderId, stripeCustomerId: $stripeCustomerId, stripePaymentMethodId: $stripePaymentMethodId, brand: $brand, last4: $last4, exMonth: $exMonth, exYear: $exYear, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RiderPaymentMethodCopyWith<$Res>  {
  factory $RiderPaymentMethodCopyWith(RiderPaymentMethod value, $Res Function(RiderPaymentMethod) _then) = _$RiderPaymentMethodCopyWithImpl;
@useResult
$Res call({
 String id, String riderId, String stripeCustomerId, String stripePaymentMethodId, String brand, String last4, int exMonth, int exYear, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$RiderPaymentMethodCopyWithImpl<$Res>
    implements $RiderPaymentMethodCopyWith<$Res> {
  _$RiderPaymentMethodCopyWithImpl(this._self, this._then);

  final RiderPaymentMethod _self;
  final $Res Function(RiderPaymentMethod) _then;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? riderId = null,Object? stripeCustomerId = null,Object? stripePaymentMethodId = null,Object? brand = null,Object? last4 = null,Object? exMonth = null,Object? exYear = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: null == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String,stripePaymentMethodId: null == stripePaymentMethodId ? _self.stripePaymentMethodId : stripePaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,exMonth: null == exMonth ? _self.exMonth : exMonth // ignore: cast_nullable_to_non_nullable
as int,exYear: null == exYear ? _self.exYear : exYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiderPaymentMethod].
extension RiderPaymentMethodPatterns on RiderPaymentMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiderPaymentMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiderPaymentMethod value)  $default,){
final _that = this;
switch (_that) {
case _RiderPaymentMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiderPaymentMethod value)?  $default,){
final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RiderPaymentMethod():
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String riderId,  String stripeCustomerId,  String stripePaymentMethodId,  String brand,  String last4,  int exMonth,  int exYear,  bool isDefault, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RiderPaymentMethod() when $default != null:
return $default(_that.id,_that.riderId,_that.stripeCustomerId,_that.stripePaymentMethodId,_that.brand,_that.last4,_that.exMonth,_that.exYear,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiderPaymentMethod extends RiderPaymentMethod {
  const _RiderPaymentMethod({required this.id, required this.riderId, required this.stripeCustomerId, required this.stripePaymentMethodId, required this.brand, required this.last4, required this.exMonth, required this.exYear, this.isDefault = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): super._();
  factory _RiderPaymentMethod.fromJson(Map<String, dynamic> json) => _$RiderPaymentMethodFromJson(json);

@override final  String id;
@override final  String riderId;
@override final  String stripeCustomerId;
@override final  String stripePaymentMethodId;
// Card details
@override final  String brand;
// visa, mastercard, amex, etc.
@override final  String last4;
@override final  int exMonth;
@override final  int exYear;
// Flags
@override@JsonKey() final  bool isDefault;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiderPaymentMethodCopyWith<_RiderPaymentMethod> get copyWith => __$RiderPaymentMethodCopyWithImpl<_RiderPaymentMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderPaymentMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiderPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.stripePaymentMethodId, stripePaymentMethodId) || other.stripePaymentMethodId == stripePaymentMethodId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.exMonth, exMonth) || other.exMonth == exMonth)&&(identical(other.exYear, exYear) || other.exYear == exYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,stripeCustomerId,stripePaymentMethodId,brand,last4,exMonth,exYear,isDefault,createdAt,updatedAt);

@override
String toString() {
  return 'RiderPaymentMethod(id: $id, riderId: $riderId, stripeCustomerId: $stripeCustomerId, stripePaymentMethodId: $stripePaymentMethodId, brand: $brand, last4: $last4, exMonth: $exMonth, exYear: $exYear, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RiderPaymentMethodCopyWith<$Res> implements $RiderPaymentMethodCopyWith<$Res> {
  factory _$RiderPaymentMethodCopyWith(_RiderPaymentMethod value, $Res Function(_RiderPaymentMethod) _then) = __$RiderPaymentMethodCopyWithImpl;
@override @useResult
$Res call({
 String id, String riderId, String stripeCustomerId, String stripePaymentMethodId, String brand, String last4, int exMonth, int exYear, bool isDefault,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$RiderPaymentMethodCopyWithImpl<$Res>
    implements _$RiderPaymentMethodCopyWith<$Res> {
  __$RiderPaymentMethodCopyWithImpl(this._self, this._then);

  final _RiderPaymentMethod _self;
  final $Res Function(_RiderPaymentMethod) _then;

/// Create a copy of RiderPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? riderId = null,Object? stripeCustomerId = null,Object? stripePaymentMethodId = null,Object? brand = null,Object? last4 = null,Object? exMonth = null,Object? exYear = null,Object? isDefault = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RiderPaymentMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,stripeCustomerId: null == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String,stripePaymentMethodId: null == stripePaymentMethodId ? _self.stripePaymentMethodId : stripePaymentMethodId // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,exMonth: null == exMonth ? _self.exMonth : exMonth // ignore: cast_nullable_to_non_nullable
as int,exYear: null == exYear ? _self.exYear : exYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EarningsSummary {

 String get driverId;// Total earnings
 double get totalEarnings; double get totalPlatformFees; double get totalStripeFees;// Period earnings
 double get earningsToday; double get earningsThisWeek; double get earningsThisMonth; double get earningsThisYear;// Ride stats
 int get totalRidesCompleted; int get ridesCompletedToday; int get ridesCompletedThisWeek; int get ridesCompletedThisMonth;// Balance
 double get availableBalance; double get pendingBalance;// Timestamps
@TimestampConverter() DateTime? get lastUpdated;@TimestampConverter() DateTime? get lastPayoutDate;
/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsSummaryCopyWith<EarningsSummary> get copyWith => _$EarningsSummaryCopyWithImpl<EarningsSummary>(this as EarningsSummary, _$identity);

  /// Serializes this EarningsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsSummary&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalPlatformFees, totalPlatformFees) || other.totalPlatformFees == totalPlatformFees)&&(identical(other.totalStripeFees, totalStripeFees) || other.totalStripeFees == totalStripeFees)&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.earningsThisWeek, earningsThisWeek) || other.earningsThisWeek == earningsThisWeek)&&(identical(other.earningsThisMonth, earningsThisMonth) || other.earningsThisMonth == earningsThisMonth)&&(identical(other.earningsThisYear, earningsThisYear) || other.earningsThisYear == earningsThisYear)&&(identical(other.totalRidesCompleted, totalRidesCompleted) || other.totalRidesCompleted == totalRidesCompleted)&&(identical(other.ridesCompletedToday, ridesCompletedToday) || other.ridesCompletedToday == ridesCompletedToday)&&(identical(other.ridesCompletedThisWeek, ridesCompletedThisWeek) || other.ridesCompletedThisWeek == ridesCompletedThisWeek)&&(identical(other.ridesCompletedThisMonth, ridesCompletedThisMonth) || other.ridesCompletedThisMonth == ridesCompletedThisMonth)&&(identical(other.availableBalance, availableBalance) || other.availableBalance == availableBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastPayoutDate, lastPayoutDate) || other.lastPayoutDate == lastPayoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,totalEarnings,totalPlatformFees,totalStripeFees,earningsToday,earningsThisWeek,earningsThisMonth,earningsThisYear,totalRidesCompleted,ridesCompletedToday,ridesCompletedThisWeek,ridesCompletedThisMonth,availableBalance,pendingBalance,lastUpdated,lastPayoutDate);

@override
String toString() {
  return 'EarningsSummary(driverId: $driverId, totalEarnings: $totalEarnings, totalPlatformFees: $totalPlatformFees, totalStripeFees: $totalStripeFees, earningsToday: $earningsToday, earningsThisWeek: $earningsThisWeek, earningsThisMonth: $earningsThisMonth, earningsThisYear: $earningsThisYear, totalRidesCompleted: $totalRidesCompleted, ridesCompletedToday: $ridesCompletedToday, ridesCompletedThisWeek: $ridesCompletedThisWeek, ridesCompletedThisMonth: $ridesCompletedThisMonth, availableBalance: $availableBalance, pendingBalance: $pendingBalance, lastUpdated: $lastUpdated, lastPayoutDate: $lastPayoutDate)';
}


}

/// @nodoc
abstract mixin class $EarningsSummaryCopyWith<$Res>  {
  factory $EarningsSummaryCopyWith(EarningsSummary value, $Res Function(EarningsSummary) _then) = _$EarningsSummaryCopyWithImpl;
@useResult
$Res call({
 String driverId, double totalEarnings, double totalPlatformFees, double totalStripeFees, double earningsToday, double earningsThisWeek, double earningsThisMonth, double earningsThisYear, int totalRidesCompleted, int ridesCompletedToday, int ridesCompletedThisWeek, int ridesCompletedThisMonth, double availableBalance, double pendingBalance,@TimestampConverter() DateTime? lastUpdated,@TimestampConverter() DateTime? lastPayoutDate
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
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? totalEarnings = null,Object? totalPlatformFees = null,Object? totalStripeFees = null,Object? earningsToday = null,Object? earningsThisWeek = null,Object? earningsThisMonth = null,Object? earningsThisYear = null,Object? totalRidesCompleted = null,Object? ridesCompletedToday = null,Object? ridesCompletedThisWeek = null,Object? ridesCompletedThisMonth = null,Object? availableBalance = null,Object? pendingBalance = null,Object? lastUpdated = freezed,Object? lastPayoutDate = freezed,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalPlatformFees: null == totalPlatformFees ? _self.totalPlatformFees : totalPlatformFees // ignore: cast_nullable_to_non_nullable
as double,totalStripeFees: null == totalStripeFees ? _self.totalStripeFees : totalStripeFees // ignore: cast_nullable_to_non_nullable
as double,earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as double,earningsThisWeek: null == earningsThisWeek ? _self.earningsThisWeek : earningsThisWeek // ignore: cast_nullable_to_non_nullable
as double,earningsThisMonth: null == earningsThisMonth ? _self.earningsThisMonth : earningsThisMonth // ignore: cast_nullable_to_non_nullable
as double,earningsThisYear: null == earningsThisYear ? _self.earningsThisYear : earningsThisYear // ignore: cast_nullable_to_non_nullable
as double,totalRidesCompleted: null == totalRidesCompleted ? _self.totalRidesCompleted : totalRidesCompleted // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedToday: null == ridesCompletedToday ? _self.ridesCompletedToday : ridesCompletedToday // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisWeek: null == ridesCompletedThisWeek ? _self.ridesCompletedThisWeek : ridesCompletedThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisMonth: null == ridesCompletedThisMonth ? _self.ridesCompletedThisMonth : ridesCompletedThisMonth // ignore: cast_nullable_to_non_nullable
as int,availableBalance: null == availableBalance ? _self.availableBalance : availableBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutDate: freezed == lastPayoutDate ? _self.lastPayoutDate : lastPayoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  double totalEarnings,  double totalPlatformFees,  double totalStripeFees,  double earningsToday,  double earningsThisWeek,  double earningsThisMonth,  double earningsThisYear,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.driverId,_that.totalEarnings,_that.totalPlatformFees,_that.totalStripeFees,_that.earningsToday,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsThisYear,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalance,_that.pendingBalance,_that.lastUpdated,_that.lastPayoutDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  double totalEarnings,  double totalPlatformFees,  double totalStripeFees,  double earningsToday,  double earningsThisWeek,  double earningsThisMonth,  double earningsThisYear,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary():
return $default(_that.driverId,_that.totalEarnings,_that.totalPlatformFees,_that.totalStripeFees,_that.earningsToday,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsThisYear,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalance,_that.pendingBalance,_that.lastUpdated,_that.lastPayoutDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  double totalEarnings,  double totalPlatformFees,  double totalStripeFees,  double earningsToday,  double earningsThisWeek,  double earningsThisMonth,  double earningsThisYear,  int totalRidesCompleted,  int ridesCompletedToday,  int ridesCompletedThisWeek,  int ridesCompletedThisMonth,  double availableBalance,  double pendingBalance, @TimestampConverter()  DateTime? lastUpdated, @TimestampConverter()  DateTime? lastPayoutDate)?  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.driverId,_that.totalEarnings,_that.totalPlatformFees,_that.totalStripeFees,_that.earningsToday,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsThisYear,_that.totalRidesCompleted,_that.ridesCompletedToday,_that.ridesCompletedThisWeek,_that.ridesCompletedThisMonth,_that.availableBalance,_that.pendingBalance,_that.lastUpdated,_that.lastPayoutDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsSummary extends EarningsSummary {
  const _EarningsSummary({required this.driverId, this.totalEarnings = 0.0, this.totalPlatformFees = 0.0, this.totalStripeFees = 0.0, this.earningsToday = 0.0, this.earningsThisWeek = 0.0, this.earningsThisMonth = 0.0, this.earningsThisYear = 0.0, this.totalRidesCompleted = 0, this.ridesCompletedToday = 0, this.ridesCompletedThisWeek = 0, this.ridesCompletedThisMonth = 0, this.availableBalance = 0.0, this.pendingBalance = 0.0, @TimestampConverter() this.lastUpdated, @TimestampConverter() this.lastPayoutDate}): super._();
  factory _EarningsSummary.fromJson(Map<String, dynamic> json) => _$EarningsSummaryFromJson(json);

@override final  String driverId;
// Total earnings
@override@JsonKey() final  double totalEarnings;
@override@JsonKey() final  double totalPlatformFees;
@override@JsonKey() final  double totalStripeFees;
// Period earnings
@override@JsonKey() final  double earningsToday;
@override@JsonKey() final  double earningsThisWeek;
@override@JsonKey() final  double earningsThisMonth;
@override@JsonKey() final  double earningsThisYear;
// Ride stats
@override@JsonKey() final  int totalRidesCompleted;
@override@JsonKey() final  int ridesCompletedToday;
@override@JsonKey() final  int ridesCompletedThisWeek;
@override@JsonKey() final  int ridesCompletedThisMonth;
// Balance
@override@JsonKey() final  double availableBalance;
@override@JsonKey() final  double pendingBalance;
// Timestamps
@override@TimestampConverter() final  DateTime? lastUpdated;
@override@TimestampConverter() final  DateTime? lastPayoutDate;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsSummary&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalPlatformFees, totalPlatformFees) || other.totalPlatformFees == totalPlatformFees)&&(identical(other.totalStripeFees, totalStripeFees) || other.totalStripeFees == totalStripeFees)&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.earningsThisWeek, earningsThisWeek) || other.earningsThisWeek == earningsThisWeek)&&(identical(other.earningsThisMonth, earningsThisMonth) || other.earningsThisMonth == earningsThisMonth)&&(identical(other.earningsThisYear, earningsThisYear) || other.earningsThisYear == earningsThisYear)&&(identical(other.totalRidesCompleted, totalRidesCompleted) || other.totalRidesCompleted == totalRidesCompleted)&&(identical(other.ridesCompletedToday, ridesCompletedToday) || other.ridesCompletedToday == ridesCompletedToday)&&(identical(other.ridesCompletedThisWeek, ridesCompletedThisWeek) || other.ridesCompletedThisWeek == ridesCompletedThisWeek)&&(identical(other.ridesCompletedThisMonth, ridesCompletedThisMonth) || other.ridesCompletedThisMonth == ridesCompletedThisMonth)&&(identical(other.availableBalance, availableBalance) || other.availableBalance == availableBalance)&&(identical(other.pendingBalance, pendingBalance) || other.pendingBalance == pendingBalance)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastPayoutDate, lastPayoutDate) || other.lastPayoutDate == lastPayoutDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,totalEarnings,totalPlatformFees,totalStripeFees,earningsToday,earningsThisWeek,earningsThisMonth,earningsThisYear,totalRidesCompleted,ridesCompletedToday,ridesCompletedThisWeek,ridesCompletedThisMonth,availableBalance,pendingBalance,lastUpdated,lastPayoutDate);

@override
String toString() {
  return 'EarningsSummary(driverId: $driverId, totalEarnings: $totalEarnings, totalPlatformFees: $totalPlatformFees, totalStripeFees: $totalStripeFees, earningsToday: $earningsToday, earningsThisWeek: $earningsThisWeek, earningsThisMonth: $earningsThisMonth, earningsThisYear: $earningsThisYear, totalRidesCompleted: $totalRidesCompleted, ridesCompletedToday: $ridesCompletedToday, ridesCompletedThisWeek: $ridesCompletedThisWeek, ridesCompletedThisMonth: $ridesCompletedThisMonth, availableBalance: $availableBalance, pendingBalance: $pendingBalance, lastUpdated: $lastUpdated, lastPayoutDate: $lastPayoutDate)';
}


}

/// @nodoc
abstract mixin class _$EarningsSummaryCopyWith<$Res> implements $EarningsSummaryCopyWith<$Res> {
  factory _$EarningsSummaryCopyWith(_EarningsSummary value, $Res Function(_EarningsSummary) _then) = __$EarningsSummaryCopyWithImpl;
@override @useResult
$Res call({
 String driverId, double totalEarnings, double totalPlatformFees, double totalStripeFees, double earningsToday, double earningsThisWeek, double earningsThisMonth, double earningsThisYear, int totalRidesCompleted, int ridesCompletedToday, int ridesCompletedThisWeek, int ridesCompletedThisMonth, double availableBalance, double pendingBalance,@TimestampConverter() DateTime? lastUpdated,@TimestampConverter() DateTime? lastPayoutDate
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
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? totalEarnings = null,Object? totalPlatformFees = null,Object? totalStripeFees = null,Object? earningsToday = null,Object? earningsThisWeek = null,Object? earningsThisMonth = null,Object? earningsThisYear = null,Object? totalRidesCompleted = null,Object? ridesCompletedToday = null,Object? ridesCompletedThisWeek = null,Object? ridesCompletedThisMonth = null,Object? availableBalance = null,Object? pendingBalance = null,Object? lastUpdated = freezed,Object? lastPayoutDate = freezed,}) {
  return _then(_EarningsSummary(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalPlatformFees: null == totalPlatformFees ? _self.totalPlatformFees : totalPlatformFees // ignore: cast_nullable_to_non_nullable
as double,totalStripeFees: null == totalStripeFees ? _self.totalStripeFees : totalStripeFees // ignore: cast_nullable_to_non_nullable
as double,earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as double,earningsThisWeek: null == earningsThisWeek ? _self.earningsThisWeek : earningsThisWeek // ignore: cast_nullable_to_non_nullable
as double,earningsThisMonth: null == earningsThisMonth ? _self.earningsThisMonth : earningsThisMonth // ignore: cast_nullable_to_non_nullable
as double,earningsThisYear: null == earningsThisYear ? _self.earningsThisYear : earningsThisYear // ignore: cast_nullable_to_non_nullable
as double,totalRidesCompleted: null == totalRidesCompleted ? _self.totalRidesCompleted : totalRidesCompleted // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedToday: null == ridesCompletedToday ? _self.ridesCompletedToday : ridesCompletedToday // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisWeek: null == ridesCompletedThisWeek ? _self.ridesCompletedThisWeek : ridesCompletedThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesCompletedThisMonth: null == ridesCompletedThisMonth ? _self.ridesCompletedThisMonth : ridesCompletedThisMonth // ignore: cast_nullable_to_non_nullable
as int,availableBalance: null == availableBalance ? _self.availableBalance : availableBalance // ignore: cast_nullable_to_non_nullable
as double,pendingBalance: null == pendingBalance ? _self.pendingBalance : pendingBalance // ignore: cast_nullable_to_non_nullable
as double,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPayoutDate: freezed == lastPayoutDate ? _self.lastPayoutDate : lastPayoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
