// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleModel _$VehicleModelFromJson(Map json) => _VehicleModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  color: json['color'] as String,
  licensePlate: json['licensePlate'] as String,
  capacity: (json['capacity'] as num?)?.toInt() ?? 4,
  fuelType:
      $enumDecodeNullable(_$FuelTypeEnumMap, json['fuelType']) ??
      FuelType.gasoline,
  imageUrl: json['imageUrl'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? false,
  verificationStatus:
      $enumDecodeNullable(
        _$VehicleVerificationStatusEnumMap,
        json['verificationStatus'],
      ) ??
      VehicleVerificationStatus.pending,
  verificationNote: json['verificationNote'] as String?,
  registrationDocUrl: json['registrationDocUrl'] as String?,
  insuranceDocUrl: json['insuranceDocUrl'] as String?,
  insuranceExpiry: const TimestampConverter().fromJson(json['insuranceExpiry']),
  hasAC: json['hasAC'] as bool? ?? false,
  hasCharger: json['hasCharger'] as bool? ?? false,
  hasWifi: json['hasWifi'] as bool? ?? false,
  petsAllowed: json['petsAllowed'] as bool? ?? false,
  smokingAllowed: json['smokingAllowed'] as bool? ?? false,
  hasLuggage: json['hasLuggage'] as bool? ?? false,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$VehicleModelToJson(_VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'capacity': instance.capacity,
      'fuelType': _$FuelTypeEnumMap[instance.fuelType]!,
      'imageUrl': instance.imageUrl,
      'imageUrls': instance.imageUrls,
      'isActive': instance.isActive,
      'verificationStatus':
          _$VehicleVerificationStatusEnumMap[instance.verificationStatus]!,
      'verificationNote': instance.verificationNote,
      'registrationDocUrl': instance.registrationDocUrl,
      'insuranceDocUrl': instance.insuranceDocUrl,
      'insuranceExpiry': const TimestampConverter().toJson(
        instance.insuranceExpiry,
      ),
      'hasAC': instance.hasAC,
      'hasCharger': instance.hasCharger,
      'hasWifi': instance.hasWifi,
      'petsAllowed': instance.petsAllowed,
      'smokingAllowed': instance.smokingAllowed,
      'hasLuggage': instance.hasLuggage,
      'totalRides': instance.totalRides,
      'averageRating': instance.averageRating,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$FuelTypeEnumMap = {
  FuelType.gasoline: 'gasoline',
  FuelType.diesel: 'diesel',
  FuelType.electric: 'electric',
  FuelType.hybrid: 'hybrid',
  FuelType.pluginHybrid: 'pluginHybrid',
  FuelType.hydrogen: 'hydrogen',
  FuelType.other: 'other',
};

const _$VehicleVerificationStatusEnumMap = {
  VehicleVerificationStatus.pending: 'pending',
  VehicleVerificationStatus.verified: 'verified',
  VehicleVerificationStatus.rejected: 'rejected',
};
