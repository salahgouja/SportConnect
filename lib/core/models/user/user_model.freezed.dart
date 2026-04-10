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

 String get uid; String get email; String get displayName; String? get photoUrl; String? get phoneNumber;@TimestampConverter() DateTime? get dateOfBirth; String? get gender; String get fcmToken;// Address & location
 String? get address; double? get latitude; double? get longitude; String? get city; String? get country;// Verification & status
 bool get isEmailVerified; bool get isPhoneVerified; bool get isIdVerified; bool get isActive; bool get isPremium;// Social
 List<String> get blockedUsers;// Rider-specific: Passenger rating
 RatingBreakdown get rating;// Rider-specific: Gamification
// CHANGED: Use the factory constructor .rider()
 GamificationStats get gamification;// Onboarding
 bool get needsRoleSelection;// Preferences
 UserPreferences get preferences;// Expertise
 Expertise get expertise;// Timestamps
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other.blockedUsers, blockedUsers)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,dateOfBirth,gender,fcmToken,address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isPremium,const DeepCollectionEquality().hash(blockedUsers),rating,gamification,needsRoleSelection,preferences,expertise,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, fcmToken: $fcmToken, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isPremium: $isPremium, blockedUsers: $blockedUsers, rating: $rating, gamification: $gamification, needsRoleSelection: $needsRoleSelection, preferences: $preferences, expertise: $expertise, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String? gender, String fcmToken, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isPremium, List<String> blockedUsers, RatingBreakdown rating, GamificationStats gamification, bool needsRoleSelection, UserPreferences preferences, Expertise expertise,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? fcmToken = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isPremium = null,Object? blockedUsers = null,Object? rating = null,Object? gamification = null,Object? needsRoleSelection = null,Object? preferences = null,Object? expertise = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self.blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> vehicleIds,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  String? stripeCustomerId,  bool isStripeEnabled,  bool isStripeOnboarded,  String? stripeAccountStatus,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  List<String> stripeRequirements,  String? stripeDisabledReason,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.vehicleIds,_that.rating,_that.gamification,_that.stripeAccountId,_that.stripeCustomerId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.stripeAccountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.stripeRequirements,_that.stripeDisabledReason,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  rider,required TResult Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> vehicleIds,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  String? stripeCustomerId,  bool isStripeEnabled,  bool isStripeOnboarded,  String? stripeAccountStatus,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  List<String> stripeRequirements,  String? stripeDisabledReason,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)  driver,}) {final _that = this;
switch (_that) {
case RiderModel():
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel():
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.vehicleIds,_that.rating,_that.gamification,_that.stripeAccountId,_that.stripeCustomerId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.stripeAccountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.stripeRequirements,_that.stripeDisabledReason,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> favoriteRoutes,  RatingBreakdown rating,  GamificationStats gamification,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  rider,TResult? Function( String uid,  String email,  String displayName,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  String? city,  String? country,  bool isEmailVerified,  bool isPhoneVerified,  bool isIdVerified,  bool isActive,  bool isPremium,  List<String> blockedUsers,  List<String> vehicleIds,  RatingBreakdown rating,  GamificationStats gamification,  String? stripeAccountId,  String? stripeCustomerId,  bool isStripeEnabled,  bool isStripeOnboarded,  String? stripeAccountStatus,  bool chargesEnabled,  bool payoutsEnabled,  bool detailsSubmitted,  List<String> stripeRequirements,  String? stripeDisabledReason,  bool needsRoleSelection,  UserPreferences preferences,  Expertise expertise, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt, @TimestampConverter()  DateTime? lastSeenAt)?  driver,}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.favoriteRoutes,_that.rating,_that.gamification,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.city,_that.country,_that.isEmailVerified,_that.isPhoneVerified,_that.isIdVerified,_that.isActive,_that.isPremium,_that.blockedUsers,_that.vehicleIds,_that.rating,_that.gamification,_that.stripeAccountId,_that.stripeCustomerId,_that.isStripeEnabled,_that.isStripeOnboarded,_that.stripeAccountStatus,_that.chargesEnabled,_that.payoutsEnabled,_that.detailsSubmitted,_that.stripeRequirements,_that.stripeDisabledReason,_that.needsRoleSelection,_that.preferences,_that.expertise,_that.createdAt,_that.updatedAt,_that.lastSeenAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class RiderModel extends UserModel {
  const RiderModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, @TimestampConverter() this.dateOfBirth, this.gender, this.fcmToken = "", this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<String> favoriteRoutes = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats.rider(), this.needsRoleSelection = false, this.preferences = const UserPreferences(), this.expertise = Expertise.rookie, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt, final  String? $type}): _blockedUsers = blockedUsers,_favoriteRoutes = favoriteRoutes,$type = $type ?? 'rider',super._();
  factory RiderModel.fromJson(Map<String, dynamic> json) => _$RiderModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String displayName;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override@TimestampConverter() final  DateTime? dateOfBirth;
@override final  String? gender;
@override@JsonKey() final  String fcmToken;
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
// Expertise
@override@JsonKey() final  Expertise expertise;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._favoriteRoutes, _favoriteRoutes)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,dateOfBirth,gender,fcmToken,address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_favoriteRoutes),rating,gamification,needsRoleSelection,preferences,expertise,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.rider(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, fcmToken: $fcmToken, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isPremium: $isPremium, blockedUsers: $blockedUsers, favoriteRoutes: $favoriteRoutes, rating: $rating, gamification: $gamification, needsRoleSelection: $needsRoleSelection, preferences: $preferences, expertise: $expertise, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $RiderModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $RiderModelCopyWith(RiderModel value, $Res Function(RiderModel) _then) = _$RiderModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String? gender, String fcmToken, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isPremium, List<String> blockedUsers, List<String> favoriteRoutes, RatingBreakdown rating, GamificationStats gamification, bool needsRoleSelection, UserPreferences preferences, Expertise expertise,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? fcmToken = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isPremium = null,Object? blockedUsers = null,Object? favoriteRoutes = null,Object? rating = null,Object? gamification = null,Object? needsRoleSelection = null,Object? preferences = null,Object? expertise = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(RiderModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteRoutes: null == favoriteRoutes ? _self._favoriteRoutes : favoriteRoutes // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
  const DriverModel({required this.uid, required this.email, required this.displayName, this.photoUrl, this.phoneNumber, @TimestampConverter() this.dateOfBirth, this.gender, this.fcmToken = "", this.address, this.latitude, this.longitude, this.city, this.country, this.isEmailVerified = false, this.isPhoneVerified = false, this.isIdVerified = false, this.isActive = true, this.isPremium = false, final  List<String> blockedUsers = const [], final  List<String> vehicleIds = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats.driver(), this.stripeAccountId, this.stripeCustomerId, this.isStripeEnabled = false, this.isStripeOnboarded = false, this.stripeAccountStatus, this.chargesEnabled = false, this.payoutsEnabled = false, this.detailsSubmitted = false, final  List<String> stripeRequirements = const [], this.stripeDisabledReason, this.needsRoleSelection = false, this.preferences = const UserPreferences(), this.expertise = Expertise.rookie, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, @TimestampConverter() this.lastSeenAt, final  String? $type}): _blockedUsers = blockedUsers,_vehicleIds = vehicleIds,_stripeRequirements = stripeRequirements,$type = $type ?? 'driver',super._();
  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String displayName;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override@TimestampConverter() final  DateTime? dateOfBirth;
@override final  String? gender;
@override@JsonKey() final  String fcmToken;
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
@override@JsonKey() final  bool isPremium;
// Social
 final  List<String> _blockedUsers;
// Social
@override@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}

// Driver-specific: Vehicle IDs (resolved through VehicleRepository)
 final  List<String> _vehicleIds;
// Driver-specific: Vehicle IDs (resolved through VehicleRepository)
@JsonKey() List<String> get vehicleIds {
  if (_vehicleIds is EqualUnmodifiableListView) return _vehicleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicleIds);
}

// Driver-specific: Driver rating
@override@JsonKey() final  RatingBreakdown rating;
// Driver-specific: Gamification
@override@JsonKey() final  GamificationStats gamification;
// Driver-specific: Stripe Connect (fields mirror Cloud Function writes)
 final  String? stripeAccountId;
 final  String? stripeCustomerId;
@JsonKey() final  bool isStripeEnabled;
@JsonKey() final  bool isStripeOnboarded;
/// "pending" | "active" | "under_review" | "incomplete"
 final  String? stripeAccountStatus;
/// Whether Stripe has enabled charges on this account
@JsonKey() final  bool chargesEnabled;
/// Whether Stripe has enabled payouts on this account
@JsonKey() final  bool payoutsEnabled;
/// Whether the driver has submitted all required Stripe details
@JsonKey() final  bool detailsSubmitted;
/// Outstanding Stripe requirements (e.g. ["individual.dob"])
 final  List<String> _stripeRequirements;
/// Outstanding Stripe requirements (e.g. ["individual.dob"])
@JsonKey() List<String> get stripeRequirements {
  if (_stripeRequirements is EqualUnmodifiableListView) return _stripeRequirements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stripeRequirements);
}

/// Reason charges/payouts are disabled, if any
 final  String? stripeDisabledReason;
// Onboarding
@override@JsonKey() final  bool needsRoleSelection;
// Preferences
@override@JsonKey() final  UserPreferences preferences;
// Expertise
@override@JsonKey() final  Expertise expertise;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.isIdVerified, isIdVerified) || other.isIdVerified == isIdVerified)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&const DeepCollectionEquality().equals(other._vehicleIds, _vehicleIds)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.isStripeEnabled, isStripeEnabled) || other.isStripeEnabled == isStripeEnabled)&&(identical(other.isStripeOnboarded, isStripeOnboarded) || other.isStripeOnboarded == isStripeOnboarded)&&(identical(other.stripeAccountStatus, stripeAccountStatus) || other.stripeAccountStatus == stripeAccountStatus)&&(identical(other.chargesEnabled, chargesEnabled) || other.chargesEnabled == chargesEnabled)&&(identical(other.payoutsEnabled, payoutsEnabled) || other.payoutsEnabled == payoutsEnabled)&&(identical(other.detailsSubmitted, detailsSubmitted) || other.detailsSubmitted == detailsSubmitted)&&const DeepCollectionEquality().equals(other._stripeRequirements, _stripeRequirements)&&(identical(other.stripeDisabledReason, stripeDisabledReason) || other.stripeDisabledReason == stripeDisabledReason)&&(identical(other.needsRoleSelection, needsRoleSelection) || other.needsRoleSelection == needsRoleSelection)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,dateOfBirth,gender,fcmToken,address,latitude,longitude,city,country,isEmailVerified,isPhoneVerified,isIdVerified,isActive,isPremium,const DeepCollectionEquality().hash(_blockedUsers),const DeepCollectionEquality().hash(_vehicleIds),rating,gamification,stripeAccountId,stripeCustomerId,isStripeEnabled,isStripeOnboarded,stripeAccountStatus,chargesEnabled,payoutsEnabled,detailsSubmitted,const DeepCollectionEquality().hash(_stripeRequirements),stripeDisabledReason,needsRoleSelection,preferences,expertise,createdAt,updatedAt,lastSeenAt]);

@override
String toString() {
  return 'UserModel.driver(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, fcmToken: $fcmToken, address: $address, latitude: $latitude, longitude: $longitude, city: $city, country: $country, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, isIdVerified: $isIdVerified, isActive: $isActive, isPremium: $isPremium, blockedUsers: $blockedUsers, vehicleIds: $vehicleIds, rating: $rating, gamification: $gamification, stripeAccountId: $stripeAccountId, stripeCustomerId: $stripeCustomerId, isStripeEnabled: $isStripeEnabled, isStripeOnboarded: $isStripeOnboarded, stripeAccountStatus: $stripeAccountStatus, chargesEnabled: $chargesEnabled, payoutsEnabled: $payoutsEnabled, detailsSubmitted: $detailsSubmitted, stripeRequirements: $stripeRequirements, stripeDisabledReason: $stripeDisabledReason, needsRoleSelection: $needsRoleSelection, preferences: $preferences, expertise: $expertise, createdAt: $createdAt, updatedAt: $updatedAt, lastSeenAt: $lastSeenAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String displayName, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String? gender, String fcmToken, String? address, double? latitude, double? longitude, String? city, String? country, bool isEmailVerified, bool isPhoneVerified, bool isIdVerified, bool isActive, bool isPremium, List<String> blockedUsers, List<String> vehicleIds, RatingBreakdown rating, GamificationStats gamification, String? stripeAccountId, String? stripeCustomerId, bool isStripeEnabled, bool isStripeOnboarded, String? stripeAccountStatus, bool chargesEnabled, bool payoutsEnabled, bool detailsSubmitted, List<String> stripeRequirements, String? stripeDisabledReason, bool needsRoleSelection, UserPreferences preferences, Expertise expertise,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt,@TimestampConverter() DateTime? lastSeenAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? fcmToken = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? city = freezed,Object? country = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? isIdVerified = null,Object? isActive = null,Object? isPremium = null,Object? blockedUsers = null,Object? vehicleIds = null,Object? rating = null,Object? gamification = null,Object? stripeAccountId = freezed,Object? stripeCustomerId = freezed,Object? isStripeEnabled = null,Object? isStripeOnboarded = null,Object? stripeAccountStatus = freezed,Object? chargesEnabled = null,Object? payoutsEnabled = null,Object? detailsSubmitted = null,Object? stripeRequirements = null,Object? stripeDisabledReason = freezed,Object? needsRoleSelection = null,Object? preferences = null,Object? expertise = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastSeenAt = freezed,}) {
  return _then(DriverModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,isIdVerified: null == isIdVerified ? _self.isIdVerified : isIdVerified // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleIds: null == vehicleIds ? _self._vehicleIds : vehicleIds // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,isStripeEnabled: null == isStripeEnabled ? _self.isStripeEnabled : isStripeEnabled // ignore: cast_nullable_to_non_nullable
as bool,isStripeOnboarded: null == isStripeOnboarded ? _self.isStripeOnboarded : isStripeOnboarded // ignore: cast_nullable_to_non_nullable
as bool,stripeAccountStatus: freezed == stripeAccountStatus ? _self.stripeAccountStatus : stripeAccountStatus // ignore: cast_nullable_to_non_nullable
as String?,chargesEnabled: null == chargesEnabled ? _self.chargesEnabled : chargesEnabled // ignore: cast_nullable_to_non_nullable
as bool,payoutsEnabled: null == payoutsEnabled ? _self.payoutsEnabled : payoutsEnabled // ignore: cast_nullable_to_non_nullable
as bool,detailsSubmitted: null == detailsSubmitted ? _self.detailsSubmitted : detailsSubmitted // ignore: cast_nullable_to_non_nullable
as bool,stripeRequirements: null == stripeRequirements ? _self._stripeRequirements : stripeRequirements // ignore: cast_nullable_to_non_nullable
as List<String>,stripeDisabledReason: freezed == stripeDisabledReason ? _self.stripeDisabledReason : stripeDisabledReason // ignore: cast_nullable_to_non_nullable
as String?,needsRoleSelection: null == needsRoleSelection ? _self.needsRoleSelection : needsRoleSelection // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
