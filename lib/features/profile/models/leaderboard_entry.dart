import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_entry.freezed.dart';
part 'leaderboard_entry.g.dart';

/// Leaderboard entry model for gamification / profile feature.
@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String displayName,
    required int totalXP,
    required int level,
    required int rank,
    String? photoUrl,
    @Default(0) int ridesThisMonth,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}
