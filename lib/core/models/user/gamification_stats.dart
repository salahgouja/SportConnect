import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/models/user/achievement.dart';

part 'gamification_stats.freezed.dart';
part 'gamification_stats.g.dart';

@freezed
abstract class GamificationStats with _$GamificationStats {
  const factory GamificationStats({
    @Default(0) int totalXP,
    @Default(0) int totalRides,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0.0) double totalDistance,
    @Default([]) List<String> unlockedBadges,
    @Default([]) List<Achievement> achievements,
  }) = _GamificationStats;

  const GamificationStats._();

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatsFromJson(json);

  // Example: 1000 XP per level
  int get level => (totalXP / 1000).floor() + 1;

  int get currentLevelXP => totalXP % 1000;

  double get levelProgress => (totalXP % 1000) / 1000;

  int get xpToNextLevel => 1000 - (totalXP % 1000);
}
