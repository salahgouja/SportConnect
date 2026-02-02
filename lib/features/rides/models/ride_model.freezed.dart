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
mixin _$LocationPoint {

 String get address; double get latitude; double get longitude; String? get placeId; String? get city;
/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationPointCopyWith<LocationPoint> get copyWith => _$LocationPointCopyWithImpl<LocationPoint>(this as LocationPoint, _$identity);

  /// Serializes this LocationPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationPoint&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude,placeId,city);

@override
String toString() {
  return 'LocationPoint(address: $address, latitude: $latitude, longitude: $longitude, placeId: $placeId, city: $city)';
}


}

/// @nodoc
abstract mixin class $LocationPointCopyWith<$Res>  {
  factory $LocationPointCopyWith(LocationPoint value, $Res Function(LocationPoint) _then) = _$LocationPointCopyWithImpl;
@useResult
$Res call({
 String address, double latitude, double longitude, String? placeId, String? city
});




}
/// @nodoc
class _$LocationPointCopyWithImpl<$Res>
    implements $LocationPointCopyWith<$Res> {
  _$LocationPointCopyWithImpl(this._self, this._then);

  final LocationPoint _self;
  final $Res Function(LocationPoint) _then;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,Object? placeId = freezed,Object? city = freezed,}) {
  return _then(_self.copyWith(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationPoint].
extension LocationPointPatterns on LocationPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationPoint value)  $default,){
final _that = this;
switch (_that) {
case _LocationPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationPoint value)?  $default,){
final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude,  String? placeId,  String? city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude,_that.placeId,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String address,  double latitude,  double longitude,  String? placeId,  String? city)  $default,) {final _that = this;
switch (_that) {
case _LocationPoint():
return $default(_that.address,_that.latitude,_that.longitude,_that.placeId,_that.city);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String address,  double latitude,  double longitude,  String? placeId,  String? city)?  $default,) {final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
return $default(_that.address,_that.latitude,_that.longitude,_that.placeId,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationPoint implements LocationPoint {
  const _LocationPoint({required this.address, required this.latitude, required this.longitude, this.placeId, this.city});
  factory _LocationPoint.fromJson(Map<String, dynamic> json) => _$LocationPointFromJson(json);

@override final  String address;
@override final  double latitude;
@override final  double longitude;
@override final  String? placeId;
@override final  String? city;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationPointCopyWith<_LocationPoint> get copyWith => __$LocationPointCopyWithImpl<_LocationPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationPoint&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,address,latitude,longitude,placeId,city);

@override
String toString() {
  return 'LocationPoint(address: $address, latitude: $latitude, longitude: $longitude, placeId: $placeId, city: $city)';
}


}

/// @nodoc
abstract mixin class _$LocationPointCopyWith<$Res> implements $LocationPointCopyWith<$Res> {
  factory _$LocationPointCopyWith(_LocationPoint value, $Res Function(_LocationPoint) _then) = __$LocationPointCopyWithImpl;
@override @useResult
$Res call({
 String address, double latitude, double longitude, String? placeId, String? city
});




}
/// @nodoc
class __$LocationPointCopyWithImpl<$Res>
    implements _$LocationPointCopyWith<$Res> {
  __$LocationPointCopyWithImpl(this._self, this._then);

  final _LocationPoint _self;
  final $Res Function(_LocationPoint) _then;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? latitude = null,Object? longitude = null,Object? placeId = freezed,Object? city = freezed,}) {
  return _then(_LocationPoint(
address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RouteWaypoint {

 LocationPoint get location; int get order;@TimestampConverter() DateTime? get estimatedArrival;
/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteWaypointCopyWith<RouteWaypoint> get copyWith => _$RouteWaypointCopyWithImpl<RouteWaypoint>(this as RouteWaypoint, _$identity);

  /// Serializes this RouteWaypoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteWaypoint&&(identical(other.location, location) || other.location == location)&&(identical(other.order, order) || other.order == order)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,order,estimatedArrival);

@override
String toString() {
  return 'RouteWaypoint(location: $location, order: $order, estimatedArrival: $estimatedArrival)';
}


}

/// @nodoc
abstract mixin class $RouteWaypointCopyWith<$Res>  {
  factory $RouteWaypointCopyWith(RouteWaypoint value, $Res Function(RouteWaypoint) _then) = _$RouteWaypointCopyWithImpl;
@useResult
$Res call({
 LocationPoint location, int order,@TimestampConverter() DateTime? estimatedArrival
});


$LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class _$RouteWaypointCopyWithImpl<$Res>
    implements $RouteWaypointCopyWith<$Res> {
  _$RouteWaypointCopyWithImpl(this._self, this._then);

  final RouteWaypoint _self;
  final $Res Function(RouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? order = null,Object? estimatedArrival = freezed,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteWaypoint].
extension RouteWaypointPatterns on RouteWaypoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteWaypoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteWaypoint value)  $default,){
final _that = this;
switch (_that) {
case _RouteWaypoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteWaypoint value)?  $default,){
final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)  $default,) {final _that = this;
switch (_that) {
case _RouteWaypoint():
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPoint location,  int order, @TimestampConverter()  DateTime? estimatedArrival)?  $default,) {final _that = this;
switch (_that) {
case _RouteWaypoint() when $default != null:
return $default(_that.location,_that.order,_that.estimatedArrival);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteWaypoint implements RouteWaypoint {
  const _RouteWaypoint({required this.location, this.order = 0, @TimestampConverter() this.estimatedArrival});
  factory _RouteWaypoint.fromJson(Map<String, dynamic> json) => _$RouteWaypointFromJson(json);

@override final  LocationPoint location;
@override@JsonKey() final  int order;
@override@TimestampConverter() final  DateTime? estimatedArrival;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteWaypointCopyWith<_RouteWaypoint> get copyWith => __$RouteWaypointCopyWithImpl<_RouteWaypoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteWaypointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteWaypoint&&(identical(other.location, location) || other.location == location)&&(identical(other.order, order) || other.order == order)&&(identical(other.estimatedArrival, estimatedArrival) || other.estimatedArrival == estimatedArrival));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,order,estimatedArrival);

@override
String toString() {
  return 'RouteWaypoint(location: $location, order: $order, estimatedArrival: $estimatedArrival)';
}


}

/// @nodoc
abstract mixin class _$RouteWaypointCopyWith<$Res> implements $RouteWaypointCopyWith<$Res> {
  factory _$RouteWaypointCopyWith(_RouteWaypoint value, $Res Function(_RouteWaypoint) _then) = __$RouteWaypointCopyWithImpl;
@override @useResult
$Res call({
 LocationPoint location, int order,@TimestampConverter() DateTime? estimatedArrival
});


@override $LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class __$RouteWaypointCopyWithImpl<$Res>
    implements _$RouteWaypointCopyWith<$Res> {
  __$RouteWaypointCopyWithImpl(this._self, this._then);

  final _RouteWaypoint _self;
  final $Res Function(_RouteWaypoint) _then;

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? order = null,Object? estimatedArrival = freezed,}) {
  return _then(_RouteWaypoint(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,estimatedArrival: freezed == estimatedArrival ? _self.estimatedArrival : estimatedArrival // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RouteWaypoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$RideBooking {

 String get id; String get passengerId; String get passengerName; String? get passengerPhotoUrl; int get seatsBooked; BookingStatus get status; LocationPoint? get pickupLocation; LocationPoint? get dropoffLocation; String? get note;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get respondedAt;
/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideBookingCopyWith<RideBooking> get copyWith => _$RideBookingCopyWithImpl<RideBooking>(this as RideBooking, _$identity);

  /// Serializes this RideBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhotoUrl, passengerPhotoUrl) || other.passengerPhotoUrl == passengerPhotoUrl)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,passengerId,passengerName,passengerPhotoUrl,seatsBooked,status,pickupLocation,dropoffLocation,note,createdAt,respondedAt);

@override
String toString() {
  return 'RideBooking(id: $id, passengerId: $passengerId, passengerName: $passengerName, passengerPhotoUrl: $passengerPhotoUrl, seatsBooked: $seatsBooked, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, note: $note, createdAt: $createdAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $RideBookingCopyWith<$Res>  {
  factory $RideBookingCopyWith(RideBooking value, $Res Function(RideBooking) _then) = _$RideBookingCopyWithImpl;
@useResult
$Res call({
 String id, String passengerId, String passengerName, String? passengerPhotoUrl, int seatsBooked, BookingStatus status, LocationPoint? pickupLocation, LocationPoint? dropoffLocation, String? note,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? respondedAt
});


$LocationPointCopyWith<$Res>? get pickupLocation;$LocationPointCopyWith<$Res>? get dropoffLocation;

}
/// @nodoc
class _$RideBookingCopyWithImpl<$Res>
    implements $RideBookingCopyWith<$Res> {
  _$RideBookingCopyWithImpl(this._self, this._then);

  final RideBooking _self;
  final $Res Function(RideBooking) _then;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? passengerId = null,Object? passengerName = null,Object? passengerPhotoUrl = freezed,Object? seatsBooked = null,Object? status = null,Object? pickupLocation = freezed,Object? dropoffLocation = freezed,Object? note = freezed,Object? createdAt = freezed,Object? respondedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhotoUrl: freezed == passengerPhotoUrl ? _self.passengerPhotoUrl : passengerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: null == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get dropoffLocation {
    if (_self.dropoffLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.dropoffLocation!, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideBooking].
extension RideBookingPatterns on RideBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideBooking value)  $default,){
final _that = this;
switch (_that) {
case _RideBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideBooking value)?  $default,){
final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String passengerId,  String passengerName,  String? passengerPhotoUrl,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
return $default(_that.id,_that.passengerId,_that.passengerName,_that.passengerPhotoUrl,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String passengerId,  String passengerName,  String? passengerPhotoUrl,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt)  $default,) {final _that = this;
switch (_that) {
case _RideBooking():
return $default(_that.id,_that.passengerId,_that.passengerName,_that.passengerPhotoUrl,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String passengerId,  String passengerName,  String? passengerPhotoUrl,  int seatsBooked,  BookingStatus status,  LocationPoint? pickupLocation,  LocationPoint? dropoffLocation,  String? note, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _RideBooking() when $default != null:
return $default(_that.id,_that.passengerId,_that.passengerName,_that.passengerPhotoUrl,_that.seatsBooked,_that.status,_that.pickupLocation,_that.dropoffLocation,_that.note,_that.createdAt,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideBooking implements RideBooking {
  const _RideBooking({required this.id, required this.passengerId, this.passengerName = 'Unknown Passenger', this.passengerPhotoUrl, this.seatsBooked = 1, this.status = BookingStatus.pending, this.pickupLocation, this.dropoffLocation, this.note, @TimestampConverter() this.createdAt, @TimestampConverter() this.respondedAt});
  factory _RideBooking.fromJson(Map<String, dynamic> json) => _$RideBookingFromJson(json);

@override final  String id;
@override final  String passengerId;
@override@JsonKey() final  String passengerName;
@override final  String? passengerPhotoUrl;
@override@JsonKey() final  int seatsBooked;
@override@JsonKey() final  BookingStatus status;
@override final  LocationPoint? pickupLocation;
@override final  LocationPoint? dropoffLocation;
@override final  String? note;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? respondedAt;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideBookingCopyWith<_RideBooking> get copyWith => __$RideBookingCopyWithImpl<_RideBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.passengerId, passengerId) || other.passengerId == passengerId)&&(identical(other.passengerName, passengerName) || other.passengerName == passengerName)&&(identical(other.passengerPhotoUrl, passengerPhotoUrl) || other.passengerPhotoUrl == passengerPhotoUrl)&&(identical(other.seatsBooked, seatsBooked) || other.seatsBooked == seatsBooked)&&(identical(other.status, status) || other.status == status)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropoffLocation, dropoffLocation) || other.dropoffLocation == dropoffLocation)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,passengerId,passengerName,passengerPhotoUrl,seatsBooked,status,pickupLocation,dropoffLocation,note,createdAt,respondedAt);

@override
String toString() {
  return 'RideBooking(id: $id, passengerId: $passengerId, passengerName: $passengerName, passengerPhotoUrl: $passengerPhotoUrl, seatsBooked: $seatsBooked, status: $status, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, note: $note, createdAt: $createdAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$RideBookingCopyWith<$Res> implements $RideBookingCopyWith<$Res> {
  factory _$RideBookingCopyWith(_RideBooking value, $Res Function(_RideBooking) _then) = __$RideBookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String passengerId, String passengerName, String? passengerPhotoUrl, int seatsBooked, BookingStatus status, LocationPoint? pickupLocation, LocationPoint? dropoffLocation, String? note,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? respondedAt
});


@override $LocationPointCopyWith<$Res>? get pickupLocation;@override $LocationPointCopyWith<$Res>? get dropoffLocation;

}
/// @nodoc
class __$RideBookingCopyWithImpl<$Res>
    implements _$RideBookingCopyWith<$Res> {
  __$RideBookingCopyWithImpl(this._self, this._then);

  final _RideBooking _self;
  final $Res Function(_RideBooking) _then;

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? passengerId = null,Object? passengerName = null,Object? passengerPhotoUrl = freezed,Object? seatsBooked = null,Object? status = null,Object? pickupLocation = freezed,Object? dropoffLocation = freezed,Object? note = freezed,Object? createdAt = freezed,Object? respondedAt = freezed,}) {
  return _then(_RideBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,passengerId: null == passengerId ? _self.passengerId : passengerId // ignore: cast_nullable_to_non_nullable
as String,passengerName: null == passengerName ? _self.passengerName : passengerName // ignore: cast_nullable_to_non_nullable
as String,passengerPhotoUrl: freezed == passengerPhotoUrl ? _self.passengerPhotoUrl : passengerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,seatsBooked: null == seatsBooked ? _self.seatsBooked : seatsBooked // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,dropoffLocation: freezed == dropoffLocation ? _self.dropoffLocation : dropoffLocation // ignore: cast_nullable_to_non_nullable
as LocationPoint?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get pickupLocation {
    if (_self.pickupLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.pickupLocation!, (value) {
    return _then(_self.copyWith(pickupLocation: value));
  });
}/// Create a copy of RideBooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get dropoffLocation {
    if (_self.dropoffLocation == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.dropoffLocation!, (value) {
    return _then(_self.copyWith(dropoffLocation: value));
  });
}
}


/// @nodoc
mixin _$RideReview {

 String get id; String get reviewerId; String get reviewerName; String? get reviewerPhotoUrl; String get revieweeId; double get rating; String? get comment; List<String> get tags;@TimestampConverter() DateTime? get createdAt;
/// Create a copy of RideReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideReviewCopyWith<RideReview> get copyWith => _$RideReviewCopyWithImpl<RideReview>(this as RideReview, _$identity);

  /// Serializes this RideReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideReview&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewerId,reviewerName,reviewerPhotoUrl,revieweeId,rating,comment,const DeepCollectionEquality().hash(tags),createdAt);

@override
String toString() {
  return 'RideReview(id: $id, reviewerId: $reviewerId, reviewerName: $reviewerName, reviewerPhotoUrl: $reviewerPhotoUrl, revieweeId: $revieweeId, rating: $rating, comment: $comment, tags: $tags, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RideReviewCopyWith<$Res>  {
  factory $RideReviewCopyWith(RideReview value, $Res Function(RideReview) _then) = _$RideReviewCopyWithImpl;
@useResult
$Res call({
 String id, String reviewerId, String reviewerName, String? reviewerPhotoUrl, String revieweeId, double rating, String? comment, List<String> tags,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$RideReviewCopyWithImpl<$Res>
    implements $RideReviewCopyWith<$Res> {
  _$RideReviewCopyWithImpl(this._self, this._then);

  final RideReview _self;
  final $Res Function(RideReview) _then;

/// Create a copy of RideReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reviewerId = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? revieweeId = null,Object? rating = null,Object? comment = freezed,Object? tags = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RideReview].
extension RideReviewPatterns on RideReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideReview value)  $default,){
final _that = this;
switch (_that) {
case _RideReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideReview value)?  $default,){
final _that = this;
switch (_that) {
case _RideReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  String revieweeId,  double rating,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideReview() when $default != null:
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.revieweeId,_that.rating,_that.comment,_that.tags,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  String revieweeId,  double rating,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RideReview():
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.revieweeId,_that.rating,_that.comment,_that.tags,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reviewerId,  String reviewerName,  String? reviewerPhotoUrl,  String revieweeId,  double rating,  String? comment,  List<String> tags, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RideReview() when $default != null:
return $default(_that.id,_that.reviewerId,_that.reviewerName,_that.reviewerPhotoUrl,_that.revieweeId,_that.rating,_that.comment,_that.tags,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideReview implements RideReview {
  const _RideReview({required this.id, required this.reviewerId, required this.reviewerName, this.reviewerPhotoUrl, required this.revieweeId, required this.rating, this.comment, final  List<String> tags = const [], @TimestampConverter() this.createdAt}): _tags = tags;
  factory _RideReview.fromJson(Map<String, dynamic> json) => _$RideReviewFromJson(json);

@override final  String id;
@override final  String reviewerId;
@override final  String reviewerName;
@override final  String? reviewerPhotoUrl;
@override final  String revieweeId;
@override final  double rating;
@override final  String? comment;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of RideReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideReviewCopyWith<_RideReview> get copyWith => __$RideReviewCopyWithImpl<_RideReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideReview&&(identical(other.id, id) || other.id == id)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerPhotoUrl, reviewerPhotoUrl) || other.reviewerPhotoUrl == reviewerPhotoUrl)&&(identical(other.revieweeId, revieweeId) || other.revieweeId == revieweeId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reviewerId,reviewerName,reviewerPhotoUrl,revieweeId,rating,comment,const DeepCollectionEquality().hash(_tags),createdAt);

@override
String toString() {
  return 'RideReview(id: $id, reviewerId: $reviewerId, reviewerName: $reviewerName, reviewerPhotoUrl: $reviewerPhotoUrl, revieweeId: $revieweeId, rating: $rating, comment: $comment, tags: $tags, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RideReviewCopyWith<$Res> implements $RideReviewCopyWith<$Res> {
  factory _$RideReviewCopyWith(_RideReview value, $Res Function(_RideReview) _then) = __$RideReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String reviewerId, String reviewerName, String? reviewerPhotoUrl, String revieweeId, double rating, String? comment, List<String> tags,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$RideReviewCopyWithImpl<$Res>
    implements _$RideReviewCopyWith<$Res> {
  __$RideReviewCopyWithImpl(this._self, this._then);

  final _RideReview _self;
  final $Res Function(_RideReview) _then;

/// Create a copy of RideReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reviewerId = null,Object? reviewerName = null,Object? reviewerPhotoUrl = freezed,Object? revieweeId = null,Object? rating = null,Object? comment = freezed,Object? tags = null,Object? createdAt = freezed,}) {
  return _then(_RideReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerPhotoUrl: freezed == reviewerPhotoUrl ? _self.reviewerPhotoUrl : reviewerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,revieweeId: null == revieweeId ? _self.revieweeId : revieweeId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RideModel {

 String get id; String get driverId; String get driverName; String? get driverPhotoUrl; double? get driverRating;// Route information
 LocationPoint get origin; LocationPoint get destination; List<RouteWaypoint> get waypoints;// Route details
 double? get distanceKm; int? get durationMinutes; String? get polylineEncoded;// Timing
@RequiredTimestampConverter() DateTime get departureTime;@TimestampConverter() DateTime? get arrivalTime; int get flexibilityMinutes;// Capacity
 int get availableSeats; int get bookedSeats;// Pricing
 double get pricePerSeat; String? get currency; bool get isPriceNegotiable; bool get acceptsOnlinePayment;// Driver has Stripe connected
// Status
 RideStatus get status;// Preferences
 bool get allowPets; bool get allowSmoking; bool get allowLuggage; bool get isWomenOnly; bool get allowChat; int? get maxDetourMinutes;// Vehicle
 String? get vehicleId; String? get vehicleInfo;// Bookings
 List<RideBooking> get bookings;// Reviews
 List<RideReview> get reviews;// Recurrence (for regular commutes)
 bool get isRecurring; List<int> get recurringDays;@TimestampConverter() DateTime? get recurringEndDate;// XP Rewards
 int get xpReward;// Metadata
 String? get notes; List<String> get tags;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideModelCopyWith<RideModel> get copyWith => _$RideModelCopyWithImpl<RideModel>(this as RideModel, _$identity);

  /// Serializes this RideModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhotoUrl, driverPhotoUrl) || other.driverPhotoUrl == driverPhotoUrl)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other.waypoints, waypoints)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.polylineEncoded, polylineEncoded) || other.polylineEncoded == polylineEncoded)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.flexibilityMinutes, flexibilityMinutes) || other.flexibilityMinutes == flexibilityMinutes)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.bookedSeats, bookedSeats) || other.bookedSeats == bookedSeats)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isPriceNegotiable, isPriceNegotiable) || other.isPriceNegotiable == isPriceNegotiable)&&(identical(other.acceptsOnlinePayment, acceptsOnlinePayment) || other.acceptsOnlinePayment == acceptsOnlinePayment)&&(identical(other.status, status) || other.status == status)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.allowLuggage, allowLuggage) || other.allowLuggage == allowLuggage)&&(identical(other.isWomenOnly, isWomenOnly) || other.isWomenOnly == isWomenOnly)&&(identical(other.allowChat, allowChat) || other.allowChat == allowChat)&&(identical(other.maxDetourMinutes, maxDetourMinutes) || other.maxDetourMinutes == maxDetourMinutes)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&const DeepCollectionEquality().equals(other.bookings, bookings)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,driverName,driverPhotoUrl,driverRating,origin,destination,const DeepCollectionEquality().hash(waypoints),distanceKm,durationMinutes,polylineEncoded,departureTime,arrivalTime,flexibilityMinutes,availableSeats,bookedSeats,pricePerSeat,currency,isPriceNegotiable,acceptsOnlinePayment,status,allowPets,allowSmoking,allowLuggage,isWomenOnly,allowChat,maxDetourMinutes,vehicleId,vehicleInfo,const DeepCollectionEquality().hash(bookings),const DeepCollectionEquality().hash(reviews),isRecurring,const DeepCollectionEquality().hash(recurringDays),recurringEndDate,xpReward,notes,const DeepCollectionEquality().hash(tags),createdAt,updatedAt]);

@override
String toString() {
  return 'RideModel(id: $id, driverId: $driverId, driverName: $driverName, driverPhotoUrl: $driverPhotoUrl, driverRating: $driverRating, origin: $origin, destination: $destination, waypoints: $waypoints, distanceKm: $distanceKm, durationMinutes: $durationMinutes, polylineEncoded: $polylineEncoded, departureTime: $departureTime, arrivalTime: $arrivalTime, flexibilityMinutes: $flexibilityMinutes, availableSeats: $availableSeats, bookedSeats: $bookedSeats, pricePerSeat: $pricePerSeat, currency: $currency, isPriceNegotiable: $isPriceNegotiable, acceptsOnlinePayment: $acceptsOnlinePayment, status: $status, allowPets: $allowPets, allowSmoking: $allowSmoking, allowLuggage: $allowLuggage, isWomenOnly: $isWomenOnly, allowChat: $allowChat, maxDetourMinutes: $maxDetourMinutes, vehicleId: $vehicleId, vehicleInfo: $vehicleInfo, bookings: $bookings, reviews: $reviews, isRecurring: $isRecurring, recurringDays: $recurringDays, recurringEndDate: $recurringEndDate, xpReward: $xpReward, notes: $notes, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RideModelCopyWith<$Res>  {
  factory $RideModelCopyWith(RideModel value, $Res Function(RideModel) _then) = _$RideModelCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String driverName, String? driverPhotoUrl, double? driverRating, LocationPoint origin, LocationPoint destination, List<RouteWaypoint> waypoints, double? distanceKm, int? durationMinutes, String? polylineEncoded,@RequiredTimestampConverter() DateTime departureTime,@TimestampConverter() DateTime? arrivalTime, int flexibilityMinutes, int availableSeats, int bookedSeats, double pricePerSeat, String? currency, bool isPriceNegotiable, bool acceptsOnlinePayment, RideStatus status, bool allowPets, bool allowSmoking, bool allowLuggage, bool isWomenOnly, bool allowChat, int? maxDetourMinutes, String? vehicleId, String? vehicleInfo, List<RideBooking> bookings, List<RideReview> reviews, bool isRecurring, List<int> recurringDays,@TimestampConverter() DateTime? recurringEndDate, int xpReward, String? notes, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$LocationPointCopyWith<$Res> get origin;$LocationPointCopyWith<$Res> get destination;

}
/// @nodoc
class _$RideModelCopyWithImpl<$Res>
    implements $RideModelCopyWith<$Res> {
  _$RideModelCopyWithImpl(this._self, this._then);

  final RideModel _self;
  final $Res Function(RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? driverPhotoUrl = freezed,Object? driverRating = freezed,Object? origin = null,Object? destination = null,Object? waypoints = null,Object? distanceKm = freezed,Object? durationMinutes = freezed,Object? polylineEncoded = freezed,Object? departureTime = null,Object? arrivalTime = freezed,Object? flexibilityMinutes = null,Object? availableSeats = null,Object? bookedSeats = null,Object? pricePerSeat = null,Object? currency = freezed,Object? isPriceNegotiable = null,Object? acceptsOnlinePayment = null,Object? status = null,Object? allowPets = null,Object? allowSmoking = null,Object? allowLuggage = null,Object? isWomenOnly = null,Object? allowChat = null,Object? maxDetourMinutes = freezed,Object? vehicleId = freezed,Object? vehicleInfo = freezed,Object? bookings = null,Object? reviews = null,Object? isRecurring = null,Object? recurringDays = null,Object? recurringEndDate = freezed,Object? xpReward = null,Object? notes = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverPhotoUrl: freezed == driverPhotoUrl ? _self.driverPhotoUrl : driverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint,waypoints: null == waypoints ? _self.waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,polylineEncoded: freezed == polylineEncoded ? _self.polylineEncoded : polylineEncoded // ignore: cast_nullable_to_non_nullable
as String?,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,flexibilityMinutes: null == flexibilityMinutes ? _self.flexibilityMinutes : flexibilityMinutes // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,bookedSeats: null == bookedSeats ? _self.bookedSeats : bookedSeats // ignore: cast_nullable_to_non_nullable
as int,pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,isPriceNegotiable: null == isPriceNegotiable ? _self.isPriceNegotiable : isPriceNegotiable // ignore: cast_nullable_to_non_nullable
as bool,acceptsOnlinePayment: null == acceptsOnlinePayment ? _self.acceptsOnlinePayment : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,allowLuggage: null == allowLuggage ? _self.allowLuggage : allowLuggage // ignore: cast_nullable_to_non_nullable
as bool,isWomenOnly: null == isWomenOnly ? _self.isWomenOnly : isWomenOnly // ignore: cast_nullable_to_non_nullable
as bool,allowChat: null == allowChat ? _self.allowChat : allowChat // ignore: cast_nullable_to_non_nullable
as bool,maxDetourMinutes: freezed == maxDetourMinutes ? _self.maxDetourMinutes : maxDetourMinutes // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as String?,bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<RideReview>,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<int>,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get origin {
  
  return $LocationPointCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get destination {
  
  return $LocationPointCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideModel].
extension RideModelPatterns on RideModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideModel value)  $default,){
final _that = this;
switch (_that) {
case _RideModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideModel value)?  $default,){
final _that = this;
switch (_that) {
case _RideModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String? driverPhotoUrl,  double? driverRating,  LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded, @RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime,  int flexibilityMinutes,  int availableSeats,  int bookedSeats,  double pricePerSeat,  String? currency,  bool isPriceNegotiable,  bool acceptsOnlinePayment,  RideStatus status,  bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly,  bool allowChat,  int? maxDetourMinutes,  String? vehicleId,  String? vehicleInfo,  List<RideBooking> bookings,  List<RideReview> reviews,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.driverPhotoUrl,_that.driverRating,_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded,_that.departureTime,_that.arrivalTime,_that.flexibilityMinutes,_that.availableSeats,_that.bookedSeats,_that.pricePerSeat,_that.currency,_that.isPriceNegotiable,_that.acceptsOnlinePayment,_that.status,_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly,_that.allowChat,_that.maxDetourMinutes,_that.vehicleId,_that.vehicleInfo,_that.bookings,_that.reviews,_that.isRecurring,_that.recurringDays,_that.recurringEndDate,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String driverName,  String? driverPhotoUrl,  double? driverRating,  LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded, @RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime,  int flexibilityMinutes,  int availableSeats,  int bookedSeats,  double pricePerSeat,  String? currency,  bool isPriceNegotiable,  bool acceptsOnlinePayment,  RideStatus status,  bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly,  bool allowChat,  int? maxDetourMinutes,  String? vehicleId,  String? vehicleInfo,  List<RideBooking> bookings,  List<RideReview> reviews,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RideModel():
return $default(_that.id,_that.driverId,_that.driverName,_that.driverPhotoUrl,_that.driverRating,_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded,_that.departureTime,_that.arrivalTime,_that.flexibilityMinutes,_that.availableSeats,_that.bookedSeats,_that.pricePerSeat,_that.currency,_that.isPriceNegotiable,_that.acceptsOnlinePayment,_that.status,_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly,_that.allowChat,_that.maxDetourMinutes,_that.vehicleId,_that.vehicleInfo,_that.bookings,_that.reviews,_that.isRecurring,_that.recurringDays,_that.recurringEndDate,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String driverName,  String? driverPhotoUrl,  double? driverRating,  LocationPoint origin,  LocationPoint destination,  List<RouteWaypoint> waypoints,  double? distanceKm,  int? durationMinutes,  String? polylineEncoded, @RequiredTimestampConverter()  DateTime departureTime, @TimestampConverter()  DateTime? arrivalTime,  int flexibilityMinutes,  int availableSeats,  int bookedSeats,  double pricePerSeat,  String? currency,  bool isPriceNegotiable,  bool acceptsOnlinePayment,  RideStatus status,  bool allowPets,  bool allowSmoking,  bool allowLuggage,  bool isWomenOnly,  bool allowChat,  int? maxDetourMinutes,  String? vehicleId,  String? vehicleInfo,  List<RideBooking> bookings,  List<RideReview> reviews,  bool isRecurring,  List<int> recurringDays, @TimestampConverter()  DateTime? recurringEndDate,  int xpReward,  String? notes,  List<String> tags, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RideModel() when $default != null:
return $default(_that.id,_that.driverId,_that.driverName,_that.driverPhotoUrl,_that.driverRating,_that.origin,_that.destination,_that.waypoints,_that.distanceKm,_that.durationMinutes,_that.polylineEncoded,_that.departureTime,_that.arrivalTime,_that.flexibilityMinutes,_that.availableSeats,_that.bookedSeats,_that.pricePerSeat,_that.currency,_that.isPriceNegotiable,_that.acceptsOnlinePayment,_that.status,_that.allowPets,_that.allowSmoking,_that.allowLuggage,_that.isWomenOnly,_that.allowChat,_that.maxDetourMinutes,_that.vehicleId,_that.vehicleInfo,_that.bookings,_that.reviews,_that.isRecurring,_that.recurringDays,_that.recurringEndDate,_that.xpReward,_that.notes,_that.tags,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideModel extends RideModel {
  const _RideModel({required this.id, required this.driverId, required this.driverName, this.driverPhotoUrl, this.driverRating, required this.origin, required this.destination, final  List<RouteWaypoint> waypoints = const [], this.distanceKm, this.durationMinutes, this.polylineEncoded, @RequiredTimestampConverter() required this.departureTime, @TimestampConverter() this.arrivalTime, this.flexibilityMinutes = 15, this.availableSeats = 3, this.bookedSeats = 0, this.pricePerSeat = 0.0, this.currency, this.isPriceNegotiable = false, this.acceptsOnlinePayment = false, this.status = RideStatus.draft, this.allowPets = false, this.allowSmoking = false, this.allowLuggage = true, this.isWomenOnly = false, this.allowChat = true, this.maxDetourMinutes, this.vehicleId, this.vehicleInfo, final  List<RideBooking> bookings = const [], final  List<RideReview> reviews = const [], this.isRecurring = false, final  List<int> recurringDays = const [], @TimestampConverter() this.recurringEndDate, this.xpReward = 50, this.notes, final  List<String> tags = const [], @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _waypoints = waypoints,_bookings = bookings,_reviews = reviews,_recurringDays = recurringDays,_tags = tags,super._();
  factory _RideModel.fromJson(Map<String, dynamic> json) => _$RideModelFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String driverName;
@override final  String? driverPhotoUrl;
@override final  double? driverRating;
// Route information
@override final  LocationPoint origin;
@override final  LocationPoint destination;
 final  List<RouteWaypoint> _waypoints;
@override@JsonKey() List<RouteWaypoint> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}

// Route details
@override final  double? distanceKm;
@override final  int? durationMinutes;
@override final  String? polylineEncoded;
// Timing
@override@RequiredTimestampConverter() final  DateTime departureTime;
@override@TimestampConverter() final  DateTime? arrivalTime;
@override@JsonKey() final  int flexibilityMinutes;
// Capacity
@override@JsonKey() final  int availableSeats;
@override@JsonKey() final  int bookedSeats;
// Pricing
@override@JsonKey() final  double pricePerSeat;
@override final  String? currency;
@override@JsonKey() final  bool isPriceNegotiable;
@override@JsonKey() final  bool acceptsOnlinePayment;
// Driver has Stripe connected
// Status
@override@JsonKey() final  RideStatus status;
// Preferences
@override@JsonKey() final  bool allowPets;
@override@JsonKey() final  bool allowSmoking;
@override@JsonKey() final  bool allowLuggage;
@override@JsonKey() final  bool isWomenOnly;
@override@JsonKey() final  bool allowChat;
@override final  int? maxDetourMinutes;
// Vehicle
@override final  String? vehicleId;
@override final  String? vehicleInfo;
// Bookings
 final  List<RideBooking> _bookings;
// Bookings
@override@JsonKey() List<RideBooking> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}

// Reviews
 final  List<RideReview> _reviews;
// Reviews
@override@JsonKey() List<RideReview> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

// Recurrence (for regular commutes)
@override@JsonKey() final  bool isRecurring;
 final  List<int> _recurringDays;
@override@JsonKey() List<int> get recurringDays {
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recurringDays);
}

@override@TimestampConverter() final  DateTime? recurringEndDate;
// XP Rewards
@override@JsonKey() final  int xpReward;
// Metadata
@override final  String? notes;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideModelCopyWith<_RideModel> get copyWith => __$RideModelCopyWithImpl<_RideModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideModel&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhotoUrl, driverPhotoUrl) || other.driverPhotoUrl == driverPhotoUrl)&&(identical(other.driverRating, driverRating) || other.driverRating == driverRating)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.polylineEncoded, polylineEncoded) || other.polylineEncoded == polylineEncoded)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.arrivalTime, arrivalTime) || other.arrivalTime == arrivalTime)&&(identical(other.flexibilityMinutes, flexibilityMinutes) || other.flexibilityMinutes == flexibilityMinutes)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.bookedSeats, bookedSeats) || other.bookedSeats == bookedSeats)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isPriceNegotiable, isPriceNegotiable) || other.isPriceNegotiable == isPriceNegotiable)&&(identical(other.acceptsOnlinePayment, acceptsOnlinePayment) || other.acceptsOnlinePayment == acceptsOnlinePayment)&&(identical(other.status, status) || other.status == status)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.allowLuggage, allowLuggage) || other.allowLuggage == allowLuggage)&&(identical(other.isWomenOnly, isWomenOnly) || other.isWomenOnly == isWomenOnly)&&(identical(other.allowChat, allowChat) || other.allowChat == allowChat)&&(identical(other.maxDetourMinutes, maxDetourMinutes) || other.maxDetourMinutes == maxDetourMinutes)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&const DeepCollectionEquality().equals(other._bookings, _bookings)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,driverName,driverPhotoUrl,driverRating,origin,destination,const DeepCollectionEquality().hash(_waypoints),distanceKm,durationMinutes,polylineEncoded,departureTime,arrivalTime,flexibilityMinutes,availableSeats,bookedSeats,pricePerSeat,currency,isPriceNegotiable,acceptsOnlinePayment,status,allowPets,allowSmoking,allowLuggage,isWomenOnly,allowChat,maxDetourMinutes,vehicleId,vehicleInfo,const DeepCollectionEquality().hash(_bookings),const DeepCollectionEquality().hash(_reviews),isRecurring,const DeepCollectionEquality().hash(_recurringDays),recurringEndDate,xpReward,notes,const DeepCollectionEquality().hash(_tags),createdAt,updatedAt]);

@override
String toString() {
  return 'RideModel(id: $id, driverId: $driverId, driverName: $driverName, driverPhotoUrl: $driverPhotoUrl, driverRating: $driverRating, origin: $origin, destination: $destination, waypoints: $waypoints, distanceKm: $distanceKm, durationMinutes: $durationMinutes, polylineEncoded: $polylineEncoded, departureTime: $departureTime, arrivalTime: $arrivalTime, flexibilityMinutes: $flexibilityMinutes, availableSeats: $availableSeats, bookedSeats: $bookedSeats, pricePerSeat: $pricePerSeat, currency: $currency, isPriceNegotiable: $isPriceNegotiable, acceptsOnlinePayment: $acceptsOnlinePayment, status: $status, allowPets: $allowPets, allowSmoking: $allowSmoking, allowLuggage: $allowLuggage, isWomenOnly: $isWomenOnly, allowChat: $allowChat, maxDetourMinutes: $maxDetourMinutes, vehicleId: $vehicleId, vehicleInfo: $vehicleInfo, bookings: $bookings, reviews: $reviews, isRecurring: $isRecurring, recurringDays: $recurringDays, recurringEndDate: $recurringEndDate, xpReward: $xpReward, notes: $notes, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RideModelCopyWith<$Res> implements $RideModelCopyWith<$Res> {
  factory _$RideModelCopyWith(_RideModel value, $Res Function(_RideModel) _then) = __$RideModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String driverName, String? driverPhotoUrl, double? driverRating, LocationPoint origin, LocationPoint destination, List<RouteWaypoint> waypoints, double? distanceKm, int? durationMinutes, String? polylineEncoded,@RequiredTimestampConverter() DateTime departureTime,@TimestampConverter() DateTime? arrivalTime, int flexibilityMinutes, int availableSeats, int bookedSeats, double pricePerSeat, String? currency, bool isPriceNegotiable, bool acceptsOnlinePayment, RideStatus status, bool allowPets, bool allowSmoking, bool allowLuggage, bool isWomenOnly, bool allowChat, int? maxDetourMinutes, String? vehicleId, String? vehicleInfo, List<RideBooking> bookings, List<RideReview> reviews, bool isRecurring, List<int> recurringDays,@TimestampConverter() DateTime? recurringEndDate, int xpReward, String? notes, List<String> tags,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


@override $LocationPointCopyWith<$Res> get origin;@override $LocationPointCopyWith<$Res> get destination;

}
/// @nodoc
class __$RideModelCopyWithImpl<$Res>
    implements _$RideModelCopyWith<$Res> {
  __$RideModelCopyWithImpl(this._self, this._then);

  final _RideModel _self;
  final $Res Function(_RideModel) _then;

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? driverName = null,Object? driverPhotoUrl = freezed,Object? driverRating = freezed,Object? origin = null,Object? destination = null,Object? waypoints = null,Object? distanceKm = freezed,Object? durationMinutes = freezed,Object? polylineEncoded = freezed,Object? departureTime = null,Object? arrivalTime = freezed,Object? flexibilityMinutes = null,Object? availableSeats = null,Object? bookedSeats = null,Object? pricePerSeat = null,Object? currency = freezed,Object? isPriceNegotiable = null,Object? acceptsOnlinePayment = null,Object? status = null,Object? allowPets = null,Object? allowSmoking = null,Object? allowLuggage = null,Object? isWomenOnly = null,Object? allowChat = null,Object? maxDetourMinutes = freezed,Object? vehicleId = freezed,Object? vehicleInfo = freezed,Object? bookings = null,Object? reviews = null,Object? isRecurring = null,Object? recurringDays = null,Object? recurringEndDate = freezed,Object? xpReward = null,Object? notes = freezed,Object? tags = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RideModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,driverName: null == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String,driverPhotoUrl: freezed == driverPhotoUrl ? _self.driverPhotoUrl : driverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,driverRating: freezed == driverRating ? _self.driverRating : driverRating // ignore: cast_nullable_to_non_nullable
as double?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<RouteWaypoint>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,polylineEncoded: freezed == polylineEncoded ? _self.polylineEncoded : polylineEncoded // ignore: cast_nullable_to_non_nullable
as String?,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,arrivalTime: freezed == arrivalTime ? _self.arrivalTime : arrivalTime // ignore: cast_nullable_to_non_nullable
as DateTime?,flexibilityMinutes: null == flexibilityMinutes ? _self.flexibilityMinutes : flexibilityMinutes // ignore: cast_nullable_to_non_nullable
as int,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,bookedSeats: null == bookedSeats ? _self.bookedSeats : bookedSeats // ignore: cast_nullable_to_non_nullable
as int,pricePerSeat: null == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double,currency: freezed == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String?,isPriceNegotiable: null == isPriceNegotiable ? _self.isPriceNegotiable : isPriceNegotiable // ignore: cast_nullable_to_non_nullable
as bool,acceptsOnlinePayment: null == acceptsOnlinePayment ? _self.acceptsOnlinePayment : acceptsOnlinePayment // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RideStatus,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,allowLuggage: null == allowLuggage ? _self.allowLuggage : allowLuggage // ignore: cast_nullable_to_non_nullable
as bool,isWomenOnly: null == isWomenOnly ? _self.isWomenOnly : isWomenOnly // ignore: cast_nullable_to_non_nullable
as bool,allowChat: null == allowChat ? _self.allowChat : allowChat // ignore: cast_nullable_to_non_nullable
as bool,maxDetourMinutes: freezed == maxDetourMinutes ? _self.maxDetourMinutes : maxDetourMinutes // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as String?,bookings: null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<RideBooking>,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<RideReview>,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<int>,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get origin {
  
  return $LocationPointCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get destination {
  
  return $LocationPointCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// @nodoc
mixin _$RideSearchFilters {

 LocationPoint? get origin; LocationPoint? get destination;@TimestampConverter() DateTime? get departureDate;@TimestampConverter() DateTime? get departureTimeFrom;@TimestampConverter() DateTime? get departureTimeTo; int get minSeats; double? get maxPrice; double? get maxRadiusKm; bool get allowPets; bool get allowSmoking; bool get womenOnly; double? get minDriverRating; String get sortBy; bool get sortAscending;
/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideSearchFiltersCopyWith<RideSearchFilters> get copyWith => _$RideSearchFiltersCopyWithImpl<RideSearchFilters>(this as RideSearchFilters, _$identity);

  /// Serializes this RideSearchFilters to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideSearchFilters&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.departureTimeTo, departureTimeTo) || other.departureTimeTo == departureTimeTo)&&(identical(other.minSeats, minSeats) || other.minSeats == minSeats)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.maxRadiusKm, maxRadiusKm) || other.maxRadiusKm == maxRadiusKm)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.womenOnly, womenOnly) || other.womenOnly == womenOnly)&&(identical(other.minDriverRating, minDriverRating) || other.minDriverRating == minDriverRating)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureTimeFrom,departureTimeTo,minSeats,maxPrice,maxRadiusKm,allowPets,allowSmoking,womenOnly,minDriverRating,sortBy,sortAscending);

@override
String toString() {
  return 'RideSearchFilters(origin: $origin, destination: $destination, departureDate: $departureDate, departureTimeFrom: $departureTimeFrom, departureTimeTo: $departureTimeTo, minSeats: $minSeats, maxPrice: $maxPrice, maxRadiusKm: $maxRadiusKm, allowPets: $allowPets, allowSmoking: $allowSmoking, womenOnly: $womenOnly, minDriverRating: $minDriverRating, sortBy: $sortBy, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class $RideSearchFiltersCopyWith<$Res>  {
  factory $RideSearchFiltersCopyWith(RideSearchFilters value, $Res Function(RideSearchFilters) _then) = _$RideSearchFiltersCopyWithImpl;
@useResult
$Res call({
 LocationPoint? origin, LocationPoint? destination,@TimestampConverter() DateTime? departureDate,@TimestampConverter() DateTime? departureTimeFrom,@TimestampConverter() DateTime? departureTimeTo, int minSeats, double? maxPrice, double? maxRadiusKm, bool allowPets, bool allowSmoking, bool womenOnly, double? minDriverRating, String sortBy, bool sortAscending
});


$LocationPointCopyWith<$Res>? get origin;$LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class _$RideSearchFiltersCopyWithImpl<$Res>
    implements $RideSearchFiltersCopyWith<$Res> {
  _$RideSearchFiltersCopyWithImpl(this._self, this._then);

  final RideSearchFilters _self;
  final $Res Function(RideSearchFilters) _then;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureTimeFrom = freezed,Object? departureTimeTo = freezed,Object? minSeats = null,Object? maxPrice = freezed,Object? maxRadiusKm = freezed,Object? allowPets = null,Object? allowSmoking = null,Object? womenOnly = null,Object? minDriverRating = freezed,Object? sortBy = null,Object? sortAscending = null,}) {
  return _then(_self.copyWith(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeTo: freezed == departureTimeTo ? _self.departureTimeTo : departureTimeTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minSeats: null == minSeats ? _self.minSeats : minSeats // ignore: cast_nullable_to_non_nullable
as int,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,maxRadiusKm: freezed == maxRadiusKm ? _self.maxRadiusKm : maxRadiusKm // ignore: cast_nullable_to_non_nullable
as double?,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,womenOnly: null == womenOnly ? _self.womenOnly : womenOnly // ignore: cast_nullable_to_non_nullable
as bool,minDriverRating: freezed == minDriverRating ? _self.minDriverRating : minDriverRating // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideSearchFilters].
extension RideSearchFiltersPatterns on RideSearchFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideSearchFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideSearchFilters value)  $default,){
final _that = this;
switch (_that) {
case _RideSearchFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideSearchFilters value)?  $default,){
final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  double? maxPrice,  double? maxRadiusKm,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.maxRadiusKm,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  double? maxPrice,  double? maxRadiusKm,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)  $default,) {final _that = this;
switch (_that) {
case _RideSearchFilters():
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.maxRadiusKm,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationPoint? origin,  LocationPoint? destination, @TimestampConverter()  DateTime? departureDate, @TimestampConverter()  DateTime? departureTimeFrom, @TimestampConverter()  DateTime? departureTimeTo,  int minSeats,  double? maxPrice,  double? maxRadiusKm,  bool allowPets,  bool allowSmoking,  bool womenOnly,  double? minDriverRating,  String sortBy,  bool sortAscending)?  $default,) {final _that = this;
switch (_that) {
case _RideSearchFilters() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureTimeFrom,_that.departureTimeTo,_that.minSeats,_that.maxPrice,_that.maxRadiusKm,_that.allowPets,_that.allowSmoking,_that.womenOnly,_that.minDriverRating,_that.sortBy,_that.sortAscending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideSearchFilters implements RideSearchFilters {
  const _RideSearchFilters({this.origin, this.destination, @TimestampConverter() this.departureDate, @TimestampConverter() this.departureTimeFrom, @TimestampConverter() this.departureTimeTo, this.minSeats = 1, this.maxPrice, this.maxRadiusKm, this.allowPets = false, this.allowSmoking = false, this.womenOnly = false, this.minDriverRating, this.sortBy = 'departure_time', this.sortAscending = true});
  factory _RideSearchFilters.fromJson(Map<String, dynamic> json) => _$RideSearchFiltersFromJson(json);

@override final  LocationPoint? origin;
@override final  LocationPoint? destination;
@override@TimestampConverter() final  DateTime? departureDate;
@override@TimestampConverter() final  DateTime? departureTimeFrom;
@override@TimestampConverter() final  DateTime? departureTimeTo;
@override@JsonKey() final  int minSeats;
@override final  double? maxPrice;
@override final  double? maxRadiusKm;
@override@JsonKey() final  bool allowPets;
@override@JsonKey() final  bool allowSmoking;
@override@JsonKey() final  bool womenOnly;
@override final  double? minDriverRating;
@override@JsonKey() final  String sortBy;
@override@JsonKey() final  bool sortAscending;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideSearchFiltersCopyWith<_RideSearchFilters> get copyWith => __$RideSearchFiltersCopyWithImpl<_RideSearchFilters>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideSearchFiltersToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideSearchFilters&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.departureTimeTo, departureTimeTo) || other.departureTimeTo == departureTimeTo)&&(identical(other.minSeats, minSeats) || other.minSeats == minSeats)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.maxRadiusKm, maxRadiusKm) || other.maxRadiusKm == maxRadiusKm)&&(identical(other.allowPets, allowPets) || other.allowPets == allowPets)&&(identical(other.allowSmoking, allowSmoking) || other.allowSmoking == allowSmoking)&&(identical(other.womenOnly, womenOnly) || other.womenOnly == womenOnly)&&(identical(other.minDriverRating, minDriverRating) || other.minDriverRating == minDriverRating)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortAscending, sortAscending) || other.sortAscending == sortAscending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureTimeFrom,departureTimeTo,minSeats,maxPrice,maxRadiusKm,allowPets,allowSmoking,womenOnly,minDriverRating,sortBy,sortAscending);

@override
String toString() {
  return 'RideSearchFilters(origin: $origin, destination: $destination, departureDate: $departureDate, departureTimeFrom: $departureTimeFrom, departureTimeTo: $departureTimeTo, minSeats: $minSeats, maxPrice: $maxPrice, maxRadiusKm: $maxRadiusKm, allowPets: $allowPets, allowSmoking: $allowSmoking, womenOnly: $womenOnly, minDriverRating: $minDriverRating, sortBy: $sortBy, sortAscending: $sortAscending)';
}


}

/// @nodoc
abstract mixin class _$RideSearchFiltersCopyWith<$Res> implements $RideSearchFiltersCopyWith<$Res> {
  factory _$RideSearchFiltersCopyWith(_RideSearchFilters value, $Res Function(_RideSearchFilters) _then) = __$RideSearchFiltersCopyWithImpl;
@override @useResult
$Res call({
 LocationPoint? origin, LocationPoint? destination,@TimestampConverter() DateTime? departureDate,@TimestampConverter() DateTime? departureTimeFrom,@TimestampConverter() DateTime? departureTimeTo, int minSeats, double? maxPrice, double? maxRadiusKm, bool allowPets, bool allowSmoking, bool womenOnly, double? minDriverRating, String sortBy, bool sortAscending
});


@override $LocationPointCopyWith<$Res>? get origin;@override $LocationPointCopyWith<$Res>? get destination;

}
/// @nodoc
class __$RideSearchFiltersCopyWithImpl<$Res>
    implements _$RideSearchFiltersCopyWith<$Res> {
  __$RideSearchFiltersCopyWithImpl(this._self, this._then);

  final _RideSearchFilters _self;
  final $Res Function(_RideSearchFilters) _then;

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureTimeFrom = freezed,Object? departureTimeTo = freezed,Object? minSeats = null,Object? maxPrice = freezed,Object? maxRadiusKm = freezed,Object? allowPets = null,Object? allowSmoking = null,Object? womenOnly = null,Object? minDriverRating = freezed,Object? sortBy = null,Object? sortAscending = null,}) {
  return _then(_RideSearchFilters(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as LocationPoint?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as LocationPoint?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeTo: freezed == departureTimeTo ? _self.departureTimeTo : departureTimeTo // ignore: cast_nullable_to_non_nullable
as DateTime?,minSeats: null == minSeats ? _self.minSeats : minSeats // ignore: cast_nullable_to_non_nullable
as int,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,maxRadiusKm: freezed == maxRadiusKm ? _self.maxRadiusKm : maxRadiusKm // ignore: cast_nullable_to_non_nullable
as double?,allowPets: null == allowPets ? _self.allowPets : allowPets // ignore: cast_nullable_to_non_nullable
as bool,allowSmoking: null == allowSmoking ? _self.allowSmoking : allowSmoking // ignore: cast_nullable_to_non_nullable
as bool,womenOnly: null == womenOnly ? _self.womenOnly : womenOnly // ignore: cast_nullable_to_non_nullable
as bool,minDriverRating: freezed == minDriverRating ? _self.minDriverRating : minDriverRating // ignore: cast_nullable_to_non_nullable
as double?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,sortAscending: null == sortAscending ? _self.sortAscending : sortAscending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideSearchFilters
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $LocationPointCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
