import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/user_providers.dart';

/// Profile Screen - Clean carpooling-style design
class ProfileScreen extends ConsumerWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  bool get _isOwnProfile => userId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = userId != null
        ? ref.watch(userStreamProvider(userId!))
        : ref.watch(currentUserStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => _buildContent(context, ref, user),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
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
                  ref.invalidate(userStreamProvider(userId!));
                } else {
                  ref.invalidate(currentUserStreamProvider);
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
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
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
            if (_isOwnProfile)
              IconButton(
                tooltip: 'Settings',
                onPressed: () => context.push(AppRoutes.settings.path),
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
              ),
            if (!_isOwnProfile)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
                onSelected: (value) {
                  if (value == 'report') {
                    context.push(
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
                        const Text('Report User'),
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
                        const Text('Block User'),
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

        // Verification badges
        SliverToBoxAdapter(
          child: _buildVerificationSection(context, user)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // Ride statistics
        SliverToBoxAdapter(
          child: _buildRideStats(context, user)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 24.h)),

        // About section
        if (user.bio != null && user.bio!.isNotEmpty)
          SliverToBoxAdapter(
            child: _buildAboutSection(context, user)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.1, curve: Curves.easeOutCubic),
          ),

        if (user.bio != null && user.bio!.isNotEmpty)
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
                  onTap: () => context.push(AppRoutes.editProfile.path),
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
                Container(
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
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: 'Edit Profile',
                icon: Icons.edit_outlined,
                onPressed: () => context.push(AppRoutes.editProfile.path),
                style: PremiumButtonStyle.outline,
                size: ButtonSize.medium,
              ),
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

  /// Verification badges section
  Widget _buildVerificationSection(BuildContext context, UserModel user) {
    final verifications = <_VerificationItem>[
      _VerificationItem(
        icon: Icons.email_outlined,
        label: 'Email',
        isVerified: user.isEmailVerified,
      ),
      _VerificationItem(
        icon: Icons.phone_outlined,
        label: 'Phone',
        isVerified: user.isPhoneVerified,
      ),
      _VerificationItem(
        icon: Icons.badge_outlined,
        label: 'ID',
        isVerified: user.isIdVerified,
      ),
    ];

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
                  Icons.verified_user_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).verifiedInfo,
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
              children: verifications.map((item) {
                return Expanded(child: _buildVerificationBadge(context, item));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(BuildContext context, _VerificationItem item) {
    return Semantics(
      label: '${item.label}: ${item.isVerified ? 'verified' : 'not verified'}',
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: item.isVerified
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isVerified ? Icons.check_rounded : item.icon,
              color: item.isVerified
                  ? AppColors.success
                  : AppColors.textTertiary,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: item.isVerified
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            item.isVerified
                ? AppLocalizations.of(context).verified
                : AppLocalizations.of(context).notVerified,
            style: TextStyle(
              fontSize: 12.sp,
              color: item.isVerified
                  ? AppColors.success
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Ride statistics section
  Widget _buildRideStats(BuildContext context, UserModel user) {
    // Get gamification stats based on user type
    final int totalRides = user.totalRides;
    final double co2Saved;
    final int currentStreak;
    final double? moneySaved; // Only available for riders

    switch (user) {
      case RiderModel(:final gamification):
        co2Saved = gamification.co2Saved;
        currentStreak = gamification.currentStreak;
        moneySaved = null;
      case DriverModel(:final gamification):
        co2Saved = gamification.co2Saved;
        currentStreak = gamification.currentStreak;
        moneySaved = null; // Drivers have totalEarnings instead
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
                    icon: Icons.eco_rounded,
                    value: '${co2Saved.toStringAsFixed(0)}kg',
                    label: AppLocalizations.of(context).coSaved,
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
                    icon: moneySaved != null
                        ? Icons.savings_rounded
                        : Icons.attach_money_rounded,
                    value: moneySaved != null
                        ? '€${moneySaved.toStringAsFixed(0)}'
                        : user.asDriver != null
                        ? '€${user.asDriver!.totalEarnings.toStringAsFixed(0)}'
                        : '€0',
                    label: moneySaved != null
                        ? AppLocalizations.of(context).saved
                        : AppLocalizations.of(context).earned2,
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

  /// About section with bio
  Widget _buildAboutSection(BuildContext context, UserModel user) {
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
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context).settingsAbout,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              user.bio!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
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
          onTap: () => context.push(AppRoutes.vehicles.path),
        ),
      _MenuItem(
        icon: Icons.history_rounded,
        title: 'My Rides',
        subtitle: 'View your ride history',
        color: AppColors.info,
        onTap: () => context.push(
          isDriver ? AppRoutes.driverMyRides.path : AppRoutes.riderMyRides.path,
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
          'Are you sure you want to block this user? '
          'You will no longer see their content or receive messages from them.',
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
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('blockedUsers')
                    .doc(userId)
                    .set({'blockedAt': FieldValue.serverTimestamp()});
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User has been blocked.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
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
            child: const Text('Block'),
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
              text: 'Sync Profile',
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
                  ref.invalidate(currentUserStreamProvider);
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

class _VerificationItem {
  final IconData icon;
  final String label;
  final bool isVerified;

  _VerificationItem({
    required this.icon,
    required this.label,
    required this.isVerified,
  });
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
