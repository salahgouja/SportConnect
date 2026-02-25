// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideRequestModel {

 String get id; String get rideId; String? get eventId; String? get eventName; String get requesterId; String get driverId; RideRequestStatus get status; LocationPoint get pickupLocation; LocationPoint get dropoffLocation; int get requestedSeats; String? get message; String? get rejectionReason;@RequiredTimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get respondedAt;@TimestampConverter() DateTime? get expiresAt; Map<String, dynamic> get metadata;// Denormalized display fields (populated by service layer)
 String? get passengerName; String? get passengerPhotoUrl; double get passengerRating; double get pricePerSeat;
/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideRequestModelCopyWith<RideRequestModel> get copyWith => _$RideRequestModelCopyWithImpl<RideRequestModel>(this as RideRequestModel, _$identity);

  /// Serializes this RideRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.requestedSeats, requestedSeats) || other.requestedSeats == requestedSeats)&&(identical(other.message, message) || other.message == message)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhotoUrl, passengerPhotoUrl) || other.passengerPhotoUrl == passengerPhotoUrl)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,eventId,eventName,requesterId,driverId,status,pickupLocation,dropoffLocation,requestedSeats,message,rejectionReason,createdAt,updatedAt,respondedAt,expiresAt,const DeepCollectionEquality().hash(metadata),passengerName,passengerPhotoUrl,passengerRating,pricePerSeat]);

@override
String toString() {
  return 'RideRequestModel(id: $id, rideId: $rideId, eventId: $eventId, eventName: $eventName, requesterId: $requesterId, driverId: $driverId, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, requestedSeats: $requestedSeats, message: $message, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt, respondedAt: $respondedAt, expiresAt: $expiresAt, metadata: $metadata, passengerName: $passengerName, passengerPhotoUrl: $passengerPhotoUrl, passengerRating: $passengerRating, pricePerSeat: $pricePerSeat)';
}


}

/// @nodoc
abstract mixin class $RideRequestModelCopyWith<$Res>  {
  factory $RideRequestModelCopyWith(RideRequestModel value, $Res Function(RideRequestModel) _then) = _$RideRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, String? eventId, String? eventName, String requesterId, String driverId, RideRequestStatus status, LocationPoint pickupLocation, LocationPoint dropoffLocation, int requestedSeats, String? message, String? rejectionReason,@RequiredTimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? respondedAt,@TimestampConverter() DateTime? expiresAt, Map<String, dynamic> metadata, String? passengerName, String? passengerPhotoUrl, double passengerRating, double pricePerSeat
});


$LocationPointCopyWith<$Res> get pickupLocation;$LocationPointCopyWith<$Res> get dropoffLocation;

}
/// @nodoc
class _$RideRequestModelCopyWithImpl<$Res>
    implements $RideRequestModelCopyWith<$Res> {
  _$RideRequestModelCopyWithImpl(this._self, this._then);

  final RideRequestModel _self;
  final $Res Function(RideRequestModel) _then;

/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? eventId = freezed,Object? eventName = freezed,Object? requesterId = null,Object? driverId = null,Object? status = null,Object? pickupLocation = null,Object? dropoffLocation = null,Object? requestedSeats = null,Object? message = freezed,Object? rejectionReason = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? respondedAt = freezed,Object? expiresAt = freezed,Object? metadata = null,Object? passengerName = freezed,Object? passengerPhotoUrl = freezed,Object? passengerRating = null,Object? pricePerSeat = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideRequestStatus,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint,dropoffLocation: null == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint,requestedSeats: null == requestedSeats ? _self.requestedSeats : requestedSeats // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,passengerPhotoUrl: freezed == passengerPhotoUrl ? _self.passengerPhotoUrl : passengerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get pickupLocation {
  
  return $LocationPointCopyWith<$Res>(_self.pickupLocation, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get dropoffLocation {
  
  return $LocationPointCopyWith<$Res>(_self.dropoffLocation, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideRequestModel].
extension RideRequestModelPatterns on RideRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _RideRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  String? eventId,  String? eventName,  String requesterId,  String driverId,  RideRequestStatus status,  LocationPoint pickupLocation,  LocationPoint dropoffLocation,  int requestedSeats,  String? message,  String? rejectionReason, @RequiredTimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? respondedAt, @TimestampConverter()  DateTime? expiresAt,  Map<String, dynamic> metadata,  String? passengerName,  String? passengerPhotoUrl,  double passengerRating,  double pricePerSeat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideRequestModel() when $default != null:
return $default(_that.id,_that.rideId,_that.eventId,_that.eventName,_that.requesterId,_that.driverId,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.requestedSeats,_that.message,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.respondedAt,_that.expiresAt,_that.metadata,_that.passengerName,_that.passengerPhotoUrl,_that.passengerRating,_that.pricePerSeat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  String? eventId,  String? eventName,  String requesterId,  String driverId,  RideRequestStatus status,  LocationPoint pickupLocation,  LocationPoint dropoffLocation,  int requestedSeats,  String? message,  String? rejectionReason, @RequiredTimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? respondedAt, @TimestampConverter()  DateTime? expiresAt,  Map<String, dynamic> metadata,  String? passengerName,  String? passengerPhotoUrl,  double passengerRating,  double pricePerSeat)  $default,) {final _that = this;
switch (_that) {
case _RideRequestModel():
return $default(_that.id,_that.rideId,_that.eventId,_that.eventName,_that.requesterId,_that.driverId,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.requestedSeats,_that.message,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.respondedAt,_that.expiresAt,_that.metadata,_that.passengerName,_that.passengerPhotoUrl,_that.passengerRating,_that.pricePerSeat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  String? eventId,  String? eventName,  String requesterId,  String driverId,  RideRequestStatus status,  LocationPoint pickupLocation,  LocationPoint dropoffLocation,  int requestedSeats,  String? message,  String? rejectionReason, @RequiredTimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? respondedAt, @TimestampConverter()  DateTime? expiresAt,  Map<String, dynamic> metadata,  String? passengerName,  String? passengerPhotoUrl,  double passengerRating,  double pricePerSeat)?  $default,) {final _that = this;
switch (_that) {
case _RideRequestModel() when $default != null:
return $default(_that.id,_that.rideId,_that.eventId,_that.eventName,_that.requesterId,_that.driverId,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.requestedSeats,_that.message,_that.rejectionReason,_that.createdAt,_that.updatedAt,_that.respondedAt,_that.expiresAt,_that.metadata,_that.passengerName,_that.passengerPhotoUrl,_that.passengerRating,_that.pricePerSeat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideRequestModel extends RideRequestModel {
  const _RideRequestModel({required this.id, required this.rideId, this.eventId, this.eventName, required this.requesterId, required this.driverId, required this.status, required this.pickupLocation, required this.dropoffLocation, required this.requestedSeats, this.message, this.rejectionReason, @RequiredTimestampConverter() required this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.respondedAt, @TimestampConverter() this.expiresAt, final  Map<String, dynamic> metadata = const {}, this.passengerName, this.passengerPhotoUrl, this.passengerRating = 0.0, this.pricePerSeat = 0.0}): _metadata = metadata,super._();
  factory _RideRequestModel.fromJson(Map<String, dynamic> json) => _$RideRequestModelFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  String? eventId;
@override final  String? eventName;
@override final  String requesterId;
@override final  String driverId;
@override final  RideRequestStatus status;
@override final  LocationPoint pickupLocation;
@override final  LocationPoint dropoffLocation;
@override final  int requestedSeats;
@override final  String? message;
@override final  String? rejectionReason;
@override@RequiredTimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? respondedAt;
@override@TimestampConverter() final  DateTime? expiresAt;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// Denormalized display fields (populated by service layer)
@override final  String? passengerName;
@override final  String? passengerPhotoUrl;
@override@JsonKey() final  double passengerRating;
@override@JsonKey() final  double pricePerSeat;

/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideRequestModelCopyWith<_RideRequestModel> get copyWith => __$RideRequestModelCopyWithImpl<_RideRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.requesterId, requesterId) || other.requesterId == requesterId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.requestedSeats, requestedSeats) || other.requestedSeats == requestedSeats)&&(identical(other.message, message) || other.message == message)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhotoUrl, passengerPhotoUrl) || other.passengerPhotoUrl == passengerPhotoUrl)&&(identical(other.passengerRating, passengerRating) || other.passengerRating == passengerRating)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,rideId,eventId,eventName,requesterId,driverId,status,pickupLocation,dropoffLocation,requestedSeats,message,rejectionReason,createdAt,updatedAt,respondedAt,expiresAt,const DeepCollectionEquality().hash(_metadata),passengerName,passengerPhotoUrl,passengerRating,pricePerSeat]);

@override
String toString() {
  return 'RideRequestModel(id: $id, rideId: $rideId, eventId: $eventId, eventName: $eventName, requesterId: $requesterId, driverId: $driverId, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, requestedSeats: $requestedSeats, message: $message, rejectionReason: $rejectionReason, createdAt: $createdAt, updatedAt: $updatedAt, respondedAt: $respondedAt, expiresAt: $expiresAt, metadata: $metadata, passengerName: $passengerName, passengerPhotoUrl: $passengerPhotoUrl, passengerRating: $passengerRating, pricePerSeat: $pricePerSeat)';
}


}

/// @nodoc
abstract mixin class _$RideRequestModelCopyWith<$Res> implements $RideRequestModelCopyWith<$Res> {
  factory _$RideRequestModelCopyWith(_RideRequestModel value, $Res Function(_RideRequestModel) _then) = __$RideRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, String? eventId, String? eventName, String requesterId, String driverId, RideRequestStatus status, LocationPoint pickupLocation, LocationPoint dropoffLocation, int requestedSeats, String? message, String? rejectionReason,@RequiredTimestampConverter() DateTime createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? respondedAt,@TimestampConverter() DateTime? expiresAt, Map<String, dynamic> metadata, String? passengerName, String? passengerPhotoUrl, double passengerRating, double pricePerSeat
});


@override $LocationPointCopyWith<$Res> get pickupLocation;@override $LocationPointCopyWith<$Res> get dropoffLocation;

}
/// @nodoc
class __$RideRequestModelCopyWithImpl<$Res>
    implements _$RideRequestModelCopyWith<$Res> {
  __$RideRequestModelCopyWithImpl(this._self, this._then);

  final _RideRequestModel _self;
  final $Res Function(_RideRequestModel) _then;

/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? eventId = freezed,Object? eventName = freezed,Object? requesterId = null,Object? driverId = null,Object? status = null,Object? pickupLocation = null,Object? dropoffLocation = null,Object? requestedSeats = null,Object? message = freezed,Object? rejectionReason = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? respondedAt = freezed,Object? expiresAt = freezed,Object? metadata = null,Object? passengerName = freezed,Object? passengerPhotoUrl = freezed,Object? passengerRating = null,Object? pricePerSeat = null,}) {
  return _then(_RideRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,requesterId: null == requesterId ? _self.requesterId : requesterId // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideRequestStatus,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint,dropoffLocation: null == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint,requestedSeats: null == requestedSeats ? _self.requestedSeats : requestedSeats // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,passengerName: freezed == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String?,passengerPhotoUrl: freezed == passengerPhotoUrl ? _self.passengerPhotoUrl : passengerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,passengerRating: null == passengerRating ? _self.passengerRating : passengerRating // ignore: cast_nullable_to_non_nullable
as double,pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get pickupLocation {
  
  return $LocationPointCopyWith<$Res>(_self.pickupLocation, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideRequestModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get dropoffLocation {
  
  return $LocationPointCopyWith<$Res>(_self.dropoffLocation, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}

// dart format on
