import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'driver_view_model.g.dart';

/// Driver state for managing driver-related UI state
class DriverState {
  final bool isOnline;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastStatusChange;

  const DriverState({
    this.isOnline = false,
    this.isLoading = false,
    this.errorMessage,
    this.lastStatusChange,
  });

  DriverState copyWith({
    bool? isOnline,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastStatusChange,
  }) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
    );
  }
}

/// ViewModel for driver-related operations
/// Manages driver online status, ride requests, and dashboard state
@riverpod
class DriverViewModel extends _$DriverViewModel {
  @override
  DriverState build() {
    // Listen to driver stats to sync online status
    final statsAsync = ref.watch(driverStatsProvider);
    final isOnline =
        statsAsync.whenOrNull(data: (stats) => stats?.isOnline ?? false) ??
        false;

    return DriverState(isOnline: isOnline);
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

  /// Accept a ride request
  Future<bool> acceptRideRequest(String rideId, String bookingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(driverStatsRepositoryProvider);
      await repository.acceptRequest(rideId, bookingId);

      state = state.copyWith(isLoading: false);
      ref.invalidate(pendingRideRequestsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to accept request: $e',
      );
      return false;
    }
  }

  /// Decline a ride request
  Future<bool> declineRideRequest(String rideId, String bookingId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(driverStatsRepositoryProvider);
      await repository.declineRequest(rideId, bookingId);

      state = state.copyWith(isLoading: false);
      ref.invalidate(pendingRideRequestsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to decline request: $e',
      );
      return false;
    }
  }
}

/// Provider for the current driver tab index
@riverpod
class DriverTabIndex extends _$DriverTabIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
