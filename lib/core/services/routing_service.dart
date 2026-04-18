import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/http_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'routing_service.g.dart';

/// Route model containing full route information from OSRM
class RouteInfo {
  RouteInfo({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.summary,
    required this.steps,
    this.geometry,
  });
  final List<LatLng> coordinates;
  final double distanceMeters;
  final double durationSeconds;
  final String summary;
  final List<RouteStep> steps;
  final String? geometry;

  double get distanceKm => distanceMeters / 1000;
  double get durationMinutes => durationSeconds / 60;

  String get formattedDistance {
    if (distanceKm < 1) return '${distanceMeters.toInt()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = durationMinutes.toInt();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

/// Individual step in a route with turn-by-turn instructions
class RouteStep {
  RouteStep({
    required this.instruction,
    required this.name,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.maneuverType,
    this.maneuverModifier,
    this.location,
  });
  final String instruction;
  final String name;
  final double distanceMeters;
  final double durationSeconds;
  final String maneuverType;
  final String? maneuverModifier;
  final LatLng? location;

  String get maneuverIcon {
    switch (maneuverType) {
      case 'turn':
        switch (maneuverModifier) {
          case 'left':
            return '↰';
          case 'right':
            return '↱';
          case 'slight left':
            return '↖';
          case 'slight right':
            return '↗';
          case 'sharp left':
            return '⬅';
          case 'sharp right':
            return '➡';
          case 'uturn':
            return '↩';
          default:
            return '→';
        }
      case 'depart':
        return '🚗';
      case 'arrive':
        return '🏁';
      case 'merge':
        return '⤵';
      case 'on ramp':
      case 'off ramp':
        return '⤴';
      case 'fork':
        return '⑂';
      case 'roundabout':
      case 'rotary':
        return '🔄';
      case 'continue':
        return '⬆';
      default:
        return '→';
    }
  }
}

/// Injectable routing service using OSRM (Open Source Routing Machine).
///
/// Obtain via [routingServiceProvider] — do not construct directly.
class RoutingService {
  RoutingService(this._dio);

  final Dio _dio;

  static const int _maxCacheSize = 20;
  static final Map<String, RouteInfo> _routeCache = <String, RouteInfo>{};

  static String _routeCacheKey({
    required LatLng origin,
    required LatLng destination,
    required String profile,
    List<LatLng>? waypoints,
  }) {
    final buf = StringBuffer()
      ..write(origin.latitude.toStringAsFixed(5))
      ..write(',')
      ..write(origin.longitude.toStringAsFixed(5));
    if (waypoints != null) {
      for (final wp in waypoints) {
        buf
          ..write(';')
          ..write(wp.latitude.toStringAsFixed(5))
          ..write(',')
          ..write(wp.longitude.toStringAsFixed(5));
      }
    }
    buf
      ..write(';')
      ..write(destination.latitude.toStringAsFixed(5))
      ..write(',')
      ..write(destination.longitude.toStringAsFixed(5))
      ..write('|')
      ..write(profile);
    return buf.toString();
  }

  void clearRouteCache() => _routeCache.clear();

  Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String profile = 'driving',
    bool alternatives = false,
    bool steps = true,
    String geometries = 'geojson',
    String overview = 'full',
  }) async {
    final cacheKey = _routeCacheKey(
      origin: origin,
      destination: destination,
      waypoints: waypoints,
      profile: profile,
    );
    final cached = _routeCache[cacheKey];
    if (cached != null) {
      TalkerService.info('OSRM Route cache hit: $cacheKey');
      return cached;
    }

    try {
      final coords = <String>[];
      coords.add('${origin.longitude},${origin.latitude}');
      if (waypoints != null) {
        for (final wp in waypoints) {
          coords.add('${wp.longitude},${wp.latitude}');
        }
      }
      coords.add('${destination.longitude},${destination.latitude}');

      final url =
          '${AppConstants.osrmBaseUrl}/route/v1/$profile/${coords.join(';')}';

      TalkerService.info('OSRM Route Request: $url');

      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'alternatives': alternatives.toString(),
          'steps': steps.toString(),
          'geometries': geometries,
          'overview': overview,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') {
          TalkerService.warning('OSRM returned code: ${data['code']}');
          return null;
        }
        final routes = data['routes'] as List;
        if (routes.isEmpty) {
          TalkerService.warning('No routes found');
          return null;
        }
        final routeInfo = _parseRoute(
          routes[0] as Map<String, dynamic>,
          geometries,
        );
        TalkerService.info(
          'Route found: ${routeInfo.formattedDistance}, ${routeInfo.formattedDuration}',
        );
        if (_routeCache.length >= _maxCacheSize) {
          _routeCache.remove(_routeCache.keys.first);
        }
        _routeCache[cacheKey] = routeInfo;
        return routeInfo;
      }
      TalkerService.error(
        'OSRM request failed with status: ${response.statusCode}',
      );
      return null;
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to get route from OSRM', e, stackTrace);
      return null;
    }
  }

  Future<List<RouteInfo>> getAlternativeRoutes({
    required LatLng origin,
    required LatLng destination,
    int maxAlternatives = 3,
    String profile = 'driving',
  }) async {
    try {
      final coordsString =
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}';
      final url = '${AppConstants.osrmBaseUrl}/route/v1/$profile/$coordsString';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'alternatives': maxAlternatives.toString(),
          'steps': 'true',
          'geometries': 'geojson',
          'overview': 'full',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') return [];
        final routes = data['routes'] as List;
        return routes
            .map((r) => _parseRoute(r as Map<String, dynamic>, 'geojson'))
            .toList();
      }
      return [];
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to get alternative routes', e, stackTrace);
      return [];
    }
  }

  Future<LatLng?> getNearestRoad(LatLng point) async {
    try {
      final url =
          '${AppConstants.osrmBaseUrl}/nearest/v1/driving/'
          '${point.longitude},${point.latitude}';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {'number': '1'},
      );
      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') return null;
        final waypoints = data['waypoints'] as List;
        if (waypoints.isEmpty) return null;
        final location = waypoints[0]['location'] as List;
        return LatLng(location[1] as double, location[0] as double);
      }
      return null;
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to get nearest road', e, stackTrace);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDistanceMatrix({
    required List<LatLng> sources,
    required List<LatLng> destinations,
    String profile = 'driving',
  }) async {
    try {
      final allPoints = [...sources, ...destinations];
      final coordsString = allPoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final sourceIndices = List.generate(sources.length, (i) => i).join(';');
      final destIndices = List.generate(
        destinations.length,
        (i) => i + sources.length,
      ).join(';');
      final url = '${AppConstants.osrmBaseUrl}/table/v1/$profile/$coordsString';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'sources': sourceIndices,
          'destinations': destIndices,
          'annotations': 'distance,duration',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') return null;
        return {
          'durations': data['durations'],
          'distances': data['distances'],
          'sources': data['sources'],
          'destinations': data['destinations'],
        };
      }
      return null;
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to get distance matrix', e, stackTrace);
      return null;
    }
  }

  Future<RouteInfo?> matchToRoads({
    required List<LatLng> points,
    List<int>? timestamps,
    String profile = 'driving',
  }) async {
    try {
      if (points.length < 2) return null;
      final coordsString = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final url = '${AppConstants.osrmBaseUrl}/match/v1/$profile/$coordsString';
      final queryParams = <String, dynamic>{
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'true',
      };
      if (timestamps != null && timestamps.length == points.length) {
        queryParams['timestamps'] = timestamps.join(';');
      }
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') return null;
        final matchings = data['matchings'] as List;
        if (matchings.isEmpty) return null;
        return _parseRoute(matchings[0] as Map<String, dynamic>, 'geojson');
      }
      return null;
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to match points to roads', e, stackTrace);
      return null;
    }
  }

  Future<RouteInfo?> getOptimalTrip({
    required List<LatLng> points,
    bool roundtrip = true,
    String profile = 'driving',
  }) async {
    try {
      if (points.length < 2) return null;
      final coordsString = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final url = '${AppConstants.osrmBaseUrl}/trip/v1/$profile/$coordsString';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'roundtrip': roundtrip.toString(),
          'source': 'first',
          'destination': 'last',
          'geometries': 'geojson',
          'overview': 'full',
          'steps': 'true',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data!;
        if (data['code'] != 'Ok') return null;
        final trips = data['trips'] as List;
        if (trips.isEmpty) return null;
        return _parseRoute(trips[0] as Map<String, dynamic>, 'geojson');
      }
      return null;
    } on Exception catch (e, stackTrace) {
      TalkerService.error('Failed to calculate optimal trip', e, stackTrace);
      return null;
    }
  }

  RouteInfo _parseRoute(Map<String, dynamic> route, String geometries) {
    var coordinates = <LatLng>[];
    if (geometries == 'geojson') {
      final geometry = route['geometry'] as Map<String, dynamic>?;
      if (geometry != null && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'] as List;
        coordinates = coords.map((c) {
          final coord = c as List;
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();
      }
    } else if (geometries == 'polyline' || geometries == 'polyline6') {
      final polyline = route['geometry'] as String?;
      if (polyline != null) {
        coordinates = decodePolyline(
          polyline,
          geometries == 'polyline6' ? 6 : 5,
        );
      }
    }

    final steps = <RouteStep>[];
    final legs = route['legs'] as List?;
    if (legs != null) {
      for (final leg in legs) {
        final legMap = leg as Map<String, dynamic>;
        final legSteps = legMap['steps'] as List?;
        if (legSteps != null) {
          for (final step in legSteps) {
            final stepMap = step as Map<String, dynamic>;
            final maneuver = stepMap['maneuver'] as Map<String, dynamic>?;
            LatLng? stepLocation;
            if (maneuver != null && maneuver['location'] != null) {
              final loc = maneuver['location'] as List;
              stepLocation = LatLng(loc[1] as double, loc[0] as double);
            }
            steps.add(
              RouteStep(
                instruction: _buildInstruction(stepMap),
                name: stepMap['name'] as String? ?? '',
                distanceMeters: (stepMap['distance'] as num?)?.toDouble() ?? 0,
                durationSeconds: (stepMap['duration'] as num?)?.toDouble() ?? 0,
                maneuverType: maneuver?['type'] as String? ?? '',
                maneuverModifier: maneuver?['modifier'] as String?,
                location: stepLocation,
              ),
            );
          }
        }
      }
    }

    var summary = '';
    if (legs != null && legs.isNotEmpty) {
      summary =
          (legs.first as Map<String, dynamic>)['summary'] as String? ?? '';
    }

    return RouteInfo(
      coordinates: coordinates,
      distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      summary: summary,
      steps: steps,
      geometry: geometries != 'geojson' ? route['geometry'] as String? : null,
    );
  }

  String _buildInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] as Map<String, dynamic>?;
    if (maneuver == null) return '';
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String?;
    final name = step['name'] as String? ?? '';

    switch (type) {
      case 'depart':
        final s = 'Start on $name'.trim();
        return s == 'Start on' ? 'Start driving' : s;
      case 'arrive':
        return 'Arrive at destination';
      case 'turn':
        final direction = modifier ?? 'right';
        return name.isNotEmpty
            ? 'Turn $direction onto $name'
            : 'Turn $direction';
      case 'continue':
        return name.isNotEmpty ? 'Continue on $name' : 'Continue straight';
      case 'merge':
        return 'Merge onto $name'.trim();
      case 'on ramp':
        return 'Take the ramp';
      case 'off ramp':
        return 'Take the exit';
      case 'fork':
        return 'Keep ${modifier ?? 'right'} at the fork';
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'];
        return exit != null
            ? 'Take exit $exit from the roundabout'
            : 'Enter the roundabout';
      default:
        return name.isNotEmpty ? 'Continue on $name' : 'Continue';
    }
  }

  static List<LatLng> decodePolyline(String encoded, int precision) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;
    final factor = precision == 6 ? 1e6 : 1e5;
    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      points.add(LatLng(lat / factor, lng / factor));
    }
    return points;
  }

  static String encodePolyline(List<LatLng> points, {int precision = 5}) {
    final factor = precision == 6 ? 1e6 : 1e5;
    final encoded = StringBuffer();
    var prevLat = 0;
    var prevLng = 0;
    for (final point in points) {
      final lat = (point.latitude * factor).round();
      final lng = (point.longitude * factor).round();
      _encodeValue(lat - prevLat, encoded);
      _encodeValue(lng - prevLng, encoded);
      prevLat = lat;
      prevLng = lng;
    }
    return encoded.toString();
  }

  static void _encodeValue(int value, StringBuffer buffer) {
    var v = value < 0 ? ~(value << 1) : (value << 1);
    while (v >= 0x20) {
      buffer.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    buffer.writeCharCode(v + 63);
  }
}

@Riverpod(keepAlive: true)
RoutingService routingService(Ref ref) {
  return RoutingService(ref.watch(httpServiceProvider).dio);
}
