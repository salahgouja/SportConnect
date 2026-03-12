import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Assuming these imports match your project structure
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';

class RiderMyRidesScreen extends ConsumerWidget {
  const RiderMyRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => _buildFullLoading(),
        error: (err, _) => _buildErrorState(context, err.toString()),
        data: (user) {
          if (user == null) {
            return _buildSignInState(context);
          }

          final ridesAsync = ref.watch(
            myRidesAsPassengerStreamProvider(user.uid),
          );

          return ridesAsync.when(
            loading: () => _buildFullLoading(),
            error: (err, _) => _buildErrorState(context, err.toString()),
            data: (rides) {
              if (rides.isEmpty) {
                return _buildEmptyState(context);
              }

              // 1. Categorize Rides
              final activeRides = rides
                  .where((r) => r.status == RideStatus.inProgress)
                  .toList();

              final upcomingRides =
                  rides
                      .where(
                        (r) =>
                            (r.status == RideStatus.active ||
                                r.status == RideStatus.full) &&
                            r.departureTime.isAfter(DateTime.now()),
                      )
                      .toList()
                    ..sort(
                      (a, b) => a.departureTime.compareTo(b.departureTime),
                    );

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
                    ..sort(
                      (a, b) => b.departureTime.compareTo(a.departureTime),
                    );

              // 2. Build the Unified Feed with FAB
              return Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: _buildFab(context),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                body: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context),
                    if (activeRides.isNotEmpty)
                      _buildActiveSection(context, activeRides),
                    if (upcomingRides.isNotEmpty)
                      _buildUpcomingSection(context, upcomingRides),
                    if (pastRides.isNotEmpty)
                      ..._buildHistorySection(context, pastRides),

                    // Bottom padding to ensure the FAB doesn't block the last item
                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // MARK: - Header
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      collapsedHeight: 60.h,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor:
          Colors.transparent, // Prevents material 3 color shifting
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.sp,
          color: AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Text(
          AppLocalizations.of(context).myTrips, // Or simply "Activity"
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  // MARK: - Sections
  Widget _buildActiveSection(BuildContext context, List<RideModel> rides) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Happening Now',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            ...rides.map((ride) => _buildActiveCard(context, ride)),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context, List<RideModel> rides) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Upcoming',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 180.h, // Fixed height for horizontal scroll
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              itemCount: rides.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) =>
                  _buildUpcomingCard(context, rides[index]),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ],
      ),
    );
  }

  List<Widget> _buildHistorySection(
    BuildContext context,
    List<RideModel> rides,
  ) {
    // Group by month
    final groupedRides = <String, List<RideModel>>{};
    for (final ride in rides) {
      final monthKey = DateFormat('MMMM yyyy').format(ride.departureTime);
      groupedRides.putIfAbsent(monthKey, () => []).add(ride);
    }

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 8.h),
          child: Text(
            'Past Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    ];

    groupedRides.forEach((month, monthRides) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
            child: Text(
              month.toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildHistoryCard(context, monthRides[index]),
            childCount: monthRides.length,
          ),
        ),
      );
    });

    return slivers;
  }

  // MARK: - Cards
  Widget _buildActiveCard(BuildContext context, RideModel ride) {
    return GestureDetector(
      onTap: () =>
          context.push('${AppRoutes.riderActiveRide.path}?rideId=${ride.id}'),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                        ),
                    SizedBox(width: 8.w),
                    Text(
                      'In Progress',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildRouteTimeline(ride.origin.address, ride.destination.address),
            SizedBox(height: 20.h),
            Divider(color: AppColors.primary.withValues(alpha: 0.1), height: 1),
            SizedBox(height: 16.h),
            Row(
              children: [
                DriverAvatarWidget(driverId: ride.driverId, radius: 20),
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
                      Text(
                        ride.vehicleInfo ?? 'Vehicle',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons inside the card
                IconButton(
                  onPressed: () {}, // Trigger Call
                  icon: Icon(Icons.phone_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, RideModel ride) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.riderViewRide.name,
        pathParameters: {'id': ride.id},
      ),
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  DateFormat('EEE, MMM d • h:mm a').format(ride.departureTime),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _buildRouteTimeline(
                ride.origin.address,
                ride.destination.address,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, RideModel ride) {
    final isCancelled = ride.status == RideStatus.cancelled;

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.riderViewRide.name,
        pathParameters: {'id': ride.id},
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                isCancelled ? Icons.close_rounded : Icons.check_rounded,
                size: 20.sp,
                color: isCancelled ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.destination.address
                        .split(',')
                        .first, // Just show destination for quick parsing
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('MMM d, h:mm a').format(ride.departureTime),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '\$${ride.pricePerSeat.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isCancelled
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Reusable UI Components
  Widget _buildRouteTimeline(String origin, String destination) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: 10.sp, color: AppColors.textPrimary),
            Container(
              width: 1.5.w,
              height: 24.h,
              color: AppColors.textTertiary.withValues(alpha: 0.3),
            ),
            Icon(Icons.square, size: 10.sp, color: AppColors.primary),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin.split(',').first,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 18.h),
              Text(
                destination.split(',').first,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.searchRides.path),
        backgroundColor: AppColors.primary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: Icon(Icons.add_rounded, size: 24.sp, color: Colors.white),
        label: Text(
          'Book a Ride',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // MARK: - States
  Widget _buildFullLoading() => const Center(
    child: SkeletonLoader(type: SkeletonType.rideCard, itemCount: 4),
  );

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 24.h),
            Text(
              'Sign in to see your rides',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'Log In',
              onPressed: () => context.go(AppRoutes.login.path),
              style: PremiumButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Visual: stacked avatars representing community
                SizedBox(
                  height: 64.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (i) {
                      final offsets = [-30.w, 0.0, 30.w];
                      final icons = [Icons.person, Icons.directions_car, Icons.person];
                      final colors = [AppColors.primary, AppColors.success, AppColors.info];
                      return Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 32.w + offsets[i] - 20.w,
                        child: CircleAvatar(
                          radius: 28.r,
                          backgroundColor: colors[i].withValues(alpha: 0.15),
                          child: Icon(icons[i], color: colors[i], size: 24.sp),
                        ),
                      );
                    }),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                SizedBox(height: 24.h),
                Text(
                  l10n.noRidesYetTitle,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 150.ms),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    l10n.noRidesYetSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 250.ms),
                SizedBox(height: 32.h),
                // Single prominent CTA
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.searchRides.path),
                    icon: Icon(Icons.search_rounded, size: 22.sp),
                    label: Text(
                      l10n.findACarpoolNow,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 2,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.15),
                SizedBox(height: 16.h),
                // Subtle trust badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_rounded, size: 14.sp, color: AppColors.success),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.allDriversVerifiedAndRated,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
