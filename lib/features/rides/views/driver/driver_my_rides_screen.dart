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
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

/// Driver My Rides Screen - Dashboard for managing all driver rides
/// Focused on earnings, requests, and ride management
class DriverMyRidesScreen extends ConsumerStatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  ConsumerState<DriverMyRidesScreen> createState() =>
      _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends ConsumerState<DriverMyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > 100;
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
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: _buildEarningsCard(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRequestsTab(),
            _buildActiveTab(),
            _buildScheduledTab(),
            _buildCompletedTab(),
          ],
        ),
      ),
      floatingActionButton: _buildCreateRideFab(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
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
      actions: [
        IconButton(
          onPressed: _showSettingsSheet,
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _isHeaderCollapsed
                  ? AppColors.background
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: _isHeaderCollapsed ? AppColors.textPrimary : Colors.white,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Manage your rides & earnings',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildOnlineToggle(),
                ],
              ),
            ),
          ),
        ),
        title: _isHeaderCollapsed
            ? Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
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
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            tabs: [
              _buildTabWithBadge('Requests', 0),
              const Tab(text: 'Active'),
              const Tab(text: 'Scheduled'),
              const Tab(text: 'Completed'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int tabIndex) {
    return Consumer(
      builder: (context, ref, _) {
        final pendingRequests = ref.watch(pendingRideRequestsProvider);
        final count = pendingRequests.value?.length ?? 0;

        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (count > 0) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildEarningsShimmer(),
      error: (_, __) => const SizedBox.shrink(),
      data: (userData) {
        if (userData == null) return const SizedBox.shrink();

        final statsAsync = ref.watch(driverStatsProvider);

        return statsAsync.when(
          loading: () => _buildEarningsShimmer(),
          error: (_, __) => _buildEarningsShimmer(),
          data: (stats) {
            return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildEarningStat(
                        icon: Icons.account_balance_wallet_rounded,
                        value:
                            '€${stats?.totalEarnings.toStringAsFixed(0) ?? '0'}',
                        label: 'This Month',
                        flex: 2,
                      ),
                      _buildVerticalDivider(),
                      _buildEarningStat(
                        icon: Icons.local_taxi_rounded,
                        value: '${stats?.totalRides ?? 0}',
                        label: 'Total Rides',
                        flex: 1,
                      ),
                      _buildVerticalDivider(),
                      _buildEarningStat(
                        icon: Icons.star_rounded,
                        value: (stats?.rating ?? 0.0).toStringAsFixed(1),
                        label: 'Rating',
                        flex: 1,
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.95, 0.95));
          },
        );
      },
    );
  }

  Widget _buildEarningsShimmer() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildEarningStat({
    required IconData icon,
    required String value,
    required String label,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    final pendingRequests = ref.watch(pendingRideRequestsProvider);

    return pendingRequests.when(
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_rounded,
            title: 'No Pending Requests',
            subtitle: 'New booking requests will appear here',
            actionText: 'Create New Ride',
            onAction: () => context.push(AppRouter.driverOfferRide),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(request, index)
                .animate()
                .fadeIn(delay: Duration(milliseconds: index * 100))
                .slideX(begin: 0.05);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(RideRequest request, int index) {
    final passengerName = request.passengerName;
    final seatsRequested = request.seatsRequested;
    final pricePerSeat = request.pricePerSeat;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Urgency banner
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.warning,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'NEW REQUEST',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap to respond',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Passenger info
                Row(
                  children: [
                    PremiumAvatar(
                      imageUrl: request.passengerPhotoUrl,
                      name: passengerName,
                      size: 52.w,
                      hasBorder: true,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passengerName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.warning,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                request.passengerRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '$seatsRequested seat${seatsRequested > 1 ? 's' : ''}',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+€${(pricePerSeat * seatsRequested).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'earnings',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Ride details
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16.sp,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${DateFormat('EEEE, MMM d').format(request.requestedDate)} • ${request.requestedTime}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
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
                                ),
                              ),
                              Container(
                                width: 2.w,
                                height: 20.h,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.fromLocation.split(',').first,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  request.toLocation.split(',').first,
                                  style: TextStyle(
                                    fontSize: 12.sp,
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
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Decline',
                        onPressed: () => _handleBookingAction(
                          request.rideId,
                          request.id,
                          false,
                        ),
                        style: PremiumButtonStyle.secondary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: PremiumButton(
                        text: 'Accept Request',
                        onPressed: () => _handleBookingAction(
                          request.rideId,
                          request.id,
                          true,
                        ),
                        style: PremiumButtonStyle.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) return _buildLoginRequired();

        final ridesAsync = ref.watch(
          myRidesAsDriverStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final activeRides = rides
                .where((r) => r.status == RideStatus.inProgress)
                .toList();

            if (activeRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.directions_car_outlined,
                title: 'No Active Rides',
                subtitle: 'Start a scheduled ride to see it here',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: activeRides.length,
              itemBuilder: (context, index) {
                final ride = activeRides[index];
                return _buildActiveRideCard(
                  ride,
                  index,
                ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveRideCard(RideModel ride, int index) {
    return GestureDetector(
      onTap: () => context.push(
        AppRouter.driverViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Live indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              ),
              child: Row(
                children: [
                  Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 600.ms)
                      .then()
                      .fadeOut(duration: 600.ms),
                  SizedBox(width: 10.w),
                  Text(
                    'RIDE IN PROGRESS',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${ride.bookings.length}/${ride.availableSeats} passengers',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Route
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.origin.address.split(',').first,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    ride.destination.address.split(',').first,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
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
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '€${(ride.pricePerSeat * ride.bookings.length).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'earned',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionChip(
                          icon: Icons.map_rounded,
                          label: 'Navigate',
                          onTap: () {},
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildActionChip(
                          icon: Icons.check_circle_rounded,
                          label: 'Complete',
                          onTap: () => _completeRide(ride.id),
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: isPrimary
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isPrimary ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isPrimary ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) return _buildLoginRequired();

        final ridesAsync = ref.watch(
          myRidesAsDriverStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final scheduledRides =
                rides
                    .where(
                      (r) =>
                          r.status == RideStatus.active &&
                          r.departureTime.isAfter(DateTime.now()),
                    )
                    .toList()
                  ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

            if (scheduledRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_note_rounded,
                title: 'No Scheduled Rides',
                subtitle: 'Create a new ride to start earning',
                actionText: 'Create Ride',
                onAction: () => context.push(AppRouter.driverOfferRide),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: scheduledRides.length,
              itemBuilder: (context, index) {
                final ride = scheduledRides[index];
                return _buildScheduledRideCard(
                  ride,
                  index,
                ).animate().fadeIn(delay: Duration(milliseconds: index * 80));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScheduledRideCard(RideModel ride, int index) {
    final daysUntil = ride.departureTime.difference(DateTime.now()).inDays;
    final isToday = daysUntil == 0;
    final isTomorrow = daysUntil == 1;

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.driverViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: isToday
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
              : null,
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
              width: 60.w,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                gradient: isToday || isTomorrow
                    ? AppColors.primaryGradient
                    : null,
                color: isToday || isTomorrow ? null : AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(ride.departureTime),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: isToday || isTomorrow
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(ride.departureTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isToday || isTomorrow
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
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
                      if (isToday)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (isTomorrow)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'TOMORROW',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
                        Icons.people_outline_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${ride.bookings.length}/${ride.availableSeats}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '€${ride.pricePerSeat.toStringAsFixed(0)}/seat',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
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

  Widget _buildCompletedTab() {
    final user = ref.watch(currentUserProvider);

    return user.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState('Failed to load user'),
      data: (userData) {
        if (userData == null) return _buildLoginRequired();

        final ridesAsync = ref.watch(
          myRidesAsDriverStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            final completedRides =
                rides.where((r) => r.status == RideStatus.completed).toList()
                  ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            if (completedRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.history_rounded,
                title: 'No Completed Rides',
                subtitle: 'Your completed rides will appear here',
              );
            }

            // Calculate total earnings for completed rides
            final totalEarnings = completedRides.fold<double>(
              0,
              (sum, ride) => sum + (ride.pricePerSeat * ride.bookings.length),
            );

            return Column(
              children: [
                // Earnings summary
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            '€${totalEarnings.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${completedRides.length}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'rides',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),

                // Rides list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: completedRides.length,
                    itemBuilder: (context, index) {
                      final ride = completedRides[index];
                      return _buildCompletedRideCard(ride, index)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 50));
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedRideCard(RideModel ride, int index) {
    final earnings = ride.pricePerSeat * ride.bookings.length;

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.driverViewRide.replaceFirst(':rideId', ride.id),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
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
                    '${DateFormat('MMM d, h:mm a').format(ride.departureTime)} • ${ride.bookings.length} passengers',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '+€${earnings.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRideFab() {
    return FloatingActionButton.extended(
      onPressed: () => context.push(AppRouter.driverOfferRide),
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: Icon(Icons.add_rounded, size: 22.sp),
      label: Text(
        'New Ride',
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
            'Loading your rides...',
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

  Widget _buildLoginRequired() {
    return _buildEmptyState(
      icon: Icons.login_rounded,
      title: 'Sign In Required',
      subtitle: 'Please sign in to manage your rides',
      actionText: 'Sign In',
      onAction: () => context.go(AppRouter.login),
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

  void _handleBookingAction(
    String rideId,
    String bookingId,
    bool accept,
  ) async {
    HapticFeedback.mediumImpact();

    try {
      final rideRepo = ref.read(rideRepositoryProvider);
      await rideRepo.updateBookingStatus(
        rideId: rideId,
        bookingId: bookingId,
        newStatus: accept ? BookingStatus.accepted : BookingStatus.rejected,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Booking accepted!' : 'Booking declined'),
            backgroundColor: accept ? AppColors.success : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _completeRide(String rideId) async {
    HapticFeedback.mediumImpact();

    try {
      final rideRepo = ref.read(rideRepositoryProvider);
      await rideRepo.completeRide(rideId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ride completed! Well done 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSettingsSheet() {
    HapticFeedback.lightImpact();
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
            Text(
              'Driver Settings',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSettingsOption(
              icon: Icons.directions_car_rounded,
              label: 'Manage Vehicles',
              onTap: () {
                context.pop();
                context.push(AppRouter.vehicles);
              },
            ),
            _buildSettingsOption(
              icon: Icons.history_rounded,
              label: 'Earnings History',
              onTap: () {
                context.pop();
                context.push(AppRouter.driverEarnings);
              },
            ),
            _buildSettingsOption(
              icon: Icons.settings_rounded,
              label: 'Preferences',
              onTap: () {
                context.pop();
                context.push(AppRouter.settings);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22.sp),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
        size: 24.sp,
      ),
    );
  }
}
