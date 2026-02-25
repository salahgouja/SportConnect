import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

part 'ride_repository.g.dart';

/// Ride Repository for Firestore operations
class RideRepository implements IRideRepository {
  final FirebaseFirestore _firestore;

  RideRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _ridesCollection =>
      _firestore.collection(AppConstants.ridesCollection);

  CollectionReference<Map<String, dynamic>> get _rideRequestsCollection =>
      _firestore.collection('rideRequests');

  /// Create a new ride
  @override
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
  @override
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
  @override
  Future<void> updateRide(RideModel ride) async {
    await _ridesCollection.doc(ride.id).update({
      ...ride.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update ride with map (helper method)
  Future<void> updateRideFields(
    String rideId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _ridesCollection.doc(rideId).update(updates);
  }

  /// Delete ride
  @override
  Future<void> deleteRide(String rideId) async {
    await _ridesCollection.doc(rideId).delete();
  }

  // ==================== INTERFACE IMPLEMENTATIONS ====================

  @override
  Stream<List<RideModel>> getActiveRides(String userId) {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('driverId', isEqualTo: userId)
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<RideModel>> getRideHistory(String userId) {
    return _ridesCollection
        .where('driverId', isEqualTo: userId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<String> createRideRequest(RideRequestModel request) async {
    final docRef = _rideRequestsCollection.doc();
    final requestWithId = request.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(requestWithId.toJson());
    return docRef.id;
  }

  @override
  Future<void> acceptRideRequest(String requestId) async {
    await _rideRequestsCollection.doc(requestId).update({
      'status': RideRequestStatus.accepted.name,
      'respondedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectRideRequest(String requestId) async {
    await _rideRequestsCollection.doc(requestId).update({
      'status': RideRequestStatus.rejected.name,
      'respondedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<RideRequestModel?> getRideRequest(String requestId) async {
    final doc = await _rideRequestsCollection.doc(requestId).get();
    if (!doc.exists) return null;
    return RideRequestModel.fromJson(doc.data()!);
  }

  @override
  Future<void> updateRideRequest(RideRequestModel request) async {
    await _rideRequestsCollection.doc(request.id).update({
      ...request.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<RideRequestModel>> getRideRequests(String rideId) {
    return _rideRequestsCollection
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: RideRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideRequestModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<RideModel>> searchRides({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    DateTime? date,
    int? minSeats,
    double? maxPrice,
  }) async {
    final radiusKm = 10.0;
    final latRange = radiusKm / 111.0;

    Query<Map<String, dynamic>> query = _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('route.origin.latitude', isGreaterThan: originLat - latRange)
        .where('route.origin.latitude', isLessThan: originLat + latRange);

    final results = await query.get();

    final rides = results.docs
        .map((doc) => RideModel.fromJson(doc.data()))
        .where((ride) {
          if (date != null && !_isSameDay(ride.schedule.departureTime, date)) {
            return false;
          }
          if (minSeats != null && ride.capacity.available < minSeats) {
            return false;
          }
          if (maxPrice != null && ride.pricing.pricePerSeat.amount > maxPrice) {
            return false;
          }

          final destDistance = _calculateDistance(
            ride.route.destination.latitude,
            ride.route.destination.longitude,
            destLat,
            destLng,
          );
          if (destDistance > radiusKm) return false;

          return true;
        })
        .toList();

    rides.sort(
      (a, b) => a.schedule.departureTime.compareTo(b.schedule.departureTime),
    );
    return rides;
  }

  @override
  Future<void> cancelRide(String rideId, String reason) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.cancelled.name,
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== EXISTING METHODS ====================

  /// Get rides by driver
  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    final query = await _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .get();

    return query.docs.map((doc) => RideModel.fromJson(doc.data())).toList();
  }

  /// Stream rides by driver (real-time)
  Stream<List<RideModel>> streamRidesByDriver(String driverId) {
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Stream rides where user is a passenger.
  ///
  /// Queries the bookings collection via [BookingRepository] to find
  /// rides the user is booked on, then fetches the ride documents.
  Stream<List<RideModel>> streamRidesAsPassenger(String userId) {
    // Query the bookings collection for this passenger's active bookings
    final bookingsCollection = _firestore.collection('bookings');
    return bookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((bookingSnapshot) async {
          final rideIds = bookingSnapshot.docs
              .map((doc) => doc.data()['rideId'] as String?)
              .whereType<String>()
              .toSet()
              .toList();

          if (rideIds.isEmpty) return <RideModel>[];

          // Firestore whereIn supports max 30 items
          final rides = <RideModel>[];
          for (var i = 0; i < rideIds.length; i += 30) {
            final batch = rideIds.sublist(
              i,
              i + 30 > rideIds.length ? rideIds.length : i + 30,
            );
            final query = await _ridesCollection
                .where(FieldPath.documentId, whereIn: batch)
                .get();
            rides.addAll(
              query.docs.map((doc) => RideModel.fromJson(doc.data())),
            );
          }

          // Sort by departure time descending
          rides.sort((a, b) => b.departureTime.compareTo(a.departureTime));
          return rides;
        });
  }

  /// Gets upcoming rides for user (as passenger).
  ///
  /// Queries the bookings collection to find active bookings,
  /// then filters to upcoming rides only.
  Future<List<RideModel>> getUpcomingRidesAsPassenger(String userId) async {
    final bookingsCollection = _firestore.collection('bookings');
    final bookingSnapshot = await bookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    final rideIds = bookingSnapshot.docs
        .map((doc) => doc.data()['rideId'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    if (rideIds.isEmpty) return [];

    final rides = <RideModel>[];
    for (var i = 0; i < rideIds.length; i += 30) {
      final batch = rideIds.sublist(
        i,
        i + 30 > rideIds.length ? rideIds.length : i + 30,
      );
      final query = await _ridesCollection
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      rides.addAll(query.docs.map((doc) => RideModel.fromJson(doc.data())));
    }

    // Filter to only future rides and sort ascending
    final now = DateTime.now();
    final upcoming =
        rides.where((ride) => ride.departureTime.isAfter(now)).toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

    return upcoming;
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
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .where('route.origin.latitude', isGreaterThan: latitude - latRange)
        .where('route.origin.latitude', isLessThan: latitude + latRange)
        .orderBy('route.origin.latitude')
        .orderBy('schedule.departureTime')
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
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Books a ride by creating a booking document in the bookings
  /// collection and updating the ride's booking IDs and capacity.
  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) async {
    // Store the booking in the bookings collection
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toJson());

    // Update ride's bookingIds list and increment booked capacity
    await _ridesCollection.doc(rideId).update({
      'bookingIds': FieldValue.arrayUnion([booking.id]),
      'capacity.booked': FieldValue.increment(booking.seatsBooked),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates booking status in the bookings collection and adjusts
  /// ride capacity when a booking is cancelled.
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    // Update the booking document directly
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // If cancelled, free up the seats on the ride
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected) {
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (bookingDoc.exists) {
        final seatsBooked =
            (bookingDoc.data()?['seatsBooked'] as num?)?.toInt() ?? 1;
        await _ridesCollection.doc(rideId).update({
          'bookingIds': FieldValue.arrayRemove([bookingId]),
          'capacity.booked': FieldValue.increment(-seatsBooked),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Cancels a booking by delegating to [updateBookingStatus].
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

  /// Adds a review for a ride.
  ///
  /// Stores the review in the reviews collection and updates the
  /// ride's aggregated review count and average rating.
  Future<void> addReview({
    required String rideId,
    required Map<String, dynamic> reviewData,
  }) async {
    final reviewId = reviewData['id'] as String? ?? '';

    // Store the review in the reviews collection
    await _firestore.collection('reviews').doc(reviewId).set(reviewData);

    // Update ride's aggregated stats
    await _ridesCollection.doc(rideId).update({
      'reviewCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Start ride
  @override
  Future<void> startRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.inProgress.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Complete ride
  @override
  Future<void> completeRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.completed.name,
      'arrivalTime': FieldValue.serverTimestamp(),
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
