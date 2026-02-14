import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Map service interface
abstract class IMapService {
  // Map Configuration
  Future<void> initialize();

  // Route Planning
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination);
  Future<double> getRouteDistance(LatLng origin, LatLng destination);
  Future<Duration> getRouteDuration(LatLng origin, LatLng destination);

  // Markers & UI
  Future<List<Marker>> createMarkersForPoints(List<LatLng> points);
}
