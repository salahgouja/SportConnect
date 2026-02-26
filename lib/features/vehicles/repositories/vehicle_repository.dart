import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_vehicle_repository.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'vehicle_repository.g.dart';

/// Vehicle Repository for Firestore operations
class VehicleRepository implements IVehicleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  VehicleRepository(this._firestore, this._storage);

  CollectionReference<VehicleModel> get _vehiclesCollection => _firestore
      .collection(AppConstants.vehiclesCollection)
      .withConverter<VehicleModel>(
        fromFirestore: (snap, _) =>
            VehicleModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (vehicle, _) => vehicle.toJson(),
      );

  DocumentReference<Map<String, dynamic>> _rawVehicleDoc(String id) =>
      _firestore.collection(AppConstants.vehiclesCollection).doc(id);

  // ==================== VEHICLE OPERATIONS ====================

  /// Create a new vehicle
  @override
  Future<String> createVehicle(VehicleModel vehicle) async {
    final rawCol = _firestore.collection(AppConstants.vehiclesCollection);
    final docRef = rawCol.doc();
    final vehicleWithId = vehicle.copyWith(id: docRef.id);
    final json = vehicleWithId.toJson();
    // Use server timestamps for consistency across time zones
    json['createdAt'] = DateTime.now();
    json['updatedAt'] = DateTime.now();
    await docRef.set(json);
    return docRef.id;
  }

  /// Get vehicle by ID
  @override
  Future<VehicleModel?> getVehicleById(String id) async {
    final doc = await _vehiclesCollection.doc(id).get();
    return doc.data();
  }

  /// Stream user's vehicles
  @override
  Stream<List<VehicleModel>> streamUserVehicles(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get user's vehicles
  @override
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get user's active vehicle
  @override
  Future<VehicleModel?> getActiveVehicle(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  /// Stream user's active vehicle
  @override
  Stream<VehicleModel?> streamActiveVehicle(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return snapshot.docs.first.data();
        });
  }

  /// Update vehicle
  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _rawVehicleDoc(
      vehicle.id,
    ).update({...vehicle.toJson(), 'updatedAt': DateTime.now()});
  }

  /// Set vehicle as active (deactivates others)
  @override
  Future<void> setActiveVehicle(String userId, String vehicleId) async {
    final batch = _firestore.batch();

    // Deactivate all user's vehicles
    final userVehicles = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .get();

    for (final doc in userVehicles.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // Activate the selected vehicle
    batch.update(_rawVehicleDoc(vehicleId), {'isActive': true});

    await batch.commit();
  }

  /// Delete vehicle
  @override
  Future<void> deleteVehicle(String vehicleId) async {
    // Get vehicle first to delete associated images
    final vehicle = await getVehicleById(vehicleId);
    if (vehicle != null) {
      // Delete vehicle image from storage
      if (vehicle.imageUrl != null) {
        try {
          await _storage.refFromURL(vehicle.imageUrl!).delete();
        } catch (_) {}
      }

      // Delete additional images
      for (final url in vehicle.imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
    }

    await _rawVehicleDoc(vehicleId).delete();
  }

  /// Upload vehicle image
  @override
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required String imagePath,
    required List<int> imageBytes,
  }) async {
    final ref = _storage.ref().child('vehicles/$vehicleId/$imagePath');
    await ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  /// Update vehicle verification status
  @override
  Future<void> updateVerificationStatus({
    required String vehicleId,
    required VehicleVerificationStatus status,
    String? note,
  }) async {
    await _rawVehicleDoc(vehicleId).update({
      'verificationStatus': status.name,
      'verificationNote': note,
      'updatedAt': DateTime.now(),
    });
  }

  /// Update vehicle stats after ride
  @override
  Future<void> updateVehicleStats({
    required String vehicleId,
    required double newRating,
  }) async {
    final vehicle = await getVehicleById(vehicleId);
    if (vehicle == null) return;

    final newTotalRides = vehicle.totalRides + 1;
    final newAverageRating =
        ((vehicle.averageRating * vehicle.totalRides) + newRating) /
        newTotalRides;

    await _rawVehicleDoc(vehicleId).update({
      'totalRides': newTotalRides,
      'averageRating': newAverageRating,
      'updatedAt': DateTime.now(),
    });
  }
}

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
}

/// Provider for streaming user vehicles
@riverpod
Stream<List<VehicleModel>> userVehiclesStream(Ref ref, String userId) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.streamUserVehicles(userId);
}

/// Provider for streaming active vehicle
@riverpod
Stream<VehicleModel?> activeVehicleStream(Ref ref, String userId) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.streamActiveVehicle(userId);
}
