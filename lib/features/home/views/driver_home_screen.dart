import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';
import 'package:sport_connect/features/home/view_models/driver_location_view_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Driver Home Screen - Responsive dashboard with location support.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _hasAutoNavigatedToActiveRide = false;

  @override
  void initState() {
    super.initState();
    ref.read(driverLocationViewModelProvider.notifier).initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
      _requestNotificationPermission();
    });
  }

  /// Requests notification permission, always preceded by our rationale dialog.
  ///
  /// On some Android OEMs / Android < 13, Firebase reports `denied` on a
  /// fresh install instead of `notDetermined`, which would make us skip the
  /// dialog entirely.  We guard against this by persisting a
  /// `notification_dialog_shown` flag: we only treat `denied` as a genuine
  /// previous refusal when that flag is already `true`.
  Future<void> _requestNotificationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool('notification_dialog_shown') ?? false;

      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      final status = settings.authorizationStatus;

      // Already granted — nothing to do.
      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional) {
        TalkerService.info('Notification permission already granted: $status');
        return;
      }

      // Genuinely denied after a previous explicit OS prompt — cannot re-ask.
      if (status == AuthorizationStatus.denied && alreadyAsked) {
        TalkerService.info(
          'Notification permission denied; user must re-enable from settings.',
        );
        return;
      }

      // `notDetermined` OR `denied` on first launch (OEM quirk):
      // show our rationale dialog, then request from the OS.
      await Future.delayed(const Duration(seconds: 1));
      if (!context.mounted) return;

      final accepted = await PermissionDialogHelper.showNotificationRationale(
        context,
      );

      // Mark that we have now shown the dialog regardless of the user's choice.
      await prefs.setBool('notification_dialog_shown', true);

      if (!accepted) {
        TalkerService.info('User dismissed notification rationale.');
        return;
      }

      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      TalkerService.info(
        'Notification permission result: ${result.authorizationStatus}',
      );
    } catch (e) {
      TalkerService.error('Failed to request notification permission', e);
    }
  }

  /// Requests location permission when user explicitly taps the enable button.
  /// Opens location settings if permission denied or services disabled.
  Future<void> _requestLocationPermission() async {
    try {
      final accepted = await PermissionDialogHelper.showLocationRationale(
        context,
      );
      if (!accepted) return;
      await ref
          .read(driverLocationViewModelProvider.notifier)
          .requestPermission();
      final locationState = ref.read(driverLocationViewModelProvider);
      if (!locationState.locationGranted) {
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      TalkerService.debug('Error requesting location permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(driverLocationViewModelProvider);
    final driverState = ref.watch(driverViewModelProvider);

    // ── Global Active Ride Guard ─────────────────────────────
    // On app launch / foreground, auto-navigate to the active ride screen
    // if the driver has an in-progress ride.
    if (!_hasAutoNavigatedToActiveRide) {
      final ride = driverState.activeRide;
      if (ride != null && ride.status == RideStatus.inProgress) {
        _hasAutoNavigatedToActiveRide = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.push(
              '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
            );
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _DriverDashboard(
        isLoadingLocation: locationState.isLoading,
        locationGranted: locationState.locationGranted,
        locationDeniedForever: locationState.locationDeniedForever,
        servicesDisabled: locationState.servicesDisabled,
        currentPosition: locationState.currentPosition,
        onRetryLocation: _requestLocationPermission,
        onOpenSettings: () => Geolocator.openLocationSettings(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'driver_home_offer_fab',
        onPressed: () => context.push(AppRoutes.driverOfferRide.path),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(Icons.add_rounded, size: 22.sp, color: Colors.white),
        label: Text(
          AppLocalizations.of(context).offerRide,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

/// Main dashboard widget - adapts to orientation and screen size.
class _DriverDashboard extends ConsumerWidget {
  const _DriverDashboard({
    required this.isLoadingLocation,
    required this.locationGranted,
    required this.locationDeniedForever,
    required this.servicesDisabled,
    required this.currentPosition,
    required this.onRetryLocation,
    required this.onOpenSettings,
  });

  final bool isLoadingLocation;
  final bool locationGranted;
  final bool locationDeniedForever;
  final bool servicesDisabled;
  final Position? currentPosition;
  final VoidCallback onRetryLocation;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverViewModelProvider);
    final user = driverState.user;
    final driverStats = driverState.stats;
    final pendingRequests = driverState.pendingRequests;
    final upcomingRides = driverState.upcomingRides;
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(driverViewModelProvider.notifier).refresh(),
      child: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = orientation == Orientation.landscape;
              final isSmall = constraints.maxWidth < 360;
              final isWide = constraints.maxWidth >= 600;
              final hPad = isSmall ? 14.0 : 20.0;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context, ref, user, l10n, hPad),
                  ),

                  // Location banner when permission not granted
                  if (!locationGranted && !isLoadingLocation)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          children: [
                            _buildLocationBanner(l10n),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),

                  // Active ride banner — shown when an inProgress ride exists
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: 4,
                      ),
                      child: _ActiveDriverRideBanner(driverState: driverState),
                    ),
                  ),

                  // Quick actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(hPad),
                      child: _buildQuickActions(context, l10n),
                    ),
                  ),

                  // Earnings + Stats side-by-side in landscape on wide screens
                  if (isLandscape && isWide)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildEarningsSummary(
                                l10n,
                                driverStats,
                                isSmall,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildStatsGrid(
                                l10n,
                                driverStats,
                                isLandscape,
                                isSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: _buildEarningsSummary(
                          l10n,
                          driverStats,
                          isSmall,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(hPad),
                        child: _buildStatsGrid(
                          l10n,
                          driverStats,
                          isLandscape,
                          isSmall,
                        ),
                      ),
                    ),
                  ],

                  // Pending requests
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: _buildPendingRequests(
                        context,
                        ref,
                        driverState,
                        l10n,
                        pendingRequests,
                      ),
                    ),
                  ),

                  // Upcoming rides
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(hPad),
                      child: _buildUpcomingRides(
                        context,
                        driverState,
                        l10n,
                        upcomingRides,
                      ),
                    ),
                  ),

                  // Bottom spacing for FAB
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserModel?> user,
    AppLocalizations l10n,
    double hPad,
  ) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(hPad, topPad + 16, hPad, 16),
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
            onTap: () => context.go(AppRoutes.profile.path),
            child: user.when(
              data: (userData) => PremiumAvatar(
                imageUrl: userData?.photoUrl,
                name: userData?.displayName ?? l10n.driver,
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
                  _getGreeting(l10n),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                user.when(
                  data: (userData) => Text(
                    userData?.displayName ?? l10n.driver,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () =>
                      Text(l10n.loading, style: TextStyle(fontSize: 20.sp)),
                  error: (_, _) =>
                      Text(l10n.driver, style: TextStyle(fontSize: 20.sp)),
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.notifications.path),
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
            tooltip: 'Messages',
            onPressed: () => context.go(AppRoutes.chat.path),
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

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildLocationBanner(AppLocalizations l10n) {
    final shouldOpenSettings = locationDeniedForever || servicesDisabled;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationRequired,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.enableLocationForBetterExperience,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (shouldOpenSettings)
            TextButton(
              onPressed: onOpenSettings,
              child: Text(
                l10n.openSettings,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            )
          else
            TextButton(
              onPressed: onRetryLocation,
              child: Text(
                l10n.enable,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1);
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_road_rounded,
            label: l10n.driverCreateRide,
            color: AppColors.primary,
            onTap: () => context.push(AppRoutes.driverOfferRide.path),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.directions_car_rounded,
            label: l10n.myVehicles,
            color: AppColors.secondary,
            onTap: () => context.push(AppRoutes.driverVehicles.path),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history_rounded,
            label: l10n.history,
            color: AppColors.info,
            onTap: () => context.go(AppRoutes.driverRides.path),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.emoji_events_rounded,
            label: 'Events',
            color: AppColors.xpGold,
            onTap: () => context.push(AppRoutes.events.path),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildEarningsSummary(
    AppLocalizations l10n,
    AsyncValue<DriverStats> stats,
    bool isSmall,
  ) {
    return stats.when(
      data: (driverStats) => Container(
        padding: EdgeInsets.all(isSmall ? 14.w : 20.w),
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
                Flexible(
                  child: Text(
                    l10n.todaySEarnings,
                    style: TextStyle(
                      fontSize: isSmall ? 12.sp : 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.live,
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
                Flexible(
                  child: Text(
                    l10n.value6(driverStats.earningsToday.toStringAsFixed(2)),
                    style: TextStyle(
                      fontSize: isSmall ? 28.sp : 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    l10n.valueRides(driverStats.ridesCompleted),
                    style: TextStyle(
                      fontSize: isSmall ? 12.sp : 14.sp,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _EarningsMetric(
                  label: l10n.driverThisWeek,
                  value: l10n.value6(
                    driverStats.earningsThisWeek.toStringAsFixed(0),
                  ),
                ),
                SizedBox(width: 24.w),
                _EarningsMetric(
                  label: l10n.driverThisMonth,
                  value: l10n.value6(
                    driverStats.earningsThisMonth.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),
      loading: () => _buildShimmerCard(height: 180),
      error: (_, _) => _buildErrorCard(l10n.failedToLoadEarnings),
    );
  }

  Widget _buildStatsGrid(
    AppLocalizations l10n,
    AsyncValue<DriverStats> stats,
    bool isLandscape,
    bool isSmall,
  ) {
    return stats.when(
      data: (driverStats) {
        final cards = [
          _StatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.starFilled,
            value: driverStats.rating > 0
                ? driverStats.rating.toStringAsFixed(1)
                : '\u2014',
            label: l10n.rating,
          ),
          _StatCard(
            icon: Icons.route_rounded,
            iconColor: AppColors.primary,
            value: '${driverStats.totalRides}',
            label: l10n.totalRides,
          ),
          _StatCard(
            icon: Icons.eco_rounded,
            iconColor: AppColors.success,
            value: '${driverStats.co2Saved.toStringAsFixed(0)}kg',
            label: l10n.driverCo2Saved,
          ),
          _StatCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.info,
            value: '${driverStats.hoursOnline.toStringAsFixed(0)}h',
            label: l10n.driverHoursOnline,
          ),
        ];

        if (isLandscape || isSmall) {
          // In landscape or small: one scrollable row
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards
                  .map(
                    (c) => Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(width: 120.w, child: c),
                    ),
                  )
                  .toList(),
            ),
          );
        }

        // Portrait: 2x2 grid
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                SizedBox(width: 12.w),
                Expanded(child: cards[1]),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: cards[2]),
                SizedBox(width: 12.w),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
      loading: () => _buildShimmerStatsRow(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPendingRequests(
    BuildContext context,
    WidgetRef ref,
    DriverState driverState,
    AppLocalizations l10n,
    AsyncValue<List<RideRequestModel>> requestsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                l10n.rideRequests,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.driverRequests.path),
              icon: Icon(Icons.arrow_forward_ios, size: 14.sp),
              label: Text(
                l10n.viewAll,
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
          data: (_) {
            if (driverState.pendingRequestPreview.isEmpty) {
              return _buildEmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.noPendingRequests,
                subtitle: l10n.newRideRequestsWillAppear,
              );
            }
            return Column(
              children: driverState.pendingRequestPreview.map((request) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _RequestCard(
                    request: request,
                    isProcessing: driverState.isRequestActionInProgress(
                      request.id,
                    ),
                    onAccept: () async {
                      HapticFeedback.heavyImpact();
                      await ref
                          .read(driverViewModelProvider.notifier)
                          .acceptRideRequest(request.rideId, request.id);
                    },
                    onDecline: () async {
                      HapticFeedback.lightImpact();
                      await ref
                          .read(driverViewModelProvider.notifier)
                          .declineRideRequest(request.rideId, request.id);
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => _buildShimmerCard(height: 100),
          error: (_, _) => _buildErrorCard(l10n.failedToLoadRequests),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildUpcomingRides(
    BuildContext context,
    DriverState driverState,
    AppLocalizations l10n,
    AsyncValue<List<RideModel>> ridesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.upcomingRides,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        ridesAsync.when(
          data: (_) {
            final ridePreview = driverState.upcomingRidePreview;
            if (ridePreview.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available_outlined,
                title: l10n.noUpcomingRides,
                subtitle: l10n.createARideToStartEarning,
              );
            }
            return Column(
              children: ridePreview.map((ride) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _UpcomingRideCard(
                    ride: ride,
                    onTap: () => context.pushNamed(
                      AppRoutes.rideDetail.name,
                      pathParameters: {'id': ride.id},
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => _buildShimmerCard(height: 100),
          error: (_, _) => _buildErrorCard(l10n.failedToLoadRides),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.border.withAlpha(100),
      child: Container(
        height: height.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  Widget _buildShimmerStatsRow() {
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Shimmer.fromColors(
              baseColor: AppColors.surface,
              highlightColor: AppColors.border.withAlpha(100),
              child: Container(
                height: 90.h,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
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
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
  final RideRequestModel request;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.isProcessing,
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
              PremiumAvatar(name: request.passenger.displayName, size: 44.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passenger.displayName,
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
                          request.passenger.rating.average > 0
                              ? request.passenger.rating.average
                                    .toStringAsFixed(1)
                              : AppLocalizations.of(context).kNew,
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
                          AppLocalizations.of(context).valueSeatValue(
                            request.seatsRequested,
                            request.seatsRequested > 1 ? 's' : '',
                          ),
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
                  AppLocalizations.of(context).value6(
                    (request.pricePerSeat * request.seatsRequested)
                        .toStringAsFixed(0),
                  ),
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
                  onPressed: isProcessing ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppLocalizations.of(context).decline,
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
                  onPressed: isProcessing ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).accept,
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
                    DateFormat(
                      'MMM',
                    ).format(ride.schedule.departureTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(ride.schedule.departureTime),
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
                    AppLocalizations.of(context).valueValue2(
                      ride.route.origin.city ?? ride.route.origin.address,
                      ride.route.destination.city ??
                          ride.route.destination.address,
                    ),
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
                        DateFormat(
                          'h:mm a',
                        ).format(ride.schedule.departureTime),
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
                        AppLocalizations.of(context).valueValue(
                          ride.capacity.booked,
                          ride.capacity.available,
                        ),
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
                  AppLocalizations.of(context).value6(
                    (ride.pricing.pricePerSeat.amount * ride.capacity.booked)
                        .toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context).earned,
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

/// Persistent banner shown at the top of the driver dashboard whenever the
/// driver has an active (inProgress) ride.  Tapping it jumps straight to the
/// active-ride management screen.
class _ActiveDriverRideBanner extends StatelessWidget {
  const _ActiveDriverRideBanner({required this.driverState});

  final DriverState driverState;

  @override
  Widget build(BuildContext context) {
    final ride = driverState.activeRide;
    if (ride == null) return const SizedBox.shrink();

    final origin = ride.origin.city ?? ride.origin.address;
    final dest = ride.destination.city ?? ride.destination.address;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('${AppRoutes.driverActiveRide.path}?rideId=${ride.id}');
      },
      child:
          Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.40),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ride In Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$origin → $dest',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.87),
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: -0.2, curve: Curves.easeOutCubic),
    );
  }
}
