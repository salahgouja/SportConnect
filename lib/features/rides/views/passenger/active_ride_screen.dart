import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
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
  bool _hasNavigatedOnCancel = false;

  // MapController for live tracking map — allows auto-panning to driver
  final MapController _liveMapController = MapController();

  // H1: Passenger's own GPS location for map pin
  LatLng? _passengerLocation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // H1: Fetch passenger's current location for map display
    _fetchPassengerLocation();
  }

  Future<void> _fetchPassengerLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) {
        setState(() {
          _passengerLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {
      // Location not available — pin simply won't show
    }
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
    final l10n = AppLocalizations.of(context)!;

    final userName = currentUser?.displayName ?? 'A passenger';
    final origin = ride.origin.address;
    final destination = ride.destination.address;
    final status = ride.status == RideStatus.inProgress
        ? l10n.tripStatusInProgress
        : l10n.tripStatusScheduled;
    final rideId = ride.id.substring(0, 8).toUpperCase();
    final departure = _formatDateTime(ride.departureTime);

    final msg = l10n.tripShareMessage(
      userName,
      status,
      origin,
      destination,
      rideId,
      departure,
    );

    await SharePlus.instance.share(ShareParams(text: msg));
  }

  // ==================== SECTION 7 PASSENGER HELPERS ====================

  /// SOS — shares ride details with emergency formatting.
  void _triggerSOS(RideModel ride, ActiveRideState rideState) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.sos, color: AppColors.error),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).emergencySos),
          ],
        ),
        content: Text(AppLocalizations.of(context).sosShareConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final notifier = ref.read(
                activeRideViewModelProvider(widget.rideId).notifier,
              );
              final sosMessage = notifier.generateSosMessage();
              await SharePlus.instance.share(ShareParams(text: sosMessage));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).shareSos),
          ),
        ],
      ),
    );
  }

  /// Shows dialog for passenger to describe and request a mid-ride stop.
  void _showRequestStopDialog(RideModel ride) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_location_alt, color: AppColors.warning),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).requestAStop),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).requestStopDescription),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).requestStopHint,
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final desc = controller.text.trim();
              if (desc.isEmpty) return;
              Navigator.of(ctx).pop();
              ref
                  .read(activeRideViewModelProvider(widget.rideId).notifier)
                  .requestMidRideStop(desc);
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).stopRequestSentToDriver,
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).requestStop),
          ),
        ],
      ),
    );
  }

  /// Quick message chips for passenger (e.g. "I'm at pickup", "Running late").
  Widget _buildPassengerQuickMessages(
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final messages = [
      'I\'m at the pickup',
      'Running late',
      'Wrong location',
      'On my way',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest quick message received
          if (rideState.latestQuickMessage != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.message, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
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
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: messages.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return ActionChip(
                  label: Text(
                    messages[index],
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  onPressed: () {
                    final notifier = ref.read(
                      activeRideViewModelProvider(widget.rideId).notifier,
                    );
                    final user = ref.read(currentUserProvider).value;
                    if (user == null) return;
                    notifier.sendQuickMessage(
                      chatId: ride.id,
                      message: messages[index],
                      senderId: user.uid,
                      senderName: user.displayName ?? 'Passenger',
                    );
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          ).sentMessage(messages[index]),
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
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
        ],
      ),
    );
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
            text: AppLocalizations.of(context).goHome,
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
      // Set flag BEFORE scheduling the push to prevent double-navigation
      // if the widget rebuilds between the status check and the callback.
      ref
          .read(activeRideViewModelProvider(widget.rideId).notifier)
          .markCompletionNavigationHandled();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement(
            AppRoutes.rideCompletion.path.replaceFirst(':id', ride.id),
          );
        }
      });
    }

    // Auto-navigate away when the ride is cancelled mid-trip.
    if (ride.status == RideStatus.cancelled && !_hasNavigatedOnCancel) {
      _hasNavigatedOnCancel = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).rideHasBeenCancelled),
            ),
          );
          context.goNamed(AppRoutes.riderMyRides.name);
        }
      });
    }

    // For in-progress rides, use a full-screen map-first layout
    if (ride.status == RideStatus.inProgress) {
      return _buildMapFirstLayout(context, ride, rideState, driverAsync);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ride)),
        // Static route map — shown for scheduled/active/completed rides
        SliverToBoxAdapter(
          child: _buildStaticRouteMap(context, ride, rideState)
              .animate()
              .fadeIn(duration: 400.ms, delay: 50.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: _buildStatusSection(context, ride, rideState)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
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
                            .read(
                              activeRideViewModelProvider(
                                widget.rideId,
                              ).notifier,
                            )
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

  // ═══════════════════════════════════════════════════════════════════
  // MAP-FIRST LAYOUT (in-progress rides)
  // ═══════════════════════════════════════════════════════════════════

  /// Full-screen map experience for in-progress rides.
  /// Uses a Stack with map background + overlay controls + bottom info panel.
  Widget _buildMapFirstLayout(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
    AsyncValue<UserModel?> driverAsync,
  ) {
    final originLatLng = LatLng(ride.origin.latitude, ride.origin.longitude);
    final destLatLng = LatLng(
      ride.destination.latitude,
      ride.destination.longitude,
    );
    final driverLoc = rideState.driverLiveLocation;
    final driverLatLng = driverLoc != null
        ? LatLng(driverLoc.latitude, driverLoc.longitude)
        : originLatLng;
    final etaMinutes =
        rideState.remainingEtaMinutes ??
        ((ride.durationMinutes ?? 30) * 0.5).round();
    final distToDest = rideState.remainingDistanceKm ?? ride.distanceKm ?? 0;

    // Auto-pan to follow driver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _liveMapController.move(driverLatLng, 15);
    });

    final routePoints =
        rideState.remainingRoutePoints ??
        rideState.osrmRoutePoints ??
        [
          originLatLng,
          ...ride.route.waypoints.map(
            (wp) => LatLng(wp.location.latitude, wp.location.longitude),
          ),
          destLatLng,
        ];

    return Stack(
      children: [
        // ── Full-screen live map ──
        FlutterMap(
          mapController: _liveMapController,
          options: MapOptions(initialCenter: driverLatLng, initialZoom: 15),
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
                              width: 44.w * (1 + _pulseController.value * 0.3),
                              height: 44.w * (1 + _pulseController.value * 0.3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.3 * (1 - _pulseController.value),
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
                                    color: Colors.black.withValues(alpha: 0.3),
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
                      border: Border.all(color: Colors.white, width: 2),
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.flag, color: Colors.white, size: 18.w),
                  ),
                ),
                // Waypoint markers with ETA
                ...ride.route.waypoints.map((wp) {
                  final isPassed = rideState.passedWaypointIndices.contains(
                    wp.order,
                  );
                  final etaMin = rideState.waypointEtaMinutes[wp.order];
                  return Marker(
                    point: LatLng(wp.location.latitude, wp.location.longitude),
                    width: 56.w,
                    height: etaMin != null && !isPassed ? 48.h : 28.w,
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
                            ),
                            child: Text(
                              '${etaMin}m',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: isPassed
                                ? AppColors.textTertiary
                                : AppColors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${wp.order + 1}',
                              style: TextStyle(
                                fontSize: 10.sp,
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
                // H1: Passenger's own location pin
                if (_passengerLocation != null)
                  Marker(
                    point: _passengerLocation!,
                    width: 32.w,
                    height: 32.w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // ── Route loading indicator ──
        if (rideState.osrmRoutePoints == null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 64.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                      child: const CircularProgressIndicator(strokeWidth: 2),
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
          ),

        // ── Top controls ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    _buildMapCircleButton(
                      Icons.arrow_back_ios_new,
                      () => context.pop(),
                    ),
                    SizedBox(width: 12.w),
                    _buildPhaseBadge(rideState.phase),
                    const Spacer(),
                    _buildMapCircleButton(
                      Icons.share_location,
                      () => _shareTrip(ride),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Live indicator ──
        Positioned(
          top: MediaQuery.of(context).padding.top + 56.h,
          right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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

        // ── Night safety banner ──
        if (_isNightTime)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56.h,
            left: 12.w,
            right: 80.w,
            child: _buildNightSafetyBanner(
              context,
            ).animate().fadeIn(duration: 300.ms),
          ),

        // ── Route deviation alert ──
        if (rideState.isOffRoute)
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                (_isNightTime ? 120.h : 56.h),
            left: 20.w,
            right: 20.w,
            child: _buildRouteDeviationAlert(context, rideState)
                .animate()
                .fadeIn(duration: 300.ms)
                .shake(hz: 2, offset: const Offset(2, 0)),
          ),

        // ── E4: Driver location unavailable banner ──
        if (rideState.lastDriverLocationUpdate != null &&
            DateTime.now()
                    .difference(rideState.lastDriverLocationUpdate!)
                    .inMinutes >=
                5)
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                (_isNightTime ? 160.h : 100.h),
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, size: 18.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Driver location unavailable for 5+ min',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

        // ── Bottom draggable info sheet ──
        DraggableScrollableSheet(
          initialChildSize: 0.38,
          minChildSize: 0.15,
          maxChildSize: 0.80,
          snap: true,
          snapSizes: const [0.15, 0.38, 0.80],
          builder: (context, scrollController) {
            return _buildRideInfoSheet(
              context,
              ride,
              rideState,
              driverAsync,
              etaMinutes,
              distToDest,
              scrollController,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMapCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPhaseBadge(ActiveRidePhase phase) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;
    IconData icon;
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        color = AppColors.warning;
        label = l10n.headingToPickup;
        icon = Icons.person_pin_circle;
        break;
      case ActiveRidePhase.enRoute:
        color = AppColors.primary;
        label = l10n.tripInProgress;
        icon = Icons.navigation;
        break;
      case ActiveRidePhase.arriving:
        color = AppColors.success;
        label = l10n.headingToDestination;
        icon = Icons.near_me;
        break;
      case ActiveRidePhase.completed:
        color = AppColors.success;
        label = l10n.rideCompleted;
        icon = Icons.check_circle;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Draggable bottom sheet for the map-first layout — shows ETA, driver info,
  /// route itinerary, and action buttons in a scrollable sheet.
  Widget _buildRideInfoSheet(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
    AsyncValue<UserModel?> driverAsync,
    int etaMinutes,
    double distToDest,
    ScrollController scrollController,
  ) {
    final driver = driverAsync.value;
    final l10n = AppLocalizations.of(context);
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
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Connectivity indicator
          if (!rideState.isConnected)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ).copyWith(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, size: 16.sp, color: AppColors.warning),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Poor connection — updates may be delayed',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Delay banner
          if (rideState.rideDelayMinutes >= 5)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ).copyWith(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 16.sp, color: AppColors.error),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Departure delayed by ${rideState.rideDelayMinutes} min',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Progress bar
          _buildProgressBar(ride, rideState),
          SizedBox(height: 20.h),

          // ETA, distance and speed tiles
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                _buildInfoTile(
                  icon: Icons.access_time_rounded,
                  label: AppLocalizations.of(context).eta,
                  value: etaMinutes < 1
                      ? 'Arriving'
                      : l10n.valueMin(etaMinutes),
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                _buildInfoTile(
                  icon: Icons.straighten_rounded,
                  label: AppLocalizations.of(context).distance,
                  value: distToDest < 1
                      ? '${(distToDest * 1000).toInt()} m'
                      : '${distToDest.toStringAsFixed(1)} km',
                  color: AppColors.warning,
                ),
                SizedBox(width: 12.w),
                _buildInfoTile(
                  icon: Icons.speed_rounded,
                  label: AppLocalizations.of(context).speed,
                  value: '${rideState.currentSpeedKmh.toStringAsFixed(0)} km/h',
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          // Pickup queue position badge (7A)
          if (rideState.phase == ActiveRidePhase.pickingUp &&
              rideState.pickupOrder.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Builder(
              builder: (context) {
                final user = ref.read(currentUserProvider).value;
                final pos = user != null
                    ? rideState.pickupOrder.indexOf(user.uid) + 1
                    : 0;
                if (pos <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_alt,
                          color: AppColors.info,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'You are #$pos in the pickup queue',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],

          SizedBox(height: 16.h),

          // Driver info row
          if (driver != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundImage: driver.photoUrl != null
                        ? NetworkImage(driver.photoUrl!)
                        : null,
                    child: driver.photoUrl == null
                        ? Text(
                            driver.displayName[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                driver.displayName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (driver.isIdVerified) ...[
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.verified,
                                size: 16.sp,
                                color: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14.sp, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(
                              driver.rating.average.toStringAsFixed(1),
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
                  // Call button
                  _buildMapCircleButton(
                    Icons.phone,
                    () => _callDriver(driver.phoneNumber),
                  ),
                  SizedBox(width: 10.w),
                  // Message button
                  _buildMapCircleButton(
                    Icons.message,
                    () => _sendMessage(ride.driverId),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // Quick message chips (7D)
          if (ride.status == RideStatus.inProgress)
            _buildPassengerQuickMessages(ride, rideState),

          // Request mid-ride stop button (E1)
          if (ride.status == RideStatus.inProgress &&
              rideState.phase == ActiveRidePhase.enRoute)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ).copyWith(bottom: 12.h),
              child: OutlinedButton.icon(
                onPressed: () => _showRequestStopDialog(ride),
                icon: Icon(Icons.add_location_alt, size: 18.sp),
                label: Text(AppLocalizations.of(context).requestAStop),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.4),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

          // Route itinerary (Compact)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
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
          ),

          SizedBox(height: 12.h),

          // Share live trip + SOS row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Share button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareTrip(ride),
                    icon: Icon(Icons.share_location, size: 18.sp),
                    label: Text(l10n.shareRide),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // SOS / Emergency button (7C)
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _triggerSOS(ride, rideState),
                    icon: Icon(Icons.sos, size: 18.sp),
                    label: Text(AppLocalizations.of(context).sos),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h + bottomPadding),
        ],
      ),
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
                final distToDest =
                    rideState.remainingDistanceKm ?? ride.distanceKm ?? 0;

                // Estimate ETA: use ride duration ratio or 30 km/h average
                final etaMinutes =
                    rideState.remainingEtaMinutes ??
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
                        // Route polyline — remaining route from driver position
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points:
                                  rideState.remainingRoutePoints ??
                                  rideState.osrmRoutePoints ??
                                  [
                                    originLatLng,
                                    ...ride.route.waypoints.map(
                                      (wp) => LatLng(
                                        wp.location.latitude,
                                        wp.location.longitude,
                                      ),
                                    ),
                                    destLatLng,
                                  ],
                              color: Colors.white,
                              strokeWidth: 6,
                            ),
                            Polyline(
                              points:
                                  rideState.remainingRoutePoints ??
                                  rideState.osrmRoutePoints ??
                                  [
                                    originLatLng,
                                    ...ride.route.waypoints.map(
                                      (wp) => LatLng(
                                        wp.location.latitude,
                                        wp.location.longitude,
                                      ),
                                    ),
                                    destLatLng,
                                  ],
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
                            // Waypoint markers with pickup ETA
                            ...ride.route.waypoints.map((wp) {
                              final isPassed = rideState.passedWaypointIndices
                                  .contains(wp.order);
                              final etaMin =
                                  rideState.waypointEtaMinutes[wp.order];
                              return Marker(
                                point: LatLng(
                                  wp.location.latitude,
                                  wp.location.longitude,
                                ),
                                width: 56.w,
                                height: etaMin != null && !isPassed
                                    ? 48.h
                                    : 28.w,
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
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${etaMin}m',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      width: 28.w,
                                      height: 28.w,
                                      decoration: BoxDecoration(
                                        color: isPassed
                                            ? AppColors.textTertiary
                                            : AppColors.warning,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${wp.order + 1}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
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
                    tooltip: AppLocalizations.of(context).goBackTooltip,
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

  Widget _buildStatusSection(
    BuildContext context,
    RideModel ride,
    ActiveRideState rideState,
  ) {
    final phase = rideState.phase;
    final isInProgress = ride.status == RideStatus.inProgress;
    final isEnRouteOrLater =
        isInProgress &&
        (phase == ActiveRidePhase.enRoute ||
            phase == ActiveRidePhase.arriving ||
            phase == ActiveRidePhase.completed);
    final isArrivingOrLater =
        isInProgress &&
        (phase == ActiveRidePhase.arriving ||
            phase == ActiveRidePhase.completed);
    final isCompleted = ride.status == RideStatus.completed;

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
          _buildStatusDivider(isEnRouteOrLater || isCompleted),
          _buildStatusStep(
            AppLocalizations.of(context).driverOnTheWay,
            isEnRouteOrLater || isCompleted,
            Icons.directions_car,
          ),
          _buildStatusDivider(isArrivingOrLater || isCompleted),
          _buildStatusStep(
            'Arriving Soon',
            isArrivingOrLater || isCompleted,
            Icons.near_me,
          ),
          _buildStatusDivider(isCompleted),
          _buildStatusStep(
            AppLocalizations.of(context).rideCompleted,
            isCompleted,
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
                tooltip: AppLocalizations.of(context).messageDriver,
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
                tooltip: AppLocalizations.of(context).callDriver,
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
            ...ride.route.waypoints.asMap().entries.map((entry) {
              final index = entry.key;
              final wp = entry.value;
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
                                  'Waypoint ${index + 1}',
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
                    margin: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
                    height: 24.h,
                    width: 2,
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
                tooltip: AppLocalizations.of(context).messagePassenger,
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
                  rideState.remainingEtaMinutes != null
                      ? 'Driver is ${(rideState.routeDeviationMeters / 1000).toStringAsFixed(1)} km off route — new ETA ~${rideState.remainingEtaMinutes} min'
                      : 'Driver is ${(rideState.routeDeviationMeters / 1000).toStringAsFixed(1)} km off the planned route',
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
          if (ride.status == RideStatus.draft ||
              ride.status == RideStatus.active)
            PremiumButton(
              text: AppLocalizations.of(context).cancelRide2,
              icon: Icons.cancel_outlined,
              onPressed: () => _showCancelDialog(context, ride),
              style: PremiumButtonStyle.outline,
            ),
          if (ride.status == RideStatus.completed)
            PremiumButton(
              text: AppLocalizations.of(context).rateAndReview,
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
          content: Text(AppLocalizations.of(context).failedToOpenChatTryAgain),
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
      barrierLabel: AppLocalizations.of(context).cancelRide,
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
              content: Text(
                AppLocalizations.of(context).bookingNotFoundTryAgain,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await ref
          .read(rideActionsViewModelProvider)
          .cancelBooking(rideId: ride.id, bookingId: myBooking.id);

      // Auto-refund if payment was made and intent ID exists
      if (myBooking.paymentIntentId != null) {
        try {
          await ref
              .read(paymentViewModelProvider.notifier)
              .refundBookingPayment(
                paymentId: myBooking.paymentIntentId!,
                reason: 'User cancelled ride',
              );
        } catch (e) {
          debugPrint('Failed to refund: $e');
        }
      }

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

  Widget _buildProgressBar(RideModel ride, ActiveRideState rideState) {
    double progress = 0.0;
    if (ride.distanceKm != null && ride.distanceKm! > 0) {
      final remaining = rideState.remainingDistanceKm ?? ride.distanceKm!;
      progress = ((ride.distanceKm! - remaining) / ride.distanceKm!).clamp(
        0.0,
        1.0,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
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
                '${(progress * 100).toInt()}%',
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
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
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
