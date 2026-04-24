import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/clients/nominatim_client.dart';
import 'package:sport_connect/core/services/http_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'map_service.g.dart';

/// Injectable map service using free OSM-based APIs.
///
/// Obtain via [mapServiceProvider] — do not construct directly.
class MapService {
  MapService(this._dio)
    : _nominatimClient = NominatimClient(
        _dio,
        baseUrl: AppConstants.nominatimBaseUrl,
      );

  final Dio _dio;
  final NominatimClient _nominatimClient;

  // ═══════════════════════════════════════════════════════════════
  // MAP TILE PROVIDERS
  // ═══════════════════════════════════════════════════════════════

  static const MapTileProvider standardTileProvider = MapTileProvider(
    name: 'OpenStreetMap Standard',
    urlTemplate: AppConstants.osmStandardTileUrl,
    attribution: '© OpenStreetMap contributors',
    license: 'ODbL',
  );

  // ═══════════════════════════════════════════════════════════════
  // GEOCODING — Nominatim
  // ═══════════════════════════════════════════════════════════════

  Future<List<SearchResult>> searchPlaces(
    String query, {
    LatLng? nearLocation,
    String? countryCode,
    int limit = 10,
  }) async {
    try {
      final data = await _nominatimClient.searchPlaces(
        query,
        'json',
        1,
        limit,
        'en,fr,ar',
        nearLocation?.latitude,
        nearLocation?.longitude,
        countryCode,
        AppConstants.userAgent,
      );
      return data.map((item) => SearchResult.fromNominatim(item.json)).toList();
    } catch (e, st) {
      TalkerService.error('Place search failed', e, st);
      return [];
    }
  }

  Future<SearchResult?> reverseGeocode(LatLng location) async {
    try {
      final data = await _nominatimClient.reverseGeocode(
        location.latitude,
        location.longitude,
        'json',
        1,
        'en,fr,ar',
        AppConstants.userAgent,
      );
      return SearchResult.fromNominatim(data.json);
    } catch (e, st) {
      TalkerService.error('Reverse geocode failed', e, st);
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // POI SEARCH — Overpass API
  // ═══════════════════════════════════════════════════════════════

  Future<List<PointOfInterest>> searchPOI({
    required LatLng center,
    required double radiusMeters,
    required POIType type,
  }) async {
    try {
      final overpassQuery = _buildOverpassQuery(center, radiusMeters, type);
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.overpassApiUrl,
        data: overpassQuery,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      if (response.statusCode == 200) {
        final elements = response.data!['elements'] as List<dynamic>? ?? [];
        return elements
            .map((e) => PointOfInterest.fromOverpass(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, st) {
      TalkerService.error('POI search failed', e, st);
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

  static double calculateDistance(LatLng from, LatLng to) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  static LatLngBounds getBounds(List<LatLng> points) {
    if (points.isEmpty) throw ArgumentError('Points list cannot be empty');
    return LatLngBounds.fromPoints(points);
  }

  static LatLng getBoundsCenter(LatLngBounds bounds) => bounds.center;

  // ═══════════════════════════════════════════════════════════════
  // POPULAR LOCATIONS
  // ═══════════════════════════════════════════════════════════════

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

class MapTileProvider {
  const MapTileProvider({
    required this.name,
    required this.urlTemplate,
    required this.attribution,
    required this.license,
    this.subdomains,
    this.requiresApiKey = false,
  });
  final String name;
  final String urlTemplate;
  final List<String>? subdomains;
  final String attribution;
  final String license;
  final bool requiresApiKey;
}

class SearchResult {
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
      displayName: json['display_name'] as String? ?? '',
      location: LatLng(
        double.parse(json['lat']?.toString() ?? '0'),
        double.parse(json['lon']?.toString() ?? '0'),
      ),
      addressType: json['type'] as String?,
      city:
          address?['city'] as String? ??
          address?['town'] as String? ??
          address?['village'] as String?,
      country: address?['country'] as String?,
      countryCode: address?['country_code'] as String?,
      road: address?['road'] as String?,
      postcode: address?['postcode'] as String?,
    );
  }

  final String placeId;
  final String displayName;
  final LatLng location;
  final String? addressType;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? road;
  final String? postcode;

  String get shortName {
    if (city != null && country != null) return '$city, $country';
    return displayName.split(',').take(2).join(',');
  }
}

class PointOfInterest {
  PointOfInterest({
    required this.id,
    required this.location,
    required this.tags,
    this.name,
    this.amenityType,
  });

  factory PointOfInterest.fromOverpass(Map<String, dynamic> json) {
    final tags = Map<String, String>.from(
      (json['tags'] as Map<String, dynamic>?) ?? {},
    );
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

  final String id;
  final LatLng location;
  final String? name;
  final String? amenityType;
  final Map<String, String> tags;
}

enum POIType {
  sportsFacility,
  sportsCenter,
  university,
  parking,
  gasStation,
  restaurant,
  cafe,
  hospital,
  publicTransport,
  all,
}

class PopularLocation {
  const PopularLocation({required this.name, required this.location});
  final String name;
  final LatLng location;
}

@Riverpod(keepAlive: true)
MapService mapService(Ref ref) {
  return MapService(ref.watch(httpServiceProvider).dio);
}
