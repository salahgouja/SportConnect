// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RouteWaypoint _$RouteWaypointFromJson(Map json) => _RouteWaypoint(
  location: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['location'] as Map),
  ),
  order: (json['order'] as num?)?.toInt() ?? 0,
  estimatedArrival: const TimestampConverter().fromJson(
    json['estimatedArrival'],
  ),
);

Map<String, dynamic> _$RouteWaypointToJson(_RouteWaypoint instance) =>
    <String, dynamic>{
      'location': instance.location.toJson(),
      'order': instance.order,
      'estimatedArrival': const TimestampConverter().toJson(
        instance.estimatedArrival,
      ),
    };

_RideRoute _$RideRouteFromJson(Map json) => _RideRoute(
  origin: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['origin'] as Map),
  ),
  destination: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['destination'] as Map),
  ),
  waypoints:
      (json['waypoints'] as List<dynamic>?)
          ?.map(
            (e) => RouteWaypoint.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  polylineEncoded: json['polylineEncoded'] as String?,
);

Map<String, dynamic> _$RideRouteToJson(_RideRoute instance) =>
    <String, dynamic>{
      'origin': instance.origin.toJson(),
      'destination': instance.destination.toJson(),
      'waypoints': instance.waypoints.map((e) => e.toJson()).toList(),
      'distanceKm': instance.distanceKm,
      'durationMinutes': instance.durationMinutes,
      'polylineEncoded': instance.polylineEncoded,
    };
