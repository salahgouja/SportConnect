import 'package:cloud_firestore/cloud_firestore.dart';
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

/// Model for a nearby ride preview shown on the home map
class NearbyRidePreview {
  final String id;
  final LocationPoint origin;
  final LocationPoint destination;
  final String driverName;
  final String? driverPhotoUrl;
  final double driverRating;
  final int availableSeats;
  final double pricePerSeat;
  final DateTime departureTime;
  final bool isPremium;
  final bool isEco;

  const NearbyRidePreview({
    required this.id,
    required this.origin,
    required this.destination,
    required this.driverName,
    this.driverPhotoUrl,
    this.driverRating = 0.0,
    this.availableSeats = 0,
    this.pricePerSeat = 0.0,
    required this.departureTime,
    this.isPremium = false,
    this.isEco = true,
  });

  factory NearbyRidePreview.fromJson(Map<String, dynamic> json, String id) {
    // RideModel uses composed sub-models → Firestore stores nested maps
    final routeMap = json['route'] as Map<String, dynamic>?;
    final scheduleMap = json['schedule'] as Map<String, dynamic>?;
    final capacityMap = json['capacity'] as Map<String, dynamic>?;
    final pricingMap = json['pricing'] as Map<String, dynamic>?;

    final origin = routeMap?['origin'] as Map<String, dynamic>?;
    final destination = routeMap?['destination'] as Map<String, dynamic>?;
    final pricePerSeatMap =
        pricingMap?['pricePerSeat'] as Map<String, dynamic>?;

    return NearbyRidePreview(
      id: id,
      origin: LocationPoint(
        latitude: (origin?['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (origin?['longitude'] as num?)?.toDouble() ?? 0.0,
        address: origin?['address'] ?? '',
        city: origin?['city'],
        country: origin?['country'],
        placeId: origin?['placeId'],
      ),
      destination: LocationPoint(
        latitude: (destination?['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (destination?['longitude'] as num?)?.toDouble() ?? 0.0,
        address: destination?['address'] ?? '',
        city: destination?['city'],
        country: destination?['country'],
        placeId: destination?['placeId'],
      ),
      driverName: json['driverName'] ?? 'Driver',
      driverPhotoUrl: json['driverPhotoUrl'],
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      availableSeats:
          ((capacityMap?['available'] as num?)?.toInt() ?? 0) -
          ((capacityMap?['booked'] as num?)?.toInt() ?? 0),
      pricePerSeat: (pricePerSeatMap?['amount'] as num?)?.toDouble() ?? 0.0,
      departureTime:
          (scheduleMap?['departureTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      isPremium: json['isPremium'] ?? false,
      isEco: json['isEco'] ?? true,
    );
  }
}
