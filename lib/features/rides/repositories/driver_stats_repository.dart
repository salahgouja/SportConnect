import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';

part 'driver_stats_repository.g.dart';

/// Driver Statistics Model
class DriverStats {
  final String driverId;
  final double rating;
  final int totalRides;
  final int ridesThisWeek;
  final int ridesThisMonth;
  final int ridesCompleted;
  final int pendingRequests;
  final double totalEarnings;
  final double earningsThisWeek;
  final double earningsThisMonth;
  final double earningsToday;
  final double co2Saved;
  final double hoursOnline;
  final double hoursOnlineThisWeek;
  final bool isOnline;
  final DateTime? lastRideAt;

  DriverStats({
    required this.driverId,
    this.rating = 0.0,
    this.totalRides = 0,
    this.ridesThisWeek = 0,
    this.ridesThisMonth = 0,
    this.ridesCompleted = 0,
    this.pendingRequests = 0,
    this.totalEarnings = 0.0,
    this.earningsThisWeek = 0.0,
    this.earningsThisMonth = 0.0,
    this.earningsToday = 0.0,
    this.co2Saved = 0.0,
    this.hoursOnline = 0.0,
    this.hoursOnlineThisWeek = 0.0,
    this.isOnline = false,
    this.lastRideAt,
  });

  factory DriverStats.fromJson(Map<String, dynamic> json, String driverId) {
    return DriverStats(
      driverId: driverId,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
      ridesThisWeek: (json['ridesThisWeek'] as num?)?.toInt() ?? 0,
      ridesThisMonth: (json['ridesThisMonth'] as num?)?.toInt() ?? 0,
      ridesCompleted: (json['ridesCompleted'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      earningsThisWeek: (json['earningsThisWeek'] as num?)?.toDouble() ?? 0.0,
      earningsThisMonth: (json['earningsThisMonth'] as num?)?.toDouble() ?? 0.0,
      earningsToday: (json['earningsToday'] as num?)?.toDouble() ?? 0.0,
      co2Saved: (json['co2Saved'] as num?)?.toDouble() ?? 0.0,
      hoursOnline: (json['hoursOnline'] as num?)?.toDouble() ?? 0.0,
      hoursOnlineThisWeek:
          (json['hoursOnlineThisWeek'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
      lastRideAt: json['lastRideAt'] != null
          ? (json['lastRideAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'totalRides': totalRides,
      'ridesThisWeek': ridesThisWeek,
      'ridesThisMonth': ridesThisMonth,
      'ridesCompleted': ridesCompleted,
      'pendingRequests': pendingRequests,
      'totalEarnings': totalEarnings,
      'earningsThisWeek': earningsThisWeek,
      'earningsThisMonth': earningsThisMonth,
      'earningsToday': earningsToday,
      'co2Saved': co2Saved,
      'hoursOnline': hoursOnline,
      'hoursOnlineThisWeek': hoursOnlineThisWeek,
      'isOnline': isOnline,
      'lastRideAt': lastRideAt != null ? Timestamp.fromDate(lastRideAt!) : null,
    };
  }

  DriverStats copyWith({
    double? rating,
    int? totalRides,
    int? ridesThisWeek,
    int? ridesThisMonth,
    int? ridesCompleted,
    int? pendingRequests,
    double? totalEarnings,
    double? earningsThisWeek,
    double? earningsThisMonth,
    double? earningsToday,
    double? co2Saved,
    double? hoursOnline,
    double? hoursOnlineThisWeek,
    bool? isOnline,
    DateTime? lastRideAt,
  }) {
    return DriverStats(
      driverId: driverId,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      ridesThisWeek: ridesThisWeek ?? this.ridesThisWeek,
      ridesThisMonth: ridesThisMonth ?? this.ridesThisMonth,
      ridesCompleted: ridesCompleted ?? this.ridesCompleted,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      earningsThisWeek: earningsThisWeek ?? this.earningsThisWeek,
      earningsThisMonth: earningsThisMonth ?? this.earningsThisMonth,
      earningsToday: earningsToday ?? this.earningsToday,
      co2Saved: co2Saved ?? this.co2Saved,
      hoursOnline: hoursOnline ?? this.hoursOnline,
      hoursOnlineThisWeek: hoursOnlineThisWeek ?? this.hoursOnlineThisWeek,
      isOnline: isOnline ?? this.isOnline,
      lastRideAt: lastRideAt ?? this.lastRideAt,
    );
  }
}

/// Ride Request Model
class RideRequest {
  final String id;
  final String rideId;
  final String passengerId;
  final String passengerName;
  final String? passengerPhotoUrl;
  final double passengerRating;
  final String fromLocation;
  final String toLocation;
  final DateTime requestedDate;
  final String requestedTime;
  final int seatsRequested;
  final double pricePerSeat;
  final String? message;
  final String status; // pending, accepted, declined

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhotoUrl,
    this.passengerRating = 0.0,
    required this.fromLocation,
    required this.toLocation,
    required this.requestedDate,
    required this.requestedTime,
    this.seatsRequested = 1,
    this.pricePerSeat = 0.0,
    this.message,
    this.status = 'pending',
  });

  factory RideRequest.fromJson(Map<String, dynamic> json, String id) {
    return RideRequest(
      id: id,
      rideId: json['rideId'] ?? '',
      passengerId: json['passengerId'] ?? '',
      passengerName: json['passengerName'] ?? '',
      passengerPhotoUrl: json['passengerPhotoUrl'],
      passengerRating: (json['passengerRating'] as num?)?.toDouble() ?? 0.0,
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      requestedDate: json['requestedDate'] != null
          ? (json['requestedDate'] as Timestamp).toDate()
          : DateTime.now(),
      requestedTime: json['requestedTime'] ?? '',
      seatsRequested: (json['seatsRequested'] as num?)?.toInt() ?? 1,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
      message: json['message'],
      status: json['status'] ?? 'pending',
    );
  }
}

/// Earnings Transaction Model
class EarningsTransaction {
  final String id;
  final String rideId;
  final double amount;
  final String description;
  final String type; // ride, bonus, refund, payout
  final DateTime createdAt;

  EarningsTransaction({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory EarningsTransaction.fromJson(Map<String, dynamic> json, String id) {
    return EarningsTransaction(
      id: id,
      rideId: json['rideId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      type: json['type'] ?? 'ride',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

/// Driver Stats Repository
class DriverStatsRepository {
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
    return DriverStats.fromJson(doc.data()!, driverId);
  }

  /// Stream driver stats
  Stream<DriverStats> streamDriverStats(String driverId) {
    return _driverStatsCollection.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) {
        return DriverStats(driverId: driverId);
      }
      return DriverStats.fromJson(doc.data()!, driverId);
    });
  }

  /// Update driver online status
  Future<void> setOnlineStatus(String driverId, bool isOnline) async {
    await _driverStatsCollection.doc(driverId).set({
      'isOnline': isOnline,
      'lastStatusChange': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get pending ride requests for driver
  Stream<List<RideRequest>> streamPendingRequests(String driverId) {
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((ridesSnapshot) async {
          List<RideRequest> requests = [];

          for (final rideDoc in ridesSnapshot.docs) {
            final rideData = rideDoc.data();
            final bookings = rideData['bookings'] as List<dynamic>? ?? [];

            for (final booking in bookings) {
              if (booking['status'] == 'pending') {
                // Get passenger info
                final passengerDoc = await _usersCollection
                    .doc(booking['passengerId'])
                    .get();
                final passengerData = passengerDoc.data() ?? {};

                requests.add(
                  RideRequest(
                    id: booking['id'] ?? '',
                    rideId: rideDoc.id,
                    passengerId: booking['passengerId'] ?? '',
                    passengerName:
                        passengerData['displayName'] ??
                        booking['passengerName'] ??
                        '',
                    passengerPhotoUrl: passengerData['photoUrl'],
                    passengerRating:
                        (passengerData['rating'] as num?)?.toDouble() ?? 0.0,
                    fromLocation: rideData['origin']?['address'] ?? '',
                    toLocation: rideData['destination']?['address'] ?? '',
                    requestedDate: rideData['departureTime'] != null
                        ? (rideData['departureTime'] as Timestamp).toDate()
                        : DateTime.now(),
                    requestedTime: booking['requestedTime'] ?? '',
                    seatsRequested:
                        (booking['seatsBooked'] as num?)?.toInt() ?? 1,
                    pricePerSeat:
                        (rideData['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
                    message: booking['note'],
                    status: booking['status'] ?? 'pending',
                  ),
                );
              }
            }
          }

          return requests;
        });
  }

  /// Get upcoming rides for driver - returns proper RideModel
  Stream<List<RideModel>> streamUpcomingRides(String driverId) {
    final now = DateTime.now();
    return _ridesCollection
        .where('driverId', isEqualTo: driverId)
        .where('departureTime', isGreaterThan: Timestamp.fromDate(now))
        .where('status', whereIn: ['active', 'full'])
        .orderBy('departureTime')
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
              .map((doc) => EarningsTransaction.fromJson(doc.data(), doc.id))
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
Stream<List<RideRequest>> pendingRideRequests(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  return ref
      .watch(driverStatsRepositoryProvider)
      .streamPendingRequests(user.uid);
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
