// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideRequestModel _$RideRequestModelFromJson(Map json) => _RideRequestModel(
  id: json['id'] as String,
  rideId: json['rideId'] as String,
  eventId: json['eventId'] as String?,
  eventName: json['eventName'] as String?,
  requesterId: json['requesterId'] as String,
  driverId: json['driverId'] as String,
  status: $enumDecode(_$RideRequestStatusEnumMap, json['status']),
  pickupLocation: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['pickupLocation'] as Map),
  ),
  dropoffLocation: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['dropoffLocation'] as Map),
  ),
  requestedSeats: (json['requestedSeats'] as num).toInt(),
  message: json['message'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  respondedAt: const TimestampConverter().fromJson(json['respondedAt']),
  expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
  metadata:
      (json['metadata'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ??
      const {},
  passengerName: json['passengerName'] as String?,
  passengerPhotoUrl: json['passengerPhotoUrl'] as String?,
  passengerRating: (json['passengerRating'] as num?)?.toDouble() ?? 0.0,
  pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$RideRequestModelToJson(_RideRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rideId': instance.rideId,
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'requesterId': instance.requesterId,
      'driverId': instance.driverId,
      'status': _$RideRequestStatusEnumMap[instance.status]!,
      'pickupLocation': instance.pickupLocation.toJson(),
      'dropoffLocation': instance.dropoffLocation.toJson(),
      'requestedSeats': instance.requestedSeats,
      'message': instance.message,
      'rejectionReason': instance.rejectionReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'respondedAt': const TimestampConverter().toJson(instance.respondedAt),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
      'metadata': instance.metadata,
      'passengerName': instance.passengerName,
      'passengerPhotoUrl': instance.passengerPhotoUrl,
      'passengerRating': instance.passengerRating,
      'pricePerSeat': instance.pricePerSeat,
    };

const _$RideRequestStatusEnumMap = {
  RideRequestStatus.pending: 'pending',
  RideRequestStatus.accepted: 'accepted',
  RideRequestStatus.rejected: 'rejected',
  RideRequestStatus.cancelled: 'cancelled',
  RideRequestStatus.expired: 'expired',
};
