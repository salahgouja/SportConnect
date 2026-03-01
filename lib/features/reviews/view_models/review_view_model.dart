import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';

part 'review_view_model.g.dart';

/// State for the review submission form
class ReviewFormState {
  final int rating;
  final String comment;
  final List<ReviewTag> selectedTags;
  final bool isSubmitting;
  final String? error;

  const ReviewFormState({
    this.rating = 0,
    this.comment = '',
    this.selectedTags = const [],
    this.isSubmitting = false,
    this.error,
  });

  ReviewFormState copyWith({
    int? rating,
    String? comment,
    List<ReviewTag>? selectedTags,
    bool? isSubmitting,
    String? error,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      selectedTags: selectedTags ?? this.selectedTags,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  bool get isValid => rating > 0 && rating <= 5;
}

/// State for the reviews list screen
class ReviewsListState {
  final List<ReviewModel> reviews;
  final RatingStats? stats;
  final bool isLoading;
  final String? error;
  final ReviewType? filterType;
  final bool hasMore;

  const ReviewsListState({
    this.reviews = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.filterType,
    this.hasMore = true,
  });

  ReviewsListState copyWith({
    List<ReviewModel>? reviews,
    RatingStats? stats,
    bool? isLoading,
    String? error,
    ReviewType? filterType,
    bool? hasMore,
  }) {
    return ReviewsListState(
      reviews: reviews ?? this.reviews,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterType: filterType,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Filter reviews by type if filter is set
  List<ReviewModel> get filteredReviews {
    final visible = reviews.where((r) => r.isVisible);
    if (filterType == null) return visible.toList();
    return visible.where((r) => r.type == filterType).toList();
  }

  /// Get average rating
  double get averageRating => stats?.averageRating ?? 0.0;

  /// Get total review count
  int get totalReviews => stats?.totalReviews ?? reviews.length;
}

/// ViewModel for submitting reviews
@riverpod
class ReviewFormViewModel extends _$ReviewFormViewModel {
  @override
  ReviewFormState build() => const ReviewFormState();

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  void toggleTag(ReviewTag tag) {
    final tags = List<ReviewTag>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(selectedTags: tags);
  }

  void clearTags() {
    state = state.copyWith(selectedTags: []);
  }

  /// Submit a review for a ride
  Future<bool> submitReview({
    required String rideId,
    required String revieweeId,
    required String revieweeName,
    String? revieweePhotoUrl,
    required ReviewType type,
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please provide a rating');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: 'You must be logged in to submit a review',
        );
        return false;
      }

      final repo = ref.read(reviewRepositoryProvider);

      // Convert ReviewTag enums to string names
      final tagStrings = state.selectedTags.map((tag) => tag.name).toList();

      await repo.createReview(
        currentUser.uid,
        CreateReviewRequest(
          rideId: rideId,
          revieweeId: revieweeId,
          revieweeName: revieweeName,
          revieweePhotoUrl: revieweePhotoUrl,
          type: type,
          rating: state.rating.toDouble(),
          comment: state.comment.isEmpty ? null : state.comment,
          tags: tagStrings,
        ),
      );

      // Reset form after successful submission
      state = const ReviewFormState();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit review: ${e.toString()}',
      );
      return false;
    }
  }
}

/// ViewModel for viewing reviews list
@riverpod
class ReviewsListViewModel extends _$ReviewsListViewModel {
  @override
  Future<ReviewsListState> build(String userId) async {
    return _loadReviews();
  }

  static const _pageSize = 20;

  Future<ReviewsListState> _loadReviews() async {
    try {
      final repo = ref.read(reviewRepositoryProvider);
      final reviews = await repo.getReviewsForUser(userId, limit: _pageSize);
      final stats = await repo.getRatingStatsForUser(userId);

      return ReviewsListState(
        reviews: reviews,
        stats: stats,
        isLoading: false,
        hasMore: reviews.length >= _pageSize,
      );
    } catch (e) {
      return ReviewsListState(
        isLoading: false,
        error: 'Failed to load reviews: ${e.toString()}',
      );
    }
  }

  void setFilterType(ReviewType? type) {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(filterType: type));
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadReviews());
  }

  /// Load next page of reviews using cursor-based pagination.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoading) return;

    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final repo = ref.read(reviewRepositoryProvider);
      // Use the last review's createdAt as cursor for Firestore startAfter
      final cursor = current.reviews.isNotEmpty
          ? current.reviews.last.createdAt
          : null;
      final more = await repo.getReviewsForUser(
        userId,
        limit: _pageSize,
        startAfter: cursor,
      );

      if (!ref.mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          reviews: [...current.reviews, ...more],
          isLoading: false,
          hasMore: more.length >= _pageSize,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          isLoading: false,
          error: 'Failed to load more: ${e.toString()}',
        ),
      );
    }
  }
}

/// ViewModel for responding to a review
@riverpod
class ReviewResponseViewModel extends _$ReviewResponseViewModel {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> submitResponse(String reviewId, String response) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return false;
      }

      final repo = ref.read(reviewRepositoryProvider);
      await repo.respondToReview(currentUser.uid, reviewId, response);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// VM-layer provider to get reviews for a specific ride
@riverpod
Future<List<ReviewModel>> rideReviews(Ref ref, String rideId) async {
  final repo = ref.read(reviewRepositoryProvider);
  return repo.getReviewsForRide(rideId);
}
