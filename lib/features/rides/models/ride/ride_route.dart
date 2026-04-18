import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'ride_route.freezed.dart';
part 'ride_route.g.dart';

/// Route waypoint
@freezed
abstract class RouteWaypoint with _$RouteWaypoint {
  const factory RouteWaypoint({
    required LocationPoint location,
    @Default(0) int order,
    @TimestampConverter() DateTime? estimatedArrival,
  }) = _RouteWaypoint;

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) =>
      _$RouteWaypointFromJson(json);
}

/// Ride route information
@freezed
abstract class RideRoute with _$RideRoute {
  const factory RideRoute({
    required LocationPoint origin,
    required LocationPoint destination,
    @Default([]) List<RouteWaypoint> waypoints,
    double? distanceKm,
    int? durationMinutes,
    String? polylineEncoded,
  }) = _RideRoute;
  const RideRoute._();

  factory RideRoute.fromJson(Map<String, dynamic> json) =>
      _$RideRouteFromJson(json);

  /// Get formatted distance
  String get formattedDistance =>
      distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : 'N/A';

  /// Get formatted duration
  String get formattedDuration {
    if (durationMinutes == null) return 'N/A';
    final hours = durationMinutes! ~/ 60;
    final mins = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}
