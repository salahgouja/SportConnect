import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_driver_stats_repository.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'driver_stats_repository.g.dart';

/// Driver Stats Repository
class DriverStatsRepository implements IDriverStatsRepository {
  final FirebaseFirestore _firestore;

  DriverStatsRepository(this._firestore);

  CollectionReference<DriverStats> get _driverStatsCollection => _firestore
      .collection(AppConstants.driverStatsCollection)
      .withConverter<DriverStats>(
        fromFirestore: (snap, _) => DriverStats.fromJson(snap.data()!),
        toFirestore: (stats, _) => stats.toJson(),
      );

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter<RideModel>(
        fromFirestore: (snap, _) =>
            RideModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (ride, _) => ride.toJson(),
      );

  CollectionReference<EarningsTransaction> get _transactionsCollection =>
      _firestore
          .collection(AppConstants.transactionsCollection)
          .withConverter<EarningsTransaction>(
            fromFirestore: (snap, _) =>
                EarningsTransaction.fromJson({...snap.data()!, 'id': snap.id}),
            toFirestore: (tx, _) => tx.toJson(),
          );

  CollectionReference<RideBooking> get _rideBookingsCollection => _firestore
      .collection(AppConstants.bookingsCollection)
      .withConverter<RideBooking>(
        fromFirestore: (snap, _) =>
            RideBooking.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (req, _) => req.toJson(),
      );

  /// Get driver stats
  @override
  Future<DriverStats> getDriverStats(String driverId) async {
    final doc = await _driverStatsCollection.doc(driverId).get();
    if (!doc.exists) {
      // Create default stats if not exists
      final stats = DriverStats(driverId: driverId);
      await _driverStatsCollection.doc(driverId).set(stats);
      return stats;
    }
    return doc.data()!;
  }

  /// Stream driver stats
  @override
  Stream<DriverStats> streamDriverStats(String driverId) {
    return _driverStatsCollection.doc(driverId).snapshots().map((doc) {
      return doc.data() ?? DriverStats(driverId: driverId);
    });
  }

  /// Streams pending bookings for a driver (replaces old rideRequests flow).
  @override
  Stream<List<RideBooking>> streamPendingRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: BookingStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Streams accepted bookings for a driver.
  @override
  Stream<List<RideBooking>> streamAcceptedRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: BookingStatus.accepted.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Streams rejected/cancelled bookings for a driver.
  @override
  Stream<List<RideBooking>> streamRejectedRequests(String driverId) {
    return _rideBookingsCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [BookingStatus.rejected.name, BookingStatus.cancelled.name])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Get upcoming rides for driver - returns proper RideModel
  @override
  Stream<List<RideModel>> streamUpcomingRides(String driverId) {
    final now = DateTime.now();
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .where('schedule.departureTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', whereIn: ['active', 'full'])
        .orderBy('schedule.departureTime')
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Get earnings transactions
  @override
  Stream<List<EarningsTransaction>> streamTransactions(String driverId) {
    return _transactionsCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Accept a ride request
  ///
  /// Updates the booking document in the `bookings` collection and
  /// increments the ride's booked capacity.
  @override
  Future<void> acceptRequest(String rideId, String bookingId) async {
    final bookingDoc = await _rideBookingsCollection.doc(bookingId).get();
    if (!bookingDoc.exists) return;

    final seatsBooked = bookingDoc.data()?.seatsBooked ?? 1;

    // Update booking status
    await _rideBookingsCollection.doc(bookingId).update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Update ride capacity
    await _ridesCollection.doc(rideId).update({
      'capacity.booked': FieldValue.increment(seatsBooked),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Decline a ride request
  ///
  /// Updates the booking document status in the `bookings` collection.
  @override
  Future<void> declineRequest(String rideId, String bookingId) async {
    final bookingDoc = await _rideBookingsCollection.doc(bookingId).get();
    if (!bookingDoc.exists) return;

    await _rideBookingsCollection.doc(bookingId).update({
      'status': 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update driver stats after ride completion
  @override
  Future<void> recordRideCompletion({
    required String driverId,
    required double earnings,
    required double distanceKm,
  }) async {
    DriverStats? currentStats = await getDriverStats(driverId);
    final updatedStats = currentStats.copyWith(
      totalRides: currentStats.totalRides + 1,
      ridesToday: currentStats.ridesToday + 1, // new
      ridesThisWeek: currentStats.ridesThisWeek + 1,
      ridesThisMonth: currentStats.ridesThisMonth + 1,
      totalEarnings: currentStats.totalEarnings + earnings,
      earningsToday: currentStats.earningsToday + earnings,
      earningsThisWeek: currentStats.earningsThisWeek + earnings,
      earningsThisMonth: currentStats.earningsThisMonth + earnings,
      totalDistance: currentStats.totalDistance + distanceKm,
      lastRideAt: DateTime.now(),
    );  
    await _driverStatsCollection
        .doc(driverId)
        .set(updatedStats, SetOptions(merge: true));
  }
}

@riverpod
Stream<DriverStats> driverStats(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(DriverStats(driverId: ''));
  }
  return ref.watch(driverStatsRepositoryProvider).streamDriverStats(user.uid);
}

@riverpod
Stream<List<RideBooking>> pendingRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(driverStatsRepositoryProvider).streamPendingRequests(user.uid);
}

@riverpod
Stream<List<RideBooking>> acceptedRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(driverStatsRepositoryProvider).streamAcceptedRequests(user.uid);
}

@riverpod
Stream<List<RideBooking>> rejectedRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(driverStatsRepositoryProvider).streamRejectedRequests(user.uid);
}

@riverpod
Stream<List<RideModel>> upcomingDriverRides(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(driverStatsRepositoryProvider).streamUpcomingRides(user.uid);
}

@riverpod
Stream<List<EarningsTransaction>> earningsTransactions(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref.watch(driverStatsRepositoryProvider).streamTransactions(user.uid);
}
