import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────────────────

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
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => _AchievementsLoadingShell(l10n: l10n),
      error: (e, _) =>
          _AchievementsErrorShell(l10n: l10n, message: e.toString()),
      data: (user) {
        if (user == null)
          return _AchievementsErrorShell(
            l10n: l10n,
            message: l10n.signInToSeeYourRides,
          );
        final stats = user.gamification;
        if (stats == null) return _AchievementsLoadingShell(l10n: l10n);
        return _AchievementsContent(
          user: user,
          stats: stats,
          tabController: _tabController,
          l10n: l10n,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MAIN CONTENT
// ─────────────────────────────────────────────────────────────────

class _AchievementsContent extends StatelessWidget {
  const _AchievementsContent({
    required this.user,
    required this.stats,
    required this.tabController,
    required this.l10n,
  });

  final dynamic user;
  final GamificationStats stats;
  final TabController tabController;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final levelName = _levelName(stats.level);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _AchievementsSliverHeader(
            stats: stats,
            levelName: levelName,
            tabController: tabController,
            l10n: l10n,
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _BadgesTab(stats: stats, l10n: l10n),
            _ChallengesTab(stats: stats, l10n: l10n),
            _LeaderboardTab(stats: stats, l10n: l10n),
          ],
        ),
      ),
    );
  }

  static String _levelName(int level) {
    if (level >= 20) return 'Diamond';
    if (level >= 15) return 'Platinum';
    if (level >= 10) return 'Gold';
    if (level >= 5) return 'Silver';
    return 'Bronze';
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIVER HEADER
// ─────────────────────────────────────────────────────────────────

class _AchievementsSliverHeader extends StatelessWidget {
  const _AchievementsSliverHeader({
    required this.stats,
    required this.levelName,
    required this.tabController,
    required this.l10n,
  });

  final GamificationStats stats;
  final String levelName;
  final TabController tabController;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final xpProgress = stats.xpToNextLevel > 0
        ? (stats.currentLevelXP / stats.xpToNextLevel).clamp(0.0, 1.0)
        : 1.0;
    final isMaxLevel = stats.level >= 25;

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => context.pop(),
        tooltip: l10n.goBackTooltip,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 56.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level badge + XP
                  Row(
                    children: [
                      _LevelBadge(level: stats.level, name: levelName),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.levelValueValue(stats.level, levelName),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (!isMaxLevel) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: xpProgress,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.25,
                                  ),
                                  color: Colors.white,
                                  minHeight: 6.h,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                l10n.valueXpToLevelValue(
                                  stats.xpToNextLevel - stats.currentLevelXP,
                                  stats.level + 1,
                                ),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ] else
                              Text(
                                l10n.maxLevel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Stats row
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.bolt_rounded,
                        value: l10n.valueXp2(stats.totalXP),
                        label: 'Total XP',
                      ),
                      const _StatDivider(),
                      _StatItem(
                        icon: Icons.directions_car_rounded,
                        value: '${stats.totalRides}',
                        label: l10n.navRides,
                      ),
                      const _StatDivider(),
                      _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: '${stats.currentStreak}',
                        label: 'Streak',
                      ),
                      const _StatDivider(),
                      _StatItem(
                        icon: Icons.emoji_events_rounded,
                        value: '${stats.unlockedBadges.length}',
                        label: l10n.badges,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(48.h),
        child: Container(
          color: AppColors.primary,
          child: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: l10n.badges),
              Tab(text: l10n.challenges),
              Tab(text: l10n.leaderboard),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LEVEL BADGE
// ─────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.name});
  final int level;
  final String name;

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color shadowColor;
    switch (name) {
      case 'Diamond':
        badgeColor = AppColors.info;
        shadowColor = AppColors.info;
      case 'Platinum':
        badgeColor = AppColors.levelPlatinum;
        shadowColor = AppColors.levelPlatinum;
      case 'Gold':
        badgeColor = AppColors.levelGold;
        shadowColor = AppColors.levelGold;
      case 'Silver':
        badgeColor = AppColors.levelSilver;
        shadowColor = AppColors.levelSilver;
      default: // Bronze
        badgeColor = AppColors.levelBronze;
        shadowColor = AppColors.levelBronze;
    }

    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: badgeColor, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 18.sp, color: badgeColor),
          Text(
            '$level',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGES TAB
// ─────────────────────────────────────────────────────────────────

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final badges = _getBadgeDefinitions(stats);
    final unlocked = badges.where((b) => b.unlocked).length;
    final total = badges.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        // Progress header
        Container(
          padding: EdgeInsets.all(14.w),
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    size: 18.sp,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$unlocked / $total ${l10n.badges} ${l10n.unlocked.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  color: AppColors.accent,
                  minHeight: 8.h,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, i) => _BadgeCard(data: badges[i], index: i),
        ),
      ],
    );
  }

  List<_BadgeData> _getBadgeDefinitions(GamificationStats stats) {
    final unlockedBadges = stats.unlockedBadges;
    final totalRides = stats.totalRides;
    final totalDistance = stats.totalDistance;
    final longestStreak = stats.longestStreak;

    return [
      _BadgeData(
        'First Ride',
        'Complete your first ride',
        Icons.directions_car_rounded,
        totalRides >= 1 || unlockedBadges.contains('first_ride'),
        'bronze',
      ),
      _BadgeData(
        'Road Warrior',
        'Complete 10 rides',
        Icons.emoji_transportation_rounded,
        totalRides >= 10 || unlockedBadges.contains('road_warrior'),
        'silver',
        totalRides < 10 ? totalRides / 10 : null,
      ),
      _BadgeData(
        'Eco Hero',
        'Save 50 kg of CO₂',
        Icons.eco_rounded,
        unlockedBadges.contains('eco_hero'),
        'gold',
        0.6,
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
        'Maintain a 7-day streak',
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
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGE CARD
// ─────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.data, required this.index});
  final _BadgeData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(data.tier);
    final locked = !data.unlocked;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: locked ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: locked ? AppColors.border : tierColor.withValues(alpha: 0.4),
          width: locked ? 1 : 1.5,
        ),
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked
                  ? AppColors.border.withValues(alpha: 0.4)
                  : tierColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              locked ? Icons.lock_rounded : data.icon,
              size: 22.sp,
              color: locked ? AppColors.textTertiary : tierColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data.name,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: locked ? AppColors.textTertiary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!locked)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  data.tier.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          if (locked && data.progress != null)
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: LinearProgressIndicator(
                  value: data.progress,
                  backgroundColor: AppColors.border,
                  color: tierColor,
                  minHeight: 4.h,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'diamond':
        return AppColors.info;
      case 'platinum':
        return AppColors.levelPlatinum;
      case 'gold':
        return AppColors.levelGold;
      case 'silver':
        return AppColors.levelSilver;
      default:
        return AppColors.levelBronze;
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// CHALLENGES TAB
// ─────────────────────────────────────────────────────────────────

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final challenges = _getChallenges(stats);

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: challenges.length,
      itemBuilder: (context, i) =>
          _ChallengeCard(data: challenges[i], index: i, l10n: l10n),
    );
  }

  List<_ChallengeData> _getChallenges(GamificationStats stats) {
    return [
      _ChallengeData(
        'Daily Commuter',
        'Complete 1 ride today',
        '0/1',
        0.0,
        50,
        Icons.today_rounded,
        'Resets in 12h',
      ),
      _ChallengeData(
        'Week Warrior',
        'Complete 5 rides this week',
        '${stats.totalRides.clamp(0, 5)}/5',
        (stats.totalRides.clamp(0, 5) / 5).toDouble(),
        200,
        Icons.calendar_view_week_rounded,
        'Resets in 3d',
      ),
      _ChallengeData(
        'Streak Keeper',
        'Maintain a 3-day streak',
        '${stats.currentStreak.clamp(0, 3)}/3',
        (stats.currentStreak.clamp(0, 3) / 3).toDouble(),
        150,
        Icons.local_fire_department_rounded,
        'Keep going!',
      ),
      _ChallengeData(
        'Explorer',
        'Try 3 new routes this month',
        '0/3',
        0.1,
        300,
        Icons.explore_rounded,
        'Resets in 23d',
      ),
      _ChallengeData(
        'Social Rider',
        'Rate 5 drivers this week',
        '0/5',
        0.0,
        100,
        Icons.star_half_rounded,
        'Resets in 3d',
      ),
      _ChallengeData(
        'Eco Warrior',
        'Share 3 rides today',
        '0/3',
        0.0,
        75,
        Icons.eco_rounded,
        'Resets in 12h',
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────
// CHALLENGE CARD
// ─────────────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.data,
    required this.index,
    required this.l10n,
  });
  final _ChallengeData data;
  final int index;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isComplete = data.progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
          width: isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check_circle_rounded : data.icon,
              size: 22.sp,
              color: isComplete ? AppColors.success : AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // XP chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        l10n.valueXp(data.xpReward),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: data.progress,
                          backgroundColor: AppColors.border,
                          color: isComplete
                              ? AppColors.success
                              : AppColors.primary,
                          minHeight: 5.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      data.progressText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  data.timeLeft,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 350.ms);
  }
}

// ─────────────────────────────────────────────────────────────────
// LEADERBOARD TAB
// ─────────────────────────────────────────────────────────────────

class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab({required this.stats, required this.l10n});
  final GamificationStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(16.w),
        child: SkeletonLoader(type: SkeletonType.compactTile, itemCount: 8),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 40.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.errorLoadingAchievements,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              l10n.noResultsFound,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          );
        }
        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            // Podium
            _Podium(top3: top3, l10n: l10n),
            SizedBox(height: 16.h),
            // Rest of leaderboard
            ...rest.asMap().entries.map(
              (e) => _LeaderboardRow(entry: e.value, index: e.key, l10n: l10n),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PODIUM (top 3)
// ─────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.l10n});
  final List<LeaderboardEntry> top3;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primarySurface, AppColors.background],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (second != null)
            _PodiumSpot(
              entry: second,
              height: 80.h,
              medal: AppColors.levelSilver,
            ),
          _PodiumSpot(
            entry: first,
            height: 110.h,
            medal: AppColors.levelGold,
            isCrown: true,
          ),
          if (third != null)
            _PodiumSpot(
              entry: third,
              height: 60.h,
              medal: AppColors.levelBronze,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({
    required this.entry,
    required this.height,
    required this.medal,
    this.isCrown = false,
  });
  final LeaderboardEntry entry;
  final double height;
  final Color medal;
  final bool isCrown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCrown)
          Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.levelGold,
            size: 20.sp,
          ),
        CircleAvatar(
          radius: isCrown ? 24.r : 20.r,
          backgroundImage: entry.photoUrl != null
              ? NetworkImage(entry.photoUrl!)
              : null,
          backgroundColor: medal.withValues(alpha: 0.2),
          child: entry.photoUrl == null
              ? Text(
                  entry.displayName.isNotEmpty
                      ? entry.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: medal,
                    fontSize: isCrown ? 16.sp : 13.sp,
                  ),
                )
              : null,
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: 70.w,
          child: Text(
            entry.displayName,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _formatNumber(entry.totalXP),
          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 64.w,
          height: height,
          decoration: BoxDecoration(
            color: medal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            border: Border.all(color: medal.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: medal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k XP';
    return '$n XP';
  }
}

// ─────────────────────────────────────────────────────────────────
// LEADERBOARD ROW
// ─────────────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.index,
    required this.l10n,
  });
  final LeaderboardEntry entry;
  final int index;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final rankBgColors = [
      AppColors.levelGold,
      AppColors.levelSilver,
      AppColors.levelBronze,
    ];
    final rankColor = isTop3
        ? rankBgColors[entry.rank - 1]
        : AppColors.textTertiary;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isTop3 ? rankColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isTop3
                  ? rankColor.withValues(alpha: 0.15)
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: rankColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Avatar
          CircleAvatar(
            radius: 16.r,
            backgroundImage: entry.photoUrl != null
                ? NetworkImage(entry.photoUrl!)
                : null,
            backgroundColor: AppColors.primarySurface,
            child: entry.photoUrl == null
                ? Text(
                    entry.displayName.isNotEmpty
                        ? entry.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          // Name + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Lvl ${entry.level}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(entry.totalXP),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${entry.ridesThisMonth} rides',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms);
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED STAT WIDGETS
// ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(height: 3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36.h,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHELL STATES
// ─────────────────────────────────────────────────────────────────

class _AchievementsLoadingShell extends StatelessWidget {
  const _AchievementsLoadingShell({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.badges),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SkeletonLoader(type: SkeletonType.rideCard, itemCount: 1),
            SizedBox(height: 16.h),
            SkeletonLoader(type: SkeletonType.compactTile, itemCount: 5),
          ],
        ),
      ),
    );
  }
}

class _AchievementsErrorShell extends StatelessWidget {
  const _AchievementsErrorShell({required this.l10n, required this.message});
  final AppLocalizations l10n;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.badges),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.errorLoadingAchievements,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────────────────────

class _BadgeData {
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final String tier;
  final double? progress;

  const _BadgeData(
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

  const _ChallengeData(
    this.name,
    this.description,
    this.progressText,
    this.progress,
    this.xpReward,
    this.icon,
    this.timeLeft,
  );
}
