import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/events/views/widgets/inline_event_selector.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_pricing.dart';
import 'package:sport_connect/features/rides/models/ride/ride_capacity.dart';
import 'package:sport_connect/features/rides/models/ride/ride_schedule.dart';
import 'package:sport_connect/features/rides/models/ride/ride_preferences.dart';
import 'package:sport_connect/features/rides/models/ride/ride_route.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/core/models/value_objects/money.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_view_model.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';

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
  // Page controller
  late PageController _pageController;
  int _currentStep = 0;
  // final int _totalSteps = 3; // Unused

  // Step 1: Route
  LocationPoint? _fromLocation;
  String _fromAddress = '';
  LocationPoint? _toLocation;
  String _toAddress = '';
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  List<LocationPoint> _waypoints = [];

  // Step 2: Details
  VehicleModel? _selectedVehicle;
  int _availableSeats = 3;
  double _pricePerSeat = 15.0; // Default price
  bool _isPriceNegotiable = false;
  bool _acceptOnlinePayment = true;
  bool _isRecurring = false;
  List<int> _recurringDays = [];

  // Step 3: Preferences
  bool _allowPets = false;
  bool _allowSmoking = false;
  bool _allowLuggage = true;
  bool _isWomenOnly = false;
  int? _maxDetourMinutes = 15;
  // String? _notes; // Unused

  // Event attachment
  EventModel? _selectedEvent;

  // State
  bool _isCreating = false;

  /// Tracks the vehicleId from the prefilled ride (set by _initFromPrefill)
  /// so _initVehicleFrom can select the correct vehicle even when the ride
  /// was loaded asynchronously via existingRideId.
  String? _existingVehicleId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.existingRide != null) {
      _initFromPrefill(widget.existingRide!);
      if (widget.existingRide!.eventId != null) {
        Future.microtask(() async {
          final event = await ref
              .read(eventRepositoryProvider)
              .getEventById(widget.existingRide!.eventId!);
          if (event != null && mounted) setState(() => _selectedEvent = event);
        });
      }
    } else if (widget.existingRideId != null) {
      // Route-based edit: fetch ride from Firestore so deep-links work correctly.
      Future.microtask(() async {
        final ride = await ref
            .read(rideActionsViewModelProvider)
            .getRideById(widget.existingRideId!);
        if (ride != null && mounted) {
          setState(() => _initFromPrefill(ride));
          if (ride.eventId != null) {
            final event = await ref
                .read(eventRepositoryProvider)
                .getEventById(ride.eventId!);
            if (event != null && mounted)
              setState(() => _selectedEvent = event);
          }
        }
      });
    }
  }

  void _initFromPrefill(RideModel ride) {
    _fromLocation = ride.route.origin;
    _fromAddress = ride.route.origin.address;
    _toLocation = ride.route.destination;
    _toAddress = ride.route.destination.address;
    _departureDate = ride.schedule.departureTime;
    _departureTime = TimeOfDay.fromDateTime(ride.schedule.departureTime);

    // Vehicle will be initialized when vehicles are loaded

    _availableSeats = ride.capacity.available;
    _pricePerSeat = ride.pricing.pricePerSeat.amount;
    _isPriceNegotiable = ride.pricing.isNegotiable;
    _acceptOnlinePayment = ride.pricing.acceptsOnlinePayment;

    _allowPets = ride.preferences.allowPets;
    _allowSmoking = ride.preferences.allowSmoking;
    _allowLuggage = ride.preferences.allowLuggage;
    _isWomenOnly = ride.preferences.isWomenOnly;
    _maxDetourMinutes = ride.preferences.maxDetourMinutes;
    _waypoints = ride.route.waypoints.map((wp) => wp.location).toList();
    _existingVehicleId = ride.vehicleId;
  }

  /// Initialize vehicle selection based on available vehicles and prefill data
  void _initVehicleFrom(List<VehicleModel> vehicles) {
    if (vehicles.isEmpty) return;

    final vehicleId = _existingVehicleId ?? widget.existingRide?.vehicleId;
    if (vehicleId != null) {
      try {
        _selectedVehicle = vehicles.firstWhere((v) => v.id == vehicleId);
      } catch (_) {
        // Vehicle not found, select default
        _selectedVehicle = vehicles.firstWhere(
          (v) => v.isDefault,
          orElse: () => vehicles.first,
        );
      }
    } else {
      _selectedVehicle ??= vehicles.firstWhere(
        (v) => v.isDefault,
        orElse: () => vehicles.first,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canCreateRide => _createRideBlockReason == null && !_isCreating;

  String? get _createRideBlockReason {
    if (_fromLocation == null || _toLocation == null) {
      return 'Please set origin and destination in Step 1';
    }
    if (_departureDate == null || _departureTime == null) {
      return 'Please set a departure date and time in Step 1';
    }
    if (_selectedVehicle == null) {
      return 'Please select a vehicle in Step 2';
    }
    final departureDateTime = DateTime(
      _departureDate!.year,
      _departureDate!.month,
      _departureDate!.day,
      _departureTime!.hour,
      _departureTime!.minute,
    );
    if (departureDateTime.isBefore(DateTime.now())) {
      return 'Departure time must be in the future — go back to Step 1';
    }
    if (_selectedEvent?.endsAt != null &&
        departureDateTime.isAfter(_selectedEvent!.endsAt!)) {
      return 'Departure time cannot be after the event ends — go back to Step 1';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final vehiclesAsync = ref.watch(vehicleViewModelProvider).vehicles;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: userAsync.when(
        data: (user) {
          if (user == null || user is! DriverModel) {
            return _buildNotDriverState(context);
          }

          return vehiclesAsync.when(
            data: (vehicles) {
              if (_selectedVehicle == null && vehicles.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _initVehicleFrom(vehicles);
                    });
                  }
                });
              }
              return _buildMainContent(context, vehicles);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildErrorState(context, err.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                'Driver Profile Required',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Complete your driver profile to offer rides.',
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
                child: const Text('Become a Driver'),
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
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                'Error loading data',
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
              setState(() => _currentStep = index);
            },
            children: [
              _buildRouteStep(),
              _buildDetailsStep(vehicles),
              _buildPreferencesStep(),
            ],
          ),
        ),
        _buildBottomBar(),
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
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.isEditMode ? 'Edit Ride' : 'Offer a Ride',
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
    return Row(
      children: [
        _buildStepItem(0, 'Route'),
        _buildStepConnector(0),
        _buildStepItem(1, 'Details'),
        _buildStepConnector(1),
        _buildStepItem(2, 'Preferences'),
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
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          'Where are you going?',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildRouteCard(),
        SizedBox(height: 14.h),
        _buildWaypointsSection(),
        SizedBox(height: 20.h),
        InlineEventSelector(
          selected: _selectedEvent,
          onChanged: (e) => setState(() {
            _selectedEvent = e;
            if (e != null) {
              _toLocation = e.location;
              _toAddress = e.venueName ?? e.location.address;
            }
          }),
        ),
        SizedBox(height: 20.h),
        _buildDateTimeCard(),
        SizedBox(height: 20.h),
        _buildRecurringDaysSelector(),
      ],
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
            title: 'From',
            value: _fromAddress,
            location: _fromLocation,
            placeholder: 'Select pickup location',
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
                    tooltip: 'Swap locations',
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
            title: 'To',
            value: _toAddress,
            location: _toLocation,
            placeholder: 'Select dropoff location',
            icon: Icons.location_on_rounded,
            color: AppColors.secondary,
            onTap: () => _selectLocation(isFrom: false),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
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
            'Departure Time',
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
                  label: 'Date',
                  value: _departureDate != null
                      ? DateFormat('dd/MM/yyyy').format(_departureDate!)
                      : 'Select Date',
                  icon: Icons.calendar_today_rounded,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInput(
                  label: 'Time',
                  value: _departureTime?.format(context) ?? 'Select Time',
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
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                'Recurring Ride',
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
                onChanged: (v) => setState(() {
                  _isRecurring = v;
                  if (!v) _recurringDays = [];
                }),
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
                  onTap: () => setState(() {
                    if (selected) {
                      _recurringDays.remove(dayNum);
                    } else {
                      _recurringDays.add(dayNum);
                    }
                  }),
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
                'Intermediate Stops',
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
                    'Add Stop',
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
                'Add stops along your route to pick up more passengers',
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
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _waypoints.removeAt(oldIndex);
                  _waypoints.insert(newIndex, item);
                });
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
                  'Stop ${index + 1}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  wp.address.isNotEmpty ? wp.address : 'Tap to set location',
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
            tooltip: 'Edit waypoint',
            onPressed: () => _editWaypoint(index),
            icon: Icon(Icons.edit_location_alt_rounded, size: 18.sp),
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          IconButton(
            tooltip: 'Remove waypoint',
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
      title: 'Select Stop ${_waypoints.length + 1}',
    );
    if (result != null) {
      setState(() {
        _waypoints.add(
          LocationPoint(
            latitude: result.location.latitude,
            longitude: result.location.longitude,
            address: result.address,
          ),
        );
      });
    }
  }

  Future<void> _editWaypoint(int index) async {
    final wp = _waypoints[index];
    final result = await MapLocationPicker.show(
      context,
      title: 'Edit Stop ${index + 1}',
      initialLocation: LatLng(wp.latitude, wp.longitude),
    );
    if (result != null) {
      setState(() {
        _waypoints[index] = LocationPoint(
          latitude: result.location.latitude,
          longitude: result.location.longitude,
          address: result.address,
        );
      });
    }
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypoints.removeAt(index);
    });
  }

  // --- Step 2: Details ---
  Widget _buildDetailsStep(List<VehicleModel> vehicles) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          'Ride Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildVehicleSelector(vehicles),
        SizedBox(height: 20.h),
        _buildSeatsAndPrice(),
      ],
    );
  }

  Widget _buildVehicleSelector(List<VehicleModel> vehicles) {
    if (vehicles.isEmpty) {
      return Card(
        color: AppColors.error.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "No vehicles found. Please add a vehicle to your profile.",
              ),
              TextButton(onPressed: () {}, child: const Text("Add Vehicle")),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 112.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final isSelected = _selectedVehicle?.id == vehicle.id;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedVehicle = vehicle);
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

  Widget _buildSeatsAndPrice() {
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
          _buildSeatCounter(),
          Divider(height: 28.h, color: AppColors.borderLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per Seat',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Decrease price',
                      onPressed: () {
                        if (_pricePerSeat > 0) {
                          setState(() => _pricePerSeat -= 1);
                        }
                      },
                      icon: Icon(Icons.remove, size: 18.sp),
                    ),
                    Text(
                      '\$${_pricePerSeat.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Increase price',
                      onPressed: () => setState(() => _pricePerSeat += 1),
                      icon: Icon(Icons.add, size: 18.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          SwitchListTile(
            title: Text(
              'Price Negotiable',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            value: _isPriceNegotiable,
            onChanged: (val) => setState(() => _isPriceNegotiable = val),
            activeColor: AppColors.primary,
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSeatCounter() {
    final maxSeats = _selectedVehicle?.capacity ?? 4;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Seats',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Total Capacity: $maxSeats',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            for (int i = 1; i <= maxSeats; i++)
              GestureDetector(
                onTap: () => setState(() => _availableSeats = i),
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  margin: EdgeInsets.only(left: 6.w),
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
      ],
    );
  }

  // --- Step 3: Preferences ---
  Widget _buildPreferencesStep() {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      children: [
        Text(
          'Preferences & Rules',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideX(),
        SizedBox(height: 20.h),
        _buildPreferencesCard(),
      ],
    );
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
            title: 'Allow Pets',
            subtitle: 'Pets are allowed in the car',
            icon: Icons.pets_rounded,
            value: _allowPets,
            onChanged: (val) => setState(() => _allowPets = val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: 'Allow Smoking',
            subtitle: 'Smoking is allowed during the ride',
            icon: Icons.smoke_free_rounded,
            value: _allowSmoking,
            onChanged: (val) => setState(() => _allowSmoking = val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: 'Allow Luggage',
            subtitle: 'Passengers can bring luggage',
            icon: Icons.luggage_rounded,
            value: _allowLuggage,
            onChanged: (val) => setState(() => _allowLuggage = val),
          ),
          const Divider(),
          _buildPreferenceSwitch(
            title: 'Women Only',
            subtitle: 'Ride is for women only',
            icon: Icons.female_rounded,
            value: _isWomenOnly,
            onChanged: (val) => setState(() => _isWomenOnly = val),
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
    return SwitchListTile(
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

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 2;
    final blockReason = isLastStep && !_canCreateRide
        ? _createRideBlockReason
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
                          'Back',
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
                        ? (_canCreateRide ? _createRide : null)
                        : (_canGoNext() ? _goToNextStep : null),
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
                    child: _isCreating
                        ? SizedBox(
                            height: 18.w,
                            width: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLastStep ? 'Create Ride' : 'Next',
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
  bool _canGoNext() {
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
      return _selectedVehicle != null;
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
      title: isFrom ? 'Select Origin' : 'Select Destination',
      initialLocation: isFrom
          ? (_fromLocation != null
                ? LatLng(_fromLocation!.latitude, _fromLocation!.longitude)
                : null)
          : (_toLocation != null
                ? LatLng(_toLocation!.latitude, _toLocation!.longitude)
                : null),
    );

    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromLocation = LocationPoint(
            latitude: result.location.latitude,
            longitude: result.location.longitude,
            address: result.address,
          );
          _fromAddress = result.address;
        } else {
          _toLocation = LocationPoint(
            latitude: result.location.latitude,
            longitude: result.location.longitude,
            address: result.address,
          );
          _toAddress = result.address;
        }
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final tempLoc = _fromLocation;
      final tempAddr = _fromAddress;
      _fromLocation = _toLocation;
      _fromAddress = _toAddress;
      _toLocation = tempLoc;
      _toAddress = tempAddr;
    });
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
      setState(() => _departureDate = result);
    }
  }

  void _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );

    if (result != null) {
      setState(() => _departureTime = result);
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
              content: const Text(
                'Selected time is in the past — the Create Ride button will be disabled',
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (_selectedEvent?.endsAt != null &&
            selected.isAfter(_selectedEvent!.endsAt!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Departure time is after the event ends — please choose an earlier time',
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createRide() async {
    if (!_canCreateRide) return;

    setState(() => _isCreating = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final departureDateTime = DateTime(
        _departureDate!.year,
        _departureDate!.month,
        _departureDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );

      final ride = RideModel(
        id:
            widget.existingRide?.id ??
            widget.existingRideId ??
            const Uuid().v4(),
        driverId: ref.read(currentUserProvider).value!.uid,
        route: RideRoute(
          origin: LocationPoint(
            address: _fromAddress,
            latitude: _fromLocation!.latitude,
            longitude: _fromLocation!.longitude,
          ),
          destination: LocationPoint(
            address: _toAddress,
            latitude: _toLocation!.latitude,
            longitude: _toLocation!.longitude,
          ),
          waypoints: _waypoints
              .asMap()
              .entries
              .map((e) => RouteWaypoint(location: e.value, order: e.key))
              .toList(),
        ),
        schedule: RideSchedule(
          departureTime: departureDateTime,
          isRecurring: _isRecurring,
          recurringDays: _recurringDays,
        ),
        capacity: RideCapacity(available: _availableSeats, booked: 0),
        pricing: RidePricing(
          pricePerSeat: Money(amount: _pricePerSeat, currency: 'USD'),
          isNegotiable: _isPriceNegotiable,
          acceptsOnlinePayment: _acceptOnlinePayment,
        ),
        preferences: RidePreferences(
          allowPets: _allowPets,
          allowSmoking: _allowSmoking,
          allowLuggage: _allowLuggage,
          isWomenOnly: _isWomenOnly,
          maxDetourMinutes: _maxDetourMinutes,
        ),

        // Event link
        eventId: _selectedEvent?.id,
        eventName: _selectedEvent?.title,

        status: RideStatus.active,
        createdAt: DateTime.now(),

        // Vehicle details
        vehicleId: _selectedVehicle?.id,
        vehicleInfo: _selectedVehicle != null
            ? '${_selectedVehicle!.make} ${_selectedVehicle!.model} (${_selectedVehicle!.color})'
            : null,
      );

      await ref.read(rideActionsViewModelProvider).createRide(ride);

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ride created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate
        context.go(AppRoutes.driverRides.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        _showValidationError('Failed to create ride. Please try again.');
      }
    }
  }
}
