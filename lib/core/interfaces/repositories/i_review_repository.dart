import 'package:sport_connect/features/reviews/models/review_model.dart';

abstract class IReviewRepository {
  /// Create a new review
  Future<ReviewModel> createReview(String? userId, CreateReviewRequest request);

  /// Get all reviews for a user (reviews they received)
  Future<List<ReviewModel>> getReviewsForUser(
    String userId, {
    ReviewType? type,
    int limit = 50,
    DateTime? startAfter,
  });

  /// Get all reviews left by a user
  Future<List<ReviewModel>> getReviewsByUser(String userId, {int limit = 50});

  /// Get reviews for a specific ride
  Future<List<ReviewModel>> getReviewsForRide(String rideId);

  /// Watch reviews for a user (real-time updates)
  Stream<List<ReviewModel>> watchReviewsForUser(String userId);

  /// Get rating stats for a user
  Future<RatingStats> getRatingStatsForUser(String userId);

  /// Add response to a review (by the reviewee)
  Future<void> respondToReview(String userId, String reviewId, String response);

  /// Delete a review (by reviewer or admin)
  Future<void> deleteReview(String userId, String reviewId);

  /// Check if user can review another user for a specific ride
  Future<bool> canReview(
    String userId, {
    required String rideId,
    required String revieweeId,
  });

  /// Get pending reviews (rides that user participated in but hasn't reviewed)
  Future<List<Map<String, dynamic>>> getPendingReviews(String userId);
}
