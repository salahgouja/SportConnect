import 'dart:async';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:sport_connect/core/services/talker_service.dart';

/// Map Service for Open Source Map Features
///
/// All features are FREE for commercial use worldwide
///
/// Open Source Services Used:
/// - OpenStreetMap (ODbL License) - Map tiles
/// - Nominatim (ODbL License) - Geocoding & Search
/// - OSRM (BSD License) - Routing
/// - Overpass API (ODbL License) - POI Search
class MapService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..addTalkerInterceptor();

  // ═══════════════════════════════════════════════════════════════
  // FREE MAP TILE PROVIDERS (Worldwide Coverage)
  // ═══════════════════════════════════════════════════════════════

  /// Available map styles - all free and open source
  static const Map<String, MapTileProvider> tileProviders = {
    'standard': MapTileProvider(
      name: 'OpenStreetMap Standard',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '© OpenStreetMap contributors',
      license: 'ODbL',
    ),
    'humanitarian': MapTileProvider(
      name: 'Humanitarian (HOT)',
      urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      attribution: '© OpenStreetMap contributors, Tiles by HOT',
      license: 'ODbL',
    ),
    'cycle': MapTileProvider(
      name: 'OpenCycleMap',
      urlTemplate: 'https://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      attribution: '© OpenStreetMap contributors, Tiles by Thunderforest',
      license: 'CC-BY-SA',
      requiresApiKey: true,
    ),
    'terrain': MapTileProvider(
      name: 'OpenTopoMap',
      urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
      attribution: '© OpenStreetMap contributors, SRTM, OpenTopoMap',
      license: 'CC-BY-SA',
    ),
    'dark': MapTileProvider(
      name: 'CartoDB Dark',
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
      attribution: '© OpenStreetMap contributors, © CARTO',
      license: 'CC-BY 3.0',
    ),
    'light': MapTileProvider(
      name: 'CartoDB Positron',
      urlTemplate:
          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      subdomains: ['a', 'b', 'c', 'd'],
      attribution: '© OpenStreetMap contributors, © CARTO',
      license: 'CC-BY 3.0',
    ),
    'watercolor': MapTileProvider(
      name: 'Stamen Watercolor',
      urlTemplate:
          'https://tiles.stadiamaps.com/tiles/stamen_watercolor/{z}/{x}/{y}.jpg',
      attribution: '© OpenStreetMap contributors, Map tiles by Stamen Design',
      license: 'CC-BY 3.0',
    ),
  };

  // ═══════════════════════════════════════════════════════════════
  // GEOCODING (Address Search) - Nominatim (Free, Unlimited, Worldwide)
  // ═══════════════════════════════════════════════════════════════

  /// Search for places by name (works everywhere)
  static Future<List<SearchResult>> searchPlaces(
    String query, {
    LatLng? nearLocation,
    String? countryCode,
    int limit = 10,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'format': 'json',
        'addressdetails': 1,
        'limit': limit,
        'accept-language': 'en,fr,ar', // Support English, French, Arabic
      };

      if (nearLocation != null) {
        params['lat'] = nearLocation.latitude;
        params['lon'] = nearLocation.longitude;
      }

      if (countryCode != null) {
        params['countrycodes'] = countryCode;
      }

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: params,
        options: Options(
          headers: {
            'User-Agent': 'SportConnect/1.0 (contact@sportconnect.app)',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => SearchResult.fromNominatim(item)).toList();
      }
      return [];
    } catch (e, stackTrace) {
      TalkerService.error('Place search failed', e, stackTrace);
      return [];
    }
  }

  /// Reverse geocode - get address from coordinates
  static Future<SearchResult?> reverseGeocode(LatLng location) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'format': 'json',
          'addressdetails': 1,
          'accept-language': 'en,fr,ar',
        },
        options: Options(
          headers: {
            'User-Agent': 'SportConnect/1.0 (contact@sportconnect.app)',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return SearchResult.fromNominatim(response.data);
      }
      return null;
    } catch (e, stackTrace) {
      TalkerService.error('Reverse geocode failed', e, stackTrace);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // POI SEARCH - Overpass API (Free, Unlimited, Worldwide)
  // ═══════════════════════════════════════════════════════════════

  /// Search for Points of Interest near a location
  /// Works perfectly in worldwide
  static Future<List<PointOfInterest>> searchPOI({
    required LatLng center,
    required double radiusMeters,
    required POIType type,
  }) async {
    try {
      final overpassQuery = _buildOverpassQuery(center, radiusMeters, type);

      final response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: overpassQuery,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final elements = response.data['elements'] as List<dynamic>? ?? [];
        return elements.map((e) => PointOfInterest.fromOverpass(e)).toList();
      }
      return [];
    } catch (e, stackTrace) {
      TalkerService.error('POI search failed', e, stackTrace);
      return [];
    }
  }

  static String _buildOverpassQuery(
    LatLng center,
    double radius,
    POIType type,
  ) {
    final lat = center.latitude;
    final lon = center.longitude;
    final tags = _getOverpassTags(type);

    return '''
[out:json][timeout:25];
(
  $tags(around:$radius,$lat,$lon);
);
out body;
>;
out skel qt;
''';
  }

  static String _getOverpassTags(POIType type) {
    switch (type) {
      case POIType.sportsFacility:
      case POIType.sportsCenter:
        return 'node["leisure"="sports_centre"]\n  node["leisure"="stadium"]\n  node["leisure"="pitch"]';
      case POIType.university:
        return 'node["amenity"="university"]\n  node["amenity"="college"]';
      case POIType.parking:
        return 'node["amenity"="parking"]';
      case POIType.gasStation:
        return 'node["amenity"="fuel"]';
      case POIType.restaurant:
        return 'node["amenity"="restaurant"]\n  node["amenity"="cafe"]';
      case POIType.cafe:
        return 'node["amenity"="cafe"]';
      case POIType.hospital:
        return 'node["amenity"="hospital"]\n  node["amenity"="clinic"]';
      case POIType.publicTransport:
        return 'node["highway"="bus_stop"]\n  node["railway"="station"]\n  node["railway"="tram_stop"]';
      case POIType.all:
        return 'node["amenity"]';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DISTANCE & BOUNDS CALCULATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Calculate distance between two points in kilometers
  static double calculateDistance(LatLng from, LatLng to) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  /// Calculate bounding box for a set of points
  static LatLngBounds getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }
    return LatLngBounds.fromPoints(points);
  }

  /// Get center point of bounds
  static LatLng getBoundsCenter(LatLngBounds bounds) {
    return bounds.center;
  }

  // ═══════════════════════════════════════════════════════════════
  // POPULAR LOCATIONS - France
  // ═══════════════════════════════════════════════════════════════

  /// Major cities in France
  static const List<PopularLocation> franceCities = [
    PopularLocation(name: 'Paris', location: LatLng(48.8566, 2.3522)),
    PopularLocation(name: 'Lyon', location: LatLng(45.7640, 4.8357)),
    PopularLocation(name: 'Marseille', location: LatLng(43.2965, 5.3698)),
    PopularLocation(name: 'Toulouse', location: LatLng(43.6047, 1.4442)),
    PopularLocation(name: 'Nice', location: LatLng(43.7102, 7.2620)),
    PopularLocation(name: 'Bordeaux', location: LatLng(44.8378, -0.5792)),
    PopularLocation(name: 'Lille', location: LatLng(50.6292, 3.0573)),
    PopularLocation(name: 'Strasbourg', location: LatLng(48.5734, 7.7521)),
    PopularLocation(name: 'Montpellier', location: LatLng(43.6108, 3.8767)),
    PopularLocation(name: 'Nantes', location: LatLng(47.2184, -1.5536)),
  ];
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════

/// Map tile provider configuration
class MapTileProvider {
  final String name;
  final String urlTemplate;
  final List<String>? subdomains;
  final String attribution;
  final String license;
  final bool requiresApiKey;

  const MapTileProvider({
    required this.name,
    required this.urlTemplate,
    this.subdomains,
    required this.attribution,
    required this.license,
    this.requiresApiKey = false,
  });
}

/// Search result from Nominatim
class SearchResult {
  final String placeId;
  final String displayName;
  final LatLng location;
  final String? addressType;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? road;
  final String? postcode;

  SearchResult({
    required this.placeId,
    required this.displayName,
    required this.location,
    this.addressType,
    this.city,
    this.country,
    this.countryCode,
    this.road,
    this.postcode,
  });

  factory SearchResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return SearchResult(
      placeId: json['place_id']?.toString() ?? '',
      displayName: json['display_name'] ?? '',
      location: LatLng(
        double.parse(json['lat']?.toString() ?? '0'),
        double.parse(json['lon']?.toString() ?? '0'),
      ),
      addressType: json['type'],
      city: address?['city'] ?? address?['town'] ?? address?['village'],
      country: address?['country'],
      countryCode: address?['country_code'],
      road: address?['road'],
      postcode: address?['postcode'],
    );
  }

  /// Get short display name (city, country)
  String get shortName {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return displayName.split(',').take(2).join(',');
  }
}

/// Point of Interest from Overpass
class PointOfInterest {
  final String id;
  final LatLng location;
  final String? name;
  final String? amenityType;
  final Map<String, String> tags;

  PointOfInterest({
    required this.id,
    required this.location,
    this.name,
    this.amenityType,
    required this.tags,
  });

  factory PointOfInterest.fromOverpass(Map<String, dynamic> json) {
    final tags = Map<String, String>.from(json['tags'] ?? {});
    return PointOfInterest(
      id: json['id']?.toString() ?? '',
      location: LatLng(
        (json['lat'] as num?)?.toDouble() ?? 0,
        (json['lon'] as num?)?.toDouble() ?? 0,
      ),
      name: tags['name'],
      amenityType: tags['amenity'] ?? tags['leisure'],
      tags: tags,
    );
  }
}

/// POI types for search
enum POIType {
  sportsFacility,
  sportsCenter, // Alias for sportsFacility
  university,
  parking,
  gasStation,
  restaurant,
  cafe,
  hospital,
  publicTransport,
  all,
}

/// Popular location preset
class PopularLocation {
  final String name;
  final LatLng location;

  const PopularLocation({required this.name, required this.location});
}
