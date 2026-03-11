import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'vehicle_management_view_model.g.dart';

class AddVehicleSheetUiState {
  const AddVehicleSheetUiState({
    this.capacity = 4,
    this.fuelType = FuelType.gasoline,
    this.imageFile,
    this.isLoading = false,
  });

  final int capacity;
  final FuelType fuelType;
  final File? imageFile;
  final bool isLoading;

  AddVehicleSheetUiState copyWith({
    int? capacity,
    FuelType? fuelType,
    File? imageFile,
    bool clearImageFile = false,
    bool? isLoading,
  }) {
    return AddVehicleSheetUiState(
      capacity: capacity ?? this.capacity,
      fuelType: fuelType ?? this.fuelType,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AddVehicleSheetUiViewModel extends _$AddVehicleSheetUiViewModel {
  @override
  AddVehicleSheetUiState build(String arg) => const AddVehicleSheetUiState();

  void init(VehicleModel? vehicle) {
    state = AddVehicleSheetUiState(
      capacity: vehicle?.capacity ?? 4,
      fuelType: vehicle?.fuelType ?? FuelType.gasoline,
    );
  }

  void setCapacity(int capacity) {
    state = state.copyWith(capacity: capacity);
  }

  void setFuelType(FuelType fuelType) {
    state = state.copyWith(fuelType: fuelType);
  }

  void setImageFile(File imageFile) {
    state = state.copyWith(imageFile: imageFile);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}
