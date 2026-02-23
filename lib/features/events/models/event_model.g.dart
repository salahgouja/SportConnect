// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventModel _$EventModelFromJson(Map json) => _EventModel(
  id: json['id'] as String,
  creatorId: json['creatorId'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  location: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['location'] as Map),
  ),
  startsAt: DateTime.parse(json['startsAt'] as String),
  endsAt: const TimestampConverter().fromJson(json['endsAt']),
  description: json['description'] as String?,
  venueName: json['venueName'] as String?,
  organizerName: json['organizerName'] as String?,
  imageUrl: json['imageUrl'] as String?,
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$EventModelToJson(_EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'title': instance.title,
      'type': _$EventTypeEnumMap[instance.type]!,
      'location': instance.location.toJson(),
      'startsAt': instance.startsAt.toIso8601String(),
      'endsAt': const TimestampConverter().toJson(instance.endsAt),
      'description': instance.description,
      'venueName': instance.venueName,
      'organizerName': instance.organizerName,
      'imageUrl': instance.imageUrl,
      'participantIds': instance.participantIds,
      'maxParticipants': instance.maxParticipants,
      'isActive': instance.isActive,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$EventTypeEnumMap = {
  EventType.football: 'football',
  EventType.basketball: 'basketball',
  EventType.volleyball: 'volleyball',
  EventType.tennis: 'tennis',
  EventType.running: 'running',
  EventType.gym: 'gym',
  EventType.swimming: 'swimming',
  EventType.cycling: 'cycling',
  EventType.hiking: 'hiking',
  EventType.yoga: 'yoga',
  EventType.martialArts: 'martial_arts',
  EventType.other: 'other',
};
