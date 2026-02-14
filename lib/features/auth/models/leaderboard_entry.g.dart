// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
