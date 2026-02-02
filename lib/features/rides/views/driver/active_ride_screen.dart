import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/poi_search_sheet.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

/// Active Ride Navigation Screen - Shows map and ride details for drivers during active rides
class ActiveRideScreen extends ConsumerStatefulWidget {
  final String? rideId;

  const ActiveRideScreen({super.key, this.rideId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  // Ride navigation status
  _RideStatus _rideStatus = _RideStatus.pickingUp;

  // Current driver location (updated by GPS location service)
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  double _userHeading = 0.0;

  bool _isNavigationExpanded = true;
  bool _showPassengerDetails = false;

  // POI search state
  List<PointOfInterest> _nearbyPOIs = [];
  bool _showPOIMarkers = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize GPS location tracking for driver
    _initLocationTracking();
  }

  /// Initialize GPS location tracking for real-time driver position
  Future<void> _initLocationTracking() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get initial position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _userHeading = position.heading;
          _isLoadingLocation = false;
        });

        // Center map on driver location
        _mapController.move(_currentLocation!, 15);
      }

      // Start continuous location tracking
      _startLocationStream();
    } catch (e) {
      TalkerService.error('Error initializing location: $e');
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  /// Start continuous GPS location stream for real-time updates
  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
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
          }
        });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Open POI search sheet to find nearby places
  void _openPOISearch() {
    POISearchSheet.show(
      context,
      currentLocation: _currentLocation!,
      onPOISelected: (poi) {
        // Add selected POI to map and navigate to it
        setState(() {
          _nearbyPOIs = [poi];
          _showPOIMarkers = true;
        });

        // Move map to show the POI
        _mapController.move(poi.location, 16);

        // Get address from tags
        final address = poi.tags['addr:street'] ?? poi.tags['addr:city'];

        // Show snackbar with POI info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.place, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${poi.name ?? 'Unknown'}${address != null ? ' - $address' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Navigate',
              textColor: Colors.white,
              onPressed: () {
                // Could open external navigation
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have a valid ride ID
    if (widget.rideId == null || widget.rideId!.isEmpty) {
      return _buildNoRideState();
    }

    // Watch the ride stream for real-time updates
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId!));

    return rideAsync.when(
      data: (ride) {
        if (ride == null) {
          return _buildNoRideState();
        }
        return _buildRideContent(ride);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text('Error loading ride', style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRideState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Ride'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
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
              'No active ride',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start a ride to see navigation',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideContent(RideModel ride) {
    // Get locations from the ride model
    final pickupLocation = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dropoffLocation = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(pickupLocation, dropoffLocation),

          // Top Controls
          _buildTopControls(),

          // Navigation Instructions (Collapsible)
          if (_isNavigationExpanded) _buildNavigationPanel(ride),

          // Bottom Panel with Ride Info
          _buildBottomPanel(ride, pickupLocation, dropoffLocation),

          // Passenger Details Sheet
          if (_showPassengerDetails) _buildPassengerSheet(ride),
        ],
      ),
    );
  }

  Widget _buildMap(LatLng pickupLocation, LatLng dropoffLocation) {
    // Use driver's current GPS location, or fallback to pickup location if still loading
    final driverLocation = _currentLocation ?? pickupLocation;

    // Show loading indicator while getting GPS location
    if (_isLoadingLocation) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Getting your location...',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: driverLocation, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sportconnect.app',
        ),

        // Route Line
        PolylineLayer(
          polylines: [
            Polyline(
              points: [driverLocation, pickupLocation, dropoffLocation],
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ],
        ),

        // Markers
        MarkerLayer(
          markers: [
            // Current Location Marker (Driver's real GPS position)
            Marker(
              point: driverLocation,
              width: 50.w,
              height: 50.w,
              child: Transform.rotate(
                angle:
                    _userHeading * 3.14159 / 180, // Convert heading to radians
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50.w * (1 + _pulseController.value * 0.3),
                          height: 50.w * (1 + _pulseController.value * 0.3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: 0.3 * (1 - _pulseController.value),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 18.w,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Pickup Marker
            Marker(
              point: pickupLocation,
              width: 40.w,
              height: 40.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(Icons.person_pin, color: Colors.white, size: 22.w),
              ),
            ),

            // Dropoff Marker
            Marker(
              point: dropoffLocation,
              width: 40.w,
              height: 40.w,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(Icons.flag, color: Colors.white, size: 20.w),
              ),
            ),

            // POI Markers (if any)
            if (_showPOIMarkers)
              ..._nearbyPOIs.map(
                (poi) => Marker(
                  point: poi.location,
                  width: 40.w,
                  height: 40.w,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.place_rounded,
                      color: Colors.white,
                      size: 22.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => _showExitConfirmation(),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 22.w,
                  ),
                ),
              ),

              const Spacer(),

              // Recenter Button
              GestureDetector(
                onTap: () {
                  _mapController.move(_currentLocation!, 15);
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                    size: 22.w,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // POI Search Button - Find nearby places
              GestureDetector(
                onTap: () => _openPOISearch(),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _showPOIMarkers ? AppColors.success : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.explore_rounded,
                    color: _showPOIMarkers ? Colors.white : AppColors.success,
                    size: 22.w,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Toggle Navigation
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isNavigationExpanded = !_isNavigationExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _isNavigationExpanded
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions,
                    color: _isNavigationExpanded
                        ? Colors.white
                        : AppColors.primary,
                    size: 22.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: -0.3),
    );
  }

  Widget _buildNavigationPanel(RideModel ride) {
    final nextStop = _rideStatus == _RideStatus.pickingUp
        ? ride.origin.address
        : ride.destination.address;
    final eta = ride.durationMinutes ?? 0;
    final distance = ride.distanceKm ?? 0.0;

    return Positioned(
      top: 100.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _rideStatus == _RideStatus.pickingUp
                        ? Icons.person_pin_circle
                        : Icons.flag,
                    color: Colors.white,
                    size: 28.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _rideStatus == _RideStatus.pickingUp
                            ? 'Heading to pickup'
                            : 'Heading to destination',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        nextStop,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$eta min',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Progress Bar
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getRideProgress(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ETA: $eta min • ${distance.toStringAsFixed(1)} km remaining',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
                Text(
                  'Arriving at ${_getArrivalTime(eta)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildBottomPanel(
    RideModel ride,
    LatLng pickupLocation,
    LatLng dropoffLocation,
  ) {
    final distance = ride.distanceKm ?? 0.0;
    final duration = ride.durationMinutes ?? 0;
    final fare =
        ride.pricePerSeat * (ride.bookedSeats > 0 ? ride.bookedSeats : 1);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Ride Status
              _buildRideStatusBanner(),

              // Passenger Info
              _buildPassengerInfo(ride),

              Divider(color: AppColors.border),

              // Trip Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTripStat(
                      'Distance',
                      '${distance.toStringAsFixed(1)} km',
                      Icons.straighten,
                    ),
                    _buildTripStat('Duration', '$duration min', Icons.schedule),
                    _buildTripStat(
                      'Fare',
                      '${fare.toStringAsFixed(0)} €',
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    // Call Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Message Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Main Action Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleMainAction(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionButtonColor(),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getActionButtonIcon(), size: 22.w),
                        SizedBox(width: 8.w),
                        Text(
                          _getActionButtonText(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.3),
    );
  }

  Widget _buildRideStatusBanner() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        statusColor = AppColors.warning;
        statusText = 'Heading to pickup';
        statusIcon = Icons.person_pin_circle;
        break;
      case _RideStatus.enRoute:
        statusColor = AppColors.primary;
        statusText = 'Trip in progress';
        statusIcon = Icons.navigation;
        break;
      case _RideStatus.arriving:
        statusColor = AppColors.success;
        statusText = 'Arriving at destination';
        statusIcon = Icons.flag;
        break;
      case _RideStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Trip completed';
        statusIcon = Icons.check_circle;
        break;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20.w),
          SizedBox(width: 8.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '5 min',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo(RideModel ride) {
    // Get first booking as primary passenger
    final booking = ride.bookings.isNotEmpty ? ride.bookings.first : null;
    final passengerName = booking?.passengerName ?? 'No passengers';
    final passengerCount = ride.bookedSeats;

    return GestureDetector(
      onTap: () {
        setState(() {
          _showPassengerDetails = true;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            PremiumAvatar(
              name: passengerName,
              imageUrl: booking?.passengerPhotoUrl,
              size: 50.w,
              hasBorder: true,
              borderColor: AppColors.primary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        passengerName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (passengerCount > 1) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '+${passengerCount - 1} more',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 14.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$passengerCount passenger${passengerCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '• ${booking?.seatsBooked ?? 1} seat${(booking?.seatsBooked ?? 1) != 1 ? 's' : ''} booked',
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
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20.w),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPassengerSheet(RideModel ride) {
    final booking = ride.bookings.isNotEmpty ? ride.bookings.first : null;
    final passengerName = booking?.passengerName ?? 'Unknown Passenger';
    final seatsBooked = booking?.seatsBooked ?? 1;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showPassengerDetails = false;
          });
        },
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        PremiumAvatar(
                          name: passengerName,
                          imageUrl: booking?.passengerPhotoUrl,
                          size: 60.w,
                          hasBorder: true,
                          borderColor: AppColors.primary,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                passengerName,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_seat,
                                    color: AppColors.primary,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '$seatsBooked seat${seatsBooked > 1 ? 's' : ''} booked',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showPassengerDetails = false;
                            });
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPassengerStat(
                          '${ride.bookedSeats}',
                          'Passengers',
                        ),
                        _buildPassengerStat(
                          '${ride.pricePerSeat.toStringAsFixed(0)}',
                          '€/seat',
                        ),
                        _buildPassengerStat(
                          '${ride.durationMinutes ?? 0}',
                          'min',
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Trip Details
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          _buildLocationRow(
                            Icons.radio_button_checked,
                            AppColors.success,
                            'Pickup',
                            ride.origin.address,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.w),
                            child: Container(
                              width: 2,
                              height: 24.h,
                              color: AppColors.border,
                            ),
                          ),
                          _buildLocationRow(
                            Icons.location_on,
                            AppColors.error,
                            'Dropoff',
                            ride.destination.address,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Notes (if any ride notes exist)
                    if (ride.bookings.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                '${ride.bookings.length} passenger${ride.bookings.length > 1 ? 's' : ''} booked for this ride',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildPassengerStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    Color color,
    String label,
    String address,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Calculate ride progress based on current status
  double _getRideProgress() {
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        return 0.25;
      case _RideStatus.enRoute:
        return 0.5;
      case _RideStatus.arriving:
        return 0.85;
      case _RideStatus.completed:
        return 1.0;
    }
  }

  /// Calculate arrival time based on ETA
  String _getArrivalTime(int etaMinutes) {
    final now = DateTime.now();
    final arrival = now.add(Duration(minutes: etaMinutes));
    final hour = arrival.hour;
    final minute = arrival.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getActionButtonText() {
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        return 'Arrived at Pickup';
      case _RideStatus.enRoute:
        return 'Complete Trip';
      case _RideStatus.arriving:
        return 'Drop Off Passenger';
      case _RideStatus.completed:
        return 'Rate Passenger';
    }
  }

  IconData _getActionButtonIcon() {
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        return Icons.person_pin_circle;
      case _RideStatus.enRoute:
        return Icons.flag;
      case _RideStatus.arriving:
        return Icons.exit_to_app;
      case _RideStatus.completed:
        return Icons.star;
    }
  }

  Color _getActionButtonColor() {
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        return AppColors.success;
      case _RideStatus.enRoute:
        return AppColors.primary;
      case _RideStatus.arriving:
        return AppColors.warning;
      case _RideStatus.completed:
        return AppColors.success;
    }
  }

  void _handleMainAction() {
    // Handle action based on ride status
    // This would update the ride status and potentially navigate
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride?'),
        content: const Text(
          'Are you sure you want to cancel this ride? This may affect your driver rating.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Continue Ride'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: Text(
              'Cancel Ride',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RideStatus { pickingUp, enRoute, arriving, completed }
