import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:latlong2/latlong.dart';

/// Service for handling geolocation operations
class LocationService {
  /// Check and request location permissions
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      TalkerService.warning('Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        TalkerService.warning('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      TalkerService.error('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      TalkerService.info(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      TalkerService.error('Failed to get current position', e);
      return null;
    }
  }

  /// Get current LatLng
  static Future<LatLng?> getCurrentLatLng() async {
    Position? position = await getCurrentPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      TalkerService.error('Failed to get address from coordinates', e);
    }
    return null;
  }

  /// Get coordinates from address
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      TalkerService.error('Failed to get coordinates from address', e);
    }
    return null;
  }

  /// Calculate distance between two points (in kilometers)
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000; // Convert to kilometers
  }
}
