// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiderGamificationStats _$RiderGamificationStatsFromJson(Map json) =>
    RiderGamificationStats(
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
                (e) =>
                    Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      lastRideDate: const TimestampConverter().fromJson(json['lastRideDate']),
      moneySaved: (json['moneySaved'] as num?)?.toDouble() ?? 0.0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$RiderGamificationStatsToJson(
  RiderGamificationStats instance,
) => <String, dynamic>{
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
  'moneySaved': instance.moneySaved,
  'type': instance.$type,
};

DriverGamificationStats _$DriverGamificationStatsFromJson(Map json) =>
    DriverGamificationStats(
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
                (e) =>
                    Achievement.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
      lastRideDate: const TimestampConverter().fromJson(json['lastRideDate']),
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$DriverGamificationStatsToJson(
  DriverGamificationStats instance,
) => <String, dynamic>{
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
  'totalEarnings': instance.totalEarnings,
  'type': instance.$type,
};
