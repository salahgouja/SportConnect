import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

/// Ride Repository for Firestore operations
class RideRepository implements IRideRepository {
  final FirebaseFirestore _firestore;

  RideRepository(this._firestore);

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter<RideModel>(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (ride, _) => ride.toJson(),
      );

  CollectionReference<RideRequestModel> get _rideRequestsCollection =>
      _firestore
          .collection(AppConstants.rideRequestsCollection)
          .withConverter<RideRequestModel>(
            fromFirestore: (snap, _) =>
                RideRequestModel.fromJson({...snap.data()!, 'id': snap.id}),
            toFirestore: (request, _) => request.toJson(),
          );

  CollectionReference<RideBooking> get _rideBookingsCollection => _firestore
      .collection(AppConstants.bookingsCollection)
      .withConverter<RideBooking>(
        fromFirestore: (snap, _) =>
            RideBooking.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (booking, _) => booking.toJson(),
      );

  /// Create a new ride
  @override
  Future<String> createRide(RideModel ride) async {
    final docRef = _ridesCollection.doc();
    final rideWithId = ride.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(rideWithId);
    return docRef.id;
  }

  /// Get ride by ID
  @override
  Future<RideModel?> getRideById(String rideId) async {
    final doc = await _ridesCollection.doc(rideId).get();
    return doc.data();
  }

  /// Stream ride by ID (real-time updates)
  Stream<RideModel?> streamRideById(String rideId) {
    return _ridesCollection.doc(rideId).snapshots().map((doc) => doc.data());
  }

  /// Update ride
  @override
  Future<void> updateRide(RideModel ride) async {
    final json = ride.toJson()
      ..remove('id')
      ..remove('createdAt');
    json['updatedAt'] = DateTime.now();
    await _ridesCollection.doc(ride.id).update(json);
  }

  /// Update ride with map (helper method)
  Future<void> updateRideFields(
    String rideId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = DateTime.now();
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
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<RideModel>> getRideHistory(String userId) {
    return _ridesCollection
        .where('driverId', isEqualTo: userId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<String> createRideRequest(RideRequestModel request) async {
    final docRef = _rideRequestsCollection.doc();
    var requestWithId = request.copyWith(id: docRef.id);
    requestWithId = requestWithId.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(requestWithId);
    return docRef.id;
  }

  @override
  Future<void> acceptRideRequest(String requestId) async {
    await _rideRequestsCollection.doc(requestId).update({
      'status': RideRequestStatus.accepted.name,
      'respondedAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> rejectRideRequest(String requestId) async {
    await _rideRequestsCollection.doc(requestId).update({
      'status': RideRequestStatus.rejected.name,
      'respondedAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<RideRequestModel?> getRideRequest(String requestId) async {
    final doc = await _rideRequestsCollection.doc(requestId).get();
    return doc.data();
  }

  @override
  Future<void> updateRideRequest(RideRequestModel request) async {
    final json = request.toJson()
      ..remove('id')
      ..remove('createdAt');
    json['updatedAt'] = DateTime.now();
    await _rideRequestsCollection.doc(request.id).update(json);
  }

  @override
  Stream<List<RideRequestModel>> getRideRequests(String rideId) {
    return _rideRequestsCollection
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: RideRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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

    Query<RideModel> query = _ridesCollection
        .where('status', isEqualTo: 'active')
        .where('route.origin.latitude', isGreaterThan: originLat - latRange)
        .where('route.origin.latitude', isLessThan: originLat + latRange)
        .limit(100);

    final results = await query.get();

    final rides = results.docs.map((doc) => doc.data()).where((ride) {
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
    }).toList();

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
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== EXISTING METHODS ====================

  /// Get rides by driver
  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    final query = await _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Stream rides by driver (real-time)
  Stream<List<RideModel>> streamRidesByDriver(String driverId) {
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream rides where user is a passenger.
  ///
  /// Queries the bookings collection via [BookingRepository] to find
  /// rides the user is booked on, then fetches the ride documents.
  Stream<List<RideModel>> streamRidesAsPassenger(String userId) {
    return _rideBookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((bookingSnapshot) async {
          final rideIds = bookingSnapshot.docs
              .map((doc) => doc.data().rideId)
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
            rides.addAll(query.docs.map((doc) => doc.data()));
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
    final bookingSnapshot = await _rideBookingsCollection
        .where('passengerId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(100)
        .get();

    final rideIds = bookingSnapshot.docs
        .map((doc) => doc.data().rideId)
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
      rides.addAll(query.docs.map((doc) => doc.data()));
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
              .map((doc) => doc.data())
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
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
    await _rideBookingsCollection.doc(booking.id).set(booking);

    // Track the booking ID on the ride document (but don't touch capacity yet)
    await _ridesCollection.doc(rideId).update({
      'bookingIds': FieldValue.arrayUnion([booking.id]),
      'updatedAt': DateTime.now(),
    });
  }

  /// Updates booking status in the bookings collection and adjusts
  /// ride capacity when a booking is cancelled or rejected.
  ///
  /// Reads `seatsBooked` AND `previousStatus` BEFORE updating to avoid a
  /// TOCTOU race condition. Capacity is only freed when the booking was
  /// previously `accepted` (seats were actually reserved). Rejecting or
  /// cancelling a still-pending booking must NOT decrement capacity.
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    // Read booking data first (before any writes) to avoid TOCTOU race
    int seatsBooked = 1;
    BookingStatus? previousStatus;
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected ||
        newStatus == BookingStatus.accepted) {
      final bookingDoc = await _rideBookingsCollection.doc(bookingId).get();
      if (bookingDoc.exists) {
        seatsBooked = bookingDoc.data()?.seatsBooked ?? 1;
        previousStatus = bookingDoc.data()?.status;
      }
    }

    // Update the booking document
    await _rideBookingsCollection.doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': DateTime.now(),
    });

    // If accepted, reserve the seats on the ride
    if (newStatus == BookingStatus.accepted) {
      await _ridesCollection.doc(rideId).update({
        'capacity.booked': FieldValue.increment(seatsBooked),
        'updatedAt': DateTime.now(),
      });
    }

    // Free up seats ONLY if the booking was previously accepted (i.e. seats
    // were actually reserved). Rejecting a pending booking must not touch
    // capacity — seats were never reserved for it.
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected) {
      if (previousStatus == BookingStatus.accepted) {
        await _ridesCollection.doc(rideId).update({
          'bookingIds': FieldValue.arrayRemove([bookingId]),
          'capacity.booked': FieldValue.increment(-seatsBooked),
          'updatedAt': DateTime.now(),
        });
      } else {
        // Booking was pending/rejected — only remove from bookingIds, no capacity change
        await _ridesCollection.doc(rideId).update({
          'bookingIds': FieldValue.arrayRemove([bookingId]),
          'updatedAt': DateTime.now(),
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
      final reviewRef = _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);
      transaction.set(reviewRef, reviewData);

      // Read current ride stats
      final rideRef = _ridesCollection.doc(rideId);
      final rideSnap = await transaction.get(rideRef);
      if (!rideSnap.exists) return;

      final currentCount = (rideSnap.data()!.reviewCount.toInt());
      final currentAvg = (rideSnap.data()!.averageRating).toDouble();

      // Incremental average: newAvg = (oldAvg * count + newRating) / (count + 1)
      final newCount = currentCount + 1;
      final newAvg = ((currentAvg * currentCount) + newRating) / newCount;

      transaction.update(rideRef, {
        'reviewCount': newCount,
        'averageRating': double.parse(newAvg.toStringAsFixed(2)),
        'updatedAt': DateTime.now(),
      });
    });
  }

  /// Start ride
  @override
  Future<void> startRide(String rideId) async {
    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.inProgress.name,
      'updatedAt': DateTime.now(),
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
      'schedule.arrivalTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  /// Writes the driver's current GPS coordinates to the ride document.
  ///
  /// Failures are expected to be swallowed by the caller \u2014 a missed
  /// location ping must not interrupt the navigation flow.
  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude,
  ) async {
    await _ridesCollection.doc(rideId).update({
      'liveLocation': GeoPoint(latitude, longitude),
      'lastLocationUpdate': DateTime.now(),
    });
  }

  /// Streams the driver's live GPS location from the ride document.
  @override
  Stream<({double latitude, double longitude})?> streamLiveLocation(
    String rideId,
  ) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) return null;
      final geoPoint = data['liveLocation'] as GeoPoint?;
      if (geoPoint == null) return null;
      return (latitude: geoPoint.latitude, longitude: geoPoint.longitude);
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

  /// Stream rides linked to a specific event by eventId.
  Stream<List<RideModel>> streamRidesByEventId(String eventId) {
    return _ridesCollection
        .where('eventId', isEqualTo: eventId)
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
