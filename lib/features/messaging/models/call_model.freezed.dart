// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallModel {

 String get id; String get chatId; CallType get type; String get callerId; String get callerName; String? get callerPhotoUrl; String get calleeId; String get calleeName; String? get calleePhotoUrl; CallStatus get status;// WebRTC signaling info
 String? get channelName; String? get sessionId;// Call timing
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get answeredAt;@TimestampConverter() DateTime? get endedAt;// Call duration in seconds
 int get duration;// End reason
 String? get endReason;
/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallModelCopyWith<CallModel> get copyWith => _$CallModelCopyWithImpl<CallModel>(this as CallModel, _$identity);

  /// Serializes this CallModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.type, type) || other.type == type)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerPhotoUrl, callerPhotoUrl) || other.callerPhotoUrl == callerPhotoUrl)&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.calleeName, calleeName) || other.calleeName == calleeName)&&(identical(other.calleePhotoUrl, calleePhotoUrl) || other.calleePhotoUrl == calleePhotoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.endReason, endReason) || other.endReason == endReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,type,callerId,callerName,callerPhotoUrl,calleeId,calleeName,calleePhotoUrl,status,channelName,sessionId,createdAt,answeredAt,endedAt,duration,endReason);

@override
String toString() {
  return 'CallModel(id: $id, chatId: $chatId, type: $type, callerId: $callerId, callerName: $callerName, callerPhotoUrl: $callerPhotoUrl, calleeId: $calleeId, calleeName: $calleeName, calleePhotoUrl: $calleePhotoUrl, status: $status, channelName: $channelName, sessionId: $sessionId, createdAt: $createdAt, answeredAt: $answeredAt, endedAt: $endedAt, duration: $duration, endReason: $endReason)';
}


}

/// @nodoc
abstract mixin class $CallModelCopyWith<$Res>  {
  factory $CallModelCopyWith(CallModel value, $Res Function(CallModel) _then) = _$CallModelCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, CallType type, String callerId, String callerName, String? callerPhotoUrl, String calleeId, String calleeName, String? calleePhotoUrl, CallStatus status, String? channelName, String? sessionId,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? answeredAt,@TimestampConverter() DateTime? endedAt, int duration, String? endReason
});




}
/// @nodoc
class _$CallModelCopyWithImpl<$Res>
    implements $CallModelCopyWith<$Res> {
  _$CallModelCopyWithImpl(this._self, this._then);

  final CallModel _self;
  final $Res Function(CallModel) _then;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? type = null,Object? callerId = null,Object? callerName = null,Object? callerPhotoUrl = freezed,Object? calleeId = null,Object? calleeName = null,Object? calleePhotoUrl = freezed,Object? status = null,Object? channelName = freezed,Object? sessionId = freezed,Object? createdAt = freezed,Object? answeredAt = freezed,Object? endedAt = freezed,Object? duration = null,Object? endReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CallType,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerPhotoUrl: freezed == callerPhotoUrl ? _self.callerPhotoUrl : callerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,calleeName: null == calleeName ? _self.calleeName : calleeName // ignore: cast_nullable_to_non_nullable
as String,calleePhotoUrl: freezed == calleePhotoUrl ? _self.calleePhotoUrl : calleePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallModel].
extension CallModelPatterns on CallModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallModel value)  $default,){
final _that = this;
switch (_that) {
case _CallModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallModel value)?  $default,){
final _that = this;
switch (_that) {
case _CallModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  CallType type,  String callerId,  String callerName,  String? callerPhotoUrl,  String calleeId,  String calleeName,  String? calleePhotoUrl,  CallStatus status,  String? channelName,  String? sessionId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? answeredAt, @TimestampConverter()  DateTime? endedAt,  int duration,  String? endReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallModel() when $default != null:
return $default(_that.id,_that.chatId,_that.type,_that.callerId,_that.callerName,_that.callerPhotoUrl,_that.calleeId,_that.calleeName,_that.calleePhotoUrl,_that.status,_that.channelName,_that.sessionId,_that.createdAt,_that.answeredAt,_that.endedAt,_that.duration,_that.endReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  CallType type,  String callerId,  String callerName,  String? callerPhotoUrl,  String calleeId,  String calleeName,  String? calleePhotoUrl,  CallStatus status,  String? channelName,  String? sessionId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? answeredAt, @TimestampConverter()  DateTime? endedAt,  int duration,  String? endReason)  $default,) {final _that = this;
switch (_that) {
case _CallModel():
return $default(_that.id,_that.chatId,_that.type,_that.callerId,_that.callerName,_that.callerPhotoUrl,_that.calleeId,_that.calleeName,_that.calleePhotoUrl,_that.status,_that.channelName,_that.sessionId,_that.createdAt,_that.answeredAt,_that.endedAt,_that.duration,_that.endReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  CallType type,  String callerId,  String callerName,  String? callerPhotoUrl,  String calleeId,  String calleeName,  String? calleePhotoUrl,  CallStatus status,  String? channelName,  String? sessionId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? answeredAt, @TimestampConverter()  DateTime? endedAt,  int duration,  String? endReason)?  $default,) {final _that = this;
switch (_that) {
case _CallModel() when $default != null:
return $default(_that.id,_that.chatId,_that.type,_that.callerId,_that.callerName,_that.callerPhotoUrl,_that.calleeId,_that.calleeName,_that.calleePhotoUrl,_that.status,_that.channelName,_that.sessionId,_that.createdAt,_that.answeredAt,_that.endedAt,_that.duration,_that.endReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallModel extends CallModel {
  const _CallModel({required this.id, required this.chatId, required this.type, required this.callerId, required this.callerName, this.callerPhotoUrl, required this.calleeId, required this.calleeName, this.calleePhotoUrl, this.status = CallStatus.pending, this.channelName, this.sessionId, @TimestampConverter() this.createdAt, @TimestampConverter() this.answeredAt, @TimestampConverter() this.endedAt, this.duration = 0, this.endReason}): super._();
  factory _CallModel.fromJson(Map<String, dynamic> json) => _$CallModelFromJson(json);

@override final  String id;
@override final  String chatId;
@override final  CallType type;
@override final  String callerId;
@override final  String callerName;
@override final  String? callerPhotoUrl;
@override final  String calleeId;
@override final  String calleeName;
@override final  String? calleePhotoUrl;
@override@JsonKey() final  CallStatus status;
// WebRTC signaling info
@override final  String? channelName;
@override final  String? sessionId;
// Call timing
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? answeredAt;
@override@TimestampConverter() final  DateTime? endedAt;
// Call duration in seconds
@override@JsonKey() final  int duration;
// End reason
@override final  String? endReason;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallModelCopyWith<_CallModel> get copyWith => __$CallModelCopyWithImpl<_CallModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallModel&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.type, type) || other.type == type)&&(identical(other.callerId, callerId) || other.callerId == callerId)&&(identical(other.callerName, callerName) || other.callerName == callerName)&&(identical(other.callerPhotoUrl, callerPhotoUrl) || other.callerPhotoUrl == callerPhotoUrl)&&(identical(other.calleeId, calleeId) || other.calleeId == calleeId)&&(identical(other.calleeName, calleeName) || other.calleeName == calleeName)&&(identical(other.calleePhotoUrl, calleePhotoUrl) || other.calleePhotoUrl == calleePhotoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.endReason, endReason) || other.endReason == endReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,type,callerId,callerName,callerPhotoUrl,calleeId,calleeName,calleePhotoUrl,status,channelName,sessionId,createdAt,answeredAt,endedAt,duration,endReason);

@override
String toString() {
  return 'CallModel(id: $id, chatId: $chatId, type: $type, callerId: $callerId, callerName: $callerName, callerPhotoUrl: $callerPhotoUrl, calleeId: $calleeId, calleeName: $calleeName, calleePhotoUrl: $calleePhotoUrl, status: $status, channelName: $channelName, sessionId: $sessionId, createdAt: $createdAt, answeredAt: $answeredAt, endedAt: $endedAt, duration: $duration, endReason: $endReason)';
}


}

/// @nodoc
abstract mixin class _$CallModelCopyWith<$Res> implements $CallModelCopyWith<$Res> {
  factory _$CallModelCopyWith(_CallModel value, $Res Function(_CallModel) _then) = __$CallModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, CallType type, String callerId, String callerName, String? callerPhotoUrl, String calleeId, String calleeName, String? calleePhotoUrl, CallStatus status, String? channelName, String? sessionId,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? answeredAt,@TimestampConverter() DateTime? endedAt, int duration, String? endReason
});




}
/// @nodoc
class __$CallModelCopyWithImpl<$Res>
    implements _$CallModelCopyWith<$Res> {
  __$CallModelCopyWithImpl(this._self, this._then);

  final _CallModel _self;
  final $Res Function(_CallModel) _then;

/// Create a copy of CallModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? type = null,Object? callerId = null,Object? callerName = null,Object? callerPhotoUrl = freezed,Object? calleeId = null,Object? calleeName = null,Object? calleePhotoUrl = freezed,Object? status = null,Object? channelName = freezed,Object? sessionId = freezed,Object? createdAt = freezed,Object? answeredAt = freezed,Object? endedAt = freezed,Object? duration = null,Object? endReason = freezed,}) {
  return _then(_CallModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CallType,callerId: null == callerId ? _self.callerId : callerId // ignore: cast_nullable_to_non_nullable
as String,callerName: null == callerName ? _self.callerName : callerName // ignore: cast_nullable_to_non_nullable
as String,callerPhotoUrl: freezed == callerPhotoUrl ? _self.callerPhotoUrl : callerPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,calleeId: null == calleeId ? _self.calleeId : calleeId // ignore: cast_nullable_to_non_nullable
as String,calleeName: null == calleeName ? _self.calleeName : calleeName // ignore: cast_nullable_to_non_nullable
as String,calleePhotoUrl: freezed == calleePhotoUrl ? _self.calleePhotoUrl : calleePhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,channelName: freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,endReason: freezed == endReason ? _self.endReason : endReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CallHistoryEntry {

 String get id; CallType get type; String get receiverId; String get receiverName; String? get receiverPhotoUrl; bool get isOutgoing; CallStatus get status; int get duration;@TimestampConverter() DateTime? get timestamp;
/// Create a copy of CallHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallHistoryEntryCopyWith<CallHistoryEntry> get copyWith => _$CallHistoryEntryCopyWithImpl<CallHistoryEntry>(this as CallHistoryEntry, _$identity);

  /// Serializes this CallHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverPhotoUrl, receiverPhotoUrl) || other.receiverPhotoUrl == receiverPhotoUrl)&&(identical(other.isOutgoing, isOutgoing) || other.isOutgoing == isOutgoing)&&(identical(other.status, status) || other.status == status)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,receiverId,receiverName,receiverPhotoUrl,isOutgoing,status,duration,timestamp);

@override
String toString() {
  return 'CallHistoryEntry(id: $id, type: $type, receiverId: $receiverId, receiverName: $receiverName, receiverPhotoUrl: $receiverPhotoUrl, isOutgoing: $isOutgoing, status: $status, duration: $duration, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $CallHistoryEntryCopyWith<$Res>  {
  factory $CallHistoryEntryCopyWith(CallHistoryEntry value, $Res Function(CallHistoryEntry) _then) = _$CallHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, CallType type, String receiverId, String receiverName, String? receiverPhotoUrl, bool isOutgoing, CallStatus status, int duration,@TimestampConverter() DateTime? timestamp
});




}
/// @nodoc
class _$CallHistoryEntryCopyWithImpl<$Res>
    implements $CallHistoryEntryCopyWith<$Res> {
  _$CallHistoryEntryCopyWithImpl(this._self, this._then);

  final CallHistoryEntry _self;
  final $Res Function(CallHistoryEntry) _then;

/// Create a copy of CallHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? receiverId = null,Object? receiverName = null,Object? receiverPhotoUrl = freezed,Object? isOutgoing = null,Object? status = null,Object? duration = null,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CallType,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverPhotoUrl: freezed == receiverPhotoUrl ? _self.receiverPhotoUrl : receiverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,isOutgoing: null == isOutgoing ? _self.isOutgoing : isOutgoing // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallHistoryEntry].
extension CallHistoryEntryPatterns on CallHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _CallHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CallHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CallType type,  String receiverId,  String receiverName,  String? receiverPhotoUrl,  bool isOutgoing,  CallStatus status,  int duration, @TimestampConverter()  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallHistoryEntry() when $default != null:
return $default(_that.id,_that.type,_that.receiverId,_that.receiverName,_that.receiverPhotoUrl,_that.isOutgoing,_that.status,_that.duration,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CallType type,  String receiverId,  String receiverName,  String? receiverPhotoUrl,  bool isOutgoing,  CallStatus status,  int duration, @TimestampConverter()  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _CallHistoryEntry():
return $default(_that.id,_that.type,_that.receiverId,_that.receiverName,_that.receiverPhotoUrl,_that.isOutgoing,_that.status,_that.duration,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CallType type,  String receiverId,  String receiverName,  String? receiverPhotoUrl,  bool isOutgoing,  CallStatus status,  int duration, @TimestampConverter()  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _CallHistoryEntry() when $default != null:
return $default(_that.id,_that.type,_that.receiverId,_that.receiverName,_that.receiverPhotoUrl,_that.isOutgoing,_that.status,_that.duration,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallHistoryEntry implements CallHistoryEntry {
  const _CallHistoryEntry({required this.id, required this.type, required this.receiverId, required this.receiverName, this.receiverPhotoUrl, required this.isOutgoing, required this.status, required this.duration, @TimestampConverter() this.timestamp});
  factory _CallHistoryEntry.fromJson(Map<String, dynamic> json) => _$CallHistoryEntryFromJson(json);

@override final  String id;
@override final  CallType type;
@override final  String receiverId;
@override final  String receiverName;
@override final  String? receiverPhotoUrl;
@override final  bool isOutgoing;
@override final  CallStatus status;
@override final  int duration;
@override@TimestampConverter() final  DateTime? timestamp;

/// Create a copy of CallHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallHistoryEntryCopyWith<_CallHistoryEntry> get copyWith => __$CallHistoryEntryCopyWithImpl<_CallHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.receiverName, receiverName) || other.receiverName == receiverName)&&(identical(other.receiverPhotoUrl, receiverPhotoUrl) || other.receiverPhotoUrl == receiverPhotoUrl)&&(identical(other.isOutgoing, isOutgoing) || other.isOutgoing == isOutgoing)&&(identical(other.status, status) || other.status == status)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,receiverId,receiverName,receiverPhotoUrl,isOutgoing,status,duration,timestamp);

@override
String toString() {
  return 'CallHistoryEntry(id: $id, type: $type, receiverId: $receiverId, receiverName: $receiverName, receiverPhotoUrl: $receiverPhotoUrl, isOutgoing: $isOutgoing, status: $status, duration: $duration, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$CallHistoryEntryCopyWith<$Res> implements $CallHistoryEntryCopyWith<$Res> {
  factory _$CallHistoryEntryCopyWith(_CallHistoryEntry value, $Res Function(_CallHistoryEntry) _then) = __$CallHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, CallType type, String receiverId, String receiverName, String? receiverPhotoUrl, bool isOutgoing, CallStatus status, int duration,@TimestampConverter() DateTime? timestamp
});




}
/// @nodoc
class __$CallHistoryEntryCopyWithImpl<$Res>
    implements _$CallHistoryEntryCopyWith<$Res> {
  __$CallHistoryEntryCopyWithImpl(this._self, this._then);

  final _CallHistoryEntry _self;
  final $Res Function(_CallHistoryEntry) _then;

/// Create a copy of CallHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? receiverId = null,Object? receiverName = null,Object? receiverPhotoUrl = freezed,Object? isOutgoing = null,Object? status = null,Object? duration = null,Object? timestamp = freezed,}) {
  return _then(_CallHistoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CallType,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,receiverName: null == receiverName ? _self.receiverName : receiverName // ignore: cast_nullable_to_non_nullable
as String,receiverPhotoUrl: freezed == receiverPhotoUrl ? _self.receiverPhotoUrl : receiverPhotoUrl // ignore: cast_nullable_to_non_nullable
as String?,isOutgoing: null == isOutgoing ? _self.isOutgoing : isOutgoing // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CallStatus,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
