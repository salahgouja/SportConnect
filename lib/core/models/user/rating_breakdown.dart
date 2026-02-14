import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_breakdown.freezed.dart';
part 'rating_breakdown.g.dart';

/// Rating breakdown
@freezed
abstract class RatingBreakdown with _$RatingBreakdown {
  const factory RatingBreakdown({
    @Default(0) int total,
    @Default(0.0) double average,
    @Default(0) int fiveStars,
    @Default(0) int fourStars,
    @Default(0) int threeStars,
    @Default(0) int twoStars,
    @Default(0) int oneStars,
  }) = _RatingBreakdown;

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RatingBreakdownFromJson(json);
}
