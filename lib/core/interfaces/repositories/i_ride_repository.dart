import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

/// Ride operations repository interface
abstract class IRideRepository {
  // Ride CRUD
  Future<String> createRide(RideModel ride);
  Future<RideModel?> getRideById(String rideId);
  Future<void> updateRide(RideModel ride);
  Future<void> deleteRide(String rideId);

  // Ride Discovery
  Future<List<RideModel>> searchRides({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    DateTime? date,
    int? minSeats,
    double? maxPrice,
  });

  Stream<List<RideModel>> getActiveRides(String userId);
  Stream<List<RideModel>> getRideHistory(String userId);

  // Ride Requests
  Future<String> createRideRequest(RideRequestModel request);
  Future<RideRequestModel?> getRideRequest(String requestId);
  Future<void> updateRideRequest(RideRequestModel request);
  Future<void> acceptRideRequest(String requestId);
  Future<void> rejectRideRequest(String requestId);
  Stream<List<RideRequestModel>> getRideRequests(String rideId);

  // Ride Status
  Future<void> startRide(String rideId);
  Future<void> completeRide(String rideId);
  Future<void> cancelRide(String rideId, String reason);
}
