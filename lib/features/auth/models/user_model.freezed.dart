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
UserModel _$UserModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['role']) {
                  case 'rider':
          return RiderModel.fromJson(
            json
          );
                case 'driver':
          return DriverModel.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'role',
  'UserModel',
  'Invalid union type "${json['role']}"!'
);
        }
      
}

/// @nodoc
mixin _$UserModel {

 String get uid; String get email; String get displayName; String? get photoUrl; String? get phoneNumber; String? get bio;@TimestampConverter() DateTime? get dateOfBirth; String? get gender; List<String> get interests;// Address & location
 String? get address; double? get latitude; double? get longitude; String? get city; String? get country;// Verification & status
 bool get isEmailVerified; bool get isPhoneVerified; bool get isIdVerified; bool get isActive; bool get isOnline; bool get isPremium;// Social
 List<String> get blockedUsers;// Rider-specific: Passenger rating
 RatingBreakdown get rating;// Rider-specific: Gamification
// CHANGED: Use the factory constructor .rider()
 GamificationStats get gamification;// Onboarding
 bool get needsRoleSelection;// Preferences
 UserPreferences get preferences;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;@TimestampConverter() DateTime? get lastSeenAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.interests, interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.blockedUsers, blockedUsers)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(blockedUsers),rating,gamification,needsRoleSelection,preferences,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, rating: $rating, gamification: $gamification, needsRoleSelection: $needsRoleSelection, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, RatingBreakdown rating, GamificationStats gamification, bool needsRoleSelection, UserPreferences preferences,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


$RatingBreakdownCopyWith<$Res> get rating;$GamificationStatsCopyWith<$Res> get gamification;$UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? rating = null,Object? gamification = null,Object? needsRoleSelection = null,Object? preferences = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
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
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$GamificationStatsCopyWith<$Res> get gamification {
  
  return $GamificationStatsCopyWith<$Res>(_self.gamification, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<VehicleModel> vehicles,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  rider,required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<VehicleModel> vehicles,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  driver,}) {final _that = this;
switch (_that) {
case RiderModel():
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel():
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber,  String? bio, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  List<String> interests,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isOnline,  bool isPremium,  List<String> blockedUsers,  List<VehicleModel> vehicles,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  bool isStripeEnabled,  bool isStripeOnboarded,  bool needsRoleSelection,  UserPreferences preferences, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.bio,_that.dateOfBirth,_that.gender,_that.interests,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isOnline,_that.isPremium,_that.blockedUsers,_that.vehicles,_that.rating,_that.gamification,_that.stripeAccountId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.needsRoleSelection,_that.preferences,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class RiderModel extends UserModel {
  const RiderModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, this.bio, @TimestampConverter() this.dateOfBirth, this.gender, final  List<String> interests = const [], this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isOnline = false, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<String> favoriteRoutes = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats.rider(), this.needsRoleSelection = false, this.preferences = const UserPreferences(), @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt, final  String? $type}): _interests = interests,_blockedUsers = blockedUsers,_favoriteRoutes = favoriteRoutes,$type = $type ?? 'rider',super._();
  factory RiderModel.fromJson(Map<String, dynamic> json) => _$RiderModelFromJson(json);

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
// CHANGED: Use the factory constructor .rider()
@override@JsonKey() final  GamificationStats gamification;
// Onboarding
@override@JsonKey() final  bool needsRoleSelection;
// Preferences
@override@JsonKey() final  UserPreferences preferences;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastSeenAt;

@JsonKey(name: 'role')
final String $type;


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderModelCopyWith<RiderModel> get copyWith => _$RiderModelCopyWithImpl<RiderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._favoriteRoutes, _favoriteRoutes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(_interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_favoriteRoutes),rating,gamification,needsRoleSelection,preferences,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.rider(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, favoriteRoutes: $favoriteRoutes, rating: $rating, gamification: $gamification, needsRoleSelection: $needsRoleSelection, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $RiderModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $RiderModelCopyWith(RiderModel value, $Res Function(RiderModel) _then) = _$RiderModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, List<String> favoriteRoutes, RatingBreakdown rating, GamificationStats gamification, bool needsRoleSelection, UserPreferences preferences,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


@override $RatingBreakdownCopyWith<$Res> get rating;@override $GamificationStatsCopyWith<$Res> get gamification;@override $UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$RiderModelCopyWithImpl<$Res>
    implements $RiderModelCopyWith<$Res> {
  _$RiderModelCopyWithImpl(this._self, this._then);

  final RiderModel _self;
  final $Res Function(RiderModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? favoriteRoutes = null,Object? rating = null,Object? gamification = null,Object? needsRoleSelection = null,Object? preferences = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
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
as GamificationStats,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$GamificationStatsCopyWith<$Res> get gamification {
  
  return $GamificationStatsCopyWith<$Res>(_self.gamification, (value) {
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
@JsonSerializable()

class DriverModel extends UserModel {
  const DriverModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, this.bio, @TimestampConverter() this.dateOfBirth, this.gender, final  List<String> interests = const [], this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isOnline = false, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<VehicleModel> vehicles = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats.driver(), this.stripeAccountId, this.isStripeEnabled = false, this.isStripeOnboarded = false, this.needsRoleSelection = false, this.preferences = const UserPreferences(), @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt, final  String? $type}): _interests = interests,_blockedUsers = blockedUsers,_vehicles = vehicles,$type = $type ?? 'driver',super._();
  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

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
 final  List<VehicleModel> _vehicles;
// Driver-specific: Vehicles
@JsonKey() List<VehicleModel> get vehicles {
  if (_vehicles is EqualUnmodifiableListView) return _vehicles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicles);
}

// Driver-specific: Driver rating
@override@JsonKey() final  RatingBreakdown rating;
// Driver-specific: Gamification
// CHANGED: Use the factory constructor .driver()
@override@JsonKey() final  GamificationStats gamification;
// Driver-specific: Stripe
 final  String? stripeAccountId;
@JsonKey() final  bool isStripeEnabled;
@JsonKey() final  bool isStripeOnboarded;
// Onboarding
@override@JsonKey() final  bool needsRoleSelection;
// Preferences
@override@JsonKey() final  UserPreferences preferences;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastSeenAt;

@JsonKey(name: 'role')
final String $type;


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._interests, _interests)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._vehicles, _vehicles)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.isStripeEnabled, isStripeEnabled) || other.isStripeEnabled == isStripeEnabled)&&(identical(other.isStripeOnboarded, isStripeOnboarded) || other.isStripeOnboarded == isStripeOnboarded)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,bio,dateOfBirth,gender,const DeepCollectionEquality().hash(_interests),address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isOnline,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_vehicles),rating,gamification,stripeAccountId,isStripeEnabled,isStripeOnboarded,needsRoleSelection,preferences,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.driver(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, dateOfBirth: $dateOfBirth, gender: $gender, interests: $interests, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isOnline: $isOnline, isPremium: $isPremium, blockedUsers: $blockedUsers, vehicles: $vehicles, rating: $rating, gamification: $gamification, stripeAccountId: $stripeAccountId, isStripeEnabled: $isStripeEnabled, isStripeOnboarded: $isStripeOnboarded, needsRoleSelection: $needsRoleSelection, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber, String? bio,@TimestampConverter() DateTime? dateOfBirth, String? gender, List<String> interests, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isOnline, bool isPremium, List<String> blockedUsers, List<VehicleModel> vehicles, RatingBreakdown rating, GamificationStats gamification, String? stripeAccountId, bool isStripeEnabled, bool isStripeOnboarded, bool needsRoleSelection, UserPreferences preferences,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
});


@override $RatingBreakdownCopyWith<$Res> get rating;@override $GamificationStatsCopyWith<$Res> get gamification;@override $UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? bio = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? interests = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isOnline = null,Object? isPremium = null,Object? blockedUsers = null,Object? vehicles = null,Object? rating = null,Object? gamification = null,Object? stripeAccountId = freezed,Object? isStripeEnabled = null,Object? isStripeOnboarded = null,Object? needsRoleSelection = null,Object? preferences = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
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
as List<VehicleModel>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,isStripeEnabled: null == isStripeEnabled ? _self.isStripeEnabled : isStripeEnabled // ignore: cast_nullable_to_non_nullable
as bool,isStripeOnboarded: null == isStripeOnboarded ? _self.isStripeOnboarded : isStripeOnboarded // ignore: cast_nullable_to_non_nullable
as bool,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
$GamificationStatsCopyWith<$Res> get gamification {
  
  return $GamificationStatsCopyWith<$Res>(_self.gamification, (value) {
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

// dart format on
