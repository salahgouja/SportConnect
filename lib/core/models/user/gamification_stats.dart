import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'achievement.dart';

part 'gamification_stats.freezed.dart';
part 'gamification_stats.g.dart';

/// Single sealed class handling both types
@Freezed(unionKey: 'type') // Optional: adds a 'type' field to JSON
sealed class GamificationStats with _$GamificationStats {
  const GamificationStats._();

  /// Rider Stats
  /// naming the result 'RiderGamificationStats' allows you to keep using
  /// that type explicitly in your UserModel
  @FreezedUnionValue('rider')
  const factory GamificationStats.rider({
    @Default(0) int totalXP,
    @Default(1) int level,
    @Default(0) int currentLevelXP,
    @Default(1000) int xpToNextLevel,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double co2Saved,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
    @TimestampConverter() DateTime? lastRideDate,

    // RIDER SPECIFIC
    @Default(0.0) double moneySaved,
  }) = RiderGamificationStats;

  /// Driver Stats
  @FreezedUnionValue('driver')
  const factory GamificationStats.driver({
    @Default(0) int totalXP,
    @Default(1) int level,
    @Default(0) int currentLevelXP,
    @Default(1000) int xpToNextLevel,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double co2Saved,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
    @TimestampConverter() DateTime? lastRideDate,

    // DRIVER SPECIFIC
    @Default(0.0) double totalEarnings,
  }) = DriverGamificationStats;

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatsFromJson(json);
}
