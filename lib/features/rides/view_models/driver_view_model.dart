import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/services/ride_request_service.dart';

part 'driver_view_model.g.dart';

/// Aggregated dashboard state owned entirely by [DriverViewModel].
/// Views watch ONLY this class — they do not watch any repository or stream
/// provider directly.
class DriverState {
  // ── Action state ──────────────────────────────────────────────────────────
  /// True while an async action (toggle online, accept/decline) is running.
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastStatusChange;

  // ── Derived from streams (via ref.listen — never reset by build()) ─────────
  /// Live online/offline status synced from Firestore via ref.listen.
  final bool isOnline;

  // ── Aggregated data (via ref.watch in build()) ────────────────────────────
  /// Current authenticated user model.
  final AsyncValue<UserModel?> user;

  /// Live driver stats (earnings, rating, ride count, …).
  final AsyncValue<DriverStats> stats;

  /// Live list of pending ride requests.
  final AsyncValue<List<RideRequestModel>> pendingRequests;

  /// Live list of accepted ride requests.
  final AsyncValue<List<RideRequestModel>> acceptedRequests;

  /// Live list of rejected/declined ride requests.
  final AsyncValue<List<RideRequestModel>> rejectedRequests;

  /// Live upcoming scheduled rides.
  final AsyncValue<List<RideModel>> upcomingRides;

  /// Live earnings transaction history.
  final AsyncValue<List<EarningsTransaction>> earningsTransactions;

  const DriverState({
    this.isLoading = false,
    this.errorMessage,
    this.lastStatusChange,
    this.isOnline = false,
    this.user = const AsyncLoading(),
    this.stats = const AsyncLoading(),
    this.pendingRequests = const AsyncLoading(),
    this.acceptedRequests = const AsyncLoading(),
    this.rejectedRequests = const AsyncLoading(),
    this.upcomingRides = const AsyncLoading(),
    this.earningsTransactions = const AsyncLoading(),
  });

  DriverState copyWith({
    bool? isLoading,
    String? errorMessage,
    DateTime? lastStatusChange,
    bool? isOnline,
    AsyncValue<UserModel?>? user,
    AsyncValue<DriverStats>? stats,
    AsyncValue<List<RideRequestModel>>? pendingRequests,
    AsyncValue<List<RideRequestModel>>? acceptedRequests,
    AsyncValue<List<RideRequestModel>>? rejectedRequests,
    AsyncValue<List<RideModel>>? upcomingRides,
    AsyncValue<List<EarningsTransaction>>? earningsTransactions,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
      isOnline: isOnline ?? this.isOnline,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      rejectedRequests: rejectedRequests ?? this.rejectedRequests,
      upcomingRides: upcomingRides ?? this.upcomingRides,
      earningsTransactions: earningsTransactions ?? this.earningsTransactions,
    );
  }
}

/// ViewModel for all driver dashboard screens.
///
/// Aggregates all stream data so views only need to watch this single
/// provider — following Flutter Architecture's MVVM recommendation that
/// views should not reference repository / stream providers directly.
///
/// Design notes:
/// - Data streams are subscribed via [ref.listen] so that build() is NOT
///   re-called on each emission (which would reset [isLoading]/[errorMessage]).
/// - The state is mutated granularly inside the listeners, preserving transient
///   action state across Firestore updates.
@riverpod
class DriverViewModel extends _$DriverViewModel {
  @override
  DriverState build() {
    // ── Subscribe to all data streams via ref.listen ──────────────────────
    // ref.listen is used (not ref.watch) so that incoming Firestore emissions
    // do NOT trigger a full build() re-run which would reset isLoading etc.

    ref.listen(currentUserProvider, (_, next) {
      state = state.copyWith(user: next);
    });

    ref.listen(driverStatsProvider, (_, next) {
      final newIsOnline = next.whenOrNull(data: (s) => s.isOnline);
      state = state.copyWith(
        stats: next,
        isOnline: newIsOnline ?? state.isOnline,
      );
    });

    ref.listen(pendingRideRequestsProvider, (_, next) {
      state = state.copyWith(pendingRequests: next);
    });

    ref.listen(acceptedRideRequestsProvider, (_, next) {
      state = state.copyWith(acceptedRequests: next);
    });

    ref.listen(rejectedRideRequestsProvider, (_, next) {
      state = state.copyWith(rejectedRequests: next);
    });

    ref.listen(upcomingDriverRidesProvider, (_, next) {
      state = state.copyWith(upcomingRides: next);
    });

    ref.listen(earningsTransactionsProvider, (_, next) {
      state = state.copyWith(earningsTransactions: next);
    });

    // Seed initial values from already-cached providers (avoids a loading
    // frame when the underlying providers are already populated).
    final initialStats = ref.read(driverStatsProvider);
    final initialUser = ref.read(currentUserProvider);

    return DriverState(
      user: initialUser,
      stats: initialStats,
      isOnline: initialStats.whenOrNull(data: (s) => s.isOnline) ?? false,
      pendingRequests: ref.read(pendingRideRequestsProvider),
      acceptedRequests: ref.read(acceptedRideRequestsProvider),
      rejectedRequests: ref.read(rejectedRideRequestsProvider),
      upcomingRides: ref.read(upcomingDriverRidesProvider),
      earningsTransactions: ref.read(earningsTransactionsProvider),
    );
  }

  String? _getCurrentUserId() {
    final userAsync = ref.read(currentUserProvider);
    return userAsync.value?.uid;
  }

  /// Toggle driver online status
  Future<void> toggleOnlineStatus() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(driverStatsRepositoryProvider);
      final newStatus = !state.isOnline;
      await repository.setOnlineStatus(userId, newStatus);

      state = state.copyWith(
        isOnline: newStatus,
        isLoading: false,
        lastStatusChange: DateTime.now(),
      );

      // Refresh stats
      ref.invalidate(driverStatsProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update status: $e',
      );
    }
  }

  /// Go online
  Future<void> goOnline() async {
    if (state.isOnline) return;
    await toggleOnlineStatus();
  }

  /// Go offline
  Future<void> goOffline() async {
    if (!state.isOnline) return;
    await toggleOnlineStatus();
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Force-refresh all underlying stream providers.
  ///
  /// Call this from pull-to-refresh gestures so the view does not need to
  /// import or reference the underlying repository providers directly.
  void refresh() {
    ref.invalidate(driverStatsProvider);
    ref.invalidate(pendingRideRequestsProvider);
    ref.invalidate(acceptedRideRequestsProvider);
    ref.invalidate(rejectedRideRequestsProvider);
    ref.invalidate(upcomingDriverRidesProvider);
    ref.invalidate(earningsTransactionsProvider);
  }

  /// Accept a ride request.
  ///
  /// Routes through [RideRequestService] so that capacity updates and
  /// passenger notifications are handled in one consistent place.
  Future<bool> acceptRideRequest(String rideId, String requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .acceptRequest(requestId);

      state = state.copyWith(isLoading: false);
      ref.invalidate(pendingRideRequestsProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to accept request: $e',
      );
      return false;
    }
  }

  /// Decline a ride request.
  ///
  /// Routes through [RideRequestService] so rejection notification
  /// is sent to the passenger.
  Future<bool> declineRideRequest(String rideId, String requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .rejectRequest(requestId, 'Declined by driver');

      state = state.copyWith(isLoading: false);
      ref.invalidate(pendingRideRequestsProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to decline request: $e',
      );
      return false;
    }
  }
}
