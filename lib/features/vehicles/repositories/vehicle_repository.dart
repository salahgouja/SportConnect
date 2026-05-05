import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'vehicle_repository.g.dart';

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

/// Vehicle Repository for Firestore operations
class VehicleRepository {
  VehicleRepository(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<VehicleModel> get _vehiclesCollection => _firestore
      .collection(AppConstants.vehiclesCollection)
      .withConverter<VehicleModel>(
        fromFirestore: (snap, _) =>
            VehicleModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (vehicle, _) => vehicle.toJson(),
      );

  // ==================== VEHICLE OPERATIONS ====================

  /// Create a new vehicle
  Future<String> createVehicle(VehicleModel vehicle) async {
    // VE-3: Validate vehicle year is realistic (1900-current year + 1).
    final currentYear = DateTime.now().year;
    if (vehicle.year < 1900 || vehicle.year > currentYear + 1) {
      throw ArgumentError(
        'Vehicle year must be between 1900 and ${currentYear + 1} (got ${vehicle.year}).',
      );
    }

    // FIX VE-1: Reject duplicate license plates across all drivers.
    final plateQuery = await _vehiclesCollection
        .where('licensePlate', isEqualTo: vehicle.licensePlate)
        .limit(1)
        .get();
    if (plateQuery.docs.isNotEmpty) {
      throw StateError(
        'A vehicle with plate "${vehicle.licensePlate}" is already registered.',
      );
    }

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
  Future<VehicleModel?> getVehicleById(String id) async {
    final doc = await _vehiclesCollection.doc(id).get();
    return doc.data();
  }

  /// Stream user's vehicles
  Stream<List<VehicleModel>> streamUserVehicles(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get user's vehicles
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get user's active vehicle
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
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _vehiclesCollection.doc(vehicle.id).update({
      ...vehicle.toJson(),
      'updatedAt': DateTime.now(),
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
        } on Exception catch (e, st) {}
      }

      // Delete additional images
      for (final url in vehicle.imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } on Exception catch (e, st) {}
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
    final ref = _storage
        .ref()
        .child('vehicles')
        .child(vehicleId)
        .child(imagePath);
    await ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
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
      'updatedAt': DateTime.now(),
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
      'updatedAt': DateTime.now(),
    });
  }
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
