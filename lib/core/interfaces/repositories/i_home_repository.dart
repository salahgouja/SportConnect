import 'package:latlong2/latlong.dart';
import 'package:sport_connect/features/home/models/home_models.dart';

abstract class IHomeRepository {
  /// Stream nearby active rides
  Stream<List<NearbyRidePreview>> streamNearbyRides({
    required LatLng center,
    double radiusKm = 50,
    int limit = 20,
  });

  /// Stream popular hotspots
  Stream<List<Hotspot>> streamHotspots({int limit = 10});

  /// Get hotspots near a location
  Future<List<Hotspot>> getHotspotsNearLocation(
    LatLng location, {
    double radiusKm = 10,
  });

  /// Increment hotspot ride count (called when a ride is created)
  Future<void> incrementHotspotCount(String hotspotId);

  /// Create a new hotspot
  Future<String> createHotspot(Hotspot hotspot);
}
