import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/services/feature_discovery_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/profile/views/profile_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_search_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_request_ride_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_offer_ride_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_my_rides_screen.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/features/home/repositories/home_repository.dart';
import 'package:sport_connect/features/home/models/home_models.dart';

/// Modern Carpooling Home Screen  - Uses proper MVVM architecture with repository
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabAnimationController;
  late final AnimationController _pulseAnimationController;

  // Map controller and state
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(37.7749, -122.4194);
  bool _isLoadingLocation = true;
  double _currentZoom = 14;
  String _selectedMapStyle = 'standard';
  bool _showNearbyDrivers = true;
  bool _showHotspots = true;
  String _selectedFilter = 'all';
  double _userHeading = 0.0;
  bool _isFollowingUser = true;
  bool _showDistanceRadius = false;
  double _searchRadius = 5.0; // km
  StreamSubscription<Position>? _positionStreamSubscription;

  // OSRM Routing state
  RouteInfo? _activeRoute;
  List<RouteInfo> _alternativeRoutes = [];
  bool _isLoadingRoute = false;
  bool _showRouteInfo = false;
  int _selectedRouteIndex = 0;

  // Showcase keys for feature discovery tour
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _bottomNavKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  // Map styles available
  final Map<String, String> _mapStyles = {
    'standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'terrain': 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    'dark':
        'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
    'satellite':
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  };

  @override
  void initState() {
    super.initState();

    // Register ShowcaseView FIRST before any other initialization
    // This is required for showcaseview 5.x - must be in initState
    FeatureDiscoveryService.register();

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _getCurrentLocation();
    _startLocationTracking();

    // Delay tour start to ensure widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartTour();
    });
  }

  /// Check if first time user and start showcase tour
  Future<void> _checkAndStartTour() async {
    final isFirstTime = await FeatureDiscoveryService.isFirstTimeUser();
    if (isFirstTime && mounted) {
      // Small delay to ensure UI is fully built
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        try {
          FeatureDiscoveryService.startShowcase([
            _searchBarKey,
            _bottomNavKey,
            _profileKey,
          ]);
          // Mark tour as complete
          await FeatureDiscoveryService.markFirstTimeTourComplete();
        } catch (e) {
          TalkerService.warning('Could not start showcase tour: $e');
        }
      }
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
              _userHeading = position.heading;
            });
            if (_isFollowingUser) {
              _mapController.move(_currentLocation, _currentZoom);
            }
          }
        });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        TalkerService.debug('Location services are disabled');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          TalkerService.debug('Location permission denied');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        TalkerService.debug('Location permission denied forever');
        setState(() => _isLoadingLocation = false);
        return;
      }

      TalkerService.debug('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      TalkerService.debug(
        'Got position: ${position.latitude}, ${position.longitude}',
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_currentLocation, _currentZoom);
    } catch (e) {
      TalkerService.debug('Error getting location: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pulseAnimationController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  Widget _getCurrentScreen() {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.whenData((u) => u).value;
    final isDriver = user?.role == UserRole.driver;

    switch (_currentIndex) {
      case 0:
        return _buildMapHome();
      case 1:
        // Find/Browse rides - Both can search for available rides
        return const RideSearchScreen();
      case 2:
        // Request/Offer - Different for riders vs drivers
        return isDriver
            ? const DriverOfferRideScreen() // Drivers offer rides
            : const RiderRequestRideScreen(); // Riders request rides
      case 3:
        // My Rides - Different for riders vs drivers
        return isDriver
            ? const DriverMyRidesScreen()
            : const RiderMyRidesScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildMapHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: Showcase(
        key: _bottomNavKey,
        title: 'Navigate the App',
        description:
            'Use the navigation bar to explore different sections: Explore the map, Search rides, Request or Offer rides, view your trips, and access your Profile.',
        titleTextStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        descTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.9),
        ),
        tooltipBackgroundColor: AppColors.primary,
        targetPadding: EdgeInsets.all(4.w),
        child: _buildModernBottomNav(),
      ),
    );
  }

  /// Modern bottom navigation bar with Google Nav Bar design
  Widget _buildModernBottomNav() {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.whenData((u) => u).value;
    final isDriver = user?.role == UserRole.driver;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: GNav(
            rippleColor: AppColors.primary.withOpacity(0.1),
            hoverColor: AppColors.primary.withOpacity(0.1),
            haptic: true,
            tabBorderRadius: 16.r,
            curve: Curves.easeOutExpo,
            duration: const Duration(milliseconds: 400),
            gap: 6,
            color: AppColors.textTertiary,
            activeColor: AppColors.primary,
            iconSize: 24.sp,
            tabBackgroundColor: AppColors.primary.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
            },
            tabs: [
              GButton(
                icon: Icons.explore_outlined,
                iconActiveColor: AppColors.primary,
                text: 'Explore',
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GButton(
                icon: Icons.search_rounded,
                iconActiveColor: AppColors.primary,
                text: 'Search',
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GButton(
                icon: isDriver ? Icons.add_road_rounded : Icons.hail_rounded,
                iconActiveColor: AppColors.primary,
                text: isDriver ? 'Offer' : 'Request',
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GButton(
                icon: isDriver
                    ? Icons.dashboard_rounded
                    : Icons.receipt_long_rounded,
                iconActiveColor: AppColors.primary,
                text: isDriver ? 'Dashboard' : 'My Trips',
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GButton(
                icon: Icons.person_outline,
                iconActiveColor: AppColors.primary,
                text: 'Profile',
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapHome() {
    final nearbyRides = ref.watch(nearbyRidesStreamProvider(_currentLocation));
    final hotspots = ref.watch(hotspotsStreamProvider);
    final user = ref.watch(currentUserProvider);

    return Stack(
      children: [
        // Map Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation,
            initialZoom: _currentZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() => _currentZoom = position.zoom);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _mapStyles[_selectedMapStyle]!,
              userAgentPackageName: 'com.sportconnect.app',
            ),

            // Route polyline if active
            if (_activeRoute != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _activeRoute!.coordinates,
                    color: AppColors.primary,
                    strokeWidth: 5,
                  ),
                  ..._alternativeRoutes.asMap().entries.map((entry) {
                    return Polyline(
                      points: entry.value.coordinates,
                      color: entry.key == _selectedRouteIndex
                          ? AppColors.primary.withOpacity(0.8)
                          : AppColors.textSecondary.withOpacity(0.4),
                      strokeWidth: entry.key == _selectedRouteIndex ? 5 : 3,
                    );
                  }),
                ],
              ),

            // Nearby rides markers
            if (_showNearbyDrivers)
              nearbyRides.when(
                data: (rides) => MarkerLayer(
                  markers: _buildRideMarkers(_filterRides(rides)),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),

            // Hotspots markers - using proper Hotspot model
            if (_showHotspots)
              hotspots.when(
                data: (spots) => MarkerLayer(
                  markers: spots.map((hotspot) {
                    return Marker(
                      point: hotspot.location,
                      width: 80.w,
                      height: 40.h,
                      child: _buildHotspotMarker(hotspot),
                    );
                  }).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),

            // Current location marker
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation,
                  width: 60.w,
                  height: 60.h,
                  child: _buildCurrentLocationMarker(),
                ),
              ],
            ),

            // Search radius circle
            if (_showDistanceRadius)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _currentLocation,
                    radius: _searchRadius * 1000, // Convert km to meters
                    useRadiusInMeter: true,
                    color: AppColors.primary.withOpacity(0.1),
                    borderColor: AppColors.primary.withOpacity(0.5),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
          ],
        ),

        // Top Controls
        _buildTopControls(user),

        // Filter Bar
        _buildFilterBar(),

        // Map Style Selector
        _buildMapStyleSelector(),

        // Scale Bar
        _buildScaleBar(),

        // Radius Slider (when active)
        if (_showDistanceRadius) _buildRadiusSlider(),

        // Route Info Panel
        if (_showRouteInfo && _activeRoute != null) _buildRouteInfoPanel(),

        // Quick Stats Bar
        _buildQuickStatsBar(nearbyRides),

        // Loading overlay
        if (_isLoadingLocation || _isLoadingRoute)
          Positioned(
            top: 150.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _isLoadingLocation
                          ? 'Getting location...'
                          : 'Loading route...',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Filter rides based on selected filter - uses proper model classes
  List<NearbyRidePreview> _filterRides(List<NearbyRidePreview> rides) {
    switch (_selectedFilter) {
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

  /// Build ride markers using proper NearbyRidePreview model
  List<Marker> _buildRideMarkers(List<NearbyRidePreview> rides) {
    return rides.map((ride) {
      return Marker(
        point: ride.origin,
        width: 70.w,
        height: 80.h,
        child: GestureDetector(
          onTap: () => _showRideDetails(ride),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ride.isPremium
                      ? AppColors.starFilled
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${ride.pricePerSeat.toStringAsFixed(0)} €',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Icon(
                Icons.location_on,
                color: ride.isPremium
                    ? AppColors.starFilled
                    : AppColors.primary,
                size: 26.sp,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build hotspot marker using proper Hotspot model
  Widget _buildHotspotMarker(Hotspot hotspot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place, color: Colors.white, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            '${hotspot.rideCount}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect
            if (_isFollowingUser)
              Container(
                width: 50.w * (1 + _pulseAnimationController.value * 0.3),
                height: 50.w * (1 + _pulseAnimationController.value * 0.3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    0.2 * (1 - _pulseAnimationController.value),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            // Accuracy ring
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
            // Direction indicator (compass)
            Transform.rotate(
              angle: _userHeading * (3.14159 / 180),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build scale bar for map
  Widget _buildScaleBar() {
    // Calculate approximate scale based on zoom level
    // At zoom 14, 1km ≈ ~100 pixels (varies by latitude)
    final scaleKm =
        (156543.03392 *
                (1 / (180 / 3.14159)) *
                180 /
                3.14159 /
                (1 << _currentZoom.toInt()) *
                100 /
                1000)
            .clamp(0.1, 100.0);
    String scaleText;
    if (scaleKm < 1) {
      scaleText = '${(scaleKm * 1000).toInt()} m';
    } else {
      scaleText = '${scaleKm.toStringAsFixed(1)} km';
    }

    return Positioned(
      left: 16.w,
      bottom: 80.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              scaleText,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  /// Build radius slider when distance radius is enabled
  Widget _buildRadiusSlider() {
    return Positioned(
      left: 16.w,
      right: 80.w,
      bottom: 130.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Search Radius',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${_searchRadius.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.2),
                trackHeight: 4.h,
              ),
              child: Slider(
                value: _searchRadius,
                min: 1,
                max: 25,
                divisions: 24,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _searchRadius = value);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  /// Build quick stats bar showing nearby rides count - uses proper model
  Widget _buildQuickStatsBar(AsyncValue<List<NearbyRidePreview>> nearbyRides) {
    return Positioned(
      left: 16.w,
      bottom: 24.h,
      child: nearbyRides.when(
        data: (rides) {
          final filteredRides = _filterRides(rides);
          final availableSeats = filteredRides.fold<int>(
            0,
            (sum, r) => sum + r.availableSeats,
          );

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem(
                  Icons.directions_car,
                  '${filteredRides.length}',
                  'rides',
                ),
                SizedBox(width: 16.w),
                Container(width: 1, height: 24.h, color: AppColors.border),
                SizedBox(width: 16.w),
                _buildStatItem(Icons.event_seat, '$availableSeats', 'seats'),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopControls(AsyncValue<dynamic> user) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            // Profile Button
            Showcase(
              key: _profileKey,
              title: 'Your Profile',
              description:
                  'Tap here to access your profile, settings, achievements, and more. View your XP progress and level!',
              titleTextStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              descTextStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
              tooltipBackgroundColor: AppColors.primary,
              targetShapeBorder: const CircleBorder(),
              targetPadding: EdgeInsets.all(8.w),
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 4),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: user.when(
                    data: (userData) => PremiumAvatar(
                      imageUrl: userData?.photoUrl,
                      name: userData?.displayName ?? 'User',
                      size: 40.w,
                    ),
                    loading: () => CircleAvatar(
                      radius: 20.w,
                      backgroundColor: AppColors.shimmer,
                    ),
                    error: (_, _) => CircleAvatar(
                      radius: 20.w,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Clean Search Bar - Opens inline search bottom sheet
            Expanded(
              child: Showcase(
                key: _searchBarKey,
                title: 'Search for Rides',
                description:
                    'Tap here to find rides to your destination. Enter your pickup and drop-off locations to see available rides.',
                titleTextStyle: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                descTextStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                ),
                tooltipBackgroundColor: AppColors.primary,
                targetBorderRadius: BorderRadius.circular(28.r),
                targetPadding: EdgeInsets.all(8.w),
                child: GestureDetector(
                  onTap: () => _showInlineSearchSheet(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Where are you going?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Profile Search
            GestureDetector(
              onTap: () => context.push(AppRouter.profileSearch),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Notifications
            GestureDetector(
              onTap: () => context.push(AppRouter.notifications),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildFilterBar() {
    final filters = [
      {'id': 'all', 'label': 'All', 'icon': Icons.apps},
      {'id': 'available', 'label': 'Available', 'icon': Icons.event_seat},
      {'id': 'premium', 'label': 'Premium', 'icon': Icons.star},
      {'id': 'eco', 'label': 'Eco', 'icon': Icons.eco},
    ];

    return Positioned(
      top: 100.h,
      left: 16.w,
      right: 16.w,
      child: SizedBox(
        height: 40.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter['id'];

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = filter['id'] as String);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 14.sp,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        filter['label'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMapStyleSelector() {
    return Positioned(
      right: 16.w,
      top: 160.h,
      child: Column(
        children: [
          // Map Style Toggle
          _buildMapControl(
            icon: Icons.layers_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
              _showMapStylePicker();
            },
          ),
          SizedBox(height: 8.h),
          // Toggle Distance Radius
          _buildMapControl(
            icon: Icons.radar_rounded,
            isActive: _showDistanceRadius,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showDistanceRadius = !_showDistanceRadius);
            },
            tooltip: 'Search Radius',
          ),
          SizedBox(height: 8.h),
          // Toggle Hotspots
          _buildMapControl(
            icon: Icons.place_outlined,
            isActive: _showHotspots,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showHotspots = !_showHotspots);
            },
            tooltip: 'Hotspots',
          ),
          SizedBox(height: 8.h),
          // Toggle Drivers
          _buildMapControl(
            icon: Icons.directions_car_outlined,
            isActive: _showNearbyDrivers,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _showNearbyDrivers = !_showNearbyDrivers);
            },
            tooltip: 'Nearby Rides',
          ),
          SizedBox(height: 8.h),
          // Toggle Follow User
          _buildMapControl(
            icon: _isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
            isActive: _isFollowingUser,
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _isFollowingUser = !_isFollowingUser);
              if (_isFollowingUser) {
                _mapController.move(_currentLocation, _currentZoom);
              }
            },
            tooltip: 'Follow Location',
          ),
          SizedBox(height: 8.h),
          // Zoom In
          _buildMapControl(
            icon: Icons.add,
            onTap: () {
              HapticFeedback.selectionClick();
              final newZoom = math.min(_currentZoom + 1, 18.0);
              _mapController.move(_mapController.camera.center, newZoom);
              setState(() => _currentZoom = newZoom);
            },
          ),
          SizedBox(height: 4.h),
          // Zoom Out
          _buildMapControl(
            icon: Icons.remove,
            onTap: () {
              HapticFeedback.selectionClick();
              final newZoom = math.max(_currentZoom - 1, 5.0);
              _mapController.move(_mapController.camera.center, newZoom);
              setState(() => _currentZoom = newZoom);
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.3);
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
          ],
        ),
        child: Icon(
          icon,
          size: 22.sp,
          color: isActive ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildRouteInfoPanel() {
    return Positioned(
      bottom: 24.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.route,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(_activeRoute!.distanceKm).toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_activeRoute!.durationMinutes} min',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showRouteInfo = false;
                      _activeRoute = null;
                      _alternativeRoutes = [];
                    });
                  },
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  // ignore: unused_element - keeping for potential future use
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => setState(() => _currentIndex = 2),
      backgroundColor: AppColors.primary,
      icon: Icon(Icons.add_rounded, size: 22.sp),
      label: Text(
        'Offer Ride',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, 'Map'),
              _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search'),
              _buildNavItem(
                2,
                Icons.add_circle_outline,
                Icons.add_circle,
                'Offer',
              ),
              _buildNavItem(
                3,
                Icons.history_outlined,
                Icons.history,
                'My Rides',
              ),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapStylePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Map Style',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildStyleOption('standard', 'Standard', Icons.map),
                  SizedBox(width: 12.w),
                  _buildStyleOption('terrain', 'Terrain', Icons.terrain),
                  SizedBox(width: 12.w),
                  _buildStyleOption('dark', 'Dark', Icons.dark_mode),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption(String id, String label, IconData icon) {
    final isSelected = _selectedMapStyle == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedMapStyle = id);
          context.pop();
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 28.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows inline search bottom sheet with nearby rides
  void _showInlineSearchSheet() {
    HapticFeedback.selectionClick();
    final TextEditingController fromController = TextEditingController();
    final TextEditingController toController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int selectedSeats = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final nearbyRides = ref.watch(
              nearbyRidesStreamProvider(_currentLocation),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textPrimary,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Find a Ride',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            context.pop();
                            setState(() => _currentIndex = 1);
                          },
                          icon: Icon(Icons.tune_rounded, size: 18.sp),
                          label: const Text('Filters'),
                        ),
                      ],
                    ),
                  ),

                  // Search inputs
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // From field
                        TextField(
                          controller: fromController,
                          decoration: InputDecoration(
                            hintText: 'From where?',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.circle,
                              color: AppColors.primary,
                              size: 12.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                          ),
                        ),
                        Divider(color: AppColors.border, height: 1),
                        // To field
                        TextField(
                          controller: toController,
                          decoration: InputDecoration(
                            hintText: 'To where?',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: AppColors.error,
                              size: 16.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Quick date & seat selection
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 90),
                                ),
                              );
                              if (date != null) {
                                setModalState(() => selectedDate = date);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _formatDateShort(selectedDate),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Seat selector
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 18.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  if (selectedSeats > 1) {
                                    setModalState(() => selectedSeats--);
                                  }
                                },
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 20.sp,
                                  color: selectedSeats > 1
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  '$selectedSeats',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (selectedSeats < 4) {
                                    setModalState(() => selectedSeats++);
                                  }
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  size: 20.sp,
                                  color: selectedSeats < 4
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Results header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Rides',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        nearbyRides.when(
                          data: (rides) => Text(
                            '${rides.length} available',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          loading: () => SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Ride list
                  Expanded(
                    child: nearbyRides.when(
                      data: (rides) {
                        if (rides.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 64.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No rides available nearby',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Try expanding your search radius',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: rides.length,
                          itemBuilder: (context, index) {
                            final ride = rides[index];
                            return _buildSearchRideCard(ride, context);
                          },
                        );
                      },
                      loading: () => Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48.sp,
                              color: AppColors.error,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Failed to load rides',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a ride card for the search sheet - uses proper NearbyRidePreview model
  Widget _buildSearchRideCard(
    NearbyRidePreview ride,
    BuildContext sheetContext,
  ) {
    final formattedTime = _formatTime(ride.departureTime);

    return GestureDetector(
      onTap: () {
        sheetContext.pop();
        context.push(AppRouter.rideDetailPath(ride.id));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: ride.isPremium
              ? Border.all(
                  color: AppColors.starFilled.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Driver row
            Row(
              children: [
                PremiumAvatar(
                  imageUrl: ride.driverPhotoUrl,
                  name: ride.driverName,
                  size: 44.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ride.driverName,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (ride.isPremium) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.verified,
                              color: AppColors.starFilled,
                              size: 16.sp,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.starFilled,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            ride.driverRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${ride.pricePerSeat.toStringAsFixed(0)} €',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Route info
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 24.h,
                      color: AppColors.border,
                    ),
                    Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 14.sp,
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.originAddress.isNotEmpty
                            ? ride.originAddress
                            : 'Pickup point',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        ride.destinationAddress.isNotEmpty
                            ? ride.destinationAddress
                            : 'Destination',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Bottom row
            Row(
              children: [
                _buildSearchChip(
                  Icons.event_seat,
                  '${ride.availableSeats} seats',
                  AppColors.primary,
                ),
                SizedBox(width: 8.w),
                if (ride.isEco)
                  _buildSearchChip(Icons.eco_rounded, 'Eco', AppColors.success),
                if (ride.isPremium)
                  _buildSearchChip(
                    Icons.star_rounded,
                    'Premium',
                    AppColors.starFilled,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';
    return '${date.day}/${date.month}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Show ride details using proper NearbyRidePreview model
  void _showRideDetails(NearbyRidePreview ride) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini map preview
              Container(
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: ride.origin,
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sportconnect.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: ride.origin,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Driver info
              Row(
                children: [
                  PremiumAvatar(
                    imageUrl: ride.driverPhotoUrl,
                    name: ride.driverName,
                    size: 50.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.starFilled,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              ride.driverRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${ride.pricePerSeat.toStringAsFixed(0)} €',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Route info
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: AppColors.success,
                          size: 12.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            ride.originAddress.isNotEmpty
                                ? ride.originAddress
                                : 'Pickup location',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Container(
                        width: 2,
                        height: 20.h,
                        color: AppColors.border,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.error,
                          size: 12.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            ride.destinationAddress.isNotEmpty
                                ? ride.destinationAddress
                                : 'Destination',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Ride info
              Row(
                children: [
                  _buildRideInfoChip(
                    Icons.event_seat,
                    '${ride.availableSeats} seats',
                  ),
                  SizedBox(width: 8.w),
                  if (ride.isEco)
                    _buildRideInfoChip(
                      Icons.eco,
                      'Eco',
                      color: AppColors.success,
                    ),
                  if (ride.isPremium)
                    _buildRideInfoChip(
                      Icons.star,
                      'Premium',
                      color: AppColors.starFilled,
                    ),
                ],
              ),

              SizedBox(height: 20.h),

              // Book button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.push(AppRouter.rideDetailPath(ride.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Book This Ride',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color ?? AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
