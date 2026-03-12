import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Premium Achievements Screen with gamification UI
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, user!),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(AppLocalizations.of(context).errorLoadingAchievements),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user) {
    // Get gamification stats based on user type
    final GamificationStats gamification = switch (user) {
      RiderModel(:final gamification) => gamification,
      DriverModel(:final gamification) => gamification,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 280.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              tooltip: 'Go back',
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
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
                      // Level Badge
                      _buildLevelBadge(gamification),
                      SizedBox(height: 16.h),
                      // XP Progress
                      _buildXPProgress(gamification),
                      SizedBox(height: 12.h),
                      // Stats Row
                      _buildStatsRow(gamification),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.h),
              child: Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Badges'),
                    Tab(text: 'Challenges'),
                    Tab(text: 'Leaderboard'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBadgesTab(gamification),
            _buildChallengesTab(gamification),
            _buildLeaderboardTab(user),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(GamificationStats gamification) {
    final userLevel = UserLevel.fromXP(gamification.totalXP);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF52B788), Color(0xFF40916C)],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF52B788).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            AppLocalizations.of(context).levelValueValue(userLevel.level, userLevel.name),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgress(GamificationStats gamification) {
    final userLevel = UserLevel.fromXP(gamification.totalXP);
    final currentXP = gamification.totalXP - userLevel.minXP.toInt();
    final isMaxLevel = !userLevel.maxXP.isFinite;
    final maxXP = isMaxLevel
        ? currentXP  // At max level, show full bar
        : (userLevel.maxXP - userLevel.minXP).toInt();
    final xpNeeded = isMaxLevel ? 0 : (maxXP - currentXP).clamp(0, maxXP);
    final progress = isMaxLevel ? 1.0 : (maxXP > 0 ? (currentXP / maxXP).clamp(0.0, 1.0) : 1.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).valueXp2(_formatNumber(currentXP)),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                isMaxLevel
                    ? '★ MAX'
                    : AppLocalizations.of(context).valueXp2(_formatNumber(maxXP)),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Stack(
            children: [
              Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF74C69D), Color(0xFF40916C)],
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            isMaxLevel
                ? AppLocalizations.of(context).maxLevel
                : AppLocalizations.of(context).valueXpToLevelValue(
                    _formatNumber(xpNeeded),
                    userLevel.level + 1,
                  ),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(GamificationStats gamification) {
    final badges = gamification.unlockedBadges.length;
    final challenges = gamification.achievements
        .where((a) => a.isUnlocked)
        .length;
    final rides = gamification.totalRides;
    final distance = gamification.totalDistance;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Icons.emoji_events_rounded,
            AppLocalizations.of(context).value2(badges),
            AppLocalizations.of(context).badges,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.track_changes_rounded,
            AppLocalizations.of(context).value2(challenges),
            AppLocalizations.of(context).challenges,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.directions_car_rounded,
            AppLocalizations.of(context).value2(rides),
            AppLocalizations.of(context).navRides,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.route_rounded,
            '${distance.toStringAsFixed(0)} km',
            'Distance',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: Colors.white),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40.h,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildBadgesTab(GamificationStats gamification) {
    // Define badge definitions with unlock criteria
    final badges = _getBadgeDefinitions(gamification);

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _buildBadgeCard(badges[index]),
    );
  }

  Widget _buildBadgeCard(_BadgeData badge) {
    final tierColors = {
      'bronze': const Color(0xFFB7E4C7),
      'silver': const Color(0xFF95D5B2),
      'gold': const Color(0xFF74C69D),
      'platinum': const Color(0xFF40916C),
      'diamond': const Color(0xFF2D6A4F),
    };

    final color = tierColors[badge.tier] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            if (badge.unlocked)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? color.withValues(alpha: 0.15)
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    color: badge.unlocked ? color : AppColors.textSecondary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: badge.unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!badge.unlocked && badge.progress != null) ...[
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: LinearProgressIndicator(
                      value: badge.progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 3.h,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ],
            ),
            if (badge.unlocked)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 16.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(_BadgeData badge) {
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: badge.unlocked
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.secondary.withValues(alpha: 0.2),
                        ],
                      )
                    : null,
                color: badge.unlocked ? null : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 48.sp,
                color: badge.unlocked
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              badge.name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badge.unlocked
                    ? AppLocalizations.of(context).unlocked
                    : AppLocalizations.of(context).locked,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: badge.unlocked ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
            if (!badge.unlocked && badge.progress != null) ...[
              SizedBox(height: 16.h),
              Column(
                children: [
                  LinearProgressIndicator(
                    value: badge.progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueComplete((badge.progress! * 100).toInt()),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesTab(GamificationStats gamification) {
    final l10n = AppLocalizations.of(context);
    final totalRides = gamification.totalRides;
    final totalDistance = gamification.totalDistance;
    final currentStreak = gamification.currentStreak;

    String status(bool done) =>
        done ? l10n.challengeCompleted : l10n.challengeInProgress;

    final challenges = [
      _ChallengeData(
        l10n.challengeFirstRide,
        l10n.challengeFirstRideDesc,
        '${totalRides.clamp(0, 1)}/1',
        totalRides >= 1 ? 1.0 : 0.0,
        50,
        Icons.directions_car_rounded,
        status(totalRides >= 1),
      ),
      _ChallengeData(
        l10n.challengeRideRegular,
        l10n.challengeRideRegularDesc,
        '${totalRides.clamp(0, 10)}/10',
        (totalRides / 10).clamp(0.0, 1.0),
        100,
        Icons.calendar_today_rounded,
        status(totalRides >= 10),
      ),
      _ChallengeData(
        l10n.challengeRoadTripper,
        l10n.challengeRoadTripperDesc,
        '${totalDistance.toStringAsFixed(0)}/50',
        (totalDistance / 50).clamp(0.0, 1.0),
        250,
        Icons.map_rounded,
        status(totalDistance >= 50),
      ),
      _ChallengeData(
        l10n.challengeDistanceMaster,
        l10n.challengeDistanceMasterDesc,
        '${totalDistance.toStringAsFixed(0)}/100',
        (totalDistance / 100).clamp(0.0, 1.0),
        150,
        Icons.route_rounded,
        status(totalDistance >= 100),
      ),
      _ChallengeData(
        l10n.challengeStreakBuilder,
        l10n.challengeStreakBuilderDesc,
        '$currentStreak/7',
        (currentStreak / 7).clamp(0.0, 1.0),
        200,
        Icons.local_fire_department_rounded,
        status(currentStreak >= 7),
      ),
      _ChallengeData(
        l10n.challengeCenturyRider,
        l10n.challengeCenturyRiderDesc,
        '${totalRides.clamp(0, 100)}/100',
        (totalRides / 100).clamp(0.0, 1.0),
        500,
        Icons.emoji_events_rounded,
        status(totalRides >= 100),
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: challenges.length,
      itemBuilder: (context, index) => _buildChallengeCard(challenges[index]),
    );
  }

  Widget _buildChallengeCard(_ChallengeData challenge) {
    final isCompleted = challenge.progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: isCompleted
            ? Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  challenge.icon,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF52B788).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AppLocalizations.of(context).valueXp(challenge.xpReward),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF40916C),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    challenge.timeLeft,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                    minHeight: 6.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                challenge.progressText,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(UserModel user) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_rounded,
                    size: 64.sp, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noResultsFound,
                  style: TextStyle(
                      fontSize: 16.sp, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: entries.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildLeaderboardHeader(entries, user);
            }
            final entry = entries[index - 1];
            return _buildLeaderboardRow(_LeaderboardEntry(
              entry.displayName,
              entry.totalXP,
              entry.rank,
              level: entry.level,
              isCurrentUser: entry.odid == user.uid,
            ));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context).errorLoadingAchievements,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildLeaderboardHeader(
      List<LeaderboardEntry> entries, UserModel user) {
    // Need at least 3 entries for the podium
    if (entries.length < 3) {
      return SizedBox(height: 16.h);
    }

    final medals = ['🥈', '🥇', '🥉'];
    final top3 = entries.take(3).toList();
    // Display order: 2nd, 1st, 3rd
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTopRanker(
            medals[0],
            top3[1].displayName,
            AppLocalizations.of(context).valueXp2(
                _formatNumber(top3[1].totalXP)),
            2,
          ),
          _buildTopRanker(
            medals[1],
            top3[0].displayName,
            AppLocalizations.of(context).valueXp2(
                _formatNumber(top3[0].totalXP)),
            1,
            isFirst: true,
          ),
          _buildTopRanker(
            medals[2],
            top3[2].displayName,
            AppLocalizations.of(context).valueXp2(
                _formatNumber(top3[2].totalXP)),
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildTopRanker(
    String medal,
    String name,
    String xp,
    int rank, {
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (!isFirst) SizedBox(height: 20.h),
        Text(medal, style: TextStyle(fontSize: isFirst ? 40.sp : 32.sp)),
        SizedBox(height: 8.h),
        Container(
          width: isFirst ? 60.w : 50.w,
          height: isFirst ? 60.w : 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                fontSize: isFirst ? 24.sp : 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          xp,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(_LeaderboardEntry entry) {
    final isTop3 = entry.rank <= 3;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: entry.isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32.w,
            child: isTop3
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: [
                        const Color(0xFF2D6A4F),
                        const Color(0xFF40916C),
                        const Color(0xFF74C69D),
                      ][entry.rank - 1].withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '#${entry.rank}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: [
                          const Color(0xFF1B4332),
                          const Color(0xFF2D6A4F),
                          const Color(0xFF40916C),
                        ][entry.rank - 1],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context).value3(entry.rank),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.isCurrentUser
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Text(
                entry.name[0],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: entry.isCurrentUser ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  UserLevel.fromXP(entry.xp).name,
                  style: TextStyle(
                    fontSize: 12.sp,
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
                AppLocalizations.of(context).valueXp2(
                  entry.xp.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper method to format numbers with commas
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// Get badge definitions with unlocked status based on gamification data
  List<_BadgeData> _getBadgeDefinitions(GamificationStats gamification) {
    final totalRides = gamification.totalRides;
    final totalDistance = gamification.totalDistance;
    final longestStreak = gamification.longestStreak;
    final unlockedBadges = gamification.unlockedBadges;

    return [
      _BadgeData(
        'First Ride',
        'Complete your first carpool ride',
        Icons.directions_car_rounded,
        totalRides >= 1 || unlockedBadges.contains('first_ride'),
        'bronze',
      ),
      _BadgeData(
        'Social Butterfly',
        'Connect with 10 riders',
        Icons.people_rounded,
        unlockedBadges.contains('social_butterfly'),
        'silver',
      ),
      _BadgeData(
        'Road Tripper',
        'Travel 50 km total',
        Icons.map_rounded,
        totalDistance >= 50 || unlockedBadges.contains('road_tripper'),
        'gold',
        totalDistance < 50 ? totalDistance / 50 : null,
      ),
      _BadgeData(
        'Speed Demon',
        'Maintain a 7-day ride streak',
        Icons.speed_rounded,
        longestStreak >= 7 || unlockedBadges.contains('speed_demon'),
        'gold',
      ),
      _BadgeData(
        'Perfect Score',
        'Maintain 5-star rating',
        Icons.star_rounded,
        unlockedBadges.contains('perfect_score'),
        'platinum',
      ),
      _BadgeData(
        'Road Master',
        'Complete 100 rides',
        Icons.route_rounded,
        totalRides >= 100 || unlockedBadges.contains('road_master'),
        'gold',
        totalRides < 100 ? totalRides / 100 : null,
      ),
      _BadgeData(
        'Night Owl',
        'Complete 20 night rides',
        Icons.nightlight_rounded,
        unlockedBadges.contains('night_owl'),
        'silver',
        0.3,
      ),
      _BadgeData(
        'Early Bird',
        'Complete 20 morning rides',
        Icons.wb_sunny_rounded,
        unlockedBadges.contains('early_bird'),
        'bronze',
        0.45,
      ),
      _BadgeData(
        'Marathon Driver',
        'Travel 1000 km total',
        Icons.straighten_rounded,
        totalDistance >= 1000 || unlockedBadges.contains('marathon_driver'),
        'diamond',
        totalDistance < 1000 ? totalDistance / 1000 : null,
      ),
      _BadgeData(
        'Verified Pro',
        'Get identity verified',
        Icons.verified_rounded,
        unlockedBadges.contains('verified_pro'),
        'silver',
      ),
      _BadgeData(
        'Chat Champion',
        'Send 100 messages',
        Icons.chat_rounded,
        unlockedBadges.contains('chat_champion'),
        'bronze',
        0.8,
      ),
      _BadgeData(
        'Team Player',
        'Join 5 group rides',
        Icons.groups_rounded,
        unlockedBadges.contains('team_player'),
        'gold',
        0.4,
      ),
    ];
  }
}

class _BadgeData {
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final String tier;
  final double? progress;

  _BadgeData(
    this.name,
    this.description,
    this.icon,
    this.unlocked,
    this.tier, [
    this.progress,
  ]);
}

class _ChallengeData {
  final String name;
  final String description;
  final String progressText;
  final double progress;
  final int xpReward;
  final IconData icon;
  final String timeLeft;

  _ChallengeData(
    this.name,
    this.description,
    this.progressText,
    this.progress,
    this.xpReward,
    this.icon,
    this.timeLeft,
  );
}

class _LeaderboardEntry {
  final String name;
  final int xp;
  final int rank;
  final int level;
  final bool isCurrentUser;

  _LeaderboardEntry(
    this.name,
    this.xp,
    this.rank, {
    this.level = 1,
    this.isCurrentUser = false,
  });
}
