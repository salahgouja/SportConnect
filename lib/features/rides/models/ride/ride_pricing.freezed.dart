// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_pricing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RidePricing {

 Money get pricePerSeat; bool get isNegotiable; bool get acceptsOnlinePayment;
/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RidePricingCopyWith<RidePricing> get copyWith => _$RidePricingCopyWithImpl<RidePricing>(this as RidePricing, _$identity);

  /// Serializes this RidePricing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RidePricing&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.isNegotiable, isNegotiable) || other.isNegotiable == isNegotiable)&&(identical(other.acceptsOnlinePayment, acceptsOnlinePayment) || other.acceptsOnlinePayment == acceptsOnlinePayment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricePerSeat,isNegotiable,acceptsOnlinePayment);

@override
String toString() {
  return 'RidePricing(pricePerSeat: $pricePerSeat, isNegotiable: $isNegotiable, acceptsOnlinePayment: $acceptsOnlinePayment)';
}


}

/// @nodoc
abstract mixin class $RidePricingCopyWith<$Res>  {
  factory $RidePricingCopyWith(RidePricing value, $Res Function(RidePricing) _then) = _$RidePricingCopyWithImpl;
@useResult
$Res call({
 Money pricePerSeat, bool isNegotiable, bool acceptsOnlinePayment
});


$MoneyCopyWith<$Res> get pricePerSeat;

}
/// @nodoc
class _$RidePricingCopyWithImpl<$Res>
    implements $RidePricingCopyWith<$Res> {
  _$RidePricingCopyWithImpl(this._self, this._then);

  final RidePricing _self;
  final $Res Function(RidePricing) _then;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pricePerSeat = null,Object? isNegotiable = null,Object? acceptsOnlinePayment = null,}) {
  return _then(_self.copyWith(
pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as Money,isNegotiable: null == isNegotiable ? _self.isNegotiable : isNegotiable // ignore: cast_nullable_to_non_nullable
as bool,acceptsOnlinePayment: null == acceptsOnlinePayment ? _self.acceptsOnlinePayment : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get pricePerSeat {
  
  return $MoneyCopyWith<$Res>(_self.pricePerSeat, (value) {
    return _then(_self.copyWith(pricePerSeat: value));
  });
}
}


/// Adds pattern-matching-related methods to [RidePricing].
extension RidePricingPatterns on RidePricing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RidePricing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RidePricing value)  $default,){
final _that = this;
switch (_that) {
case _RidePricing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RidePricing value)?  $default,){
final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money pricePerSeat,  bool isNegotiable,  bool acceptsOnlinePayment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
return $default(_that.pricePerSeat,_that.isNegotiable,_that.acceptsOnlinePayment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money pricePerSeat,  bool isNegotiable,  bool acceptsOnlinePayment)  $default,) {final _that = this;
switch (_that) {
case _RidePricing():
return $default(_that.pricePerSeat,_that.isNegotiable,_that.acceptsOnlinePayment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money pricePerSeat,  bool isNegotiable,  bool acceptsOnlinePayment)?  $default,) {final _that = this;
switch (_that) {
case _RidePricing() when $default != null:
return $default(_that.pricePerSeat,_that.isNegotiable,_that.acceptsOnlinePayment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RidePricing extends RidePricing {
  const _RidePricing({required this.pricePerSeat, this.isNegotiable = false, this.acceptsOnlinePayment = false}): super._();
  factory _RidePricing.fromJson(Map<String, dynamic> json) => _$RidePricingFromJson(json);

@override final  Money pricePerSeat;
@override@JsonKey() final  bool isNegotiable;
@override@JsonKey() final  bool acceptsOnlinePayment;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RidePricingCopyWith<_RidePricing> get copyWith => __$RidePricingCopyWithImpl<_RidePricing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RidePricingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RidePricing&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.isNegotiable, isNegotiable) || other.isNegotiable == isNegotiable)&&(identical(other.acceptsOnlinePayment, acceptsOnlinePayment) || other.acceptsOnlinePayment == acceptsOnlinePayment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pricePerSeat,isNegotiable,acceptsOnlinePayment);

@override
String toString() {
  return 'RidePricing(pricePerSeat: $pricePerSeat, isNegotiable: $isNegotiable, acceptsOnlinePayment: $acceptsOnlinePayment)';
}


}

/// @nodoc
abstract mixin class _$RidePricingCopyWith<$Res> implements $RidePricingCopyWith<$Res> {
  factory _$RidePricingCopyWith(_RidePricing value, $Res Function(_RidePricing) _then) = __$RidePricingCopyWithImpl;
@override @useResult
$Res call({
 Money pricePerSeat, bool isNegotiable, bool acceptsOnlinePayment
});


@override $MoneyCopyWith<$Res> get pricePerSeat;

}
/// @nodoc
class __$RidePricingCopyWithImpl<$Res>
    implements _$RidePricingCopyWith<$Res> {
  __$RidePricingCopyWithImpl(this._self, this._then);

  final _RidePricing _self;
  final $Res Function(_RidePricing) _then;

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pricePerSeat = null,Object? isNegotiable = null,Object? acceptsOnlinePayment = null,}) {
  return _then(_RidePricing(
pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as Money,isNegotiable: null == isNegotiable ? _self.isNegotiable : isNegotiable // ignore: cast_nullable_to_non_nullable
as bool,acceptsOnlinePayment: null == acceptsOnlinePayment ? _self.acceptsOnlinePayment : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RidePricing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MoneyCopyWith<$Res> get pricePerSeat {
  
  return $MoneyCopyWith<$Res>(_self.pricePerSeat, (value) {
    return _then(_self.copyWith(pricePerSeat: value));
  });
}
}

// dart format on
