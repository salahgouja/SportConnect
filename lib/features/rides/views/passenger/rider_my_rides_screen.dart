import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

/// Rider My Rides Screen - Uber/Bolt inspired ride history and bookings
/// Focused on the passenger experience with quick rebooking and trip status
class RiderMyRidesScreen extends ConsumerStatefulWidget {
  const RiderMyRidesScreen({super.key});

  @override
  ConsumerState<RiderMyRidesScreen> createState() => _RiderMyRidesScreenState();
}

class _RiderMyRidesScreenState extends ConsumerState<RiderMyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > 80;
    if (collapsed != _isHeaderCollapsed) {
      setState(() => _isHeaderCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxScrolled) => [
          _buildSliverAppBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveTripsTab(),
            _buildUpcomingTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
      floatingActionButton: _buildQuickActionFab(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250.h,
      collapsedHeight: 60.h,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _isHeaderCollapsed
                ? AppColors.background
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _isHeaderCollapsed ? AppColors.textPrimary : Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Trips',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Track & manage your rides',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildQuickStats(),
                ],
              ),
            ),
          ),
        ),
        title: _isHeaderCollapsed
            ? Text(
                'My Trips',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(52.h),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            tabs: [
              _buildTab('Active', Icons.directions_car_filled_rounded, 0),
              _buildTab('Upcoming', Icons.schedule_rounded, 1),
              _buildTab('History', Icons.history_rounded, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
    final isSelected = _tabController.index == index;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 4.w),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (userData) {
        if (userData == null) return const SizedBox.shrink();

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildStatsShimmer(),
          error: (_, __) => const SizedBox.shrink(),
          data: (rides) {
            final totalRides = rides.length;
            final activeRides = rides
                .where(
                  (r) =>
                      r.status == RideStatus.active ||
                      r.status == RideStatus.inProgress,
                )
                .length;

            return Row(
              children: [
                _buildStatChip(
                  icon: Icons.route_rounded,
                  value: '$totalRides',
                  label: 'Total Trips',
                ),
                SizedBox(width: 12.w),
                _buildStatChip(
                  icon: Icons.local_taxi_rounded,
                  value: '$activeRides',
                  label: 'Active',
                  highlighted: activeRides > 0,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms);
          },
        );
      },
    );
  }

  Widget _buildStatsShimmer() {
    return Row(
      children: [
        Container(
          width: 100.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 80.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    bool highlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: highlighted
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: highlighted
            ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripsTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: 'Sign In Required',
            subtitle: 'Please sign in to view your trips',
            actionText: 'Sign In',
            onAction: () => context.go(AppRouter.login),
          );
        }

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final activeRides = rides
                .where(
                  (r) =>
                      r.status == RideStatus.active ||
                      r.status == RideStatus.inProgress,
                )
                .toList();

            if (activeRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No Active Trips',
                subtitle: 'You don\'t have any trips in progress',
                actionText: 'Find a Ride',
                onAction: () => context.push(AppRouter.riderRequestRide),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: activeRides.length,
              itemBuilder: (context, index) {
                final ride = activeRides[index];
                return _buildActiveTripCard(ride, index)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 100))
                    .slideY(begin: 0.1);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveTripCard(RideModel ride, int index) {
    final isInProgress = ride.status == RideStatus.inProgress;

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.riderViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: isInProgress
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isInProgress
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Live status banner
            if (isInProgress)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .fadeIn(duration: 600.ms)
                        .then()
                        .fadeOut(duration: 600.ms),
                    SizedBox(width: 8.w),
                    Text(
                      'TRIP IN PROGRESS',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Route info
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2.w,
                            height: 30.h,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.origin.address,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              ride.destination.address,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
                  SizedBox(height: 16.h),

                  // Driver info and time
                  Row(
                    children: [
                      PremiumAvatar(
                        imageUrl: null,
                        name: ride.driverName,
                        size: 44.w,
                        hasBorder: true,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.warning,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  width: 4.w,
                                  height: 4.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.textTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  ride.vehicleInfo ?? 'Vehicle',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('h:mm a').format(ride.departureTime),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            DateFormat('MMM d').format(ride.departureTime),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Quick actions
                  if (!isInProgress) ...[
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Message',
                            onTap: () {
                              // Open chat
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.phone_outlined,
                            label: 'Call',
                            onTap: () {
                              // Call driver
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.close_rounded,
                            label: 'Cancel',
                            onTap: () => _showCancelDialog(ride),
                            isDestructive: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: 'Sign In Required',
            subtitle: 'Please sign in to view your trips',
            actionText: 'Sign In',
            onAction: () => context.go(AppRouter.login),
          );
        }

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final upcomingRides =
                rides.where((r) {
                    return r.status == RideStatus.active &&
                        r.departureTime.isAfter(DateTime.now());
                  }).toList()
                  ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

            if (upcomingRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available_rounded,
                title: 'No Upcoming Trips',
                subtitle: 'Book a ride to see it here',
                actionText: 'Find a Ride',
                onAction: () => context.push(AppRouter.riderRequestRide),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: upcomingRides.length,
              itemBuilder: (context, index) {
                final ride = upcomingRides[index];
                return _buildUpcomingTripCard(ride, index)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 80))
                    .slideY(begin: 0.05);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingTripCard(RideModel ride, int index) {
    final daysUntil = ride.departureTime.difference(DateTime.now()).inDays;
    String timeLabel;
    if (daysUntil == 0) {
      timeLabel = 'Today';
    } else if (daysUntil == 1) {
      timeLabel = 'Tomorrow';
    } else {
      timeLabel = 'In $daysUntil days';
    }

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.riderViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date badge
            Container(
              width: 56.w,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(ride.departureTime),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(ride.departureTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ride.origin.address.split(',').first} → ${ride.destination.address.split(',').first}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('h:mm a').format(ride.departureTime),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.driverName,
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: 'Sign In Required',
            subtitle: 'Please sign in to view your trip history',
            actionText: 'Sign In',
            onAction: () => context.go(AppRouter.login),
          );
        }

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final pastRides =
                rides
                    .where(
                      (r) =>
                          r.status == RideStatus.completed ||
                          r.status == RideStatus.cancelled,
                    )
                    .toList()
                  ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            if (pastRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.history_rounded,
                title: 'No Trip History',
                subtitle: 'Your completed trips will appear here',
                actionText: 'Find a Ride',
                onAction: () => context.push(AppRouter.riderRequestRide),
              );
            }

            // Group by month
            final groupedRides = <String, List<RideModel>>{};
            for (final ride in pastRides) {
              final monthKey = DateFormat(
                'MMMM yyyy',
              ).format(ride.departureTime);
              groupedRides.putIfAbsent(monthKey, () => []).add(ride);
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: groupedRides.length,
              itemBuilder: (context, index) {
                final monthKey = groupedRides.keys.elementAt(index);
                final monthRides = groupedRides[monthKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.h,
                        top: index > 0 ? 8.h : 0,
                      ),
                      child: Text(
                        monthKey,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...monthRides.asMap().entries.map(
                      (e) => _buildHistoryTripCard(e.value, e.key)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: e.key * 50)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTripCard(RideModel ride, int index) {
    final isCancelled = ride.status == RideStatus.cancelled;

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.riderViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: isCancelled
              ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isCancelled
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline_rounded,
                color: isCancelled ? AppColors.error : AppColors.success,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.origin.address.split(',').first} → ${ride.destination.address.split(',').first}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${DateFormat('MMM d, h:mm a').format(ride.departureTime)} • ${ride.driverName}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${ride.pricePerSeat.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!isCancelled)
                  GestureDetector(
                    onTap: () => _showRebookDialog(ride),
                    child: Text(
                      'Rebook',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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

  Widget _buildQuickActionFab() {
    return FloatingActionButton.extended(
      onPressed: () => context.push(AppRouter.riderRequestRide),
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: Icon(Icons.search_rounded, size: 22.sp),
      label: Text(
        'Find Ride',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            'Loading your trips...',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48.sp, color: AppColors.primary),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24.h),
              PremiumButton(
                text: actionText,
                onPressed: onAction,
                style: PremiumButtonStyle.primary,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _showCancelDialog(RideModel ride) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.warning_amber_rounded,
              size: 56.sp,
              color: AppColors.warning,
            ),
            SizedBox(height: 16.h),
            Text(
              'Cancel Trip?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Are you sure you want to cancel your trip to ${ride.destination.address.split(',').first}?',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: PremiumButton(
                    text: 'Keep Trip',
                    onPressed: () => Navigator.pop(context),
                    style: PremiumButtonStyle.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumButton(
                    text: 'Cancel Trip',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement cancel booking
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Trip cancelled'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                    style: PremiumButtonStyle.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showRebookDialog(RideModel ride) {
    HapticFeedback.lightImpact();
    // Navigate to request ride with pre-filled locations
    context.push(AppRouter.riderRequestRide);
  }
}
