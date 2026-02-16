import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/rides/repositories/vehicle_repository.dart';
import 'package:sport_connect/core/providers/user_providers.dart';

part 'vehicle_view_model.g.dart';

/// Vehicle state for managing vehicle-related UI state
class VehicleState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final VehicleModel? selectedVehicle;

  const VehicleState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedVehicle,
  });

  VehicleState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    VehicleModel? selectedVehicle,
  }) {
    return VehicleState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }
}

/// ViewModel for vehicle-related operations
/// Manages vehicle CRUD operations, active vehicle selection, and verification
@riverpod
class VehicleViewModel extends _$VehicleViewModel {
  @override
  VehicleState build() {
    return const VehicleState();
  }

  String? _getCurrentUserId() {
    final userAsync = ref.read(currentUserProvider);
    return userAsync.value?.uid;
  }

  /// Create a new vehicle
  Future<bool> createVehicle(VehicleModel vehicle) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the vehicle has the correct owner ID
      final vehicleWithOwner = vehicle.copyWith(ownerId: userId);

      final vehicleId = await repository.createVehicle(vehicleWithOwner);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        selectedVehicle: vehicleWithOwner.copyWith(id: vehicleId),
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to create vehicle: $e',
      );
      return false;
    }
  }

  /// Update an existing vehicle
  Future<bool> updateVehicle(VehicleModel vehicle) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await repository.updateVehicle(vehicle);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        selectedVehicle: vehicle,
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to update vehicle: $e',
      );
      return false;
    }
  }

  /// Delete a vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await repository.deleteVehicle(vehicleId);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        selectedVehicle: null,
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to delete vehicle: $e',
      );
      return false;
    }
  }

  /// Set a vehicle as active (deactivates all others)
  Future<bool> setActiveVehicle(String vehicleId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await repository.setActiveVehicle(userId, vehicleId);

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh vehicle streams
      ref.invalidate(userVehiclesStreamProvider(userId));
      ref.invalidate(activeVehicleStreamProvider(userId));

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to set active vehicle: $e',
      );
      return false;
    }
  }

  /// Upload vehicle image
  Future<String?> uploadVehicleImage({
    required String vehicleId,
    required File imageFile,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final imageBytes = await imageFile.readAsBytes();
      final imagePath = 'main_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final imageUrl = await repository.uploadVehicleImage(
        vehicleId: vehicleId,
        imagePath: imagePath,
        imageBytes: imageBytes,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);

      return imageUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload image: $e',
      );
      return null;
    }
  }

  /// Update vehicle verification status (admin function)
  Future<bool> updateVerificationStatus({
    required String vehicleId,
    required VehicleVerificationStatus status,
    String? note,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);

      await repository.updateVerificationStatus(
        vehicleId: vehicleId,
        status: status,
        note: note,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh vehicle if we have userId
      final userId = _getCurrentUserId();
      if (userId != null) {
        ref.invalidate(userVehiclesStreamProvider(userId));
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to update verification status: $e',
      );
      return false;
    }
  }

  /// Update vehicle stats after a ride
  Future<bool> updateVehicleStats({
    required String vehicleId,
    required double rating,
  }) async {
    try {
      final repository = ref.read(vehicleRepositoryProvider);

      await repository.updateVehicleStats(
        vehicleId: vehicleId,
        newRating: rating,
      );

      // Refresh vehicle if we have userId
      final userId = _getCurrentUserId();
      if (userId != null) {
        ref.invalidate(userVehiclesStreamProvider(userId));
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update vehicle stats: $e',
      );
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success state
  void clearSuccess() {
    state = state.copyWith(isSuccess: false);
  }

  /// Select a vehicle for viewing/editing
  void selectVehicle(VehicleModel vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  /// Clear selected vehicle
  void clearSelectedVehicle() {
    state = state.copyWith(selectedVehicle: null);
  }
}
