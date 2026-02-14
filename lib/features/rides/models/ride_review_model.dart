import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'ride_review_model.freezed.dart';
part 'ride_review_model.g.dart';

/// Review model
@freezed
abstract class RideReviewModel with _$RideReviewModel {
  const factory RideReviewModel({
    required String id,
    required String reviewerId,
    required String reviewerName,
    String? reviewerPhotoUrl,
    required String revieweeId,
    required double rating,
    String? comment,
    @Default([]) List<String> tags,
    @TimestampConverter() DateTime? createdAt,
  }) = _RideReviewModel;

  factory RideReviewModel.fromJson(Map<String, dynamic> json) =>
      _$RideReviewModelFromJson(json);
}
