import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
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
import 'package:uuid/uuid.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/views/event_picker_sheet.dart';

class DriverOfferRideScreen extends ConsumerStatefulWidget {
  final RideModel? existingRide;
  final bool isEditMode;

  const DriverOfferRideScreen({
    super.key,
    this.existingRide,
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
  final bool _isRecurring = false;
  final List<int> _recurringDays = [];

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.existingRide != null) {
      _initFromPrefill(widget.existingRide!);
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
  }

  /// Initialize vehicle selection based on available vehicles and prefill data
  void _initVehicleFrom(List<VehicleModel> vehicles) {
    if (vehicles.isEmpty) return;

    if (widget.existingRide?.vehicleId != null) {
      try {
        _selectedVehicle = vehicles.firstWhere(
          (v) => v.id == widget.existingRide!.vehicleId,
        );
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

  bool get _canCreateRide {
    if (_fromLocation == null ||
        _toLocation == null ||
        _departureDate == null ||
        _departureTime == null ||
        _selectedVehicle == null ||
        _isCreating) {
      return false;
    }

    // Ensure the departure is in the future
    final departureDateTime = DateTime(
      _departureDate!.year,
      _departureDate!.month,
      _departureDate!.day,
      _departureTime!.hour,
      _departureTime!.minute,
    );
    if (departureDateTime.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Ride' : 'Offer a Ride'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null || user is! DriverModel) {
              return _buildNotDriverState(context);
            }

            // Watch vehicles for this driver
            final vehiclesAsync = ref.watch(driverVehiclesProvider(user.uid));

            return vehiclesAsync.when(
              data: (vehicles) {
                // Initialize vehicle selection now that we have the list
                if (_selectedVehicle == null && vehicles.isNotEmpty) {
                  // Schedule initialization
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
      ),
    );
  }

  Widget _buildNotDriverState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drive_eta_rounded,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Driver Profile Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your driver profile to offer rides.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              // Navigate to driver verification or profile edit
              context.push(AppRoutes.profile.path);
            },
            child: const Text('Become a Driver'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, List<VehicleModel> vehicles) {
    return Column(
      children: [
        _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(children: [_buildStepIndicator()]),
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
            width: 32,
            height: 32,
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
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isCurrent
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
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
        color: _currentStep > step ? AppColors.primary : AppColors.border,
      ),
    );
  }

  // --- Step 1: Route ---
  Widget _buildRouteStep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Where are you going?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 24),
        _buildRouteCard(),
        const SizedBox(height: 16),
        _buildWaypointsSection(),
        const SizedBox(height: 24),
        _buildEventAttachmentCard(),
        const SizedBox(height: 24),
        _buildDateTimeCard(),
        const SizedBox(height: 24),
        _buildRecurringDaysSelector(),
      ],
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationTile(
            title: 'From',
            value: _fromAddress,
            location: _fromLocation, // Provide the actual location point
            placeholder: 'Select pickup location',
            icon: Icons.my_location_rounded,
            color: AppColors.primary,
            onTap: () => _selectLocation(isFrom: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 2,
                  margin: const EdgeInsets.only(left: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Swap locations',
                  onPressed: _swapLocations,
                  icon: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          _buildLocationTile(
            title: 'To',
            value: _toAddress,
            location: _toLocation, // Provide the actual location point
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
    LocationPoint? location, // Added location parameter
    required String placeholder,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : placeholder,
                    style: TextStyle(
                      color: value.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Departure Time',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInput(
                  label: 'Date',
                  value: _departureDate != null
                      ? '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringDaysSelector() {
    // Implement recurring days selector if needed
    // For now, this can be simple or empty if not implemented
    return const SizedBox.shrink();
  }

  // --- Waypoints ---
  Widget _buildWaypointsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Intermediate Stops',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_waypoints.length < 5)
                TextButton.icon(
                  onPressed: _addWaypoint,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Stop'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (_waypoints.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Add stops along your route to pick up more passengers',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stop ${index + 1}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  wp.address.isNotEmpty ? wp.address : 'Tap to set location',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
            icon: const Icon(Icons.edit_location_alt_rounded, size: 20),
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
          IconButton(
            tooltip: 'Remove waypoint',
            onPressed: () => _removeWaypoint(index),
            icon: const Icon(Icons.remove_circle_outline, size: 20),
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

  // --- Event attachment card ---
  Widget _buildEventAttachmentCard() {
    return GestureDetector(
      onTap: () async {
        final picked = await EventPickerSheet.show(
          context,
          preselected: _selectedEvent,
        );
        if (picked != null && mounted) {
          setState(() => _selectedEvent = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedEvent != null
              ? _selectedEvent!.type.color.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedEvent != null
                ? _selectedEvent!.type.color
                : AppColors.border,
            width: _selectedEvent != null ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _selectedEvent != null
            ? _buildSelectedEventContent()
            : _buildNoEventContent(),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildNoEventContent() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.event_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Link to an Event',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Optional — attach this ride to a sport event',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Icon(
          Icons.add_circle_outline_rounded,
          color: AppColors.primary,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildSelectedEventContent() {
    final event = _selectedEvent!;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: event.type.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(event.type.icon, color: event.type.color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                event.venueName ?? event.location.address,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Clear event',
          onPressed: () => setState(() => _selectedEvent = null),
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textTertiary,
            size: 18,
          ),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // --- Step 2: Details ---
  Widget _buildDetailsStep(List<VehicleModel> vehicles) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Ride Details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 24),
        _buildVehicleSelector(vehicles),
        const SizedBox(height: 24),
        _buildSeatsAndPrice(),
      ],
    );
  }

  Widget _buildVehicleSelector(List<VehicleModel> vehicles) {
    if (vehicles.isEmpty) {
      return Card(
        color: AppColors.error.withOpacity(0.1),
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
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
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
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
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
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${vehicle.make} ${vehicle.model}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.color,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          vehicle.licensePlate,
                          style: const TextStyle(
                            fontSize: 10,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSeatCounter(),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price per Seat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
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
                      icon: const Icon(Icons.remove, size: 20),
                    ),
                    Text(
                      '\$${_pricePerSeat.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Increase price',
                      onPressed: () {
                        setState(() => _pricePerSeat += 1);
                      },
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Price Negotiable'),
            value: _isPriceNegotiable,
            onChanged: (val) => setState(() => _isPriceNegotiable = val),
            dense: false,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSeatCounter() {
    final maxSeats = _selectedVehicle?.capacity ?? 4; // Default to 4 if unknown

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Seats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Total Capacity: $maxSeats',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        Row(
          children: [
            for (int i = 1; i <= maxSeats; i++)
              GestureDetector(
                onTap: () => setState(() => _availableSeats = i),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: i <= _availableSeats
                        ? AppColors.primary
                        : AppColors.background,
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
                        fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Preferences & Rules',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 24),
        _buildPreferencesCard(),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isLastStep ? 'Create Ride' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Actions ---
  bool _canGoNext() {
    if (_currentStep == 0) {
      return _fromLocation != null &&
          _toLocation != null &&
          _departureDate != null &&
          _departureTime != null;
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
    final result = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
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
        id: widget.existingRide?.id ?? const Uuid().v4(),
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
        context.go(AppRoutes.driverMyRides.path);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        _showValidationError('Failed to create ride. Please try again.');
      }
    }
  }
}
