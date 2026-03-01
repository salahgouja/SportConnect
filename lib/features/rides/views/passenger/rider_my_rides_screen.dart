import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

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
        tooltip: 'Go back',
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
                    AppLocalizations.of(context).myTrips,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    AppLocalizations.of(context).trackManageYourRides,
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
                AppLocalizations.of(context).myTrips,
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
              _buildTab(
                AppLocalizations.of(context).active,
                Icons.directions_car_filled_rounded,
                0,
              ),
              _buildTab(
                AppLocalizations.of(context).upcoming,
                Icons.schedule_rounded,
                1,
              ),
              _buildTab(
                AppLocalizations.of(context).history,
                Icons.history_rounded,
                2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
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
      error: (_, _) => const SizedBox.shrink(),
      data: (userData) {
        if (userData == null) return const SizedBox.shrink();

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildStatsShimmer(),
          error: (_, _) => const SizedBox.shrink(),
          data: (rides) {
            final totalRides = rides.length;
            final activeRides = rides
                .where(
                  (r) =>
                      r.status == RideStatus.active ||
                      r.status == RideStatus.inProgress,
                )
                .length;

            final co2Saved = rides.fold<double>(
              0,
              (sum, r) =>
                  sum +
                  (r.status == RideStatus.completed
                      ? r.co2SavedPerPassenger
                      : 0),
            );

            return Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                _buildStatChip(
                  icon: Icons.route_rounded,
                  value: '$totalRides',
                  label: AppLocalizations.of(context).totalTrips,
                ),
                _buildStatChip(
                  icon: Icons.local_taxi_rounded,
                  value: '$activeRides',
                  label: AppLocalizations.of(context).active,
                  highlighted: activeRides > 0,
                ),
                if (co2Saved > 0)
                  _buildStatChip(
                    icon: Icons.eco_rounded,
                    value: '${co2Saved.toStringAsFixed(1)} kg',
                    label: 'CO\u2082 saved',
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
                  fontSize: 12.sp,
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
      error: (_, _) =>
          _buildErrorState(AppLocalizations.of(context).failedToLoadUser),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: AppLocalizations.of(context).signInRequired,
            subtitle: 'Please sign in to view your trips',
            actionText: 'Sign In',
            onAction: () => context.go(AppRoutes.login.path),
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
                .where((r) => r.status == RideStatus.inProgress)
                .toList();

            if (activeRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.directions_car_outlined,
                title: AppLocalizations.of(context).noActiveTrips,
                subtitle: 'You don\'t have any trips in progress',
                actionText: 'Find a Ride',
                onAction: () => context.go(AppRoutes.riderRequestRide.path),
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
      onTap: () {
        if (ride.status == RideStatus.inProgress) {
          context.push(
            AppRoutes.rideNavigation.path.replaceFirst(':id', ride.id),
          );
        } else {
          context.pushNamed(
            AppRoutes.riderViewRide.name,
            pathParameters: {'id': ride.id},
          );
        }
      },
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
                      AppLocalizations.of(context).tripInProgress,
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
                      DriverAvatarWidget(driverId: ride.driverId, radius: 22),
                      SizedBox(width: 12.w),
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
                            Row(
                              children: [
                                DriverRatingWidget(
                                  driverId: ride.driverId,
                                  showIcon: true,
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
                            label: AppLocalizations.of(context).message,
                            onTap: () => _openChat(ride),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.phone_outlined,
                            label: AppLocalizations.of(context).call,
                            onTap: () => _callDriver(ride),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.close_rounded,
                            label: AppLocalizations.of(context).actionCancel,
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
      error: (_, _) =>
          _buildErrorState(AppLocalizations.of(context).failedToLoadUser),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: AppLocalizations.of(context).signInRequired,
            subtitle: 'Please sign in to view your trips',
            actionText: 'Sign In',
            onAction: () => context.go(AppRoutes.login.path),
          );
        }

        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userData.uid),
        );

        return ridesAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error.toString()),
          data: (rides) {
            // Also watch passenger bookings to enable countdown routing
            final myBookings =
                ref.watch(bookingsByPassengerProvider(userData.uid)).value ??
                [];

            final upcomingRides =
                rides.where((r) {
                    return (r.status == RideStatus.active ||
                            r.status == RideStatus.full) &&
                        r.departureTime.isAfter(DateTime.now());
                  }).toList()
                  ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

            if (upcomingRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available_rounded,
                title: AppLocalizations.of(context).noUpcomingTrips,
                subtitle: 'Book a ride to see it here',
                actionText: 'Find a Ride',
                onAction: () => context.go(AppRoutes.riderRequestRide.path),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: upcomingRides.length,
              itemBuilder: (context, index) {
                final ride = upcomingRides[index];
                return Dismissible(
                  key: ValueKey('upcoming_ride_${ride.id}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    HapticFeedback.mediumImpact();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Cancel this ride?'),
                        content: const Text(
                          'You will be taken to the cancellation screen.',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Keep'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('Cancel Ride'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context.pushNamed(
                        AppRoutes.cancellationReason.name,
                        pathParameters: {'id': ride.id},
                      );
                    }
                    return false; // list manages itself via stream
                  },
                  background: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                          size: 26.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child:
                      _buildUpcomingTripCard(
                            ride,
                            index,
                            booking: myBookings
                                .where((b) => b.rideId == ride.id)
                                .firstOrNull,
                          )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 80))
                          .slideY(begin: 0.05),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingTripCard(
    RideModel ride,
    int index, {
    RideBooking? booking,
  }) {
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
      onTap: () {
        if (booking?.status == BookingStatus.accepted) {
          context.pushNamed(
            AppRoutes.rideCountdown.name,
            pathParameters: {'bookingId': booking!.id},
          );
        } else {
          context.pushNamed(
            AppRoutes.riderViewRide.name,
            pathParameters: {'id': ride.id},
          );
        }
      },
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
                          AppLocalizations.of(context).valueValue2(
                            ride.origin.address.split(',').first,
                            ride.destination.address.split(',').first,
                          ),
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
                            fontSize: 12.sp,
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
                      DriverNameWidget(
                        driverId: ride.driverId,
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
      error: (_, _) =>
          _buildErrorState(AppLocalizations.of(context).failedToLoadUser),
      data: (userData) {
        if (userData == null) {
          return _buildEmptyState(
            icon: Icons.login_rounded,
            title: AppLocalizations.of(context).signInRequired,
            subtitle: 'Please sign in to view your trip history',
            actionText: 'Sign In',
            onAction: () => context.go(AppRoutes.login.path),
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
                          r.status == RideStatus.cancelled ||
                          (r.status == RideStatus.full &&
                              r.departureTime.isBefore(DateTime.now())),
                    )
                    .toList()
                  ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

            if (pastRides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.history_rounded,
                title: AppLocalizations.of(context).noTripHistory,
                subtitle: 'Your completed trips will appear here',
                actionText: 'Find a Ride',
                onAction: () => context.go(AppRoutes.riderRequestRide.path),
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
      onTap: () => context.pushNamed(
        AppRoutes.riderViewRide.name,
        pathParameters: {'id': ride.id},
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
                    AppLocalizations.of(context).valueValue2(
                      ride.origin.address.split(',').first,
                      ride.destination.address.split(',').first,
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM d, h:mm a').format(ride.departureTime),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      DriverNameWidget(
                        driverId: ride.driverId,
                        style: TextStyle(
                          fontSize: 11.sp,
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
                  AppLocalizations.of(
                    context,
                  ).value6(ride.pricePerSeat.toStringAsFixed(0)),
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
                      AppLocalizations.of(context).rebook,
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
      heroTag: 'rider_my_rides_fab',
      onPressed: () => context.go(AppRoutes.riderRequestRide.path),
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: Icon(Icons.search_rounded, size: 22.sp),
      label: Text(
        AppLocalizations.of(context).findRide,
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
            AppLocalizations.of(context).loadingYourTrips,
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
              AppLocalizations.of(context).somethingWentWrong,
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.sp, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 16.h),
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
              AppLocalizations.of(context).cancelTrip,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(
                context,
              ).areYouSureYouWant10(ride.destination.address.split(',').first),
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
                    onPressed: () async {
                      Navigator.pop(context);
                      final currentUser = ref.read(currentUserProvider).value;
                      if (currentUser == null) return;
                      RideBooking? booking;
                      try {
                        booking = await ref
                            .read(rideActionsViewModelProvider)
                            .getPassengerBookingForRide(
                              ride.id,
                              currentUser.uid,
                            );
                      } catch (e) {
                        booking = null;
                      }
                      if (booking == null) return;
                      try {
                        await ref
                            .read(rideActionsViewModelProvider)
                            .cancelBooking(
                              rideId: ride.id,
                              bookingId: booking.id,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).tripCancelled,
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Failed to cancel ride. Please try again.',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rebook this route?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.radio_button_checked_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.origin.shortDisplay,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.destination.shortDisplay,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ll be taken to the search screen. Enter this route to find available rides.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ctx.pop();
              context.go(
                AppRoutes.riderRequestRide.path,
                extra: <String, dynamic>{
                  'fromAddress': ride.origin.address,
                  'fromLat': ride.origin.latitude,
                  'fromLng': ride.origin.longitude,
                  'toAddress': ride.destination.address,
                  'toLat': ride.destination.latitude,
                  'toLng': ride.destination.longitude,
                },
              );
            },
            child: Text(
              'Search',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens chat with the driver
  Future<void> _openChat(RideModel ride) async {
    HapticFeedback.lightImpact();

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Text(AppLocalizations.of(context).openingChat),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // Fetch driver profile to get name and photo
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );

      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      // Create or get existing chat - this ensures the Firestore document exists
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: ride.driverId,
          userName1: currentUser.displayName,
          userName2: driverProfile.displayName,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: driverProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      // Hide loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: driverProfile,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).failedToOpenChatValue('Unable to open chat right now.'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Calls the driver using the device phone dialer.
  Future<void> _callDriver(RideModel ride) async {
    HapticFeedback.lightImpact();

    try {
      final driver = await ref.read(userProfileProvider(ride.driverId).future);
      final phoneNumber = driver?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).phoneNumberNotAvailable),
          ),
        );
        return;
      }

      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotMakePhoneCalls),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToLaunchDialer),
        ),
      );
    }
  }
}
