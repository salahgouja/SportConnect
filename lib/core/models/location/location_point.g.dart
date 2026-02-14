// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationPoint _$LocationPointFromJson(Map json) => _LocationPoint(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String,
  city: json['city'] as String?,
  country: json['country'] as String?,
  placeId: json['placeId'] as String?,
);

Map<String, dynamic> _$LocationPointToJson(_LocationPoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'country': instance.country,
      'placeId': instance.placeId,
    };
