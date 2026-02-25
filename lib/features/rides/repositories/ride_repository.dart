import 'dart:math' as math;

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
    final rideWithId = ride.copyWith(id: docRef.id);
    final json = rideWithId.toJson();
    // Use server timestamps so all clients share the same clock
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(json);
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
    final json = ride.toJson()
      ..remove('id')
      ..remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    await _ridesCollection.doc(ride.id).update(json);
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
    final requestWithId = request.copyWith(id: docRef.id);
    final json = requestWithId.toJson();
    // Use server timestamps for consistent chronological ordering
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.set(json);
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
    final json = request.toJson()
      ..remove('id')
      ..remove('createdAt');
    json['updatedAt'] = FieldValue.serverTimestamp();
    await _rideRequestsCollection.doc(request.id).update(json);
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

  /// Stream rides near location (real-time).
  ///
  /// Firestore only allows a range/inequality filter on a **single** field per
  /// query. We apply the departure-time inequality in Firestore (the most
  /// selective filter) and then post-filter by latitude/longitude in memory
  /// using the Haversine formula so we don't need a composite index.
  Stream<List<RideModel>> streamNearbyRides({
    required double latitude,
    required double longitude,
    double radiusKm = 20.0,
  }) {
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('schedule.departureTime', isGreaterThan: Timestamp.now())
        .orderBy('schedule.departureTime')
        .limit(100) // Fetch a larger set so post-filtering still returns enough
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RideModel.fromJson(doc.data()))
              .where((ride) {
                final dist = _calculateDistance(
                  ride.route.origin.latitude,
                  ride.route.origin.longitude,
                  latitude,
                  longitude,
                );
                return dist <= radiusKm;
              })
              .take(50)
              .toList();
        });
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
  /// collection and recording the booking ID on the ride.
  ///
  /// **Capacity is NOT incremented here.** Seats are only reserved when
  /// the driver accepts the booking (via [updateBookingStatus] with
  /// [BookingStatus.accepted]). This prevents over-restricting seat
  /// availability for rides that use manual acceptance.
  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) async {
    // Store the booking in the bookings collection
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toJson());

    // Track the booking ID on the ride document (but don't touch capacity yet)
    await _ridesCollection.doc(rideId).update({
      'bookingIds': FieldValue.arrayUnion([booking.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates booking status in the bookings collection and adjusts
  /// ride capacity when a booking is cancelled or rejected.
  ///
  /// Reads `seatsBooked` BEFORE updating the status to avoid a
  /// TOCTOU race condition where the booking document is already
  /// overwritten by the time we read it back.
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    // Read seatsBooked first (before any writes) to avoid TOCTOU race
    int seatsBooked = 1;
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected ||
        newStatus == BookingStatus.accepted) {
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (bookingDoc.exists) {
        seatsBooked =
            (bookingDoc.data()?['seatsBooked'] as num?)?.toInt() ?? 1;
      }
    }

    // Now update the booking document
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // If accepted, reserve the seats on the ride
    if (newStatus == BookingStatus.accepted) {
      await _ridesCollection.doc(rideId).update({
        'capacity.booked': FieldValue.increment(seatsBooked),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // If cancelled/rejected, free up the seats using the value read above
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected) {
      await _ridesCollection.doc(rideId).update({
        'bookingIds': FieldValue.arrayRemove([bookingId]),
        'capacity.booked': FieldValue.increment(-seatsBooked),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
  /// ride's aggregated review count and recalculates the average rating
  /// atomically inside a Firestore transaction.
  Future<void> addReview({
    required String rideId,
    required Map<String, dynamic> reviewData,
  }) async {
    final reviewId = reviewData['id'] as String? ?? '';
    final newRating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;

    await _firestore.runTransaction((transaction) async {
      // Store the review document
      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      transaction.set(reviewRef, reviewData);

      // Read current ride stats
      final rideRef = _ridesCollection.doc(rideId);
      final rideSnap = await transaction.get(rideRef);
      if (!rideSnap.exists) return;

      final currentCount =
          (rideSnap.data()?['reviewCount'] as num?)?.toInt() ?? 0;
      final currentAvg =
          (rideSnap.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;

      // Incremental average: newAvg = (oldAvg * count + newRating) / (count + 1)
      final newCount = currentCount + 1;
      final newAvg =
          ((currentAvg * currentCount) + newRating) / newCount;

      transaction.update(rideRef, {
        'reviewCount': newCount,
        'averageRating': double.parse(newAvg.toStringAsFixed(2)),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
  ///
  /// Writes `arrivalTime` inside the `schedule` sub-object to match the
  /// `RideSchedule` model structure (not at the document root level).
  @override
  Future<void> completeRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.completed.name,
      'schedule.arrivalTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Helper methods
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _degToRad(double deg) => deg * math.pi / 180;

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
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
}

@Riverpod(keepAlive: true)
RideRepository rideRepository(Ref ref) {
  return RideRepository(FirebaseFirestore.instance);
}
