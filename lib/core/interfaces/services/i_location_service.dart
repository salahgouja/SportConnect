import 'package:geolocator/geolocator.dart';

/// Location service interface
abstract class ILocationService {
  // Permissions
  Future<bool> checkPermission();
  Future<bool> requestPermission();

  // Location Operations
  Future<Position?> getCurrentLocation();
  Stream<Position> getLocationStream();

  // Distance Calculations
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);

  // Geocoding
  Future<String?> getAddressFromCoordinates(double lat, double lon);
  Future<Position?> getCoordinatesFromAddress(String address);
}
