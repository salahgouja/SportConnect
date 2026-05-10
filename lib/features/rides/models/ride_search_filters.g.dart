// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_search_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideSearchFilters _$RideSearchFiltersFromJson(Map json) => _RideSearchFilters(
  origin: json['origin'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['origin'] as Map),
        ),
  destination: json['destination'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['destination'] as Map),
        ),
  departureDate: const TimestampConverter().fromJson(json['departureDate']),
  departureTimeFrom: const TimestampConverter().fromJson(
    json['departureTimeFrom'],
  ),
  departureTimeTo: const TimestampConverter().fromJson(json['departureTimeTo']),
  minSeats: (json['minSeats'] as num?)?.toInt() ?? 1,
  maxPrice: (json['maxPrice'] as num?)?.toInt(),
  allowPets: json['allowPets'] as bool? ?? false,
  allowSmoking: json['allowSmoking'] as bool? ?? false,
  womenOnly: json['womenOnly'] as bool? ?? false,
  minDriverRating: (json['minDriverRating'] as num?)?.toDouble(),
  sortBy: json['sortBy'] as String? ?? 'departure_time',
  sortAscending: json['sortAscending'] as bool? ?? true,
);

Map<String, dynamic> _$RideSearchFiltersToJson(
  _RideSearchFilters instance,
) => <String, dynamic>{
  'origin': instance.origin?.toJson(),
  'destination': instance.destination?.toJson(),
  'departureDate': const TimestampConverter().toJson(instance.departureDate),
  'departureTimeFrom': const TimestampConverter().toJson(
    instance.departureTimeFrom,
  ),
  'departureTimeTo': const TimestampConverter().toJson(
    instance.departureTimeTo,
  ),
  'minSeats': instance.minSeats,
  'maxPrice': instance.maxPrice,
  'allowPets': instance.allowPets,
  'allowSmoking': instance.allowSmoking,
  'womenOnly': instance.womenOnly,
  'minDriverRating': instance.minDriverRating,
  'sortBy': instance.sortBy,
  'sortAscending': instance.sortAscending,
};
