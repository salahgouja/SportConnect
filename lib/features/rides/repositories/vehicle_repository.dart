import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/features/rides/models/vehicle_model.dart';

part 'vehicle_repository.g.dart';

/// Vehicle Repository for Firestore operations
class VehicleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  VehicleRepository(this._firestore, this._storage);

  CollectionReference<Map<String, dynamic>> get _vehiclesCollection =>
      _firestore.collection(AppConstants.vehiclesCollection);

  // ==================== VEHICLE OPERATIONS ====================

  /// Create a new vehicle
  Future<String> createVehicle(VehicleModel vehicle) async {
    final docRef = _vehiclesCollection.doc();
    final vehicleWithId = vehicle.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(vehicleWithId.toJson());
    return docRef.id;
  }

  /// Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    final doc = await _vehiclesCollection.doc(id).get();
    if (!doc.exists) return null;
    return VehicleModel.fromJson(doc.data()!);
  }

  /// Stream user's vehicles
  Stream<List<VehicleModel>> streamUserVehicles(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VehicleModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Get user's vehicles
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => VehicleModel.fromJson(doc.data()))
        .toList();
  }

  /// Get user's active vehicle
  Future<VehicleModel?> getActiveVehicle(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return VehicleModel.fromJson(snapshot.docs.first.data());
  }

  /// Stream user's active vehicle
  Stream<VehicleModel?> streamActiveVehicle(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return VehicleModel.fromJson(snapshot.docs.first.data());
        });
  }

  /// Update vehicle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _vehiclesCollection.doc(vehicle.id).update({
      ...vehicle.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Set vehicle as active (deactivates others)
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
    batch.update(_vehiclesCollection.doc(vehicleId), {'isActive': true});

    await batch.commit();
  }

  /// Delete vehicle
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

    await _vehiclesCollection.doc(vehicleId).delete();
  }

  /// Upload vehicle image
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
  Future<void> updateVerificationStatus({
    required String vehicleId,
    required VehicleVerificationStatus status,
    String? note,
  }) async {
    await _vehiclesCollection.doc(vehicleId).update({
      'verificationStatus': status.name,
      'verificationNote': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update vehicle stats after ride
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

    await _vehiclesCollection.doc(vehicleId).update({
      'totalRides': newTotalRides,
      'averageRating': newAverageRating,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
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
