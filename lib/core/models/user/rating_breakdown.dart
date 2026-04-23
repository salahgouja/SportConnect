import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_breakdown.freezed.dart';
part 'rating_breakdown.g.dart';

@freezed
abstract class RatingBreakdown with _$RatingBreakdown {
  const factory RatingBreakdown({
    @Default(0) int fiveStars,
    @Default(0) int fourStars,
    @Default(0) int threeStars,
    @Default(0) int twoStars,
    @Default(0) int oneStars,
  }) = _RatingBreakdown;

  const RatingBreakdown._();

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RatingBreakdownFromJson(json);

  int get total => fiveStars + fourStars + threeStars + twoStars + oneStars;

  double get average {
    if (total == 0) return 0;
    return ((fiveStars * 5) +
            (fourStars * 4) +
            (threeStars * 3) +
            (twoStars * 2) +
            oneStars) /
        total;
  }
}
