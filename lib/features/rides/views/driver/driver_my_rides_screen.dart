import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

/// Driver Rides Screen – pending booking requests + upcoming rides timeline.
///
/// Design: professional dashboard layout.
/// - Section 1: Pending Requests — scrollable list with inline Accept/Decline.
/// - Section 2: Upcoming Rides — vertical timeline cards.
/// - FAB: Offer a new ride.
class DriverMyRidesScreen extends ConsumerWidget {
  const DriverMyRidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverViewModelProvider);
    final pendingAsync = driverState.pendingRequests;
    final upcomingAsync = driverState.upcomingRides;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'driver_rides_offer_fab',
        onPressed: () => context.push(AppRoutes.driverOfferRide.path),
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
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(driverViewModelProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              floating: true,
              snap: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Rides',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'View requests',
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                    size: 24.sp,
                  ),
                  onPressed: () =>
                      context.pushNamed(AppRoutes.driverRequests.name),
                ),
                SizedBox(width: 4.w),
              ],
            ),

            // ── Pending Requests ─────────────────────────────────
            SliverToBoxAdapter(
              child: pendingAsync.when(
                data: (requests) => _PendingRequestsSection(requests: requests),
                loading: () => const _RequestsLoading(),
                error: (e, _) => _RequestsError(error: e),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8.h)),

            // ── Timeline Header ──────────────────────────────────
            const SliverToBoxAdapter(child: _TimelineHeader()),

            // ── Upcoming Rides ───────────────────────────────────
            upcomingAsync.when(
              data: (rides) => rides.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyTimeline())
                  : _RidesTimeline(rides: rides),
              loading: () =>
                  const SliverToBoxAdapter(child: _LoadingTimeline()),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorTimeline(error: e)),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PENDING REQUESTS SECTION
// ════════════════════════════════════════════════════════════════

class _PendingRequestsSection extends ConsumerWidget {
  const _PendingRequestsSection({required this.requests});
  final List<RideRequestModel> requests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pending Requests',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (requests.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${requests.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          if (requests.isEmpty)
            const _EmptyRequests()
          else
            ...requests.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _PendingRequestCard(request: entry.value)
                    .animate(delay: Duration(milliseconds: entry.key * 60))
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOut),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            'No Pending Requests',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'New booking requests will appear here.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RequestsLoading extends StatelessWidget {
  const _RequestsLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Requests',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _RequestsError extends StatelessWidget {
  const _RequestsError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Could not load requests. Pull to refresh.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PENDING REQUEST CARD
// ════════════════════════════════════════════════════════════════

class _PendingRequestCard extends ConsumerWidget {
  const _PendingRequestCard({required this.request});
  final RideRequestModel request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
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
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    image: request.passengerPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(request.passengerPhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: request.passengerPhotoUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 24.sp,
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.passengerName ?? 'Booking Request',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          if (request.passengerRating > 0) ...[
                            Icon(
                              Icons.star_rounded,
                              size: 12.sp,
                              color: AppColors.xpGold,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              request.passengerRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Text(
                            DateFormat(
                              'MMM d, HH:mm',
                            ).format(request.createdAt),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${request.pricePerSeat.toStringAsFixed(0)} DT',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Route
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.radio_button_checked_rounded,
                    label: 'Pickup',
                    address: request.pickupLocation.address,
                    color: AppColors.primary,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 11.5.w,
                      top: 2.h,
                      bottom: 2.h,
                    ),
                    child: SizedBox(
                      height: 16.h,
                      child: VerticalDivider(
                        width: 1.w,
                        thickness: 1.5,
                        color: AppColors.divider,
                      ),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.location_on_rounded,
                    label: 'Dropoff',
                    address: request.dropoffLocation.address,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Chip row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _DetailChip(
              icon: Icons.people_outline_rounded,
              text:
                  '${request.requestedSeats} '
                  '${request.requestedSeats == 1 ? 'seat' : 'seats'}',
            ),
          ),

          SizedBox(height: 14.h),

          Divider(height: 1, color: AppColors.divider),

          // Action buttons
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    color: AppColors.error,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          title: const Text('Decline Request?'),
                          content: const Text(
                            'This will decline the booking request. '
                            'The passenger will be notified.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Keep'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Decline'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        ref
                            .read(driverViewModelProvider.notifier)
                            .declineRideRequest(request.rideId, request.id);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'Accept',
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          title: const Text('Accept Request?'),
                          content: Text(
                            'Accept this booking from '
                            '${request.passengerName ?? 'this passenger'}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        ref
                            .read(driverViewModelProvider.notifier)
                            .acceptRideRequest(request.rideId, request.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ════════════════════════════════════════════════════════════════

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.label,
    required this.address,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String address;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 13.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
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

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// UPCOMING RIDES TIMELINE
// ════════════════════════════════════════════════════════════════

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'Upcoming Rides',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RidesTimeline extends ConsumerWidget {
  const _RidesTimeline({required this.rides});
  final List<RideModel> rides;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final ride = rides[index];
          final isLast = index == rides.length - 1;

          return Dismissible(
            key: ValueKey('driver_timeline_${ride.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              HapticFeedback.mediumImpact();
              if (!context.mounted) return false;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: const Text('Cancel Ride'),
                  content: const Text(
                    'Are you sure you want to cancel this ride? '
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Keep Ride'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
              if ((confirmed ?? false) && context.mounted) {
                context.pushNamed(
                  AppRoutes.cancellationReason.name,
                  pathParameters: {'id': ride.id},
                );
              }
              return false;
            },
            background: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.white, size: 24.sp),
                  SizedBox(height: 4.h),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: _TimelineRideCard(ride: ride, index: index, isLast: isLast),
          );
        }, childCount: rides.length),
      ),
    );
  }
}

class _TimelineRideCard extends StatelessWidget {
  const _TimelineRideCard({
    required this.ride,
    required this.index,
    required this.isLast,
  });

  final RideModel ride;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 80.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                color: AppColors.divider,
              ),
          ],
        ).animate(delay: Duration(milliseconds: index * 80)).fadeIn(),

        SizedBox(width: 12.w),

        // Card
        Expanded(
          child: GestureDetector(
            onTap: () => context.pushNamed(
              AppRoutes.driverViewRide.name,
              pathParameters: {'id': ride.id},
            ),
            child:
                Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
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
                          // Date + seats
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM d • HH:mm',
                                  ).format(ride.departureTime),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline_rounded,
                                    size: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${ride.acceptedBookings.length}/${ride.availableSeats}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Origin
                          Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked_rounded,
                                size: 14.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  ride.origin.address,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          // Destination
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  ride.destination.address,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate(delay: Duration(milliseconds: index * 80 + 40))
                    .fadeIn()
                    .slideX(begin: 0.05),
          ),
        ),
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 36.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            'No Upcoming Rides',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Use the button below to offer a new ride.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LoadingTimeline extends StatelessWidget {
  const _LoadingTimeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ErrorTimeline extends StatelessWidget {
  const _ErrorTimeline({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Could not load rides. Pull to refresh.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
