import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

part 'ride_request_service.g.dart';

/// Result wrapper for operations
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

/// Ride request service - handles business logic
/// Moved from model extensions to proper service layer
@riverpod
class RideRequestService extends _$RideRequestService {
  @override
  FutureOr<void> build() async {}

  /// Accept a ride request
  /// Business logic: validation, state updates, notifications
  Future<Result<RideRequestModel>> acceptRequest(String requestId) async {
    try {
      // Get the repository
      final repo = ref.read(rideRepositoryProvider);

      // Get request
      final request = await repo.getRideRequest(requestId);
      if (request == null) {
        return const Failure('Request not found');
      }

      // Validation
      if (!request.isPending) {
        return const Failure('Request already processed');
      }

      if (request.isExpired) {
        return const Failure('Request has expired');
      }

      // Check ride capacity
      final ride = await repo.getRideById(request.rideId);
      if (ride == null) {
        return const Failure('Ride not found');
      }

      if (!ride.capacity.canBook(request.requestedSeats)) {
        return const Failure('Not enough seats available');
      }

      // Accept the request
      final accepted = request.copyWith(
        status: RideRequestStatus.accepted,
        respondedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update request
      await repo.updateRideRequest(accepted);

      // Update ride capacity
      final newCapacity = ride.capacity.bookSeats(request.requestedSeats);
      if (newCapacity != null) {
        await repo.updateRide(ride.copyWith(capacity: newCapacity));
      }

      // Send notification to the requester that their request was accepted
      await _sendAcceptedNotification(
        requesterId: accepted.requesterId,
        driverId: accepted.driverId,
        rideId: accepted.rideId,
        ride: ride,
      );

      return Success(accepted);
    } catch (e) {
      return Failure('Failed to accept request: $e');
    }
  }

  /// Reject a ride request
  Future<Result<RideRequestModel>> rejectRequest(
    String requestId,
    String reason,
  ) async {
    try {
      final repo = ref.read(rideRepositoryProvider);

      final request = await repo.getRideRequest(requestId);
      if (request == null) {
        return const Failure('Request not found');
      }

      if (!request.isPending) {
        return const Failure('Request already processed');
      }

      final rejected = request.copyWith(
        status: RideRequestStatus.rejected,
        rejectionReason: reason,
        respondedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.updateRideRequest(rejected);

      // Fetch ride info for the notification
      final ride = await repo.getRideById(rejected.rideId);

      // Send notification to the requester that their request was rejected
      await _sendRejectedNotification(
        requesterId: rejected.requesterId,
        driverId: rejected.driverId,
        rideId: rejected.rideId,
        ride: ride,
        reason: reason,
      );

      return Success(rejected);
    } catch (e) {
      return Failure('Failed to reject request: $e');
    }
  }

  /// Cancel a ride request (by requester)
  Future<Result<RideRequestModel>> cancelRequest(String requestId) async {
    try {
      final repo = ref.read(rideRepositoryProvider);

      final request = await repo.getRideRequest(requestId);
      if (request == null) {
        return const Failure('Request not found');
      }

      if (!request.isPending) {
        return const Failure('Cannot cancel processed request');
      }

      final cancelled = request.copyWith(
        status: RideRequestStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await repo.updateRideRequest(cancelled);

      return Success(cancelled);
    } catch (e) {
      return Failure('Failed to cancel request: $e');
    }
  }

  /// Check if request is active (helper)
  bool isRequestActive(RideRequestModel request) {
    return request.isPending && !request.isExpired;
  }

  /// Get active requests for a ride
  Future<List<RideRequestModel>> getActiveRequests(String rideId) async {
    final repo = ref.read(rideRepositoryProvider);
    final requests = await repo.getRideRequests(rideId).first;
    return requests.where((r) => isRequestActive(r)).toList();
  }

  // ==================== NOTIFICATION HELPERS ====================

  /// Sends an accepted notification to the requester.
  Future<void> _sendAcceptedNotification({
    required String requesterId,
    required String driverId,
    required String rideId,
    required RideModel? ride,
  }) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      final driver = await profileRepo.getUserById(driverId);
      final rideName = _formatRideName(ride);

      await notificationRepo.sendRideBookingAccepted(
        toUserId: requesterId,
        driverName: driver?.displayName ?? 'Driver',
        driverPhoto: driver?.photoUrl,
        rideId: rideId,
        rideName: rideName,
      );
    } catch (e) {
      // Notification failure should not break the main flow
      TalkerService.error('Failed to send accepted notification: $e');
    }
  }

  /// Sends a rejected notification to the requester.
  Future<void> _sendRejectedNotification({
    required String requesterId,
    required String driverId,
    required String rideId,
    required RideModel? ride,
    String? reason,
  }) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      final driver = await profileRepo.getUserById(driverId);
      final rideName = _formatRideName(ride);

      await notificationRepo.sendRideBookingRejected(
        toUserId: requesterId,
        driverName: driver?.displayName ?? 'Driver',
        driverPhoto: driver?.photoUrl,
        rideId: rideId,
        rideName: rideName,
        reason: reason,
      );
    } catch (e) {
      TalkerService.error('Failed to send rejected notification: $e');
    }
  }

  /// Formats a ride name for notification display.
  String _formatRideName(RideModel? ride) {
    if (ride == null) return 'ride';
    final origin = ride.origin.city ?? ride.origin.address;
    final dest = ride.destination.city ?? ride.destination.address;
    return '$origin → $dest';
  }
}
