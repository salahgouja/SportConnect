import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/interfaces/services/i_location_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'location_service.g.dart';

/// Injectable location service implementation
class LocationServiceImpl implements ILocationService {
  LocationServiceImpl._();

  static LocationServiceImpl? _instance;
  static LocationServiceImpl get instance {
    _instance ??= LocationServiceImpl._();
    return _instance!;
  }

  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      TalkerService.warning('Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Future<bool> requestPermission() async {
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

  /// LS-1: Returns true if the user has permanently denied location permission.
  /// The caller should show a manual address-entry fallback in this case, since
  /// `requestPermission()` cannot prompt the user again once denied-forever.
  @override
  Future<bool> isPermissionPermanentlyDenied() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  @override
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      TalkerService.info(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } on Exception catch (e) {
      TalkerService.error('Failed to get current position', e);
      return null;
    }
  }

  @override
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  @override
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  @override
  Future<String?> getAddressFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to get address from coordinates', e);
    }
    return null;
  }

  @override
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        // Convert Location to Position
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to get coordinates from address', e);
    }
    return null;
  }
}

/// Riverpod provider for location service
@riverpod
ILocationService locationService(Ref ref) {
  return LocationServiceImpl.instance;
}
