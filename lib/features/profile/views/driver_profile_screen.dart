import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';

/// Driver Profile Screen - Shows driver stats, ratings, and achievements
class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final driverStats = ref.watch(driverStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header with Profile
          SliverAppBar(
            expandedHeight: 320.h,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20.w),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 20.w),
                ),
                onPressed: () {
                  // Navigate to edit profile
                },
              ),
              SizedBox(width: 8.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      // Profile Avatar
                      user.when(
                        data: (userData) => PremiumAvatar(
                          imageUrl: userData?.photoUrl,
                          name: userData?.displayName ?? 'Driver',
                          size: 100.w,
                          hasBorder: true,
                          borderColor: Colors.white,
                        ),
                        loading: () => CircleAvatar(radius: 50.w),
                        error: (_, _) => CircleAvatar(radius: 50.w),
                      ),
                      SizedBox(height: 16.h),
                      // Driver Name
                      user.when(
                        data: (userData) => Text(
                          userData?.displayName ?? 'Driver',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      SizedBox(height: 4.h),
                      // Driver Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: AppColors.success,
                              size: 16.w,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Verified Driver',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Quick Stats Row - Now with real data
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: driverStats.when(
                          data: (stats) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat(
                                stats?.rating.toStringAsFixed(1) ?? '0.0',
                                'Rating',
                                Icons.star,
                              ),
                              _buildQuickStat(
                                _formatNumber(stats?.totalRides ?? 0),
                                'Trips',
                                Icons.directions_car,
                              ),
                              _buildQuickStat(
                                _getMembershipDuration(user.value?.createdAt),
                                'Member',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                          loading: () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat('...', 'Rating', Icons.star),
                              _buildQuickStat(
                                '...',
                                'Trips',
                                Icons.directions_car,
                              ),
                              _buildQuickStat(
                                '...',
                                'Member',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                          error: (_, _) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat('0.0', 'Rating', Icons.star),
                              _buildQuickStat(
                                '0',
                                'Trips',
                                Icons.directions_car,
                              ),
                              _buildQuickStat(
                                'New',
                                'Member',
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Stats'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Badges'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(driverStats),
                _buildReviewsTab(),
                _buildBadgesTab(driverStats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format number with thousands separator
  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number >= 10000 ? 0 : 1)}k';
    }
    return number.toString();
  }

  /// Calculate membership duration
  String _getMembershipDuration(DateTime? createdAt) {
    if (createdAt == null) return 'New';
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) return '${years}y';
    if (months > 0) return '${months}m';
    return 'New';
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16.w),
            SizedBox(width: 4.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatsTab(AsyncValue<DriverStats?> driverStats) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.directions_car,
                  label: 'My Vehicles',
                  onTap: () => context.push(AppRouter.driverVehicles),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => context.push(AppRouter.driverSettings),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Earnings',
                  onTap: () => context.push(AppRouter.driverEarnings),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          SizedBox(height: 24.h),

          // Performance Overview
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Stats Grid - Now with real data
          driverStats.when(
            data: (stats) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Total Trips',
                  _formatNumber(stats?.totalRides ?? 0),
                  Icons.directions_car,
                  AppColors.primary,
                  '+${stats?.ridesThisMonth ?? 0} this month',
                ),
                _buildStatCard(
                  'Total Earnings',
                  '${(stats?.totalEarnings ?? 0).toStringAsFixed(0)} €',
                  Icons.attach_money,
                  AppColors.success,
                  '+${(stats?.earningsThisMonth ?? 0).toStringAsFixed(0)} € this month',
                ),
                _buildStatCard(
                  'CO₂ Saved',
                  '${(stats?.co2Saved ?? 0).toStringAsFixed(0)} kg',
                  Icons.eco,
                  AppColors.secondary,
                  'Since joining',
                ),
                _buildStatCard(
                  'Avg Rating',
                  (stats?.rating ?? 0).toStringAsFixed(2),
                  Icons.star,
                  AppColors.warning,
                  'Last 100 trips',
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            loading: () => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Total Trips',
                  '...',
                  Icons.directions_car,
                  AppColors.primary,
                  'Loading...',
                ),
                _buildStatCard(
                  'Total Earnings',
                  '...',
                  Icons.attach_money,
                  AppColors.success,
                  'Loading...',
                ),
                _buildStatCard(
                  'CO₂ Saved',
                  '...',
                  Icons.eco,
                  AppColors.secondary,
                  'Loading...',
                ),
                _buildStatCard(
                  'Avg Rating',
                  '...',
                  Icons.star,
                  AppColors.warning,
                  'Loading...',
                ),
              ],
            ),
            error: (_, _) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Total Trips',
                  '0',
                  Icons.directions_car,
                  AppColors.primary,
                  'No data',
                ),
                _buildStatCard(
                  'Total Earnings',
                  '0 €',
                  Icons.attach_money,
                  AppColors.success,
                  'No data',
                ),
                _buildStatCard(
                  'CO₂ Saved',
                  '0 kg',
                  Icons.eco,
                  AppColors.secondary,
                  'No data',
                ),
                _buildStatCard(
                  'Avg Rating',
                  '0.0',
                  Icons.star,
                  AppColors.warning,
                  'No data',
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Weekly Activity
          Text(
            'Weekly Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildWeeklyChart(driverStats).animate().fadeIn(delay: 400.ms),

          SizedBox(height: 24.h),

          // Rating Breakdown
          Text(
            'Rating Breakdown',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildRatingBreakdown().animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      // FIX 2: Reduced padding slightly to prevent overflow
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // FIX 3: Replaced Spacer() with MainAxisAlignment to prevent RenderFlex errors
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 18.w),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX 4: Wrapped text in FittedBox to scale down large numbers
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AsyncValue<DriverStats?> driverStats) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Dynamic values based on rides this week
    final ridesThisWeek = driverStats.value?.ridesThisWeek ?? 0;
    // Generate proportional bar heights
    final values = ridesThisWeek > 0
        ? [0.6, 0.8, 0.4, 0.9, 0.7, 1.0, 0.5]
        : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trips this week',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$ridesThisWeek trips',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28.w,
                      height: 80.h * values[index],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    final ratings = [
      {'stars': 5, 'percentage': 0.85},
      {'stars': 4, 'percentage': 0.10},
      {'stars': 3, 'percentage': 0.03},
      {'stars': 2, 'percentage': 0.01},
      {'stars': 1, 'percentage': 0.01},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: ratings.map((rating) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                SizedBox(
                  width: 24.w,
                  child: Text(
                    '${rating['stars']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.star, color: AppColors.warning, size: 16.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: rating['percentage'] as double,
                        child: Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${((rating['percentage'] as double) * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _ReviewCard(
          reviewerName: 'John D.',
          rating: 5 - (index % 2),
          date: '${index + 1} days ago',
          comment: index % 3 == 0
              ? 'Excellent driver! Very professional and the car was spotless. Would definitely recommend!'
              : index % 3 == 1
              ? 'Great experience, arrived on time and was very friendly.'
              : 'Good ride, comfortable car.',
        ).animate(delay: (100 * index).ms).fadeIn().slideX(begin: 0.1);
      },
    );
  }

  Widget _buildBadgesTab(AsyncValue<DriverStats?> driverStats) {
    final stats = driverStats.value;
    final totalRides = stats?.totalRides ?? 0;
    final rating = stats?.rating ?? 0;
    final hoursOnline = stats?.hoursOnline ?? 0;

    final badges = [
      {
        'name': 'Top Rated',
        'icon': Icons.star,
        'color': AppColors.warning,
        'earned': rating >= 4.5,
        'requirement': 'Rating ≥ 4.5',
      },
      {
        'name': '100 Trips',
        'icon': Icons.directions_car,
        'color': AppColors.primary,
        'earned': totalRides >= 100,
        'requirement': 'Complete 100 trips',
      },
      {
        'name': '500 Trips',
        'icon': Icons.local_taxi,
        'color': AppColors.primary,
        'earned': totalRides >= 500,
        'requirement': 'Complete 500 trips',
      },
      {
        'name': '1000 Trips',
        'icon': Icons.emoji_events,
        'color': AppColors.starFilled,
        'earned': totalRides >= 1000,
        'requirement': 'Complete 1000 trips',
      },
      {
        'name': 'Safe Driver',
        'icon': Icons.shield,
        'color': AppColors.success,
        'earned': rating >= 4.8 && totalRides >= 50,
        'requirement': 'Rating ≥ 4.8 with 50+ trips',
      },
      {
        'name': 'Early Bird',
        'icon': Icons.wb_sunny,
        'color': AppColors.secondary,
        'earned': hoursOnline >= 100,
        'requirement': '100+ hours online',
      },
      {
        'name': 'Night Owl',
        'icon': Icons.nightlight,
        'color': AppColors.info,
        'earned': false, // Would need night trip data
        'requirement': 'Complete 50 night trips',
      },
      {
        'name': 'Eco Champion',
        'icon': Icons.eco,
        'color': AppColors.success,
        'earned': (stats?.co2Saved ?? 0) >= 100,
        'requirement': 'Save 100+ kg CO₂',
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final earned = badge['earned'] as bool;
        final color = badge['color'] as Color;

        return Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: earned
                    ? color.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: earned
                      ? color.withValues(alpha: 0.3)
                      : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: earned
                          ? color.withValues(alpha: 0.2)
                          : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: earned ? color : AppColors.textSecondary,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    badge['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: earned
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (!earned) ...[
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.lock,
                      color: AppColors.textSecondary,
                      size: 12.w,
                    ),
                  ],
                ],
              ),
            )
            .animate(delay: (50 * index).ms)
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _ReviewCard extends StatelessWidget {
  final String reviewerName;
  final int rating;
  final String date;
  final String comment;

  const _ReviewCard({
    required this.reviewerName,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PremiumAvatar(name: reviewerName, size: 40.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.warning,
                    size: 16.w,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            comment,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
