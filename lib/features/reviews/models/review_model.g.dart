// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewModel _$ReviewModelFromJson(Map json) => _ReviewModel(
  id: json['id'] as String,
  rideId: json['rideId'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  revieweeId: json['revieweeId'] as String,
  revieweeName: json['revieweeName'] as String,
  type: $enumDecode(_$ReviewTypeEnumMap, json['type']),
  rating: (json['rating'] as num).toDouble(),
  createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
  reviewerPhotoUrl: json['reviewerPhotoUrl'] as String?,
  revieweePhotoUrl: json['revieweePhotoUrl'] as String?,
  comment: json['comment'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isVisible: json['isVisible'] as bool? ?? true,
  response: json['response'] as String?,
  responseAt: const TimestampConverter().fromJson(json['responseAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ReviewModelToJson(
  _ReviewModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'rideId': instance.rideId,
  'reviewerId': instance.reviewerId,
  'reviewerName': instance.reviewerName,
  'revieweeId': instance.revieweeId,
  'revieweeName': instance.revieweeName,
  'type': _$ReviewTypeEnumMap[instance.type]!,
  'rating': instance.rating,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'reviewerPhotoUrl': instance.reviewerPhotoUrl,
  'revieweePhotoUrl': instance.revieweePhotoUrl,
  'comment': instance.comment,
  'tags': instance.tags,
  'isVisible': instance.isVisible,
  'response': instance.response,
  'responseAt': const TimestampConverter().toJson(instance.responseAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$ReviewTypeEnumMap = {
  ReviewType.driver: 'driver',
  ReviewType.rider: 'rider',
};

_RatingStats _$RatingStatsFromJson(Map json) => _RatingStats(
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  fiveStarCount: (json['fiveStarCount'] as num?)?.toInt() ?? 0,
  fourStarCount: (json['fourStarCount'] as num?)?.toInt() ?? 0,
  threeStarCount: (json['threeStarCount'] as num?)?.toInt() ?? 0,
  twoStarCount: (json['twoStarCount'] as num?)?.toInt() ?? 0,
  oneStarCount: (json['oneStarCount'] as num?)?.toInt() ?? 0,
  tagCounts:
      (json['tagCounts'] as Map?)?.map(
        (k, e) => MapEntry(k as String, (e as num).toInt()),
      ) ??
      const {},
  lastReviewAt: const TimestampConverter().fromJson(json['lastReviewAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$RatingStatsToJson(_RatingStats instance) =>
    <String, dynamic>{
      'totalReviews': instance.totalReviews,
      'averageRating': instance.averageRating,
      'fiveStarCount': instance.fiveStarCount,
      'fourStarCount': instance.fourStarCount,
      'threeStarCount': instance.threeStarCount,
      'twoStarCount': instance.twoStarCount,
      'oneStarCount': instance.oneStarCount,
      'tagCounts': instance.tagCounts,
      'lastReviewAt': const TimestampConverter().toJson(instance.lastReviewAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_CreateReviewRequest _$CreateReviewRequestFromJson(Map json) =>
    _CreateReviewRequest(
      rideId: json['rideId'] as String,
      revieweeId: json['revieweeId'] as String,
      revieweeName: json['revieweeName'] as String,
      type: $enumDecode(_$ReviewTypeEnumMap, json['type']),
      rating: (json['rating'] as num).toDouble(),
      revieweePhotoUrl: json['revieweePhotoUrl'] as String?,
      comment: json['comment'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$CreateReviewRequestToJson(
  _CreateReviewRequest instance,
) => <String, dynamic>{
  'rideId': instance.rideId,
  'revieweeId': instance.revieweeId,
  'revieweeName': instance.revieweeName,
  'type': _$ReviewTypeEnumMap[instance.type]!,
  'rating': instance.rating,
  'revieweePhotoUrl': instance.revieweePhotoUrl,
  'comment': instance.comment,
  'tags': instance.tags,
};
