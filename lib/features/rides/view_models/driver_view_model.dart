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

final activeDriverRideProvider = StreamProvider<RideModel?>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) {
    return Stream.value(null);
  }

  final repository = ref.watch(rideRepositoryProvider);
  return repository.streamRidesByDriver(userId).map((rides) {
    RideModel? activeRide;

    for (final ride in rides) {
      if (ride.status != RideStatus.inProgress) {
        continue;
      }

      if (activeRide == null) {
        activeRide = ride;
        continue;
      }

      final currentUpdatedAt = activeRide.updatedAt ?? activeRide.createdAt;
      final nextUpdatedAt = ride.updatedAt ?? ride.createdAt;
      if ((nextUpdatedAt ?? ride.departureTime).isAfter(
        currentUpdatedAt ?? activeRide.departureTime,
      )) {
        activeRide = ride;
      }
    }

    return activeRide;
  });
});

/// Aggregated dashboard state owned entirely by [DriverViewModel].
/// Views watch ONLY this class — they do not watch any repository or stream
/// provider directly.
class DriverState {
  static const _unset = Object();

  // ── Action state ──────────────────────────────────────────────────────────
  /// True while an async action (toggle online, accept/decline) is running.
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final DateTime? lastStatusChange;
  final DateTime? lastRefreshAt;
  final Set<String> pendingRequestActionIds;

  // ── Derived from streams (via ref.listen — never reset by build()) ─────────
  /// Live online/offline status synced from Firestore via ref.listen.
  final bool isOnline;
  final AsyncValue<RideModel?> activeRideAsync;

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
    this.isRefreshing = false,
    this.errorMessage,
    this.lastStatusChange,
    this.lastRefreshAt,
    this.pendingRequestActionIds = const <String>{},
    this.isOnline = false,
    this.activeRideAsync = const AsyncLoading(),
    this.user = const AsyncLoading(),
    this.stats = const AsyncLoading(),
    this.pendingRequests = const AsyncLoading(),
    this.acceptedRequests = const AsyncLoading(),
    this.rejectedRequests = const AsyncLoading(),
    this.upcomingRides = const AsyncLoading(),
    this.earningsTransactions = const AsyncLoading(),
  });

  UserModel? get currentUser => user is AsyncData<UserModel?>
      ? (user as AsyncData<UserModel?>).value
      : null;
  DriverStats? get currentStats => stats is AsyncData<DriverStats>
      ? (stats as AsyncData<DriverStats>).value
      : null;
  RideModel? get activeRide => activeRideAsync is AsyncData<RideModel?>
      ? (activeRideAsync as AsyncData<RideModel?>).value
      : null;
  bool get hasActiveRide => activeRide != null;
  bool get hasProfileData => currentUser != null;
  List<RideRequestModel> get pendingRequestPreview =>
      (pendingRequests is AsyncData<List<RideRequestModel>>
              ? (pendingRequests as AsyncData<List<RideRequestModel>>).value
              : const <RideRequestModel>[])
          .take(2)
          .toList(growable: false);
  List<RideModel> get upcomingRidePreview =>
      (upcomingRides is AsyncData<List<RideModel>>
              ? (upcomingRides as AsyncData<List<RideModel>>).value
              : const <RideModel>[])
          .take(3)
          .toList(growable: false);
  int get pendingRequestCount =>
      pendingRequests is AsyncData<List<RideRequestModel>>
      ? (pendingRequests as AsyncData<List<RideRequestModel>>).value.length
      : 0;
  bool get hasPendingRequests => pendingRequestCount > 0;
  bool get hasUpcomingRides => upcomingRides is AsyncData<List<RideModel>>
      ? (upcomingRides as AsyncData<List<RideModel>>).value.isNotEmpty
      : false;
  bool isRequestActionInProgress(String requestId) =>
      pendingRequestActionIds.contains(requestId);

  DriverState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _unset,
    DateTime? lastStatusChange,
    DateTime? lastRefreshAt,
    Set<String>? pendingRequestActionIds,
    bool? isOnline,
    AsyncValue<RideModel?>? activeRideAsync,
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
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      pendingRequestActionIds:
          pendingRequestActionIds ?? this.pendingRequestActionIds,
      isOnline: isOnline ?? this.isOnline,
      activeRideAsync: activeRideAsync ?? this.activeRideAsync,
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
  Future<void>? _refreshOperation;

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

    ref.listen(activeDriverRideProvider, (_, next) {
      state = state.copyWith(activeRideAsync: next);
    });

    // Seed initial values from already-cached providers (avoids a loading
    // frame when the underlying providers are already populated).
    final initialStats = ref.read(driverStatsProvider);
    final initialUser = ref.read(currentUserProvider);

    return DriverState(
      user: initialUser,
      stats: initialStats,
      isOnline: initialStats.whenOrNull(data: (s) => s.isOnline) ?? false,
      activeRideAsync: ref.read(activeDriverRideProvider),
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
    if (userId == null || state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(driverStatsRepositoryProvider);
      final newStatus = !state.isOnline;
      await repository.setOnlineStatus(userId, newStatus);

      if (!ref.mounted) return;

      state = state.copyWith(
        isOnline: newStatus,
        isLoading: false,
        lastStatusChange: DateTime.now(),
      );

      // Refresh stats
      ref.invalidate(driverStatsProvider);
    } catch (e) {
      if (!ref.mounted) return;
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
  Future<void> refresh() {
    final existingOperation = _refreshOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final refreshOperation = _runRefresh();
    _refreshOperation = refreshOperation;
    return refreshOperation.whenComplete(() {
      if (identical(_refreshOperation, refreshOperation)) {
        _refreshOperation = null;
      }
    });
  }

  Future<void> _runRefresh() async {
    if (!ref.mounted) return;

    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      await Future.wait<void>([
        ref.refresh(currentUserProvider.future),
        ref.refresh(driverStatsProvider.future),
        ref.refresh(activeDriverRideProvider.future),
        ref.refresh(pendingRideRequestsProvider.future),
        ref.refresh(acceptedRideRequestsProvider.future),
        ref.refresh(rejectedRideRequestsProvider.future),
        ref.refresh(upcomingDriverRidesProvider.future),
        ref.refresh(earningsTransactionsProvider.future),
      ]);

      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        lastRefreshAt: DateTime.now(),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh dashboard: $e',
      );
    }
  }

  /// Accept a ride request.
  ///
  /// Routes through [RideRequestService] so that capacity updates and
  /// passenger notifications are handled in one consistent place.
  Future<bool> acceptRideRequest(String rideId, String requestId) async {
    if (rideId.isEmpty || requestId.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing ride request data.');
      return false;
    }
    if (state.pendingRequestActionIds.contains(requestId)) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    state = state.copyWith(
      pendingRequestActionIds: {...state.pendingRequestActionIds, requestId},
    );

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .acceptRequest(requestId);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(requestId),
      );
      ref.invalidate(pendingRideRequestsProvider);
      ref.invalidate(acceptedRideRequestsProvider);
      ref.invalidate(upcomingDriverRidesProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(requestId),
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
    if (rideId.isEmpty || requestId.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing ride request data.');
      return false;
    }
    if (state.pendingRequestActionIds.contains(requestId)) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    state = state.copyWith(
      pendingRequestActionIds: {...state.pendingRequestActionIds, requestId},
    );

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .rejectRequest(requestId, 'Declined by driver');

      if (!ref.mounted) return false;

      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(requestId),
      );
      ref.invalidate(pendingRideRequestsProvider);
      ref.invalidate(rejectedRideRequestsProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(requestId),
        errorMessage: 'Failed to decline request: $e',
      );
      return false;
    }
  }
}
