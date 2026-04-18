import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/gamification_widgets.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/rating_and_profile_widgets.dart';
import 'package:sport_connect/core/widgets/safety_widgets.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Profile Screen - Clean carpooling-style design
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});
  final String? userId;

  bool get _isOwnProfile => userId == null;

  int _calculateCompletionFields(UserModel user) {
    var count = 0;
    if (user.displayName.isNotEmpty) count++;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) count++;
    if (user.isPhoneVerified) count++;
    if (user.isEmailVerified) count++;
    return count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = userId != null
        ? ref.watch(currentUserProfileProvider(userId!))
        : ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => _buildContent(context, ref, user),
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (e, _) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).failedToLoadProfile,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).pleaseCheckYourConnectionAnd,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                if (userId != null) {
                  ref.invalidate(currentUserProfileProvider(userId!));
                } else {
                  ref.invalidate(currentUserProvider);
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context).tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserModel? user) {
    if (user == null) {
      return _buildUserNotFoundState(context, ref);
    }

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          pinned: true,
          centerTitle: true,
          leading: _isOwnProfile
              ? null
              : IconButton(
                  tooltip: AppLocalizations.of(context).goBackTooltip,
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.adaptive.arrow_back_rounded,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
          title: Text(
            _isOwnProfile
                ? AppLocalizations.of(context).myProfile
                : AppLocalizations.of(context).navProfile,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            if (_isOwnProfile) ...[
              IconButton(
                tooltip: AppLocalizations.of(context).actionSearch,
                onPressed: () => context.push(AppRoutes.profileSearch.path),
                icon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).navSettings,
                onPressed: () => context.push(AppRoutes.settings.path),
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
            ],
            if (!_isOwnProfile)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.adaptive.more_rounded,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
                onSelected: (value) async {
                  if (value == 'report') {
                    await context.push<void>(
                      AppRoutes.reportIssue.path,
                      extra: {
                        'reportedUserId': userId,
                        'reason': 'User profile report',
                      },
                    );
                  } else if (value == 'block') {
                    _showBlockUserDialog(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 20.sp,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 12.w),
                        Text(AppLocalizations.of(context).reportUser),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_outlined,
                          size: 20.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 12.w),
                        Text(AppLocalizations.of(context).blockUser),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Profile header section
        SliverToBoxAdapter(
          child: _buildProfileHeader(context, user)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // Profile completion progress bar
        if (_isOwnProfile)
          SliverToBoxAdapter(
            child:
                Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ProfileCompletionBar(
                        completedFields: _calculateCompletionFields(user),
                        totalFields: 6,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (_isOwnProfile) SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        // XP & Level progress
        if (_isOwnProfile)
          SliverToBoxAdapter(
            child: _buildXPSection(context, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 90.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (_isOwnProfile) SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // Ride statistics
        SliverToBoxAdapter(
          child: _buildRideStats(context, user)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 16.h)),

        // Drive history transparency card
        if (!_isOwnProfile)
          SliverToBoxAdapter(
            child:
                Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: () {
                        final reliability = ref.watch(
                          userRideReliabilityProvider(userId!),
                        );
                        return DriveHistoryCard(
                          totalRides: user.totalRides,
                          averageRating: user.rating.average,
                          cancelCount: reliability.value?.cancelCount ?? 0,
                          noShowCount: reliability.value?.noShowCount ?? 0,
                          memberSince: user.createdAt ?? DateTime.now(),
                          isVerified: user.isIdVerified,
                        );
                      }(),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (!_isOwnProfile) SliverToBoxAdapter(child: SizedBox(height: 8.h)),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // Quick actions menu
        if (_isOwnProfile)
          SliverToBoxAdapter(
            child: _buildQuickActions(context, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }

  /// Profile header with avatar, name, rating, and member since
  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    final rating = user.rating;
    final memberSince = user.createdAt;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              LevelAvatar(
                name: user.displayName,
                level: user.userLevel.level,
                size: 100,
                imageUrl: user.photoUrl,
              ),
              if (_isOwnProfile)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await context.push<void>(AppRoutes.editProfile.path);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          // Name
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 8.h),

          // Rating and member info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (rating.average > 0) ...[
                GestureDetector(
                  onTap: () => context.push(
                    '${AppRoutes.reviewsList.path.replaceFirst(':userId', user.uid)}'
                    '?userName=${Uri.encodeComponent(user.displayName)}'
                    '${user.photoUrl != null ? '&userPhotoUrl=${Uri.encodeComponent(user.photoUrl!)}' : ''}',
                  ),
                  child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.xpGold,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        rating.average.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                SizedBox(width: 12.w),
              ],
              Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textTertiary,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                memberSince != null
                    ? AppLocalizations.of(
                        context,
                      ).memberSinceValue(_formatDate(memberSince))
                    : AppLocalizations.of(context).newMember,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Location
          if (user.city != null || user.country != null) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textTertiary,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  [
                    user.city,
                    user.country,
                  ].where((e) => e != null && e.isNotEmpty).join(', '),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 20.h),

          // Edit profile button (for own profile)
          if (_isOwnProfile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: AppLocalizations.of(context).settingsEditProfile,
                    icon: Icons.edit_outlined,
                    onPressed: () => context.push(AppRoutes.editProfile.path),
                    style: PremiumButtonStyle.outline,
                    size: ButtonSize.medium,
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: 'Upgrade to Premium',
                    icon: Icons.workspace_premium_rounded,
                    onPressed: () =>
                        context.push(AppRoutes.premiumSubscribe.path),
                    style: PremiumButtonStyle.gradient,
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Ride statistics section
  Widget _buildRideStats(BuildContext context, UserModel user) {
    // Get gamification stats based on user type
    final totalRides = user.totalRides;
    final double totalDistance;
    final int currentStreak;

    switch (user) {
      case RiderModel(:final gamification):
        totalDistance = gamification.totalDistance;
        currentStreak = gamification.currentStreak;
      case DriverModel(:final gamification):
        totalDistance = gamification.totalDistance;
        currentStreak = gamification.currentStreak;
    }

    final String moneyStatValue;
    final String moneyStatLabel;
    final IconData moneyStatIcon;

    if (user.isRider) {
      moneyStatValue = '€${user.asRider!.moneySaved.toStringAsFixed(0)}';
      moneyStatLabel = AppLocalizations.of(context).saved;
      moneyStatIcon = Icons.savings_rounded;
    } else {
      moneyStatValue = '€${user.asDriver!.totalEarnings.toStringAsFixed(0)}';
      moneyStatLabel = AppLocalizations.of(context).earned2;
      moneyStatIcon = Icons.attach_money_rounded;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).rideStatistics,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.route_rounded,
                    value: totalRides.toString(),
                    label: AppLocalizations.of(context).totalRides,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.route_rounded,
                    value: '${totalDistance.toStringAsFixed(0)} km',
                    label: AppLocalizations.of(context).distance,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '$currentStreak',
                    label: AppLocalizations.of(context).dayStreak,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    icon: moneyStatIcon,
                    value: moneyStatValue,
                    label: moneyStatLabel,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// XP & Level section with progress bar and streak
  Widget _buildXPSection(BuildContext context, UserModel user) {
    final level = user.userLevel;
    final totalXP = user.totalXP;
    final int currentStreak;
    switch (user) {
      case RiderModel(:final gamification):
        currentStreak = gamification.currentStreak;
      case DriverModel(:final gamification):
        currentStreak = gamification.currentStreak;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.achievements.path),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.xpGold,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).levelAndXp,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  StreakCounter(
                    days: currentStreak,
                    isActive: currentStreak > 0,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              XPProgressBar(
                currentXP: totalXP,
                maxXP: level.maxXP.isFinite ? level.maxXP.toInt() : totalXP,
                level: level.level,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context).viewAchievements,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick actions menu section
  Widget _buildQuickActions(BuildContext context, UserModel user) {
    final isDriver = user.role == UserRole.driver;
    final menuItems = [
      // Vehicles management is only relevant for drivers
      if (isDriver)
        _MenuItem(
          icon: Icons.directions_car_outlined,
          title: 'My Vehicles',
          subtitle: 'Manage your vehicles',
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.driverVehicles.path),
        ),
      _MenuItem(
        icon: Icons.history_rounded,
        title: 'My Rides',
        subtitle: 'View your ride history',
        color: AppColors.info,
        onTap: () => context.push(
          isDriver ? AppRoutes.driverRides.path : AppRoutes.riderMyRides.path,
        ),
      ),
      _MenuItem(
        icon: Icons.event_rounded,
        title: 'My Events',
        subtitle: 'Created & joined events',
        color: AppColors.primaryLight,
        onTap: () => context.push(AppRoutes.myEvents.path),
      ),
      _MenuItem(
        icon: Icons.emoji_events_outlined,
        title: 'Achievements',
        subtitle: 'View your badges & rewards',
        color: AppColors.xpGold,
        onTap: () => context.push(AppRoutes.achievements.path),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'View your notifications',
        color: AppColors.warning,
        onTap: () => context.push(AppRoutes.notifications.path),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App preferences & privacy',
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRoutes.settings.path),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == menuItems.length - 1;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                      bottom: isLast ? Radius.circular(16.r) : Radius.zero,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 60.w,
                    endIndent: 16.w,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog to block a user
  void _showBlockUserDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).blockUserDialogTitle,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).blockUserDialogTitle),
        content: Text(
          AppLocalizations.of(context).blockUserDialogMessageGeneric,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final currentUser = ref.read(currentUserProvider).value;
                if (currentUser == null) return;
                await ref
                    .read(
                      socialActionsViewModelProvider(
                        currentUser.uid,
                        userId!,
                      ).notifier,
                    )
                    .toggleBlock();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).userBlocked),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  context.pop();
                }
              } on Exception {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).somethingWentWrong,
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context).actionBlock),
          ),
        ],
      ),
    );
  }

  /// User not found state with sync option
  Widget _buildUserNotFoundState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 64.sp,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppLocalizations.of(context).profileNotFound,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).yourProfileDataCouldNot,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            PremiumButton(
              text: AppLocalizations.of(context).syncProfile,
              icon: Icons.refresh_rounded,
              onPressed: () async {
                final authActions = ref.read(authActionsViewModelProvider);
                final currentUser = authActions.currentUser;
                if (currentUser != null) {
                  final profileActions = ref.read(
                    profileActionsViewModelProvider,
                  );
                  final existingUser = await profileActions.getUserById(
                    currentUser.uid,
                  );
                  if (existingUser == null) {
                    // Create new user as rider by default
                    await authActions.createUserDocument(
                      UserModel.rider(
                        uid: currentUser.uid,
                        email: currentUser.email ?? '',
                        displayName: currentUser.displayName ?? 'User',
                        photoUrl: currentUser.photoURL,
                        createdAt: DateTime.now(),
                        lastSeenAt: DateTime.now(),
                      ),
                    );
                  }
                  ref.invalidate(currentUserProvider);
                }
              },
              style: PremiumButtonStyle.gradient,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () async {
                await ref.read(authActionsViewModelProvider).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login.path);
                }
              },
              child: Text(
                AppLocalizations.of(context).signOutTryAgain,
                style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}

class _MenuItem {
  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
