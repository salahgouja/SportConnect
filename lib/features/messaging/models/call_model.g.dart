// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallModel _$CallModelFromJson(Map json) => _CallModel(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  type: $enumDecode(_$CallTypeEnumMap, json['type']),
  callerId: json['callerId'] as String,
  callerName: json['callerName'] as String,
  callerPhotoUrl: json['callerPhotoUrl'] as String?,
  calleeId: json['calleeId'] as String,
  calleeName: json['calleeName'] as String,
  calleePhotoUrl: json['calleePhotoUrl'] as String?,
  status:
      $enumDecodeNullable(_$CallStatusEnumMap, json['status']) ??
      CallStatus.pending,
  channelName: json['channelName'] as String?,
  sessionId: json['sessionId'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  answeredAt: const TimestampConverter().fromJson(json['answeredAt']),
  endedAt: const TimestampConverter().fromJson(json['endedAt']),
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  endReason: json['endReason'] as String?,
);

Map<String, dynamic> _$CallModelToJson(_CallModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'type': _$CallTypeEnumMap[instance.type]!,
      'callerId': instance.callerId,
      'callerName': instance.callerName,
      'callerPhotoUrl': instance.callerPhotoUrl,
      'calleeId': instance.calleeId,
      'calleeName': instance.calleeName,
      'calleePhotoUrl': instance.calleePhotoUrl,
      'status': _$CallStatusEnumMap[instance.status]!,
      'channelName': instance.channelName,
      'sessionId': instance.sessionId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'answeredAt': const TimestampConverter().toJson(instance.answeredAt),
      'endedAt': const TimestampConverter().toJson(instance.endedAt),
      'duration': instance.duration,
      'endReason': instance.endReason,
    };

const _$CallTypeEnumMap = {CallType.voice: 'voice', CallType.video: 'video'};

const _$CallStatusEnumMap = {
  CallStatus.pending: 'pending',
  CallStatus.ringing: 'ringing',
  CallStatus.connecting: 'connecting',
  CallStatus.ongoing: 'ongoing',
  CallStatus.ended: 'ended',
  CallStatus.missed: 'missed',
  CallStatus.declined: 'declined',
  CallStatus.failed: 'failed',
};

_CallHistoryEntry _$CallHistoryEntryFromJson(Map json) => _CallHistoryEntry(
  id: json['id'] as String,
  type: $enumDecode(_$CallTypeEnumMap, json['type']),
  receiverId: json['receiverId'] as String,
  receiverName: json['receiverName'] as String,
  receiverPhotoUrl: json['receiverPhotoUrl'] as String?,
  isOutgoing: json['isOutgoing'] as bool,
  status: $enumDecode(_$CallStatusEnumMap, json['status']),
  duration: (json['duration'] as num).toInt(),
  timestamp: const TimestampConverter().fromJson(json['timestamp']),
);

Map<String, dynamic> _$CallHistoryEntryToJson(_CallHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CallTypeEnumMap[instance.type]!,
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'receiverPhotoUrl': instance.receiverPhotoUrl,
      'isOutgoing': instance.isOutgoing,
      'status': _$CallStatusEnumMap[instance.status]!,
      'duration': instance.duration,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };
