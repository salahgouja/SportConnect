import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

class DriverLocationState {
  final bool isLoading;
  final bool hasInitialized;
  final bool locationGranted;
  final bool locationDeniedForever;
  final bool servicesDisabled;
  final Position? currentPosition;
  final String? errorMessage;

  const DriverLocationState({
    this.isLoading = true,
    this.hasInitialized = false,
    this.locationGranted = false,
    this.locationDeniedForever = false,
    this.servicesDisabled = false,
    this.currentPosition,
    this.errorMessage,
  });

  DriverLocationState copyWith({
    bool? isLoading,
    bool? hasInitialized,
    bool? locationGranted,
    bool? locationDeniedForever,
    bool? servicesDisabled,
    Position? currentPosition,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverLocationState(
      isLoading: isLoading ?? this.isLoading,
      hasInitialized: hasInitialized ?? this.hasInitialized,
      locationGranted: locationGranted ?? this.locationGranted,
      locationDeniedForever:
          locationDeniedForever ?? this.locationDeniedForever,
      servicesDisabled: servicesDisabled ?? this.servicesDisabled,
      currentPosition: currentPosition ?? this.currentPosition,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DriverLocationViewModel extends Notifier<DriverLocationState> {
  StreamSubscription<Position>? _positionSubscription;
  Future<void>? _initializeOperation;
  Future<void>? _permissionOperation;

  @override
  DriverLocationState build() {
    ref.onDispose(() => _positionSubscription?.cancel());
    return const DriverLocationState();
  }

  Future<void> initialize({bool force = false}) {
    if (state.hasInitialized && !force) {
      return Future.value();
    }

    final existingOperation = _initializeOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final initializeOperation = _runInitialize(force: force);
    _initializeOperation = initializeOperation;
    return initializeOperation.whenComplete(() {
      if (identical(_initializeOperation, initializeOperation)) {
        _initializeOperation = null;
      }
    });
  }

  Future<void> _runInitialize({required bool force}) async {
    await Future<void>.value();

    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();
      if (!ref.mounted) return;

      if (!servicesEnabled) {
        state = state.copyWith(
          isLoading: false,
          hasInitialized: true,
          servicesDisabled: true,
          locationGranted: false,
          locationDeniedForever: false,
        );
        return;
      }

      final permission = await Geolocator.checkPermission();
      final deniedForever = permission == LocationPermission.deniedForever;
      final granted = permission != LocationPermission.denied && !deniedForever;

      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        servicesDisabled: false,
        locationGranted: granted,
        locationDeniedForever: deniedForever,
      );

      if (granted) {
        await _fetchCurrentPosition();
        if (!ref.mounted) return;
        _startLocationTracking();
      }
    } catch (e) {
      if (!ref.mounted) return;
      TalkerService.debug('Error checking location status: $e');
      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        errorMessage: 'location-init-failed',
      );
    }
  }

  Future<void> requestPermission() {
    final existingOperation = _permissionOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final permissionOperation = _runRequestPermission();
    _permissionOperation = permissionOperation;
    return permissionOperation.whenComplete(() {
      if (identical(_permissionOperation, permissionOperation)) {
        _permissionOperation = null;
      }
    });
  }

  Future<void> _runRequestPermission() async {
    await Future<void>.value();
    
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final granted = await LocationServiceImpl.instance.requestPermission();
      final permission = await Geolocator.checkPermission();
      final servicesEnabled = await Geolocator.isLocationServiceEnabled();

      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        locationGranted: granted,
        servicesDisabled: !servicesEnabled,
        locationDeniedForever: permission == LocationPermission.deniedForever,
      );

      if (granted) {
        await _fetchCurrentPosition();
        if (!ref.mounted) return;
        _startLocationTracking();
      }
    } catch (e) {
      if (!ref.mounted) return;
      TalkerService.debug('Error requesting location permission: $e');
      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        errorMessage: 'location-request-failed',
      );
    }
  }

  Future<void> _fetchCurrentPosition() async {
    final position = await LocationServiceImpl.instance.getCurrentLocation();
    if (!ref.mounted || position == null) {
      return;
    }

    state = state.copyWith(
      currentPosition: position,
      locationGranted: true,
      servicesDisabled: false,
    );
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationServiceImpl.instance
        .getLocationStream()
        .listen(
          (position) {
            if (!ref.mounted) return;
            state = state.copyWith(
              currentPosition: position,
              locationGranted: true,
            );
          },
          onError: (Object error) {
            if (!ref.mounted) return;
            TalkerService.debug('Location stream error: $error');
            state = state.copyWith(errorMessage: 'location-stream-failed');
          },
        );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final driverLocationViewModelProvider =
    NotifierProvider<DriverLocationViewModel, DriverLocationState>(
      DriverLocationViewModel.new,
    );
