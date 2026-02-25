import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/utility_widgets.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_search_filters.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Ride Search Screen with filters - Enhanced UI
class RideSearchScreen extends ConsumerStatefulWidget {
  const RideSearchScreen({super.key});

  @override
  ConsumerState<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends ConsumerState<RideSearchScreen>
    with SingleTickerProviderStateMixin {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  int _seats = 1;
  final bool _showFilters = false;
  bool _isSearching = false;
  bool _hasSearched = false;
  int _selectedDateChip = 0; // 0=Today, 1=Tomorrow, 2=Custom

  // Filter options
  double _maxPrice = 50;
  bool _femaleOnly = false;
  bool _instantBook = false;
  bool _verifiedOnly = false;
  bool _petFriendly = false;
  bool _musicAllowed = false;
  double _minRating = 0;
  String _sortBy = 'recommended';

  // Location data
  LatLng? _fromLocation;
  LatLng? _toLocation;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Compact App Bar
          _buildSliverAppBar(),

          // Search Card
          SliverToBoxAdapter(child: _buildSearchCard()),

          // Quick Date Selection
          SliverToBoxAdapter(child: _buildQuickDateSelection()),

          // Active Filters
          if (_hasActiveFilters)
            SliverToBoxAdapter(child: _buildActiveFilters()),

          // Results Header
          SliverToBoxAdapter(child: _buildResultsHeader()),

          // Ride Results
          _buildResultsList(),

          // Bottom Padding
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
      // Floating Filter Button
      floatingActionButton: _buildFloatingFilterButton(),
    );
  }

  bool get _hasActiveFilters =>
      _femaleOnly ||
      _instantBook ||
      _verifiedOnly ||
      _petFriendly ||
      _musicAllowed ||
      _maxPrice < 50 ||
      _minRating > 0;

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 56.h,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: 'Go back',
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.home.path),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
      title: Text(
        AppLocalizations.of(context).findARide,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Filters',
          onPressed: () => _showAdvancedFilters(),
          icon: Badge(
            isLabelVisible: _hasActiveFilters,
            backgroundColor: AppColors.warning,
            smallSize: 8.w,
            child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          // Connected Inputs (more compact)
          IntrinsicHeight(
            child: Row(
              children: [
                // Route indicators
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2.w,
                      height: 28.h,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primary, AppColors.error],
                        ),
                        borderRadius: BorderRadius.circular(1.r),
                      ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompactInputField(
                        controller: _fromController,
                        hint: 'Pickup location',
                        icon: Icons.my_location_rounded,
                        isFrom: true,
                      ),
                      Divider(
                        height: 16.h,
                        thickness: 1,
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                      _buildCompactInputField(
                        controller: _toController,
                        hint: 'Where to?',
                        icon: Icons.search_rounded,
                        isFrom: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Swap Button
                GestureDetector(
                  onTap: _swapLocations,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Date, Seats & Search Row (compact)
          Row(
            children: [
              Expanded(child: _buildCompactDateSelector()),
              SizedBox(width: 8.w),
              _buildCompactSeatSelector(),
              SizedBox(width: 8.w),
              _buildSearchButton(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  void _swapLocations() {
    HapticFeedback.lightImpact();
    final tempText = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = tempText;
    final tempLocation = _fromLocation;
    setState(() {
      _fromLocation = _toLocation;
      _toLocation = tempLocation;
    });
  }

  Widget _buildCompactInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isFrom,
  }) {
    return GestureDetector(
      onTap: () => _openLocationPicker(isFrom: isFrom),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: controller.text.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                  fontWeight: controller.text.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    controller.clear();
                    if (isFrom) {
                      _fromLocation = null;
                    } else {
                      _toLocation = null;
                    }
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16.sp,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
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
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _selectedDateChip = 2; // Custom
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              _formatDate(_selectedDate),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSeatSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _seats > 1
                ? () {
                    HapticFeedback.selectionClick();
                    setState(() => _seats--);
                  }
                : null,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.remove_rounded,
                color: _seats > 1 ? AppColors.primary : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 2.w),
                Text(
                  AppLocalizations.of(context).value2(_seats),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _seats < 4
                ? () {
                    HapticFeedback.selectionClick();
                    setState(() => _seats++);
                  }
                : null,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.add_rounded,
                color: _seats < 4 ? AppColors.primary : AppColors.textTertiary,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: _performSearch,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _isSearching
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Icon(Icons.search_rounded, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Future<void> _performSearch() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseEnterBothLocations),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
      return;
    }
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).pleaseSelectLocationsFromThe,
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSearching = true);

    final filters = RideSearchFilters(
      origin: LocationPoint(
        address: _fromController.text,
        latitude: _fromLocation!.latitude,
        longitude: _fromLocation!.longitude,
      ),
      destination: LocationPoint(
        address: _toController.text,
        latitude: _toLocation!.latitude,
        longitude: _toLocation!.longitude,
      ),
      departureDate: _selectedDate,
      minSeats: _seats,
    );

    ref.read(rideSearchViewModelProvider.notifier).updateFilters(filters);
    try {
      await ref.read(rideSearchViewModelProvider.notifier).searchRides();
      if (!mounted) return;
      setState(() => _hasSearched = true);
    } catch (e) {
      if (!mounted) return;
      TalkerService.debug('Ride search failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).searchFailedPleaseTryAgain,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Widget _buildQuickDateSelection() {
    final now = DateTime.now();
    final dates = [
      ('Today', now),
      ('Tomorrow', now.add(const Duration(days: 1))),
      ('This Weekend', _getNextWeekend()),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(dates.length, (index) {
                final isSelected = _selectedDateChip == index;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedDateChip = index;
                        _selectedDate = dates[index].$2;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected ? AppSpacing.shadowSm : null,
                      ),
                      child: Text(
                        dates[index].$1,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  DateTime _getNextWeekend() {
    final now = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    return now.add(
      Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday),
    );
  }

  Widget _buildActiveFilters() {
    final filters = <Widget>[];

    if (_maxPrice < 50) {
      filters.add(
        _buildFilterTag(
          AppLocalizations.of(context).maxValue(_maxPrice.toInt()),
          () {
            setState(() => _maxPrice = 50);
          },
        ),
      );
    }
    if (_femaleOnly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).femaleOnly, () {
          setState(() => _femaleOnly = false);
        }),
      );
    }
    if (_instantBook) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).instantBook, () {
          setState(() => _instantBook = false);
        }),
      );
    }
    if (_verifiedOnly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).verified, () {
          setState(() => _verifiedOnly = false);
        }),
      );
    }
    if (_petFriendly) {
      filters.add(
        _buildFilterTag(AppLocalizations.of(context).petFriendly, () {
          setState(() => _petFriendly = false);
        }),
      );
    }
    if (_minRating > 0) {
      filters.add(
        _buildFilterTag(
          AppLocalizations.of(
            context,
          ).valueRating(_minRating.toStringAsFixed(1)),
          () {
            setState(() => _minRating = 0);
          },
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).activeFilters,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _maxPrice = 50;
                    _femaleOnly = false;
                    _instantBook = false;
                    _verifiedOnly = false;
                    _petFriendly = false;
                    _musicAllowed = false;
                    _minRating = 0;
                  });
                },
                child: Text(
                  AppLocalizations.of(context).clearAll2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: filters),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    final ridesAsync = ref.watch(activeRidesProvider);
    final ridesCount = ridesAsync.when(
      data: (rides) => _filterRides(rides).length,
      loading: () => 0,
      error: (_, _) => 0,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).valueRidesAvailable(ridesCount),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _getSortLabel(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  /// Filter rides based on current filter settings
  List<RideModel> _filterRides(List<RideModel> rides) {
    return rides.where((ride) {
      // Filter by date
      if (!_isSameDay(ride.departureTime, _selectedDate)) return false;

      // Filter by available seats
      if (ride.remainingSeats < _seats) return false;

      // Filter by max price
      if (ride.pricePerSeat > _maxPrice) return false;

      // Note: Rating-based filtering removed due to database normalization
      // Driver ratings are no longer stored in RideModel for data integrity
      // Rating filters can be re-implemented with cached driver stats if needed

      return true;
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'rating':
        return 'Rating';
      case 'departure':
        return 'Departure';
      default:
        return 'Recommended';
    }
  }

  Widget _buildFloatingFilterButton() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _showFilters ? const Offset(0, 2) : Offset.zero,
      child: FloatingActionButton.extended(
        heroTag: 'ride_search_filter_fab',
        onPressed: _showAdvancedFilters,
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.filter_list_rounded, size: 20.sp),
        label: Text(
          AppLocalizations.of(context).filtersValue(
            _hasActiveFilters ? ' (${_getActiveFilterCount()})' : '',
          ),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_maxPrice < 50) count++;
    if (_femaleOnly) count++;
    if (_instantBook) count++;
    if (_verifiedOnly) count++;
    if (_petFriendly) count++;
    if (_musicAllowed) count++;
    if (_minRating > 0) count++;
    return count;
  }

  void _showAdvancedFilters() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                // Handle & Header
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).filters,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _maxPrice = 50;
                                _femaleOnly = false;
                                _instantBook = false;
                                _verifiedOnly = false;
                                _petFriendly = false;
                                _musicAllowed = false;
                                _minRating = 0;
                              });
                            },
                            child: Text(
                              AppLocalizations.of(context).reset,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter Options
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Range
                        _buildFilterSectionTitle(
                          AppLocalizations.of(context).priceRange,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).text52,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).maxValue(_maxPrice.toInt()),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context).text100,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.border,
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            trackHeight: 4.h,
                          ),
                          child: Slider(
                            value: _maxPrice,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            onChanged: (value) {
                              setModalState(() => _maxPrice = value);
                              setState(() => _maxPrice = value);
                            },
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Driver Rating
                        _buildFilterSectionTitle(
                          AppLocalizations.of(context).minimumRating,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [0.0, 3.0, 4.0, 4.5, 4.8].map((rating) {
                            final isSelected = _minRating == rating;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setModalState(() => _minRating = rating);
                                setState(() => _minRating = rating);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (rating > 0) ...[
                                      Icon(
                                        Icons.star_rounded,
                                        size: 14.sp,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.xpGold,
                                      ),
                                      SizedBox(width: 2.w),
                                    ],
                                    Text(
                                      rating == 0
                                          ? AppLocalizations.of(context).any
                                          : AppLocalizations.of(
                                              context,
                                            ).value13(rating),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 24.h),

                        // Preferences
                        _buildFilterSectionTitle(
                          AppLocalizations.of(context).preferences,
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            _buildToggleChip(
                              label: AppLocalizations.of(context).femaleOnly,
                              icon: Icons.female_rounded,
                              isSelected: _femaleOnly,
                              onTap: () {
                                setModalState(() => _femaleOnly = !_femaleOnly);
                                setState(() => _femaleOnly = !_femaleOnly);
                              },
                            ),
                            _buildToggleChip(
                              label: AppLocalizations.of(context).instantBook,
                              icon: Icons.bolt_rounded,
                              isSelected: _instantBook,
                              onTap: () {
                                setModalState(
                                  () => _instantBook = !_instantBook,
                                );
                                setState(() => _instantBook = !_instantBook);
                              },
                            ),
                            _buildToggleChip(
                              label: AppLocalizations.of(
                                context,
                              ).verifiedDriver2,
                              icon: Icons.verified_rounded,
                              isSelected: _verifiedOnly,
                              onTap: () {
                                setModalState(
                                  () => _verifiedOnly = !_verifiedOnly,
                                );
                                setState(() => _verifiedOnly = !_verifiedOnly);
                              },
                            ),
                            _buildToggleChip(
                              label: AppLocalizations.of(context).petFriendly,
                              icon: Icons.pets_rounded,
                              isSelected: _petFriendly,
                              onTap: () {
                                setModalState(
                                  () => _petFriendly = !_petFriendly,
                                );
                                setState(() => _petFriendly = !_petFriendly);
                              },
                            ),
                            _buildToggleChip(
                              label: AppLocalizations.of(context).musicAllowed,
                              icon: Icons.music_note_rounded,
                              isSelected: _musicAllowed,
                              onTap: () {
                                setModalState(
                                  () => _musicAllowed = !_musicAllowed,
                                );
                                setState(() => _musicAllowed = !_musicAllowed);
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),

                        // Vehicle Type (New Feature)
                        _buildFilterSectionTitle(
                          AppLocalizations.of(context).vehicleType,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildVehicleOption(
                              Icons.directions_car,
                              AppLocalizations.of(context).any,
                              true,
                              setModalState,
                            ),
                            SizedBox(width: 10.w),
                            _buildVehicleOption(
                              Icons.electric_car,
                              AppLocalizations.of(context).electric,
                              false,
                              setModalState,
                            ),
                            SizedBox(width: 10.w),
                            _buildVehicleOption(
                              Icons.local_taxi,
                              AppLocalizations.of(context).comfort,
                              false,
                              setModalState,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Apply Button
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    child: PremiumButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        context.pop();
                        HapticFeedback.mediumImpact();
                      },
                      style: PremiumButtonStyle.gradient,
                      icon: Icons.check_rounded,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(
    IconData icon,
    String label,
    bool isSelected,
    StateSetter setModalState,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySurface
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
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

  Future<void> _openLocationPicker({required bool isFrom}) async {
    final result = await MapLocationPicker.show(
      context,
      title: isFrom ? 'Select Pickup Location' : 'Select Destination',
      initialLocation: isFrom ? _fromLocation : _toLocation,
      showQuickPicks: true,
    );

    if (result != null) {
      setState(() {
        if (isFrom) {
          _fromLocation = result.location;
          _fromController.text = result.address;
        } else {
          _toLocation = result.location;
          _toController.text = result.address;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    }
    if (date.day == now.day + 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Tomorrow';
    }
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildResultsList() {
    if (_hasSearched) {
      final searchState = ref.watch(rideSearchViewModelProvider);
      if (searchState.isLoading) {
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      if (searchState.error != null) {
        return SliverFillRemaining(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Search failed',
            subtitle: searchState.error!,
            actionText: 'Retry',
            onActionPressed: _performSearch,
          ),
        );
      }

      final sorted = _sortRides(_filterRides(searchState.rides));
      if (sorted.isEmpty) {
        return SliverFillRemaining(
          child: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No rides found',
            subtitle:
                'Try adjusting your filters or search for a different date',
            actionText: 'Offer a Ride',
            onActionPressed: () => context.push(AppRoutes.driverOfferRide.path),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return _buildRideModelCard(sorted[index], index)
                .animate()
                .fadeIn(
                  duration: 350.ms,
                  delay: Duration(milliseconds: 50 + (index * 60)),
                )
                .slideX(begin: 0.1, curve: Curves.easeOutCubic);
          }, childCount: sorted.length),
        ),
      );
    }

    // Fallback to active rides stream when no explicit search has been performed
    final ridesAsync = ref.watch(activeRidesProvider);
    return ridesAsync.when(
      loading: () => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).findingRides,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          subtitle: 'Unable to load rides. Please try again.',
          actionText: 'Retry',
          onActionPressed: () => ref.invalidate(activeRidesProvider),
        ),
      ),
      data: (allRides) {
        final rides = _filterRides(allRides);
        final sortedRides = _sortRides(rides);
        if (sortedRides.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No rides found',
              subtitle:
                  'Try adjusting your filters or search for a different date',
              actionText: 'Offer a Ride',
              onActionPressed: () =>
                  context.push(AppRoutes.driverOfferRide.path),
            ),
          );
        }
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildRideModelCard(sortedRides[index], index)
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: Duration(milliseconds: 50 + (index * 60)),
                  )
                  .slideX(begin: 0.1, curve: Curves.easeOutCubic);
            }, childCount: sortedRides.length),
          ),
        );
      },
    );
  }

  /// Sort rides based on current sort option
  List<RideModel> _sortRides(List<RideModel> rides) {
    final sorted = List<RideModel>.from(rides);
    switch (_sortBy) {
      case 'price_low':
        sorted.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.pricePerSeat.compareTo(a.pricePerSeat));
        break;
      case 'rating':
        // Note: Rating-based sorting removed due to database normalization
        // Fallback to departure time sorting
        sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'departure':
        sorted.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      default:
        // Recommended: combination of remaining seats and departure time
        sorted.sort((a, b) {
          final scoreA =
              (a.remainingSeats * 10) +
              (100 - a.departureTime.difference(DateTime.now()).inMinutes);
          final scoreB =
              (b.remainingSeats * 10) +
              (100 - b.departureTime.difference(DateTime.now()).inMinutes);
          return scoreB.compareTo(scoreA);
        });
    }
    return sorted;
  }

  /// Build ride card using RideModel from Firestore
  Widget _buildRideModelCard(RideModel ride, int index) {
    final departureTimeFormatted = DateFormat(
      'h:mm a',
    ).format(ride.departureTime);
    final estimatedArrival = ride.departureTime.add(
      Duration(minutes: ride.durationMinutes ?? 60),
    );
    final arrivalTimeFormatted = DateFormat('h:mm a').format(estimatedArrival);
    final durationFormatted = _formatDuration(ride.durationMinutes ?? 60);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => context.pushNamed(
            AppRoutes.rideDetail.name,
            pathParameters: {'id': ride.id},
          ),
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            children: [
              // Main Content
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  children: [
                    // Top Row: Driver + Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver Avatar
                        DriverAvatarWidget(driverId: ride.driverId, radius: 22),
                        SizedBox(width: 10.w),
                        // Driver info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DriverNameWidget(
                                driverId: ride.driverId,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  DriverRatingWidget(
                                    driverId: ride.driverId,
                                    showIcon: true,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    durationFormatted,
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
                        // Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).value5(ride.pricePerSeat.toStringAsFixed(0)),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Route display
                    Row(
                      children: [
                        // Timeline
                        Column(
                          children: [
                            Text(
                              departureTimeFormatted,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              width: 2.w,
                              height: 24.h,
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.primary, AppColors.error],
                                ),
                                borderRadius: BorderRadius.circular(1.r),
                              ),
                            ),
                            Text(
                              arrivalTimeFormatted,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        // Locations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      ride.origin.address,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: AppColors.error,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      ride.destination.address,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom info bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Seats
                    _buildInfoChip(
                      Icons.event_seat_rounded,
                      AppLocalizations.of(
                        context,
                      ).valueSeats(ride.remainingSeats),
                      AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    // Eco badge - show if ride has no smoking preference or allows luggage
                    if (!ride.allowSmoking)
                      _buildInfoChip(
                        Icons.eco_rounded,
                        AppLocalizations.of(context).eco,
                        AppColors.success,
                      ),
                    const Spacer(),
                    // Book button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        AppLocalizations.of(context).book,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}min';
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).sortBy2,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildSortOption(
                    icon: Icons.recommend_rounded,
                    title: AppLocalizations.of(context).recommended,
                    subtitle: 'Best match for your search',
                    value: 'recommended',
                  ),
                  _buildSortOption(
                    icon: Icons.arrow_downward_rounded,
                    title: AppLocalizations.of(context).lowestPrice2,
                    subtitle: 'Show cheapest rides first',
                    value: 'price_low',
                  ),
                  _buildSortOption(
                    icon: Icons.access_time_rounded,
                    title: AppLocalizations.of(context).earliestDeparture2,
                    subtitle: 'Show rides leaving soonest',
                    value: 'departure',
                  ),
                  _buildSortOption(
                    icon: Icons.star_rounded,
                    title: AppLocalizations.of(context).highestRated2,
                    subtitle: 'Show best-rated drivers first',
                    value: 'rating',
                  ),
                  _buildSortOption(
                    icon: Icons.timer_rounded,
                    title: AppLocalizations.of(context).shortestDuration,
                    subtitle: 'Show fastest routes first',
                    value: 'duration',
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _sortBy == value;
    return ListTile(
      onTap: () {
        context.pop();
        HapticFeedback.selectionClick();
        setState(() => _sortBy = value);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22.sp,
            )
          : null,
    );
  }
}
