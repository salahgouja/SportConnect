import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/home/models/home_models.dart';
import 'package:sport_connect/features/home/view_models/home_view_model.dart';
import 'package:sport_connect/features/home/view_models/rider_home_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/misc_feature_widgets.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen>
    with TickerProviderStateMixin {
  // ── Animation ──────────────────────────────────────────────
  late final AnimationController _pulseAnimationController;

  // ── Map controller (widget-owned) ──────────────────────────
  final MapController _mapController = MapController();

  // ── Search (ephemeral UI state) ────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  /// Whether the active-ride guard has already navigated (prevent re-entry).
  bool _hasAutoNavigatedToActiveRide = false;

  // ── Map tile sources ───────────────────────────────────────
  final Map<String, String> _mapStyles = {
    'standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'terrain': 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    'dark':
        'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
    'satellite':
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  };

  // ─────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(riderHomeViewModelProvider.notifier).checkInitialLocationState();
      _requestNotificationPermission();
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Location permission handling — delegates to ViewModel
  // ─────────────────────────────────────────────────────────────

  /// Called when the user taps "Allow Location" on the gate screen.
  Future<void> _onAllowLocationTapped() async {
    final vm = ref.read(riderHomeViewModelProvider.notifier);
    vm.setAcquiringLocation();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      vm.setLocationServiceDisabled();
      return;
    }

    final accepted = await PermissionDialogHelper.showLocationRationale(
      context,
    );
    if (!accepted) {
      vm.setLocationDeniedSoft();
      return;
    }

    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      vm.setLocationDeniedSoft();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      vm.setLocationDeniedHard();
      return;
    }

    await vm.acquireLocationAndShowMap();
  }

  // ─────────────────────────────────────────────────────────────
  // Notification permission
  // ─────────────────────────────────────────────────────────────

  Future<void> _requestNotificationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool('notification_dialog_shown') ?? false;
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      final status = settings.authorizationStatus;

      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional)
        return;

      if (status == AuthorizationStatus.denied && alreadyAsked) return;

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final accepted = await PermissionDialogHelper.showNotificationRationale(
        context,
      );
      await prefs.setBool('notification_dialog_shown', true);

      if (!accepted) return;

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      TalkerService.error('Failed to request notification permission', e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(riderHomeViewModelProvider);
    final locationState = vmState.locationState;

    // ── Global Active Ride Guard ─────────────────────────────
    // On app launch / foreground, check if the user has an in-progress ride
    // and auto-navigate to the active ride screen.
    if (!_hasAutoNavigatedToActiveRide) {
      final user = ref.watch(currentUserProvider).value;
      if (user != null) {
        final bookings =
            ref.watch(bookingsByPassengerProvider(user.uid)).value ?? [];
        final acceptedBooking = bookings
            .where((b) => b.status == BookingStatus.accepted)
            .toList();
        for (final booking in acceptedBooking) {
          final ride = ref.watch(rideStreamProvider(booking.rideId)).value;
          if (ride != null && ride.status == RideStatus.inProgress) {
            _hasAutoNavigatedToActiveRide = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.push(
                  '${AppRoutes.riderActiveRide.path}?rideId=${ride.id}',
                );
              }
            });
            break;
          }
        }
      }
    }

    // Auto-follow map when location changes
    ref.listen<RiderHomeState>(riderHomeViewModelProvider, (previous, next) {
      if (next.locationState == LocationPermissionState.ready &&
          next.isFollowingUser &&
          next.currentLocation != null) {
        final vm = ref.read(riderHomeViewModelProvider.notifier);
        if (vm.canMoveMap()) {
          _mapController.move(next.currentLocation!, next.currentZoom);
          vm.updateLastMapMoveTime(DateTime.now());
        }
      }
    });

    return Scaffold(
      body: switch (locationState) {
        LocationPermissionState.unknown => _buildLocationGate(),
        LocationPermissionState.acquiring => _buildAcquiringState(),
        LocationPermissionState.ready => _buildMapHome(vmState),
        LocationPermissionState.deniedSoft => _buildDeniedSoftState(),
        LocationPermissionState.deniedHard => _buildDeniedHardState(),
        LocationPermissionState.serviceDisabled => _buildServiceDisabledState(),
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Gate screens
  // ─────────────────────────────────────────────────────────────

  /// Primary gate: first launch or permission not yet asked.
  Widget _buildLocationGate() {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Illustration
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 56.sp,
                color: AppColors.primary,
              ),
            ).animate().scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),

            SizedBox(height: 32.h),

            Text(
              l10n.findRidesNearYou,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            SizedBox(height: 12.h),

            Text(
              l10n.locationGateDescription,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),

            const Spacer(flex: 2),

            // Benefits list
            ...[
                  (Icons.search_rounded, l10n.locationBenefitFind),
                  (Icons.navigation_rounded, l10n.locationBenefitNavigate),
                  (Icons.shield_rounded, l10n.locationBenefitSafety),
                ]
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            item.$1,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList()
                .animate(interval: 80.ms)
                .fadeIn(delay: 400.ms)
                .slideX(begin: -0.1),

            const Spacer(),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onAllowLocationTapped,
                icon: Icon(Icons.my_location_rounded, size: 20.sp),
                label: Text(
                  l10n.allowLocation,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            SizedBox(height: 12.h),

            // Secondary: browse without location
            TextButton(
              onPressed: () => context.push(AppRoutes.searchRides.path),
              child: Text(
                l10n.browseWithoutLocation,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Shown while the OS permission dialog is pending or GPS is resolving.
  Widget _buildAcquiringState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
                Icon(
                  Icons.location_searching_rounded,
                  size: 28.sp,
                  color: AppColors.primary,
                ),
              ],
            ),
          ).animate().fadeIn(),
          SizedBox(height: 24.h),
          Text(
            l10n.findingYourLocation,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: 8.h),
          Text(
            l10n.thisWillOnlyTakeAMoment,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  /// Soft deny: user tapped "Not now" — offer to try again or browse by city.
  Widget _buildDeniedSoftState() {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48.sp,
                color: AppColors.warning,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            SizedBox(height: 24.h),
            Text(
              l10n.locationNotEnabled,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.locationNotEnabledDescription,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onAllowLocationTapped,
                icon: Icon(Icons.my_location_rounded, size: 20.sp),
                label: Text(
                  l10n.tryAgain,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.push(AppRoutes.searchRides.path),
              child: Text(
                l10n.browseByCity,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hard deny: permission permanently denied — must go to device settings.
  Widget _buildDeniedHardState() {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            SizedBox(height: 24.h),
            Text(
              l10n.locationPermissionBlocked,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.locationPermissionBlockedDescription,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Geolocator.openAppSettings(),
                icon: Icon(Icons.settings_rounded, size: 20.sp),
                label: Text(
                  l10n.openSettings,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.push(AppRoutes.searchRides.path),
              child: Text(
                l10n.browseByCity,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Device-level location services are turned off.
  Widget _buildServiceDisabledState() {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gps_off_rounded,
                size: 48.sp,
                color: AppColors.warning,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
            SizedBox(height: 24.h),
            Text(
              l10n.locationServicesOff,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.locationServicesOffDescription,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 36.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  // Re-check after returning from settings
                  if (mounted) {
                    ref
                        .read(riderHomeViewModelProvider.notifier)
                        .checkInitialLocationState();
                  }
                },
                icon: Icon(Icons.settings_rounded, size: 20.sp),
                label: Text(
                  l10n.openLocationSettings,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => context.push(AppRoutes.searchRides.path),
              child: Text(
                l10n.browseByCity,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Map home — only rendered when locationState == ready
  // ─────────────────────────────────────────────────────────────

  Widget _buildMapHome(RiderHomeState vmState) {
    // Extract state from ViewModel
    final loc = vmState.currentLocation ?? const LatLng(0, 0);
    final queryAnchor = vmState.nearbyQueryAnchor ?? loc;
    final currentZoom = vmState.currentZoom;
    final selectedMapStyle = vmState.selectedMapStyle;
    final showNearbyDrivers = vmState.showNearbyDrivers;
    final showHotspots = vmState.showHotspots;
    final showDistanceRadius = vmState.showDistanceRadius;
    final searchRadius = vmState.searchRadius;
    final isFollowingUser = vmState.isFollowingUser;
    final activeRoute = vmState.activeRoute;
    final alternativeRoutes = vmState.alternativeRoutes;
    final selectedRouteIndex = vmState.selectedRouteIndex;
    final isLoadingRoute = vmState.isLoadingRoute;
    final showRouteInfo = vmState.showRouteInfo;

    final nearbyRides = ref.watch(
      nearbyRidesStreamProvider(queryAnchor, searchRadius),
    );
    final filteredNearbyRides = nearbyRides.whenData(
      (rides) =>
          ref.read(riderHomeViewModelProvider.notifier).applyFilter(rides),
    );
    final homeVmState = ref.watch(homeViewModelProvider);
    final hotspots = homeVmState.hotspots;
    final user = homeVmState.user;

    return Stack(
      children: [
        // ── Map ───────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: loc,
            initialZoom: currentZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                final vm = ref.read(riderHomeViewModelProvider.notifier);
                final nextZoom = position.zoom;
                vm.updateZoom(nextZoom);
                vm.disableFollowingUser();
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _mapStyles[selectedMapStyle]!,
              userAgentPackageName: 'com.sportconnect.app',
            ),

            if (activeRoute != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: activeRoute.coordinates,
                    color: AppColors.primary,
                    strokeWidth: 5,
                  ),
                  ...alternativeRoutes.asMap().entries.map(
                    (e) => Polyline(
                      points: e.value.coordinates,
                      color: e.key == selectedRouteIndex
                          ? AppColors.primary.withValues(alpha: 0.8)
                          : AppColors.textSecondary.withValues(alpha: 0.4),
                      strokeWidth: e.key == selectedRouteIndex ? 5 : 3,
                    ),
                  ),
                ],
              ),

            if (showNearbyDrivers)
              filteredNearbyRides.when(
                data: (rides) => MarkerLayer(markers: _buildRideMarkers(rides)),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),

            if (showHotspots)
              hotspots.when(
                data: (spots) => MarkerLayer(
                  markers: spots
                      .map(
                        (h) => Marker(
                          point: h.location.toLatLng(),
                          width: 80.w,
                          height: 40.h,
                          child: _buildHotspotMarker(h),
                        ),
                      )
                      .toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, _) => const MarkerLayer(markers: []),
              ),

            MarkerLayer(
              markers: [
                Marker(
                  point: loc,
                  width: 60.w,
                  height: 60.h,
                  child: _buildCurrentLocationMarker(vmState),
                ),
              ],
            ),

            if (showDistanceRadius)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: loc,
                    radius: searchRadius * 1000,
                    useRadiusInMeter: true,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderColor: AppColors.primary.withValues(alpha: 0.5),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
          ],
        ),

        // ── Top bar ───────────────────────────────────────────
        _buildTopControls(user),

        // ── Filter chips ──────────────────────────────────────
        _buildFilterBar(filteredNearbyRides, vmState),

        // ── Right-side map controls ───────────────────────────
        _buildMapControls(vmState),

        // ── Radius slider ─────────────────────────────────────
        if (showDistanceRadius) _buildRadiusSlider(vmState),

        // ── Route info panel ──────────────────────────────────
        if (showRouteInfo && activeRoute != null) _buildRouteInfoPanel(vmState),

        // ── Empty state hint ──────────────────────────────────
        if (showNearbyDrivers)
          filteredNearbyRides.when(
            data: (rides) => rides.isEmpty
                ? Positioned(
                    top: 160.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).noRidesAvailableNearby,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

        // ── Loading route overlay ─────────────────────────────
        if (isLoadingRoute)
          Positioned(
            top: 160.h,
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                      AppLocalizations.of(context).loadingRoute,
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

        // ── Active trip banner ────────────────────────────────
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 100.h,
          child: const _ActiveTripBanner(),
        ),

        // ── Quick stats ───────────────────────────────────────
        _buildQuickStatsBar(filteredNearbyRides),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // Map widgets
  // ─────────────────────────────────────────────────────────────

  Widget _buildTopControls(AsyncValue<dynamic> user) {
    final l10n = AppLocalizations.of(context);
    // Watch unread notifications count from your provider
    // final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            // Avatar → Profile
            Semantics(
              button: true,
              label: l10n.navProfile,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.profile.path),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: user.when(
                    data: (u) => PremiumAvatar(
                      imageUrl: u?.photoUrl,
                      name: u?.displayName ?? 'User',
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

            // Search bar (fake — opens sheet on tap)
            Expanded(
              child: GestureDetector(
                onTap: _showInlineSearchSheet,
                child: AbsorbPointer(
                  child: AppSearchBar(
                    controller: _searchController,
                    onChanged: (_) {},
                    hintText: l10n.whereAreYouGoing,
                  ),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Notifications with badge
            Semantics(
              button: true,
              label: l10n.settingsNotifications,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.notifications.path),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  // Replace 0 with your real unreadCount provider value
                  child: _NotificationBadge(
                    count: 0,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  /// Filter bar with live counts per chip.
  Widget _buildFilterBar(
    AsyncValue<List<RideModel>> filteredNearbyRides,
    RiderHomeState vmState,
  ) {
    final l10n = AppLocalizations.of(context);
    final queryAnchor =
        vmState.nearbyQueryAnchor ??
        vmState.currentLocation ??
        const LatLng(0, 0);
    final searchRadius = vmState.searchRadius;
    final selectedFilter = vmState.selectedFilter;
    final allRides =
        ref.watch(nearbyRidesStreamProvider(queryAnchor, searchRadius)).value ??
        [];

    final filters = [
      {
        'id': 'all',
        'label': l10n.filterAll,
        'icon': Icons.apps,
        'count': allRides.length,
      },
      {
        'id': 'available',
        'label': l10n.availableSeats,
        'icon': Icons.event_seat,
        'count': allRides.where((r) => r.availableSeats > 0).length,
      },
      {
        'id': 'premium',
        'label': l10n.premium,
        'icon': Icons.star,
        'count': allRides.where((r) => r.isPremium).length,
      },
      {
        'id': 'eco',
        'label': l10n.eco,
        'icon': Icons.eco,
        'count': allRides.where((r) => r.isEco).length,
      },
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
            final f = filters[index];
            final isSelected = selectedFilter == f['id'];
            final count = f['count'] as int;

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Semantics(
                selected: isSelected,
                button: true,
                label: '${f['label']} filter, $count rides',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(riderHomeViewModelProvider.notifier)
                        .setFilter(f['id'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          f['icon'] as IconData,
                          size: 14.sp,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          f['label'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  /// Right-side map control panel — toggles + a visually distinct events button.
  Widget _buildMapControls(RiderHomeState vmState) {
    final l10n = AppLocalizations.of(context);
    final showDistanceRadius = vmState.showDistanceRadius;
    final showHotspots = vmState.showHotspots;
    final showNearbyDrivers = vmState.showNearbyDrivers;
    final isFollowingUser = vmState.isFollowingUser;
    final currentLocation = vmState.currentLocation;
    final currentZoom = vmState.currentZoom;

    return Positioned(
      right: 16.w,
      top: 160.h,
      child: Column(
        children: [
          _buildMapControl(
            icon: Icons.layers_outlined,
            onTap: _showMapStylePicker,
          ),
          SizedBox(height: 8.h),
          _buildMapControl(
            icon: Icons.radar_rounded,
            isActive: showDistanceRadius,
            tooltip: l10n.searchRadius,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(riderHomeViewModelProvider.notifier)
                  .toggleDistanceRadius();
            },
          ),
          SizedBox(height: 8.h),
          _buildMapControl(
            icon: Icons.place_outlined,
            isActive: showHotspots,
            tooltip: l10n.hotspots,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(riderHomeViewModelProvider.notifier).toggleHotspots();
            },
          ),
          SizedBox(height: 8.h),
          _buildMapControl(
            icon: Icons.directions_car_outlined,
            isActive: showNearbyDrivers,
            tooltip: l10n.nearbyRides,
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(riderHomeViewModelProvider.notifier)
                  .toggleNearbyDrivers();
            },
          ),
          SizedBox(height: 8.h),
          _buildMapControl(
            icon: isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
            isActive: isFollowingUser,
            tooltip: l10n.followLocation,
            onTap: () {
              HapticFeedback.mediumImpact();
              final vm = ref.read(riderHomeViewModelProvider.notifier);
              vm.toggleFollowingUser();
              final newState = ref.read(riderHomeViewModelProvider);
              if (newState.isFollowingUser && currentLocation != null) {
                _mapController.move(currentLocation, currentZoom);
              }
            },
          ),
          // Divider to visually separate navigation action from toggles
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Container(
              width: 36.w,
              height: 1,
              color: AppColors.border.withValues(alpha: 0.6),
            ),
          ),
          _buildMapControl(
            icon: Icons.emoji_events_outlined,
            tooltip: l10n.events,
            isNavigation: true,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push(AppRoutes.events.path);
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
    bool isNavigation = false,
    String? tooltip,
  }) {
    return Semantics(
      button: true,
      label: tooltip ?? 'Map control',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isNavigation
                ? AppColors.surface
                : isActive
                ? AppColors.primary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: isNavigation
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 22.sp,
            color: isNavigation
                ? AppColors.primary
                : isActive
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationMarker(RiderHomeState vmState) {
    final isFollowingUser = vmState.isFollowingUser;
    final userHeading = vmState.userHeading;

    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, _) => Stack(
        alignment: Alignment.center,
        children: [
          if (isFollowingUser)
            Container(
              width: 50.w * (1 + _pulseAnimationController.value * 0.3),
              height: 50.w * (1 + _pulseAnimationController.value * 0.3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.2 * (1 - _pulseAnimationController.value),
                ),
                shape: BoxShape.circle,
              ),
            ),
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: userHeading * (3.14159 / 180),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.navigation, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildRideMarkers(List<RideModel> rides) {
    return rides
        .map(
          (ride) => Marker(
            point: ride.origin.toLatLng(),
            width: 70.w,
            height: 80.h,
            child: GestureDetector(
              onTap: () => _showRideDetails(ride),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
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
                      AppLocalizations.of(
                        context,
                      ).value5(ride.pricePerSeat.toStringAsFixed(0)),
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
          ),
        )
        .toList();
  }

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
            AppLocalizations.of(context).value2(hotspot.rideCount),
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

  Widget _buildRadiusSlider(RiderHomeState vmState) {
    final searchRadius = vmState.searchRadius;

    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 130.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
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
                      AppLocalizations.of(context).searchRadius,
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
                    AppLocalizations.of(
                      context,
                    ).valueKm(searchRadius.toStringAsFixed(1)),
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
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                trackHeight: 4.h,
              ),
              child: Slider(
                value: searchRadius,
                min: 1,
                max: 25,
                divisions: 24,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  ref
                      .read(riderHomeViewModelProvider.notifier)
                      .updateSearchRadius(v);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildQuickStatsBar(AsyncValue<List<RideModel>> nearbyRides) {
    return Positioned(
      left: 16.w,
      bottom: 16.h,
      child: nearbyRides.when(
        data: (rides) {
          final seats = rides.fold<int>(0, (s, r) => s + r.availableSeats);
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
                  AppLocalizations.of(context).value2(rides.length),
                  AppLocalizations.of(context).rides,
                ),
                SizedBox(width: 16.w),
                Container(width: 1, height: 24.h, color: AppColors.border),
                SizedBox(width: 16.w),
                _buildStatItem(
                  Icons.event_seat,
                  AppLocalizations.of(context).value2(seats),
                  AppLocalizations.of(context).seats,
                ),
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
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteInfoPanel(RiderHomeState vmState) {
    final activeRoute = vmState.activeRoute!;

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
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.route, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueKm(activeRoute.distanceKm.toStringAsFixed(1)),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueMin(activeRoute.durationMinutes),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close route info',
              onPressed: () {
                ref.read(riderHomeViewModelProvider.notifier).clearRoutes();
              },
              icon: Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  // ─────────────────────────────────────────────────────────────
  // Map style picker
  // ─────────────────────────────────────────────────────────────

  void _showMapStylePicker() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mapStyle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStyleOption(l10n.standard, l10n.standard2, Icons.map),
                SizedBox(width: 12.w),
                _buildStyleOption(l10n.terrain, l10n.terrain2, Icons.terrain),
                SizedBox(width: 12.w),
                _buildStyleOption(l10n.dark, l10n.dark2, Icons.dark_mode),
                SizedBox(width: 12.w),
                _buildStyleOption(
                  'satellite',
                  l10n.satellite,
                  Icons.satellite_alt,
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleOption(String id, String label, IconData icon) {
    final vmState = ref.watch(riderHomeViewModelProvider);
    final isSelected = vmState.selectedMapStyle == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(riderHomeViewModelProvider.notifier).setMapStyle(id);
          context.pop();
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
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

  // ─────────────────────────────────────────────────────────────
  // Search sheet
  // ─────────────────────────────────────────────────────────────

  void _showInlineSearchSheet() {
    HapticFeedback.selectionClick();
    final outerContext = context;
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    int selectedSeats = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final vmState = ref.read(riderHomeViewModelProvider);
          final anchor =
              vmState.nearbyQueryAnchor ??
              vmState.currentLocation ??
              const LatLng(0, 0);
          final searchRadius = vmState.searchRadius;
          return Consumer(
            builder: (ctx, cRef, _) {
              final nearbyRides = cRef.watch(
                nearbyRidesStreamProvider(anchor, searchRadius),
              );
              final l10n = AppLocalizations.of(ctx);

              return Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle
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
                            onTap: () => ctx.pop(),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.textPrimary,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            l10n.findARide,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              outerContext.push(AppRoutes.searchRides.path);
                            },
                            icon: Icon(Icons.tune_rounded, size: 18.sp),
                            label: Text(l10n.filters),
                          ),
                        ],
                      ),
                    ),

                    // From / To inputs
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: fromCtrl,
                            onChanged: (_) => setModal(() {}),
                            decoration: InputDecoration(
                              hintText: l10n.fromWhere,
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
                          TextField(
                            controller: toCtrl,
                            onChanged: (_) => setModal(() {}),
                            decoration: InputDecoration(
                              hintText: l10n.toWhere,
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

                    // Date + Seats
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: ctx,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 90),
                                  ),
                                );
                                if (d != null) setModal(() => selectedDate = d);
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
                                    if (selectedSeats > 1)
                                      setModal(() => selectedSeats--);
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).value2(selectedSeats),
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
                                      setModal(() => selectedSeats++);
                                    } else {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).maxSeatsReached,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
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

                    // Results header — count reflects filtered list, not raw
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.nearbyRides,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          nearbyRides.when(
                            data: (rides) {
                              final filtered = _filterSearchSheetRides(
                                rides,
                                fromText: fromCtrl.text,
                                toText: toCtrl.text,
                                date: selectedDate,
                                seats: selectedSeats,
                              );
                              return Text(
                                l10n.valueAvailable(filtered.length),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
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

                    Expanded(
                      child: nearbyRides.when(
                        data: (rides) {
                          final filtered = _filterSearchSheetRides(
                            rides,
                            fromText: fromCtrl.text,
                            toText: toCtrl.text,
                            date: selectedDate,
                            seats: selectedSeats,
                          );

                          if (filtered.isEmpty) {
                            final vm = ref.read(
                              riderHomeViewModelProvider.notifier,
                            );
                            final hasOtherDays = vm.applyFilter(rides).any((r) {
                              final rd = DateTime(
                                r.departureTime.year,
                                r.departureTime.month,
                                r.departureTime.day,
                              );
                              final sd = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              );
                              return rd != sd;
                            });
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
                                    l10n.noRidesAvailableNearby,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    hasOtherDays
                                        ? l10n.tryADifferentDate
                                        : l10n.tryExpandingYourSearchRadius,
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
                            itemCount: filtered.length,
                            itemBuilder: (_, i) =>
                                _buildSearchRideCard(filtered[i], ctx),
                          );
                        },
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        error: (_, _) => Center(
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
                                AppLocalizations.of(context).failedToLoadRides,
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
      ),
    ).whenComplete(() {
      fromCtrl.dispose();
      toCtrl.dispose();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Ride cards & chips
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchRideCard(RideModel ride, BuildContext sheetCtx) {
    final time = _formatTime(ride.departureTime);
    return GestureDetector(
      onTap: () {
        sheetCtx.pop();
        context.pushNamed(
          AppRoutes.rideDetail.name,
          pathParameters: {'id': ride.id},
        );
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
            DriverInfoWidget(
              driverId: ride.driverId,
              builder: (ctx, name, photo, rating) => Row(
                children: [
                  PremiumAvatar(imageUrl: photo, name: name, size: 44.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
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
                              rating.average.toStringAsFixed(1),
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
                              time,
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
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).value5(ride.pricePerSeat.toStringAsFixed(0)),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
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
                        ride.origin.address.isNotEmpty
                            ? ride.origin.address
                            : AppLocalizations.of(context).pickupPoint,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        ride.destination.address.isNotEmpty
                            ? ride.destination.address
                            : AppLocalizations.of(context).destination,
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
            Row(
              children: [
                _buildSearchChip(
                  Icons.event_seat,
                  AppLocalizations.of(context).valueSeats(ride.availableSeats),
                  AppColors.primary,
                ),
                if (ride.isEco) ...[
                  SizedBox(width: 8.w),
                  _buildSearchChip(
                    Icons.eco_rounded,
                    AppLocalizations.of(context).eco,
                    AppColors.success,
                  ),
                ],
                if (ride.isPremium) ...[
                  SizedBox(width: 8.w),
                  _buildSearchChip(
                    Icons.star_rounded,
                    AppLocalizations.of(context).premium,
                    AppColors.starFilled,
                  ),
                ],
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

  // ─────────────────────────────────────────────────────────────
  // Ride details sheet
  // ─────────────────────────────────────────────────────────────

  void _showRideDetails(RideModel ride) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Route preview — lightweight, no second map instance
              Container(
                height: 90.h,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
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
                          size: 16.sp,
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.origin.address.isNotEmpty
                                ? ride.origin.address
                                : AppLocalizations.of(context).pickupLocation,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            ride.destination.address.isNotEmpty
                                ? ride.destination.address
                                : AppLocalizations.of(context).destination,
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
              ),

              SizedBox(height: 16.h),

              DriverInfoWidget(
                driverId: ride.driverId,
                builder: (ctx, name, photo, rating) => Row(
                  children: [
                    PremiumAvatar(imageUrl: photo, name: name, size: 50.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
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
                                rating.average.toStringAsFixed(1),
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
                    // Price + seat total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).value5(ride.pricePerSeat.toStringAsFixed(0)),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context).perSeat,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  _buildRideInfoChip(
                    Icons.event_seat,
                    AppLocalizations.of(
                      context,
                    ).valueSeats(ride.availableSeats),
                  ),
                  SizedBox(width: 8.w),
                  if (ride.isEco)
                    _buildRideInfoChip(
                      Icons.eco,
                      AppLocalizations.of(context).eco,
                      color: AppColors.success,
                    ),
                  if (ride.isPremium)
                    _buildRideInfoChip(
                      Icons.star,
                      AppLocalizations.of(context).premium,
                      color: AppColors.starFilled,
                    ),
                ],
              ),

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ctx.pop();
                    context.pushNamed(
                      AppRoutes.rideDetail.name,
                      pathParameters: {'id': ride.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).bookThisRide,
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
        ),
      ),
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

  // ─────────────────────────────────────────────────────────────
  // Filtering helpers
  // ─────────────────────────────────────────────────────────────

  List<RideModel> _filterSearchSheetRides(
    List<RideModel> rides, {
    required String fromText,
    required String toText,
    required DateTime date,
    required int seats,
  }) {
    final from = fromText.trim().toLowerCase();
    final to = toText.trim().toLowerCase();
    final dateOnly = DateTime(date.year, date.month, date.day);

    final vm = ref.read(riderHomeViewModelProvider.notifier);
    return vm.applyFilter(rides).where((ride) {
      final rideDate = DateTime(
        ride.departureTime.year,
        ride.departureTime.month,
        ride.departureTime.day,
      );
      final originTxt = '${ride.origin.address} ${ride.origin.city ?? ''}'
          .toLowerCase();
      final destTxt =
          '${ride.destination.address} ${ride.destination.city ?? ''}'
              .toLowerCase();

      return (from.isEmpty || originTxt.contains(from)) &&
          (to.isEmpty || destTxt.contains(to)) &&
          rideDate == dateOnly &&
          ride.availableSeats >= seats;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────
  // Formatters
  // ─────────────────────────────────────────────────────────────

  String _formatDateShort(DateTime date) {
    final today = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    if (d == t) return AppLocalizations.of(context).today;
    if (d == t.add(const Duration(days: 1)))
      return AppLocalizations.of(context).tomorrow;
    return '${date.day}/${date.month}';
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────
// Notification badge helper widget
// ─────────────────────────────────────────────────────────────

class _NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  const _NotificationBadge({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active Trip Banner
// ─────────────────────────────────────────────────────────────

class _ActiveTripBanner extends ConsumerWidget {
  const _ActiveTripBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    final bookings =
        ref.watch(bookingsByPassengerProvider(user.uid)).value ?? [];

    final accepted =
        bookings.where((b) => b.status == BookingStatus.accepted).toList()
          ..sort(
            (a, b) => (a.createdAt ?? DateTime(0)).compareTo(
              b.createdAt ?? DateTime(0),
            ),
          );
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

    if (accepted.isEmpty && pending.isEmpty) return const SizedBox.shrink();

    if (accepted.isNotEmpty) {
      final booking = accepted.first;
      final ride = ref.watch(rideStreamProvider(booking.rideId)).value;

      if (ride != null &&
          (ride.status == RideStatus.completed ||
              ride.status == RideStatus.cancelled)) {
        return _pendingChip(context, pending);
      }
      return _acceptedBanner(context, booking, ride);
    }

    return _pendingChip(context, pending);
  }

  Widget _acceptedBanner(
    BuildContext context,
    RideBooking booking,
    RideModel? ride,
  ) {
    final l10n = AppLocalizations.of(context);
    final isInProgress = ride?.status == RideStatus.inProgress;
    final needsPayment =
        !isInProgress &&
        booking.paymentIntentId == null &&
        (ride?.acceptsOnlinePayment ?? false);

    final IconData icon;
    final String title;
    final String subtitle;
    final VoidCallback onTap;
    final Color color;

    if (isInProgress) {
      icon = Icons.navigation_rounded;
      title = l10n.rideInProgress;
      subtitle = ride != null
          ? '${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}'
          : l10n.tapToOpenNavigation;
      onTap = () => context.push(
        '${AppRoutes.riderActiveRide.path}?rideId=${booking.rideId}',
      );
      color = AppColors.success;
    } else if (needsPayment) {
      icon = Icons.payment_rounded;
      title = l10n.completePayment;
      subtitle = l10n.bookingAcceptedPaymentRequired;
      onTap = () => context.pushNamed(
        AppRoutes.rideBookingPending.name,
        pathParameters: {'rideId': booking.rideId},
      );
      color = AppColors.warning;
    } else {
      icon = Icons.access_time_rounded;
      title = l10n.bookingConfirmed;
      subtitle = ride != null
          ? l10n.departingValue(_formatDeparture(ride.departureTime, context))
          : l10n.tapToViewCountdown;
      onTap = () => context.pushNamed(
        AppRoutes.rideCountdown.name,
        pathParameters: {'bookingId': booking.id},
      );
      color = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.87),
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.25, curve: Curves.easeOutCubic),
    );
  }

  Widget _pendingChip(BuildContext context, List<RideBooking> pending) {
    if (pending.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.riderMyRides.name),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Static clock icon — spinner was misleading (passive wait, not active loading)
                  Icon(
                    Icons.schedule_rounded,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.awaitingDriverCount(pending.length),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }

  /// Fully localized departure formatter.
  String _formatDeparture(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diff = dt.difference(DateTime.now());
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (diff.inDays == 0) return l10n.departingTodayAt(h, m);
    if (diff.inDays == 1) return l10n.departingTomorrow;
    return l10n.departingInDays(diff.inDays);
  }
}
