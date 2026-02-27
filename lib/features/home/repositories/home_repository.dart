import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_home_repository.dart';
import 'package:sport_connect/core/providers/firebase_providers.dart';
import 'package:sport_connect/features/home/models/home_models.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'home_repository.g.dart';

/// Repository for home screen data
class HomeRepository implements IHomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepository(this._firestore);

  CollectionReference<RideModel> get _ridesCollection => _firestore
      .collection(AppConstants.ridesCollection)
      .withConverter(
        fromFirestore: (snap, _) => RideModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );
  CollectionReference<Hotspot> get _hotspotsCollection => _firestore
      .collection(AppConstants.hotspotsCollection)
      .withConverter(
        fromFirestore: (snap, _) => Hotspot.fromJson(snap.data()!, snap.id),
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
          final distance = const Distance();
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

  /// Stream popular hotspots
  @override
  Stream<List<Hotspot>> streamHotspots({int limit = 10}) {
    return _hotspotsCollection
        .orderBy('rideCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Get hotspots near a location
  @override
  Future<List<Hotspot>> getHotspotsNearLocation(
    LatLng location, {
    double radiusKm = 10,
  }) async {
    // Simplified query - in production, use proper geo-queries
    final snapshot = await _hotspotsCollection
        .orderBy('rideCount', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Increment hotspot ride count (called when a ride is created)
  @override
  Future<void> incrementHotspotCount(String hotspotId) async {
    await _hotspotsCollection.doc(hotspotId).update({
      'rideCount': FieldValue.increment(1),
    });
  }

  /// Create a new hotspot
  @override
  Future<String> createHotspot(Hotspot hotspot) async {
    final docRef = await _hotspotsCollection.add(hotspot);
    return docRef.id;
  }
}

/// Provider for HomeRepository
@riverpod
IHomeRepository homeRepository(Ref ref) {
  return HomeRepository(ref.watch(firestoreInstanceProvider));
}

/// Stream provider for nearby rides
@riverpod
Stream<List<RideModel>> nearbyRidesStream(
  Ref ref,
  LatLng location,
  double radiusKm,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamNearbyRides(center: location, radiusKm: radiusKm);
}

/// Stream provider for hotspots
@riverpod
Stream<List<Hotspot>> hotspotsStream(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamHotspots();
}
