import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'rider_home_view_model.g.dart';

/// Location permission and service state
enum LocationPermissionState {
  /// Never asked yet / cold start
  unknown,

  /// User tapped allow — OS dialog pending or GPS acquiring
  acquiring,

  /// GPS fix obtained — map ready
  ready,

  /// Soft deny: user tapped "Not now" on rationale screen
  deniedSoft,

  /// Hard deny: user previously denied the OS dialog forever
  deniedHard,

  /// Device-level location services are OFF
  serviceDisabled,
}

/// Complete state for RiderHomeScreen
class RiderHomeState {
  const RiderHomeState({
    this.locationState = LocationPermissionState.unknown,
    this.currentLocation,
    this.userHeading = 0.0,
    this.nearbyQueryAnchor,
    this.lastMapMoveAt,
    this.currentZoom = 14,
    this.selectedMapStyle = 'standard',
    this.showNearbyDrivers = true,
    this.showHotspots = true,
    this.showDistanceRadius = false,
    this.searchRadius = 5.0,
    this.isFollowingUser = true,
    this.selectedFilter = 'all',
    this.activeRoute,
    this.alternativeRoutes = const [],
    this.isLoadingRoute = false,
    this.showRouteInfo = false,
    this.selectedRouteIndex = 0,
    this.showMapView = false,
  });

  // Location permission and acquisition
  final LocationPermissionState locationState;

  // Current location
  final LatLng? currentLocation;
  final double userHeading;
  final LatLng? nearbyQueryAnchor;
  final DateTime? lastMapMoveAt;

  // Map view settings
  final double currentZoom;
  final String selectedMapStyle;
  final bool showNearbyDrivers;
  final bool showHotspots;
  final bool showDistanceRadius;
  final double searchRadius;
  final bool isFollowingUser;

  // Filter state
  final String selectedFilter;

  // Route state
  final RouteInfo? activeRoute;
  final List<RouteInfo> alternativeRoutes;
  final bool isLoadingRoute;
  final bool showRouteInfo;
  final int selectedRouteIndex;

  // View mode: false = feed (default), true = full map
  final bool showMapView;

  RiderHomeState copyWith({
    LocationPermissionState? locationState,
    LatLng? currentLocation,
    double? userHeading,
    LatLng? nearbyQueryAnchor,
    DateTime? lastMapMoveAt,
    double? currentZoom,
    String? selectedMapStyle,
    bool? showNearbyDrivers,
    bool? showHotspots,
    bool? showDistanceRadius,
    double? searchRadius,
    bool? isFollowingUser,
    String? selectedFilter,
    RouteInfo? activeRoute,
    List<RouteInfo>? alternativeRoutes,
    bool? isLoadingRoute,
    bool? showRouteInfo,
    int? selectedRouteIndex,
    bool? showMapView,
  }) {
    return RiderHomeState(
      locationState: locationState ?? this.locationState,
      currentLocation: currentLocation ?? this.currentLocation,
      userHeading: userHeading ?? this.userHeading,
      nearbyQueryAnchor: nearbyQueryAnchor ?? this.nearbyQueryAnchor,
      lastMapMoveAt: lastMapMoveAt ?? this.lastMapMoveAt,
      currentZoom: currentZoom ?? this.currentZoom,
      selectedMapStyle: selectedMapStyle ?? this.selectedMapStyle,
      showNearbyDrivers: showNearbyDrivers ?? this.showNearbyDrivers,
      showHotspots: showHotspots ?? this.showHotspots,
      showDistanceRadius: showDistanceRadius ?? this.showDistanceRadius,
      searchRadius: searchRadius ?? this.searchRadius,
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      activeRoute: activeRoute ?? this.activeRoute,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      showRouteInfo: showRouteInfo ?? this.showRouteInfo,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      showMapView: showMapView ?? this.showMapView,
    );
  }

  RiderHomeState clearLocation() {
    return RiderHomeState(
      locationState: locationState,
      currentLocation: null,
      userHeading: 0.0,
      nearbyQueryAnchor: null,
      lastMapMoveAt: null,
      currentZoom: currentZoom,
      selectedMapStyle: selectedMapStyle,
      showNearbyDrivers: showNearbyDrivers,
      showHotspots: showHotspots,
      showDistanceRadius: showDistanceRadius,
      searchRadius: searchRadius,
      isFollowingUser: isFollowingUser,
      selectedFilter: selectedFilter,
      activeRoute: activeRoute,
      alternativeRoutes: alternativeRoutes,
      isLoadingRoute: isLoadingRoute,
      showRouteInfo: showRouteInfo,
      selectedRouteIndex: selectedRouteIndex,
      showMapView: showMapView,
    );
  }

  RiderHomeState clearRoute() {
    return RiderHomeState(
      locationState: locationState,
      currentLocation: currentLocation,
      userHeading: userHeading,
      nearbyQueryAnchor: nearbyQueryAnchor,
      lastMapMoveAt: lastMapMoveAt,
      currentZoom: currentZoom,
      selectedMapStyle: selectedMapStyle,
      showNearbyDrivers: showNearbyDrivers,
      showHotspots: showHotspots,
      showDistanceRadius: showDistanceRadius,
      searchRadius: searchRadius,
      isFollowingUser: isFollowingUser,
      selectedFilter: selectedFilter,
      activeRoute: null,
      alternativeRoutes: const [],
      isLoadingRoute: false,
      showRouteInfo: false,
      selectedRouteIndex: 0,
      showMapView: showMapView,
    );
  }
}

/// ViewModel for RiderHomeScreen with all business logic
@riverpod
class RiderHomeViewModel extends _$RiderHomeViewModel {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  RiderHomeState build() {
    ref.onDispose(() {
      _positionStreamSubscription?.cancel();
    });

    return const RiderHomeState();
  }

  // ============================================================================
  // Location Permission Flow
  // ============================================================================

  /// Check initial location permission state on cold start
  Future<void> checkInitialLocationState() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        locationState: LocationPermissionState.serviceDisabled,
      );
      return;
    }

    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Already granted — go straight to acquiring
      await acquireLocationAndShowMap();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        locationState: LocationPermissionState.deniedHard,
      );
      return;
    }

    // First launch or soft-denied previously
    state = state.copyWith(
      locationState: LocationPermissionState.unknown,
    );
  }

  /// Transition to acquiring state (called when user taps "Allow Location")
  void setAcquiringLocation() {
    state = state.copyWith(
      locationState: LocationPermissionState.acquiring,
    );
  }

  /// Handle permission denial states
  void setLocationDeniedSoft() {
    state = state.copyWith(
      locationState: LocationPermissionState.deniedSoft,
    );
  }

  void setLocationDeniedHard() {
    state = state.copyWith(
      locationState: LocationPermissionState.deniedHard,
    );
  }

  void setLocationServiceDisabled() {
    state = state.copyWith(
      locationState: LocationPermissionState.serviceDisabled,
    );
  }

  /// Acquire GPS location and transition to ready state
  Future<void> acquireLocationAndShowMap() async {
    // Stay in acquiring if not already
    if (state.locationState != LocationPermissionState.acquiring) {
      state = state.copyWith(
        locationState: LocationPermissionState.acquiring,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final loc = LatLng(position.latitude, position.longitude);

      state = state.copyWith(
        currentLocation: loc,
        nearbyQueryAnchor: loc,
        userHeading: position.heading,
        locationState: LocationPermissionState.ready,
      );

      // Start continuous tracking
      _startLocationStream();
    } catch (e) {
      TalkerService.error('Failed to get initial position: $e');
      // GPS timed out but permission granted — show map anyway
      state = state.copyWith(
        currentLocation: null,
        locationState: LocationPermissionState.ready,
      );
      _startLocationStream();
    }
  }

  /// Start continuous GPS tracking stream
  void _startLocationStream() {
    _positionStreamSubscription?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (Position position) {
        final next = LatLng(position.latitude, position.longitude);

        // Skip tiny movements to avoid unnecessary rebuilds
        final current = state.currentLocation;
        if (current != null) {
          final moved = Geolocator.distanceBetween(
            current.latitude,
            current.longitude,
            next.latitude,
            next.longitude,
          );
          final headingDelta = (state.userHeading - position.heading).abs();
          if (moved < 12 && headingDelta < 8) return;
        }

        // Update location
        var newState = state.copyWith(
          currentLocation: next,
          userHeading: position.heading,
        );

        // Refresh Firestore query anchor every 1 km
        final anchor = state.nearbyQueryAnchor;
        if (anchor == null ||
            Geolocator.distanceBetween(
                  anchor.latitude,
                  anchor.longitude,
                  next.latitude,
                  next.longitude,
                ) >=
                1000) {
          newState = newState.copyWith(nearbyQueryAnchor: next);
        }

        state = newState;
      },
      onError: (e) {
        TalkerService.error('Location stream error: $e');
      },
    );
  }

  /// Stop location tracking (cleanup)
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // ============================================================================
  // Map State Methods
  // ============================================================================

  /// Update zoom level (called from map onPositionChanged)
  void updateZoom(double zoom) {
    if ((state.currentZoom - zoom).abs() > 0.01) {
      state = state.copyWith(currentZoom: zoom);
    }
  }

  /// Update map style
  void setMapStyle(String style) {
    state = state.copyWith(selectedMapStyle: style);
  }

  /// Toggle nearby drivers visibility
  void toggleNearbyDrivers() {
    state = state.copyWith(showNearbyDrivers: !state.showNearbyDrivers);
  }

  /// Toggle hotspots visibility
  void toggleHotspots() {
    state = state.copyWith(showHotspots: !state.showHotspots);
  }

  /// Toggle distance radius circle
  void toggleDistanceRadius() {
    state = state.copyWith(showDistanceRadius: !state.showDistanceRadius);
  }

  /// Update search radius
  void updateSearchRadius(double radius) {
    if (radius >= 1.0 && radius <= 25.0) {
      state = state.copyWith(searchRadius: radius);
    }
  }

  /// Toggle user following mode
  void toggleFollowingUser() {
    state = state.copyWith(isFollowingUser: !state.isFollowingUser);
  }

  /// Disable following when user manually pans map
  void disableFollowingUser() {
    if (state.isFollowingUser) {
      state = state.copyWith(isFollowingUser: false);
    }
  }

  /// Record last map move time (for throttling)
  void updateLastMapMoveTime(DateTime time) {
    state = state.copyWith(lastMapMoveAt: time);
  }

  /// Check if map can move (throttle check)
  bool canMoveMap() {
    final last = state.lastMapMoveAt;
    if (last == null) return true;
    final now = DateTime.now();
    return now.difference(last) >= const Duration(milliseconds: 700);
  }

  // ============================================================================
  // Filter Methods
  // ============================================================================

  /// Set ride filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Apply filter to ride list
  List<RideModel> applyFilter(List<RideModel> rides) {
    switch (state.selectedFilter) {
      case 'available':
        return rides.where((r) => r.availableSeats > 0).toList();
      case 'premium':
        return rides.where((r) => r.isPremium).toList();
      case 'eco':
        return rides.where((r) => r.isEco).toList();
      default:
        return rides;
    }
  }

  // ============================================================================
  // Route Methods
  // ============================================================================

  /// Set active route
  void setActiveRoute(RouteInfo? route) {
    state = state.copyWith(
      activeRoute: route,
      showRouteInfo: route != null,
    );
  }

  /// Set alternative routes
  void setAlternativeRoutes(List<RouteInfo> routes) {
    state = state.copyWith(alternativeRoutes: routes);
  }

  /// Select route by index
  void selectRoute(int index) {
    if (index >= 0 && index < state.alternativeRoutes.length) {
      state = state.copyWith(
        selectedRouteIndex: index,
        activeRoute: state.alternativeRoutes[index],
      );
    }
  }

  /// Toggle route info panel
  void toggleRouteInfo() {
    state = state.copyWith(showRouteInfo: !state.showRouteInfo);
  }

  /// Set route loading state
  void setLoadingRoute(bool loading) {
    state = state.copyWith(isLoadingRoute: loading);
  }

  /// Clear all route state
  void clearRoutes() {
    state = state.clearRoute();
  }

  /// Toggle between feed view and full map view
  void toggleMapView() {
    state = state.copyWith(showMapView: !state.showMapView);
  }

  /// Switch to map view
  void showMap() {
    state = state.copyWith(showMapView: true);
  }

  /// Switch to feed view
  void showFeed() {
    state = state.copyWith(showMapView: false);
  }
}
