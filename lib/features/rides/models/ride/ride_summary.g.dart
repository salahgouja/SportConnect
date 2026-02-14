// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideSummary _$RideSummaryFromJson(Map json) => _RideSummary(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  originAddress: json['originAddress'] as String,
  destinationAddress: json['destinationAddress'] as String,
  departureTime: const RequiredTimestampConverter().fromJson(
    json['departureTime'],
  ),
  formattedPrice: json['formattedPrice'] as String,
  seatsAvailable: (json['seatsAvailable'] as num).toInt(),
  isBookable: json['isBookable'] as bool,
);

Map<String, dynamic> _$RideSummaryToJson(_RideSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'departureTime': const RequiredTimestampConverter().toJson(
        instance.departureTime,
      ),
      'formattedPrice': instance.formattedPrice,
      'seatsAvailable': instance.seatsAvailable,
      'isBookable': instance.isBookable,
    };

_RideDetailState _$RideDetailStateFromJson(Map json) => _RideDetailState(
  id: json['id'] as String,
  driverId: json['driverId'] as String?,
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
  departureTime: const TimestampConverter().fromJson(json['departureTime']),
  formattedPrice: json['formattedPrice'] as String?,
  seatsAvailable: (json['seatsAvailable'] as num?)?.toInt(),
  activeBookings:
      (json['activeBookings'] as List<dynamic>?)
          ?.map(
            (e) => RideBooking.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  pendingRequestsCount: (json['pendingRequestsCount'] as num?)?.toInt() ?? 0,
  canBook: json['canBook'] as bool? ?? false,
  isLoading: json['isLoading'] as bool? ?? false,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$RideDetailStateToJson(
  _RideDetailState instance,
) => <String, dynamic>{
  'id': instance.id,
  'driverId': instance.driverId,
  'origin': instance.origin?.toJson(),
  'destination': instance.destination?.toJson(),
  'departureTime': const TimestampConverter().toJson(instance.departureTime),
  'formattedPrice': instance.formattedPrice,
  'seatsAvailable': instance.seatsAvailable,
  'activeBookings': instance.activeBookings.map((e) => e.toJson()).toList(),
  'pendingRequestsCount': instance.pendingRequestsCount,
  'canBook': instance.canBook,
  'isLoading': instance.isLoading,
  'errorMessage': instance.errorMessage,
};
