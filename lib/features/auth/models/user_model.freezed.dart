// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {

 String get id; String get title; String get description; String get iconName; int get xpReward; bool get isUnlocked;@TimestampConverter() DateTime? get unlockedAt;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconName,xpReward,isUnlocked,unlockedAt);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, iconName: $iconName, xpReward: $xpReward, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String iconName, int xpReward, bool isUnlocked,@TimestampConverter() DateTime? unlockedAt
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconName = null,Object? xpReward = null,Object? isUnlocked = null,Object? unlockedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconName,  int xpReward,  bool isUnlocked, @TimestampConverter()  DateTime? unlockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.xpReward,_that.isUnlocked,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String iconName,  int xpReward,  bool isUnlocked, @TimestampConverter()  DateTime? unlockedAt)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.xpReward,_that.isUnlocked,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String iconName,  int xpReward,  bool isUnlocked, @TimestampConverter()  DateTime? unlockedAt)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.iconName,_that.xpReward,_that.isUnlocked,_that.unlockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement implements Achievement {
  const _Achievement({required this.id, required this.title, required this.description, required this.iconName, required this.xpReward, this.isUnlocked = false, @TimestampConverter() this.unlockedAt});
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String iconName;
@override final  int xpReward;
@override@JsonKey() final  bool isUnlocked;
@override@TimestampConverter() final  DateTime? unlockedAt;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.xpReward, xpReward) || other.xpReward == xpReward)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,iconName,xpReward,isUnlocked,unlockedAt);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, iconName: $iconName, xpReward: $xpReward, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String iconName, int xpReward, bool isUnlocked,@TimestampConverter() DateTime? unlockedAt
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? iconName = null,Object? xpReward = null,Object? isUnlocked = null,Object? unlockedAt = freezed,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,xpReward: null == xpReward ? _self.xpReward : xpReward // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamificationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamificationStats value)  $default,){
final _that = this;
switch (_that) {
case _GamificationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamificationStats value)?  $default,){
final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)  $default,) {final _that = this;
switch (_that) {
case _GamificationStats():
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,) {final _that = this;
switch (_that) {
case _GamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GamificationStats implements GamificationStats {
  const _GamificationStats({this.totalXP = 0, this.level = 1, this.currentLevelXP = 0, this.xpToNextLevel = 1000, this.totalRides = 0, this.currentStreak = 0, this.longestStreak = 0, this.co2Saved = 0.0, this.totalDistance = 0.0, final  List<String> unlockedBadges = const [], final  List<Achievement> achievements = const [], @TimestampConverter() this.lastRideDate}): _unlockedBadges = unlockedBadges,_achievements = achievements;
  factory _GamificationStats.fromJson(Map<String, dynamic> json) => _$GamificationStatsFromJson(json);

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

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamificationStatsCopyWith<_GamificationStats> get copyWith => __$GamificationStatsCopyWithImpl<_GamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements),lastRideDate);

@override
String toString() {
  return 'GamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class _$GamificationStatsCopyWith<$Res> implements $GamificationStatsCopyWith<$Res> {
  factory _$GamificationStatsCopyWith(_GamificationStats value, $Res Function(_GamificationStats) _then) = __$GamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class __$GamificationStatsCopyWithImpl<$Res>
    implements _$GamificationStatsCopyWith<$Res> {
  __$GamificationStatsCopyWithImpl(this._self, this._then);

  final _GamificationStats _self;
  final $Res Function(_GamificationStats) _then;

/// Create a copy of GamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_GamificationStats(
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
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RiderGamificationStats {

 int get totalXP; int get level; int get currentLevelXP; int get xpToNextLevel; int get totalRides; int get currentStreak; int get longestStreak; double get co2Saved; double get moneySaved; double get totalDistance; List<String> get unlockedBadges; List<Achievement> get achievements;@TimestampConverter() DateTime? get lastRideDate;
/// Create a copy of RiderGamificationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderGamificationStatsCopyWith<RiderGamificationStats> get copyWith => _$RiderGamificationStatsCopyWithImpl<RiderGamificationStats>(this as RiderGamificationStats, _$identity);

  /// Serializes this RiderGamificationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.moneySaved, moneySaved) || other.moneySaved == moneySaved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other.unlockedBadges, unlockedBadges)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,moneySaved,totalDistance,const DeepCollectionEquality().hash(unlockedBadges),const DeepCollectionEquality().hash(achievements),lastRideDate);

@override
String toString() {
  return 'RiderGamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, moneySaved: $moneySaved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class $RiderGamificationStatsCopyWith<$Res>  {
  factory $RiderGamificationStatsCopyWith(RiderGamificationStats value, $Res Function(RiderGamificationStats) _then) = _$RiderGamificationStatsCopyWithImpl;
@useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double moneySaved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class _$RiderGamificationStatsCopyWithImpl<$Res>
    implements $RiderGamificationStatsCopyWith<$Res> {
  _$RiderGamificationStatsCopyWithImpl(this._self, this._then);

  final RiderGamificationStats _self;
  final $Res Function(RiderGamificationStats) _then;

/// Create a copy of RiderGamificationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? moneySaved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_self.copyWith(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,moneySaved: null == moneySaved ? _self.moneySaved : moneySaved // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self.unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RiderGamificationStats].
extension RiderGamificationStatsPatterns on RiderGamificationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RiderGamificationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RiderGamificationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RiderGamificationStats value)  $default,){
final _that = this;
switch (_that) {
case _RiderGamificationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RiderGamificationStats value)?  $default,){
final _that = this;
switch (_that) {
case _RiderGamificationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double moneySaved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RiderGamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.moneySaved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double moneySaved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)  $default,) {final _that = this;
switch (_that) {
case _RiderGamificationStats():
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.moneySaved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double moneySaved,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,) {final _that = this;
switch (_that) {
case _RiderGamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.moneySaved,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RiderGamificationStats implements RiderGamificationStats {
  const _RiderGamificationStats({this.totalXP = 0, this.level = 1, this.currentLevelXP = 0, this.xpToNextLevel = 1000, this.totalRides = 0, this.currentStreak = 0, this.longestStreak = 0, this.co2Saved = 0.0, this.moneySaved = 0.0, this.totalDistance = 0.0, final  List<String> unlockedBadges = const [], final  List<Achievement> achievements = const [], @TimestampConverter() this.lastRideDate}): _unlockedBadges = unlockedBadges,_achievements = achievements;
  factory _RiderGamificationStats.fromJson(Map<String, dynamic> json) => _$RiderGamificationStatsFromJson(json);

@override@JsonKey() final  int totalXP;
@override@JsonKey() final  int level;
@override@JsonKey() final  int currentLevelXP;
@override@JsonKey() final  int xpToNextLevel;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  double co2Saved;
@override@JsonKey() final  double moneySaved;
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

/// Create a copy of RiderGamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RiderGamificationStatsCopyWith<_RiderGamificationStats> get copyWith => __$RiderGamificationStatsCopyWithImpl<_RiderGamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderGamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RiderGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.moneySaved, moneySaved) || other.moneySaved == moneySaved)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,moneySaved,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements),lastRideDate);

@override
String toString() {
  return 'RiderGamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, moneySaved: $moneySaved, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class _$RiderGamificationStatsCopyWith<$Res> implements $RiderGamificationStatsCopyWith<$Res> {
  factory _$RiderGamificationStatsCopyWith(_RiderGamificationStats value, $Res Function(_RiderGamificationStats) _then) = __$RiderGamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double moneySaved, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class __$RiderGamificationStatsCopyWithImpl<$Res>
    implements _$RiderGamificationStatsCopyWith<$Res> {
  __$RiderGamificationStatsCopyWithImpl(this._self, this._then);

  final _RiderGamificationStats _self;
  final $Res Function(_RiderGamificationStats) _then;

/// Create a copy of RiderGamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? moneySaved = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_RiderGamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,moneySaved: null == moneySaved ? _self.moneySaved : moneySaved // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self._unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DriverGamificationStats {

 int get totalXP; int get level; int get currentLevelXP; int get xpToNextLevel; int get totalRides; int get currentStreak; int get longestStreak; double get co2Saved; double get totalEarnings; double get totalDistance; List<String> get unlockedBadges; List<Achievement> get achievements;@TimestampConverter() DateTime? get lastRideDate;
/// Create a copy of DriverGamificationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverGamificationStatsCopyWith<DriverGamificationStats> get copyWith => _$DriverGamificationStatsCopyWithImpl<DriverGamificationStats>(this as DriverGamificationStats, _$identity);

  /// Serializes this DriverGamificationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other.unlockedBadges, unlockedBadges)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalEarnings,totalDistance,const DeepCollectionEquality().hash(unlockedBadges),const DeepCollectionEquality().hash(achievements),lastRideDate);

@override
String toString() {
  return 'DriverGamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalEarnings: $totalEarnings, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class $DriverGamificationStatsCopyWith<$Res>  {
  factory $DriverGamificationStatsCopyWith(DriverGamificationStats value, $Res Function(DriverGamificationStats) _then) = _$DriverGamificationStatsCopyWithImpl;
@useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalEarnings, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class _$DriverGamificationStatsCopyWithImpl<$Res>
    implements $DriverGamificationStatsCopyWith<$Res> {
  _$DriverGamificationStatsCopyWithImpl(this._self, this._then);

  final DriverGamificationStats _self;
  final $Res Function(DriverGamificationStats) _then;

/// Create a copy of DriverGamificationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalEarnings = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_self.copyWith(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self.unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverGamificationStats].
extension DriverGamificationStatsPatterns on DriverGamificationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverGamificationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverGamificationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverGamificationStats value)  $default,){
final _that = this;
switch (_that) {
case _DriverGamificationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverGamificationStats value)?  $default,){
final _that = this;
switch (_that) {
case _DriverGamificationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalEarnings,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverGamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalEarnings,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalEarnings,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)  $default,) {final _that = this;
switch (_that) {
case _DriverGamificationStats():
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalEarnings,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalXP,  int level,  int currentLevelXP,  int xpToNextLevel,  int totalRides,  int currentStreak,  int longestStreak,  double co2Saved,  double totalEarnings,  double totalDistance,  List<String> unlockedBadges,  List<Achievement> achievements, @TimestampConverter()  DateTime? lastRideDate)?  $default,) {final _that = this;
switch (_that) {
case _DriverGamificationStats() when $default != null:
return $default(_that.totalXP,_that.level,_that.currentLevelXP,_that.xpToNextLevel,_that.totalRides,_that.currentStreak,_that.longestStreak,_that.co2Saved,_that.totalEarnings,_that.totalDistance,_that.unlockedBadges,_that.achievements,_that.lastRideDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverGamificationStats implements DriverGamificationStats {
  const _DriverGamificationStats({this.totalXP = 0, this.level = 1, this.currentLevelXP = 0, this.xpToNextLevel = 1000, this.totalRides = 0, this.currentStreak = 0, this.longestStreak = 0, this.co2Saved = 0.0, this.totalEarnings = 0.0, this.totalDistance = 0.0, final  List<String> unlockedBadges = const [], final  List<Achievement> achievements = const [], @TimestampConverter() this.lastRideDate}): _unlockedBadges = unlockedBadges,_achievements = achievements;
  factory _DriverGamificationStats.fromJson(Map<String, dynamic> json) => _$DriverGamificationStatsFromJson(json);

@override@JsonKey() final  int totalXP;
@override@JsonKey() final  int level;
@override@JsonKey() final  int currentLevelXP;
@override@JsonKey() final  int xpToNextLevel;
@override@JsonKey() final  int totalRides;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override@JsonKey() final  double co2Saved;
@override@JsonKey() final  double totalEarnings;
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

/// Create a copy of DriverGamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverGamificationStatsCopyWith<_DriverGamificationStats> get copyWith => __$DriverGamificationStatsCopyWithImpl<_DriverGamificationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverGamificationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverGamificationStats&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentLevelXP, currentLevelXP) || other.currentLevelXP == currentLevelXP)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel)&&(identical(other.totalRides, totalRides) || other.totalRides == totalRides)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.co2Saved, co2Saved) || other.co2Saved == co2Saved)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&const DeepCollectionEquality().equals(other._unlockedBadges, _unlockedBadges)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.lastRideDate, lastRideDate) || other.lastRideDate == lastRideDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalXP,level,currentLevelXP,xpToNextLevel,totalRides,currentStreak,longestStreak,co2Saved,totalEarnings,totalDistance,const DeepCollectionEquality().hash(_unlockedBadges),const DeepCollectionEquality().hash(_achievements),lastRideDate);

@override
String toString() {
  return 'DriverGamificationStats(totalXP: $totalXP, level: $level, currentLevelXP: $currentLevelXP, xpToNextLevel: $xpToNextLevel, totalRides: $totalRides, currentStreak: $currentStreak, longestStreak: $longestStreak, co2Saved: $co2Saved, totalEarnings: $totalEarnings, totalDistance: $totalDistance, unlockedBadges: $unlockedBadges, achievements: $achievements, lastRideDate: $lastRideDate)';
}


}

/// @nodoc
abstract mixin class _$DriverGamificationStatsCopyWith<$Res> implements $DriverGamificationStatsCopyWith<$Res> {
  factory _$DriverGamificationStatsCopyWith(_DriverGamificationStats value, $Res Function(_DriverGamificationStats) _then) = __$DriverGamificationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalXP, int level, int currentLevelXP, int xpToNextLevel, int totalRides, int currentStreak, int longestStreak, double co2Saved, double totalEarnings, double totalDistance, List<String> unlockedBadges, List<Achievement> achievements,@TimestampConverter() DateTime? lastRideDate
});




}
/// @nodoc
class __$DriverGamificationStatsCopyWithImpl<$Res>
    implements _$DriverGamificationStatsCopyWith<$Res> {
  __$DriverGamificationStatsCopyWithImpl(this._self, this._then);

  final _DriverGamificationStats _self;
  final $Res Function(_DriverGamificationStats) _then;

/// Create a copy of DriverGamificationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalXP = null,Object? level = null,Object? currentLevelXP = null,Object? xpToNextLevel = null,Object? totalRides = null,Object? currentStreak = null,Object? longestStreak = null,Object? co2Saved = null,Object? totalEarnings = null,Object? totalDistance = null,Object? unlockedBadges = null,Object? achievements = null,Object? lastRideDate = freezed,}) {
  return _then(_DriverGamificationStats(
totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentLevelXP: null == currentLevelXP ? _self.currentLevelXP : currentLevelXP // ignore: cast_nullable_to_non_nullable
as int,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,totalRides: null == totalRides ? _self.totalRides : totalRides // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,co2Saved: null == co2Saved ? _self.co2Saved : co2Saved // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,unlockedBadges: null == unlockedBadges ? _self._unlockedBadges : unlockedBadges // ignore: cast_nullable_to_non_nullable
as List<String>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,lastRideDate: freezed == lastRideDate ? _self.lastRideDate : lastRideDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UserPreferences {

 bool get notificationsEnabled; bool get emailNotifications; bool get rideReminders; bool get chatNotifications; bool get marketingEmails; String get language; String get theme; double get maxPickupRadius; bool get showOnlineStatus; bool get allowMessages;
/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<UserPreferences> get copyWith => _$UserPreferencesCopyWithImpl<UserPreferences>(this as UserPreferences, _$identity);

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreferences&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.rideReminders, rideReminders) || other.rideReminders == rideReminders)&&(identical(other.chatNotifications, chatNotifications) || other.chatNotifications == chatNotifications)&&(identical(other.marketingEmails, marketingEmails) || other.marketingEmails == marketingEmails)&&(identical(other.language, language) || other.language == language)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.maxPickupRadius, maxPickupRadius) || other.maxPickupRadius == maxPickupRadius)&&(identical(other.showOnlineStatus, showOnlineStatus) || other.showOnlineStatus == showOnlineStatus)&&(identical(other.allowMessages, allowMessages) || other.allowMessages == allowMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,emailNotifications,rideReminders,chatNotifications,marketingEmails,language,theme,maxPickupRadius,showOnlineStatus,allowMessages);

@override
String toString() {
  return 'UserPreferences(notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, rideReminders: $rideReminders, chatNotifications: $chatNotifications, marketingEmails: $marketingEmails, language: $language, theme: $theme, maxPickupRadius: $maxPickupRadius, showOnlineStatus: $showOnlineStatus, allowMessages: $allowMessages)';
}


}

/// @nodoc
abstract mixin class $UserPreferencesCopyWith<$Res>  {
  factory $UserPreferencesCopyWith(UserPreferences value, $Res Function(UserPreferences) _then) = _$UserPreferencesCopyWithImpl;
@useResult
$Res call({
 bool notificationsEnabled, bool emailNotifications, bool rideReminders, bool chatNotifications, bool marketingEmails, String language, String theme, double maxPickupRadius, bool showOnlineStatus, bool allowMessages
});




}
/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._self, this._then);

  final UserPreferences _self;
  final $Res Function(UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? emailNotifications = null,Object? rideReminders = null,Object? chatNotifications = null,Object? marketingEmails = null,Object? language = null,Object? theme = null,Object? maxPickupRadius = null,Object? showOnlineStatus = null,Object? allowMessages = null,}) {
  return _then(_self.copyWith(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,rideReminders: null == rideReminders ? _self.rideReminders : rideReminders // ignore: cast_nullable_to_non_nullable
as bool,chatNotifications: null == chatNotifications ? _self.chatNotifications : chatNotifications // ignore: cast_nullable_to_non_nullable
as bool,marketingEmails: null == marketingEmails ? _self.marketingEmails : marketingEmails // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,maxPickupRadius: null == maxPickupRadius ? _self.maxPickupRadius : maxPickupRadius // ignore: cast_nullable_to_non_nullable
as double,showOnlineStatus: null == showOnlineStatus ? _self.showOnlineStatus : showOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool,allowMessages: null == allowMessages ? _self.allowMessages : allowMessages // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreferences].
extension UserPreferencesPatterns on UserPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreferences value)  $default,){
final _that = this;
switch (_that) {
case _UserPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool emailNotifications,  bool rideReminders,  bool chatNotifications,  bool marketingEmails,  String language,  String theme,  double maxPickupRadius,  bool showOnlineStatus,  bool allowMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.notificationsEnabled,_that.emailNotifications,_that.rideReminders,_that.chatNotifications,_that.marketingEmails,_that.language,_that.theme,_that.maxPickupRadius,_that.showOnlineStatus,_that.allowMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool emailNotifications,  bool rideReminders,  bool chatNotifications,  bool marketingEmails,  String language,  String theme,  double maxPickupRadius,  bool showOnlineStatus,  bool allowMessages)  $default,) {final _that = this;
switch (_that) {
case _UserPreferences():
return $default(_that.notificationsEnabled,_that.emailNotifications,_that.rideReminders,_that.chatNotifications,_that.marketingEmails,_that.language,_that.theme,_that.maxPickupRadius,_that.showOnlineStatus,_that.allowMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool notificationsEnabled,  bool emailNotifications,  bool rideReminders,  bool chatNotifications,  bool marketingEmails,  String language,  String theme,  double maxPickupRadius,  bool showOnlineStatus,  bool allowMessages)?  $default,) {final _that = this;
switch (_that) {
case _UserPreferences() when $default != null:
return $default(_that.notificationsEnabled,_that.emailNotifications,_that.rideReminders,_that.chatNotifications,_that.marketingEmails,_that.language,_that.theme,_that.maxPickupRadius,_that.showOnlineStatus,_that.allowMessages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreferences implements UserPreferences {
  const _UserPreferences({this.notificationsEnabled = true, this.emailNotifications = true, this.rideReminders = true, this.chatNotifications = true, this.marketingEmails = true, this.language = 'en', this.theme = 'system', this.maxPickupRadius = 5.0, this.showOnlineStatus = true, this.allowMessages = true});
  factory _UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);

@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool emailNotifications;
@override@JsonKey() final  bool rideReminders;
@override@JsonKey() final  bool chatNotifications;
@override@JsonKey() final  bool marketingEmails;
@override@JsonKey() final  String language;
@override@JsonKey() final  String theme;
@override@JsonKey() final  double maxPickupRadius;
@override@JsonKey() final  bool showOnlineStatus;
@override@JsonKey() final  bool allowMessages;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferencesCopyWith<_UserPreferences> get copyWith => __$UserPreferencesCopyWithImpl<_UserPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreferences&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.emailNotifications, emailNotifications) || other.emailNotifications == emailNotifications)&&(identical(other.rideReminders, rideReminders) || other.rideReminders == rideReminders)&&(identical(other.chatNotifications, chatNotifications) || other.chatNotifications == chatNotifications)&&(identical(other.marketingEmails, marketingEmails) || other.marketingEmails == marketingEmails)&&(identical(other.language, language) || other.language == language)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.maxPickupRadius, maxPickupRadius) || other.maxPickupRadius == maxPickupRadius)&&(identical(other.showOnlineStatus, showOnlineStatus) || other.showOnlineStatus == showOnlineStatus)&&(identical(other.allowMessages, allowMessages) || other.allowMessages == allowMessages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,emailNotifications,rideReminders,chatNotifications,marketingEmails,language,theme,maxPickupRadius,showOnlineStatus,allowMessages);

@override
String toString() {
  return 'UserPreferences(notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, rideReminders: $rideReminders, chatNotifications: $chatNotifications, marketingEmails: $marketingEmails, language: $language, theme: $theme, maxPickupRadius: $maxPickupRadius, showOnlineStatus: $showOnlineStatus, allowMessages: $allowMessages)';
}


}

/// @nodoc
abstract mixin class _$UserPreferencesCopyWith<$Res> implements $UserPreferencesCopyWith<$Res> {
  factory _$UserPreferencesCopyWith(_UserPreferences value, $Res Function(_UserPreferences) _then) = __$UserPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool notificationsEnabled, bool emailNotifications, bool rideReminders, bool chatNotifications, bool marketingEmails, String language, String theme, double maxPickupRadius, bool showOnlineStatus, bool allowMessages
});




}
/// @nodoc
class __$UserPreferencesCopyWithImpl<$Res>
    implements _$UserPreferencesCopyWith<$Res> {
  __$UserPreferencesCopyWithImpl(this._self, this._then);

  final _UserPreferences _self;
  final $Res Function(_UserPreferences) _then;

/// Create a copy of UserPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? emailNotifications = null,Object? rideReminders = null,Object? chatNotifications = null,Object? marketingEmails = null,Object? language = null,Object? theme = null,Object? maxPickupRadius = null,Object? showOnlineStatus = null,Object? allowMessages = null,}) {
  return _then(_UserPreferences(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailNotifications: null == emailNotifications ? _self.emailNotifications : emailNotifications // ignore: cast_nullable_to_non_nullable
as bool,rideReminders: null == rideReminders ? _self.rideReminders : rideReminders // ignore: cast_nullable_to_non_nullable
as bool,chatNotifications: null == chatNotifications ? _self.chatNotifications : chatNotifications // ignore: cast_nullable_to_non_nullable
as bool,marketingEmails: null == marketingEmails ? _self.marketingEmails : marketingEmails // ignore: cast_nullable_to_non_nullable
as bool,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,maxPickupRadius: null == maxPickupRadius ? _self.maxPickupRadius : maxPickupRadius // ignore: cast_nullable_to_non_nullable
as double,showOnlineStatus: null == showOnlineStatus ? _self.showOnlineStatus : showOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool,allowMessages: null == allowMessages ? _self.allowMessages : allowMessages // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Vehicle {

 String get id; String get make; String get model; String get fuelType; int get year; String get color; String get licensePlate; int get seats; String? get imageUrl; bool get isDefault; bool get isVerified;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.year, year) || other.year == year)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,make,model,fuelType,year,color,licensePlate,seats,imageUrl,isDefault,isVerified);

@override
String toString() {
  return 'Vehicle(id: $id, make: $make, model: $model, fuelType: $fuelType, year: $year, color: $color, licensePlate: $licensePlate, seats: $seats, imageUrl: $imageUrl, isDefault: $isDefault, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 String id, String make, String model, String fuelType, int year, String color, String licensePlate, int seats, String? imageUrl, bool isDefault, bool isVerified
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? make = null,Object? model = null,Object? fuelType = null,Object? year = null,Object? color = null,Object? licensePlate = null,Object? seats = null,Object? imageUrl = freezed,Object? isDefault = null,Object? isVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String make,  String model,  String fuelType,  int year,  String color,  String licensePlate,  int seats,  String? imageUrl,  bool isDefault,  bool isVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.fuelType,_that.year,_that.color,_that.licensePlate,_that.seats,_that.imageUrl,_that.isDefault,_that.isVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String make,  String model,  String fuelType,  int year,  String color,  String licensePlate,  int seats,  String? imageUrl,  bool isDefault,  bool isVerified)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.id,_that.make,_that.model,_that.fuelType,_that.year,_that.color,_that.licensePlate,_that.seats,_that.imageUrl,_that.isDefault,_that.isVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String make,  String model,  String fuelType,  int year,  String color,  String licensePlate,  int seats,  String? imageUrl,  bool isDefault,  bool isVerified)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.fuelType,_that.year,_that.color,_that.licensePlate,_that.seats,_that.imageUrl,_that.isDefault,_that.isVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vehicle implements Vehicle {
  const _Vehicle({required this.id, required this.make, required this.model, required this.fuelType, required this.year, required this.color, required this.licensePlate, this.seats = 4, this.imageUrl, this.isDefault = false, this.isVerified = false});
  factory _Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

@override final  String id;
@override final  String make;
@override final  String model;
@override final  String fuelType;
@override final  int year;
@override final  String color;
@override final  String licensePlate;
@override@JsonKey() final  int seats;
@override final  String? imageUrl;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isVerified;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.year, year) || other.year == year)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,make,model,fuelType,year,color,licensePlate,seats,imageUrl,isDefault,isVerified);

@override
String toString() {
  return 'Vehicle(id: $id, make: $make, model: $model, fuelType: $fuelType, year: $year, color: $color, licensePlate: $licensePlate, seats: $seats, imageUrl: $imageUrl, isDefault: $isDefault, isVerified: $isVerified)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 String id, String make, String model, String fuelType, int year, String color, String licensePlate, int seats, String? imageUrl, bool isDefault, bool isVerified
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? make = null,Object? model = null,Object? fuelType = null,Object? year = null,Object? color = null,Object? licensePlate = null,Object? seats = null,Object? imageUrl = freezed,Object? isDefault = null,Object? isVerified = null,}) {
  return _then(_Vehicle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,make: null == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RatingBreakdown {

 int get total; double get average; int get fiveStars; int get fourStars; int get threeStars; int get twoStars; int get oneStars;
/// Create a copy of RatingBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<RatingBreakdown> get copyWith => _$RatingBreakdownCopyWithImpl<RatingBreakdown>(this as RatingBreakdown, _$identity);

  /// Serializes this RatingBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RatingBreakdown&&(identical(other.total, total) || other.total == total)&&(identical(other.average, average) || other.average == average)&&(identical(other.fiveStars, fiveStars) || other.fiveStars == fiveStars)&&(identical(other.fourStars, fourStars) || other.fourStars == fourStars)&&(identical(other.threeStars, threeStars) || other.threeStars == threeStars)&&(identical(other.twoStars, twoStars) || other.twoStars == twoStars)&&(identical(other.oneStars, oneStars) || other.oneStars == oneStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,average,fiveStars,fourStars,threeStars,twoStars,oneStars);

@override
String toString() {
  return 'RatingBreakdown(total: $total, average: $average, fiveStars: $fiveStars, fourStars: $fourStars, threeStars: $threeStars, twoStars: $twoStars, oneStars: $oneStars)';
}


}

/// @nodoc
abstract mixin class $RatingBreakdownCopyWith<$Res>  {
  factory $RatingBreakdownCopyWith(RatingBreakdown value, $Res Function(RatingBreakdown) _then) = _$RatingBreakdownCopyWithImpl;
@useResult
$Res call({
 int total, double average, int fiveStars, int fourStars, int threeStars, int twoStars, int oneStars
});




}
/// @nodoc
class _$RatingBreakdownCopyWithImpl<$Res>
    implements $RatingBreakdownCopyWith<$Res> {
  _$RatingBreakdownCopyWithImpl(this._self, this._then);

  final RatingBreakdown _self;
  final $Res Function(RatingBreakdown) _then;

/// Create a copy of RatingBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? average = null,Object? fiveStars = null,Object? fourStars = null,Object? threeStars = null,Object? twoStars = null,Object? oneStars = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,fiveStars: null == fiveStars ? _self.fiveStars : fiveStars // ignore: cast_nullable_to_non_nullable
as int,fourStars: null == fourStars ? _self.fourStars : fourStars // ignore: cast_nullable_to_non_nullable
as int,threeStars: null == threeStars ? _self.threeStars : threeStars // ignore: cast_nullable_to_non_nullable
as int,twoStars: null == twoStars ? _self.twoStars : twoStars // ignore: cast_nullable_to_non_nullable
as int,oneStars: null == oneStars ? _self.oneStars : oneStars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RatingBreakdown].
extension RatingBreakdownPatterns on RatingBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RatingBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RatingBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RatingBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _RatingBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RatingBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _RatingBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  double average,  int fiveStars,  int fourStars,  int threeStars,  int twoStars,  int oneStars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RatingBreakdown() when $default != null:
return $default(_that.total,_that.average,_that.fiveStars,_that.fourStars,_that.threeStars,_that.twoStars,_that.oneStars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  double average,  int fiveStars,  int fourStars,  int threeStars,  int twoStars,  int oneStars)  $default,) {final _that = this;
switch (_that) {
case _RatingBreakdown():
return $default(_that.total,_that.average,_that.fiveStars,_that.fourStars,_that.threeStars,_that.twoStars,_that.oneStars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  double average,  int fiveStars,  int fourStars,  int threeStars,  int twoStars,  int oneStars)?  $default,) {final _that = this;
switch (_that) {
case _RatingBreakdown() when $default != null:
return $default(_that.total,_that.average,_that.fiveStars,_that.fourStars,_that.threeStars,_that.twoStars,_that.oneStars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RatingBreakdown implements RatingBreakdown {
  const _RatingBreakdown({this.total = 0, this.average = 0.0, this.fiveStars = 0, this.fourStars = 0, this.threeStars = 0, this.twoStars = 0, this.oneStars = 0});
  factory _RatingBreakdown.fromJson(Map<String, dynamic> json) => _$RatingBreakdownFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  double average;
@override@JsonKey() final  int fiveStars;
@override@JsonKey() final  int fourStars;
@override@JsonKey() final  int threeStars;
@override@JsonKey() final  int twoStars;
@override@JsonKey() final  int oneStars;

/// Create a copy of RatingBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingBreakdownCopyWith<_RatingBreakdown> get copyWith => __$RatingBreakdownCopyWithImpl<_RatingBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatingBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RatingBreakdown&&(identical(other.total, total) || other.total == total)&&(identical(other.average, average) || other.average == average)&&(identical(other.fiveStars, fiveStars) || other.fiveStars == fiveStars)&&(identical(other.fourStars, fourStars) || other.fourStars == fourStars)&&(identical(other.threeStars, threeStars) || other.threeStars == threeStars)&&(identical(other.twoStars, twoStars) || other.twoStars == twoStars)&&(identical(other.oneStars, oneStars) || other.oneStars == oneStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,average,fiveStars,fourStars,threeStars,twoStars,oneStars);

@override
String toString() {
  return 'RatingBreakdown(total: $total, average: $average, fiveStars: $fiveStars, fourStars: $fourStars, threeStars: $threeStars, twoStars: $twoStars, oneStars: $oneStars)';
}


}

/// @nodoc
abstract mixin class _$RatingBreakdownCopyWith<$Res> implements $RatingBreakdownCopyWith<$Res> {
  factory _$RatingBreakdownCopyWith(_RatingBreakdown value, $Res Function(_RatingBreakdown) _then) = __$RatingBreakdownCopyWithImpl;
@override @useResult
$Res call({
 int total, double average, int fiveStars, int fourStars, int threeStars, int twoStars, int oneStars
});




}
/// @nodoc
class __$RatingBreakdownCopyWithImpl<$Res>
    implements _$RatingBreakdownCopyWith<$Res> {
  __$RatingBreakdownCopyWithImpl(this._self, this._then);

  final _RatingBreakdown _self;
  final $Res Function(_RatingBreakdown) _then;

/// Create a copy of RatingBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? average = null,Object? fiveStars = null,Object? fourStars = null,Object? threeStars = null,Object? twoStars = null,Object? oneStars = null,}) {
  return _then(_RatingBreakdown(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,fiveStars: null == fiveStars ? _self.fiveStars : fiveStars // ignore: cast_nullable_to_non_nullable
as int,fourStars: null == fourStars ? _self.fourStars : fourStars // ignore: cast_nullable_to_non_nullable
as int,threeStars: null == threeStars ? _self.threeStars : threeStars // ignore: cast_nullable_to_non_nullable
as int,twoStars: null == twoStars ? _self.twoStars : twoStars // ignore: cast_nullable_to_non_nullable
as int,oneStars: null == oneStars ? _self.oneStars : oneStars // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$UserModel {

 String get uid; String get email; String get displayName; String? get photoUrl; String? get phoneNumber; String? get bio;@TimestampConverter() DateTime? get dateOfBirth; String? get gender; List<String> get interests;// Address & location
 String? get address; double? get latitude; double? get longitude; String? get city; String? get country;// Verification & status
 bool get isEmailVerified; bool get isPhoneVerified; bool get isIdVerified; bool get isActive; bool get isOnline; bool get isPremium;// Social
 List<String> get blockedUsers;// Rider-specific: Passenger rating
 RatingBreakdown get rating;// Rider-specific: Gamification
 Object get gamification;// Preferences
 UserPreferences get preferences;// FCM Token for push notifications
 String? get fcmToken;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get lastSeenAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.interests, interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.blockedUsers, blockedUsers)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.gamification, gamification)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(blockedUsers),rating,const DeepCollectionEquality().hash(gamification),preferences,fcmToken,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, rating: $rating, gamification: $gamification, preferences: $preferences, fcmToken: $fcmToken, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, RatingBreakdown rating, UserPreferences preferences, String? fcmToken,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


$RatingBreakdownCopyWith<$Res> get rating;$UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? rating = null,Object? preferences = null,Object? fcmToken = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self.blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<$Res> get rating {
  
  return $RatingBreakdownCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RiderModel value)?  rider,TResult Function( DriverModel value)?  driver,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that);case DriverModel() when driver != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RiderModel value)  rider,required TResult Function( DriverModel value)  driver,}){
final _that = this;
switch (_that) {
case RiderModel():
return rider(_that);case DriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RiderModel value)?  rider,TResult? Function( DriverModel value)?  driver,}){
final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that);case DriverModel() when driver != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  RiderGamificationStats gamification,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<Vehicle> vehicles,  RatingBreakdown rating,  DriverGamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  RiderGamificationStats gamification,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  rider,required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<Vehicle> vehicles,  RatingBreakdown rating,  DriverGamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  driver,}) {final _that = this;
switch (_that) {
case RiderModel():
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel():
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  RiderGamificationStats gamification,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<Vehicle> vehicles,  RatingBreakdown rating,  DriverGamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  UserPreferences preferences,  String? fcmToken, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.preferences,_that.fcmToken,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc


class RiderModel extends UserModel {
  const RiderModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, this.bio, @TimestampConverter() this.dateOfBirth, this.gender, final  List<String> interests = const [], this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isOnline = false, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<String> favoriteRoutes = const [], this.rating = const RatingBreakdown(), this.gamification = const RiderGamificationStats(), this.preferences = const UserPreferences(), this.fcmToken, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt}): _interests = interests,_blockedUsers = blockedUsers,_favoriteRoutes = favoriteRoutes,super._();
  

@override final  String uid;
@override final  String email;
@override final  String displayName;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override final  String? bio;
@override@TimestampConverter() final  DateTime? dateOfBirth;
@override final  String? gender;
 final  List<String> _interests;
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

// Address & location
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? city;
@override final  String? country;
// Verification & status
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isPhoneVerified;
@override@JsonKey() final  bool isIdVerified;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  bool isPremium;
// Social
 final  List<String> _blockedUsers;
// Social
@override@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}

// Rider-specific: Favorite routes
 final  List<String> _favoriteRoutes;
// Rider-specific: Favorite routes
@JsonKey() List<String> get favoriteRoutes {
  if (_favoriteRoutes is EqualUnmodifiableListView) return _favoriteRoutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteRoutes);
}

// Rider-specific: Passenger rating
@override@JsonKey() final  RatingBreakdown rating;
// Rider-specific: Gamification
@override@JsonKey() final  RiderGamificationStats gamification;
// Preferences
@override@JsonKey() final  UserPreferences preferences;
// FCM Token for push notifications
@override final  String? fcmToken;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastSeenAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderModelCopyWith<RiderModel> get copyWith => _$RiderModelCopyWithImpl<RiderModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._favoriteRoutes, _favoriteRoutes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(_interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_favoriteRoutes),rating,gamification,preferences,fcmToken,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.rider(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, favoriteRoutes: $favoriteRoutes, rating: $rating, gamification: $gamification, preferences: $preferences, fcmToken: $fcmToken, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $RiderModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $RiderModelCopyWith(RiderModel value, $Res Function(RiderModel) _then) = _$RiderModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, List<String> favoriteRoutes, RatingBreakdown rating, RiderGamificationStats gamification, UserPreferences preferences, String? fcmToken,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


@override $RatingBreakdownCopyWith<$Res> get rating;$RiderGamificationStatsCopyWith<$Res> get gamification;@override $UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$RiderModelCopyWithImpl<$Res>
    implements $RiderModelCopyWith<$Res> {
  _$RiderModelCopyWithImpl(this._self, this._then);

  final RiderModel _self;
  final $Res Function(RiderModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? favoriteRoutes = null,Object? rating = null,Object? gamification = null,Object? preferences = null,Object? fcmToken = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(RiderModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteRoutes: null == favoriteRoutes ? _self._favoriteRoutes : favoriteRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as RiderGamificationStats,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<$Res> get rating {
  
  return $RatingBreakdownCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RiderGamificationStatsCopyWith<$Res> get gamification {
  
  return $RiderGamificationStatsCopyWith<$Res>(_self.gamification, (value) {
    return _then(_self.copyWith(gamification: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}

/// @nodoc


class DriverModel extends UserModel {
  const DriverModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, this.bio, @TimestampConverter() this.dateOfBirth, this.gender, final  List<String> interests = const [], this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isOnline = false, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<Vehicle> vehicles = const [], this.rating = const RatingBreakdown(), this.gamification = const DriverGamificationStats(), this.stripeAccountId, this.isStripeEnabled = false, this.isStripeOnboarded = false, this.preferences = const UserPreferences(), this.fcmToken, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt}): _interests = interests,_blockedUsers = blockedUsers,_vehicles = vehicles,super._();
  

@override final  String uid;
@override final  String email;
@override final  String displayName;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override final  String? bio;
@override@TimestampConverter() final  DateTime? dateOfBirth;
@override final  String? gender;
 final  List<String> _interests;
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

// Address & location
@override final  String? address;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? city;
@override final  String? country;
// Verification & status
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isPhoneVerified;
@override@JsonKey() final  bool isIdVerified;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  bool isPremium;
// Social
 final  List<String> _blockedUsers;
// Social
@override@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}

// Driver-specific: Vehicles
 final  List<Vehicle> _vehicles;
// Driver-specific: Vehicles
@JsonKey() List<Vehicle> get vehicles {
  if (_vehicles is EqualUnmodifiableListView) return _vehicles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicles);
}

// Driver-specific: Driver rating
@override@JsonKey() final  RatingBreakdown rating;
// Driver-specific: Gamification
@override@JsonKey() final  DriverGamificationStats gamification;
// Driver-specific: Stripe
 final  String? stripeAccountId;
@JsonKey() final  bool isStripeEnabled;
@JsonKey() final  bool isStripeOnboarded;
// Preferences
@override@JsonKey() final  UserPreferences preferences;
// FCM Token for push notifications
@override final  String? fcmToken;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastSeenAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._vehicles, _vehicles)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.isStripeEnabled, isStripeEnabled) || other.isStripeEnabled == isStripeEnabled)&&(identical(other.isStripeOnboarded, isStripeOnboarded) || other.isStripeOnboarded == isStripeOnboarded)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(_interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_vehicles),rating,gamification,stripeAccountId,isStripeEnabled,isStripeOnboarded,preferences,fcmToken,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.driver(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, vehicles: $vehicles, rating: $rating, gamification: $gamification, stripeAccountId: $stripeAccountId, isStripeEnabled: $isStripeEnabled, isStripeOnboarded: $isStripeOnboarded, preferences: $preferences, fcmToken: $fcmToken, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, List<Vehicle> vehicles, RatingBreakdown rating, DriverGamificationStats gamification, String? stripeAccountId, bool isStripeEnabled, bool isStripeOnboarded, UserPreferences preferences, String? fcmToken,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


@override $RatingBreakdownCopyWith<$Res> get rating;$DriverGamificationStatsCopyWith<$Res> get gamification;@override $UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? vehicles = null,Object? rating = null,Object? gamification = null,Object? stripeAccountId = freezed,Object? isStripeEnabled = null,Object? isStripeOnboarded = null,Object? preferences = null,Object? fcmToken = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(DriverModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,vehicles: null == vehicles ? _self._vehicles : vehicles // ignore: cast_nullable_to_non_nullable
as List<Vehicle>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as DriverGamificationStats,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,isStripeEnabled: null == isStripeEnabled ? _self.isStripeEnabled : isStripeEnabled // ignore: cast_nullable_to_non_nullable
as bool,isStripeOnboarded: null == isStripeOnboarded ? _self.isStripeOnboarded : isStripeOnboarded // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,fcmToken: freezed == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<$Res> get rating {
  
  return $RatingBreakdownCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverGamificationStatsCopyWith<$Res> get gamification {
  
  return $DriverGamificationStatsCopyWith<$Res>(_self.gamification, (value) {
    return _then(_self.copyWith(gamification: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// @nodoc
mixin _$LeaderboardEntry {

 String get odid; String get displayName; String? get photoUrl; int get totalXP; int get level; int get rank; int get ridesThisMonth;
/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith => _$LeaderboardEntryCopyWithImpl<LeaderboardEntry>(this as LeaderboardEntry, _$identity);

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderboardEntry&&(identical(other.odid, odid) || other.odid == odid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,odid,displayName,photoUrl,totalXP,level,rank,ridesThisMonth);

@override
String toString() {
  return 'LeaderboardEntry(odid: $odid, displayName: $displayName, photoUrl: $photoUrl, totalXP: $totalXP, level: $level, rank: $rank, ridesThisMonth: $ridesThisMonth)';
}


}

/// @nodoc
abstract mixin class $LeaderboardEntryCopyWith<$Res>  {
  factory $LeaderboardEntryCopyWith(LeaderboardEntry value, $Res Function(LeaderboardEntry) _then) = _$LeaderboardEntryCopyWithImpl;
@useResult
$Res call({
 String odid, String displayName, String? photoUrl, int totalXP, int level, int rank, int ridesThisMonth
});




}
/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final LeaderboardEntry _self;
  final $Res Function(LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? odid = null,Object? displayName = null,Object? photoUrl = freezed,Object? totalXP = null,Object? level = null,Object? rank = null,Object? ridesThisMonth = null,}) {
  return _then(_self.copyWith(
odid: null == odid ? _self.odid : odid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderboardEntry].
extension LeaderboardEntryPatterns on LeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String odid,  String displayName,  String? photoUrl,  int totalXP,  int level,  int rank,  int ridesThisMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.odid,_that.displayName,_that.photoUrl,_that.totalXP,_that.level,_that.rank,_that.ridesThisMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String odid,  String displayName,  String? photoUrl,  int totalXP,  int level,  int rank,  int ridesThisMonth)  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry():
return $default(_that.odid,_that.displayName,_that.photoUrl,_that.totalXP,_that.level,_that.rank,_that.ridesThisMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String odid,  String displayName,  String? photoUrl,  int totalXP,  int level,  int rank,  int ridesThisMonth)?  $default,) {final _that = this;
switch (_that) {
case _LeaderboardEntry() when $default != null:
return $default(_that.odid,_that.displayName,_that.photoUrl,_that.totalXP,_that.level,_that.rank,_that.ridesThisMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderboardEntry implements LeaderboardEntry {
  const _LeaderboardEntry({required this.odid, required this.displayName, this.photoUrl, required this.totalXP, required this.level, required this.rank, this.ridesThisMonth = 0});
  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryFromJson(json);

@override final  String odid;
@override final  String displayName;
@override final  String? photoUrl;
@override final  int totalXP;
@override final  int level;
@override final  int rank;
@override@JsonKey() final  int ridesThisMonth;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderboardEntryCopyWith<_LeaderboardEntry> get copyWith => __$LeaderboardEntryCopyWithImpl<_LeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderboardEntry&&(identical(other.odid, odid) || other.odid == odid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.ridesThisMonth, ridesThisMonth) || other.ridesThisMonth == ridesThisMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,odid,displayName,photoUrl,totalXP,level,rank,ridesThisMonth);

@override
String toString() {
  return 'LeaderboardEntry(odid: $odid, displayName: $displayName, photoUrl: $photoUrl, totalXP: $totalXP, level: $level, rank: $rank, ridesThisMonth: $ridesThisMonth)';
}


}

/// @nodoc
abstract mixin class _$LeaderboardEntryCopyWith<$Res> implements $LeaderboardEntryCopyWith<$Res> {
  factory _$LeaderboardEntryCopyWith(_LeaderboardEntry value, $Res Function(_LeaderboardEntry) _then) = __$LeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
 String odid, String displayName, String? photoUrl, int totalXP, int level, int rank, int ridesThisMonth
});




}
/// @nodoc
class __$LeaderboardEntryCopyWithImpl<$Res>
    implements _$LeaderboardEntryCopyWith<$Res> {
  __$LeaderboardEntryCopyWithImpl(this._self, this._then);

  final _LeaderboardEntry _self;
  final $Res Function(_LeaderboardEntry) _then;

/// Create a copy of LeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? odid = null,Object? displayName = null,Object? photoUrl = freezed,Object? totalXP = null,Object? level = null,Object? rank = null,Object? ridesThisMonth = null,}) {
  return _then(_LeaderboardEntry(
odid: null == odid ? _self.odid : odid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,ridesThisMonth: null == ridesThisMonth ? _self.ridesThisMonth : ridesThisMonth // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
