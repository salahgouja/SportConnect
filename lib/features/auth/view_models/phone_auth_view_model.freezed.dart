// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phone_auth_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhoneAuthState {

 String get sentPhone; int get resendCooldown;
/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhoneAuthStateCopyWith<PhoneAuthState> get copyWith => _$PhoneAuthStateCopyWithImpl<PhoneAuthState>(this as PhoneAuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhoneAuthState&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState(sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class $PhoneAuthStateCopyWith<$Res>  {
  factory $PhoneAuthStateCopyWith(PhoneAuthState value, $Res Function(PhoneAuthState) _then) = _$PhoneAuthStateCopyWithImpl;
@useResult
$Res call({
 String sentPhone, int resendCooldown
});




}
/// @nodoc
class _$PhoneAuthStateCopyWithImpl<$Res>
    implements $PhoneAuthStateCopyWith<$Res> {
  _$PhoneAuthStateCopyWithImpl(this._self, this._then);

  final PhoneAuthState _self;
  final $Res Function(PhoneAuthState) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_self.copyWith(
sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PhoneAuthState].
extension PhoneAuthStatePatterns on PhoneAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Idle value)?  idle,TResult Function( _Sending value)?  sending,TResult Function( _CodeSent value)?  codeSent,TResult Function( _Verifying value)?  verifying,TResult Function( _Verified value)?  verified,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Sending() when sending != null:
return sending(_that);case _CodeSent() when codeSent != null:
return codeSent(_that);case _Verifying() when verifying != null:
return verifying(_that);case _Verified() when verified != null:
return verified(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Idle value)  idle,required TResult Function( _Sending value)  sending,required TResult Function( _CodeSent value)  codeSent,required TResult Function( _Verifying value)  verifying,required TResult Function( _Verified value)  verified,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Idle():
return idle(_that);case _Sending():
return sending(_that);case _CodeSent():
return codeSent(_that);case _Verifying():
return verifying(_that);case _Verified():
return verified(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Idle value)?  idle,TResult? Function( _Sending value)?  sending,TResult? Function( _CodeSent value)?  codeSent,TResult? Function( _Verifying value)?  verifying,TResult? Function( _Verified value)?  verified,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that);case _Sending() when sending != null:
return sending(_that);case _CodeSent() when codeSent != null:
return codeSent(_that);case _Verifying() when verifying != null:
return verifying(_that);case _Verified() when verified != null:
return verified(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String sentPhone,  int resendCooldown)?  idle,TResult Function( String sentPhone,  int resendCooldown)?  sending,TResult Function( String verificationId,  int? resendToken,  String sentPhone,  int resendCooldown)?  codeSent,TResult Function( String sentPhone,  int resendCooldown)?  verifying,TResult Function( String sentPhone,  int resendCooldown)?  verified,TResult Function( String message,  String sentPhone,  int resendCooldown)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that.sentPhone,_that.resendCooldown);case _Sending() when sending != null:
return sending(_that.sentPhone,_that.resendCooldown);case _CodeSent() when codeSent != null:
return codeSent(_that.verificationId,_that.resendToken,_that.sentPhone,_that.resendCooldown);case _Verifying() when verifying != null:
return verifying(_that.sentPhone,_that.resendCooldown);case _Verified() when verified != null:
return verified(_that.sentPhone,_that.resendCooldown);case _Error() when error != null:
return error(_that.message,_that.sentPhone,_that.resendCooldown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String sentPhone,  int resendCooldown)  idle,required TResult Function( String sentPhone,  int resendCooldown)  sending,required TResult Function( String verificationId,  int? resendToken,  String sentPhone,  int resendCooldown)  codeSent,required TResult Function( String sentPhone,  int resendCooldown)  verifying,required TResult Function( String sentPhone,  int resendCooldown)  verified,required TResult Function( String message,  String sentPhone,  int resendCooldown)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle(_that.sentPhone,_that.resendCooldown);case _Sending():
return sending(_that.sentPhone,_that.resendCooldown);case _CodeSent():
return codeSent(_that.verificationId,_that.resendToken,_that.sentPhone,_that.resendCooldown);case _Verifying():
return verifying(_that.sentPhone,_that.resendCooldown);case _Verified():
return verified(_that.sentPhone,_that.resendCooldown);case _Error():
return error(_that.message,_that.sentPhone,_that.resendCooldown);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String sentPhone,  int resendCooldown)?  idle,TResult? Function( String sentPhone,  int resendCooldown)?  sending,TResult? Function( String verificationId,  int? resendToken,  String sentPhone,  int resendCooldown)?  codeSent,TResult? Function( String sentPhone,  int resendCooldown)?  verifying,TResult? Function( String sentPhone,  int resendCooldown)?  verified,TResult? Function( String message,  String sentPhone,  int resendCooldown)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle(_that.sentPhone,_that.resendCooldown);case _Sending() when sending != null:
return sending(_that.sentPhone,_that.resendCooldown);case _CodeSent() when codeSent != null:
return codeSent(_that.verificationId,_that.resendToken,_that.sentPhone,_that.resendCooldown);case _Verifying() when verifying != null:
return verifying(_that.sentPhone,_that.resendCooldown);case _Verified() when verified != null:
return verified(_that.sentPhone,_that.resendCooldown);case _Error() when error != null:
return error(_that.message,_that.sentPhone,_that.resendCooldown);case _:
  return null;

}
}

}

/// @nodoc


class _Idle extends PhoneAuthState {
  const _Idle({this.sentPhone = '', this.resendCooldown = 0}): super._();
  

@override@JsonKey() final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdleCopyWith<_Idle> get copyWith => __$IdleCopyWithImpl<_Idle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.idle(sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$IdleCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$IdleCopyWith(_Idle value, $Res Function(_Idle) _then) = __$IdleCopyWithImpl;
@override @useResult
$Res call({
 String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$IdleCopyWithImpl<$Res>
    implements _$IdleCopyWith<$Res> {
  __$IdleCopyWithImpl(this._self, this._then);

  final _Idle _self;
  final $Res Function(_Idle) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_Idle(
sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Sending extends PhoneAuthState {
  const _Sending({this.sentPhone = '', this.resendCooldown = 0}): super._();
  

@override@JsonKey() final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendingCopyWith<_Sending> get copyWith => __$SendingCopyWithImpl<_Sending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sending&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.sending(sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$SendingCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$SendingCopyWith(_Sending value, $Res Function(_Sending) _then) = __$SendingCopyWithImpl;
@override @useResult
$Res call({
 String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$SendingCopyWithImpl<$Res>
    implements _$SendingCopyWith<$Res> {
  __$SendingCopyWithImpl(this._self, this._then);

  final _Sending _self;
  final $Res Function(_Sending) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_Sending(
sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _CodeSent extends PhoneAuthState {
  const _CodeSent({required this.verificationId, this.resendToken, required this.sentPhone, this.resendCooldown = 0}): super._();
  

 final  String verificationId;
 final  int? resendToken;
@override final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeSentCopyWith<_CodeSent> get copyWith => __$CodeSentCopyWithImpl<_CodeSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeSent&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.resendToken, resendToken) || other.resendToken == resendToken)&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,verificationId,resendToken,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.codeSent(verificationId: $verificationId, resendToken: $resendToken, sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$CodeSentCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$CodeSentCopyWith(_CodeSent value, $Res Function(_CodeSent) _then) = __$CodeSentCopyWithImpl;
@override @useResult
$Res call({
 String verificationId, int? resendToken, String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$CodeSentCopyWithImpl<$Res>
    implements _$CodeSentCopyWith<$Res> {
  __$CodeSentCopyWithImpl(this._self, this._then);

  final _CodeSent _self;
  final $Res Function(_CodeSent) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verificationId = null,Object? resendToken = freezed,Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_CodeSent(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,resendToken: freezed == resendToken ? _self.resendToken : resendToken // ignore: cast_nullable_to_non_nullable
as int?,sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Verifying extends PhoneAuthState {
  const _Verifying({this.sentPhone = '', this.resendCooldown = 0}): super._();
  

@override@JsonKey() final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyingCopyWith<_Verifying> get copyWith => __$VerifyingCopyWithImpl<_Verifying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verifying&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.verifying(sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$VerifyingCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$VerifyingCopyWith(_Verifying value, $Res Function(_Verifying) _then) = __$VerifyingCopyWithImpl;
@override @useResult
$Res call({
 String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$VerifyingCopyWithImpl<$Res>
    implements _$VerifyingCopyWith<$Res> {
  __$VerifyingCopyWithImpl(this._self, this._then);

  final _Verifying _self;
  final $Res Function(_Verifying) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_Verifying(
sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Verified extends PhoneAuthState {
  const _Verified({this.sentPhone = '', this.resendCooldown = 0}): super._();
  

@override@JsonKey() final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifiedCopyWith<_Verified> get copyWith => __$VerifiedCopyWithImpl<_Verified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verified&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.verified(sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$VerifiedCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$VerifiedCopyWith(_Verified value, $Res Function(_Verified) _then) = __$VerifiedCopyWithImpl;
@override @useResult
$Res call({
 String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$VerifiedCopyWithImpl<$Res>
    implements _$VerifiedCopyWith<$Res> {
  __$VerifiedCopyWithImpl(this._self, this._then);

  final _Verified _self;
  final $Res Function(_Verified) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_Verified(
sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Error extends PhoneAuthState {
  const _Error(this.message, {this.sentPhone = '', this.resendCooldown = 0}): super._();
  

 final  String message;
@override@JsonKey() final  String sentPhone;
@override@JsonKey() final  int resendCooldown;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message)&&(identical(other.sentPhone, sentPhone) || other.sentPhone == sentPhone)&&(identical(other.resendCooldown, resendCooldown) || other.resendCooldown == resendCooldown));
}


@override
int get hashCode => Object.hash(runtimeType,message,sentPhone,resendCooldown);

@override
String toString() {
  return 'PhoneAuthState.error(message: $message, sentPhone: $sentPhone, resendCooldown: $resendCooldown)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@override @useResult
$Res call({
 String message, String sentPhone, int resendCooldown
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? sentPhone = null,Object? resendCooldown = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sentPhone: null == sentPhone ? _self.sentPhone : sentPhone // ignore: cast_nullable_to_non_nullable
as String,resendCooldown: null == resendCooldown ? _self.resendCooldown : resendCooldown // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
