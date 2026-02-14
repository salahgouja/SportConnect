import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_home_repository.dart';
import 'package:sport_connect/features/home/models/home_models.dart';

part 'home_repository.g.dart';

/// Repository for home screen data
class HomeRepository implements IHomeRepository {
  final FirebaseFirestore _firestore;

  HomeRepository(this._firestore);

  /// Stream nearby active rides
  Stream<List<NearbyRidePreview>> streamNearbyRides({
    required LatLng center,
    double radiusKm = 50,
    int limit = 20,
  }) {
    // Note: For production, use geohashing or Firebase GeoFire for efficient geo-queries
    return _firestore
        .collection(AppConstants.ridesCollection)
        .where('status', isEqualTo: 'active')
        .where(
          'schedule.departureTime',
          isGreaterThan: Timestamp.fromDate(DateTime.now()),
        )
        .orderBy('schedule.departureTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NearbyRidePreview.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Stream popular hotspots
  Stream<List<Hotspot>> streamHotspots({int limit = 10}) {
    return _firestore
        .collection('hotspots')
        .orderBy('rideCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Hotspot.fromJson(doc.data(), doc.id))
              .toList();
        });
  }

  /// Get hotspots near a location
  Future<List<Hotspot>> getHotspotsNearLocation(
    LatLng location, {
    double radiusKm = 10,
  }) async {
    // Simplified query - in production, use proper geo-queries
    final snapshot = await _firestore
        .collection('hotspots')
        .orderBy('rideCount', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => Hotspot.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Increment hotspot ride count (called when a ride is created)
  Future<void> incrementHotspotCount(String hotspotId) async {
    await _firestore.collection('hotspots').doc(hotspotId).update({
      'rideCount': FieldValue.increment(1),
    });
  }

  /// Create a new hotspot
  Future<String> createHotspot(Hotspot hotspot) async {
    final docRef = await _firestore
        .collection('hotspots')
        .add(hotspot.toJson());
    return docRef.id;
  }
}

/// Provider for HomeRepository
@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository(FirebaseFirestore.instance);
}

/// Stream provider for nearby rides
@riverpod
Stream<List<NearbyRidePreview>> nearbyRidesStream(Ref ref, LatLng location) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamNearbyRides(center: location);
}

/// Stream provider for hotspots
@riverpod
Stream<List<Hotspot>> hotspotsStream(Ref ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamHotspots();
}
