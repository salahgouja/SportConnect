import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

/// Vehicle Repository for Firestore operations
abstract class IVehicleRepository {
  // ==================== VEHICLE OPERATIONS ====================

  /// Create a new vehicle
  Future<String> createVehicle(VehicleModel vehicle);

  /// Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id);

  /// Stream user's vehicles
  Stream<List<VehicleModel>> streamUserVehicles(String userId);

  /// Get user's vehicles
  Future<List<VehicleModel>> getUserVehicles(String userId);

  /// Get user's active vehicle
  Future<VehicleModel?> getActiveVehicle(String userId);

  /// Stream user's active vehicle
  Stream<VehicleModel?> streamActiveVehicle(String userId);

  /// Update vehicle
  Future<void> updateVehicle(VehicleModel vehicle);

  /// Set vehicle as active (deactivates others)
  Future<void> setActiveVehicle(String userId, String vehicleId);

  /// Delete vehicle
  Future<void> deleteVehicle(String vehicleId);

  /// Upload vehicle image
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required String imagePath,
    required List<int> imageBytes,
  });

  /// Update vehicle verification status
  Future<void> updateVerificationStatus({
    required String vehicleId,
    required VehicleVerificationStatus status,
    String? note,
  });

  /// Update vehicle stats after ride
  Future<void> updateVehicleStats({
    required String vehicleId,
    required double newRating,
  });
}
