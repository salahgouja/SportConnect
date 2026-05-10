// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RidePreferences _$RidePreferencesFromJson(Map json) => _RidePreferences(
  allowPets: json['allowPets'] as bool? ?? false,
  allowSmoking: json['allowSmoking'] as bool? ?? false,
  allowLuggage: json['allowLuggage'] as bool? ?? true,
  isWomenOnly: json['isWomenOnly'] as bool? ?? false,
);

Map<String, dynamic> _$RidePreferencesToJson(_RidePreferences instance) =>
    <String, dynamic>{
      'allowPets': instance.allowPets,
      'allowSmoking': instance.allowSmoking,
      'allowLuggage': instance.allowLuggage,
      'isWomenOnly': instance.isWomenOnly,
    };
