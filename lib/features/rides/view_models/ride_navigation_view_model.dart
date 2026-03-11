import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

class RideNavigationState {
  const RideNavigationState({
    this.rideId,
    this.currentPosition,
    this.progress = 0,
    this.eta = 'Calculating...',
    this.distanceRemaining = '--',
    this.speedKmh = 0,
    this.totalDistanceKm,
    this.totalDurationMinutes,
    this.originLatLng,
    this.destinationLatLng,
    this.lastRideId,
    this.osrmRoutePoints,
    this.osrmRouteRideId,
    this.isLoadingOsrmRoute = false,
    this.isTracking = false,
  });

  final String? rideId;
  final Position? currentPosition;
  final double progress;
  final String eta;
  final String distanceRemaining;
  final double speedKmh;
  final double? totalDistanceKm;
  final int? totalDurationMinutes;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final String? lastRideId;
  final List<LatLng>? osrmRoutePoints;
  final String? osrmRouteRideId;
  final bool isLoadingOsrmRoute;
  final bool isTracking;

  RideNavigationState copyWith({
    String? rideId,
    bool clearRideId = false,
    Position? currentPosition,
    bool clearCurrentPosition = false,
    double? progress,
    String? eta,
    String? distanceRemaining,
    double? speedKmh,
    double? totalDistanceKm,
    bool clearTotalDistanceKm = false,
    int? totalDurationMinutes,
    bool clearTotalDurationMinutes = false,
    LatLng? originLatLng,
    bool clearOriginLatLng = false,
    LatLng? destinationLatLng,
    bool clearDestinationLatLng = false,
    String? lastRideId,
    bool clearLastRideId = false,
    List<LatLng>? osrmRoutePoints,
    bool clearOsrmRoutePoints = false,
    String? osrmRouteRideId,
    bool clearOsrmRouteRideId = false,
    bool? isLoadingOsrmRoute,
    bool? isTracking,
  }) {
    return RideNavigationState(
      rideId: clearRideId ? null : (rideId ?? this.rideId),
      currentPosition: clearCurrentPosition
          ? null
          : (currentPosition ?? this.currentPosition),
      progress: progress ?? this.progress,
      eta: eta ?? this.eta,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      speedKmh: speedKmh ?? this.speedKmh,
      totalDistanceKm: clearTotalDistanceKm
          ? null
          : (totalDistanceKm ?? this.totalDistanceKm),
      totalDurationMinutes: clearTotalDurationMinutes
          ? null
          : (totalDurationMinutes ?? this.totalDurationMinutes),
      originLatLng: clearOriginLatLng
          ? null
          : (originLatLng ?? this.originLatLng),
      destinationLatLng: clearDestinationLatLng
          ? null
          : (destinationLatLng ?? this.destinationLatLng),
      lastRideId: clearLastRideId ? null : (lastRideId ?? this.lastRideId),
      osrmRoutePoints: clearOsrmRoutePoints
          ? null
          : (osrmRoutePoints ?? this.osrmRoutePoints),
      osrmRouteRideId: clearOsrmRouteRideId
          ? null
          : (osrmRouteRideId ?? this.osrmRouteRideId),
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

class RideNavigationViewModel extends Notifier<RideNavigationState> {
  StreamSubscription<Position>? _positionSubscription;
  bool _disposed = false;

  @override
  RideNavigationState build() {
    ref.onDispose(() {
      _disposed = true;
      _positionSubscription?.cancel();
      _positionSubscription = null;
    });
    return const RideNavigationState();
  }

  Future<void> startTracking(String rideId) async {
    if (state.rideId != rideId) {
      state = const RideNavigationState().copyWith(rideId: rideId);
    }
    if (state.isTracking) return;
    state = state.copyWith(isTracking: true);
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      if (_disposed) return;
      state = state.copyWith(currentPosition: position);
      unawaited(_updateLocationInFirebase(position));
      final trackedRideId = state.rideId;
      if (trackedRideId == null) return;
      final ride = ref.read(rideStreamProvider(trackedRideId)).value;
      if (ride != null) {
        _calculateProgress(position, ride);
      }
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    if (_disposed) return;
    state = state.copyWith(isTracking: false);
  }

  Future<void> _updateLocationInFirebase(Position position) async {
    try {
      final trackedRideId = state.rideId;
      if (trackedRideId == null) return;
      await ref
          .read(rideActionsViewModelProvider)
          .updateLiveLocation(
            trackedRideId,
            position.latitude,
            position.longitude,
          );
    } catch (_) {
      // Silent fail for location updates.
    }
  }

  void syncRide(RideModel ride) {
    if (state.lastRideId != ride.id) {
      state = state.copyWith(
        originLatLng: LatLng(ride.origin.latitude, ride.origin.longitude),
        destinationLatLng: LatLng(
          ride.destination.latitude,
          ride.destination.longitude,
        ),
        totalDistanceKm: ride.distanceKm,
        totalDurationMinutes: ride.durationMinutes,
        lastRideId: ride.id,
      );
    }

    final position = state.currentPosition;
    if (position != null) {
      _calculateProgress(position, ride);
    }
  }

  Future<void> ensureOsrmRoute(RideModel ride) async {
    if (state.isLoadingOsrmRoute || state.osrmRouteRideId == ride.id) return;
    state = state.copyWith(isLoadingOsrmRoute: true, osrmRouteRideId: ride.id);
    try {
      final routeInfo = await RoutingService.getRoute(
        origin: LatLng(ride.origin.latitude, ride.origin.longitude),
        destination: LatLng(ride.destination.latitude, ride.destination.longitude),
      );
      if (_disposed) return;
      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        isLoadingOsrmRoute: false,
      );
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(isLoadingOsrmRoute: false);
    }
  }

  void _calculateProgress(Position position, RideModel ride) {
    final speedKmh = (position.speed * 3.6).clamp(0.0, 200.0);
    final originLatLng = state.originLatLng ??
        LatLng(ride.origin.latitude, ride.origin.longitude);
    final destinationLatLng = state.destinationLatLng ??
        LatLng(ride.destination.latitude, ride.destination.longitude);
    final totalDistKm = state.totalDistanceKm ?? ride.distanceKm ?? 0;
    final totalDurationMinutes =
      state.totalDurationMinutes ?? ride.durationMinutes;

    final currentLatLng = LatLng(position.latitude, position.longitude);
    final distToDest = _haversineKm(currentLatLng, destinationLatLng);
    final distFromOrigin = _haversineKm(originLatLng, currentLatLng);

    final progress = totalDistKm > 0
        ? (distFromOrigin / (distFromOrigin + distToDest)).clamp(0.0, 1.0)
        : 0.0;

    int remainingMinutes;
    if (speedKmh > 5) {
      remainingMinutes = (distToDest / speedKmh * 60).round();
    } else if (totalDurationMinutes != null) {
      remainingMinutes = ((1 - progress) * totalDurationMinutes).round();
    } else {
      final avgSpeedKmh =
          (totalDistKm > 0 && ((ride.durationMinutes ?? 0) > 0))
          ? totalDistKm / ((ride.durationMinutes ?? 1) / 60)
          : 30.0;
      remainingMinutes = (distToDest / avgSpeedKmh * 60).round();
    }

    final distStr = distToDest < 1
        ? '${(distToDest * 1000).toInt()} m'
        : '${distToDest.toStringAsFixed(1)} km';

    final etaStr = remainingMinutes < 1
        ? 'Arriving'
        : remainingMinutes >= 60
        ? '${remainingMinutes ~/ 60}h ${remainingMinutes % 60}m'
        : '$remainingMinutes min';

    state = state.copyWith(
      speedKmh: speedKmh,
      progress: progress,
      eta: etaStr,
      distanceRemaining: distStr,
      originLatLng: originLatLng,
      destinationLatLng: destinationLatLng,
      totalDistanceKm: totalDistKm,
      totalDurationMinutes: totalDurationMinutes,
    );
  }

  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final sinLat = math.sin(dLat / 2);
    final sinLon = math.sin(dLon / 2);
    final h =
        sinLat * sinLat +
        math.cos(_degToRad(a.latitude)) *
            math.cos(_degToRad(b.latitude)) *
            sinLon *
            sinLon;
    return 2 * r * math.asin(math.sqrt(h));
  }

  double _degToRad(double deg) => deg * math.pi / 180;

}

final rideNavigationViewModelProvider =
    NotifierProvider<RideNavigationViewModel, RideNavigationState>(
      RideNavigationViewModel.new,
    );