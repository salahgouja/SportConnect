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
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/poi_search_sheet.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/features/rides/views/widgets/ride_shared_widgets.dart';

/// Active Ride Navigation Screen - Shows map and ride details for drivers during active rides
class DriverActiveRideScreen extends ConsumerStatefulWidget {
  final String? rideId;

  const DriverActiveRideScreen({super.key, this.rideId});

  @override
  ConsumerState<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState extends ConsumerState<DriverActiveRideScreen>
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
  bool _isProcessing = false;

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
        if (!mounted) return;
        final accepted = await PermissionDialogHelper.showRideTrackingRationale(
          context,
        );
        if (!accepted) {
          setState(() => _isLoadingLocation = false);
          return;
        }
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
    if (_currentLocation == null) return;
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
                    AppLocalizations.of(context).valueValue5(
                      poi.name ?? 'Unknown',
                      address != null ? ' - $address' : '',
                    ),
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
    // Bookings are stored in a separate collection — watch them alongside the ride
    final bookings =
        ref.watch(bookingsByRideProvider(widget.rideId!)).value ??
        const <RideBooking>[];

    return rideAsync.when(
      data: (ride) {
        if (ride == null) {
          return _buildNoRideState();
        }
        return _buildRideContent(ride, bookings);
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
              Text(
                AppLocalizations.of(context).errorLoadingRide,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(AppLocalizations.of(context).goBack),
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
        title: Text(AppLocalizations.of(context).activeRide),
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
              AppLocalizations.of(context).noActiveRide,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).startARideToSee,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideContent(RideModel ride, List<RideBooking> bookings) {
    // Handle cancelled ride
    if (ride.status == RideStatus.cancelled) {
      return _buildCancelledState();
    }

    // Sync local status with Firestore ride status (forward-only)
    _syncRideStatus(ride);

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
          _buildBottomPanel(ride, pickupLocation, dropoffLocation, bookings),

          // Passenger Details Sheet
          if (_showPassengerDetails) _buildPassengerSheet(ride, bookings),
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
                AppLocalizations.of(context).gettingYourLocation,
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
                onTap: _currentLocation != null
                    ? () => _mapController.move(_currentLocation!, 15)
                    : null,
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
                            ? AppLocalizations.of(context).headingToPickup
                            : AppLocalizations.of(context).headingToDestination,
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
                      AppLocalizations.of(
                        context,
                      ).valueKm(distance.toStringAsFixed(1)),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).valueMin(eta),
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
                  AppLocalizations.of(
                    context,
                  ).etaValueMinValueKm(eta, distance.toStringAsFixed(1)),
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  ).arrivingAtValue(_getArrivalTime(eta)),
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
    List<RideBooking> bookings,
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
              _buildRideStatusBanner(ride),

              // Passenger Info
              _buildPassengerInfo(ride, bookings),

              Divider(color: AppColors.border),

              // Trip Details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RideTripStat(
                      label: AppLocalizations.of(context).distance,
                      value: AppLocalizations.of(
                        context,
                      ).valueKm(distance.toStringAsFixed(1)),
                      icon: Icons.straighten,
                    ),
                    RideTripStat(
                      label: AppLocalizations.of(context).duration,
                      value: AppLocalizations.of(context).valueMin(duration),
                      icon: Icons.schedule,
                    ),
                    RideTripStat(
                      label: AppLocalizations.of(context).fare,
                      value: AppLocalizations.of(
                        context,
                      ).value5(fare.toStringAsFixed(0)),
                      icon: Icons.attach_money,
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
                        onPressed: () {
                          final booking = bookings.isNotEmpty
                              ? bookings.first
                              : null;
                          if (booking != null) {
                            _callPassenger(booking.passengerId);
                          }
                        },
                        icon: const Icon(Icons.phone),
                        label: Text(AppLocalizations.of(context).call),
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
                        onPressed: () async {
                          final booking = bookings.isNotEmpty
                              ? bookings.first
                              : null;
                          if (booking == null) return;

                          final currentUser = ref
                              .read(currentUserProvider)
                              .value;
                          if (currentUser == null) return;

                          try {
                            // Fetch passenger profile first
                            final passengerProfile = await ref.read(
                              userProfileProvider(booking.passengerId).future,
                            );

                            if (!mounted) return;

                            // If profile is null, fallback to default values
                            if (passengerProfile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passenger profile not found'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            final chat = await ref.read(
                              getOrCreateChatProvider(
                                userId1: currentUser.uid,
                                userId2: booking.passengerId,
                                userName1: currentUser.displayName,
                                userName2: passengerProfile.displayName,
                                userPhoto1: currentUser.photoUrl,
                                userPhoto2: passengerProfile.photoUrl,
                              ).future,
                            );

                            if (!mounted) return;

                            final passengerUser = UserModel.rider(
                              uid: booking.passengerId,
                              email: passengerProfile.email,
                              displayName: passengerProfile.displayName,
                              photoUrl: passengerProfile.photoUrl,
                            );

                            context.pushNamed(
                              AppRoutes.chatDetail.name,
                              pathParameters: {'id': chat.id},
                              extra: passengerUser,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Failed to open chat. Please try again.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.message),
                        label: Text(AppLocalizations.of(context).message),
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
                    onPressed: _isProcessing
                        ? null
                        : () => _handleMainAction(ride),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionButtonColor(),
                      disabledBackgroundColor: _getActionButtonColor()
                          .withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            height: 22.w,
                            width: 22.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
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

  Widget _buildRideStatusBanner(RideModel ride) {
    final l10n = AppLocalizations.of(context);
    final eta = ride.durationMinutes ?? 0;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        statusColor = AppColors.warning;
        statusText = l10n.headingToPickup;
        statusIcon = Icons.person_pin_circle;
        break;
      case _RideStatus.enRoute:
        statusColor = AppColors.primary;
        statusText = l10n.tripInProgress;
        statusIcon = Icons.navigation;
        break;
      case _RideStatus.arriving:
        statusColor = AppColors.success;
        statusText = l10n.headingToDestination;
        statusIcon = Icons.flag;
        break;
      case _RideStatus.completed:
        statusColor = AppColors.success;
        statusText = l10n.rideCompleted;
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
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          if (_rideStatus != _RideStatus.completed)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                l10n.valueMin(eta),
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

  Widget _buildPassengerInfo(RideModel ride, List<RideBooking> bookings) {
    // Get first accepted booking as primary passenger
    final booking = bookings.isNotEmpty ? bookings.first : null;
    if (booking == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Text(
          'No passengers',
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
      );
    }

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
            PassengerAvatarWidget(passengerId: booking.passengerId, radius: 25),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PassengerNameWidget(
                        passengerId: booking.passengerId,
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
                            AppLocalizations.of(
                              context,
                            ).valueMore(passengerCount - 1),
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
                        AppLocalizations.of(context).valuePassengerValue(
                          passengerCount,
                          passengerCount != 1 ? 's' : '',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        AppLocalizations.of(context).valueSeatValueBooked(
                          booking.seatsBooked,
                          booking.seatsBooked != 1 ? 's' : '',
                        ),
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

  Widget _buildPassengerSheet(RideModel ride, List<RideBooking> bookings) {
    final booking = bookings.isNotEmpty ? bookings.first : null;
    if (booking == null) {
      return const SizedBox.shrink();
    }
    final seatsBooked = booking.seatsBooked;

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
                        PassengerAvatarWidget(
                          passengerId: booking.passengerId,
                          radius: 30,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PassengerNameWidget(
                                passengerId: booking.passengerId,
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
                                    AppLocalizations.of(
                                      context,
                                    ).valueSeatValueBooked2(
                                      seatsBooked,
                                      seatsBooked > 1 ? 's' : '',
                                    ),
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
                          tooltip: 'Close passenger details',
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
                          AppLocalizations.of(context).value2(ride.bookedSeats),
                          AppLocalizations.of(context).passengers,
                        ),
                        _buildPassengerStat(
                          AppLocalizations.of(
                            context,
                          ).value2(ride.pricePerSeat.toStringAsFixed(0)),
                          AppLocalizations.of(context).seat2,
                        ),
                        _buildPassengerStat(
                          AppLocalizations.of(
                            context,
                          ).value2(ride.durationMinutes ?? 0),
                          AppLocalizations.of(context).min,
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
                            AppLocalizations.of(context).pickup,
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
                            AppLocalizations.of(context).dropoff,
                            ride.destination.address,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Notes (if any ride notes exist)
                    if (bookings.isNotEmpty)
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
                                AppLocalizations.of(
                                  context,
                                ).valuePassengerValueBookedFor(
                                  bookings.length,
                                  bookings.length > 1 ? 's' : '',
                                ),
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
    final l10n = AppLocalizations.of(context);
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        return 'Arrived at Pickup';
      case _RideStatus.enRoute:
        return l10n.completeRide;
      case _RideStatus.arriving:
        return 'Drop Off Passenger';
      case _RideStatus.completed:
        return l10n.rateYourRide;
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

  /// Sync local ride status with Firestore ride status (forward-only).
  void _syncRideStatus(RideModel ride) {
    if (ride.status == RideStatus.completed) {
      _rideStatus = _RideStatus.completed;
    } else if (ride.status == RideStatus.inProgress &&
        _rideStatus == _RideStatus.pickingUp) {
      _rideStatus = _RideStatus.enRoute;
    }
  }

  /// Handles the main action button based on current ride status.
  void _handleMainAction(RideModel ride) {
    if (_isProcessing) return;
    switch (_rideStatus) {
      case _RideStatus.pickingUp:
        _confirmArrivedAtPickup(ride);
        break;
      case _RideStatus.enRoute:
        _confirmCompleteTrip();
        break;
      case _RideStatus.arriving:
        _confirmDropOff(ride);
        break;
      case _RideStatus.completed:
        _navigateToRating(ride);
        break;
    }
  }

  /// Step 1: Driver arrived at pickup → Confirms and starts ride in Firestore.
  Future<void> _confirmArrivedAtPickup(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.person_pin_circle, color: AppColors.success),
            SizedBox(width: 8.w),
            Expanded(child: Text(l10n.startRide)),
          ],
        ),
        content: Text(l10n.markThisRideAsStarted),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.goBack),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(l10n.startRide),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final success = await ref
          .read(rideDetailViewModelProvider(widget.rideId!).notifier)
          .startRide();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        HapticFeedback.mediumImpact();
        setState(() => _rideStatus = _RideStatus.enRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8.w),
                Text(l10n.rideInProgress),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else {
        _showErrorSnackBar(l10n.failedToLoadRide);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorSnackBar('$e');
    }
  }

  /// Step 2: Transition to arriving state (local UI change only).
  void _confirmCompleteTrip() {
    HapticFeedback.lightImpact();
    setState(() => _rideStatus = _RideStatus.arriving);
  }

  /// Step 3: Drop off passenger → Completes ride in Firestore.
  Future<void> _confirmDropOff(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.flag, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(child: Text(l10n.completeRide)),
          ],
        ),
        content: Text(l10n.markThisRideAsCompleted),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.goBack),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(l10n.completeRide),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final success = await ref
          .read(rideDetailViewModelProvider(widget.rideId!).notifier)
          .completeRide();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        HapticFeedback.heavyImpact();
        setState(() => _rideStatus = _RideStatus.completed);
        _showCompletionCelebration(ride);
      } else {
        _showErrorSnackBar(l10n.failedToLoadRide);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorSnackBar('$e');
    }
  }

  /// Step 4: Navigates to the review screen so driver can rate a passenger.
  Future<void> _navigateToRating(RideModel ride) async {
    final allBookings =
        await ref.read(bookingRepositoryProvider).getBookingsByRideId(ride.id);
    final booking = allBookings
        .where((b) => b.status == BookingStatus.accepted)
        .firstOrNull;
    if (booking == null) {
      // No passengers to rate — go to completion screen
      context.pushReplacement(
        AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
      );
      return;
    }

    try {
      // Fetch passenger profile for review
      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (!mounted) return;

      // If profile doesn't exist, still navigate but with fallback
      final displayName = passengerProfile?.displayName ?? 'Passenger';
      final photoUrl = passengerProfile?.photoUrl ?? '';

      context.push(
        '${AppRoutes.submitReview.path}'
        '?rideId=${ride.id}'
        '&revieweeId=${booking.passengerId}'
        '&revieweeName=${Uri.encodeComponent(displayName)}'
        '&revieweePhotoUrl=${Uri.encodeComponent(photoUrl)}'
        '&reviewType=passengerReview',
      );
    } catch (e) {
      if (!mounted) return;
      // If profile fetch fails, still navigate but without name/photo
      context.push(
        '${AppRoutes.submitReview.path}'
        '?rideId=${ride.id}'
        '&revieweeId=${booking.passengerId}'
        '&revieweeName=${Uri.encodeComponent('Passenger')}'
        '&revieweePhotoUrl='
        '&reviewType=passengerReview',
      );
    }
  }

  /// Shows a celebration bottom sheet when the ride is completed.
  void _showCompletionCelebration(RideModel ride) {
    final l10n = AppLocalizations.of(context);
    final fare =
        ride.pricePerSeat * (ride.bookedSeats > 0 ? ride.bookedSeats : 1);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48.w,
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.rideCompletedWellDone,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 8.h),
            Text(
              l10n.value5(fare.toStringAsFixed(0)),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ).animate().fadeIn(delay: 500.ms),
            SizedBox(height: 8.h),
            Text(
              '${ride.origin.address} → ${ride.destination.address}',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(delay: 600.ms),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(l10n.goBack),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateToRating(ride);
                    },
                    icon: const Icon(Icons.star),
                    label: Text(l10n.rateYourRide),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  /// Shows an error snackbar with the given message.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  /// Calls a passenger using the device phone dialer.
  Future<void> _callPassenger(String passengerId) async {
    try {
      final passenger = await ref.read(userProfileProvider(passengerId).future);
      final phoneNumber = passenger?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).phoneNumberNotAvailable),
          ),
        );
        return;
      }

      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotMakePhoneCalls),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToLaunchDialer),
        ),
      );
    }
  }

  /// Builds the UI state shown when the ride has been cancelled.
  Widget _buildCancelledState() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 48.w,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.rideCancelledSuccessfully,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows exit / cancel ride confirmation dialog.
  void _showExitConfirmation() {
    final l10n = AppLocalizations.of(context);

    // If ride is already completed, just pop without confirmation
    if (_rideStatus == _RideStatus.completed) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(l10n.cancelRide),
        content: Text(l10n.areYouSureYouWant7),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.continueRide),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isProcessing = true);
              try {
                await ref
                    .read(rideDetailViewModelProvider(widget.rideId!).notifier)
                    .cancelRide();
              } catch (_) {
                // Cancellation failed — still pop to avoid stuck state
              }
              if (!mounted) return;
              setState(() => _isProcessing = false);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(l10n.cancelRide2),
          ),
        ],
      ),
    );
  }
}

enum _RideStatus { pickingUp, enRoute, arriving, completed }
