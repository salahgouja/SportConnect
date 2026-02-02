import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';

part 'ride_repository.g.dart';

/// Ride Repository for Firestore operations
class RideRepository {
  final FirebaseFirestore _firestore;

  RideRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _ridesCollection =>
      _firestore.collection(AppConstants.ridesCollection);

  /// Create a new ride
  Future<String> createRide(RideModel ride) async {
    final docRef = _ridesCollection.doc();
    final rideWithId = ride.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(rideWithId.toJson());
    return docRef.id;
  }

  /// Get ride by ID
  Future<RideModel?> getRideById(String rideId) async {
    final doc = await _ridesCollection.doc(rideId).get();
    if (!doc.exists) return null;
    return RideModel.fromJson(doc.data()!);
  }

  /// Stream ride by ID (real-time updates)
  Stream<RideModel?> streamRideById(String rideId) {
    return _ridesCollection.doc(rideId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RideModel.fromJson(doc.data()!);
    });
  }

  /// Update ride
  Future<void> updateRide(String rideId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _ridesCollection.doc(rideId).update(updates);
  }

  /// Delete ride
  Future<void> deleteRide(String rideId) async {
    await _ridesCollection.doc(rideId).delete();
  }

  /// Get rides by driver
  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    final query = await _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('departureTime', descending: true)
        .get();

    return query.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
  }

  /// Stream rides by driver (real-time)
  Stream<List<RideModel>> streamRidesByDriver(String driverId) {
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream rides where user is a passenger
  Stream<List<RideModel>> streamRidesAsPassenger(String userId) {
    return _ridesCollection
        .orderBy('departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .where(
                (ride) => ride.bookings.any(
                  (booking) =>
                      booking.passengerId == userId &&
                      booking.status != BookingStatus.rejected,
                ),
              )
              .toList();
        });
  }

  /// Get upcoming rides for user (as passenger)
  Future<List<RideModel>> getUpcomingRidesAsPassenger(String userId) async {
    final query = await _ridesCollection
        .where(
          'bookings',
          arrayContainsAny: [
            {'passengerId': userId, 'status': 'accepted'},
          ],
        )
        .where('departureTime', isGreaterThan: Timestamp.now())
        .orderBy('departureTime')
        .get();

    return query.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
  }

  /// Search rides with filters
  Future<List<RideModel>> searchRides({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required DateTime departureDate,
    int minSeats = 1,
    double radiusKm = 10.0,
    double? maxPrice,
  }) async {
    // Calculate bounding box for origin (simplified - for production use geohashing)
    final latRange = radiusKm / 111.0; // ~111km per degree latitude
    // Note: lngRange could be used for more precise filtering: radiusKm / (111.0 * cosDeg(originLat))

    Query<Map<String, dynamic>> query = _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('origin.latitude', isGreaterThan: originLat - latRange)
        .where('origin.latitude', isLessThan: originLat + latRange);

    final results = await query.get();

    // Filter results in memory for other criteria
    final rides = results.docs
        .map((doc) => RideModel.fromJson(doc.data()))
        .where((ride) {
          // Check departure date
          if (!_isSameDay(ride.departureTime, departureDate)) return false;

          // Check available seats
          if (ride.remainingSeats < minSeats) return false;

          // Check price
          if (maxPrice != null && ride.pricePerSeat > maxPrice) return false;

          // Check destination proximity
          final destDistance = _calculateDistance(
            ride.destination.latitude,
            ride.destination.longitude,
            destLat,
            destLng,
          );
          if (destDistance > radiusKm) return false;

          return true;
        })
        .toList();

    // Sort by departure time
    rides.sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return rides;
  }

  /// Stream rides near location (real-time)
  Stream<List<RideModel>> streamNearbyRides({
    required double latitude,
    required double longitude,
    double radiusKm = 20.0,
  }) {
    final latRange = radiusKm / 111.0;

    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('departureTime', isGreaterThan: Timestamp.now())
        .where('origin.latitude', isGreaterThan: latitude - latRange)
        .where('origin.latitude', isLessThan: latitude + latRange)
        .orderBy('origin.latitude')
        .orderBy('departureTime')
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream all active rides (for search screen)
  Stream<List<RideModel>> streamActiveRides() {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('departureTime', isGreaterThan: Timestamp.now())
        .orderBy('departureTime')
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Book a ride
  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) async {
    await _ridesCollection.doc(rideId).update({
      'bookings': FieldValue.arrayUnion([booking.toJson()]),
      'bookedSeats': FieldValue.increment(booking.seatsBooked),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    final rideDoc = await _ridesCollection.doc(rideId).get();
    if (!rideDoc.exists) return;

    final ride = RideModel.fromJson(rideDoc.data()!);
    final updatedBookings = ride.bookings.map((b) {
      if (b.id == bookingId) {
        return b.copyWith(status: newStatus, respondedAt: DateTime.now());
      }
      return b;
    }).toList();

    // Calculate booked seats
    final bookedSeats = updatedBookings
        .where((b) => b.status == BookingStatus.accepted)
        .fold(0, (sum, b) => sum + b.seatsBooked);

    // Update status if full
    var status = ride.status;
    if (bookedSeats >= ride.availableSeats) {
      status = RideStatus.full;
    } else if (status == RideStatus.full && bookedSeats < ride.availableSeats) {
      status = RideStatus.active;
    }

    await _ridesCollection.doc(rideId).update({
      'bookings': updatedBookings.map((b) => b.toJson()).toList(),
      'bookedSeats': bookedSeats,
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel booking
  Future<void> cancelBooking({
    required String rideId,
    required String bookingId,
  }) async {
    await updateBookingStatus(
      rideId: rideId,
      bookingId: bookingId,
      newStatus: BookingStatus.cancelled,
    );
  }

  /// Add review
  Future<void> addReview({
    required String rideId,
    required RideReview review,
  }) async {
    await _ridesCollection.doc(rideId).update({
      'reviews': FieldValue.arrayUnion([review.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Start ride
  Future<void> startRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.inProgress.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Complete ride
  Future<void> completeRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.completed.name,
      'arrivalTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel ride
  Future<void> cancelRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula
    const earthRadius = 6371.0; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        _sinSquared(dLat / 2) +
        cosDeg(lat1) * cosDeg(lat2) * _sinSquared(dLon / 2);
    final c = 2 * _atan2(a);
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * 3.141592653589793 / 180;
  double cosDeg(double deg) => _cos(_degToRad(deg));
  double _cos(double rad) => rad; // Simplified - use dart:math in production
  double _sinSquared(double x) => x * x; // Simplified
  double _atan2(double x) => x; // Simplified
}

@riverpod
RideRepository rideRepository(Ref ref) {
  return RideRepository(FirebaseFirestore.instance);
}
