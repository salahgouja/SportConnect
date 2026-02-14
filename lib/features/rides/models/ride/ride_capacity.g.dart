// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_capacity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideCapacity _$RideCapacityFromJson(Map json) => _RideCapacity(
  available: (json['available'] as num?)?.toInt() ?? 3,
  booked: (json['booked'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RideCapacityToJson(_RideCapacity instance) =>
    <String, dynamic>{
      'available': instance.available,
      'booked': instance.booked,
    };
