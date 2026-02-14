// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
GamificationStats _$GamificationStatsFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'rider':
          return RiderGamificationStats.fromJson(
            json
          );
                case 'driver':
          return DriverGamificationStats.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'GamificationStats',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$GamificationStats {

 int get totalXP; int get level; int get currentLevelXP; int get xpToNextLevel; int get totalRides; int get currentStreak; int get longestStreak; double get co2Saved; double get totalDistance; List<String> get unlockedBadges; List<Achievement> get achievements;@TimestampConverter() DateTime? get lastRideDate;
/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamificationStatsCopyWith<GamificationStats> get copyWith => _$GamificationStatsCopyWithImpl<GamificationStats>(this as GamificationStats, _$identity);

  /// Serializes this GamificationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other.unlockedBadges, unlockedBadges)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalDistance,const DeepCollectionEquality().hash(unlockedBadges),const DeepCollectionEquality().hash(achievements),lastRideDate);

@override
String toString() {
  return 'GamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class $GamificationStatsCopyWith<$Res>  {
  factory $GamificationStatsCopyWith(GamificationStats value, $Res Function(GamificationStats) _then) = _$GamificationStatsCopyWithImpl;
@useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class _$GamificationStatsCopyWithImpl<$Res>
    implements $GamificationStatsCopyWith<$Res> {
  _$GamificationStatsCopyWithImpl(this._self, this._then);

  final GamificationStats _self;
  final $Res Function(GamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_self.copyWith(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self.unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GamificationStats].
extension GamificationStatsPatterns on GamificationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RiderGamificationStats value)?  rider,TResult Function( DriverGamificationStats value)?  driver,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RiderGamificationStats() when rider != null:
return rider(_that);case DriverGamificationStats() when driver != null:
return driver(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RiderGamificationStats value)  rider,required TResult Function( DriverGamificationStats value)  driver,}){
final _that = this;
switch (_that) {
case RiderGamificationStats():
return rider(_that);case DriverGamificationStats():
return driver(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RiderGamificationStats value)?  rider,TResult? Function( DriverGamificationStats value)?  driver,}){
final _that = this;
switch (_that) {
case RiderGamificationStats() when rider != null:
return rider(_that);case DriverGamificationStats() when driver != null:
return driver(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double moneySaved)?  rider,TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double totalEarnings)?  driver,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RiderGamificationStats() when rider != null:
return rider(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.moneySaved);case DriverGamificationStats() when driver != null:
return driver(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double moneySaved)  rider,required TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double totalEarnings)  driver,}) {final _that = this;
switch (_that) {
case RiderGamificationStats():
return rider(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.moneySaved);case DriverGamificationStats():
return driver(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.totalEarnings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double moneySaved)?  rider,TResult? Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate,  double totalEarnings)?  driver,}) {final _that = this;
switch (_that) {
case RiderGamificationStats() when rider != null:
return rider(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.moneySaved);case DriverGamificationStats() when driver != null:
return driver(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate,_that.totalEarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class RiderGamificationStats extends GamificationStats {
  const RiderGamificationStats({this.totalXP = 0, this.level = 1, this.currentLevelXP = 0, this.xpToNextLevel = 1000, this.totalRides = 0, this.currentStreak = 0, this.longestStreak = 0, this.co2Saved = 0.0, this.totalDistance = 0.0, final  List<String> unlockedBadges = const [], final  List<Achievement> achievements = const [], @TimestampConverter() this.lastRideDate, this.moneySaved = 0.0, final  String? $type}): _unlockedBadges = unlockedBadges,_achievements = achievements,$type = $type ?? 'rider',super._();
  factory RiderGamificationStats.fromJson(Map<String, dynamic> json) => _$RiderGamificationStatsFromJson(json);

@override@JsonKey() final  int totalXP;
@override@JsonKey() final  int level;
@override@JsonKey() final  int currentLevelXP;
@override@JsonKey() final  int xpToNextLevel;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  double co2Saved;
@override@JsonKey() final  double totalDistance;
 final  List<String> _unlockedBadges;
@override@JsonKey() List<String> get unlockedBadges {
  if (_unlockedBadges is EqualUnmodifiableListView) return _unlockedBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlockedBadges);
}

 final  List<Achievement> _achievements;
@override@JsonKey() List<Achievement> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

@override@TimestampConverter() final  DateTime? lastRideDate;
// RIDER SPECIFIC
@JsonKey() final  double moneySaved;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderGamificationStatsCopyWith<RiderGamificationStats> get copyWith => _$RiderGamificationStatsCopyWithImpl<RiderGamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderGamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate)&&(identical(other.moneySaved, moneySaved) || other.moneySaved == moneySaved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements),lastRideDate,moneySaved);

@override
String toString() {
  return 'GamificationStats.rider(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate, moneySaved: $moneySaved)';
}


}

/// @nodoc
abstract mixin class $RiderGamificationStatsCopyWith<$Res> implements $GamificationStatsCopyWith<$Res> {
  factory $RiderGamificationStatsCopyWith(RiderGamificationStats value, $Res Function(RiderGamificationStats) _then) = _$RiderGamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate, double moneySaved
});




}
/// @nodoc
class _$RiderGamificationStatsCopyWithImpl<$Res>
    implements $RiderGamificationStatsCopyWith<$Res> {
  _$RiderGamificationStatsCopyWithImpl(this._self, this._then);

  final RiderGamificationStats _self;
  final $Res Function(RiderGamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,Object? moneySaved = null,}) {
  return _then(RiderGamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self._unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,moneySaved: null == moneySaved ? _self.moneySaved : moneySaved // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DriverGamificationStats extends GamificationStats {
  const DriverGamificationStats({this.totalXP = 0, this.level = 1, this.currentLevelXP = 0, this.xpToNextLevel = 1000, this.totalRides = 0, this.currentStreak = 0, this.longestStreak = 0, this.co2Saved = 0.0, this.totalDistance = 0.0, final  List<String> unlockedBadges = const [], final  List<Achievement> achievements = const [], @TimestampConverter() this.lastRideDate, this.totalEarnings = 0.0, final  String? $type}): _unlockedBadges = unlockedBadges,_achievements = achievements,$type = $type ?? 'driver',super._();
  factory DriverGamificationStats.fromJson(Map<String, dynamic> json) => _$DriverGamificationStatsFromJson(json);

@override@JsonKey() final  int totalXP;
@override@JsonKey() final  int level;
@override@JsonKey() final  int currentLevelXP;
@override@JsonKey() final  int xpToNextLevel;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  double co2Saved;
@override@JsonKey() final  double totalDistance;
 final  List<String> _unlockedBadges;
@override@JsonKey() List<String> get unlockedBadges {
  if (_unlockedBadges is EqualUnmodifiableListView) return _unlockedBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unlockedBadges);
}

 final  List<Achievement> _achievements;
@override@JsonKey() List<Achievement> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

@override@TimestampConverter() final  DateTime? lastRideDate;
// DRIVER SPECIFIC
@JsonKey() final  double totalEarnings;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverGamificationStatsCopyWith<DriverGamificationStats> get copyWith => _$DriverGamificationStatsCopyWithImpl<DriverGamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverGamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements),lastRideDate,totalEarnings);

@override
String toString() {
  return 'GamificationStats.driver(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class $DriverGamificationStatsCopyWith<$Res> implements $GamificationStatsCopyWith<$Res> {
  factory $DriverGamificationStatsCopyWith(DriverGamificationStats value, $Res Function(DriverGamificationStats) _then) = _$DriverGamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate, double totalEarnings
});




}
/// @nodoc
class _$DriverGamificationStatsCopyWithImpl<$Res>
    implements $DriverGamificationStatsCopyWith<$Res> {
  _$DriverGamificationStatsCopyWithImpl(this._self, this._then);

  final DriverGamificationStats _self;
  final $Res Function(DriverGamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,Object? totalEarnings = null,}) {
  return _then(DriverGamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self._unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
