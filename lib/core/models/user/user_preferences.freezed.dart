// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

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

// dart format on
