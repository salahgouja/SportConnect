// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String get id; String get creatorId; String get title; EventType get type; LocationPoint get location;@RequiredTimestampConverter() DateTime get startsAt;@TimestampConverter() DateTime? get endsAt; String? get description;/// Venue / facility name (e.g. "Downtown Sports Complex").
 String? get venueName;/// Display name of the organiser (denormalized for fast rendering).
 String? get organizerName;/// Cover image URL (Firebase Storage).
 String? get imageUrl; List<String> get participantIds; int get maxParticipants; bool get isActive;@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.location, location) || other.location == location)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,type,location,startsAt,endsAt,description,venueName,organizerName,imageUrl,const DeepCollectionEquality().hash(participantIds),maxParticipants,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'EventModel(id: $id, creatorId: $creatorId, title: $title, type: $type, location: $location, startsAt: $startsAt, endsAt: $endsAt, description: $description, venueName: $venueName, organizerName: $organizerName, imageUrl: $imageUrl, participantIds: $participantIds, maxParticipants: $maxParticipants, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String id, String creatorId, String title, EventType type, LocationPoint location,@RequiredTimestampConverter() DateTime startsAt,@TimestampConverter() DateTime? endsAt, String? description, String? venueName, String? organizerName, String? imageUrl, List<String> participantIds, int maxParticipants, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? type = null,Object? location = null,Object? startsAt = null,Object? endsAt = freezed,Object? description = freezed,Object? venueName = freezed,Object? organizerName = freezed,Object? imageUrl = freezed,Object? participantIds = null,Object? maxParticipants = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? venueName,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.venueName,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? venueName,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.venueName,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String creatorId,  String title,  EventType type,  LocationPoint location, @RequiredTimestampConverter()  DateTime startsAt, @TimestampConverter()  DateTime? endsAt,  String? description,  String? venueName,  String? organizerName,  String? imageUrl,  List<String> participantIds,  int maxParticipants,  bool isActive, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.creatorId,_that.title,_that.type,_that.location,_that.startsAt,_that.endsAt,_that.description,_that.venueName,_that.organizerName,_that.imageUrl,_that.participantIds,_that.maxParticipants,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel extends EventModel {
  const _EventModel({required this.id, required this.creatorId, required this.title, required this.type, required this.location, @RequiredTimestampConverter() required this.startsAt, @TimestampConverter() this.endsAt, this.description, this.venueName, this.organizerName, this.imageUrl, final  List<String> participantIds = const [], this.maxParticipants = 0, this.isActive = true, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt}): _participantIds = participantIds,super._();
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  String id;
@override final  String creatorId;
@override final  String title;
@override final  EventType type;
@override final  LocationPoint location;
@override@RequiredTimestampConverter() final  DateTime startsAt;
@override@TimestampConverter() final  DateTime? endsAt;
@override final  String? description;
/// Venue / facility name (e.g. "Downtown Sports Complex").
@override final  String? venueName;
/// Display name of the organiser (denormalized for fast rendering).
@override final  String? organizerName;
/// Cover image URL (Firebase Storage).
@override final  String? imageUrl;
 final  List<String> _participantIds;
@override@JsonKey() List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

@override@JsonKey() final  int maxParticipants;
@override@JsonKey() final  bool isActive;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.location, location) || other.location == location)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,title,type,location,startsAt,endsAt,description,venueName,organizerName,imageUrl,const DeepCollectionEquality().hash(_participantIds),maxParticipants,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'EventModel(id: $id, creatorId: $creatorId, title: $title, type: $type, location: $location, startsAt: $startsAt, endsAt: $endsAt, description: $description, venueName: $venueName, organizerName: $organizerName, imageUrl: $imageUrl, participantIds: $participantIds, maxParticipants: $maxParticipants, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String creatorId, String title, EventType type, LocationPoint location,@RequiredTimestampConverter() DateTime startsAt,@TimestampConverter() DateTime? endsAt, String? description, String? venueName, String? organizerName, String? imageUrl, List<String> participantIds, int maxParticipants, bool isActive,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


@override $LocationPointCopyWith<$Res> get location;

}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? title = null,Object? type = null,Object? location = null,Object? startsAt = null,Object? endsAt = freezed,Object? description = freezed,Object? venueName = freezed,Object? organizerName = freezed,Object? imageUrl = freezed,Object? participantIds = null,Object? maxParticipants = null,Object? isActive = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EventType,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationPoint,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: freezed == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationPointCopyWith<$Res> get location {
  
  return $LocationPointCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
