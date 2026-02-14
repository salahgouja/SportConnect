import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/interfaces/repositories/i_review_repository.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:uuid/uuid.dart';

/// Firestore Collection Structure for Reviews:
///
/// /reviews/{reviewId}
///   - id: string
///   - rideId: string
///   - reviewerId: string
///   - reviewerName: string
///   - reviewerPhotoUrl: string?
///   - revieweeId: string
///   - revieweeName: string
///   - revieweePhotoUrl: string?
///   - type: string (driver/rider)
///   - rating: number
///   - comment: string?
///   - tags: array<string>
///   - isVisible: bool
///   - response: string?
///   - responseAt: timestamp?
///   - createdAt: timestamp
///   - updatedAt: timestamp?
///
/// Indexes needed:
/// - reviews: revieweeId ASC, createdAt DESC
/// - reviews: reviewerId ASC, createdAt DESC
/// - reviews: rideId ASC
/// - reviews: type ASC, revieweeId ASC, createdAt DESC
///
/// This design supports:
/// 1. Many-to-many: A user can review many users, and be reviewed by many users
/// 2. Efficient queries: Get all reviews for a user, or all reviews by a user
/// 3. Ride association: Link reviews to specific rides
/// 4. Response feature: Reviewees can respond to reviews
/// 5. Tag aggregation: Can compute tag statistics

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ReviewRepository(firestore, ref);
});

/// Provider to get reviews for a specific user
final userReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  userId,
) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getReviewsForUser(userId);
});

/// Provider to get reviews left by a specific user
final reviewsByUserProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  userId,
) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getReviewsByUser(userId);
});

/// Provider to get rating stats for a user
final userRatingStatsProvider = FutureProvider.family<RatingStats, String>((
  ref,
  userId,
) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getRatingStatsForUser(userId);
});

/// Provider to get reviews for a specific ride
final rideReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  rideId,
) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getReviewsForRide(rideId);
});

/// Stream provider for real-time review updates for a user
final userReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, userId) {
      final repo = ref.read(reviewRepositoryProvider);
      return repo.watchReviewsForUser(userId);
    });

class ReviewRepository implements IReviewRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;
  final _uuid = const Uuid();

  ReviewRepository(this._firestore, this._ref);

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  /// Create a new review
  Future<ReviewModel> createReview(CreateReviewRequest request) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Check if user already reviewed this person for this ride
    final existingReview = await _reviewsCollection
        .where('rideId', isEqualTo: request.rideId)
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('revieweeId', isEqualTo: request.revieweeId)
        .get();

    if (existingReview.docs.isNotEmpty) {
      throw Exception('You have already reviewed this person for this ride');
    }

    final now = DateTime.now();
    final reviewId = _uuid.v4();

    final review = ReviewModel(
      id: reviewId,
      rideId: request.rideId,
      reviewerId: currentUser.uid,
      reviewerName: currentUser.displayName,
      reviewerPhotoUrl: currentUser.photoUrl,
      revieweeId: request.revieweeId,
      revieweeName: request.revieweeName,
      revieweePhotoUrl: request.revieweePhotoUrl,
      type: request.type,
      rating: request.rating,
      comment: request.comment,
      tags: request.tags,
      isVisible: true,
      createdAt: now,
    );

    await _reviewsCollection.doc(reviewId).set(review.toJson());

    // Update the user's aggregated rating stats
    await _updateUserRatingStats(request.revieweeId);

    return review;
  }

  /// Get all reviews for a user (reviews they received)
  Future<List<ReviewModel>> getReviewsForUser(
    String userId, {
    ReviewType? type,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> query = _reviewsCollection
        .where('revieweeId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data()))
        .toList();
  }

  /// Get all reviews left by a user
  Future<List<ReviewModel>> getReviewsByUser(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _reviewsCollection
        .where('reviewerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data()))
        .toList();
  }

  /// Get reviews for a specific ride
  Future<List<ReviewModel>> getReviewsForRide(String rideId) async {
    final snapshot = await _reviewsCollection
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromJson(doc.data()))
        .toList();
  }

  /// Watch reviews for a user (real-time updates)
  Stream<List<ReviewModel>> watchReviewsForUser(String userId) {
    return _reviewsCollection
        .where('revieweeId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get rating stats for a user
  Future<RatingStats> getRatingStatsForUser(String userId) async {
    final reviews = await getReviewsForUser(userId);
    return RatingStats.fromReviews(reviews);
  }

  /// Add response to a review (by the reviewee)
  Future<void> respondToReview(String reviewId, String response) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    // Verify the current user is the reviewee
    final reviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final review = ReviewModel.fromJson(reviewDoc.data()!);
    if (review.revieweeId != currentUser.uid) {
      throw Exception('Only the reviewee can respond to this review');
    }

    await _reviewsCollection.doc(reviewId).update({
      'response': response,
      'responseAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a review (by reviewer or admin)
  Future<void> deleteReview(String reviewId) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final reviewDoc = await _reviewsCollection.doc(reviewId).get();
    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final review = ReviewModel.fromJson(reviewDoc.data()!);
    if (review.reviewerId != currentUser.uid) {
      throw Exception('Only the reviewer can delete this review');
    }

    // Soft delete - just hide the review
    await _reviewsCollection.doc(reviewId).update({
      'isVisible': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update the user's aggregated rating stats
    await _updateUserRatingStats(review.revieweeId);
  }

  /// Update user's aggregated rating stats
  Future<void> _updateUserRatingStats(String userId) async {
    final reviews = await getReviewsForUser(userId);
    final stats = RatingStats.fromReviews(reviews);

    // Update the user document with new stats
    await _firestore.collection('users').doc(userId).update({
      'rating': {
        'total': stats.totalReviews,
        'average': stats.averageRating,
        'fiveStars': stats.fiveStarCount,
        'fourStars': stats.fourStarCount,
        'threeStars': stats.threeStarCount,
        'twoStars': stats.twoStarCount,
        'oneStars': stats.oneStarCount,
      },
    });
  }

  /// Check if user can review another user for a specific ride
  Future<bool> canReview({
    required String rideId,
    required String revieweeId,
  }) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) return false;

    // Check if already reviewed
    final existing = await _reviewsCollection
        .where('rideId', isEqualTo: rideId)
        .where('reviewerId', isEqualTo: currentUser.uid)
        .where('revieweeId', isEqualTo: revieweeId)
        .get();

    return existing.docs.isEmpty;
  }

  /// Get pending reviews (rides that user participated in but hasn't reviewed)
  Future<List<Map<String, dynamic>>> getPendingReviews() async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) return [];

    // Get completed rides where user was a participant
    final completedRides = await _firestore
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .where('participantIds', arrayContains: currentUser.uid)
        .orderBy('updatedAt', descending: true)
        .limit(20)
        .get();

    final pending = <Map<String, dynamic>>[];

    for (final rideDoc in completedRides.docs) {
      final rideData = rideDoc.data();
      final rideId = rideDoc.id;
      final driverId = rideData['driverId'] as String;

      // Check if user is the driver or a passenger
      final isDriver = driverId == currentUser.uid;

      if (isDriver) {
        // Driver can review passengers
        final bookings = (rideData['bookings'] as List<dynamic>?) ?? [];
        for (final booking in bookings) {
          final passengerId = booking['passengerId'] as String;
          final canReviewPassenger = await canReview(
            rideId: rideId,
            revieweeId: passengerId,
          );
          if (canReviewPassenger) {
            pending.add({
              'rideId': rideId,
              'revieweeId': passengerId,
              'revieweeName': booking['passengerName'] ?? 'Passenger',
              'revieweePhotoUrl': booking['passengerPhotoUrl'],
              'type': ReviewType.rider,
              'rideDate': rideData['departureTime'],
              'origin': rideData['origin'],
              'destination': rideData['destination'],
            });
          }
        }
      } else {
        // Passenger can review driver
        final canReviewDriver = await canReview(
          rideId: rideId,
          revieweeId: driverId,
        );
        if (canReviewDriver) {
          pending.add({
            'rideId': rideId,
            'revieweeId': driverId,
            'revieweeName': rideData['driverName'] ?? 'Driver',
            'revieweePhotoUrl': rideData['driverPhotoUrl'],
            'type': ReviewType.driver,
            'rideDate': rideData['departureTime'],
            'origin': rideData['origin'],
            'destination': rideData['destination'],
          });
        }
      }
    }

    return pending;
  }
}
