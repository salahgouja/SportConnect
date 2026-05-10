import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'vehicle_model.freezed.dart';
part 'vehicle_model.g.dart';

/// Vehicle model - NO circular dependency with DriverModel
/// Owner resolved through VehicleRepository/Service
@freezed
abstract class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String id,
    required String ownerId,
    required String make,
    required String model,
    required int year,
    required String color,
    required String licensePlate,
    @Default('Unknown') String ownerName,
    String? ownerPhotoUrl,
    @Default(4) int capacity,
    String? imageUrl,
    @Default([]) List<String> imageUrls,
    @Default(false) bool isActive,
    @Default(false) bool isDefault,

    // Stats
    @Default(0) int totalRides,
    @Default(0.0) double averageRating,

    // Timestamps
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _VehicleModel;
  const VehicleModel._();

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  /// Get display name
  String get displayName => '$year $make $model';

  /// Convenience: backward compat for views using vehicle.owner
  String get owner => ownerId;

  /// Get full display with color
  String get fullDisplayName => '$year $color $make $model';
}
