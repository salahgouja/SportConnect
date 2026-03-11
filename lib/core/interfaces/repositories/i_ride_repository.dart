import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

/// Ride operations repository interface
abstract class IRideRepository {
  // Ride CRUD
  Future<String> createRide(RideModel ride);
  Future<RideModel?> getRideById(String rideId);
  Stream<RideModel?> streamRideById(String rideId);
  Future<void> updateRide(RideModel ride);
  Future<void> updateRideFields(String rideId, Map<String, dynamic> updates);
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
  Future<List<RideModel>> getRidesByDriver(String driverId);
  Stream<List<RideModel>> streamRidesByDriver(String driverId);
  Stream<List<RideModel>> streamRidesAsPassenger(String userId);
  Stream<List<RideModel>> streamNearbyRides({
    required double latitude,
    required double longitude,
    double radiusKm = 20.0,
  });
  Stream<List<RideModel>> streamActiveRides();

  // Ride Requests
  Future<String> createRideRequest(RideRequestModel request);
  Future<RideRequestModel?> getRideRequest(String requestId);
  Future<void> updateRideRequest(RideRequestModel request);
  Future<void> acceptRideRequest(String requestId);
  Future<void> rejectRideRequest(String requestId);
  Stream<List<RideRequestModel>> getRideRequests(String rideId);

  // Bookings
  Future<void> bookRide({required String rideId, required RideBooking booking});
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  });
  Future<void> cancelBooking({
    required String rideId,
    required String bookingId,
  });

  // Ride Status
  Future<void> startRide(String rideId);
  Future<void> completeRide(String rideId);
  Future<void> cancelRide(String rideId, String reason);
  Future<void> updateRidePhase(String rideId, String phase);
  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude,
  );

  /// Persists the ordered list of passenger pickup IDs to Firestore.
  Future<void> updatePickupOrder(String rideId, List<String> passengerIds);

  /// Mark a passenger as picked up in Firestore.
  Future<void> markPassengerPickedUp(String rideId, String passengerId);

  /// Mark a passenger as no-show and cancel their booking.
  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  });

  /// Add a mid-ride stop to the ride's waypoints.
  Future<void> addMidRideStop(String rideId, Map<String, dynamic> waypoint);

  /// Remove a mid-ride stop from the ride's waypoints by index.
  Future<void> removeMidRideStop(String rideId, int waypointIndex);

  /// Record the actual distance driven (for fare adjustment).
  Future<void> recordActualDistance(String rideId, double distanceKm);

  /// Create a return ride offer from a completed ride.
  Future<String> createReturnRide(String originalRideId);

  /// Streams the driver's live GPS location for a ride.
  Stream<({double latitude, double longitude})?> streamLiveLocation(
    String rideId,
  );

  /// Streams the driver's current ride phase (pickingUp, enRoute, arriving, completed).
  Stream<String?> streamRidePhase(String rideId);

  /// Streams rides linked to a specific event by eventId.
  Stream<List<RideModel>> streamRidesByEventId(String eventId);
}
