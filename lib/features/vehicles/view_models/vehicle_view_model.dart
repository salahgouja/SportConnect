import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';

part 'vehicle_view_model.g.dart';

/// Vehicle state for managing vehicle-related UI state
class VehicleState {
  const VehicleState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedVehicle,
    this.actionType,
    this.actionMessage,
    this.userId,
    this.vehicles = const AsyncLoading(),
  });
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final VehicleModel? selectedVehicle;
  final String? actionType;
  final String? actionMessage;

  /// The UID of the currently authenticated user; null when signed out.
  final String? userId;

  /// Live list of the user's vehicles, driven via [ref.listen].
  final AsyncValue<List<VehicleModel>> vehicles;

  VehicleState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    VehicleModel? selectedVehicle,
    String? actionType,
    String? actionMessage,
    String? userId,
    AsyncValue<List<VehicleModel>>? vehicles,
    bool clearAction = false,
  }) {
    return VehicleState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      actionType: clearAction ? null : (actionType ?? this.actionType),
      actionMessage: clearAction ? null : (actionMessage ?? this.actionMessage),
      userId: userId ?? this.userId,
      vehicles: vehicles ?? this.vehicles,
    );
  }
}

/// ViewModel for vehicle-related operations
/// Manages vehicle CRUD operations, active vehicle selection, and verification
@riverpod
class VehicleViewModel extends _$VehicleViewModel {
  @override
  VehicleState build() {
    // Watch auth state — infrequent (login/logout only), safe to use ref.watch.
    final userId = ref.watch(currentAuthUidProvider).value;

    // Subscribe to the user's vehicles stream via ref.listen so that incoming
    // Firestore emissions do NOT re-run build() (which would reset isLoading).
    if (userId != null) {
      ref.listen(userVehiclesStreamProvider(userId), (_, next) {
        state = state.copyWith(vehicles: next);
      });
    }

    return VehicleState(
      userId: userId,
      vehicles: userId != null
          ? ref.read(userVehiclesStreamProvider(userId))
          : const AsyncData([]),
    );
  }

  String? _getCurrentUserId() {
    return ref.read(currentAuthUidProvider).value;
  }

  /// Create a new vehicle
  Future<bool> createVehicle(VehicleModel vehicle) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearAction: true,
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

      if (!ref.mounted) return true;
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        selectedVehicle: vehicleWithOwner.copyWith(id: vehicleId),
        actionType: 'created',
        actionMessage: 'Vehicle added successfully',
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
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
      isSuccess: false,
      clearAction: true,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await repository.updateVehicle(vehicle);

      if (!ref.mounted) return true;
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        selectedVehicle: vehicle,
        actionType: 'updated',
        actionMessage: 'Vehicle updated successfully',
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
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
      isSuccess: false,
      clearAction: true,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Block deletion if the vehicle is used by an active/in-progress ride
      final rideRepo = ref.read(rideRepositoryProvider);
      final inUse = await rideRepo.hasActiveRidesForVehicle(vehicleId);
      if (!ref.mounted) return false;
      if (inUse) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage:
              'This vehicle is linked to an active ride and cannot be deleted.',
        );
        return false;
      }

      await repository.deleteVehicle(vehicleId);

      if (!ref.mounted) return true;
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        actionType: 'deleted',
        actionMessage: 'Vehicle deleted successfully',
      );

      // Refresh user vehicles list
      ref.invalidate(userVehiclesStreamProvider(userId));

      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
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
      isSuccess: false,
      clearAction: true,
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final userId = _getCurrentUserId();

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await repository.setActiveVehicle(userId, vehicleId);

      if (!ref.mounted) return true;
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        actionType: 'activated',
        actionMessage: 'Vehicle set as active',
      );

      // Refresh vehicle streams
      ref.invalidate(userVehiclesStreamProvider(userId));
      ref.invalidate(activeVehicleStreamProvider(userId));

      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to set active vehicle: $e',
      );
      return false;
    }
  }

  void clearAction() {
    state = state.copyWith(clearAction: true);
  }

  /// Upload vehicle image
  Future<String?> uploadVehicleImage({
    required String vehicleId,
    required File imageFile,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final imageBytes = await imageFile.readAsBytes();
      final imagePath = 'main_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final imageUrl = await repository.uploadVehicleImage(
        vehicleId: vehicleId,
        imagePath: imagePath,
        imageBytes: imageBytes,
      );

      if (!ref.mounted) return imageUrl;
      state = state.copyWith(isLoading: false, isSuccess: true);

      return imageUrl;
    } on Exception catch (e, st) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload image: $e',
      );
      return null;
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

      if (!ref.mounted) return true;
      // Refresh vehicle if we have userId
      final userId = _getCurrentUserId();
      if (userId != null) {
        ref.invalidate(userVehiclesStreamProvider(userId));
      }

      return true;
    } on Exception catch (e, st) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        errorMessage: 'Failed to update vehicle stats: $e',
      );
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith();
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
    state = state.copyWith();
  }
}
