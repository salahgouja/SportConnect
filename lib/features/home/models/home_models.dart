import 'package:sport_connect/core/models/location/location_point.dart';

/// Model for a hotspot location on the map
class Hotspot {
  final String id;
  final String name;
  final LocationPoint location;
  final int rideCount;
  final String? category;
  final String? iconUrl;

  const Hotspot({
    required this.id,
    required this.name,
    required this.location,
    this.rideCount = 0,
    this.category,
    this.iconUrl,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json, String id) {
    return Hotspot(
      id: id,
      name: json['name'] ?? 'Location',
      location: LocationPoint(
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        address: json['address'] ?? '',
        city: json['city'],
        country: json['country'],
        placeId: json['placeId'],
      ),
      rideCount: (json['rideCount'] as num?)?.toInt() ?? 0,
      category: json['category'],
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      if (location.city != null) 'city': location.city,
      if (location.country != null) 'country': location.country,
      if (location.placeId != null) 'placeId': location.placeId,
      'rideCount': rideCount,
      if (category != null) 'category': category,
      if (iconUrl != null) 'iconUrl': iconUrl,
    };
  }
}
