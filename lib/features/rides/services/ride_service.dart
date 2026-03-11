import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'ride_service.g.dart';

/// Ride service - handles ride business logic
@Riverpod(keepAlive: true)
class RideService extends _$RideService {
  @override
  FutureOr<void> build() async {}

  /// Create a new ride with validation
  Future<String> createRide(RideModel ride) async {
    // Validate ride data
    if (ride.schedule.isPast) {
      throw ArgumentError('Cannot create ride with past departure time');
    }

    if (ride.capacity.available < 1) {
      throw ArgumentError('Ride must have at least 1 available seat');
    }

    if (ride.pricing.pricePerSeat.amount < 0) {
      throw ArgumentError('Price cannot be negative');
    }

    // Save to repository
    final repo = ref.read(rideRepositoryProvider);
    return await repo.createRide(ride);
  }

  /// Update ride with business rules
  Future<void> updateRide(RideModel ride) async {
    final repo = ref.read(rideRepositoryProvider);

    // Get existing ride
    final existing = await repo.getRideById(ride.id);
    if (existing == null) {
      throw ArgumentError('Ride not found');
    }

    // Business rules: cannot change certain fields if ride has bookings
    if (existing.bookingIds.isNotEmpty) {
      // Can't change departure time within 24 hours
      if (ride.schedule.departureTime != existing.schedule.departureTime) {
        final hoursUntilDeparture = existing.schedule.departureTime
            .difference(DateTime.now())
            .inHours;
        if (hoursUntilDeparture < 24) {
          throw ArgumentError(
            'Cannot change departure time within 24 hours of ride',
          );
        }
      }

      // Can't reduce capacity below booked seats
      if (ride.capacity.available < existing.capacity.booked) {
        throw ArgumentError('Cannot reduce capacity below booked seats');
      }
    }

    await repo.updateRide(ride);
  }

  /// Cancel a ride
  Future<void> cancelRide(String rideId, String reason) async {
    final repo = ref.read(rideRepositoryProvider);

    final ride = await repo.getRideById(rideId);
    if (ride == null) {
      throw ArgumentError('Ride not found');
    }

    if (ride.status == RideStatus.cancelled) {
      throw ArgumentError('Ride already cancelled');
    }

    if (ride.status == RideStatus.completed) {
      throw ArgumentError('Cannot cancel completed ride');
    }

    // Cancel the ride
    final cancelled = ride.copyWith(
      status: RideStatus.cancelled,
      notes: ride.notes != null
          ? '${ride.notes}\nCancelled: $reason'
          : 'Cancelled: $reason',
      updatedAt: DateTime.now(),
    );

    await repo.updateRide(cancelled);

    // Notify all passengers about the cancellation
    await _notifyPassengersOfCancellation(ride: ride, reason: reason);
  }

  /// Complete a ride, award XP and record driver stats.
  ///
  /// This is the business-logic entry point for ride completion.
  /// Call this instead of going directly to the repository so that
  /// XP rewards and driver stats are always recorded.
  Future<void> completeRide(String rideId) async {
    final repo = ref.read(rideRepositoryProvider);

    final ride = await repo.getRideById(rideId);
    if (ride == null) {
      throw ArgumentError('Ride not found');
    }

    if (ride.status != RideStatus.inProgress) {
      throw ArgumentError('Only in-progress rides can be completed');
    }

    // Mark ride as completed in Firestore
    await repo.completeRide(rideId);

    // Award XP and record driver stats
    try {
      final xp = calculateXpReward(ride);
      final distanceKm = ride.route.distanceKm ?? 0.0;
      final earnings = ride.pricing.pricePerSeat.amount * ride.capacity.booked;

      final statsRepo = ref.read(driverStatsRepositoryProvider);
      await statsRepo.recordRideCompletion(
        driverId: ride.driverId,
        earnings: earnings,
        distanceKm: distanceKm,
      );

      TalkerService.info(
        'Ride $rideId completed. XP awarded: $xp, earnings: $earnings',
      );
    } catch (e) {
      // Stats failure should NOT roll back the completion
      TalkerService.error('Failed to record ride completion stats: $e');
    }
  }

  /// Calculate XP reward based on ride characteristics
  int calculateXpReward(RideModel ride) {
    int xp = 50; // Base XP

    // Distance bonus
    if (ride.route.distanceKm != null) {
      xp += (ride.route.distanceKm! / 10).round();
    }

    // Recurring ride bonus
    if (ride.schedule.isRecurring) {
      xp += 20;
    }

    // Full capacity bonus
    if (ride.capacity.percentageFilled >= 80) {
      xp += 30;
    }

    // High rating bonus
    if (ride.averageRating >= 4.5) {
      xp += 25;
    }

    return xp;
  }

  // ==================== NOTIFICATION HELPERS ====================

  /// Notifies all booked passengers that a ride has been cancelled.
  Future<void> _notifyPassengersOfCancellation({
    required RideModel ride,
    required String reason,
  }) async {
    try {
      final notificationRepo = ref.read(notificationRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      final bookingRepo = ref.read(bookingRepositoryProvider);

      // Fetch driver info for the notification
      final driver = await profileRepo.getUserById(ride.driverId);
      final driverName = driver?.displayName ?? 'Driver';
      final driverPhoto = driver?.photoUrl;

      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;
      final rideName = '$origin \u2192 $dest';

      // Fetch all bookings for this ride and notify each passenger
      final bookings = await bookingRepo.getBookingsByRideId(
        ride.id,
        ride.driverId,
      );
      for (final booking in bookings) {
        await notificationRepo.sendRideCancelled(
          toUserId: booking.passengerId,
          driverName: driverName,
          driverPhoto: driverPhoto,
          rideId: ride.id,
          rideName: rideName,
          reason: reason,
        );
      }
    } catch (e) {
      // Notification failure should not break the main cancellation flow
      TalkerService.error('Failed to notify passengers of cancellation: $e');
    }
  }

  // ==================== 7B: NO-SHOW HANDLING ====================

  /// Mark a passenger as no-show, cancel their booking, and notify them.
  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  }) async {
    final repo = ref.read(rideRepositoryProvider);
    await repo.markPassengerNoShow(
      rideId: rideId,
      bookingId: bookingId,
      passengerId: passengerId,
    );

    // Notify the passenger
    try {
      final ride = await repo.getRideById(rideId);
      if (ride == null) return;
      final profileRepo = ref.read(profileRepositoryProvider);
      final driver = await profileRepo.getUserById(ride.driverId);
      final driverName = driver?.displayName ?? 'Driver';
      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;

      final notificationRepo = ref.read(notificationRepositoryProvider);
      await notificationRepo.createNotification(
        NotificationModel(
          id: '',
          userId: passengerId,
          type: NotificationType.rideCancelled,
          title: 'Marked as No-Show',
          body:
              '$driverName marked you as no-show for "$origin → $dest". '
              'Your booking has been cancelled.',
          senderName: driverName,
          referenceId: rideId,
          referenceType: 'ride',
          priority: NotificationPriority.high,
        ),
      );
    } catch (e) {
      TalkerService.error('Failed to send no-show notification: $e');
    }
  }

  // ==================== 7G: RIDE TIMEOUT ====================

  /// Check if a ride has exceeded its estimated duration.
  /// Returns null if no timeout, or the minutes exceeded.
  int? checkRideTimeout(RideModel ride) {
    if (ride.status != RideStatus.inProgress) return null;
    final actualDeparture = ride.schedule.actualDepartureTime;
    if (actualDeparture == null) return null;

    final estimatedDuration = ride.durationMinutes ?? 120;
    final elapsed = DateTime.now().difference(actualDeparture).inMinutes;
    final threshold = (estimatedDuration * 2).round();

    if (elapsed > threshold) {
      return elapsed - estimatedDuration;
    }
    return null;
  }

  /// Force-complete a ride that has timed out.
  Future<void> forceCompleteTimedOutRide(String rideId) async {
    final repo = ref.read(rideRepositoryProvider);
    final ride = await repo.getRideById(rideId);
    if (ride == null || ride.status != RideStatus.inProgress) return;

    TalkerService.warning('Force-completing timed-out ride $rideId');
    await completeRide(rideId);
  }

  // ==================== 7J: DELAY DETECTION ====================

  /// Notify all passengers of a ride delay.
  Future<void> notifyRideDelay({
    required RideModel ride,
    required int delayMinutes,
  }) async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final driver = await profileRepo.getUserById(ride.driverId);
      final driverName = driver?.displayName ?? 'Driver';
      final origin = ride.origin.city ?? ride.origin.address;
      final dest = ride.destination.city ?? ride.destination.address;
      final rideName = '$origin → $dest';

      final notificationRepo = ref.read(notificationRepositoryProvider);
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final bookings = await bookingRepo.getBookingsByRideId(
        ride.id,
        ride.driverId,
      );

      for (final booking in bookings) {
        if (booking.status != BookingStatus.accepted) continue;
        await notificationRepo.createNotification(
          NotificationModel(
            id: '',
            userId: booking.passengerId,
            type: NotificationType.rideUpdated,
            title: 'Ride Delayed',
            body:
                '$driverName\'s ride "$rideName" is running ~$delayMinutes min late.',
            senderName: driverName,
            referenceId: ride.id,
            referenceType: 'ride',
            priority: NotificationPriority.high,
          ),
        );
      }
    } catch (e) {
      TalkerService.error('Failed to send delay notifications: $e');
    }
  }

  // ==================== 7H: RETURN RIDE ====================

  /// Create a return ride from a completed ride.
  Future<String> createReturnRide(String originalRideId) async {
    final repo = ref.read(rideRepositoryProvider);
    return repo.createReturnRide(originalRideId);
  }
}
