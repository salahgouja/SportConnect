import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

/// Driver Stats Repository
abstract class IDriverStatsRepository {
  /// Get driver stats
  Future<DriverStats> getDriverStats(String driverId);

  /// Stream driver stats
  Stream<DriverStats> streamDriverStats(String driverId);

  /// Stream pending bookings for driver
  Stream<List<RideBooking>> streamPendingRequests(String driverId);

  /// Stream accepted bookings for driver
  Stream<List<RideBooking>> streamAcceptedRequests(String driverId);

  /// Stream rejected/cancelled bookings for driver
  Stream<List<RideBooking>> streamRejectedRequests(String driverId);

  /// Get upcoming rides for driver
  Stream<List<RideModel>> streamUpcomingRides(String driverId);

  /// Get earnings transactions
  Stream<List<EarningsTransaction>> streamTransactions(String driverId);

  /// Accept a booking
  Future<void> acceptRequest(String rideId, String bookingId);

  /// Decline a booking
  Future<void> declineRequest(String rideId, String bookingId);

  /// Update driver stats after ride completion
  Future<void> recordRideCompletion({
    required String driverId,
    required double earnings,
    required double distanceKm,
  });
}
