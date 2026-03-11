import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_navigation_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Real-time ride navigation screen with GPS tracking.
///
/// Features:
/// - Live GPS position tracking with Firebase sync
/// - Route progress with origin/destination
/// - ETA, distance remaining, and speed (km/h)
/// - Driver info panel with avatar and rating
/// - Share live location link
/// - Arrival confirmation with ride completion flow
class RideNavigationScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideNavigationScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideNavigationScreen> createState() =>
      _RideNavigationScreenState();
}

class _RideNavigationScreenState extends ConsumerState<RideNavigationScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  RideNavigationState get _navState => ref.watch(rideNavigationViewModelProvider);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startLocationTracking();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      final accepted = await PermissionDialogHelper.showRideTrackingRationale(
        context,
      );
      if (!accepted) return;
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return;
      }
    }

    await ref
      .read(rideNavigationViewModelProvider.notifier)
      .startTracking(widget.rideId);
  }

  /// Builds the polyline points for the route.
  /// Uses the encoded polyline from the ride model if available,
  /// otherwise falls back to waypoints between current and destination.
  List<LatLng> _buildRoutePoints(
    RideModel ride,
    LatLng currentLatLng,
    LatLng destLatLng,
  ) {
    final encoded = ride.route.polylineEncoded;
    if (encoded != null && encoded.isNotEmpty) {
      return RoutingService.decodePolyline(encoded, 5);
    }
    // Fallback: current position → sorted waypoints → destination
    final points = <LatLng>[currentLatLng];
    final waypoints = List.of(ride.route.waypoints)
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final wp in waypoints) {
      points.add(LatLng(wp.location.latitude, wp.location.longitude));
    }
    points.add(destLatLng);
    return points;
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final l10n = AppLocalizations.of(context);

    ref.listen(rideStreamProvider(widget.rideId), (previous, next) {
      final ride = next.value;
      if (ride == null) return;
      final notifier = ref.read(rideNavigationViewModelProvider.notifier);
      notifier.syncRide(ride);
      notifier.ensureOsrmRoute(ride);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  l10n.somethingWentWrong,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Unable to load ride navigation data.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(rideStreamProvider(widget.rideId)),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (ride) {
          if (ride == null) {
            return Center(child: Text(l10n.rideNotFound));
          }
          return _buildNavigationView(context, ride, l10n);
        },
      ),
    );
  }

  Widget _buildNavigationView(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        // Map placeholder (replace with actual map widget e.g. google_maps_flutter)
        _buildMapArea(ride),

        // Top bar
        _buildTopBar(context, ride),

        // Bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomPanel(context, ride, l10n),
        ),

        // Share location button
        Positioned(
          top: MediaQuery.of(context).padding.top + 60.h,
          right: 16.w,
          child: _buildShareButton(ride),
        ),
      ],
    );
  }

  Widget _buildMapArea(RideModel ride) {
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );
    final currentPosition = _navState.currentPosition;
    final currentLatLng = currentPosition != null
        ? LatLng(currentPosition.latitude, currentPosition.longitude)
        : originLatLng;

    if (currentPosition == null) {
      // Show a loading state while waiting for first GPS fix
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
      options: MapOptions(initialCenter: currentLatLng, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sportconnect.app',
        ),

        // Route polyline — use OSRM real road route when available, else fallback
        PolylineLayer(
          polylines: [
            Polyline(
              points:
                  _navState.osrmRoutePoints ??
                  _buildRoutePoints(ride, currentLatLng, destLatLng),
              color: Colors.white,
              strokeWidth: 6,
            ),
            Polyline(
              points:
                  _navState.osrmRoutePoints ??
                  _buildRoutePoints(ride, currentLatLng, destLatLng),
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ],
        ),

        // Markers
        MarkerLayer(
          markers: [
            // Current position marker (animated via AnimatedBuilder not possible in marker,
            // so use a static pulsing style)
            Marker(
              point: currentLatLng,
              width: 50.w,
              height: 50.w,
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
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 18.w,
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
                  Icons.trip_origin_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),

            // Destination marker
            Marker(
              point: destLatLng,
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
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, RideModel ride) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
        child: Row(
          children: [
            _buildNavButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
            SizedBox(width: 12.w),
            // Driver info pill
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DriverAvatarWidget(driverId: ride.driverId, radius: 14),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DriverNameWidget(
                        driverId: ride.driverId,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22.sp, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildShareButton(RideModel ride) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final pos = _navState.currentPosition;
        final locationText = pos != null
            ? 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}'
            : 'Live location not yet available';
        SharePlus.instance.share(
          ShareParams(
            text:
                'Track my SportConnect ride!\n'
                'From: ${ride.origin.address}\n'
                'To: ${ride.destination.address}\n'
                '$locationText',
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.share_location_rounded,
          color: AppColors.primary,
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Progress bar
          _buildProgressBar(),
          SizedBox(height: 20.h),

          // ETA and distance
          Row(
            children: [
              _buildInfoTile(
                icon: Icons.access_time_rounded,
                label: 'ETA',
                value: _navState.eta,
                color: AppColors.primary,
              ),
              SizedBox(width: 16.w),
              _buildInfoTile(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: _navState.distanceRemaining,
                color: AppColors.warning,
              ),
              SizedBox(width: 16.w),
              _buildInfoTile(
                icon: Icons.speed_rounded,
                label: 'Speed',
                value: '${_navState.speedKmh.toStringAsFixed(0)} km/h',
                color: AppColors.success,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Route summary
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildMiniRouteRow(
                  Icons.trip_origin_rounded,
                  AppColors.success,
                  ride.origin.address,
                ),
                // Show intermediate waypoints
                for (final wp in ride.route.waypoints)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _buildMiniRouteRow(
                      Icons.circle,
                      AppColors.warning,
                      wp.location.address,
                    ),
                  ),
                SizedBox(height: 8.h),
                _buildMiniRouteRow(
                  Icons.location_on_rounded,
                  AppColors.error,
                  ride.destination.address,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: "I've Arrived",
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(rideNavigationViewModelProvider.notifier)
                        .stopTracking();
                    context.pushReplacement(
                      AppRoutes.rideCompletion.path.replaceFirst(
                        ':id',
                        widget.rideId,
                      ),
                    );
                  },
                  icon: Icons.flag_rounded,
                  style: PremiumButtonStyle.success,
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 52.w,
                child: PremiumButton(
                  text: '',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.pop();
                  },
                  style: PremiumButtonStyle.ghost,
                  icon: Icons.close_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trip Progress',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(_navState.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: _navState.progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
