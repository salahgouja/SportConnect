// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideSchedule _$RideScheduleFromJson(Map json) => _RideSchedule(
  departureTime: const RequiredTimestampConverter().fromJson(
    json['departureTime'],
  ),
  arrivalTime: const TimestampConverter().fromJson(json['arrivalTime']),
  flexibilityMinutes: (json['flexibilityMinutes'] as num?)?.toInt() ?? 15,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringDays:
      (json['recurringDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  recurringEndDate: const TimestampConverter().fromJson(
    json['recurringEndDate'],
  ),
);

Map<String, dynamic> _$RideScheduleToJson(_RideSchedule instance) =>
    <String, dynamic>{
      'departureTime': const RequiredTimestampConverter().toJson(
        instance.departureTime,
      ),
      'arrivalTime': const TimestampConverter().toJson(instance.arrivalTime),
      'flexibilityMinutes': instance.flexibilityMinutes,
      'isRecurring': instance.isRecurring,
      'recurringDays': instance.recurringDays,
      'recurringEndDate': const TimestampConverter().toJson(
        instance.recurringEndDate,
      ),
    };
