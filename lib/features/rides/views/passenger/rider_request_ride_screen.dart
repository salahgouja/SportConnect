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
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

/// Rider's screen to request/search for a ride
/// Modern, Bolt-like UI with minimal steps and clear visual feedback
class RiderRequestRideScreen extends ConsumerStatefulWidget {
  const RiderRequestRideScreen({super.key});

  @override
  ConsumerState<RiderRequestRideScreen> createState() =>
      _RiderRequestRideScreenState();
}

class _RiderRequestRideScreenState extends ConsumerState<RiderRequestRideScreen>
    with SingleTickerProviderStateMixin {
  // Location data
  LatLng? _fromLocation;
  LatLng? _toLocation;
  String _fromAddress = '';
  String _toAddress = '';

  // Search parameters
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _passengers = 1;

  // UI state
  bool _isSearching = false;
  bool _showResults = false;
  int _selectedDateOption = 0; // 0: Today, 1: Tomorrow, 2: Custom

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canSearch =>
      _fromLocation != null &&
      _toLocation != null &&
      _fromAddress.isNotEmpty &&
      _toAddress.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildLocationCard()),
          SliverToBoxAdapter(child: _buildDateTimeSection()),
          SliverToBoxAdapter(child: _buildPassengerSelector()),
          if (_showResults) ...[
            SliverToBoxAdapter(child: _buildResultsHeader()),
            _buildResultsList(),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
      bottomSheet: _buildSearchButton(),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRouter.home),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where to?',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Find the perfect ride for your journey',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          // From Location
          _buildLocationRow(
            icon: Icons.my_location_rounded,
            iconColor: AppColors.primary,
            label: _fromAddress.isEmpty ? 'Where from?' : _fromAddress,
            hint: _fromAddress.isEmpty,
            onTap: () => _selectLocation(isFrom: true),
          ),

          // Divider with swap button
          Row(
            children: [
              SizedBox(width: 20.w),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.more_vert,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.divider,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
              ),
              // Swap button
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.swap_vert_rounded,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          // To Location
          _buildLocationRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: _toAddress.isEmpty ? 'Where to?' : _toAddress,
            hint: _toAddress.isEmpty,
            onTap: () => _selectLocation(isFrom: false),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
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

  Widget _buildDateTimeSection() {
    return Container(
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'When?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Quick date selection chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    _buildDateChip(0, 'Today', DateTime.now()),
                    SizedBox(width: 8.w),
                    _buildDateChip(
                      1,
                      'Tomorrow',
                      DateTime.now().add(const Duration(days: 1)),
                    ),
                    SizedBox(width: 8.w),
                    _buildDateChip(2, 'Pick Date', null),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Time picker row
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Departure time',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDateChip(int index, String label, DateTime? date) {
    final isSelected = _selectedDateOption == index;
    final displayDate = date != null
        ? DateFormat('EEE, MMM d').format(date)
        : DateFormat('EEE, MMM d').format(_selectedDate);

    return GestureDetector(
      onTap: () => _selectDateOption(index, date),
      child: AnimatedContainer(
        height: 60.h,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (index != 2 || isSelected) ...[
              SizedBox(height: 2.h),
              Text(
                index == 2 ? displayDate : displayDate,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSelector() {
    return Container(
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passengers',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'How many seats do you need?',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Counter
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove,
                      onTap: _passengers > 1
                          ? () => setState(() => _passengers--)
                          : null,
                    ),
                    Container(
                      width: 40.w,
                      alignment: Alignment.center,
                      child: Text(
                        '$_passengers',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      icon: Icons.add,
                      onTap: _passengers < 6
                          ? () => setState(() => _passengers++)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildCounterButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: () {
        if (enabled) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    final rides = ref.watch(activeRidesProvider);
    final count = rides.when(
      data: (list) => list.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Text(
            'Available Rides',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showSortOptions(),
            icon: Icon(Icons.sort_rounded, size: 18.sp),
            label: Text('Sort', style: TextStyle(fontSize: 13.sp)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final rides = ref.watch(activeRidesProvider);

    return rides.when(
      data: (rideList) {
        if (rideList.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildRideCard(rideList[index]),
            childCount: rideList.length,
          ),
        );
      },
      loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
      error: (err, _) =>
          SliverToBoxAdapter(child: _buildErrorState(err.toString())),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: InkWell(
        onTap: () => context.push('${AppRouter.rideDetail}/${ride.id}'),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            children: [
              // Driver info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: ride.driverPhotoUrl != null
                        ? NetworkImage(ride.driverPhotoUrl!)
                        : null,
                    backgroundColor: AppColors.primarySurface,
                    child: ride.driverPhotoUrl == null
                        ? Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 22.sp,
                          )
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14.sp,
                              color: AppColors.starFilled,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              (ride.driverRating ?? 0).toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'per seat',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              Divider(height: 1, color: AppColors.divider),
              SizedBox(height: 12.h),

              // Route and time
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    DateFormat('HH:mm').format(ride.departureTime),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${ride.remainingSeats} seats',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Quick features
                  if (ride.allowPets) _buildFeatureChip(Icons.pets_rounded),
                  if (ride.isPriceNegotiable)
                    _buildFeatureChip(Icons.handshake_rounded),
                  if (ride.allowLuggage)
                    _buildFeatureChip(Icons.luggage_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildFeatureChip(IconData icon) {
    return Container(
      margin: EdgeInsets.only(left: 6.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(icon, size: 14.sp, color: AppColors.textSecondary),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No rides found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search criteria\nor check back later',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Finding rides...',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
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
        child: PremiumButton(
          text: _isSearching ? 'Searching...' : 'Search Rides',
          onPressed: _canSearch ? _performSearch : null,
          isLoading: _isSearching,
          icon: Icons.search_rounded,
          style: PremiumButtonStyle.primary,
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _selectLocation({required bool isFrom}) async {
    final result = await MapLocationPicker.show(
      context,
      title: isFrom ? 'Pickup Location' : 'Drop-off Location',
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

  void _selectDateOption(int index, DateTime? date) async {
    HapticFeedback.selectionClick();

    if (index == 2) {
      // Custom date picker
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
        setState(() {
          _selectedDate = picked;
          _selectedDateOption = 2;
        });
      }
    } else {
      setState(() {
        _selectedDate = date!;
        _selectedDateOption = index;
      });
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildSortOption('Recommended', Icons.auto_awesome_rounded),
              _buildSortOption('Earliest departure', Icons.schedule_rounded),
              _buildSortOption('Lowest price', Icons.attach_money_rounded),
              _buildSortOption('Highest rated', Icons.star_rounded),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement sorting
      },
    );
  }

  Future<void> _performSearch() async {
    if (!_canSearch) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    try {
      // Combine date and time
      final departureDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create search filters
      final filters = RideSearchFilters(
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
        departureDate: departureDateTime,
        minSeats: _passengers,
      );

      // Update filters and trigger search
      ref.read(rideSearchViewModelProvider.notifier).updateFilters(filters);
      try {
        await ref.read(rideSearchViewModelProvider.notifier).searchRides();
      } on Object catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search failed. Please try again.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }
}
