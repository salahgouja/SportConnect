import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

/// Fuel type enum
enum FuelType {
  gasoline,
  diesel,
  electric,
  hybrid,
  pluginHybrid,
  hydrogen,
  other,
}

/// Vehicle verification status
enum VehicleVerificationStatus { pending, verified, rejected }

/// Vehicle model
@freezed
abstract class VehicleModel with _$VehicleModel {
  const VehicleModel._();

  const factory VehicleModel({
    required String id,
    required String ownerId,
    required String make,
    required String model,
    required String year,
    required String color,
    required String licensePlate,
    @Default(4) int capacity,
    @Default(FuelType.gasoline) FuelType fuelType,
    String? imageUrl,
    @Default([]) List<String> imageUrls,
    @Default(false) bool isActive,
    @Default(VehicleVerificationStatus.pending)
    VehicleVerificationStatus verificationStatus,
    String? verificationNote,

    // Vehicle documents
    String? registrationDocUrl,
    String? insuranceDocUrl,
    @TimestampConverter() DateTime? insuranceExpiry,

    // Vehicle features/amenities
    @Default(false) bool hasAC,
    @Default(false) bool hasCharger,
    @Default(false) bool hasWifi,
    @Default(false) bool petsAllowed,
    @Default(false) bool smokingAllowed,
    @Default(false) bool hasLuggage,

    // Stats
    @Default(0) int totalRides,
    @Default(0.0) double averageRating,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  /// Check if vehicle is verified
  bool get isVerified =>
      verificationStatus == VehicleVerificationStatus.verified;

  /// Get display name
  String get displayName => '$year $make $model';

  /// Get fuel type display name
  String get fuelTypeDisplayName {
    switch (fuelType) {
      case FuelType.gasoline:
        return 'Gasoline';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.pluginHybrid:
        return 'Plug-in Hybrid';
      case FuelType.hydrogen:
        return 'Hydrogen';
      case FuelType.other:
        return 'Other';
    }
  }

  /// Get list of enabled features
  List<String> get enabledFeatures {
    final features = <String>[];
    if (hasAC) features.add('Air Conditioning');
    if (hasCharger) features.add('Phone Charger');
    if (hasWifi) features.add('WiFi');
    if (petsAllowed) features.add('Pets Allowed');
    if (smokingAllowed) features.add('Smoking Allowed');
    if (hasLuggage) features.add('Luggage Space');
    return features;
  }
}
