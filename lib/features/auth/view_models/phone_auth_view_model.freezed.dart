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





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhoneAuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhoneAuthState()';
}


}

/// @nodoc
class $PhoneAuthStateCopyWith<$Res>  {
$PhoneAuthStateCopyWith(PhoneAuthState _, $Res Function(PhoneAuthState) __);
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
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  sending,TResult Function( String verificationId,  int? resendToken)?  codeSent,TResult Function()?  verifying,TResult Function()?  verified,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Sending() when sending != null:
return sending();case _CodeSent() when codeSent != null:
return codeSent(_that.verificationId,_that.resendToken);case _Verifying() when verifying != null:
return verifying();case _Verified() when verified != null:
return verified();case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  sending,required TResult Function( String verificationId,  int? resendToken)  codeSent,required TResult Function()  verifying,required TResult Function()  verified,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Idle():
return idle();case _Sending():
return sending();case _CodeSent():
return codeSent(_that.verificationId,_that.resendToken);case _Verifying():
return verifying();case _Verified():
return verified();case _Error():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  sending,TResult? Function( String verificationId,  int? resendToken)?  codeSent,TResult? Function()?  verifying,TResult? Function()?  verified,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Idle() when idle != null:
return idle();case _Sending() when sending != null:
return sending();case _CodeSent() when codeSent != null:
return codeSent(_that.verificationId,_that.resendToken);case _Verifying() when verifying != null:
return verifying();case _Verified() when verified != null:
return verified();case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Idle implements PhoneAuthState {
  const _Idle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Idle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhoneAuthState.idle()';
}


}




/// @nodoc


class _Sending implements PhoneAuthState {
  const _Sending();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhoneAuthState.sending()';
}


}




/// @nodoc


class _CodeSent implements PhoneAuthState {
  const _CodeSent({required this.verificationId, this.resendToken});
  

 final  String verificationId;
 final  int? resendToken;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeSentCopyWith<_CodeSent> get copyWith => __$CodeSentCopyWithImpl<_CodeSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeSent&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.resendToken, resendToken) || other.resendToken == resendToken));
}


@override
int get hashCode => Object.hash(runtimeType,verificationId,resendToken);

@override
String toString() {
  return 'PhoneAuthState.codeSent(verificationId: $verificationId, resendToken: $resendToken)';
}


}

/// @nodoc
abstract mixin class _$CodeSentCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$CodeSentCopyWith(_CodeSent value, $Res Function(_CodeSent) _then) = __$CodeSentCopyWithImpl;
@useResult
$Res call({
 String verificationId, int? resendToken
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
@pragma('vm:prefer-inline') $Res call({Object? verificationId = null,Object? resendToken = freezed,}) {
  return _then(_CodeSent(
verificationId: null == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String,resendToken: freezed == resendToken ? _self.resendToken : resendToken // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _Verifying implements PhoneAuthState {
  const _Verifying();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verifying);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhoneAuthState.verifying()';
}


}




/// @nodoc


class _Verified implements PhoneAuthState {
  const _Verified();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verified);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhoneAuthState.verified()';
}


}




/// @nodoc


class _Error implements PhoneAuthState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of PhoneAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PhoneAuthState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $PhoneAuthStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
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
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
