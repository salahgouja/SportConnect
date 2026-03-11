import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/safety_widgets.dart';
import 'package:sport_connect/core/widgets/ride_feature_widgets.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';
import 'package:sport_connect/core/widgets/misc_feature_widgets.dart';

/// Active Ride Screen  - shows real-time ride status from Firestore
class PassengerActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const PassengerActiveRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<PassengerActiveRideScreen> createState() =>
      _PassengerActiveRideScreenState();
}

class _PassengerActiveRideScreenState
    extends ConsumerState<PassengerActiveRideScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  // MapController for live tracking map — allows auto-panning to driver
  final MapController _liveMapController = MapController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _liveMapController.dispose();
    super.dispose();
  }

  /// Shares live trip details with contacts.
  Future<void> _shareTrip(RideModel ride) async {
    HapticFeedback.mediumImpact();
    final currentUser = ref.read(currentUserProvider).value;
    final userName = currentUser?.displayName ?? 'A passenger';
    final origin = ride.origin.address;
    final destination = ride.destination.address;
    final status = ride.status == RideStatus.inProgress
        ? 'currently on a ride'
        : 'about to ride';
    final msg =
        '$userName is $status with SportConnect.\n\n'
        'From: $origin\n'
        'To: $destination\n'
        'Ride ID: ${ride.id.substring(0, 8).toUpperCase()}\n\n'
        'Departure: ${_formatDateTime(ride.departureTime)}';

    await SharePlus.instance.share(ShareParams(text: msg));
  }

  /// Returns true if it's currently nighttime (between 8 PM and 6 AM).
  bool get _isNightTime {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 6;
  }

  @override
  Widget build(BuildContext context) {
    final rideState = ref.watch(activeRideViewModelProvider(widget.rideId));
    final rideAsync = rideState.ride;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        data: (ride) => ride == null
            ? _buildRideNotFound()
            : _buildActiveRideContent(context, ride, rideState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).failedToLoadRide,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                e.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).rideNotFound,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).thisRideMayHaveBeen,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          PremiumButton(
            text: 'Go Home',
            onPressed: () => context.go(AppRoutes.splash.path),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideContent(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final driverAsync = ref.watch(currentUserProfileProvider(ride.driverId));

    // Auto-navigate to completion screen when driver marks ride as done.
    if (ride.status == RideStatus.completed &&
        !rideState.hasAutoNavigatedToCompletion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(activeRideViewModelProvider(widget.rideId).notifier)
              .markCompletionNavigationHandled();
          context.pushReplacement(
            AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
          );
        }
      });
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ride)),
        // Night safety banner — shown when riding after dark
        if (_isNightTime && ride.status == RideStatus.inProgress)
          SliverToBoxAdapter(
            child: _buildNightSafetyBanner(
              context,
            ).animate().fadeIn(duration: 300.ms),
          ),
        // Route deviation alert — shown when driver goes off-route
        if (rideState.isOffRoute && ride.status == RideStatus.inProgress)
          SliverToBoxAdapter(
            child: _buildRouteDeviationAlert(context, rideState)
                .animate()
                .fadeIn(duration: 300.ms)
                .shake(hz: 2, offset: const Offset(2, 0)),
          ),
        // Live driver tracking map — shown when ride is in progress
        if (ride.status == RideStatus.inProgress)
          SliverToBoxAdapter(
            child: _buildLiveTrackingMap(context, ride, rideState)
                .animate()
                .fadeIn(duration: 400.ms, delay: 50.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        // Static route map — shown for scheduled/active/completed rides (not inProgress)
        if (ride.status != RideStatus.inProgress)
          SliverToBoxAdapter(
            child: _buildStaticRouteMap(context, ride, rideState)
                .animate()
                .fadeIn(duration: 400.ms, delay: 50.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        // Share trip row + Safety check-in (only during active ride)
        if (ride.status == RideStatus.inProgress)
          SliverToBoxAdapter(
            child: _buildShareTripRow(context, ride)
                .animate()
                .fadeIn(duration: 400.ms, delay: 75.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        // Safety check-in banner (only during active ride)
        if (ride.status == RideStatus.inProgress)
          SliverToBoxAdapter(
            child: Padding(
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
          ),
        SliverToBoxAdapter(
          child: _buildStatusSection(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        // Ride sharing link
        SliverToBoxAdapter(
          child:
              Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 4.h,
                    ),
                    child: RideSharingLink(
                      rideId: ride.id,
                      onShare: () {
                        HapticFeedback.lightImpact();
                        Share.share(
                          'Track my ride on SportConnect! Ride ID: ${ride.id}',
                        );
                      },
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: driverAsync
              .when(
                data: (driver) => _buildDriverInfo(context, driver, ride),
                loading: () => const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        // Vehicle photo match for easy identification
        if (ride.vehicleId != null || ride.vehicleInfo != null)
          SliverToBoxAdapter(
            child:
                Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      child: Builder(
                        builder: (context) {
                          if (ride.vehicleId != null) {
                            final vehiclesAsync = ref.watch(
                              userVehiclesStreamProvider(ride.driverId),
                            );
                            return vehiclesAsync.when(
                              data: (vehicles) {
                                final vehicle = vehicles
                                    .where((v) => v.id == ride.vehicleId)
                                    .firstOrNull;
                                if (vehicle == null) {
                                  return const SizedBox.shrink();
                                }
                                return VehiclePhotoMatchCard(
                                  vehicleMake: vehicle.make,
                                  vehicleModel: vehicle.model,
                                  vehicleColor: vehicle.color,
                                  licensePlate: vehicle.licensePlate,
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            );
                          }
                          // Fallback: parse from vehicleInfo string
                          final parts = ride.vehicleInfo!.split(' ');
                          return VehiclePhotoMatchCard(
                            vehicleMake: parts.firstOrNull ?? '',
                            vehicleModel: parts.skip(1).join(' '),
                            vehicleColor: '',
                            licensePlate: '',
                          );
                        },
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        SliverToBoxAdapter(
          child: _buildRouteDetails(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: _buildPassengersList(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        // Post-ride review prompt — shown when ride is completed
        if (ride.status == RideStatus.completed && !rideState.hasSkippedReview)
          SliverToBoxAdapter(
            child:
                Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: PostRideReviewPrompt(
                        driverName: driverAsync.value?.displayName ?? 'Driver',
                        onRate: (rating) => _showRatingDialog(context, ride),
                        onSkip: () => ref
                            .read(activeRideViewModelProvider(widget.rideId).notifier)
                            .skipReviewPrompt(),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 450.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        SliverToBoxAdapter(
          child: _buildActionButtons(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  /// Builds a live map showing driver's real-time position from Firestore,
  /// OSRM route polyline, origin/destination markers, and real-time ETA.
  Widget _buildLiveTrackingMap(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 250.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Map
            Builder(
              builder: (context) {
                final driverLoc = rideState.driverLiveLocation;
                final driverLatLng = driverLoc != null
                    ? LatLng(driverLoc.latitude, driverLoc.longitude)
                    : originLatLng;

                // Calculate real-time ETA from driver position to destination
                final distToDest = rideState.remainingDistanceKm ?? ride.distanceKm ?? 0;

                // Estimate ETA: use ride duration ratio or 30 km/h average
                final etaMinutes = rideState.remainingEtaMinutes ??
                    ((ride.durationMinutes ?? 30) * 0.5).round();

                // Auto-pan the live map to follow the driver
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _liveMapController.move(driverLatLng, 15);
                  }
                });

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _liveMapController,
                      options: MapOptions(
                        initialCenter: driverLatLng,
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.sportconnect.app',
                        ),
                        // Route polyline — OSRM road route
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points:
                                  rideState.osrmRoutePoints ??
                                  [originLatLng, destLatLng],
                              color: Colors.white,
                              strokeWidth: 6,
                            ),
                            Polyline(
                              points:
                                  rideState.osrmRoutePoints ??
                                  [originLatLng, destLatLng],
                              color: AppColors.primary,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        // Markers
                        MarkerLayer(
                          markers: [
                            // Driver's live position (pulsing)
                            if (driverLoc != null)
                              Marker(
                                point: driverLatLng,
                                width: 44.w,
                                height: 44.w,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width:
                                              44.w *
                                              (1 +
                                                  _pulseController.value * 0.3),
                                          height:
                                              44.w *
                                              (1 +
                                                  _pulseController.value * 0.3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha:
                                                  0.3 *
                                                  (1 - _pulseController.value),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: 28.w,
                                          height: 28.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.directions_car,
                                            color: Colors.white,
                                            size: 16.w,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            // Origin marker
                            Marker(
                              point: originLatLng,
                              width: 36.w,
                              height: 36.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 18.w,
                                ),
                              ),
                            ),
                            // Destination marker
                            Marker(
                              point: destLatLng,
                              width: 36.w,
                              height: 36.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 18.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ETA overlay
                    Positioned(
                      bottom: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              color: Colors.white,
                              size: 16.w,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              driverLoc != null
                                  ? (etaMinutes < 1
                                        ? 'Arriving'
                                        : AppLocalizations.of(
                                            context,
                                          ).valueMin(etaMinutes))
                                  : 'Waiting for driver...',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Distance remaining overlay
                    if (driverLoc != null)
                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              Icon(
                                Icons.straighten,
                                color: AppColors.textPrimary,
                                size: 16.w,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                distToDest < 1
                                    ? '${(distToDest * 1000).toInt()} m'
                                    : '${distToDest.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Live indicator
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: driverLoc != null
                              ? AppColors.success
                              : AppColors.textSecondary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              driverLoc != null ? 'LIVE' : 'OFFLINE',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Static route map preview for non-inProgress states (scheduled, active, completed).
  Widget _buildStaticRouteMap(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );
    final center = LatLng(
      (originLatLng.latitude + destLatLng.latitude) / 2,
      (originLatLng.longitude + destLatLng.longitude) / 2,
    );
    final routePoints = rideState.osrmRoutePoints ?? [originLatLng, destLatLng];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sportconnect.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.white,
                      strokeWidth: 6,
                    ),
                    Polyline(
                      points: routePoints,
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: originLatLng,
                      width: 36.w,
                      height: 36.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 18.w,
                        ),
                      ),
                    ),
                    // Waypoint markers
                    ...ride.route.waypoints.map(
                      (wp) => Marker(
                        point: LatLng(
                          wp.location.latitude,
                          wp.location.longitude,
                        ),
                        width: 30.w,
                        height: 30.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 14.w,
                          ),
                        ),
                      ),
                    ),
                    Marker(
                      point: destLatLng,
                      width: 36.w,
                      height: 36.w,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 18.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Distance / duration overlay
            if (ride.route.distanceKm != null ||
                ride.route.durationMinutes != null)
              Positioned(
                bottom: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ride.route.distanceKm != null) ...[
                        Icon(
                          Icons.straighten_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ride.route.formattedDistance,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      if (ride.route.distanceKm != null &&
                          ride.route.durationMinutes != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      if (ride.route.durationMinutes != null) ...[
                        Icon(
                          Icons.schedule_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ride.route.formattedDuration,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Status badge
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ride.status == RideStatus.completed
                      ? AppColors.success
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  ride.status == RideStatus.completed
                      ? AppLocalizations.of(context).rideCompleted
                      : AppLocalizations.of(context).routeDetails,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RideModel ride) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Go back',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Spacer(),
                  _buildStatusBadge(ride.status),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).activeRide,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _formatDateTime(ride.departureTime),
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RideStatus status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case RideStatus.draft:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.2);
        textColor = AppColors.textSecondary;
        label = 'Draft';
        icon = Icons.edit_outlined;
        break;
      case RideStatus.active:
        bgColor = AppColors.info.withValues(alpha: 0.2);
        textColor = AppColors.info;
        label = 'Active';
        icon = Icons.check_circle_outline;
        break;
      case RideStatus.full:
        bgColor = AppColors.warning.withValues(alpha: 0.2);
        textColor = AppColors.warning;
        label = 'Full';
        icon = Icons.people;
        break;
      case RideStatus.inProgress:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'In Progress';
        icon = Icons.directions_car;
        break;
      case RideStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'Completed';
        icon = Icons.done_all;
        break;
      case RideStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.2);
        textColor = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusStep(
            AppLocalizations.of(context).rideConfirmed,
            ride.status.index >= RideStatus.active.index,
            Icons.check_circle,
          ),
          _buildStatusDivider(ride.status.index >= RideStatus.inProgress.index),
          _buildStatusStep(
            AppLocalizations.of(context).driverOnTheWay,
            ride.status.index >= RideStatus.inProgress.index,
            Icons.directions_car,
          ),
          _buildStatusDivider(ride.status == RideStatus.completed),
          _buildStatusStep(
            AppLocalizations.of(context).rideCompleted,
            ride.status == RideStatus.completed,
            Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isCompleted, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isCompleted ? Colors.white : AppColors.textTertiary,
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isCompleted
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          Icon(Icons.check, size: 20.sp, color: AppColors.success),
      ],
    );
  }

  Widget _buildStatusDivider(bool isActive) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24.h,
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(
    BuildContext context,
    UserModel? driver,
    RideModel ride,
  ) {
    if (driver == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: driver.photoUrl != null
                ? NetworkImage(driver.photoUrl!)
                : null,
            child: driver.photoUrl == null
                ? Text(
                    driver.displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (driver.isIdVerified)
                      Icon(Icons.verified, size: 16.sp, color: Colors.blue),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      driver.rating.average.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).valueRides2(driver.rating.total),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Message driver',
                onPressed: () => _sendMessage(driver.uid),
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Call driver',
                onPressed: driver.phoneNumber != null
                    ? () => _callDriver(driver.phoneNumber)
                    : null,
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color:
                        (driver.phoneNumber != null
                                ? Colors.green
                                : Colors.grey)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.phone,
                    color: driver.phoneNumber != null
                        ? Colors.green
                        : Colors.grey,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(BuildContext context, RideModel ride) {
    final passedWaypoints = ref
        .watch(activeRideViewModelProvider(widget.rideId))
        .passedWaypointIndices;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).routeDetails,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.my_location,
                  size: 18.sp,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).pickup,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.origin.address,
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
          ),
          // Dotted line
          Container(
            padding: EdgeInsets.only(left: 16.w),
            height: 24.h,
            width: 2,
            margin: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          // Waypoints
          if (ride.route.waypoints.isNotEmpty)
            ...ride.route.waypoints.map((wp) {
              final isPassed = passedWaypoints.contains(wp.order);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? AppColors.success.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          isPassed
                              ? Icons.check_circle_rounded
                              : Icons.flag_circle,
                          size: 18.sp,
                          color: isPassed ? AppColors.success : Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Waypoint ${wp.order + 1}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                if (isPassed) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Passed',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              wp.location.address,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isPassed
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                                decoration: isPassed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 16.w),
                    height: 24.h,
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: isPassed
                              ? AppColors.success
                              : AppColors.border,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).destination,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.destination.address,
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
          ),
          // Event badge
          if (ride.eventId != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 12.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      ride.eventName ?? 'Event',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          // Ride info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoItem(
                icon: Icons.attach_money,
                value: AppLocalizations.of(
                  context,
                ).value5(ride.pricePerSeat.toStringAsFixed(0)),
                label: AppLocalizations.of(context).perSeat2,
              ),
              InfoItem(
                icon: Icons.event_seat,
                value: AppLocalizations.of(
                  context,
                ).valueValue(ride.remainingSeats, ride.availableSeats),
                label: AppLocalizations.of(context).seatsLeft,
              ),
              InfoItem(
                icon: Icons.access_time,
                value: _formatTime(ride.departureTime),
                label: AppLocalizations.of(context).departure,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersList(BuildContext context, RideModel ride) {
    final passengers = ride.acceptedBookings;

    if (passengers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 40.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).noPassengersYet,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).passengersValue(passengers.length),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...passengers.map(
            (booking) => _buildPassengerItem(booking.passengerId),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(String passengerId) {
    final passengerAsync = ref.watch(currentUserProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        if (passenger == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: passenger.photoUrl != null
                    ? NetworkImage(passenger.photoUrl!)
                    : null,
                child: passenger.photoUrl == null
                    ? Text(passenger.displayName[0].toUpperCase())
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          passenger.rating.average.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Message passenger',
                onPressed: () => _sendMessage(passenger.uid),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// Night safety banner — enhanced visibility when riding after dark.
  Widget _buildNightSafetyBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.15),
            const Color(0xFF283593).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.nightlight_round,
            size: 20.sp,
            color: const Color(0xFF5C6BC0),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Night ride — stay alert and share your trip with someone you trust',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.shield_rounded,
            size: 18.sp,
            color: const Color(0xFF5C6BC0),
          ),
        ],
      ),
    );
  }

  /// Route deviation alert — shown when driver goes >500m off the planned route.
  Widget _buildRouteDeviationAlert(
    BuildContext context,
    ActiveRideState rideState,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Deviation Detected',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Driver is ${(rideState.routeDeviationMeters / 1000).toStringAsFixed(1)} km off the planned route',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Share My Trip row — shown during active ride.
  Widget _buildShareTripRow(BuildContext context, RideModel ride) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: GestureDetector(
        onTap: () => _shareTrip(ride),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_location, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Share My Trip',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RideModel ride) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          if (ride.status == RideStatus.inProgress)
            PremiumButton(
              text: 'View on Map',
              icon: Icons.map_outlined,
              onPressed: () => context.push(
                AppRoutes.rideNavigation.path.replaceFirst(':id', ride.id),
              ),
              style: PremiumButtonStyle.primary,
            ),
          SizedBox(height: 12.h),
          if (ride.status == RideStatus.draft ||
              ride.status == RideStatus.active)
            PremiumButton(
              text: 'Cancel Ride',
              icon: Icons.cancel_outlined,
              onPressed: () => _showCancelDialog(context, ride),
              style: PremiumButtonStyle.outline,
            ),
          if (ride.status == RideStatus.completed)
            PremiumButton(
              text: 'Rate & Review',
              icon: Icons.star_outline,
              onPressed: () => _showRatingDialog(context, ride),
              style: PremiumButtonStyle.primary,
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String recipientId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch recipient's actual profile for correct display name and avatar
      final recipientProfile = await ref.read(
        userProfileProvider(recipientId).future,
      );
      final recipientName = recipientProfile?.displayName ?? 'User';
      final recipientPhotoUrl = recipientProfile?.photoUrl;

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: recipientId,
          userName1: currentUser.displayName,
          userName2: recipientName,
        ).future,
      );

      if (!mounted) return;

      // Pass the actual UserModel so the chat screen can show the correct info
      final receiverUser =
          recipientProfile ??
          UserModel.rider(
            uid: recipientId,
            email: '',
            displayName: recipientName,
            photoUrl: recipientPhotoUrl,
          );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: receiverUser,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to open chat. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _callDriver(String? phoneNumber) async {
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).phoneNumberNotAvailable),
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).cannotMakePhoneCalls),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToLaunchDialer),
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, RideModel ride) {
    showDialog(
      context: context,
      barrierLabel: 'Cancel ride dialog',
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).cancelRide2),
        content: Text(AppLocalizations.of(context).areYouSureYouWant9),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppLocalizations.of(context).keepRide),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              _cancelRide(ride);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).cancelRide2),
          ),
        ],
      ),
    );
  }

  void _cancelRide(RideModel ride) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) return;

      // Find the passenger's booking for this ride to cancel only their booking
      final allBookings = await ref.read(
        bookingsByPassengerProvider(currentUser.uid).future,
      );
      final myBooking = allBookings
          .where((b) => b.rideId == ride.id)
          .firstOrNull;

      if (myBooking == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Booking not found. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await ref
          .read(rideActionsViewModelProvider)
          .cancelBooking(rideId: ride.id, bookingId: myBooking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).rideCancelledSuccessfully,
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToCancelRideValue(e),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showRatingDialog(BuildContext context, RideModel ride) async {
    // Fetch driver profile to get name for review screen
    final driverProfile = await ref.read(
      userProfileProvider(ride.driverId).future,
    );

    if (!mounted) return;

    // Navigate to the submit review screen for the driver
    context.push(
      '${AppRoutes.submitReview.path}'
      '?rideId=${ride.id}'
      '&revieweeId=${ride.driverId}'
      '&revieweeName=${Uri.encodeComponent(driverProfile?.displayName ?? 'Driver')}'
      '&reviewType=driverReview',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: AppColors.primary),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
