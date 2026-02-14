import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/interfaces/repositories/i_driver_stats_repository.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

part 'driver_stats_repository.g.dart';

/// Driver Stats Repository
class DriverStatsRepository implements IDriverStatsRepository {
  final FirebaseFirestore _firestore;

  DriverStatsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _driverStatsCollection =>
      _firestore.collection('driver_stats');

  CollectionReference<Map<String, dynamic>> get _ridesCollection =>
      _firestore.collection(AppConstants.ridesCollection);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(AppConstants.usersCollection);

  CollectionReference<Map<String, dynamic>> get _transactionsCollection =>
      _firestore.collection('transactions');

  /// Get driver stats
  Future<DriverStats> getDriverStats(String driverId) async {
    final doc = await _driverStatsCollection.doc(driverId).get();
    if (!doc.exists) {
      // Create default stats if not exists
      final stats = DriverStats(driverId: driverId);
      await _driverStatsCollection.doc(driverId).set(stats.toJson());
      return stats;
    }
    return DriverStats.fromJson(doc.data()!);
  }

  /// Stream driver stats
  Stream<DriverStats> streamDriverStats(String driverId) {
    return _driverStatsCollection.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) {
        return DriverStats(driverId: driverId);
      }
      return DriverStats.fromJson(doc.data()!);
    });
  }

  /// Update driver online status
  Future<void> setOnlineStatus(String driverId, bool isOnline) async {
    await _driverStatsCollection.doc(driverId).set({
      'isOnline': isOnline,
      'lastStatusChange': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Streams pending ride requests for a driver.
  ///
  /// Queries the `rideRequests` collection directly for pending requests
  /// addressed to this driver.
  Stream<List<RideRequestModel>> streamPendingRequests(String driverId) {
    return _firestore
        .collection('rideRequests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: RideRequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RideRequestModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Streams accepted ride requests for a driver.
  Stream<List<RideRequestModel>> streamAcceptedRequests(String driverId) {
    return _firestore
        .collection('rideRequests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: RideRequestStatus.accepted.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RideRequestModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Streams rejected ride requests for a driver.
  Stream<List<RideRequestModel>> streamRejectedRequests(String driverId) {
    return _firestore
        .collection('rideRequests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: RideRequestStatus.rejected.name)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RideRequestModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Get upcoming rides for driver - returns proper RideModel
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
          return snapshot.docs.map((doc) {
            return RideModel.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  /// Get earnings transactions
  Stream<List<EarningsTransaction>> streamTransactions(String driverId) {
    return _transactionsCollection
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    EarningsTransaction.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList();
        });
  }

  /// Accept a ride request
  Future<void> acceptRequest(String rideId, String bookingId) async {
    final rideDoc = await _ridesCollection.doc(rideId).get();
    if (!rideDoc.exists) return;

    final bookings = List<Map<String, dynamic>>.from(
      rideDoc.data()?['bookings'] ?? [],
    );

    final index = bookings.indexWhere((b) => b['id'] == bookingId);
    if (index != -1) {
      bookings[index]['status'] = 'accepted';
      bookings[index]['respondedAt'] = Timestamp.now();

      await _ridesCollection.doc(rideId).update({
        'bookings': bookings,
        'bookedSeats': FieldValue.increment(
          bookings[index]['seatsBooked'] ?? 1,
        ),
      });
    }
  }

  /// Decline a ride request
  Future<void> declineRequest(String rideId, String bookingId) async {
    final rideDoc = await _ridesCollection.doc(rideId).get();
    if (!rideDoc.exists) return;

    final bookings = List<Map<String, dynamic>>.from(
      rideDoc.data()?['bookings'] ?? [],
    );

    final index = bookings.indexWhere((b) => b['id'] == bookingId);
    if (index != -1) {
      bookings[index]['status'] = 'rejected';
      bookings[index]['respondedAt'] = Timestamp.now();

      await _ridesCollection.doc(rideId).update({'bookings': bookings});
    }
  }

  /// Update driver stats after ride completion
  Future<void> recordRideCompletion({
    required String driverId,
    required double earnings,
    required double distanceKm,
  }) async {
    final co2Saved = distanceKm * 0.12; // ~120g CO2 per km saved

    await _driverStatsCollection.doc(driverId).set({
      'totalRides': FieldValue.increment(1),
      'ridesCompleted': FieldValue.increment(1),
      'ridesThisWeek': FieldValue.increment(1),
      'ridesThisMonth': FieldValue.increment(1),
      'totalEarnings': FieldValue.increment(earnings),
      'earningsThisWeek': FieldValue.increment(earnings),
      'earningsThisMonth': FieldValue.increment(earnings),
      'earningsToday': FieldValue.increment(earnings),
      'co2Saved': FieldValue.increment(co2Saved),
      'lastRideAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

@Riverpod(keepAlive: true)
DriverStatsRepository driverStatsRepository(Ref ref) {
  return DriverStatsRepository(FirebaseFirestore.instance);
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
Stream<List<RideRequestModel>> pendingRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref
      .watch(driverStatsRepositoryProvider)
      .streamPendingRequests(user.uid);
}

@riverpod
Stream<List<RideRequestModel>> acceptedRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref
      .watch(driverStatsRepositoryProvider)
      .streamAcceptedRequests(user.uid);
}

@riverpod
Stream<List<RideRequestModel>> rejectedRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref
      .watch(driverStatsRepositoryProvider)
      .streamRejectedRequests(user.uid);
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
