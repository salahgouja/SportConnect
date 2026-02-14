// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverStats {

 String get driverId;// Default to empty string to handle null from Firestore
 double get rating; int get totalRides; int get ridesThisWeek; int get ridesThisMonth; int get ridesCompleted; int get pendingRequests; double get totalEarnings; double get earningsThisWeek; double get earningsThisMonth; double get earningsToday; double get co2Saved; double get hoursOnline; double get hoursOnlineThisWeek; bool get isOnline;@TimestampConverter() DateTime? get lastRideAt;
/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverStatsCopyWith<DriverStats> get copyWith => _$DriverStatsCopyWithImpl<DriverStats>(this as DriverStats, _$identity);

  /// Serializes this DriverStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesThisWeek, ridesThisWeek) || other.ridesThisWeek == ridesThisWeek)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth)&&(identical(other.ridesCompleted, ridesCompleted) || other.ridesCompleted == ridesCompleted)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.earningsThisWeek, earningsThisWeek) || other.earningsThisWeek == earningsThisWeek)&&(identical(other.earningsThisMonth, earningsThisMonth) || other.earningsThisMonth == earningsThisMonth)&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.hoursOnline, hoursOnline) || other.hoursOnline == hoursOnline)&&(identical(other.hoursOnlineThisWeek, hoursOnlineThisWeek) || other.hoursOnlineThisWeek == hoursOnlineThisWeek)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,rating,totalRides,ridesThisWeek,ridesThisMonth,ridesCompleted,pendingRequests,totalEarnings,earningsThisWeek,earningsThisMonth,earningsToday,co2Saved,hoursOnline,hoursOnlineThisWeek,isOnline,lastRideAt);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, rating: $rating, totalRides: $totalRides, ridesThisWeek: $ridesThisWeek, ridesThisMonth: $ridesThisMonth, ridesCompleted: $ridesCompleted, pendingRequests: $pendingRequests, totalEarnings: $totalEarnings, earningsThisWeek: $earningsThisWeek, earningsThisMonth: $earningsThisMonth, earningsToday: $earningsToday, co2Saved: $co2Saved, hoursOnline: $hoursOnline, hoursOnlineThisWeek: $hoursOnlineThisWeek, isOnline: $isOnline, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class $DriverStatsCopyWith<$Res>  {
  factory $DriverStatsCopyWith(DriverStats value, $Res Function(DriverStats) _then) = _$DriverStatsCopyWithImpl;
@useResult
$Res call({
 String driverId, double rating, int totalRides, int ridesThisWeek, int ridesThisMonth, int ridesCompleted, int pendingRequests, double totalEarnings, double earningsThisWeek, double earningsThisMonth, double earningsToday, double co2Saved, double hoursOnline, double hoursOnlineThisWeek, bool isOnline,@TimestampConverter() DateTime? lastRideAt
});




}
/// @nodoc
class _$DriverStatsCopyWithImpl<$Res>
    implements $DriverStatsCopyWith<$Res> {
  _$DriverStatsCopyWithImpl(this._self, this._then);

  final DriverStats _self;
  final $Res Function(DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? rating = null,Object? totalRides = null,Object? ridesThisWeek = null,Object? ridesThisMonth = null,Object? ridesCompleted = null,Object? pendingRequests = null,Object? totalEarnings = null,Object? earningsThisWeek = null,Object? earningsThisMonth = null,Object? earningsToday = null,Object? co2Saved = null,Object? hoursOnline = null,Object? hoursOnlineThisWeek = null,Object? isOnline = null,Object? lastRideAt = freezed,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesThisWeek: null == ridesThisWeek ? _self.ridesThisWeek : ridesThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,ridesCompleted: null == ridesCompleted ? _self.ridesCompleted : ridesCompleted // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,earningsThisWeek: null == earningsThisWeek ? _self.earningsThisWeek : earningsThisWeek // ignore: cast_nullable_to_non_nullable
as double,earningsThisMonth: null == earningsThisMonth ? _self.earningsThisMonth : earningsThisMonth // ignore: cast_nullable_to_non_nullable
as double,earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as double,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,hoursOnline: null == hoursOnline ? _self.hoursOnline : hoursOnline // ignore: cast_nullable_to_non_nullable
as double,hoursOnlineThisWeek: null == hoursOnlineThisWeek ? _self.hoursOnlineThisWeek : hoursOnlineThisWeek // ignore: cast_nullable_to_non_nullable
as double,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverStats].
extension DriverStatsPatterns on DriverStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverStats value)  $default,){
final _that = this;
switch (_that) {
case _DriverStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverStats value)?  $default,){
final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String driverId,  double rating,  int totalRides,  int ridesThisWeek,  int ridesThisMonth,  int ridesCompleted,  int pendingRequests,  double totalEarnings,  double earningsThisWeek,  double earningsThisMonth,  double earningsToday,  double co2Saved,  double hoursOnline,  double hoursOnlineThisWeek,  bool isOnline, @TimestampConverter()  DateTime? lastRideAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesThisWeek,_that.ridesThisMonth,_that.ridesCompleted,_that.pendingRequests,_that.totalEarnings,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsToday,_that.co2Saved,_that.hoursOnline,_that.hoursOnlineThisWeek,_that.isOnline,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String driverId,  double rating,  int totalRides,  int ridesThisWeek,  int ridesThisMonth,  int ridesCompleted,  int pendingRequests,  double totalEarnings,  double earningsThisWeek,  double earningsThisMonth,  double earningsToday,  double co2Saved,  double hoursOnline,  double hoursOnlineThisWeek,  bool isOnline, @TimestampConverter()  DateTime? lastRideAt)  $default,) {final _that = this;
switch (_that) {
case _DriverStats():
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesThisWeek,_that.ridesThisMonth,_that.ridesCompleted,_that.pendingRequests,_that.totalEarnings,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsToday,_that.co2Saved,_that.hoursOnline,_that.hoursOnlineThisWeek,_that.isOnline,_that.lastRideAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String driverId,  double rating,  int totalRides,  int ridesThisWeek,  int ridesThisMonth,  int ridesCompleted,  int pendingRequests,  double totalEarnings,  double earningsThisWeek,  double earningsThisMonth,  double earningsToday,  double co2Saved,  double hoursOnline,  double hoursOnlineThisWeek,  bool isOnline, @TimestampConverter()  DateTime? lastRideAt)?  $default,) {final _that = this;
switch (_that) {
case _DriverStats() when $default != null:
return $default(_that.driverId,_that.rating,_that.totalRides,_that.ridesThisWeek,_that.ridesThisMonth,_that.ridesCompleted,_that.pendingRequests,_that.totalEarnings,_that.earningsThisWeek,_that.earningsThisMonth,_that.earningsToday,_that.co2Saved,_that.hoursOnline,_that.hoursOnlineThisWeek,_that.isOnline,_that.lastRideAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverStats implements DriverStats {
  const _DriverStats({this.driverId = '', this.rating = 0.0, this.totalRides = 0, this.ridesThisWeek = 0, this.ridesThisMonth = 0, this.ridesCompleted = 0, this.pendingRequests = 0, this.totalEarnings = 0.0, this.earningsThisWeek = 0.0, this.earningsThisMonth = 0.0, this.earningsToday = 0.0, this.co2Saved = 0.0, this.hoursOnline = 0.0, this.hoursOnlineThisWeek = 0.0, this.isOnline = false, @TimestampConverter() this.lastRideAt});
  factory _DriverStats.fromJson(Map<String, dynamic> json) => _$DriverStatsFromJson(json);

@override@JsonKey() final  String driverId;
// Default to empty string to handle null from Firestore
@override@JsonKey() final  double rating;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int ridesThisWeek;
@override@JsonKey() final  int ridesThisMonth;
@override@JsonKey() final  int ridesCompleted;
@override@JsonKey() final  int pendingRequests;
@override@JsonKey() final  double totalEarnings;
@override@JsonKey() final  double earningsThisWeek;
@override@JsonKey() final  double earningsThisMonth;
@override@JsonKey() final  double earningsToday;
@override@JsonKey() final  double co2Saved;
@override@JsonKey() final  double hoursOnline;
@override@JsonKey() final  double hoursOnlineThisWeek;
@override@JsonKey() final  bool isOnline;
@override@TimestampConverter() final  DateTime? lastRideAt;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverStatsCopyWith<_DriverStats> get copyWith => __$DriverStatsCopyWithImpl<_DriverStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverStats&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.ridesThisWeek, ridesThisWeek) || other.ridesThisWeek == ridesThisWeek)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth)&&(identical(other.ridesCompleted, ridesCompleted) || other.ridesCompleted == ridesCompleted)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.earningsThisWeek, earningsThisWeek) || other.earningsThisWeek == earningsThisWeek)&&(identical(other.earningsThisMonth, earningsThisMonth) || other.earningsThisMonth == earningsThisMonth)&&(identical(other.earningsToday, earningsToday) || other.earningsToday == earningsToday)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.hoursOnline, hoursOnline) || other.hoursOnline == hoursOnline)&&(identical(other.hoursOnlineThisWeek, hoursOnlineThisWeek) || other.hoursOnlineThisWeek == hoursOnlineThisWeek)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.lastRideAt, lastRideAt) || other.lastRideAt == lastRideAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,rating,totalRides,ridesThisWeek,ridesThisMonth,ridesCompleted,pendingRequests,totalEarnings,earningsThisWeek,earningsThisMonth,earningsToday,co2Saved,hoursOnline,hoursOnlineThisWeek,isOnline,lastRideAt);

@override
String toString() {
  return 'DriverStats(driverId: $driverId, rating: $rating, totalRides: $totalRides, ridesThisWeek: $ridesThisWeek, ridesThisMonth: $ridesThisMonth, ridesCompleted: $ridesCompleted, pendingRequests: $pendingRequests, totalEarnings: $totalEarnings, earningsThisWeek: $earningsThisWeek, earningsThisMonth: $earningsThisMonth, earningsToday: $earningsToday, co2Saved: $co2Saved, hoursOnline: $hoursOnline, hoursOnlineThisWeek: $hoursOnlineThisWeek, isOnline: $isOnline, lastRideAt: $lastRideAt)';
}


}

/// @nodoc
abstract mixin class _$DriverStatsCopyWith<$Res> implements $DriverStatsCopyWith<$Res> {
  factory _$DriverStatsCopyWith(_DriverStats value, $Res Function(_DriverStats) _then) = __$DriverStatsCopyWithImpl;
@override @useResult
$Res call({
 String driverId, double rating, int totalRides, int ridesThisWeek, int ridesThisMonth, int ridesCompleted, int pendingRequests, double totalEarnings, double earningsThisWeek, double earningsThisMonth, double earningsToday, double co2Saved, double hoursOnline, double hoursOnlineThisWeek, bool isOnline,@TimestampConverter() DateTime? lastRideAt
});




}
/// @nodoc
class __$DriverStatsCopyWithImpl<$Res>
    implements _$DriverStatsCopyWith<$Res> {
  __$DriverStatsCopyWithImpl(this._self, this._then);

  final _DriverStats _self;
  final $Res Function(_DriverStats) _then;

/// Create a copy of DriverStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? rating = null,Object? totalRides = null,Object? ridesThisWeek = null,Object? ridesThisMonth = null,Object? ridesCompleted = null,Object? pendingRequests = null,Object? totalEarnings = null,Object? earningsThisWeek = null,Object? earningsThisMonth = null,Object? earningsToday = null,Object? co2Saved = null,Object? hoursOnline = null,Object? hoursOnlineThisWeek = null,Object? isOnline = null,Object? lastRideAt = freezed,}) {
  return _then(_DriverStats(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,ridesThisWeek: null == ridesThisWeek ? _self.ridesThisWeek : ridesThisWeek // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,ridesCompleted: null == ridesCompleted ? _self.ridesCompleted : ridesCompleted // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,earningsThisWeek: null == earningsThisWeek ? _self.earningsThisWeek : earningsThisWeek // ignore: cast_nullable_to_non_nullable
as double,earningsThisMonth: null == earningsThisMonth ? _self.earningsThisMonth : earningsThisMonth // ignore: cast_nullable_to_non_nullable
as double,earningsToday: null == earningsToday ? _self.earningsToday : earningsToday // ignore: cast_nullable_to_non_nullable
as double,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,hoursOnline: null == hoursOnline ? _self.hoursOnline : hoursOnline // ignore: cast_nullable_to_non_nullable
as double,hoursOnlineThisWeek: null == hoursOnlineThisWeek ? _self.hoursOnlineThisWeek : hoursOnlineThisWeek // ignore: cast_nullable_to_non_nullable
as double,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,lastRideAt: freezed == lastRideAt ? _self.lastRideAt : lastRideAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EarningsTransaction {

 String get id; String get rideId; double get amount; String get description; String get type;// ride, bonus, refund, payout
@RequiredTimestampConverter() DateTime get createdAt;
/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsTransactionCopyWith<EarningsTransaction> get copyWith => _$EarningsTransactionCopyWithImpl<EarningsTransaction>(this as EarningsTransaction, _$identity);

  /// Serializes this EarningsTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,amount,description,type,createdAt);

@override
String toString() {
  return 'EarningsTransaction(id: $id, rideId: $rideId, amount: $amount, description: $description, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EarningsTransactionCopyWith<$Res>  {
  factory $EarningsTransactionCopyWith(EarningsTransaction value, $Res Function(EarningsTransaction) _then) = _$EarningsTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String rideId, double amount, String description, String type,@RequiredTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$EarningsTransactionCopyWithImpl<$Res>
    implements $EarningsTransactionCopyWith<$Res> {
  _$EarningsTransactionCopyWithImpl(this._self, this._then);

  final EarningsTransaction _self;
  final $Res Function(EarningsTransaction) _then;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rideId = null,Object? amount = null,Object? description = null,Object? type = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsTransaction].
extension EarningsTransactionPatterns on EarningsTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsTransaction value)  $default,){
final _that = this;
switch (_that) {
case _EarningsTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String rideId,  double amount,  String description,  String type, @RequiredTimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.amount,_that.description,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String rideId,  double amount,  String description,  String type, @RequiredTimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _EarningsTransaction():
return $default(_that.id,_that.rideId,_that.amount,_that.description,_that.type,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String rideId,  double amount,  String description,  String type, @RequiredTimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EarningsTransaction() when $default != null:
return $default(_that.id,_that.rideId,_that.amount,_that.description,_that.type,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsTransaction implements EarningsTransaction {
  const _EarningsTransaction({required this.id, required this.rideId, required this.amount, required this.description, this.type = 'ride', @RequiredTimestampConverter() required this.createdAt});
  factory _EarningsTransaction.fromJson(Map<String, dynamic> json) => _$EarningsTransactionFromJson(json);

@override final  String id;
@override final  String rideId;
@override final  double amount;
@override final  String description;
@override@JsonKey() final  String type;
// ride, bonus, refund, payout
@override@RequiredTimestampConverter() final  DateTime createdAt;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsTransactionCopyWith<_EarningsTransaction> get copyWith => __$EarningsTransactionCopyWithImpl<_EarningsTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.rideId, rideId) || other.rideId == rideId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rideId,amount,description,type,createdAt);

@override
String toString() {
  return 'EarningsTransaction(id: $id, rideId: $rideId, amount: $amount, description: $description, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EarningsTransactionCopyWith<$Res> implements $EarningsTransactionCopyWith<$Res> {
  factory _$EarningsTransactionCopyWith(_EarningsTransaction value, $Res Function(_EarningsTransaction) _then) = __$EarningsTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String rideId, double amount, String description, String type,@RequiredTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$EarningsTransactionCopyWithImpl<$Res>
    implements _$EarningsTransactionCopyWith<$Res> {
  __$EarningsTransactionCopyWithImpl(this._self, this._then);

  final _EarningsTransaction _self;
  final $Res Function(_EarningsTransaction) _then;

/// Create a copy of EarningsTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rideId = null,Object? amount = null,Object? description = null,Object? type = null,Object? createdAt = null,}) {
  return _then(_EarningsTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rideId: null == rideId ? _self.rideId : rideId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
