// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideReviewModel _$RideReviewModelFromJson(Map json) => _RideReviewModel(
  id: json['id'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  revieweeId: json['revieweeId'] as String,
  rating: (json['rating'] as num).toDouble(),
  reviewerPhotoUrl: json['reviewerPhotoUrl'] as String?,
  comment: json['comment'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$RideReviewModelToJson(_RideReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'revieweeId': instance.revieweeId,
      'rating': instance.rating,
      'reviewerPhotoUrl': instance.reviewerPhotoUrl,
      'comment': instance.comment,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
