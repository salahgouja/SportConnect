import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/payments/views/driver_earnings_screen.dart';
import 'package:sport_connect/features/profile/views/driver_profile_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_offer_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_search_screen.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_router.dart';

/// Driver Home Screen - Modern dashboard for carpooling drivers
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _getCurrentScreen(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withAlpha(15),
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: GNav(
            rippleColor: AppColors.primary.withAlpha(25),
            hoverColor: AppColors.primary.withAlpha(25),
            haptic: true,
            tabBorderRadius: 16.r,
            curve: Curves.easeOutExpo,
            duration: const Duration(milliseconds: 400),
            gap: 6,
            color: AppColors.textTertiary,
            activeColor: AppColors.primary,
            iconSize: 20.sp,
            tabBackgroundColor: AppColors.primary.withAlpha(25),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
            },
            tabs: [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
                textStyle: _navTextStyle,
              ),
              GButton(
                icon: Icons.search_rounded,
                text: 'Browse',
                textStyle: _navTextStyle,
              ),
              GButton(
                icon: Icons.add_road_rounded,
                text: 'Offer',
                textStyle: _navTextStyle,
              ),
              GButton(
                icon: Icons.account_balance_wallet_outlined,
                iconActiveColor: AppColors.success,
                text: 'Earnings',
                textStyle: _navTextStyle.copyWith(color: AppColors.success),
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
                textStyle: _navTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _navTextStyle => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => setState(() => _currentIndex = 2),
      backgroundColor: AppColors.primary,
      elevation: 4,
      icon: Icon(Icons.add_rounded, size: 22.sp, color: Colors.white),
      label: Text(
        'Offer Ride',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _DriverDashboard();
      case 1:
        return const RideSearchScreen();
      case 2:
        return const DriverOfferRideScreen();
      case 3:
        return const DriverEarningsScreen();
      case 4:
        return const DriverProfileScreen();
      default:
        return _DriverDashboard();
    }
  }
}

/// Main Dashboard Widget
class _DriverDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final driverStats = ref.watch(driverStatsProvider);
    final pendingRequests = ref.watch(pendingRideRequestsProvider);
    final upcomingRides = ref.watch(upcomingDriverRidesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(driverStatsProvider);
        ref.invalidate(pendingRideRequestsProvider);
        ref.invalidate(upcomingDriverRidesProvider);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverToBoxAdapter(child: _buildHeader(context, ref, user)),

          // Online Status Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildOnlineStatus(ref, driverStats),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildQuickActions(context),
            ),
          ),

          // Earnings Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildEarningsSummary(driverStats),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildStatsRow(driverStats),
            ),
          ),

          // Pending Requests
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildPendingRequests(context, ref, pendingRequests),
            ),
          ),

          // Upcoming Rides
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: _buildUpcomingRides(context, upcomingRides),
            ),
          ),

          // Bottom spacing
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> user,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withAlpha(15), AppColors.background],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => context.push(AppRouter.profile),
            child: user.when(
              data: (userData) => PremiumAvatar(
                imageUrl: userData?.photoUrl,
                name: userData?.displayName ?? 'Driver',
                size: 52.w,
                hasBorder: true,
              ),
              loading: () => CircleAvatar(radius: 26.w),
              error: (_, _) => CircleAvatar(radius: 26.w),
            ),
          ),
          SizedBox(width: 14.w),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                user.when(
                  data: (userData) => Text(
                    userData?.displayName ?? 'Driver',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  loading: () =>
                      Text('Loading...', style: TextStyle(fontSize: 20.sp)),
                  error: (_, _) =>
                      Text('Driver', style: TextStyle(fontSize: 20.sp)),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            onPressed: () => context.push(AppRouter.notifications),
            icon: Badge(
              smallSize: 8.w,
              backgroundColor: AppColors.error,
              child: Icon(
                Icons.notifications_outlined,
                size: 26.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRouter.chat),
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 24.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  Widget _buildOnlineStatus(WidgetRef ref, AsyncValue<DriverStats> stats) {
    return stats.when(
      data: (driverStats) {
        final isOnline = driverStats.isOnline;
        return GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            final user = ref.read(currentUserProvider).value;
            if (user != null) {
              await ref
                  .read(driverStatsRepositoryProvider)
                  .setOnlineStatus(user.uid, !isOnline);
            }
          },
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: isOnline
                  ? LinearGradient(
                      colors: [
                        AppColors.success.withAlpha(30),
                        AppColors.success.withAlpha(10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isOnline ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isOnline
                    ? AppColors.success.withAlpha(60)
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppColors.success
                        : AppColors.textTertiary,
                    shape: BoxShape.circle,
                    boxShadow: isOnline
                        ? [
                            BoxShadow(
                              color: AppColors.success.withAlpha(60),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isOnline ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isOnline
                            ? 'Accepting ride requests'
                            : 'Tap to go online and start earning',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.touch_app_rounded,
                  color: isOnline
                      ? AppColors.success.withAlpha(150)
                      : AppColors.textTertiary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
      },
      loading: () => _buildLoadingCard(),
      error: (_, _) => _buildErrorCard('Failed to load status'),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_road_rounded,
            label: 'Create Ride',
            color: AppColors.primary,
            onTap: () => context.push(AppRouter.createRide),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.directions_car_rounded,
            label: 'My Vehicles',
            color: AppColors.secondary,
            onTap: () => context.push(AppRouter.driverVehicles),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history_rounded,
            label: 'History',
            color: AppColors.info,
            onTap: () => context.push(AppRouter.driverMyRides),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildEarningsSummary(AsyncValue<DriverStats> stats) {
    return stats.when(
      data: (driverStats) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(50),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Earnings",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${driverStats.earningsToday.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    '${driverStats.ridesCompleted} rides',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Weekly progress
            Row(
              children: [
                _EarningsMetric(
                  label: 'This Week',
                  value: '€${driverStats.earningsThisWeek.toStringAsFixed(0)}',
                ),
                SizedBox(width: 24.w),
                _EarningsMetric(
                  label: 'This Month',
                  value: '€${driverStats.earningsThisMonth.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),
      loading: () => _buildLoadingCard(),
      error: (_, _) => _buildErrorCard('Failed to load earnings'),
    );
  }

  Widget _buildStatsRow(AsyncValue<DriverStats> stats) {
    return stats.when(
      data: (driverStats) => Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              iconColor: AppColors.starFilled,
              value: driverStats.rating > 0
                  ? driverStats.rating.toStringAsFixed(1)
                  : '—',
              label: 'Rating',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.route_rounded,
              iconColor: AppColors.primary,
              value: '${driverStats.totalRides}',
              label: 'Total Rides',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.eco_rounded,
              iconColor: AppColors.success,
              value: '${driverStats.co2Saved.toStringAsFixed(0)}kg',
              label: 'CO₂ Saved',
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
      loading: () => Row(
        children: List.generate(
          3,
          (_) => Expanded(child: _buildLoadingStatCard()),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPendingRequests(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<RideRequest>> requestsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ride Requests',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRouter.driverRequests),
              icon: Icon(Icons.arrow_forward_ios, size: 14.sp),
              label: Text(
                'View All',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return _buildEmptyState(
                icon: Icons.inbox_outlined,
                title: 'No pending requests',
                subtitle: 'New ride requests will appear here',
              );
            }
            return Column(
              children: requests.take(2).map((request) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _RequestCard(
                    request: request,
                    onAccept: () async {
                      HapticFeedback.heavyImpact();
                      await ref
                          .read(driverStatsRepositoryProvider)
                          .acceptRequest(request.rideId, request.id);
                    },
                    onDecline: () async {
                      HapticFeedback.lightImpact();
                      await ref
                          .read(driverStatsRepositoryProvider)
                          .declineRequest(request.rideId, request.id);
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (_, _) => _buildErrorCard('Failed to load requests'),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildUpcomingRides(
    BuildContext context,
    AsyncValue<List<RideModel>> ridesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Rides',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ridesAsync.when(
          data: (rides) {
            if (rides.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available_outlined,
                title: 'No upcoming rides',
                subtitle: 'Create a ride to start earning',
              );
            }
            return Column(
              children: rides.take(3).map((ride) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _UpcomingRideCard(
                    ride: ride,
                    onTap: () =>
                        context.push(AppRouter.rideDetailPath(ride.id)),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => _buildLoadingCard(),
          error: (_, _) => _buildErrorCard('Failed to load rides'),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      height: 90.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(25),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32.sp, color: AppColors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============ Helper Widgets ============

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsMetric extends StatelessWidget {
  final String label;
  final String value;

  const _EarningsMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white.withAlpha(180)),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RideRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Passenger info
          Row(
            children: [
              PremiumAvatar(name: request.passengerName, size: 44.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passengerName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.starFilled,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          request.passengerRating > 0
                              ? request.passengerRating.toStringAsFixed(1)
                              : 'New',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.event_seat,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${request.seatsRequested} seat${request.seatsRequested > 1 ? 's' : ''}',
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '€${(request.pricePerSeat * request.seatsRequested).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Route info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(width: 1, height: 20.h, color: AppColors.border),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.error,
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
                        request.fromLocation,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        request.toLocation,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
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
          ),
          SizedBox(height: 12.h),
          // Time
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                DateFormat('EEE, MMM d • h:mm a').format(request.requestedDate),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingRideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;

  const _UpcomingRideCard({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date box
            Container(
              width: 56.w,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(ride.departureTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(ride.departureTime),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            // Ride info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
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
                        Icons.people_outline,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${ride.bookedSeats}/${ride.availableSeats}',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${(ride.pricePerSeat * ride.bookedSeats).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'earned',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
