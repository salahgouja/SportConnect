// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderboardEntry _$LeaderboardEntryFromJson(Map json) => _LeaderboardEntry(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  totalXP: (json['totalXP'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  rank: (json['rank'] as num).toInt(),
  photoUrl: json['photoUrl'] as String?,
  ridesThisMonth: (json['ridesThisMonth'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$LeaderboardEntryToJson(_LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'totalXP': instance.totalXP,
      'level': instance.level,
      'rank': instance.rank,
      'photoUrl': instance.photoUrl,
      'ridesThisMonth': instance.ridesThisMonth,
    };
