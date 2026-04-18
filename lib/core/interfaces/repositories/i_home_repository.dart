import 'package:latlong2/latlong.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

abstract class IHomeRepository {
  /// Stream nearby active rides
  Stream<List<RideModel>> streamNearbyRides({
    required LatLng center,
    double radiusKm = 50,
    int limit = 20,
  });
}
