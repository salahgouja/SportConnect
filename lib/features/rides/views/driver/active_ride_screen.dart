import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/poi_search_sheet.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/features/rides/views/widgets/ride_shared_widgets.dart';
import 'package:sport_connect/core/widgets/safety_widgets.dart';

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
  bool _hasCenteredInitialLocation = false;

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

    _initializeRideSession();
  }

  Future<void> _initializeRideSession() async {
    final rideId = widget.rideId;
    if (rideId == null || rideId.isEmpty) return;

    final notifier = ref.read(activeRideViewModelProvider(rideId).notifier);
    final initialResult = await notifier.initializeLocationTracking();

    if (!mounted ||
        initialResult != ActiveRideLocationInitResult.permissionRequired) {
      return;
    }

    final accepted = await PermissionDialogHelper.showRideTrackingRationale(
      context,
    );
    if (!mounted || !accepted) return;

    await notifier.initializeLocationTracking(requestPermission: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Open POI search sheet to find nearby places
  void _openPOISearch() {
    final rideState = ref.read(activeRideViewModelProvider(widget.rideId!));
    final currentLocation = rideState.currentLocation;
    if (currentLocation == null) return;

    POISearchSheet.show(
      context,
      currentLocation: currentLocation,
      onPOISelected: (poi) {
        ref
            .read(activeRideViewModelProvider(widget.rideId!).notifier)
            .selectPoi(poi);

        _mapController.move(poi.location, 16);
        final address = poi.tags['addr:street'] ?? poi.tags['addr:city'];
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
              onPressed: () async {
                final lat = poi.location.latitude;
                final lng = poi.location.longitude;
                final name = Uri.encodeComponent(poi.name ?? '');
                final uri = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
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

    final rideState = ref.watch(activeRideViewModelProvider(widget.rideId!));

    ref.listen<LatLng?>(
      activeRideViewModelProvider(
        widget.rideId!,
      ).select((state) => state.currentLocation),
      (_, nextLocation) {
        if (_hasCenteredInitialLocation || nextLocation == null) return;
        _hasCenteredInitialLocation = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(nextLocation, 15);
        });
      },
    );

    return rideState.ride.when(
      data: (ride) {
        if (ride == null) {
          return _buildNoRideState();
        }
        return _buildRideContent(ride, rideState);
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

  Widget _buildRideContent(RideModel ride, ActiveRideState rideState) {
    // Handle cancelled ride
    if (ride.status == RideStatus.cancelled) {
      return _buildCancelledState();
    }

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
          _buildMap(pickupLocation, dropoffLocation, rideState),

          // Top Controls
          _buildTopControls(rideState),

          // Navigation Instructions (Collapsible)
          if (rideState.isNavigationExpanded)
            _buildNavigationPanel(ride, rideState),

          // Bottom Panel with Ride Info
          _buildBottomPanel(ride, rideState),

          // Passenger Details Sheet
          if (rideState.showPassengerDetails)
            _buildPassengerSheet(ride, rideState),
        ],
      ),
    );
  }

  Widget _buildMap(
    LatLng pickupLocation,
    LatLng dropoffLocation,
    ActiveRideState rideState,
  ) {
    // Use driver's current GPS location, or fallback to pickup location if still loading
    final driverLocation = rideState.currentLocation ?? pickupLocation;

    // Show loading indicator while getting GPS location
    if (rideState.isLoadingLocation) {
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

        // Route Line — use OSRM real road route when available, else fallback to segments
        PolylineLayer(
          polylines: [
            Polyline(
              points:
                  rideState.osrmRoutePoints ??
                  [driverLocation, pickupLocation, dropoffLocation],
              color: Colors.white,
              strokeWidth: 6,
            ),
            Polyline(
              points:
                  rideState.osrmRoutePoints ??
                  [driverLocation, pickupLocation, dropoffLocation],
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
                angle: rideState.userHeading * 3.14159 / 180,
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
            if (rideState.showPOIMarkers)
              ...rideState.nearbyPOIs.map(
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

  Widget _buildTopControls(ActiveRideState rideState) {
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
                onTap: rideState.currentLocation != null
                    ? () => _mapController.move(rideState.currentLocation!, 15)
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
                    color: rideState.showPOIMarkers
                        ? AppColors.success
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
                    Icons.explore_rounded,
                    color: rideState.showPOIMarkers
                        ? Colors.white
                        : AppColors.success,
                    size: 22.w,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Toggle Navigation
              GestureDetector(
                onTap: () => ref
                    .read(activeRideViewModelProvider(widget.rideId!).notifier)
                    .toggleNavigationExpanded(),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: rideState.isNavigationExpanded
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
                    color: rideState.isNavigationExpanded
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

  Widget _buildNavigationPanel(RideModel ride, ActiveRideState rideState) {
    final nextStop = rideState.phase == ActiveRidePhase.pickingUp
        ? ride.origin.address
        : ride.destination.address;
    // Use dynamic ETA/distance from GPS position when available, else fallback to static
    final eta = rideState.remainingEtaMinutes ?? ride.durationMinutes ?? 0;
    final distance = rideState.remainingDistanceKm ?? ride.distanceKm ?? 0.0;

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
                    rideState.phase == ActiveRidePhase.pickingUp
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
                        rideState.phase == ActiveRidePhase.pickingUp
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
            // Speed indicator + progress bar
            Row(
              children: [
                // Live speed badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        '${rideState.currentSpeedKmh.toInt()} km/h',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Progress Bar
                Expanded(
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _getRideProgress(ride, rideState),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

  Widget _buildBottomPanel(RideModel ride, ActiveRideState rideState) {
    final bookings = rideState.bookings;
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
              _buildRideStatusBanner(ride, rideState),

              // Safety Check-In
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: SafetyCheckInBanner(
                  onCheckIn: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Safety check-in confirmed!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),

              // Passenger Info
              _buildPassengerInfo(ride, rideState),

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
                    onPressed: rideState.isProcessing
                        ? null
                        : () => _handleMainAction(ride),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionButtonColor(rideState.phase),
                      disabledBackgroundColor: _getActionButtonColor(
                        rideState.phase,
                      ).withValues(alpha: 0.6),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: rideState.isProcessing
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
                              Icon(
                                _getActionButtonIcon(rideState.phase),
                                size: 22.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _getActionButtonText(rideState.phase),
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

  Widget _buildRideStatusBanner(RideModel ride, ActiveRideState rideState) {
    final l10n = AppLocalizations.of(context);
    final eta = ride.durationMinutes ?? 0;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (rideState.phase) {
      case ActiveRidePhase.pickingUp:
        statusColor = AppColors.warning;
        statusText = l10n.headingToPickup;
        statusIcon = Icons.person_pin_circle;
        break;
      case ActiveRidePhase.enRoute:
        statusColor = AppColors.primary;
        statusText = l10n.tripInProgress;
        statusIcon = Icons.navigation;
        break;
      case ActiveRidePhase.arriving:
        statusColor = AppColors.success;
        statusText = l10n.headingToDestination;
        statusIcon = Icons.flag;
        break;
      case ActiveRidePhase.completed:
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
          if (rideState.phase != ActiveRidePhase.completed)
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

  Widget _buildPassengerInfo(RideModel ride, ActiveRideState rideState) {
    final bookings = rideState.bookings;
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
    final pickedUp = rideState.pickedUpPassengerIds.length;

    return GestureDetector(
      onTap: () => ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .showPassengerDetails(),
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
                      if (pickedUp > 0) ...[
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: pickedUp >= bookings.length
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '$pickedUp/${bookings.length} picked up',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: pickedUp >= bookings.length
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPassengerSheet(RideModel ride, ActiveRideState rideState) {
    final bookings = rideState.bookings;
    final booking = bookings.isNotEmpty ? bookings.first : null;
    if (booking == null) {
      return const SizedBox.shrink();
    }
    final seatsBooked = booking.seatsBooked;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ref
            .read(activeRideViewModelProvider(widget.rideId!).notifier)
            .hidePassengerDetails(),
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
                          onPressed: () => ref
                              .read(
                                activeRideViewModelProvider(
                                  widget.rideId!,
                                ).notifier,
                              )
                              .hidePassengerDetails(),
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

                    // Passenger pickup checklist
                    if (bookings.length > 0) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Pickup Checklist',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${rideState.pickedUpPassengerIds.intersection(bookings.map((b) => b.passengerId).toSet()).length}/${bookings.length}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            ...bookings.map((b) {
                              final isChecked = rideState.pickedUpPassengerIds
                                  .contains(b.passengerId);
                              return InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                        activeRideViewModelProvider(
                                          widget.rideId!,
                                        ).notifier,
                                      )
                                      .togglePickedUpPassenger(b.passengerId);
                                  HapticFeedback.selectionClick();
                                },
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isChecked
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked,
                                        color: isChecked
                                            ? AppColors.success
                                            : AppColors.textTertiary,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      PassengerAvatarWidget(
                                        passengerId: b.passengerId,
                                        radius: 16,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: PassengerNameWidget(
                                          passengerId: b.passengerId,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: isChecked
                                                ? AppColors.textSecondary
                                                : AppColors.textPrimary,
                                            decoration: isChecked
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${b.seatsBooked} seat${b.seatsBooked > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

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

  /// Calculate ride progress based on GPS position along route when available.
  double _getRideProgress(RideModel ride, ActiveRideState rideState) {
    // Use dynamic distance if available to compute real progress
    if (rideState.remainingDistanceKm != null) {
      final totalDist = ride.distanceKm ?? ride.route.distanceKm ?? 1.0;
      final progress = (1.0 - (rideState.remainingDistanceKm! / totalDist))
          .clamp(0.0, 1.0);
      // Map progress into the status phases
      switch (rideState.phase) {
        case ActiveRidePhase.pickingUp:
          return (progress * 0.3).clamp(0.0, 0.3);
        case ActiveRidePhase.enRoute:
          return (0.3 + progress * 0.5).clamp(0.3, 0.8);
        case ActiveRidePhase.arriving:
          return (0.8 + progress * 0.2).clamp(0.8, 1.0);
        case ActiveRidePhase.completed:
          return 1.0;
      }
    }
    // Fallback to static values
    switch (rideState.phase) {
      case ActiveRidePhase.pickingUp:
        return 0.25;
      case ActiveRidePhase.enRoute:
        return 0.5;
      case ActiveRidePhase.arriving:
        return 0.85;
      case ActiveRidePhase.completed:
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

  String _getActionButtonText(ActiveRidePhase phase) {
    final l10n = AppLocalizations.of(context);
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        return 'Arrived at Pickup';
      case ActiveRidePhase.enRoute:
        return l10n.completeRide;
      case ActiveRidePhase.arriving:
        return 'Drop Off Passenger';
      case ActiveRidePhase.completed:
        return l10n.rateYourRide;
    }
  }

  IconData _getActionButtonIcon(ActiveRidePhase phase) {
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        return Icons.person_pin_circle;
      case ActiveRidePhase.enRoute:
        return Icons.flag;
      case ActiveRidePhase.arriving:
        return Icons.exit_to_app;
      case ActiveRidePhase.completed:
        return Icons.star;
    }
  }

  Color _getActionButtonColor(ActiveRidePhase phase) {
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        return AppColors.success;
      case ActiveRidePhase.enRoute:
        return AppColors.primary;
      case ActiveRidePhase.arriving:
        return AppColors.warning;
      case ActiveRidePhase.completed:
        return AppColors.success;
    }
  }

  /// Handles the main action button based on current ride status.
  void _handleMainAction(RideModel ride) {
    final rideState = ref.read(activeRideViewModelProvider(widget.rideId!));
    if (rideState.isProcessing) return;

    switch (rideState.phase) {
      case ActiveRidePhase.pickingUp:
        _confirmArrivedAtPickup(ride);
        break;
      case ActiveRidePhase.enRoute:
        _confirmCompleteTrip();
        break;
      case ActiveRidePhase.arriving:
        _confirmDropOff(ride);
        break;
      case ActiveRidePhase.completed:
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

    if (confirmed != true || !context.mounted) return;

    try {
      final success = await ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .startRide();

      if (!context.mounted) return;

      if (success) {
        HapticFeedback.mediumImpact();
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
        _showErrorSnackBar(
          ref.read(activeRideViewModelProvider(widget.rideId!)).actionError ??
              l10n.failedToLoadRide,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('$e');
    }
  }

  /// Step 2: Transition to arriving state (local UI change only).
  void _confirmCompleteTrip() {
    HapticFeedback.lightImpact();
    ref
        .read(activeRideViewModelProvider(widget.rideId!).notifier)
        .transitionToArriving();
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

    if (confirmed != true || !context.mounted) return;

    try {
      final success = await ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .completeRide();

      if (!context.mounted) return;

      if (success) {
        HapticFeedback.heavyImpact();
        _showCompletionCelebration(ride);
      } else {
        _showErrorSnackBar(
          ref.read(activeRideViewModelProvider(widget.rideId!)).actionError ??
              l10n.failedToLoadRide,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('$e');
    }
  }

  /// Step 4: Navigates to the review screen so driver can rate a passenger.
  Future<void> _navigateToRating(RideModel ride) async {
    final allBookings = await ref
        .read(rideActionsViewModelProvider)
        .getBookingsByRideId(ride.id, ride.driverId);
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
        if (!context.mounted) return;
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
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotMakePhoneCalls),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
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
    final rideState = ref.read(activeRideViewModelProvider(widget.rideId!));

    // If ride is already completed, just pop without confirmation
    if (rideState.phase == ActiveRidePhase.completed) {
      context.pop();
      return;
    }

    showDialog(
      context: context,
      barrierLabel: 'Cancel ride dialog',
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
              final success = await ref
                  .read(activeRideViewModelProvider(widget.rideId!).notifier)
                  .cancelRide();
              if (!context.mounted) return;
              if (!success) {
                _showErrorSnackBar(
                  ref
                          .read(activeRideViewModelProvider(widget.rideId!))
                          .actionError ??
                      l10n.failedToLoadRide,
                );
                return;
              }
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
