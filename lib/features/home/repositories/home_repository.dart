import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_home_repository.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

/// Repository for home screen data
class HomeRepository implements IHomeRepository {
  HomeRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter(
        fromFirestore: (snap, _) => RideModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  /// Stream nearby active rides
  @override
  Stream<List<RideModel>> streamNearbyRides({
    required LatLng center,
    double radiusKm = 50,
    int limit = 20,
  }) {
    // Note: For production, use geohashing or Firebase GeoFire for efficient geo-queries
    return _ridesCollection
        .where('status', isEqualTo: 'active')
        .where(
          'schedule.departureTime',
          isGreaterThan: Timestamp.fromDate(DateTime.now()),
        )
        .orderBy('schedule.departureTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          const distance = Distance();
          final maxDistanceMeters = radiusKm * 1000;

          final rides = snapshot.docs
              .map((doc) => doc.data())
              .where((ride) {
                final rideOrigin = ride.origin.toLatLng();
                final distanceMeters = distance.as(
                  LengthUnit.Meter,
                  center,
                  rideOrigin,
                );
                return distanceMeters <= maxDistanceMeters;
              })
              .take(limit)
              .toList();

          return rides;
        });
  }
}
