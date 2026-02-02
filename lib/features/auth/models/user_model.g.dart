// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map json) => _Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  iconName: json['iconName'] as String,
  xpReward: (json['xpReward'] as num).toInt(),
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  unlockedAt: const TimestampConverter().fromJson(json['unlockedAt']),
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'xpReward': instance.xpReward,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': const TimestampConverter().toJson(instance.unlockedAt),
    };

_GamificationStats _$GamificationStatsFromJson(Map json) => _GamificationStats(
  totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
  level: (json['level'] as num?)?.toInt() ?? 1,
  currentLevelXP: (json['currentLevelXP'] as num?)?.toInt() ?? 0,
  xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 1000,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
  totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
  unlockedBadges:
      (json['unlockedBadges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  achievements:
      (json['achievements'] as List<dynamic>?)
          ?.map(
            (e) => Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  lastRideDate: const TimestampConverter().fromJson(json['lastRideDate']),
);

Map<String, dynamic> _$GamificationStatsToJson(_GamificationStats instance) =>
    <String, dynamic>{
      'totalXP': instance.totalXP,
      'level': instance.level,
      'currentLevelXP': instance.currentLevelXP,
      'xpToNextLevel': instance.xpToNextLevel,
      'totalRides': instance.totalRides,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'co2Saved': instance.co2Saved,
      'totalDistance': instance.totalDistance,
      'unlockedBadges': instance.unlockedBadges,
      'achievements': instance.achievements.map((e) => e.toJson()).toList(),
      'lastRideDate': const TimestampConverter().toJson(instance.lastRideDate),
    };

_RiderGamificationStats _$RiderGamificationStatsFromJson(Map json) =>
    _RiderGamificationStats(
      totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentLevelXP: (json['currentLevelXP'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 1000,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
      moneySaved: (json['moneySaved'] as num?)?.toDouble() ?? 0.0,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      unlockedBadges:
          (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map(
                (e) =>
                    Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      lastRideDate: const TimestampConverter().fromJson(json['lastRideDate']),
    );

Map<String, dynamic> _$RiderGamificationStatsToJson(
  _RiderGamificationStats instance,
) => <String, dynamic>{
  'totalXP': instance.totalXP,
  'level': instance.level,
  'currentLevelXP': instance.currentLevelXP,
  'xpToNextLevel': instance.xpToNextLevel,
  'totalRides': instance.totalRides,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'co2Saved': instance.co2Saved,
  'moneySaved': instance.moneySaved,
  'totalDistance': instance.totalDistance,
  'unlockedBadges': instance.unlockedBadges,
  'achievements': instance.achievements.map((e) => e.toJson()).toList(),
  'lastRideDate': const TimestampConverter().toJson(instance.lastRideDate),
};

_DriverGamificationStats _$DriverGamificationStatsFromJson(Map json) =>
    _DriverGamificationStats(
      totalXP: (json['totalXP'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      currentLevelXP: (json['currentLevelXP'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xpToNextLevel'] as num?)?.toInt() ?? 1000,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
      unlockedBadges:
          (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.map(
                (e) =>
                    Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      lastRideDate: const TimestampConverter().fromJson(json['lastRideDate']),
    );

Map<String, dynamic> _$DriverGamificationStatsToJson(
  _DriverGamificationStats instance,
) => <String, dynamic>{
  'totalXP': instance.totalXP,
  'level': instance.level,
  'currentLevelXP': instance.currentLevelXP,
  'xpToNextLevel': instance.xpToNextLevel,
  'totalRides': instance.totalRides,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'co2Saved': instance.co2Saved,
  'totalEarnings': instance.totalEarnings,
  'totalDistance': instance.totalDistance,
  'unlockedBadges': instance.unlockedBadges,
  'achievements': instance.achievements.map((e) => e.toJson()).toList(),
  'lastRideDate': const TimestampConverter().toJson(instance.lastRideDate),
};

_UserPreferences _$UserPreferencesFromJson(Map json) => _UserPreferences(
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  emailNotifications: json['emailNotifications'] as bool? ?? true,
  rideReminders: json['rideReminders'] as bool? ?? true,
  chatNotifications: json['chatNotifications'] as bool? ?? true,
  marketingEmails: json['marketingEmails'] as bool? ?? true,
  language: json['language'] as String? ?? 'en',
  theme: json['theme'] as String? ?? 'system',
  maxPickupRadius: (json['maxPickupRadius'] as num?)?.toDouble() ?? 5.0,
  showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
  allowMessages: json['allowMessages'] as bool? ?? true,
);

Map<String, dynamic> _$UserPreferencesToJson(_UserPreferences instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotifications': instance.emailNotifications,
      'rideReminders': instance.rideReminders,
      'chatNotifications': instance.chatNotifications,
      'marketingEmails': instance.marketingEmails,
      'language': instance.language,
      'theme': instance.theme,
      'maxPickupRadius': instance.maxPickupRadius,
      'showOnlineStatus': instance.showOnlineStatus,
      'allowMessages': instance.allowMessages,
    };

_Vehicle _$VehicleFromJson(Map json) => _Vehicle(
  id: json['id'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  fuelType: json['fuelType'] as String,
  year: (json['year'] as num).toInt(),
  color: json['color'] as String,
  licensePlate: json['licensePlate'] as String,
  seats: (json['seats'] as num?)?.toInt() ?? 4,
  imageUrl: json['imageUrl'] as String?,
  isDefault: json['isDefault'] as bool? ?? false,
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'make': instance.make,
  'model': instance.model,
  'fuelType': instance.fuelType,
  'year': instance.year,
  'color': instance.color,
  'licensePlate': instance.licensePlate,
  'seats': instance.seats,
  'imageUrl': instance.imageUrl,
  'isDefault': instance.isDefault,
  'isVerified': instance.isVerified,
};

_RatingBreakdown _$RatingBreakdownFromJson(Map json) => _RatingBreakdown(
  total: (json['total'] as num?)?.toInt() ?? 0,
  average: (json['average'] as num?)?.toDouble() ?? 0.0,
  fiveStars: (json['fiveStars'] as num?)?.toInt() ?? 0,
  fourStars: (json['fourStars'] as num?)?.toInt() ?? 0,
  threeStars: (json['threeStars'] as num?)?.toInt() ?? 0,
  twoStars: (json['twoStars'] as num?)?.toInt() ?? 0,
  oneStars: (json['oneStars'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RatingBreakdownToJson(_RatingBreakdown instance) =>
    <String, dynamic>{
      'total': instance.total,
      'average': instance.average,
      'fiveStars': instance.fiveStars,
      'fourStars': instance.fourStars,
      'threeStars': instance.threeStars,
      'twoStars': instance.twoStars,
      'oneStars': instance.oneStars,
    };

_LeaderboardEntry _$LeaderboardEntryFromJson(Map json) => _LeaderboardEntry(
  odid: json['odid'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  totalXP: (json['totalXP'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
  ridesThisMonth: (json['ridesThisMonth'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'odid': instance.odid,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'totalXP': instance.totalXP,
      'level': instance.level,
      'rank': instance.rank,
      'ridesThisMonth': instance.ridesThisMonth,
    };
