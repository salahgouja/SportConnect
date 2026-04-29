import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/firebase_options.dart';

enum ActiveRideGeofenceRole { driver, passenger }

class ActiveRideGeofenceService {
  ActiveRideGeofenceService._();

  static final ActiveRideGeofenceService instance =
      ActiveRideGeofenceService._();

  static const String _idPrefix = 'sc';
  static const double _pickupRadiusMeters = 150;
  static const double _destinationRadiusMeters = 180;
  static const Duration _expiration = Duration(hours: 18);
  static const Duration _loiteringDelay = Duration(minutes: 2);
  static const Duration _notificationResponsiveness = Duration(seconds: 30);

  final Map<String, String> _activeSignatures = <String, String>{};
  Future<void>? _initializeOperation;

  Future<bool> syncForRide({
    required ActiveRideGeofenceRole role,
    required RideModel ride,
    required List<RideBooking> bookings,
    String? passengerId,
  }) async {
    // native_geofence requires the location background mode in UIBackgroundModes
    // on iOS, which was intentionally removed — geofencing is Android-only.
    if (!Platform.isAndroid) return false;

    if (!_shouldMonitor(ride.status)) {
      await clearRideGeofences(ride.id);
      return false;
    }

    final geofences = _buildGeofences(
      role: role,
      ride: ride,
      bookings: bookings,
      passengerId: passengerId,
    );
    if (geofences.isEmpty) return false;

    final signatureKey = '${ride.id}:${role.name}';
    final signature = _signatureFor(geofences);
    if (_activeSignatures[signatureKey] == signature) {
      return true;
    }

    try {
      final ready = await _ensureReady();
      if (!ready) return false;

      final manager = NativeGeofenceManager.instance;
      final registeredIds = await manager.getRegisteredGeofenceIds();
      final desiredIds = geofences.map((g) => g.id).toSet();

      await Future.wait(
        registeredIds
            .where((id) => id.startsWith('$_idPrefix|${ride.id}|'))
            .where((id) => !desiredIds.contains(id))
            .map(manager.removeGeofenceById),
      );

      for (final geofence in geofences) {
        await manager.createGeofence(
          geofence,
          activeRideGeofenceTriggered,
        );
      }

      _activeSignatures[signatureKey] = signature;
      return true;
    } on NativeGeofenceException catch (e, st) {
      debugPrint('Active ride geofence sync failed: ${e.code.name}');
      debugPrintStack(stackTrace: st);
      return false;
    } catch (e, st) {
      debugPrint('Active ride geofence sync failed: $e');
      debugPrintStack(stackTrace: st);
      return false;
    }
  }

  Future<void> clearRideGeofences(String rideId) async {
    if (rideId.isEmpty || !Platform.isAndroid) return;

    _activeSignatures.removeWhere((key, _) => key.startsWith('$rideId:'));

    try {
      await _ensureInitialized();
      final manager = NativeGeofenceManager.instance;
      final registeredIds = await manager.getRegisteredGeofenceIds();
      await Future.wait(
        registeredIds
            .where((id) => id.startsWith('$_idPrefix|$rideId|'))
            .map(manager.removeGeofenceById),
      );
    } catch (e) {
      debugPrint('Active ride geofence cleanup skipped: $e');
    }
  }

  // Requests background ("always") location permission on Android. Call this
  // from a UI context after showing the user a rationale.
  static Future<bool> requestBackgroundPermission() async {
    if (!Platform.isAndroid) return false;
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  Future<bool> _ensureReady() async {
    final location = await Permission.location.status;
    if (!location.isGranted) return false;

    // Check (don't request) — requesting locationAlways here would silently
    // open OS Settings mid-ride on Android 11+. The explicit request is done
    // in the active-ride screen init flow with a rationale dialog.
    final always = await Permission.locationAlways.status;
    if (!always.isGranted) return false;

    try {
      await _ensureInitialized();
    } on Object catch (e, st) {
      debugPrint('Geofence manager init failed: $e');
      debugPrintStack(stackTrace: st);
      return false;
    }
    return true;
  }

  Future<void> _ensureInitialized() {
    final existing = _initializeOperation;
    if (existing != null) return existing;

    final operation = NativeGeofenceManager.instance.initialize();
    _initializeOperation = operation;
    return operation.whenComplete(() {
      if (identical(_initializeOperation, operation)) {
        _initializeOperation = null;
      }
    });
  }

  bool _shouldMonitor(RideStatus status) {
    return status == RideStatus.active ||
        status == RideStatus.full ||
        status == RideStatus.inProgress;
  }

  List<Geofence> _buildGeofences({
    required ActiveRideGeofenceRole role,
    required RideModel ride,
    required List<RideBooking> bookings,
    String? passengerId,
  }) {
    final result = <Geofence>[];

    if (role == ActiveRideGeofenceRole.driver) {
      final acceptedBookings = bookings
          .where((booking) => booking.status == BookingStatus.accepted)
          .toList(growable: false);

      if (acceptedBookings.isEmpty) {
        result.add(
          _createGeofence(
            id: _zoneId(ride.id, role, 'pickup'),
            point: ride.origin,
            radiusMeters: _pickupRadiusMeters,
          ),
        );
      } else {
        for (final booking in acceptedBookings) {
          result.add(
            _createGeofence(
              id: _zoneId(
                ride.id,
                role,
                'pickup',
                suffix: booking.id,
              ),
              point: booking.pickupLocation ?? ride.origin,
              radiusMeters: _pickupRadiusMeters,
            ),
          );
        }
      }

      result.add(
        _createGeofence(
          id: _zoneId(ride.id, role, 'destination'),
          point: ride.destination,
          radiusMeters: _destinationRadiusMeters,
        ),
      );
      return result;
    }

    RideBooking? passengerBooking;
    for (final booking in bookings) {
      if (passengerId == null || booking.passengerId == passengerId) {
        passengerBooking = booking;
        break;
      }
    }

    result
      ..add(
        _createGeofence(
          id: _zoneId(ride.id, role, 'pickup', suffix: passengerBooking?.id),
          point: passengerBooking?.pickupLocation ?? ride.origin,
          radiusMeters: _pickupRadiusMeters,
        ),
      )
      ..add(
        _createGeofence(
          id: _zoneId(
            ride.id,
            role,
            'destination',
            suffix: passengerBooking?.id,
          ),
          point: passengerBooking?.dropoffLocation ?? ride.destination,
          radiusMeters: _destinationRadiusMeters,
        ),
      );

    return result;
  }

  Geofence _createGeofence({
    required String id,
    required LocationPoint point,
    required double radiusMeters,
  }) {
    return Geofence(
      id: id,
      location: Location(
        latitude: point.latitude,
        longitude: point.longitude,
      ),
      radiusMeters: radiusMeters,
      triggers: const {
        GeofenceEvent.enter,
        GeofenceEvent.exit,
        GeofenceEvent.dwell,
      },
      iosSettings: const IosGeofenceSettings(initialTrigger: true),
      androidSettings: const AndroidGeofenceSettings(
        initialTriggers: {GeofenceEvent.enter},
        expiration: _expiration,
        loiteringDelay: _loiteringDelay,
        notificationResponsiveness: _notificationResponsiveness,
      ),
    );
  }

  String _zoneId(
    String rideId,
    ActiveRideGeofenceRole role,
    String zoneType, {
    String? suffix,
  }) {
    final tail = suffix == null || suffix.isEmpty ? '' : '|$suffix';
    return '$_idPrefix|$rideId|${role.name}|$zoneType$tail';
  }

  String _signatureFor(List<Geofence> geofences) {
    final rows = geofences.map((g) {
      return '${g.id}:'
          '${g.location.latitude.toStringAsFixed(6)},'
          '${g.location.longitude.toStringAsFixed(6)},'
          '${g.radiusMeters.toStringAsFixed(0)}';
    }).toList()..sort();
    return rows.join(';');
  }
}

@pragma('vm:entry-point')
Future<void> activeRideGeofenceTriggered(GeofenceCallbackParams params) async {
  DartPluginRegistrant.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final firestore = FirebaseFirestore.instance;
    for (final geofence in params.geofences) {
      final metadata = _parseActiveRideGeofenceId(geofence.id);
      final rideId = metadata['rideId'];
      if (rideId == null || rideId.isEmpty) continue;

      final payload = <String, Object?>{
        'geofenceId': geofence.id,
        'rideId': rideId,
        'role': metadata['role'],
        'zoneType': metadata['zoneType'],
        'bookingId': metadata['bookingId'],
        'event': params.event.name,
        'triggeredAt': FieldValue.serverTimestamp(),
        'deviceLocation': params.location == null
            ? null
            : {
                'latitude': params.location!.latitude,
                'longitude': params.location!.longitude,
              },
        'zone': {
          'latitude': geofence.location.latitude,
          'longitude': geofence.location.longitude,
          'radiusMeters': geofence.radiusMeters,
        },
      };

      final rideRef = firestore.collection('rides').doc(rideId);
      await rideRef.collection('geofenceEvents').add(payload);
      await rideRef.set(
        {
          'lastGeofenceEvent': payload,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
  } catch (e, st) {
    debugPrint('Active ride geofence callback failed: $e');
    debugPrintStack(stackTrace: st);
  }
}

Map<String, String?> _parseActiveRideGeofenceId(String geofenceId) {
  final parts = geofenceId.split('|');
  if (parts.length < 4 || parts.first != 'sc') {
    return const <String, String?>{};
  }

  return <String, String?>{
    'rideId': parts[1],
    'role': parts[2],
    'zoneType': parts[3],
    'bookingId': parts.length > 4 ? parts[4] : null,
  };
}
