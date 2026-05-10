import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'vehicle_management_view_model.g.dart';

class AddVehicleSheetUiState {
  const AddVehicleSheetUiState({
    this.capacity = 4,
    this.imageFile,
    this.isLoading = false,
  });

  final int capacity;
  final File? imageFile;
  final bool isLoading;

  AddVehicleSheetUiState copyWith({
    int? capacity,
    File? imageFile,
    bool clearImageFile = false,
    bool? isLoading,
  }) {
    return AddVehicleSheetUiState(
      capacity: capacity ?? this.capacity,
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
    );
  }

  void setCapacity(int capacity) {
    state = state.copyWith(capacity: capacity);
  }

  void setImageFile(File imageFile) {
    state = state.copyWith(imageFile: imageFile);
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }
}
