import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

/// Shown immediately after a passenger submits a booking request.
///
/// Streams the booking status in real-time and auto-navigates when the
/// driver responds:
/// - Accepted → [RideCountdownScreen]
/// - Rejected / Cancelled → back to My Rides
class RideBookingPendingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideBookingPendingScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideBookingPendingScreen> createState() =>
      _RideBookingPendingScreenState();
}

class _RideBookingPendingScreenState
    extends ConsumerState<RideBookingPendingScreen> {
  Timer? _expiryTimer;
  Duration _timeRemaining = Duration.zero;
  bool _isCancelling = false;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _startExpiryCountdown(DateTime createdAt) {
    final expiry = createdAt.add(const Duration(hours: 24));
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = expiry.difference(DateTime.now());
      setState(
        () => _timeRemaining = remaining.isNegative ? Duration.zero : remaining,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final bookingsStream = ref
        .watch(bookingRepositoryProvider)
        .streamBookingsByPassengerId(currentUser.uid);

    return StreamBuilder<List<RideBooking>>(
      stream: bookingsStream,
      builder: (context, bookingSnap) {
        final booking = bookingSnap.data
            ?.where((b) => b.rideId == widget.rideId)
            .firstOrNull;

        // Start expiry countdown once we have the booking creation time
        if (booking?.createdAt != null && _timeRemaining == Duration.zero) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _startExpiryCountdown(booking!.createdAt!),
          );
        }

        // Auto-navigate when driver responds
        if (booking != null && !_hasNavigated) {
          if (booking.status == BookingStatus.accepted) {
            _hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.pushReplacement(
                  AppRoutes.rideCountdown.path.replaceFirst(
                    ':bookingId',
                    booking.id,
                  ),
                );
              }
            });
          } else if (booking.status == BookingStatus.rejected ||
              booking.status == BookingStatus.cancelled) {
            _hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go(AppRoutes.riderMyRides.path);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      booking.status == BookingStatus.rejected
                          ? 'Your booking was declined by the driver.'
                          : 'Booking has been cancelled.',
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          }
        }

        final rideAsync = ref.watch(rideDetailViewModelProvider(widget.rideId));

        return rideAsync.when(
          data: (ride) => ride == null
              ? _buildError('Ride not found')
              : _buildContent(ride, booking),
          loading: _buildLoading,
          error: (e, _) => _buildError(e.toString()),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.primary),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Request Status'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RideModel ride, RideBooking? booking) {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);
    final expiryText =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Booking Request'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated success icon
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                color: AppColors.success,
                size: 48.sp,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 20.h),

            Text(
              'Request Sent!',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 8.h),

            Text(
              "Waiting for the driver to confirm your booking.\n"
              "You'll be notified as soon as they respond.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),

            SizedBox(height: 32.h),

            // Ride info card
            _buildRideCard(ride).animate().slideY(delay: 400.ms),

            SizedBox(height: 24.h),

            // Expiry countdown
            if (booking?.createdAt != null && _timeRemaining > Duration.zero)
              _buildExpiryChip(expiryText).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 32.h),

            // Cancel request button
            if (booking != null && booking.status == BookingStatus.pending) ...[
              PremiumButton(
                text: 'Cancel Request',
                isLoading: _isCancelling,
                style: PremiumButtonStyle.danger,
                onPressed: () => _cancelBooking(booking),
              ),
              SizedBox(height: 12.h),
            ],

            TextButton(
              onPressed: () => context.go(AppRoutes.riderMyRides.path),
              child: Text(
                'View All My Rides',
                style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final dep = ride.schedule.departureTime;
    final depText =
        '${dep.day}/${dep.month}/${dep.year}  '
        '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}';

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
          // Origin
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
          // Destination
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
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          // Metadata row
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                depText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.attach_money_rounded,
                size: 14.sp,
                color: AppColors.success,
              ),
              Text(
                '${ride.pricing.pricePerSeat.amount.toStringAsFixed(0)} '
                '${ride.pricing.pricePerSeat.currency}/seat',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryChip(String expiryText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: AppColors.warning, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            'Expires in  ',
            style: TextStyle(fontSize: 13.sp, color: AppColors.warningDark),
          ),
          Text(
            expiryText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.warningDark,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(RideBooking booking) async {
    HapticFeedback.mediumImpact();
    setState(() => _isCancelling = true);
    try {
      await ref
          .read(rideActionsViewModelProvider)
          .cancelBooking(rideId: widget.rideId, bookingId: booking.id);
      if (mounted) context.go(AppRoutes.riderMyRides.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }
}
