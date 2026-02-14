import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

/// Driver Stats Repository
abstract class IDriverStatsRepository {
  /// Get driver stats
  Future<DriverStats> getDriverStats(String driverId);

  /// Stream driver stats
  Stream<DriverStats> streamDriverStats(String driverId);

  /// Update driver online status
  Future<void> setOnlineStatus(String driverId, bool isOnline);

  /// Get pending ride requests for driver
  Stream<List<RideRequestModel>> streamPendingRequests(String driverId);

  /// Get upcoming rides for driver - returns proper RideModel
  Stream<List<RideModel>> streamUpcomingRides(String driverId);

  /// Get earnings transactions
  Stream<List<EarningsTransaction>> streamTransactions(String driverId);

  /// Accept a ride request
  Future<void> acceptRequest(String rideId, String bookingId);

  /// Decline a ride request
  Future<void> declineRequest(String rideId, String bookingId);

  /// Update driver stats after ride completion
  Future<void> recordRideCompletion({
    required String driverId,
    required double earnings,
    required double distanceKm,
  });
}
