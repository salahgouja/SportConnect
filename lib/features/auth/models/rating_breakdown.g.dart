// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
