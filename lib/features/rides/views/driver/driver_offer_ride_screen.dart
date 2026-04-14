import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/events/views/widgets/inline_event_selector.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_offer_ride_view_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_view_model.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/core/widgets/rating_and_profile_widgets.dart';
import 'package:sport_connect/core/widgets/ride_feature_widgets.dart';
import 'package:sport_connect/core/animations/feedback_animations.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class DriverOfferRideScreen extends ConsumerStatefulWidget {
  final RideModel? existingRide;

  /// When provided the screen fetches the ride by ID so the edit route
  /// works correctly even after a hot-restart or deep-link (no state.extra).
  final String? existingRideId;
  final bool isEditMode;

  const DriverOfferRideScreen({
    super.key,
    this.existingRide,
    this.existingRideId,
    this.isEditMode = false,
  });

  @override
  ConsumerState<DriverOfferRideScreen> createState() =>
      _DriverOfferRideScreenState();
}

class _DriverOfferRideScreenState extends ConsumerState<DriverOfferRideScreen> {
  // Page controller (widget-local only)
  late PageController _pageController;
  final MapController _mapController = MapController();

  // Shorthand accessor for form state
  DriverOfferRideFormState get _formState =>
      ref.watch(driverOfferRideViewModelProvider);

  // Computed accessors for readability
  int get _currentStep => _formState.currentStep;
  LocationPoint? get _fromLocation => _formState.fromLocation;
  String get _fromAddress => _formState.fromAddress;
  LocationPoint? get _toLocation => _formState.toLocation;
  String get _toAddress => _formState.toAddress;
  DateTime? get _departureDate => _formState.departureDate;
  TimeOfDay? get _departureTime => _formState.departureTime;
  List<LocationPoint> get _waypoints => _formState.waypoints;
  int get _availableSeats => _formState.availableSeats;
  double get _pricePerSeat => _formState.pricePerSeat;
  bool get _isRecurring => _formState.isRecurring;
  List<int> get _recurringDays => _formState.recurringDays;
  bool get _allowPets => _formState.allowPets;
  bool get _allowSmoking => _formState.allowSmoking;
  bool get _allowLuggage => _formState.allowLuggage;
  bool get _isWomenOnly => _formState.isWomenOnly;
  int? get _maxDetourMinutes => _formState.maxDetourMinutes;
  EventModel? get _selectedEvent => _formState.selectedEvent;
  List<LatLng>? get _osrmRoutePoints => _formState.osrmRoutePoints;
  bool get _isLoadingOsrmRoute => _formState.isLoadingRoute;
  LocationPoint? get _lastFromForRoute => null; // Removed from state
  LocationPoint? get _lastToForRoute => null; // Removed from state

  VehicleModel? _selectedVehicle(List<VehicleModel> vehicles) {
    final id = _formState.selectedVehicleId;
    if (id == null) return null;
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.existingRide != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(driverOfferRideViewModelProvider.notifier)
            .initializeFromExistingRide(widget.existingRide!);
        if (widget.existingRide!.eventId != null) {
          ref
              .read(driverOfferRideViewModelProvider.notifier)
              .loadSelectedEvent(widget.existingRide!.eventId!);
        }
      });
    } else if (widget.existingRideId != null) {
      // Route-based edit: fetch ride from Firestore
      Future.microtask(() async {
        final ride = await ref
            .read(rideActionsViewModelProvider)
            .getRideById(widget.existingRideId!);
        if (ride != null && mounted) {
          ref
              .read(driverOfferRideViewModelProvider.notifier)
              .initializeFromExistingRide(ride);
          if (ride.eventId != null) {
            ref
                .read(driverOfferRideViewModelProvider.notifier)
                .loadSelectedEvent(ride.eventId!);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final vehiclesAsync = ref.watch(vehicleViewModelProvider).vehicles;

    // Listen for submission errors to show feedback
    ref.listen(
      driverOfferRideViewModelProvider.select((s) => s.osrmRoutePoints),
      (previous, next) {
        if (next != null && next != previous) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final allPoints = [
              LatLng(_fromLocation!.latitude, _fromLocation!.longitude),
              ..._waypoints.map((w) => LatLng(w.latitude, w.longitude)),
              LatLng(_toLocation!.latitude, _toLocation!.longitude),
            ];
            final bounds = LatLngBounds.fromPoints(allPoints);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(48),
              ),
            );
          });
        }
      },
    );

    // Auto-select vehicle when vehicles load if none selected
    if (_formState.selectedVehicleId == null) {
      vehiclesAsync.whenData((vehicles) {
        if (vehicles.isNotEmpty && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final vehicleId =
                _formState.existingRideId != null &&
                    widget.existingRide?.vehicleId != null
                ? widget.existingRide!.vehicleId
                : vehicles
                      .firstWhere(
                        (v) => v.isDefault,
                        orElse: () => vehicles.first,
                      )
                      .id;
            if (vehicleId != null) {
              ref
                  .read(driverOfferRideViewModelProvider.notifier)
                  .setVehicle(vehicleId);
            }
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: userAsync.when(
        data: (user) {
          if (user == null || user is! DriverModel) {
            return _buildNotDriverState(context);
          }

          return vehiclesAsync.when(
            data: (vehicles) => _buildMainContent(context, vehicles),
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (err, stack) => _buildErrorState(context, err.toString()),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => _buildErrorState(context, err.toString()),
      ),
    );
  }

  Widget _buildNotDriverState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context).goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.drive_eta_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context).driverProfileRequired,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context).completeDriverProfileMessage,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              FilledButton(
                onPressed: () => context.push(AppRoutes.profile.path),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 14.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(AppLocalizations.of(context).becomeDriverButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context).goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).errorLoadingData,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, List<VehicleModel> vehicles) {
    return Column(
      children: [
        _buildSliverHeader(context),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              ref
                  .read(driverOfferRideViewModelProvider.notifier)
                  .setStep(index);
            },
            children: [
              _buildRouteStep(),
              _buildDetailsStep(vehicles),
              _buildPreferencesStep(vehicles),
            ],
          ),
        ),
        _buildBottomBar(vehicles),
      ],
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, topPad + 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context).backButton,
                icon: Icon(Icons.adaptive.arrow_back_rounded, size: 20),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.isEditMode
                    ? AppLocalizations.of(context).editRideTitle
                    : AppLocalizations.of(context).offerARideTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _buildStepItem(0, l10n.routeStep),
        _buildStepConnector(0),
        _buildStepItem(1, l10n.detailsStep),
        _buildStepConnector(1),
        _buildStepItem(2, l10n.preferencesStep),
      ],
    );
  }

  Widget _buildStepItem(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 22.h),
        color: _currentStep > step ? AppColors.primary : AppColors.border,
      ),
    );
  }

  // --- Step 1: Route ---
  Widget _buildRouteStep() {
    // Route preview is auto-triggered by view model when locations change

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          AppLocalizations.of(context).whereAreYouGoing,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildRouteCard(),

        // Keep this slot stable to avoid remounting sibling widgets and
        // replaying entrance animations when destination is cleared/restored.
        AnimatedSwitcher(
          duration: 220.ms,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _fromLocation != null && _toLocation != null
              ? Column(
                  key: const ValueKey('route-preview-visible'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 14.h),
                    _buildRoutePreview(),
                    SizedBox(height: 14.h),
                  ],
                )
              : SizedBox(
                  key: const ValueKey('route-preview-hidden'),
                  height: 14.h,
                ),
        ),

        _buildWaypointsSection(),
        SizedBox(height: 20.h),
        InlineEventSelector(
          selected: _selectedEvent,
          onChanged: (e) {
            if (e == null) {
              ref.read(driverOfferRideViewModelProvider.notifier).clearEvent();
            } else {
              ref.read(driverOfferRideViewModelProvider.notifier).setEvent(e);
            }
          },
        ),
        SizedBox(height: 20.h),
        _buildDateTimeCard(),
        SizedBox(height: 20.h),
        _buildRecurringDaysSelector(),
      ],
    );
  }

  Widget _buildDestinationOverlay() {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        color: AppColors.surface,
      ),
      child: Stack(
        children: [
          // Blurred/faded map hint using color
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.04),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
          // Centered CTA
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  AppLocalizations.of(context).selectDestinationTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(context).selectDropoffLocation,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton.icon(
                  onPressed: () => _selectLocation(isFrom: false),
                  icon: Icon(Icons.add_location_alt_rounded, size: 16.sp),
                  label: Text(
                    AppLocalizations.of(context).toLabel,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
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
          _buildLocationTile(
            title: AppLocalizations.of(context).fromLabel,
            value: _fromAddress,
            location: _fromLocation,
            placeholder: AppLocalizations.of(context).selectPickupLocation,
            icon: Icons.my_location_rounded,
            color: AppColors.primary,
            onTap: () => _selectLocation(isFrom: true),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  height: 36.h,
                  width: 2,
                  margin: EdgeInsets.only(left: 10.w),
                  color: AppColors.border,
                ),
                const Spacer(),
                SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context).swapLocationsTooltip,
                    onPressed: _swapLocations,
                    icon: Icon(Icons.swap_vert_rounded, size: 20.sp),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primarySurface,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLocationTile(
            title: AppLocalizations.of(context).toLabel,
            value: _toAddress,
            location: _toLocation,
            placeholder: AppLocalizations.of(context).selectDropoffLocation,
            icon: Icons.location_on_rounded,
            color: AppColors.secondary,
            onTap: () => _selectLocation(isFrom: false),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRoutePreview() {
    final origin = LatLng(_fromLocation!.latitude, _fromLocation!.longitude);
    final dest = LatLng(_toLocation!.latitude, _toLocation!.longitude);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    final routePoints = _osrmRoutePoints ?? [origin, dest];

    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),

              onMapReady: () {
                final allPoints = [
                  origin,
                  ..._waypoints.map((w) => LatLng(w.latitude, w.longitude)),
                  dest,
                ];
                final bounds = LatLngBounds.fromPoints(allPoints);
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(48),
                  ),
                );
              },
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
                    strokeWidth: 6.0,
                    color: Colors.white,
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.white,
                  ),
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.primary,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: origin,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.primary,
                      size: 22.sp,
                    ),
                  ),
                  ..._waypoints.map(
                    (wp) => Marker(
                      point: LatLng(wp.latitude, wp.longitude),
                      width: 24.w,
                      height: 24.w,
                      child: Icon(
                        Icons.circle,
                        color: AppColors.warning,
                        size: 14.sp,
                      ),
                    ),
                  ),
                  Marker(
                    point: dest,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoadingOsrmRoute)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildLocationTile({
    required String title,
    required String value,
    LocationPoint? location,
    required String placeholder,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value.isNotEmpty ? value : placeholder,
                    style: TextStyle(
                      color: value.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).departureTimeLabel,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeInput(
                  label: AppLocalizations.of(context).dateLabel,
                  value: _departureDate != null
                      ? DateFormat('dd/MM/yyyy').format(_departureDate!)
                      : AppLocalizations.of(context).selectDatePlaceholder,
                  icon: Icons.calendar_today_rounded,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInput(
                  label: AppLocalizations.of(context).timeLabel,
                  value:
                      _departureTime?.format(context) ??
                      AppLocalizations.of(context).selectTimePlaceholder,
                  icon: Icons.access_time_rounded,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimeInput({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14.sp, color: AppColors.textSecondary),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringDaysSelector() {
    final l10n = AppLocalizations.of(context);
    final dayLabels = [
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
      l10n.daySun,
    ];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat_rounded, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                l10n.recurringRideTitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Switch.adaptive(
                value: _isRecurring,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  ref
                      .read(driverOfferRideViewModelProvider.notifier)
                      .setRecurring(v);
                },
              ),
            ],
          ),
          if (_isRecurring) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List.generate(7, (i) {
                final dayNum = i + 1; // 1=Mon .. 7=Sun
                final selected = _recurringDays.contains(dayNum);
                return GestureDetector(
                  onTap: () {
                    final updated = List<int>.from(_recurringDays);
                    if (selected) {
                      updated.remove(dayNum);
                    } else {
                      updated.add(dayNum);
                    }
                    ref
                        .read(driverOfferRideViewModelProvider.notifier)
                        .setRecurringDays(updated);
                  },
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_recurringDays.isNotEmpty) ...[
              SizedBox(height: 16.h),
              // Recurring end date picker
              GestureDetector(
                onTap: () async {
                  final baseDate = _departureDate ?? DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _formState.recurringEndDate ??
                        baseDate.add(const Duration(days: 28)),
                    firstDate: baseDate.add(const Duration(days: 1)),
                    lastDate: baseDate.add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: AppColors.cardBg,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    ref
                        .read(driverOfferRideViewModelProvider.notifier)
                        .setRecurringEndDate(picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formState.recurringEndDate != null
                            ? 'Ends ${DateFormat('MMM d, yyyy').format(_formState.recurringEndDate!)}'
                            : 'Set end date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _formState.recurringEndDate != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0);
  }

  // --- Waypoints ---
  Widget _buildWaypointsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).intermediateStopsLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_waypoints.length < 5)
                TextButton.icon(
                  onPressed: _addWaypoint,
                  icon: Icon(Icons.add_circle_outline, size: 16.sp),
                  label: Text(
                    AppLocalizations.of(context).addStopButton,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                ),
            ],
          ),
          if (_waypoints.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Text(
                AppLocalizations.of(context).addStopsHint,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _waypoints.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final updated = List<LocationPoint>.from(_waypoints);
                final item = updated.removeAt(oldIndex);
                updated.insert(newIndex, item);
                ref
                    .read(driverOfferRideViewModelProvider.notifier)
                    .setWaypoints(updated);
              },
              itemBuilder: (context, index) {
                final wp = _waypoints[index];
                return _buildWaypointTile(wp, index);
              },
            ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildWaypointTile(LocationPoint wp, int index) {
    return Container(
      key: ValueKey('waypoint_$index'),
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            color: AppColors.textTertiary,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).stopNumberLabel(index + 1),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  wp.address.isNotEmpty
                      ? wp.address
                      : AppLocalizations.of(context).tapToSetLocation,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).editWaypointTooltip,
            onPressed: () => _editWaypoint(index),
            icon: Icon(Icons.edit_location_alt_rounded, size: 18.sp),
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).removeWaypointTooltip,
            onPressed: () => _removeWaypoint(index),
            icon: Icon(Icons.remove_circle_outline, size: 18.sp),
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
    );
  }

  Future<void> _addWaypoint() async {
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(
        context,
      ).selectStopTitle(_waypoints.length + 1),
    );
    if (result != null) {
      final waypoint = LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      );
      ref.read(driverOfferRideViewModelProvider.notifier).addWaypoint(waypoint);
    }
  }

  Future<void> _editWaypoint(int index) async {
    final wp = _waypoints[index];
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(context).editStopTitle(index + 1),
      initialLocation: LatLng(wp.latitude, wp.longitude),
    );
    if (result != null) {
      final updated = List<LocationPoint>.from(_waypoints);
      updated[index] = LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      );
      ref.read(driverOfferRideViewModelProvider.notifier).setWaypoints(updated);
    }
  }

  void _removeWaypoint(int index) {
    ref.read(driverOfferRideViewModelProvider.notifier).removeWaypoint(index);
  }

  // --- Step 2: Details ---
  Widget _buildDetailsStep(List<VehicleModel> vehicles) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          AppLocalizations.of(context).rideDetailsTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildVehicleSelector(vehicles),
        SizedBox(height: 20.h),
        _buildSeatsAndPriceWithVehicle(vehicles),
      ],
    );
  }

  Widget _buildVehicleSelector(List<VehicleModel> vehicles) {
    final selectedVehicle = _selectedVehicle(vehicles);
    if (vehicles.isEmpty) {
      return Card(
        color: AppColors.error.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(AppLocalizations.of(context).noVehiclesError),
              TextButton(
                onPressed: () => context.push(AppRoutes.driverVehicles.path),
                child: Text(AppLocalizations.of(context).addVehicleButton),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).vehicleLabel,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (vehicles.length > 1)
              GestureDetector(
                onTap: () => VehicleQuickSwitchSheet.show(
                  context,
                  vehicles: vehicles
                      .map(
                        (v) => VehicleOption(
                          id: v.id,
                          name: '${v.make} ${v.model}',
                          plate: v.licensePlate,
                        ),
                      )
                      .toList(),
                  currentVehicleId: selectedVehicle?.id,
                  onSelect: (id) {
                    ref
                        .read(driverOfferRideViewModelProvider.notifier)
                        .setVehicle(id);
                  },
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).quickSwitchButton,
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
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 112.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final isSelected = selectedVehicle?.id == vehicle.id;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(driverOfferRideViewModelProvider.notifier)
                      .setVehicle(vehicle.id);
                },
                child: Container(
                  width: 150.w,
                  margin: EdgeInsets.only(right: 10.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySurface
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getVehicleIcon(vehicle.type),
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 22.sp,
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        vehicle.color,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          vehicle.licensePlate,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.motorcycle:
      case VehicleType.bicycle:
        return Icons.two_wheeler;
      case VehicleType.van:
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.car:
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildSeatsAndPriceWithVehicle(List<VehicleModel> vehicles) {
    final l10n = AppLocalizations.of(context);
    final selectedVehicle = _selectedVehicle(vehicles);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
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
          _buildSeatCounter(selectedVehicle),
          Divider(height: 28.h, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pricePerSeatLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _pricePerSeat < 1
                        ? l10n.minimumPriceError
                        : l10n.totalPriceForSeats(
                            (_pricePerSeat * _availableSeats).toStringAsFixed(
                              0,
                            ),
                            _availableSeats,
                          ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _pricePerSeat < 1
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontWeight: _pricePerSeat < 1
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _pricePerSeat < 1
                        ? AppColors.error
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.decreasePriceTooltip,
                      onPressed: _pricePerSeat > 1
                          ? () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(
                                    driverOfferRideViewModelProvider.notifier,
                                  )
                                  .setPrice(_pricePerSeat - 1);
                            }
                          : null,
                      icon: Icon(Icons.remove, size: 18.sp),
                    ),
                    SizedBox(
                      width: 50.w,
                      child: Text(
                        '\$${_pricePerSeat.toInt()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17.sp,
                          color: _pricePerSeat < 1
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.increasePriceTooltip,
                      onPressed: _pricePerSeat < 999
                          ? () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(
                                    driverOfferRideViewModelProvider.notifier,
                                  )
                                  .setPrice(_pricePerSeat + 1);
                            }
                          : null,
                      icon: Icon(Icons.add, size: 18.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSeatCounter(VehicleModel? selectedVehicle) {
    final l10n = AppLocalizations.of(context);
    final maxSeats = selectedVehicle?.capacity ?? 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          l10n.availableSeatsLabel,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          l10n.totalCapacityCount(maxSeats),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (int i = 1; i <= maxSeats; i++)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(driverOfferRideViewModelProvider.notifier)
                        .setSeats(i);
                  },
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    margin: EdgeInsets.only(left: i == 1 ? 0 : 6.w),
                    decoration: BoxDecoration(
                      color: i <= _availableSeats
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i <= _availableSeats
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: i <= _availableSeats
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Step 3: Preferences ---
  Widget _buildPreferencesStep(List<VehicleModel> vehicles) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          AppLocalizations.of(context).preferencesRulesTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildRideSummaryCard(vehicles),
        SizedBox(height: 16.h),
        _buildPreferencesCard(),
        SizedBox(height: 16.h),
        _buildMaxDetourSlider(),
      ],
    );
  }

  /// Ride summary card showing all key details before creation
  Widget _buildRideSummaryCard(List<VehicleModel> vehicles) {
    final l10n = AppLocalizations.of(context);
    final selectedVehicle = _selectedVehicle(vehicles);
    final departure = (_departureDate != null && _departureTime != null)
        ? DateTime(
            _departureDate!.year,
            _departureDate!.month,
            _departureDate!.day,
            _departureTime!.hour,
            _departureTime!.minute,
          )
        : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.rideSummaryLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildSummaryRow(
            Icons.my_location_rounded,
            l10n.fromLabel,
            _fromAddress.isNotEmpty ? _fromAddress : l10n.notSetPlaceholder,
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            Icons.location_on_rounded,
            l10n.toLabel,
            _toAddress.isNotEmpty ? _toAddress : l10n.notSetPlaceholder,
          ),
          if (_waypoints.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              Icons.route_rounded,
              l10n.summaryStopsLabel,
              l10n.intermediateStopsCount(_waypoints.length),
            ),
          ],
          SizedBox(height: 8.h),
          _buildSummaryRow(
            Icons.schedule_rounded,
            l10n.departureSummaryLabel,
            departure != null
                ? DateFormat('EEE, MMM d \u2022 HH:mm').format(departure)
                : l10n.notSetPlaceholder,
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            Icons.directions_car_rounded,
            l10n.vehicleLabel,
            selectedVehicle != null
                ? '${selectedVehicle.make} ${selectedVehicle.model}'
                : l10n.notSelectedPlaceholder,
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            Icons.event_seat_rounded,
            l10n.seatsSummaryLabel,
            l10n.seatsAvailableCount(_availableSeats),
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            Icons.attach_money_rounded,
            l10n.priceSummaryLabel,
            l10n.pricePerSeatSummary('\$${_pricePerSeat.toInt()}'),
          ),
          if (_selectedEvent != null) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              Icons.event_rounded,
              l10n.eventSummaryLabel,
              _selectedEvent!.title,
            ),
          ],
          if (_isRecurring && _recurringDays.isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              Icons.repeat_rounded,
              l10n.recurringSummaryLabel,
              _recurringDays
                  .map(
                    (d) => [
                      l10n.dayMon,
                      l10n.dayTue,
                      l10n.dayWed,
                      l10n.dayThu,
                      l10n.dayFri,
                      l10n.daySat,
                      l10n.daySun,
                    ][d - 1],
                  )
                  .join(', '),
            ),
            if (_formState.recurringEndDate != null) ...[
              SizedBox(height: 8.h),
              _buildSummaryRow(
                Icons.event_rounded,
                'Ends',
                DateFormat('MMM d, yyyy').format(_formState.recurringEndDate!),
              ),
            ],
          ],
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Max detour slider for how far drivers will deviate for pickups
  Widget _buildMaxDetourSlider() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.maxDetourLabel,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _maxDetourMinutes != null
                      ? l10n.maxDetourMinutesValue(_maxDetourMinutes!)
                      : l10n.noneLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.maxDetourHint,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Slider.adaptive(
            value: (_maxDetourMinutes ?? 0).toDouble(),
            min: 0,
            max: 60,
            divisions: 12,
            label: _maxDetourMinutes != null
                ? l10n.maxDetourMinutesValue(_maxDetourMinutes!)
                : l10n.noneLabel,
            activeColor: AppColors.primary,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              ref
                  .read(driverOfferRideViewModelProvider.notifier)
                  .setMaxDetourMinutes(val.toInt() == 0 ? null : val.toInt());
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.noneLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                l10n.sixtyMinLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
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
          _buildPreferenceSwitch(
            title: AppLocalizations.of(context).allowPetsToggle,
            subtitle: AppLocalizations.of(context).allowPetsSubtitle,
            icon: Icons.pets_rounded,
            value: _allowPets,
            onChanged: (val) => ref
                .read(driverOfferRideViewModelProvider.notifier)
                .setAllowPets(val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: AppLocalizations.of(context).allowSmokingToggle,
            subtitle: AppLocalizations.of(context).allowSmokingSubtitle,
            icon: Icons.smoke_free_rounded,
            value: _allowSmoking,
            onChanged: (val) => ref
                .read(driverOfferRideViewModelProvider.notifier)
                .setAllowSmoking(val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: AppLocalizations.of(context).allowLuggageToggle,
            subtitle: AppLocalizations.of(context).allowLuggageSubtitle,
            icon: Icons.luggage_rounded,
            value: _allowLuggage,
            onChanged: (val) => ref
                .read(driverOfferRideViewModelProvider.notifier)
                .setAllowLuggage(val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: AppLocalizations.of(context).womenOnlyToggle,
            subtitle: AppLocalizations.of(context).womenOnlySubtitle,
            icon: Icons.female_rounded,
            value: _isWomenOnly,
            onChanged: (val) => ref
                .read(driverOfferRideViewModelProvider.notifier)
                .setWomenOnly(val),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: 28.w),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _buildBottomBar(List<VehicleModel> vehicles) {
    final isLastStep = _currentStep == 2;
    final blockReason = isLastStep && !_formState.canSubmit
        ? _formState.submissionBlockReason
        : null;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blockReason != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14.sp,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        blockReason,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 14.w),
                      child: OutlinedButton(
                        onPressed: _goToPreviousStep,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).backButton,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isLastStep
                        ? (_formState.canSubmit && !_formState.isSubmitting
                              ? () => _createRide(vehicles)
                              : null)
                        : (_canGoNext(vehicles) ? _goToNextStep : null),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.4,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _formState.isSubmitting
                        ? SizedBox(
                            height: 18.w,
                            width: 18.w,
                            child: const CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isLastStep
                                ? AppLocalizations.of(context).createRideButton
                                : AppLocalizations.of(context).nextButton,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Actions ---
  bool _canGoNext(List<VehicleModel> vehicles) {
    final selectedVehicle = _selectedVehicle(vehicles);
    if (_currentStep == 0) {
      if (_fromLocation == null ||
          _toLocation == null ||
          _departureDate == null ||
          _departureTime == null) {
        return false;
      }
      final departure = DateTime(
        _departureDate!.year,
        _departureDate!.month,
        _departureDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );
      if (departure.isBefore(DateTime.now())) return false;
      if (_selectedEvent?.endsAt != null &&
          departure.isAfter(_selectedEvent!.endsAt!)) {
        return false;
      }
      return true;
    }
    if (_currentStep == 1) {
      return selectedVehicle != null;
    }
    return true;
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  Future<void> _selectLocation({required bool isFrom}) async {
    final result = await MapLocationPicker.show(
      context,
      title: isFrom
          ? AppLocalizations.of(context).selectOriginTitle
          : AppLocalizations.of(context).selectDestinationTitle,
      initialLocation: isFrom
          ? (_fromLocation != null
                ? LatLng(_fromLocation!.latitude, _fromLocation!.longitude)
                : null)
          : (_toLocation != null
                ? LatLng(_toLocation!.latitude, _toLocation!.longitude)
                : null),
    );

    if (result != null) {
      final location = LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      );
      if (isFrom) {
        ref
            .read(driverOfferRideViewModelProvider.notifier)
            .setFromLocation(location, result.address);
      } else {
        ref
            .read(driverOfferRideViewModelProvider.notifier)
            .setToLocation(location, result.address);
      }
    }
  }

  void _swapLocations() {
    ref.read(driverOfferRideViewModelProvider.notifier).swapLocations();
  }

  void _selectDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventEnd = _selectedEvent?.endsAt;
    final lastDate = eventEnd != null
        ? (eventEnd.isBefore(now.add(const Duration(days: 90)))
              ? eventEnd
              : now.add(const Duration(days: 90)))
        : now.add(const Duration(days: 90));
    final rawInitial = _departureDate ?? now;
    final initial = rawInitial.isBefore(today) ? today : rawInitial;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: lastDate,
    );

    if (result != null) {
      ref
          .read(driverOfferRideViewModelProvider.notifier)
          .setDepartureDate(result);
    }
  }

  void _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );

    if (result != null) {
      ref
          .read(driverOfferRideViewModelProvider.notifier)
          .setDepartureTime(result);
      if (_departureDate != null) {
        final selected = DateTime(
          _departureDate!.year,
          _departureDate!.month,
          _departureDate!.day,
          result.hour,
          result.minute,
        );
        if (!mounted) return;
        if (selected.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).timeInPastWarning),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (selected.difference(DateTime.now()).inMinutes < 15) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).departureMinimumWarning,
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (_selectedEvent?.endsAt != null &&
            selected.isAfter(_selectedEvent!.endsAt!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).departureAfterEventWarning,
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _createRide(List<VehicleModel> vehicles) async {
    if (!_formState.canSubmit) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final rideId = await ref
        .read(driverOfferRideViewModelProvider.notifier)
        .submitRide(user.uid);

    if (rideId == null) return;

    if (mounted) {
      await FeedbackAnimations.showSuccess(
        context,
        message: widget.isEditMode
            ? AppLocalizations.of(context).rideUpdatedSuccess
            : AppLocalizations.of(context).rideCreatedSuccess,
      );
      if (!mounted) return;
      context.go(AppRoutes.driverRides.path);
    }
  }
}
