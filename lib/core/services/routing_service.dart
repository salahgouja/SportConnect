import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/services/talker_service.dart';

/// Route model containing full route information from OSRM
class RouteInfo {
  final List<LatLng> coordinates;
  final double distanceMeters;
  final double durationSeconds;
  final String summary;
  final List<RouteStep> steps;
  final String? geometry;

  RouteInfo({
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.summary,
    required this.steps,
    this.geometry,
  });

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000;

  /// Duration in minutes
  double get durationMinutes => durationSeconds / 60;

  /// Formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${distanceMeters.toInt()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Formatted duration string
  String get formattedDuration {
    final minutes = durationMinutes.toInt();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

/// Individual step in a route with turn-by-turn instructions
class RouteStep {
  final String instruction;
  final String name;
  final double distanceMeters;
  final double durationSeconds;
  final String maneuverType;
  final String? maneuverModifier;
  final LatLng? location;

  RouteStep({
    required this.instruction,
    required this.name,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.maneuverType,
    this.maneuverModifier,
    this.location,
  });

  /// Get icon for this maneuver type
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

/// Service for routing using Project OSRM (Open Source Routing Machine)
/// Uses the free public demo server at router.project-osrm.org
class RoutingService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..addTalkerInterceptor();

  /// OSRM public demo server base URL
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Get a route between two points
  /// Returns null if no route can be found
  static Future<RouteInfo?> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String profile = 'driving', // driving, cycling, walking
    bool alternatives = false,
    bool steps = true,
    String geometries = 'geojson', // polyline, polyline6, geojson
    String overview = 'full', // full, simplified, false
  }) async {
    try {
      // Build coordinates string: origin;waypoint1;waypoint2;...;destination
      final coords = <String>[];
      coords.add('${origin.longitude},${origin.latitude}');

      if (waypoints != null) {
        for (final wp in waypoints) {
          coords.add('${wp.longitude},${wp.latitude}');
        }
      }

      coords.add('${destination.longitude},${destination.latitude}');

      final coordsString = coords.join(';');

      // Build URL
      final url = '$_baseUrl/route/v1/$profile/$coordsString';

      TalkerService.info('OSRM Route Request: $url');

      final response = await _dio.get(
        url,
        queryParameters: {
          'alternatives': alternatives.toString(),
          'steps': steps.toString(),
          'geometries': geometries,
          'overview': overview,
          'annotations': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          TalkerService.warning('OSRM returned code: ${data['code']}');
          return null;
        }

        final routes = data['routes'] as List;
        if (routes.isEmpty) {
          TalkerService.warning('No routes found');
          return null;
        }

        // Parse the first (best) route
        final route = routes[0];
        final routeInfo = _parseRoute(route, geometries);

        TalkerService.info(
          'Route found: ${routeInfo.formattedDistance}, ${routeInfo.formattedDuration}',
        );

        return routeInfo;
      } else {
        TalkerService.error(
          'OSRM request failed with status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      TalkerService.error('Failed to get route from OSRM', e, stackTrace);
      return null;
    }
  }

  /// Get routes with multiple alternatives
  static Future<List<RouteInfo>> getAlternativeRoutes({
    required LatLng origin,
    required LatLng destination,
    int maxAlternatives = 3,
    String profile = 'driving',
  }) async {
    try {
      final coordsString =
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}';

      final url = '$_baseUrl/route/v1/$profile/$coordsString';

      final response = await _dio.get(
        url,
        queryParameters: {
          'alternatives': maxAlternatives.toString(),
          'steps': 'true',
          'geometries': 'geojson',
          'overview': 'full',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          return [];
        }

        final routes = data['routes'] as List;
        return routes.map((r) => _parseRoute(r, 'geojson')).toList();
      }

      return [];
    } catch (e, stackTrace) {
      TalkerService.error('Failed to get alternative routes', e, stackTrace);
      return [];
    }
  }

  /// Get the nearest road to a point (snap to road network)
  static Future<LatLng?> getNearestRoad(LatLng point) async {
    try {
      final url =
          '$_baseUrl/nearest/v1/driving/${point.longitude},${point.latitude}';

      final response = await _dio.get(url, queryParameters: {'number': '1'});

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          return null;
        }

        final waypoints = data['waypoints'] as List;
        if (waypoints.isEmpty) {
          return null;
        }

        final location = waypoints[0]['location'] as List;
        return LatLng(location[1] as double, location[0] as double);
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Failed to get nearest road', e, stackTrace);
      return null;
    }
  }

  /// Get a distance/duration matrix between multiple points
  /// Useful for finding optimal pickup routes
  static Future<Map<String, dynamic>?> getDistanceMatrix({
    required List<LatLng> sources,
    required List<LatLng> destinations,
    String profile = 'driving',
  }) async {
    try {
      // Combine all points
      final allPoints = [...sources, ...destinations];
      final coordsString = allPoints
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      // Create source/destination indices
      final sourceIndices = List.generate(sources.length, (i) => i).join(';');
      final destIndices = List.generate(
        destinations.length,
        (i) => i + sources.length,
      ).join(';');

      final url = '$_baseUrl/table/v1/$profile/$coordsString';

      final response = await _dio.get(
        url,
        queryParameters: {
          'sources': sourceIndices,
          'destinations': destIndices,
          'annotations': 'distance,duration',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          return null;
        }

        return {
          'durations': data['durations'],
          'distances': data['distances'],
          'sources': data['sources'],
          'destinations': data['destinations'],
        };
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Failed to get distance matrix', e, stackTrace);
      return null;
    }
  }

  /// Match GPS points to road network (useful for tracking)
  static Future<RouteInfo?> matchToRoads({
    required List<LatLng> points,
    List<int>? timestamps,
    String profile = 'driving',
  }) async {
    try {
      if (points.length < 2) {
        return null;
      }

      final coordsString = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final url = '$_baseUrl/match/v1/$profile/$coordsString';

      final queryParams = <String, dynamic>{
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'true',
      };

      if (timestamps != null && timestamps.length == points.length) {
        queryParams['timestamps'] = timestamps.join(';');
      }

      final response = await _dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          return null;
        }

        final matchings = data['matchings'] as List;
        if (matchings.isEmpty) {
          return null;
        }

        return _parseRoute(matchings[0], 'geojson');
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Failed to match points to roads', e, stackTrace);
      return null;
    }
  }

  /// Solve traveling salesman problem for optimal route through multiple points
  static Future<RouteInfo?> getOptimalTrip({
    required List<LatLng> points,
    bool roundtrip = true,
    String profile = 'driving',
  }) async {
    try {
      if (points.length < 2) {
        return null;
      }

      final coordsString = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');

      final url = '$_baseUrl/trip/v1/$profile/$coordsString';

      final response = await _dio.get(
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
        final data = response.data;

        if (data['code'] != 'Ok') {
          return null;
        }

        final trips = data['trips'] as List;
        if (trips.isEmpty) {
          return null;
        }

        return _parseRoute(trips[0], 'geojson');
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Failed to calculate optimal trip', e, stackTrace);
      return null;
    }
  }

  /// Parse route from OSRM response
  static RouteInfo _parseRoute(Map<String, dynamic> route, String geometries) {
    // Parse coordinates from geometry
    List<LatLng> coordinates = [];

    if (geometries == 'geojson') {
      final geometry = route['geometry'];
      if (geometry != null && geometry['coordinates'] != null) {
        final coords = geometry['coordinates'] as List;
        coordinates = coords.map((c) {
          final coord = c as List;
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();
      }
    } else if (geometries == 'polyline' || geometries == 'polyline6') {
      // Decode polyline
      final polyline = route['geometry'] as String?;
      if (polyline != null) {
        coordinates = _decodePolyline(
          polyline,
          geometries == 'polyline6' ? 6 : 5,
        );
      }
    }

    // Parse steps
    final List<RouteStep> steps = [];
    final legs = route['legs'] as List?;
    if (legs != null) {
      for (final leg in legs) {
        final legSteps = leg['steps'] as List?;
        if (legSteps != null) {
          for (final step in legSteps) {
            final maneuver = step['maneuver'];
            LatLng? stepLocation;
            if (maneuver != null && maneuver['location'] != null) {
              final loc = maneuver['location'] as List;
              stepLocation = LatLng(loc[1] as double, loc[0] as double);
            }

            steps.add(
              RouteStep(
                instruction: _buildInstruction(step),
                name: step['name'] as String? ?? '',
                distanceMeters: (step['distance'] as num?)?.toDouble() ?? 0,
                durationSeconds: (step['duration'] as num?)?.toDouble() ?? 0,
                maneuverType: maneuver?['type'] as String? ?? '',
                maneuverModifier: maneuver?['modifier'] as String?,
                location: stepLocation,
              ),
            );
          }
        }
      }
    }

    // Build summary from leg names
    String summary = '';
    if (legs != null && legs.isNotEmpty) {
      summary = legs.first['summary'] as String? ?? '';
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

  /// Build human-readable instruction from step
  static String _buildInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'];
    if (maneuver == null) return '';

    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String?;
    final name = step['name'] as String? ?? '';

    String instruction = '';

    switch (type) {
      case 'depart':
        instruction = 'Start on $name'.trim();
        if (instruction == 'Start on') instruction = 'Start driving';
        break;
      case 'arrive':
        instruction = 'Arrive at destination';
        break;
      case 'turn':
        final direction = modifier ?? 'right';
        if (name.isNotEmpty) {
          instruction = 'Turn $direction onto $name';
        } else {
          instruction = 'Turn $direction';
        }
        break;
      case 'continue':
        if (name.isNotEmpty) {
          instruction = 'Continue on $name';
        } else {
          instruction = 'Continue straight';
        }
        break;
      case 'merge':
        instruction = 'Merge onto $name'.trim();
        break;
      case 'on ramp':
        instruction = 'Take the ramp';
        break;
      case 'off ramp':
        instruction = 'Take the exit';
        break;
      case 'fork':
        final direction = modifier ?? 'right';
        instruction = 'Keep $direction at the fork';
        break;
      case 'roundabout':
      case 'rotary':
        final exit = maneuver['exit'];
        if (exit != null) {
          instruction = 'Take exit $exit from the roundabout';
        } else {
          instruction = 'Enter the roundabout';
        }
        break;
      default:
        if (name.isNotEmpty) {
          instruction = 'Continue on $name';
        } else {
          instruction = 'Continue';
        }
    }

    return instruction;
  }

  /// Decode polyline to list of coordinates
  static List<LatLng> _decodePolyline(String encoded, int precision) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final double factor = precision == 6 ? 1e6 : 1e5;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      // Decode longitude
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

  /// Encode list of coordinates to polyline
  static String encodePolyline(List<LatLng> points, {int precision = 5}) {
    final double factor = precision == 6 ? 1e6 : 1e5;
    final StringBuffer encoded = StringBuffer();
    int prevLat = 0;
    int prevLng = 0;

    for (final point in points) {
      final int lat = (point.latitude * factor).round();
      final int lng = (point.longitude * factor).round();

      _encodeValue(lat - prevLat, encoded);
      _encodeValue(lng - prevLng, encoded);

      prevLat = lat;
      prevLng = lng;
    }

    return encoded.toString();
  }

  static void _encodeValue(int value, StringBuffer buffer) {
    int v = value < 0 ? ~(value << 1) : (value << 1);
    while (v >= 0x20) {
      buffer.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    buffer.writeCharCode(v + 63);
  }
}
