import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/models/user_model.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/core/config/app_router.dart';

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
        error: (e, _) => _buildErrorState(context),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
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
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
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
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
          title: Text(
            _isOwnProfile ? 'My Profile' : 'Profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            if (_isOwnProfile)
              IconButton(
                onPressed: () => context.push(AppRouter.settings),
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 24.sp,
                ),
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
                  onTap: () => context.push(AppRouter.editProfile),
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
                    color: AppColors.xpGold.withOpacity(0.15),
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
                    ? 'Member since ${_formatDate(memberSince)}'
                    : 'New member',
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
                onPressed: () => context.push(AppRouter.editProfile),
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
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
                  'Verified Info',
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
                return Expanded(child: _buildVerificationBadge(item));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(_VerificationItem item) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: item.isVerified
                ? AppColors.success.withOpacity(0.1)
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isVerified ? Icons.check_rounded : item.icon,
            color: item.isVerified ? AppColors.success : AppColors.textTertiary,
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
          item.isVerified ? 'Verified' : 'Not verified',
          style: TextStyle(
            fontSize: 10.sp,
            color: item.isVerified ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ],
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
        moneySaved = gamification.moneySaved;
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
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
                  'Ride Statistics',
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
                    label: 'Total Rides',
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.eco_rounded,
                    value: '${co2Saved.toStringAsFixed(0)}kg',
                    label: 'CO₂ Saved',
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
                    label: 'Day Streak',
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
                        : user.maybeDriver != null
                        ? '€${user.asDriver.gamification.totalEarnings.toStringAsFixed(0)}'
                        : '€0',
                    label: moneySaved != null ? 'Saved' : 'Earned',
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
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
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
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
                  'About',
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
      _MenuItem(
        icon: Icons.directions_car_outlined,
        title: 'My Vehicles',
        subtitle: 'Manage your vehicles',
        color: AppColors.primary,
        onTap: () => context.push(AppRouter.vehicles),
      ),
      _MenuItem(
        icon: Icons.history_rounded,
        title: 'My Rides',
        subtitle: 'View your ride history',
        color: AppColors.info,
        onTap: () => context.push(
          isDriver ? AppRouter.driverMyRides : AppRouter.riderMyRides,
        ),
      ),
      _MenuItem(
        icon: Icons.emoji_events_outlined,
        title: 'Achievements',
        subtitle: 'View your badges & rewards',
        color: AppColors.xpGold,
        onTap: () => context.push(AppRouter.achievements),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'View your notifications',
        color: AppColors.warning,
        onTap: () => context.push(AppRouter.notifications),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App preferences & privacy',
        color: AppColors.textSecondary,
        onTap: () => context.push(AppRouter.settings),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
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
                              color: item.color.withOpacity(0.1),
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
                    color: AppColors.border.withOpacity(0.5),
                  ),
              ],
            );
          }).toList(),
        ),
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
                color: AppColors.warning.withOpacity(0.1),
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
              'Profile Not Found',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your profile data could not be loaded.\nThis may happen if you\'re a new user.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            PremiumButton(
              text: 'Sync Profile',
              icon: Icons.refresh_rounded,
              onPressed: () async {
                final authRepo = ref.read(authRepositoryProvider);
                final currentUser = authRepo.currentUser;
                if (currentUser != null) {
                  final profileRepo = ref.read(profileRepositoryProvider);
                  final existingUser = await profileRepo.getUserById(
                    currentUser.uid,
                  );
                  if (existingUser == null) {
                    // Create new user as rider by default
                    await authRepo.createUserDocument(
                      RiderModel(
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
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              },
              child: Text(
                'Sign out & try again',
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
