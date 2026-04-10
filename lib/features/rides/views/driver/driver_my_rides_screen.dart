import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────────────────

class DriverMyRidesScreen extends ConsumerWidget {
  const DriverMyRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final driverState = ref.watch(driverViewModelProvider);
    final notifier = ref.read(driverViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator.adaptive(
        color: AppColors.primary,
        onRefresh: () async => notifier.refresh(),
        child: CustomScrollView(
          slivers: [
            _DriverSliverAppBar(
              onOfferRide: () => context.push(AppRoutes.driverOfferRide.path),
            ),
            // Active ride banner
            if (driverState.hasActiveRide && driverState.activeRide != null)
              SliverToBoxAdapter(
                child: _ActiveRideBanner(ride: driverState.activeRide!),
              ),
            // Pending booking requests
            SliverToBoxAdapter(
              child: _PendingRequestsSection(
                requestsAsync: driverState.pendingRequests,
                notifier: notifier,
              ),
            ),
            // Upcoming rides timeline
            SliverToBoxAdapter(
              child: _UpcomingRidesSection(
                ridesAsync: driverState.upcomingRides,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.driverOfferRide.path),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.offerRide),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIVER APP BAR
// ─────────────────────────────────────────────────────────────────

class _DriverSliverAppBar extends StatelessWidget {
  const _DriverSliverAppBar({required this.onOfferRide});
  final VoidCallback onOfferRide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now);

    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () => context.pushNamed(AppRoutes.driverRequests.name),
          icon: const Icon(Icons.inbox_rounded),
          tooltip: AppLocalizations.of(context).viewRequestsTooltip,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.driverMyRidesTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE RIDE BANNER
// ─────────────────────────────────────────────────────────────────

class _ActiveRideBanner extends StatelessWidget {
  const _ActiveRideBanner({required this.ride});
  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: GestureDetector(
        onTap: () => context.push(
          '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _PulsingDot(),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RIDE IN PROGRESS',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${ride.origin.address} → ${ride.destination.address}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${ride.bookedSeats}/${ride.capacity.available} passengers · '
                      '${AppLocalizations.of(context).value5(ride.pricePerSeat.toStringAsFixed(0))} per seat',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 10.w,
          height: 10.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .scaleXY(begin: 1, end: 1.5, duration: 800.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(begin: 1.5, end: 1, duration: 800.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────────
// PENDING REQUESTS SECTION
// ─────────────────────────────────────────────────────────────────

class _PendingRequestsSection extends ConsumerWidget {
  const _PendingRequestsSection({
    required this.requestsAsync,
    required this.notifier,
  });

  final AsyncValue<List<RideBooking>> requestsAsync;
  final DriverViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.pendingRequestsTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              requestsAsync.maybeWhen(
                data: (list) => list.isNotEmpty
                    ? _Badge(count: list.length)
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          requestsAsync.when(
            loading: () =>
                SkeletonLoader(type: SkeletonType.compactTile, itemCount: 3),
            error: (e, _) => _InlineError(message: l10n.couldNotLoadRequests),
            data: (requests) {
              if (requests.isEmpty) {
                return _InlineEmpty(
                  icon: Icons.inbox_rounded,
                  label: 'No pending requests',
                );
              }
              return Column(
                children: requests.asMap().entries.map((e) {
                  return _PendingRequestCard(
                    request: e.value,
                    index: e.key,
                    notifier: notifier,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PENDING REQUEST CARD
// ─────────────────────────────────────────────────────────────────

class _PendingRequestCard extends ConsumerWidget {
  const _PendingRequestCard({
    required this.request,
    required this.index,
    required this.notifier,
  });

  final RideBooking request;
  final int index;
  final DriverViewModel notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(userProfileProvider(request.passengerId)).value;
    final ride = ref.watch(rideStreamProvider(request.rideId)).value;

    final passengerName = profile?.displayName ?? '…';
    final passengerPhoto = profile?.photoUrl;
    final passengerRating = profile?.rating.average ?? 0.0;
    final pricePerSeat = ride?.pricePerSeat ?? 0.0;
    final pickupAddress = request.pickupLocation?.address ?? ride?.origin.address ?? '…';
    final dropoffAddress = request.dropoffLocation?.address ?? ride?.destination.address ?? '…';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Passenger header
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: passengerPhoto != null
                    ? NetworkImage(passengerPhoto)
                    : null,
                backgroundColor: AppColors.primarySurface,
                child: passengerPhoto == null
                    ? Icon(Icons.person_rounded, size: 20.sp, color: AppColors.primary)
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passengerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 13.sp, color: AppColors.accent),
                        SizedBox(width: 3.w),
                        Text(
                          passengerRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
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
                    l10n.value5(pricePerSeat.toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '× ${request.seatsBooked} ${l10n.seatsCount(request.seatsBooked)}',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Route info
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                _RoutePoint(
                  icon: Icons.radio_button_checked_rounded,
                  color: AppColors.primary,
                  label: l10n.pickupLabel,
                  address: pickupAddress,
                ),
                SizedBox(height: 6.h),
                _RoutePoint(
                  icon: Icons.location_on_rounded,
                  color: AppColors.error,
                  label: l10n.dropoffLabel,
                  address: dropoffAddress,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Accept / Decline
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmDecline(context, passengerName),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    l10n.declineButton,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _confirmAccept(context, passengerName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.acceptButton,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 350.ms);
  }

  void _confirmAccept(BuildContext context, String passengerName) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(l10n.acceptRequestTitle),
        content: Text(l10n.acceptRequestMessage(passengerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              notifier.acceptRideRequest(request.rideId, request.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.acceptButton),
          ),
        ],
      ),
    );
  }

  void _confirmDecline(BuildContext context, String passengerName) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(l10n.declineRequestTitle),
        content: Text(l10n.declineRequestMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.keepButton),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              notifier.declineRideRequest(request.rideId, request.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.declineButton),
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12.sp,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UPCOMING RIDES SECTION
// ─────────────────────────────────────────────────────────────────

class _UpcomingRidesSection extends StatelessWidget {
  const _UpcomingRidesSection({required this.ridesAsync});
  final AsyncValue<List<RideModel>> ridesAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.upcoming,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ridesAsync.when(
            loading: () =>
                SkeletonLoader(type: SkeletonType.rideCard, itemCount: 2),
            error: (e, _) => _InlineError(message: l10n.couldNotLoadRides),
            data: (rides) {
              if (rides.isEmpty) {
                return _InlineEmpty(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.noRidesYetTitle,
                );
              }
              return _RidesTimeline(rides: rides);
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RIDES TIMELINE
// ─────────────────────────────────────────────────────────────────

class _RidesTimeline extends StatelessWidget {
  const _RidesTimeline({required this.rides});
  final List<RideModel> rides;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rides.asMap().entries.map((e) {
        return _TimelineRideCard(
          ride: e.value,
          isLast: e.key == rides.length - 1,
          index: e.key,
        );
      }).toList(),
    );
  }
}

class _TimelineRideCard extends StatelessWidget {
  const _TimelineRideCard({
    required this.ride,
    required this.isLast,
    required this.index,
  });

  final RideModel ride;
  final bool isLast;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dt = ride.departureTime;
    final time = DateFormat('HH:mm').format(dt);
    final date = DateFormat('d MMM').format(dt);
    final seatsText = '${ride.bookedSeats}/${ride.capacity.available}';

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.driverViewRide.name,
        pathParameters: {'id': ride.id},
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            // Card content
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time + price
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            l10n.value5(ride.pricePerSeat.toStringAsFixed(0)),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Route
                    Text(
                      ride.origin.address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 2.w),
                      child: Icon(
                        Icons.south_rounded,
                        size: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      ride.destination.address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Seats + status
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$seatsText booked',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        _StatusChip(status: ride.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 80).ms, duration: 350.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STATUS CHIP
// ─────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final RideStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case RideStatus.active:
        bg = AppColors.primarySurface;
        fg = AppColors.primary;
        label = 'Open';
      case RideStatus.full:
        bg = AppColors.warningSurface;
        fg = AppColors.warning;
        label = 'Full';
      case RideStatus.inProgress:
        bg = AppColors.successLight.withValues(alpha: 0.2);
        fg = AppColors.success;
        label = 'Live';
      case RideStatus.completed:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
        label = 'Done';
      case RideStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.1);
        fg = AppColors.error;
        label = 'Cancelled';
      case RideStatus.draft:
        bg = AppColors.infoSurface;
        fg = AppColors.info;
        label = 'Draft';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BADGE
// ─────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INLINE STATES
// ─────────────────────────────────────────────────────────────────

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.sp, color: AppColors.textTertiary),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
