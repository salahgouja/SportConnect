import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Model for a hotspot location on the map
class Hotspot {
  final String id;
  final String name;
  final LatLng location;
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
      location: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
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
      'rideCount': rideCount,
      if (category != null) 'category': category,
      if (iconUrl != null) 'iconUrl': iconUrl,
    };
  }
}

/// Model for a nearby ride preview shown on the home map
class NearbyRidePreview {
  final String id;
  final LatLng origin;
  final String originAddress;
  final String destinationAddress;
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
    required this.originAddress,
    required this.destinationAddress,
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
    final origin = json['origin'] as Map<String, dynamic>?;
    final destination = json['destination'] as Map<String, dynamic>?;

    return NearbyRidePreview(
      id: id,
      origin: LatLng(
        (origin?['latitude'] as num?)?.toDouble() ?? 0.0,
        (origin?['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      originAddress: origin?['address'] ?? '',
      destinationAddress: destination?['address'] ?? '',
      driverName: json['driverName'] ?? 'Driver',
      driverPhotoUrl: json['driverPhotoUrl'],
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      availableSeats:
          ((json['availableSeats'] as num?)?.toInt() ?? 0) -
          ((json['bookedSeats'] as num?)?.toInt() ?? 0),
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
      departureTime: (json['departureTime'] as Timestamp).toDate(),
      isPremium: json['isPremium'] ?? false,
      isEco: json['isEco'] ?? true,
    );
  }
}
