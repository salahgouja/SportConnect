import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

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
  @override
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
  @override
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
  Future<String> createRideRequest(String rideId, RideBooking booking) async {
    // Unified flow: creating a "request" simply creates a pending booking.
    final docRef = _rideBookingsCollection.doc(
      booking.id.isNotEmpty ? booking.id : null,
    );
    final bookingWithId = booking.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
    );
    await docRef.set(bookingWithId);
    return docRef.id;
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
    // R-2: A negative maxPrice silently hides all rides.
    if (maxPrice != null && maxPrice < 0) {
      throw ArgumentError('maxPrice must be >= 0 (got $maxPrice).');
    }

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
  @override
  Future<List<RideModel>> getRidesByDriver(String driverId) async {
    final query = await _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('schedule.departureTime', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Check if a vehicle is associated with any non-terminal ride.
  @override
  Future<bool> hasActiveRidesForVehicle(String vehicleId) async {
    final snapshot = await _ridesCollection
        .where('vehicleId', isEqualTo: vehicleId)
        .where('status', whereIn: ['draft', 'active', 'full', 'inProgress'])
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Stream rides by driver (real-time)
  @override
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
  @override
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
  @override
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
  @override
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
  @override
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
  @override
  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    // Read booking data first (before any writes) to avoid TOCTOU race
    int seatsBooked = 1;
    BookingStatus? previousStatus;
    Map<String, dynamic>? pickupLocationMap;
    if (newStatus == BookingStatus.cancelled ||
        newStatus == BookingStatus.rejected ||
        newStatus == BookingStatus.accepted) {
      final bookingDoc = await _rideBookingsCollection.doc(bookingId).get();
      if (bookingDoc.exists) {
        seatsBooked = bookingDoc.data()?.seatsBooked ?? 1;
        previousStatus = bookingDoc.data()?.status;
        // Capture pickup location for waypoint creation on accept
        if (newStatus == BookingStatus.accepted &&
            bookingDoc.data()?.pickupLocation != null) {
          final pickup = bookingDoc.data()!.pickupLocation!;
          pickupLocationMap = pickup.toJson();
        }
      }
    }

    // Generate a 4-digit OTP when accepting — shown to passenger, entered by driver.
    // Use Random.secure() to prevent OTP prediction from a time-seeded RNG.
    final pickupOtp = newStatus == BookingStatus.accepted
        ? (1000 + math.Random.secure().nextInt(9000)).toString()
        : null;

    // Update the booking document
    await _rideBookingsCollection.doc(bookingId).update({
      'status': newStatus.name,
      'respondedAt': DateTime.now(),
      'pickupOtp': ?pickupOtp,
    });

    // If accepted, reserve the seats on the ride and add pickup waypoint.
    // R-6/R-7: Use a transaction so capacity check + increment and waypoint
    // order assignment are atomic — preventing overselling and duplicate order
    // values when two bookings are accepted concurrently.
    if (newStatus == BookingStatus.accepted) {
      await _firestore.runTransaction((txn) async {
        final rideRef = _firestore
            .collection(AppConstants.ridesCollection)
            .doc(rideId);
        final rideSnap = await txn.get(rideRef);
        if (!rideSnap.exists) throw StateError('Ride $rideId not found.');

        final data = rideSnap.data()!;
        final total = (data['capacity']?['total'] as int?) ?? 0;
        final booked = (data['capacity']?['booked'] as int?) ?? 0;
        final available = total - booked;

        // R-6: Reject if not enough seats available at transaction time.
        if (available < seatsBooked) {
          throw StateError(
            'Not enough seats: $available available, $seatsBooked requested.',
          );
        }

        final updates = <String, dynamic>{
          'capacity.booked': FieldValue.increment(seatsBooked),
          'updatedAt': DateTime.now(),
        };

        // R-7: Derive waypoint order inside the transaction using the
        // snapshot's current count — eliminates the duplicate-order race.
        if (pickupLocationMap != null) {
          final waypointsList = (data['route']?['waypoints'] as List?) ?? [];
          final nextOrder = waypointsList.length;
          updates['route.waypoints'] = FieldValue.arrayUnion([
            {'location': pickupLocationMap, 'order': nextOrder},
          ]);
        }

        txn.update(rideRef, updates);
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
  @override
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
  ///
  /// Uses a transaction to atomically validate that at least one accepted
  /// booking exists, set the ride status to inProgress, record the actual
  /// departure time, and set the initial ride phase.
  @override
  Future<void> startRide(String rideId) async {
    await _firestore.runTransaction((transaction) async {
      final rideRef = _ridesCollection.doc(rideId);
      final rideSnap = await transaction.get(rideRef);
      if (!rideSnap.exists) throw ArgumentError('Ride not found');

      final driverId = rideSnap.data()!.driverId;

      // Validate: at least one accepted booking
      // Include driverId filter to satisfy Firestore security rules.
      final bookingsSnap = await _rideBookingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: BookingStatus.accepted.name)
          .limit(1)
          .get();
      if (bookingsSnap.docs.isEmpty) {
        throw StateError('Cannot start ride without accepted bookings');
      }

      transaction.update(rideRef, {
        'status': RideStatus.inProgress.name,
        'ridePhase': 'pickingUp',
        'schedule.actualDepartureTime': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
    });
  }

  /// Complete ride
  ///
  /// Writes `arrivalTime` inside the `schedule` sub-object to match the
  /// `RideSchedule` model structure (not at the document root level).
  @override
  Future<void> completeRide(String rideId) async {
    // R-4: Warn if any accepted passenger was never picked up (OTP not confirmed).
    final rideDoc = await _firestore
        .collection(AppConstants.ridesCollection)
        .doc(rideId)
        .get();
    if (rideDoc.exists) {
      final pickedUp = List<String>.from(
        rideDoc.data()?['pickedUpPassengers'] as List? ?? [],
      );
      final acceptedBookings = await _rideBookingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('status', isEqualTo: BookingStatus.accepted.name)
          .get();
      final notPickedUp = acceptedBookings.docs
          .map((d) => d.data().passengerId)
          .where((pid) => !pickedUp.contains(pid))
          .toList();
      if (notPickedUp.isNotEmpty) {
        throw StateError(
          'Cannot complete ride: ${notPickedUp.length} accepted passenger(s) '
          'have not been picked up (OTP not confirmed).',
        );
      }
    }

    await _ridesCollection.doc(rideId).update({
      'status': RideStatus.completed.name,
      'ridePhase': 'completed',
      'schedule.arrivalTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    });
  }

  /// Updates the driver's ride phase (pickingUp, enRoute, arriving, completed).
  /// This is persisted so passengers can see granular progress.
  @override
  Future<void> updateRidePhase(String rideId, String phase) async {
    await _ridesCollection.doc(rideId).update({
      'ridePhase': phase,
      'updatedAt': DateTime.now(),
    });
  }

  /// Streams the driver's current ride phase from the ride document.
  @override
  Stream<String?> streamRidePhase(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((
      snapshot,
    ) {
      return snapshot.data()?['ridePhase'] as String?;
    });
  }

  /// Writes the driver's current GPS coordinates to Firebase Realtime Database.
  ///
  /// RTDB is used instead of Firestore for live location because:
  /// - ~10x cheaper (charged per GB transferred, not per write operation)
  /// - ~50-150ms latency vs Firestore's ~300-1000ms for real-time
  /// - Designed for high-frequency data; no per-write billing pressure
  @override
  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude, {
    double heading = 0,
  }) async {
    await FirebaseDatabase.instance.ref('liveLocations/$rideId').update({
      'lat': latitude,
      'lng': longitude,
      'heading': heading,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Streams the driver's live GPS location from Firebase Realtime Database.
  @override
  Stream<({double latitude, double longitude})?> streamLiveLocation(
    String rideId,
  ) {
    return FirebaseDatabase.instance.ref('liveLocations/$rideId').onValue.map((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return null;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return (latitude: lat, longitude: lng);
    });
  }

  // ==================== REAL-TIME EXTRA FIELDS ====================

  /// Streams the list of passenger IDs the driver has confirmed as picked up.
  @override
  Stream<List<String>> streamPickedUpPassengers(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map(
          (snap) => List<String>.from(
            snap.data()?['pickedUpPassengers'] as List? ?? [],
          ),
        );
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
  @override
  Stream<List<RideModel>> streamRidesByEventId(String eventId) {
    return _ridesCollection
        .where('eventId', isEqualTo: eventId)
        .orderBy('schedule.departureTime')
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ==================== 7A: PICKUP ORDER ====================

  @override
  Future<void> updatePickupOrder(
    String rideId,
    List<String> passengerIds,
  ) async {
    await _ridesCollection.doc(rideId).update({
      'pickupOrder': passengerIds,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> markPassengerPickedUp(String rideId, String passengerId) async {
    await _ridesCollection.doc(rideId).update({
      'pickedUpPassengers': FieldValue.arrayUnion([passengerId]),
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7B: NO-SHOW ====================

  @override
  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final bookingRef = _rideBookingsCollection.doc(bookingId);
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) return;

      final seatsBooked = bookingSnap.data()?.seatsBooked ?? 1;

      // Cancel the booking
      transaction.update(bookingRef, {
        'status': BookingStatus.cancelled.name,
        'note': 'No-show',
        'respondedAt': DateTime.now(),
      });

      // Record no-show on the ride and free up seats
      final rideRef = _ridesCollection.doc(rideId);
      transaction.update(rideRef, {
        'noShowPassengers': FieldValue.arrayUnion([passengerId]),
        'capacity.booked': FieldValue.increment(-seatsBooked),
        'updatedAt': DateTime.now(),
      });
    });
  }

  // ==================== 7E: MID-RIDE STOPS ====================

  @override
  Future<void> addMidRideStop(
    String rideId,
    Map<String, dynamic> waypoint,
  ) async {
    final ride = await getRideById(rideId);
    if (ride == null) return;

    final waypoints = List<Map<String, dynamic>>.from(
      ride.route.waypoints.map((w) => w.toJson()),
    );
    waypoints.add(waypoint);

    for (int i = 0; i < waypoints.length; i++) {
      waypoints[i]['order'] = i;
    }

    await _ridesCollection.doc(rideId).update({
      'route.waypoints': waypoints,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> removeMidRideStop(String rideId, int waypointIndex) async {
    final ride = await getRideById(rideId);
    if (ride == null) return;
    final waypoints = List<Map<String, dynamic>>.from(
      ride.route.waypoints.map((w) => w.toJson()),
    );
    if (waypointIndex < 0 || waypointIndex >= waypoints.length) return;
    waypoints.removeAt(waypointIndex);

    for (int i = 0; i < waypoints.length; i++) {
      waypoints[i]['order'] = i;
    }

    await _ridesCollection.doc(rideId).update({
      'route.waypoints': waypoints,
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7F: FARE ADJUSTMENT ====================

  @override
  Future<void> recordActualDistance(String rideId, double distanceKm) async {
    await _ridesCollection.doc(rideId).update({
      'actualDistanceKm': distanceKm,
      'updatedAt': DateTime.now(),
    });
  }

  // ==================== 7H: RETURN RIDE ====================

  @override
  Future<String> createReturnRide(String originalRideId) async {
    final original = await getRideById(originalRideId);
    if (original == null) throw ArgumentError('Original ride not found');

    // Swap origin and destination
    final returnRoute = original.route.copyWith(
      origin: original.route.destination,
      destination: original.route.origin,
      waypoints: const [], // Fresh route, no leftover waypoints
    );

    final returnSchedule = original.schedule.copyWith(
      departureTime: DateTime.now().add(const Duration(hours: 1)),
      arrivalTime: null,
      actualDepartureTime: null,
    );

    final returnRide = original.copyWith(
      id: '', // Will be auto-generated
      route: returnRoute,
      schedule: returnSchedule,
      status: RideStatus.active,
      bookingIds: const [],
      bookings: const [],
      reviewCount: 0,
      averageRating: 0.0,
      notes: 'Return trip from "${original.destination.address}"',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return createRide(returnRide);
  }
}
