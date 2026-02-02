import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

/// Driver's screen to offer/create a ride
/// Modern UI with automatic vehicle selection and seat count from driver's vehicles
class DriverOfferRideScreen extends ConsumerStatefulWidget {
  const DriverOfferRideScreen({super.key});

  @override
  ConsumerState<DriverOfferRideScreen> createState() =>
      _DriverOfferRideScreenState();
}

class _DriverOfferRideScreenState extends ConsumerState<DriverOfferRideScreen> {
  // Location data
  LatLng? _fromLocation;
  LatLng? _toLocation;
  String _fromAddress = '';
  String _toAddress = '';

  // Selected vehicle
  Vehicle? _selectedVehicle;

  // Ride parameters
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _availableSeats = 3;
  double _pricePerSeat = 10.0;
  bool _isRecurring = false;
  List<int> _recurringDays = [];

  // Preferences
  bool _allowPets = false;
  bool _allowSmoking = false;
  bool _allowLuggage = true;
  bool _isWomenOnly = false;
  bool _acceptOnlinePayment = false;
  bool _isPriceNegotiable = false;
  int _maxDetourMinutes = 10;

  // UI state
  bool _isCreating = false;
  int _currentStep = 0; // 0: Route, 1: Details, 2: Preferences
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initVehicle();
  }

  void _initVehicle() {
    // Auto-select default vehicle if available
    final user = ref.read(currentUserProvider).value;
    if (user != null && user is DriverModel) {
      final vehicles = user.vehicles;
      if (vehicles.isNotEmpty) {
        // Find default or first vehicle
        final defaultVehicle = vehicles.firstWhere(
          (v) => v.isDefault,
          orElse: () => vehicles.first,
        );
        setState(() {
          _selectedVehicle = defaultVehicle;
          _availableSeats = defaultVehicle.seats > 1
              ? defaultVehicle.seats - 1
              : 1; // -1 for driver
          _allowPets = false;
          _allowSmoking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canCreateRide =>
      _fromLocation != null &&
      _toLocation != null &&
      _selectedVehicle != null &&
      _availableSeats > 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null || user is! DriverModel) {
          return _buildNotDriverState();
        }
        return _buildMainContent(user);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildNotDriverState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offer a Ride'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.car_rental_rounded,
                size: 80.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 24.h),
              Text(
                'Driver Account Required',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You need to register as a driver and add a vehicle to offer rides.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              PremiumButton(
                text: 'Become a Driver',
                onPressed: () => context.push(AppRouter.driverOnboarding),
                style: PremiumButtonStyle.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text('Something went wrong', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(DriverModel driver) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildRouteStep(),
                _buildDetailsStep(driver),
                _buildPreferencesStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRouter.home),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Offer a Ride',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Share your journey, earn money',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 48.w), // Balance for back button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Route', 'Details', 'Preferences'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      color: AppColors.cardBg,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18.sp,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRouteStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Route Card
          _buildRouteCard(),

          SizedBox(height: 16.h),

          // Date & Time Card
          _buildDateTimeCard(),

          SizedBox(height: 100.h), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Your Route',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),

          // From Location
          _buildLocationTile(
            icon: Icons.trip_origin_rounded,
            iconColor: AppColors.primary,
            label: _fromAddress.isEmpty ? 'Starting Point' : _fromAddress,
            hint: _fromAddress.isEmpty,
            onTap: () => _selectLocation(isFrom: true),
          ),

          // Swap row
          Row(
            children: [
              SizedBox(width: 26.w),
              Container(
                width: 2.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.error],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _swapLocations,
                icon: Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),

          // To Location
          _buildLocationTile(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: _toAddress.isEmpty ? 'Destination' : _toAddress,
            hint: _toAddress.isEmpty,
            onTap: () => _selectLocation(isFrom: false),
          ),

          SizedBox(height: 8.h),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLocationTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: hint ? FontWeight.w400 : FontWeight.w500,
                  color: hint ? AppColors.textTertiary : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                subtitle: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
                onTap: _selectDate,
              ),
              Divider(height: 1, indent: 68.w, color: AppColors.divider),
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Departure Time',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                subtitle: Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
                onTap: _selectTime,
              ),

              // Recurring ride toggle
              Divider(height: 1, indent: 68.w, color: AppColors.divider),
              SwitchListTile(
                secondary: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.repeat_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Recurring Ride',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Offer this ride regularly',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isRecurring,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),

              if (_isRecurring) _buildRecurringDaysSelector(),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildRecurringDaysSelector() {
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = _recurringDays.contains(index);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isSelected) {
                  _recurringDays.remove(index);
                } else {
                  _recurringDays.add(index);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  days[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailsStep(DriverModel driver) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Vehicle Selection
          _buildVehicleSelector(driver),

          SizedBox(height: 16.h),

          // Seats & Price
          _buildSeatsAndPrice(),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(DriverModel driver) {
    final vehicles = driver.vehicles;

    if (vehicles.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48.sp,
              color: AppColors.warning,
            ),
            SizedBox(height: 12.h),
            Text(
              'No Vehicles Added',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add a vehicle to start offering rides',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            PremiumButton(
              text: 'Add Vehicle',
              onPressed: () => context.push(AppRouter.vehicles),
              style: PremiumButtonStyle.secondary,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Select Vehicle',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push(AppRouter.vehicles),
                  icon: Icon(Icons.add_rounded, size: 18.sp),
                  label: Text('Add', style: TextStyle(fontSize: 13.sp)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 130.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final isSelected = _selectedVehicle?.id == vehicle.id;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedVehicle = vehicle;
                      _availableSeats = vehicle.seats > 1
                          ? vehicle.seats - 1
                          : 1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140.w,
                    margin: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySurface
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_filled_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 24.sp,
                            ),
                            const Spacer(),
                            if (vehicle.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.airline_seat_recline_normal_rounded,
                              size: 14.sp,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${vehicle.seats} seats',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: _getColorFromName(vehicle.color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 12.h),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'white': Colors.white,
      'black': Colors.black,
      'silver': Colors.grey.shade400,
      'gray': Colors.grey,
      'grey': Colors.grey,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'brown': Colors.brown,
      'beige': const Color(0xFFF5F5DC),
    };
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }

  Widget _buildSeatsAndPrice() {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            children: [
              // Available Seats
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.airline_seat_recline_extra_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Available Seats',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _selectedVehicle != null
                      ? 'Max ${_selectedVehicle!.seats - 1} passengers'
                      : 'Select a vehicle first',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: _buildSeatCounter(),
              ),

              Divider(height: 1, indent: 68.w, color: AppColors.divider),

              // Price per Seat
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price per Seat',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Slider(
                            value: _pricePerSeat,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.border,
                            onChanged: (value) =>
                                setState(() => _pricePerSeat = value),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '\$${_pricePerSeat.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Price negotiable toggle
              SwitchListTile(
                secondary: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Price Negotiable',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                value: _isPriceNegotiable,
                activeColor: AppColors.primary,
                onChanged: (value) =>
                    setState(() => _isPriceNegotiable = value),
              ),

              // Online payment toggle
              SwitchListTile(
                secondary: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Accept Online Payment',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Receive payments via Stripe',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _acceptOnlinePayment,
                activeColor: AppColors.primary,
                onChanged: (value) =>
                    setState(() => _acceptOnlinePayment = value),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildSeatCounter() {
    final maxSeats = _selectedVehicle != null ? _selectedVehicle!.seats - 1 : 4;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _availableSeats > 1
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _availableSeats--);
                  }
                : null,
            icon: Icon(
              Icons.remove,
              size: 18.sp,
              color: _availableSeats > 1
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
          ),
          Container(
            width: 32.w,
            alignment: Alignment.center,
            child: Text(
              '$_availableSeats',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: _availableSeats < maxSeats
                ? () {
                    HapticFeedback.lightImpact();
                    setState(() => _availableSeats++);
                  }
                : null,
            icon: Icon(
              Icons.add,
              size: 18.sp,
              color: _availableSeats < maxSeats
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildPreferencesCard(),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 20.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Ride Preferences',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          _buildPreferenceSwitch(
            icon: Icons.luggage_rounded,
            title: 'Allow Luggage',
            subtitle: 'Passengers can bring luggage',
            value: _allowLuggage,
            onChanged: (v) => setState(() => _allowLuggage = v),
          ),
          _buildPreferenceSwitch(
            icon: Icons.pets_rounded,
            title: 'Allow Pets',
            subtitle: 'Passengers can bring pets',
            value: _allowPets,
            onChanged: (v) => setState(() => _allowPets = v),
          ),
          _buildPreferenceSwitch(
            icon: Icons.smoke_free_rounded,
            title: 'Allow Smoking',
            subtitle: 'Smoking is allowed in the car',
            value: _allowSmoking,
            onChanged: (v) => setState(() => _allowSmoking = v),
          ),
          _buildPreferenceSwitch(
            icon: Icons.female_rounded,
            title: 'Women Only',
            subtitle: 'Only female passengers',
            value: _isWomenOnly,
            onChanged: (v) => setState(() => _isWomenOnly = v),
          ),

          Divider(
            height: 1,
            indent: 16.w,
            endIndent: 16.w,
            color: AppColors.divider,
          ),

          // Max detour
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.alt_route_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Max Detour',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'How far you\'ll go to pick up passengers',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$_maxDetourMinutes min',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Slider(
            value: _maxDetourMinutes.toDouble(),
            min: 0,
            max: 30,
            divisions: 6,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            label: '$_maxDetourMinutes min',
            onChanged: (value) =>
                setState(() => _maxDetourMinutes = value.round()),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPreferenceSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: PremiumButton(
                  text: 'Back',
                  onPressed: _goToPreviousStep,
                  style: PremiumButtonStyle.secondary,
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: PremiumButton(
                text: _currentStep == 2
                    ? (_isCreating ? 'Creating...' : 'Create Ride')
                    : 'Continue',
                onPressed: _currentStep == 2
                    ? (_canCreateRide ? _createRide : null)
                    : _goToNextStep,
                isLoading: _isCreating,
                style: PremiumButtonStyle.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _selectLocation({required bool isFrom}) async {
    final result = await MapLocationPicker.show(
      context,
      title: isFrom ? 'Pickup Location' : 'Destination',
      initialLocation: isFrom ? _fromLocation : _toLocation,
      showQuickPicks: true,
    );

    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromLocation = result.location;
          _fromAddress = result.address;
        } else {
          _toLocation = result.location;
          _toAddress = result.address;
        }
      });
    }
  }

  void _swapLocations() {
    if (_fromLocation == null && _toLocation == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      final tempLocation = _fromLocation;
      final tempAddress = _fromAddress;
      _fromLocation = _toLocation;
      _fromAddress = _toAddress;
      _toLocation = tempLocation;
      _toAddress = tempAddress;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
      setState(() => _selectedTime = picked);
    }
  }

  void _goToNextStep() {
    if (_currentStep < 2) {
      // Validate current step
      if (_currentStep == 0 && (_fromLocation == null || _toLocation == null)) {
        _showValidationError(
          'Please select both pickup and destination locations',
        );
        return;
      }
      if (_currentStep == 1 && _selectedVehicle == null) {
        _showValidationError('Please select a vehicle');
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Future<void> _createRide() async {
    if (!_canCreateRide) return;

    HapticFeedback.mediumImpact();
    setState(() => _isCreating = true);

    try {
      final departureDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final ride = RideModel(
        id: '', // Will be set by repository
        driverId: ref.read(currentUserProvider).value!.uid,
        driverName: ref.read(currentUserProvider).value!.displayName,
        driverPhotoUrl: ref.read(currentUserProvider).value!.photoUrl,
        driverRating: ref.read(currentUserProvider).value!.rating.average,
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
        departureTime: departureDateTime,
        availableSeats: _availableSeats,
        pricePerSeat: _pricePerSeat,
        isPriceNegotiable: _isPriceNegotiable,
        acceptsOnlinePayment: _acceptOnlinePayment,
        vehicleId: _selectedVehicle!.id,
        vehicleInfo: '${_selectedVehicle!.make} ${_selectedVehicle!.model}',
        allowPets: _allowPets,
        allowSmoking: _allowSmoking,
        allowLuggage: _allowLuggage,
        isWomenOnly: _isWomenOnly,
        maxDetourMinutes: _maxDetourMinutes,
        isRecurring: _isRecurring,
        recurringDays: _recurringDays,
        status: RideStatus.active,
      );

      await ref.read(rideRepositoryProvider).createRide(ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ride created successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.push(AppRouter.driverRides);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
