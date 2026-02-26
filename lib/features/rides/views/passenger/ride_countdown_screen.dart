import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

/// Pre-departure countdown screen for accepted bookings.
///
/// Shown when the driver has accepted the passenger's request but the
/// ride has not yet started.  Displays a live countdown to the
/// scheduled departure and provides quick-action buttons.
class RideCountdownScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const RideCountdownScreen({super.key, required this.bookingId});

  @override
  ConsumerState<RideCountdownScreen> createState() =>
      _RideCountdownScreenState();
}

class _RideCountdownScreenState extends ConsumerState<RideCountdownScreen> {
  Timer? _countdownTimer;
  Duration _timeUntilDeparture = const Duration(hours: 1);
  // Track last departure time to avoid restarting timer unnecessarily
  DateTime? _lastDepartureTime;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime departure) {
    if (_lastDepartureTime == departure) return;
    _lastDepartureTime = departure;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = departure.difference(DateTime.now());
      setState(
        () => _timeUntilDeparture = diff.isNegative ? Duration.zero : diff,
      );
    });
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}d  ${d.inHours.remainder(24)}h  '
          '${d.inMinutes.remainder(60)}m';
    }
    if (d.inHours > 0) {
      return '${d.inHours.toString().padLeft(2, '0')}:'
          '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes.toString().padLeft(2, '0')}:'
        '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RideBooking?>(
      stream: ref
          .watch(bookingRepositoryProvider)
          .streamBookingById(widget.bookingId),
      builder: (context, bookingSnap) {
        final booking = bookingSnap.data;

        if (!bookingSnap.hasData && !bookingSnap.hasError) {
          return _buildScaffold(
            title: 'Your Ride',
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (booking == null) {
          return _buildScaffold(
            title: 'Your Ride',
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: const Text(
                  'Booking not found. It may have been cancelled.',
                ),
              ),
            ),
          );
        }

        final rideAsync = ref.watch(
          rideDetailViewModelProvider(booking.rideId),
        );

        return rideAsync.when(
          data: (ride) => ride == null
              ? _buildScaffold(
                  title: 'Your Ride',
                  body: const Center(child: Text('Ride not found')),
                )
              : _buildContent(ride, booking),
          loading: () => _buildScaffold(
            title: 'Your Ride',
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _buildScaffold(
            title: 'Your Ride',
            body: Center(child: Text('Error: $e')),
          ),
        );
      },
    );
  }

  Scaffold _buildScaffold({required String title, required Widget body}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(title),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _buildContent(RideModel ride, RideBooking booking) {
    _startTimer(ride.schedule.departureTime);

    final isInPast = _timeUntilDeparture == Duration.zero;
    final isImminent = !isInPast && _timeUntilDeparture.inMinutes <= 15;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Your Ride'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Booking confirmed badge
            _buildStatusBadge().animate().fadeIn(delay: 100.ms),
            SizedBox(height: 32.h),

            // Countdown display
            if (!isInPast) ...[
              Text(
                isImminent ? 'Departing soon!' : 'Departure in',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isImminent
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                    _formatDuration(_timeUntilDeparture),
                    style: TextStyle(
                      fontSize: 44.sp,
                      fontWeight: FontWeight.bold,
                      color: isImminent ? AppColors.warning : AppColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .tint(
                    color: isImminent ? AppColors.warning : AppColors.primary,
                    duration: 1.seconds,
                  ),
            ] else
              Text(
                '🚗  Ride has started!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            SizedBox(height: 32.h),

            // Route card
            _buildRouteCard(ride).animate().slideY(delay: 200.ms),
            SizedBox(height: 16.h),

            // Booking info card
            _buildBookingInfoCard(booking).animate().slideY(delay: 300.ms),
            SizedBox(height: 32.h),

            // Action buttons
            if (isInPast)
              PremiumButton(
                text: 'Join Active Ride',
                style: PremiumButtonStyle.success,
                onPressed: () => context.push(
                  '${AppRoutes.riderActiveRide.path}?rideId=${booking.rideId}',
                ),
              )
            else
              PremiumButton(
                text: 'View Ride Details',
                onPressed: () => context.push(
                  AppRoutes.riderViewRide.path.replaceFirst(
                    ':id',
                    booking.rideId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(30),
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Booking Confirmed',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.origin.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.5.w),
            child: SizedBox(
              height: 18.h,
              child: VerticalDivider(
                width: 1.w,
                color: AppColors.divider,
                thickness: 1.5,
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.error,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.destination.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
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
    );
  }

  Widget _buildBookingInfoCard(RideBooking booking) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.airline_seat_recline_normal_rounded,
            value: '${booking.seatsBooked}',
            label: 'Seats',
          ),
          Container(width: 1.w, height: 32.h, color: AppColors.divider),
          _buildInfoItem(
            icon: Icons.confirmation_number_rounded,
            value: booking.id.length >= 6
                ? booking.id.substring(0, 6).toUpperCase()
                : booking.id.toUpperCase(),
            label: 'Ref #',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
