// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiderModel _$RiderModelFromJson(Map json) => RiderModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
  gender: json['gender'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  city: json['city'] as String?,
  country: json['country'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
  isIdVerified: json['isIdVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  isOnline: json['isOnline'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  favoriteRoutes:
      (json['favoriteRoutes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rating: json['rating'] == null
      ? const RatingBreakdown()
      : RatingBreakdown.fromJson(
          Map<String, dynamic>.from(json['rating'] as Map),
        ),
  gamification: json['gamification'] == null
      ? const GamificationStats.rider()
      : GamificationStats.fromJson(
          Map<String, dynamic>.from(json['gamification'] as Map),
        ),
  needsRoleSelection: json['needsRoleSelection'] as bool? ?? false,
  preferences: json['preferences'] == null
      ? const UserPreferences()
      : UserPreferences.fromJson(
          Map<String, dynamic>.from(json['preferences'] as Map),
        ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  lastSeenAt: const TimestampConverter().fromJson(json['lastSeenAt']),
  $type: json['role'] as String?,
);

Map<String, dynamic> _$RiderModelToJson(RiderModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'bio': instance.bio,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'gender': instance.gender,
      'interests': instance.interests,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'country': instance.country,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'isIdVerified': instance.isIdVerified,
      'isActive': instance.isActive,
      'isOnline': instance.isOnline,
      'isPremium': instance.isPremium,
      'blockedUsers': instance.blockedUsers,
      'favoriteRoutes': instance.favoriteRoutes,
      'rating': instance.rating.toJson(),
      'gamification': instance.gamification.toJson(),
      'needsRoleSelection': instance.needsRoleSelection,
      'preferences': instance.preferences.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'lastSeenAt': const TimestampConverter().toJson(instance.lastSeenAt),
      'role': instance.$type,
    };

DriverModel _$DriverModelFromJson(Map json) => DriverModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  bio: json['bio'] as String?,
  dateOfBirth: const TimestampConverter().fromJson(json['dateOfBirth']),
  gender: json['gender'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  city: json['city'] as String?,
  country: json['country'] as String?,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
  isIdVerified: json['isIdVerified'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  isOnline: json['isOnline'] as bool? ?? false,
  isPremium: json['isPremium'] as bool? ?? false,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  vehicles:
      (json['vehicles'] as List<dynamic>?)
          ?.map(
            (e) => VehicleModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  rating: json['rating'] == null
      ? const RatingBreakdown()
      : RatingBreakdown.fromJson(
          Map<String, dynamic>.from(json['rating'] as Map),
        ),
  gamification: json['gamification'] == null
      ? const GamificationStats.driver()
      : GamificationStats.fromJson(
          Map<String, dynamic>.from(json['gamification'] as Map),
        ),
  stripeAccountId: json['stripeAccountId'] as String?,
  isStripeEnabled: json['isStripeEnabled'] as bool? ?? false,
  isStripeOnboarded: json['isStripeOnboarded'] as bool? ?? false,
  needsRoleSelection: json['needsRoleSelection'] as bool? ?? false,
  preferences: json['preferences'] == null
      ? const UserPreferences()
      : UserPreferences.fromJson(
          Map<String, dynamic>.from(json['preferences'] as Map),
        ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  lastSeenAt: const TimestampConverter().fromJson(json['lastSeenAt']),
  $type: json['role'] as String?,
);

Map<String, dynamic> _$DriverModelToJson(DriverModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'bio': instance.bio,
      'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
      'gender': instance.gender,
      'interests': instance.interests,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'city': instance.city,
      'country': instance.country,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'isIdVerified': instance.isIdVerified,
      'isActive': instance.isActive,
      'isOnline': instance.isOnline,
      'isPremium': instance.isPremium,
      'blockedUsers': instance.blockedUsers,
      'vehicles': instance.vehicles.map((e) => e.toJson()).toList(),
      'rating': instance.rating.toJson(),
      'gamification': instance.gamification.toJson(),
      'stripeAccountId': instance.stripeAccountId,
      'isStripeEnabled': instance.isStripeEnabled,
      'isStripeOnboarded': instance.isStripeOnboarded,
      'needsRoleSelection': instance.needsRoleSelection,
      'preferences': instance.preferences.toJson(),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'lastSeenAt': const TimestampConverter().toJson(instance.lastSeenAt),
      'role': instance.$type,
    };
