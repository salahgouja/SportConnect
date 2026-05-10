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
  ownerName: json['ownerName'] as String? ?? 'Unknown',
  ownerPhotoUrl: json['ownerPhotoUrl'] as String?,
  capacity: (json['capacity'] as num?)?.toInt() ?? 4,
  imageUrl: json['imageUrl'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? false,
  isDefault: json['isDefault'] as bool? ?? false,
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
      'ownerName': instance.ownerName,
      'ownerPhotoUrl': instance.ownerPhotoUrl,
      'capacity': instance.capacity,
      'imageUrl': instance.imageUrl,
      'imageUrls': instance.imageUrls,
      'isActive': instance.isActive,
      'isDefault': instance.isDefault,
      'totalRides': instance.totalRides,
      'averageRating': instance.averageRating,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
