import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/poi_search_sheet.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/widgets/ride_shared_widgets.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Active Ride Navigation Screen - Shows map and ride details for drivers during active rides
class DriverActiveRideScreen extends ConsumerStatefulWidget {
  const DriverActiveRideScreen({super.key, this.rideId});
  final String? rideId;

  @override
  ConsumerState<DriverActiveRideScreen> createState() =>
      _DriverActiveRideScreenState();
}

class _DriverActiveRideScreenState
    extends ConsumerState<DriverActiveRideScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _geofencePulseController;
  bool _hasCenteredInitialLocation = false;

  // Controls the bottom sheet programmatically for auto-expansion
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _geofencePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeRideSession();
    });
  }

  Future<void> _initializeRideSession() async {
    final rideId = widget.rideId;
    if (rideId == null || rideId.isEmpty) return;

    final notifier = ref.read(activeRideViewModelProvider(rideId).notifier);
    var result = await notifier.initializeLocationTracking();

    if (!mounted) return;

    if (result == ActiveRideLocationInitResult.permissionRequired) {
      final accepted = await PermissionDialogHelper.showRideTrackingRationale(
        context,
      );
      if (!mounted || !accepted) return;
      result = await notifier.initializeLocationTracking(
        requestPermission: true,
      );
      if (!mounted) return;
    }

  }

  @override
  void dispose() {
    _geofencePulseController.dispose();
    _sheetController.dispose();
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
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).valueValue5(
            poi.name ?? 'Unknown',
            address != null ? ' - $address' : '',
          ),
          type: AdaptiveSnackBarType.success,
          action: AppLocalizations.of(context).addAsStop,
          onActionPressed: () {},
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

    // PERF: Only watch the ride AsyncValue — GPS state changes won't trigger
    // a full rebuild of this widget tree. Individual sections use Consumer
    // widgets with their own targeted watches.
    final rideAsync = ref.watch(
      activeRideViewModelProvider(widget.rideId!).select((s) => s.ride),
    );

    // Center map on first GPS location fix
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

    // Auto-expand bottom sheet on key phase transitions (pickingUp for OTP,
    // arriving for completion prompt) so the driver sees action buttons.
    ref.listen<ActiveRidePhase>(
      activeRideViewModelProvider(widget.rideId!).select((s) => s.phase),
      (prev, next) {
        if (prev == next) return;
        if (next == ActiveRidePhase.pickingUp ||
            next == ActiveRidePhase.arriving) {
          if (_sheetController.isAttached) {
            _sheetController.animateTo(
              0.55,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        }
      },
    );

    return rideAsync.when(
      data: (ride) {
        if (ride == null) {
          return _buildNoRideState();
        }
        return _buildRideContent(ride);
      },
      loading: () => const AdaptiveScaffold(
        body: SkeletonLoader(type: SkeletonType.rideCard, itemCount: 5),
      ),
      error: (e, _) => AdaptiveScaffold(
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
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: AppLocalizations.of(context).activeRide,
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

  Widget _buildRideContent(RideModel ride) {
    // Handle cancelled ride
    if (ride.status == RideStatus.cancelled) {
      return _buildCancelledState();
    }

    // Auto-redirect to completion screen if ride is already completed
    // (e.g. driver force-quit app and returned to a finished ride).
    final currentState = ref.read(activeRideViewModelProvider(widget.rideId!));
    if (ride.status == RideStatus.completed &&
        !currentState.hasAutoNavigatedToCompletion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(activeRideViewModelProvider(widget.rideId!).notifier)
            .markCompletionNavigationHandled();
        context.pushReplacement(
          AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
        );
      });
    }

    // Phase auto-expand is handled by ref.listen in build()

    // Get locations from the ride model
    final pickupLocation = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dropoffLocation = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );

    final provider = activeRideViewModelProvider(widget.rideId!);

    return AdaptiveScaffold(
      body: Stack(
        children: [
          // Map — PERF: isolated Consumer, rebuilds on GPS updates (expected)
          Consumer(
            builder: (context, ref, _) {
              final rideState = ref.watch(provider);
              return _buildMap(
                ride,
                pickupLocation,
                dropoffLocation,
                rideState,
              );
            },
          ),

          // Off-route banner — only rebuilds when isOffRoute changes
          if (ride.status == RideStatus.inProgress)
            Consumer(
              builder: (context, ref, _) {
                final isOffRoute = ref.watch(
                  provider.select((s) => s.isOffRoute),
                );
                if (!isOffRoute) return const SizedBox.shrink();
                final rideState = ref.read(provider);
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 56.h,
                  left: 20.w,
                  right: 20.w,
                  child: _buildDriverOffRouteBanner(rideState),
                );
              },
            ),

          // Route loading indicator — only rebuilds when route availability changes
          if (ride.status == RideStatus.inProgress)
            Consumer(
              builder: (context, ref, _) {
                final hasRoute = ref.watch(
                  provider.select((s) => s.osrmRoutePoints != null),
                );
                if (hasRoute) return const SizedBox.shrink();
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 64.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
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
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Loading route...',
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
              },
            ),

          // Top Controls — isolated Consumer
          Consumer(
            builder: (context, ref, _) {
              final rideState = ref.watch(provider);
              return _buildTopControls(rideState);
            },
          ),

          // Navigation Instructions (Collapsible) — only mounts when expanded
          Consumer(
            builder: (context, ref, _) {
              final isExpanded = ref.watch(
                provider.select((s) => s.isNavigationExpanded),
              );
              if (!isExpanded) return const SizedBox.shrink();
              final rideState = ref.watch(provider);
              return _buildNavigationPanel(ride, rideState);
            },
          ),

          // Bottom Panel with Ride Info — DraggableScrollableSheet is NOT rebuilt,
          // only its content (via Consumer inside builder)
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.38,
            minChildSize: 0.15,
            maxChildSize: 0.80,
            snap: true,
            snapSizes: const [0.15, 0.38, 0.80],
            builder: (context, scrollController) {
              // Consumer moved inside to watch updates WITHOUT rebuilding the sheet
              return Consumer(
                builder: (context, ref, _) {
                  final rideState = ref.watch(provider);
                  return _buildBottomSheet(scrollController, ride, rideState);
                },
              );
            },
          ),

          // Passenger Details Sheet — only builds when shown
          Consumer(
            builder: (context, ref, _) {
              final showDetails = ref.watch(
                provider.select((s) => s.showPassengerDetails),
              );
              if (!showDetails) return const SizedBox.shrink();
              final rideState = ref.read(provider);
              return _buildPassengerSheet(ride, rideState);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    RideModel ride,
    LatLng pickupLocation,
    LatLng dropoffLocation,
    ActiveRideState rideState,
  ) {
    // Use driver's current GPS location, or fallback to pickup location if still loading
    final driverLocation = rideState.currentLocation ?? pickupLocation;

    // Show loading indicator while getting GPS location
    if (rideState.isLoadingLocation) {
      return ColoredBox(
        color: AppColors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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

    // Cache polyline points to avoid recomputing the same list for both strokes
    final polylinePoints =
        rideState.remainingRoutePoints ??
        rideState.osrmRoutePoints ??
        [
          pickupLocation,
          ...(ride.route.waypoints.toList()
                ..sort((a, b) => a.order.compareTo(b.order)))
              .map((wp) => LatLng(wp.location.latitude, wp.location.longitude)),
          dropoffLocation,
        ];

    return RepaintBoundary(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: driverLocation, initialZoom: 15),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sportconnect.app',
          ),

          // Proximity zones — 150 m pickup, 180 m destination.
          // Radii match _checkProximity thresholds in ActiveRideViewModel.
          // AnimatedBuilder rebuilds only this layer on each pulse tick.
          AnimatedBuilder(
            animation: _geofencePulseController,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(
                _geofencePulseController.value,
              );
              return CircleLayer(
                circles: [
                  CircleMarker(
                    point: pickupLocation,
                    radius: 150.0 + t * 10,
                    useRadiusInMeter: true,
                    color: AppColors.primary.withValues(alpha: 0.08 + t * 0.09),
                    borderColor: AppColors.primary.withValues(
                      alpha: 0.42 + t * 0.38,
                    ),
                    borderStrokeWidth: 2.5,
                  ),
                  CircleMarker(
                    point: dropoffLocation,
                    radius: 180.0 + t * 10,
                    useRadiusInMeter: true,
                    color: AppColors.error.withValues(alpha: 0.06 + t * 0.07),
                    borderColor: AppColors.error.withValues(
                      alpha: 0.32 + t * 0.33,
                    ),
                    borderStrokeWidth: 2.5,
                  ),
                ],
              );
            },
          ),

          // Route Line — remaining route from driver's current position, or full route as fallback
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                color: Colors.white,
                strokeWidth: 6,
              ),
              Polyline(
                points: polylinePoints,
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
                child: _PulsingLocationMarker(
                  heading: rideState.userHeading,
                  outerSize: 50.w,
                  innerSize: 30.w,
                  iconSize: 18.w,
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
                  child: Icon(
                    Icons.person_pin,
                    color: Colors.white,
                    size: 22.w,
                  ),
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

              // Waypoint Markers
              ...ride.route.waypoints.map((wp) {
                final isPassed = rideState.passedWaypointIndices.contains(
                  wp.order,
                );
                final etaMin = rideState.waypointEtaMinutes[wp.order];
                return Marker(
                  point: LatLng(wp.location.latitude, wp.location.longitude),
                  width: 56.w,
                  height: etaMin != null && !isPassed ? 52.h : 32.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (etaMin != null && !isPassed)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          margin: EdgeInsets.only(bottom: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(4.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '${etaMin}m',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: isPassed
                              ? AppColors.textTertiary
                              : AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${wp.order + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // POI Markers (if any)
              if (rideState.showPOIMarkers)
                ...rideState.nearbyPOIs.map(
                  (poi) => Marker(
                    point: poi.location,
                    width: 40.w,
                    height: 40.w,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
      ),
    );
  }

  Widget _buildTopControls(ActiveRideState rideState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Back Button
                _buildControlButton(
                  icon: Icons.close,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showExitConfirmation();
                  },
                ),

                const Spacer(),

                // Recenter Button
                _buildControlButton(
                  icon: Icons.my_location,
                  iconColor: AppColors.primary,
                  onTap: rideState.currentLocation != null
                      ? () {
                          HapticFeedback.lightImpact();
                          _mapController.move(rideState.currentLocation!, 15);
                        }
                      : null,
                ),

                SizedBox(width: 8.w),

                // POI Search Button - Find nearby places
                _buildControlButton(
                  icon: Icons.explore_rounded,
                  isActive: rideState.showPOIMarkers,
                  activeColor: AppColors.success,
                  iconColor: AppColors.success,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _openPOISearch();
                  },
                ),

                SizedBox(width: 8.w),

                // Toggle Navigation
                _buildControlButton(
                  icon: Icons.directions,
                  isActive: rideState.isNavigationExpanded,
                  activeColor: AppColors.primary,
                  iconColor: AppColors.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(
                          activeRideViewModelProvider(widget.rideId!).notifier,
                        )
                        .toggleNavigationExpanded();
                  },
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn().slideY(begin: -0.3),
    );
  }

  /// A reusable floating control button with Material splash feedback.
  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? iconColor,
    bool isActive = false,
    Color? activeColor,
  }) {
    final bgColor = isActive
        ? (activeColor ?? AppColors.primary)
        : Colors.white;
    final fgColor = isActive
        ? Colors.white
        : (iconColor ?? AppColors.textPrimary);
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Icon(icon, color: fgColor, size: 22.w),
        ),
      ),
    );
  }

  Widget _buildNavigationPanel(RideModel ride, ActiveRideState rideState) {
    // Determine next stop: if picking up → origin; if en route → next unpassed
    // waypoint (if any), else destination.
    String nextStop;
    IconData nextStopIcon;
    String nextStopLabel;

    if (rideState.phase == ActiveRidePhase.pickingUp) {
      nextStop = ride.origin.address;
      if (ride.status == RideStatus.inProgress) {
        nextStopIcon = Icons.how_to_reg;
        nextStopLabel = 'Verifying Passengers';
      } else {
        nextStopIcon = Icons.person_pin_circle;
        nextStopLabel = AppLocalizations.of(context).headingToPickup;
      }
    } else {
      // Find next unpassed waypoint
      final nextWaypoint =
          ride.route.waypoints
              .where(
                (wp) => !rideState.passedWaypointIndices.contains(wp.order),
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      if (nextWaypoint.isNotEmpty) {
        final wp = nextWaypoint.first;
        final etaMin = rideState.waypointEtaMinutes[wp.order];
        nextStop = wp.location.address.isNotEmpty
            ? wp.location.address
            : 'Waypoint ${ride.route.waypoints.indexOf(wp) + 1}';
        nextStopIcon = Icons.location_on;
        nextStopLabel = etaMin != null
            ? 'Next stop (${AppLocalizations.of(context).valueMin(etaMin)})'
            : 'Next stop';
      } else {
        nextStop = ride.destination.address;
        nextStopIcon = Icons.flag;
        nextStopLabel = AppLocalizations.of(context).headingToDestination;
      }
    }

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
                  child: Icon(nextStopIcon, color: Colors.white, size: 28.w),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextStopLabel,
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
                        !rideState.currentSpeedKmh.isFinite ||
                                rideState.currentSpeedKmh < 2
                            ? 'Parked'
                            : '${rideState.currentSpeedKmh.toInt()} km/h',
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

  Widget _buildBottomSheet(
    ScrollController scrollController,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final bookings = rideState.bookings;
    final distance = rideState.remainingDistanceKm ?? ride.distanceKm ?? 0.0;
    final duration = rideState.remainingEtaMinutes ?? ride.durationMinutes ?? 0;
    final fare =
        ride.pricePerSeatInCents *
        (ride.bookedSeats > 0 ? ride.bookedSeats : 1);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
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
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),

          // Ride Status
          _buildRideStatusBanner(ride, rideState),

          // Connectivity indicator
          if (!rideState.isConnected)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 18.sp, color: AppColors.warning),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Poor connection — location updates queued'
                      '${rideState.pendingLocationWrites > 0 ? ' (${rideState.pendingLocationWrites})' : ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Delay banner
          if (rideState.rideDelayMinutes >= 5 &&
              ride.status != RideStatus.inProgress)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 18.sp, color: AppColors.error),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Departure delayed by ${rideState.rideDelayMinutes} min — passengers notified',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Timeout warning
          if (rideState.rideTimeoutMinutes != null &&
              !rideState.hasShownTimeoutWarning)
            _buildTimeoutWarning(ride, rideState),

          // Passenger Info
          _buildPassengerInfo(ride, rideState),

          const Divider(color: AppColors.border),

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
                  ).value5((fare / 100).toStringAsFixed(2)),
                  icon: Icons.euro_symbol,
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Per-ride earnings card — shows breakdown so driver knows
          // exactly how much they'll receive from this trip.
          _buildEarningsCard(ride, rideState),

          SizedBox(height: 12.h),

          // Quick Message Chips
          if (ride.status == RideStatus.inProgress)
            _buildQuickMessageChips(ride, rideState),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Call Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (bookings.isEmpty) return;
                      if (bookings.length == 1) {
                        _callPassenger(bookings.first.passengerId);
                      } else {
                        _showPassengerPicker(
                          bookings,
                          _callPassenger,
                        );
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: Text(AppLocalizations.of(context).call),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
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
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (bookings.isEmpty) return;
                      if (bookings.length == 1) {
                        _messagePassenger(bookings.first.passengerId);
                      } else {
                        _showPassengerPicker(
                          bookings,
                          _messagePassenger,
                        );
                      }
                    },
                    icon: const Icon(Icons.message),
                    label: Text(AppLocalizations.of(context).message),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
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
                    : () {
                        HapticFeedback.mediumImpact();
                        _handleMainAction(ride);
                      },
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
                        child: const CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getActionButtonIcon(
                              rideState.phase,
                              status: ride.status,
                            ),
                            size: 22.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _getActionButtonText(
                              rideState.phase,
                              status: ride.status,
                            ),
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

          SizedBox(height: 12.h + bottomPadding),
        ],
      ),
    );
  }

  Widget _buildRideStatusBanner(RideModel ride, ActiveRideState rideState) {
    final l10n = AppLocalizations.of(context);
    final eta = rideState.remainingEtaMinutes ?? ride.durationMinutes ?? 0;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (rideState.phase) {
      case ActiveRidePhase.pickingUp:
        statusColor = AppColors.warning;
        // Show different text before/after driver has arrived at pickup
        if (ride.status == RideStatus.inProgress) {
          statusText = 'At Pickup — Verifying Passengers';
          statusIcon = Icons.how_to_reg;
        } else {
          statusText = l10n.headingToPickup;
          statusIcon = Icons.person_pin_circle;
        }
      case ActiveRidePhase.enRoute:
        statusColor = AppColors.primary;
        statusText = l10n.tripInProgress;
        statusIcon = Icons.navigation;
      case ActiveRidePhase.arriving:
        statusColor = AppColors.success;
        statusText = l10n.headingToDestination;
        statusIcon = Icons.flag;
      case ActiveRidePhase.completed:
        statusColor = AppColors.success;
        statusText = l10n.rideCompleted;
        statusIcon = Icons.check_circle;
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
    if (bookings.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Text(
          'No passengers',
          style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
        ),
      );
    }

    final pickedUp = rideState.pickedUpPassengerIds.length;

    return GestureDetector(
      onTap: () => ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .showPassengerDetails(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with count and pickup progress
            Row(
              children: [
                Icon(Icons.people, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).valuePassengerValue(
                    bookings.length,
                    bookings.length != 1 ? 's' : '',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // All passenger rows
            ...bookings.asMap().entries.map((entry) {
              final booking = entry.value;
              final isPickedUp = rideState.pickedUpPassengerIds.contains(
                booking.passengerId,
              );
              final isNoShow = rideState.noShowPassengerIds.contains(
                booking.passengerId,
              );
              final queuePos =
                  rideState.pickupOrder.indexOf(booking.passengerId) + 1;
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    // Pickup queue badge
                    if (queuePos > 0 &&
                        rideState.phase == ActiveRidePhase.pickingUp) ...[
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: isPickedUp
                              ? AppColors.success
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$queuePos',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    PassengerAvatarWidget(
                      passengerId: booking.passengerId,
                      radius: 16,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: PassengerNameWidget(
                        passengerId: booking.passengerId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isNoShow
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          decoration: isNoShow
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    // Payment status badge — always visible so driver knows
                    // who has paid before confirming pickup via OTP.
                    if (!isNoShow && !isPickedUp) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: booking.paidAt != null
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              booking.paidAt != null
                                  ? Icons.check_circle_outline
                                  : Icons.pending_outlined,
                              size: 10.sp,
                              color: booking.paidAt != null
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              booking.paidAt != null ? 'Paid' : 'Unpaid',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: booking.paidAt != null
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ],
                    if (isNoShow)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'No-show',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    else if (isPickedUp)
                      Icon(
                        Icons.check_circle,
                        size: 16.sp,
                        color: AppColors.success,
                      )
                    else if (rideState.phase == ActiveRidePhase.pickingUp) ...[
                      // OTP confirm — disabled (amber) when unpaid to warn driver.
                      GestureDetector(
                        onTap: () {
                          if (booking.paidAt == null) {
                            AdaptiveSnackBar.show(
                              context,
                              message:
                                  "This passenger hasn't paid yet. Collect cash or wait for payment.",
                              type: AdaptiveSnackBarType.warning,
                            );
                            return;
                          }
                          _showOtpDialog(booking);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: booking.paidAt != null
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: booking.paidAt != null
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.warning.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'OTP',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: booking.paidAt != null
                                  ? AppColors.primary
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => _confirmNoShow(booking),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'No-show',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSheet(RideModel ride, ActiveRideState rideState) {
    final bookings = rideState.bookings;
    if (bookings.isEmpty) {
      return const SizedBox.shrink();
    }
    final primaryBooking = bookings.first;
    final seatsBooked = primaryBooking.seatsBooked;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ref
            .read(activeRideViewModelProvider(widget.rideId!).notifier)
            .hidePassengerDetails(),
        child: ColoredBox(
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
                          passengerId: primaryBooking.passengerId,
                          radius: 30,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PassengerNameWidget(
                                passengerId: primaryBooking.passengerId,
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
                          tooltip: AppLocalizations.of(
                            context,
                          ).closePassengerDetails,
                          icon: const Icon(Icons.close),
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
                          ).value2(
                            (ride.pricePerSeatInCents / 100).toStringAsFixed(
                              2,
                            ),
                          ),
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

                    // Passenger pickup checklist (OTP-verified)
                    if (bookings.isNotEmpty) ...[
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
                                  Icons.pin_rounded,
                                  size: 18.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Confirm Pickups',
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
                            SizedBox(height: 4.h),
                            Text(
                              'Ask each passenger for their 4-digit code',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ...bookings.map((b) {
                              final isPickedUp = rideState.pickedUpPassengerIds
                                  .contains(b.passengerId);
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPickedUp
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      color: isPickedUp
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
                                          color: isPickedUp
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary,
                                          decoration: isPickedUp
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (!isPickedUp)
                                      GestureDetector(
                                        onTap: () => _showOtpDialog(b),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Text(
                                            'Enter OTP',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 18.sp,
                                        color: AppColors.success,
                                      ),
                                  ],
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

  // ==================== SECTION 7 UI BUILDERS ====================

  /// Per-ride earnings breakdown card shown in the bottom sheet.
  /// Gives the driver a clear view of gross fare, platform fee, and net pay.
  Widget _buildEarningsCard(RideModel ride, ActiveRideState rideState) {
    final bookings = rideState.bookings;
    final paidBookings = bookings.where((b) => b.paidAt != null).toList();
    final unpaidCount = bookings.length - paidBookings.length;

    // Gross = price × total seats booked across ALL accepted bookings
    final totalSeats = bookings.fold<int>(0, (sum, b) => sum + b.seatsBooked);
    final gross = ride.pricePerSeatInCents * totalSeats;
    const platformFeeRate = 0.15;
    final platformFee = gross * platformFeeRate;
    final net = gross - platformFee;

    // Count how many paid seats
    final paidSeats = paidBookings.fold<int>(
      0,
      (sum, b) => sum + b.seatsBooked,
    );
    final paidNet =
        ride.pricePerSeatInCents * paidSeats * (1 - platformFeeRate);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 16.sp,
                  color: AppColors.success,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Your Earnings',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                if (unpaidCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '$unpaidCount unpaid',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _EarningsStat(
                  label: 'Gross fare',
                  value: '€${(gross / 100).toStringAsFixed(2)}',
                  dimmed: true,
                ),
                _EarningsStat(
                  label: 'Platform (15%)',
                  value: '−€${(platformFee / 100).toStringAsFixed(2)}',
                  dimmed: true,
                  isDeduction: true,
                ),
                _EarningsStat(
                  label: paidSeats > 0 && paidSeats < totalSeats
                      ? 'Paid so far'
                      : 'You receive',
                  value:
                      '€${((paidSeats > 0 && paidSeats < totalSeats ? paidNet : net) / 100).toStringAsFixed(2)}',
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Quick message chips for in-ride communication.
  Widget _buildQuickMessageChips(RideModel ride, ActiveRideState rideState) {
    final messages = [
      'Running late',
      'Almost there',
      "I'm outside",
      'Traffic ahead',
      'Taking detour',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest received message bubble
          if (rideState.latestQuickMessage != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.message, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      rideState.latestQuickMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Quick message send chips
          SizedBox(
            height: 36.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: messages.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(
                    messages[index],
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  onPressed: () {
                    final notifier = ref.read(
                      activeRideViewModelProvider(widget.rideId!).notifier,
                    );
                    final user = ref.read(currentUserProvider).value;
                    if (user == null) return;
                    // Use ride group chat to send quick message
                    notifier.sendQuickMessage(
                      chatId: ride.id,
                      message: messages[index],
                      senderId: user.uid,
                      senderName: user.username,
                    );
                    HapticFeedback.lightImpact();
                    AdaptiveSnackBar.show(
                      context,
                      message: AppLocalizations.of(
                        context,
                      ).sentMessage(messages[index]),
                      duration: const Duration(seconds: 1),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  /// Timeout warning widget inside the bottom panel.
  Widget _buildTimeoutWarning(RideModel ride, ActiveRideState rideState) {
    final overMin = rideState.rideTimeoutMinutes ?? 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timer_off, size: 18.sp, color: AppColors.error),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Ride exceeds estimated time by $overMin min',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(
                          activeRideViewModelProvider(widget.rideId!).notifier,
                        )
                        .dismissTimeoutWarning();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).dismiss,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleMainAction(ride),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Complete Ride',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 7 ACTIONS ====================

  /// Shows OTP input dialog. Driver enters the 4-digit code the passenger
  /// displays on their screen to confirm the pickup.
  void _showOtpDialog(RideBooking booking) {
    var otp = '';
    String? errorText;
    var isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog.adaptive(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pin_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Confirm Pickup',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask the passenger for their 4-digit pickup code.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      enabled: !isSubmitting,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: '- - - -',
                        hintStyle: TextStyle(
                          fontSize: 24.sp,
                          letterSpacing: 8,
                          color: AppColors.textTertiary,
                        ),
                        counterText: '',
                        errorText: errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        otp = value.trim();
                        if (errorText != null) {
                          setDialogState(() => errorText = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.of(context).actionCancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (otp.length != 4) {
                            setDialogState(
                              () => errorText = 'Enter the 4-digit code',
                            );
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            errorText = null;
                          });

                          final notifier = ref.read(
                            activeRideViewModelProvider(
                              widget.rideId!,
                            ).notifier,
                          );

                          final ok = await notifier.confirmPickupWithOtp(
                            passengerId: booking.passengerId,
                            bookingId: booking.id,
                            enteredOtp: otp,
                          );

                          if (!mounted || !dialogContext.mounted) return;

                          if (ok) {
                            Navigator.of(dialogContext).pop();

                            HapticFeedback.mediumImpact();

                            if (!mounted) return;
                            AdaptiveSnackBar.show(
                              context,
                              message: 'Passenger confirmed!',
                              type: AdaptiveSnackBarType.success,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            setDialogState(() {
                              isSubmitting = false;
                              errorText =
                                  'Wrong code — ask the passenger again';
                            });
                            HapticFeedback.heavyImpact();
                          }
                        },
                  child: isSubmitting
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Confirm no-show dialog for a passenger with 30-second undo window.
  void _confirmNoShow(RideBooking booking) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).markAsNoShowQuestion),
        content: Text(
          AppLocalizations.of(
            context,
          ).markNoShowDialogMessage(booking.passengerId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Mark locally — not committed to Firestore yet
              ref
                  .read(activeRideViewModelProvider(widget.rideId!).notifier)
                  .localMarkNoShow(passengerId: booking.passengerId);
              HapticFeedback.mediumImpact();

              // Show undo snackbar for 30 seconds
              ScaffoldMessenger.of(context).clearSnackBars();
              AdaptiveSnackBar.show(
                context,
                message: AppLocalizations.of(context).passengerMarkedNoShow,
                type: AdaptiveSnackBarType.error,
                duration: const Duration(seconds: 30),
                action: AppLocalizations.of(context).undo,
                onActionPressed: () {
                  ref
                      .read(
                        activeRideViewModelProvider(
                          widget.rideId!,
                        ).notifier,
                      )
                      .undoNoShow(passengerId: booking.passengerId);
                  HapticFeedback.lightImpact();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).markNoShow),
          ),
        ],
      ),
    );
  }

  /// Show return ride prompt after ride completion.
  void _showReturnRidePrompt(RideModel ride) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).createReturnRideQuestion),
        content: Text(
          AppLocalizations.of(context).createReturnRideMessage(
            ride.destination.address,
            ride.origin.address,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).noThanks),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final returnId = await ref
                  .read(activeRideViewModelProvider(widget.rideId!).notifier)
                  .createReturnRide();
              if (!mounted) return;
              if (returnId != null) {
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(context).returnRideCreated,
                  type: AdaptiveSnackBarType.success,
                );
              }
            },
            child: Text(AppLocalizations.of(context).createReturnRide),
          ),
        ],
      ),
    );
  }

  /// Off-route alert banner shown to the driver.
  Widget _buildDriverOffRouteBanner(ActiveRideState rideState) {
    final deviationKm = rideState.routeDeviationMeters / 1000;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.wrong_location, color: Colors.white, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Off Route',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${deviationKm.toStringAsFixed(1)} km from planned route — recalculating...',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          return 1;
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
        return 1;
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

  String _getActionButtonText(ActiveRidePhase phase, {RideStatus? status}) {
    final l10n = AppLocalizations.of(context);
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        return status == RideStatus.inProgress
            ? 'Start Driving'
            : 'Arrived at Pickup';
      case ActiveRidePhase.enRoute:
        return 'Almost There';
      case ActiveRidePhase.arriving:
        return l10n.completeRide;
      case ActiveRidePhase.completed:
        return l10n.rateYourRide;
    }
  }

  IconData _getActionButtonIcon(ActiveRidePhase phase, {RideStatus? status}) {
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        return status == RideStatus.inProgress
            ? Icons.directions_car
            : Icons.location_on;
      case ActiveRidePhase.enRoute:
        return Icons.near_me;
      case ActiveRidePhase.arriving:
        return Icons.check_circle;
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

  /// Handles the main action button based on current ride phase and status.
  void _handleMainAction(RideModel ride) {
    final rideState = ref.read(activeRideViewModelProvider(widget.rideId!));
    if (rideState.isProcessing) return;

    switch (rideState.phase) {
      case ActiveRidePhase.pickingUp:
        if (ride.status == RideStatus.inProgress) {
          _confirmDepartFromPickup(ride);
        } else {
          _confirmArrivedAtPickup(ride);
        }
      case ActiveRidePhase.enRoute:
        _confirmCompleteTrip();
      case ActiveRidePhase.arriving:
        _confirmDropOff(ride);
      case ActiveRidePhase.completed:
        _navigateToRating(ride);
    }
  }

  /// Step 1: Driver arrived at pickup → Confirms arrival and starts ride in Firestore.
  Future<void> _confirmArrivedAtPickup(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    final passengerCount = ride.bookedSeats;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.success),
            SizedBox(width: 8.w),
            const Expanded(child: Text('Confirm Arrival')),
          ],
        ),
        content: Text(
          "You've arrived at the pickup location. "
          '$passengerCount passenger${passengerCount != 1 ? 's' : ''} will be notified.',
        ),
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
            child: const Text("Yes, I've Arrived"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .startRide();

      if (!mounted) return;

      if (success) {
        HapticFeedback.mediumImpact();
        AdaptiveSnackBar.show(
          context,
          message: l10n.rideInProgress,
          type: AdaptiveSnackBarType.success,
        );
      } else {
        _showErrorSnackBar(
          ref.read(activeRideViewModelProvider(widget.rideId!)).actionError ??
              l10n.failedToLoadRide,
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      _showErrorSnackBar('$e');
    }
  }

  /// Step 1b: Driver confirms all passengers are picked up → departs.
  Future<void> _confirmDepartFromPickup(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    final rideState = ref.read(activeRideViewModelProvider(widget.rideId!));
    final unverifiedCount = rideState.bookings
        .where(
          (b) =>
              b.status == BookingStatus.accepted &&
              !rideState.pickedUpPassengerIds.contains(b.passengerId) &&
              !rideState.noShowPassengerIds.contains(b.passengerId),
        )
        .length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            const Icon(Icons.directions_car, color: AppColors.primary),
            SizedBox(width: 8.w),
            const Expanded(child: Text('Start Driving')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unverifiedCount > 0) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '$unverifiedCount passenger${unverifiedCount > 1 ? 's' : ''} not yet verified with OTP.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            Text(
              unverifiedCount > 0
                  ? 'Are you sure you want to start driving without verifying all passengers?'
                  : 'All passengers verified. Ready to go!',
            ),
          ],
        ),
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
            child: Text(AppLocalizations.of(context).departNow),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(activeRideViewModelProvider(widget.rideId!).notifier)
        .departFromPickup();

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Step 2: Transition to arriving state — driver signals they're approaching destination.
  void _confirmCompleteTrip() {
    HapticFeedback.lightImpact();
    ref
        .read(activeRideViewModelProvider(widget.rideId!).notifier)
        .transitionToArriving();
    AdaptiveSnackBar.show(
      context,
      message: 'Approaching destination...',
      type: AdaptiveSnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  /// Step 3: Completes ride in Firestore — passengers dropped off.
  Future<void> _confirmDropOff(RideModel ride) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            const Icon(Icons.flag, color: AppColors.primary),
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

    try {
      final success = await ref
          .read(activeRideViewModelProvider(widget.rideId!).notifier)
          .completeRide();

      if (!mounted) return;

      if (success) {
        HapticFeedback.heavyImpact();
        _showCompletionCelebration(ride);
      } else {
        _showErrorSnackBar(
          ref.read(activeRideViewModelProvider(widget.rideId!)).actionError ??
              l10n.failedToLoadRide,
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      _showErrorSnackBar('$e');
    }
  }

  /// Step 4: Navigates to the review screen so driver can rate a passenger.
  Future<void> _navigateToRating(RideModel ride) async {
    final allBookings = await ref
        .read(rideActionsViewModelProvider.notifier)
        .getBookingsByRideId(ride.id, ride.driverId);
    final booking = allBookings
        .where((b) => b.status == BookingStatus.accepted)
        .firstOrNull;
    if (!mounted) return;
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
      final displayName = passengerProfile?.username ?? 'Passenger';
      final photoUrl = passengerProfile?.photoUrl ?? '';

      context.push(
        '${AppRoutes.submitReview.path}'
        '?rideId=${ride.id}'
        '&revieweeId=${booking.passengerId}'
        '&revieweeName=${Uri.encodeComponent(displayName)}'
        '&revieweePhotoUrl=${Uri.encodeComponent(photoUrl)}'
        '&reviewType=passengerReview',
      );
    } on Exception {
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
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final fare =
        ride.pricePerSeatInCents *
        (ride.bookedSeats > 0 ? ride.bookedSeats : 1);

    AppModalSheet.show<void>(
      context: context,
      barrierDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      showCloseButton: false,
      child: Builder(
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
                l10n.value5((fare / 100).toStringAsFixed(2)),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ).animate().fadeIn(delay: 500.ms),
              SizedBox(height: 8.h),
              Text(
                '${ride.origin.address} → ${ride.destination.address}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 600.ms),
              SizedBox(height: 12.h),
              // 7H — Return ride prompt
              TextButton.icon(
                onPressed: () {
                  if (mounted) Navigator.of(ctx).pop();
                  if (mounted) _showReturnRidePrompt(ride);
                },
                icon: Icon(Icons.swap_horiz, size: 18.sp),
                label: Text(
                  'Create Return Ride',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ).animate().fadeIn(delay: 650.ms),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!mounted) return;
                        Navigator.of(ctx).pop();
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
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
                        if (!mounted) return;
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
      ),
    );
  }

  /// Shows an error snackbar with the given message.
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
    );
  }

  /// Shows a bottom sheet to pick which passenger to contact (for multi-passenger rides).
  void _showPassengerPicker(
    List<RideBooking> bookings,
    void Function(String passengerId) onSelect,
  ) {
    AppModalSheet.show<void>(
      context: context,
      title: 'Select Passenger',
      maxHeightFactor: 0.6,
      child: Builder(
        builder: (ctx) => Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...bookings.map(
                (b) => AdaptiveListTile(
                  leading: PassengerAvatarWidget(
                    passengerId: b.passengerId,
                  ),
                  title: PassengerNameWidget(
                    passengerId: b.passengerId,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${b.seatsBooked} seat${b.seatsBooked > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelect(b.passengerId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens a chat conversation with a specific passenger.
  Future<void> _messagePassenger(String passengerId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      final passengerProfile = await ref.read(
        userProfileProvider(passengerId).future,
      );

      if (!mounted) return;

      if (passengerProfile == null) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).passengerProfileNotFound,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: passengerId,
          userName1: currentUser.username,
          userName2: passengerProfile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      final passengerUser = UserModel.rider(
        uid: passengerId,
        email: passengerProfile.email,
        username: passengerProfile.username,
        photoUrl: passengerProfile.photoUrl,
      );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: passengerUser,
      );
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToOpenChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  /// Calls a passenger using the device phone dialer.
  Future<void> _callPassenger(String passengerId) async {
    try {
      final passenger = await ref.read(userProfileProvider(passengerId).future);
      final phoneNumber = switch (passenger) {
        final RiderModel rider => rider.phoneNumber,
        final DriverModel driver => driver.phoneNumber,
        _ => null,
      };

      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).phoneNumberNotAvailable,
          type: AdaptiveSnackBarType.error,
        );
        return;
      }

      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).cannotMakePhoneCalls,
          type: AdaptiveSnackBarType.error,
        );
      }
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToLaunchDialer,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  /// Builds the UI state shown when the ride has been cancelled.
  Widget _buildCancelledState() {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
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

    // Block exit during arriving phase — passengers are being dropped off.
    // Driver must complete the ride first.
    if (rideState.phase == ActiveRidePhase.arriving) {
      final ride = rideState.currentRide;
      AdaptiveSnackBar.show(
        context,
        message: 'Complete the ride before leaving.',
        type: AdaptiveSnackBarType.warning,
        action: ride != null ? 'Complete Now' : null,
        onActionPressed: ride != null ? () => _handleMainAction(ride) : null,
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).cancelRide,
      builder: (ctx) => AlertDialog.adaptive(
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
              if (!mounted) return;
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

/// Self-contained pulsing marker that manages its own [AnimationController].
///
/// Extracting the animation into a separate [StatefulWidget] prevents the
/// 60 fps animation rebuild from being coupled to the parent's state changes
/// (GPS updates, ETA recalculations, etc.) and avoids animation stutter when
/// the parent rebuilds.
class _PulsingLocationMarker extends StatefulWidget {
  const _PulsingLocationMarker({
    required this.heading,
    required this.outerSize,
    required this.innerSize,
    required this.iconSize,
  });

  final double heading;
  final double outerSize;
  final double innerSize;
  final double iconSize;

  @override
  State<_PulsingLocationMarker> createState() => _PulsingLocationMarkerState();
}

class _PulsingLocationMarkerState extends State<_PulsingLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.heading * 3.14159 / 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.outerSize * (1 + _controller.value * 0.3),
                height: widget.outerSize * (1 + _controller.value * 0.3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 * (1 - _controller.value),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: widget.innerSize,
                height: widget.innerSize,
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
                  size: widget.iconSize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact stat column used inside the per-ride earnings card.
class _EarningsStat extends StatelessWidget {
  const _EarningsStat({
    required this.label,
    required this.value,
    this.highlight = false,
    this.dimmed = false,
    this.isDeduction = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool dimmed;
  final bool isDeduction;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: dimmed ? AppColors.textTertiary : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 15.sp : 13.sp,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight
                  ? AppColors.success
                  : isDeduction
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
