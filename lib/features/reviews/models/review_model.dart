import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Review type - whether it's for a driver or rider
enum ReviewType {
  @JsonValue('driver')
  driver, // Review left for a driver
  @JsonValue('rider')
  rider; // Review left for a rider/passenger

  String get displayName {
    switch (this) {
      case ReviewType.driver:
        return 'Driver Review';
      case ReviewType.rider:
        return 'Passenger Review';
    }
  }
}

/// Predefined review tags for quick feedback
enum ReviewTag {
  @JsonValue('punctual')
  punctual('Punctual', '⏰', ReviewType.driver),
  @JsonValue('great_conversation')
  greatConversation('Great Conversation', '💬', ReviewType.driver),
  @JsonValue('clean_car')
  cleanCar('Clean Car', '✨', ReviewType.driver),
  @JsonValue('safe_driver')
  safeDriver('Safe Driver', '🛡️', ReviewType.driver),
  @JsonValue('comfortable_ride')
  comfortableRide('Comfortable Ride', '🛋️', ReviewType.driver),
  @JsonValue('good_music')
  goodMusic('Good Music', '🎵', ReviewType.driver),
  @JsonValue('friendly')
  friendly('Friendly', '😊', ReviewType.driver),
  @JsonValue('professional')
  professional('Professional', '👔', ReviewType.driver),
  @JsonValue('flexible')
  flexible('Flexible', '🤝', ReviewType.driver),
  @JsonValue('respectful_rider')
  respectfulRider('Respectful', '🙏', ReviewType.rider),
  @JsonValue('on_time_rider')
  onTimeRider('On Time', '⏰', ReviewType.rider),
  @JsonValue('polite')
  polite('Polite', '😊', ReviewType.rider),
  @JsonValue('easy_communication')
  easyCommunication('Easy Communication', '💬', ReviewType.rider);

  final String label;
  final String emoji;
  final ReviewType applicableTo;

  const ReviewTag(this.label, this.emoji, this.applicableTo);

  static List<ReviewTag> getTagsFor(ReviewType type) {
    return ReviewTag.values.where((tag) => tag.applicableTo == type).toList();
  }
}

/// Timestamp converter for Firestore
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }
}

/// Required timestamp converter (non-nullable)
class RequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RequiredTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Review model - stored in /reviews collection
/// Firestore structure:
/// /reviews/{reviewId}
///   - id: string
///   - rideId: string (reference to the ride)
///   - reviewerId: string (who wrote the review)
///   - revieweeId: string (who is being reviewed)
///   - type: ReviewType (driver or rider)
///   - rating: double (1-5)
///   - comment: string?
///   - tags: List<ReviewTag>
///   - isVisible: bool
///   - response: string? (optional response from reviewee)
///   - createdAt: timestamp
///   - updatedAt: timestamp
@freezed
abstract class ReviewModel with _$ReviewModel {
  const ReviewModel._();

  const factory ReviewModel({
    required String id,
    required String rideId,
    required String reviewerId,
    required String reviewerName,
    String? reviewerPhotoUrl,
    required String revieweeId,
    required String revieweeName,
    String? revieweePhotoUrl,
    required ReviewType type,
    required double rating,
    String? comment,
    @Default([])
    List<String> tags, // Store as strings for Firestore compatibility
    @Default(true) bool isVisible,
    String? response, // Response from the person being reviewed
    @TimestampConverter() DateTime? responseAt,
    @RequiredTimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  /// Get the display tags as ReviewTag enums
  List<ReviewTag> get reviewTags {
    return tags
        .map((t) {
          try {
            return ReviewTag.values.firstWhere((tag) => tag.name == t);
          } catch (_) {
            return null;
          }
        })
        .whereType<ReviewTag>()
        .toList();
  }

  /// Get formatted rating (e.g., "4.5")
  String get formattedRating => rating.toStringAsFixed(1);

  /// Check if review has a response
  bool get hasResponse => response != null && response!.isNotEmpty;

  /// Get time since review was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Aggregated rating stats - stored as a subcollection or embedded in user document
/// This is computed and cached for performance
@freezed
abstract class RatingStats with _$RatingStats {
  const RatingStats._();

  const factory RatingStats({
    @Default(0) int totalReviews,
    @Default(0.0) double averageRating,
    @Default(0) int fiveStarCount,
    @Default(0) int fourStarCount,
    @Default(0) int threeStarCount,
    @Default(0) int twoStarCount,
    @Default(0) int oneStarCount,
    @Default({}) Map<String, int> tagCounts, // Tag -> count
    @TimestampConverter() DateTime? lastReviewAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _RatingStats;

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  /// Get the distribution percentages
  Map<int, double> get distribution {
    if (totalReviews == 0) {
      return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    }
    return {
      5: (fiveStarCount / totalReviews) * 100,
      4: (fourStarCount / totalReviews) * 100,
      3: (threeStarCount / totalReviews) * 100,
      2: (twoStarCount / totalReviews) * 100,
      1: (oneStarCount / totalReviews) * 100,
    };
  }

  /// Get top tags (most used)
  List<MapEntry<String, int>> get topTags {
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Get formatted average (e.g., "4.5")
  String get formattedAverage => averageRating.toStringAsFixed(1);

  /// Create stats from a list of reviews
  factory RatingStats.fromReviews(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const RatingStats();
    }

    int fiveStar = 0;
    int fourStar = 0;
    int threeStar = 0;
    int twoStar = 0;
    int oneStar = 0;
    double totalRating = 0;
    Map<String, int> tagCounts = {};

    for (final review in reviews) {
      totalRating += review.rating;

      // Count stars
      final rounded = review.rating.round();
      switch (rounded) {
        case 5:
          fiveStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 1:
          oneStar++;
          break;
      }

      // Count tags
      for (final tag in review.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Sort reviews by date to get latest
    final sortedReviews = List<ReviewModel>.from(reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RatingStats(
      totalReviews: reviews.length,
      averageRating: totalRating / reviews.length,
      fiveStarCount: fiveStar,
      fourStarCount: fourStar,
      threeStarCount: threeStar,
      twoStarCount: twoStar,
      oneStarCount: oneStar,
      tagCounts: tagCounts,
      lastReviewAt: sortedReviews.first.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Review request - used when creating a new review
@freezed
abstract class CreateReviewRequest with _$CreateReviewRequest {
  const factory CreateReviewRequest({
    required String rideId,
    required String revieweeId,
    required String revieweeName,
    String? revieweePhotoUrl,
    required ReviewType type,
    required double rating,
    String? comment,
    @Default([]) List<String> tags,
  }) = _CreateReviewRequest;

  factory CreateReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReviewRequestFromJson(json);
}
