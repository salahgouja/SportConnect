import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
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
  bool _isProcessingPayment = false;
  bool _paymentFailed = false;
  DateTime? _trackedCreatedAt;

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

    final bookingsAsync = ref.watch(
      bookingsByPassengerProvider(currentUser.uid),
    );
    final booking = bookingsAsync.value
        ?.where((b) => b.rideId == widget.rideId)
        .firstOrNull;

    // Start expiry countdown once we have the booking creation time
    if (booking?.createdAt != null && booking!.createdAt != _trackedCreatedAt) {
      _trackedCreatedAt = booking.createdAt;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startExpiryCountdown(booking.createdAt!);
      });
    }

    // Auto-navigate when driver responds
    final vmState = ref.watch(rideDetailViewModelProvider(widget.rideId));
    final ride = vmState.ride.value;

    if (booking != null && !_hasNavigated && !_isProcessingPayment) {
      if (booking.status == BookingStatus.accepted) {
        _hasNavigated = true;
        if (ride != null && ride.acceptsOnlinePayment) {
          // Only launch payment if this booking hasn't already been paid.
          // This guards against double-charges when the user back-navigates
          // from the countdown screen (which resets _hasNavigated).
          if (booking.paymentIntentId == null) {
            // Driver accepted — collect payment before proceeding
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _processPayment(ride, booking);
            });
          } else {
            // Payment already completed — go straight to countdown
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
          }
        } else {
          // Cash ride — go straight to countdown
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
        }
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

    return vmState.ride.when(
      data: (ride) => ride == null
          ? _buildError('Ride not found')
          : _buildContent(ride, booking),
      loading: _buildLoading,
      error: (e, _) => _buildError(e.toString()),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
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
    final isAcceptedNeedsPayment =
        booking?.status == BookingStatus.accepted &&
        ride.acceptsOnlinePayment &&
        booking?.paymentIntentId == null;
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
        foregroundColor: AppColors.textOnPrimary,
        title: const Text('Booking Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: isAcceptedNeedsPayment
                    ? AppColors.primary.withAlpha(30)
                    : AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAcceptedNeedsPayment
                    ? Icons.payment_rounded
                    : Icons.mark_email_read_rounded,
                color: isAcceptedNeedsPayment
                    ? AppColors.primary
                    : AppColors.success,
                size: 48.sp,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            SizedBox(height: 20.h),

            Text(
              isAcceptedNeedsPayment ? 'Booking Accepted!' : 'Request Sent!',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 8.h),

            Text(
              isAcceptedNeedsPayment
                  ? 'Complete your payment to confirm the ride.'
                  : "Waiting for the driver to confirm your booking.\n"
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

            SizedBox(height: 16.h),

            // Driver info — shows who confirmed/offered the ride
            _buildDriverInfoCard(ride).animate().fadeIn(delay: 500.ms),

            SizedBox(height: 24.h),

            // Payment section when driver accepted and online payment is needed
            if (isAcceptedNeedsPayment && booking != null) ...[
              if (_isProcessingPayment)
                Column(
                  children: [
                    SizedBox(height: 8.h),
                    const CircularProgressIndicator(),
                    SizedBox(height: 12.h),
                    Text(
                      'Processing payment...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else if (_paymentFailed)
                PremiumButton(
                  text: 'Complete Payment',
                  onPressed: () => _processPayment(ride, booking),
                  style: PremiumButtonStyle.primary,
                ),
              SizedBox(height: 32.h),
            ],

            // Expiry countdown (only when pending)
            if (!isAcceptedNeedsPayment &&
                booking?.createdAt != null &&
                _timeRemaining > Duration.zero)
              _buildExpiryChip(expiryText).animate().fadeIn(delay: 500.ms),

            if (!isAcceptedNeedsPayment) SizedBox(height: 32.h),

            // Cancel request button (only when pending)
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

  Widget _buildDriverInfoCard(RideModel ride) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Row(
            children: [
              DriverAvatarWidget(driverId: ride.driverId, radius: 22),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12.sp,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          rating.average.toStringAsFixed(1),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Your Driver',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final dep = ride.schedule.departureTime;
    final depText = DateFormat.yMd().add_Hm().format(dep);

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

  Future<void> _processPayment(RideModel ride, RideBooking booking) async {
    if (_isProcessingPayment) return;
    setState(() {
      _isProcessingPayment = true;
      _paymentFailed = false;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw Exception('User not found');

      final paymentViewModel = ref.read(paymentViewModelProvider.notifier);

      // Fetch driver profile for Stripe account
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );
      if (driverProfile == null) throw Exception('Driver profile not found');

      final driverModel = driverProfile.asDriver;
      if (driverModel == null) {
        throw Exception('Driver profile is not a driver account');
      }

      final driverStripeAccountId = driverModel.stripeAccountId;
      if (driverStripeAccountId == null || driverStripeAccountId.isEmpty) {
        throw StripePaymentException(
          'Driver has not set up payment processing yet.',
        );
      }

      final customerId = await paymentViewModel.getOrCreateCustomer(
        userId: user.uid,
        email: user.email,
        name: user.displayName,
        phone: user.phoneNumber,
      );

      final totalAmount = ride.pricePerSeat * booking.seatsBooked;
      final currencyIso = _getCurrencyIsoCode(ride.currency ?? 'eur');

      final stripeService = ref.read(stripeServiceProvider);
      final paymentData = await stripeService.createPaymentIntent(
        rideId: ride.id,
        riderId: user.uid,
        riderName: user.displayName,
        driverId: ride.driverId,
        driverName: driverProfile.displayName,
        amount: totalAmount,
        currency: currencyIso,
        customerId: customerId,
        driverStripeAccountId: driverStripeAccountId,
        description: '${ride.origin.address} → ${ride.destination.address}',
      );

      final paymentSuccess = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentData['clientSecret'],
        customerId: customerId,
        ephemeralKeySecret: paymentData['ephemeralKey'],
      );

      if (!mounted) return;

      if (paymentSuccess) {
        // Stamp the booking with the payment intent ID before navigating.
        // This prevents "Complete Payment" from re-appearing and guards
        // against double-charges if the user back-navigates later.
        try {
          await ref
              .read(rideActionsViewModelProvider)
              .markBookingPaid(
                bookingId: booking.id,
                paymentIntentId: paymentData['paymentIntentId'] as String,
              );
        } catch (_) {
          // Non-fatal: payment already succeeded; the stamp is best-effort.
        }

        if (!mounted) return;
        context.pushReplacement(
          AppRoutes.rideCountdown.path.replaceFirst(':bookingId', booking.id),
        );
      } else {
        // Payment cancelled — let the user retry
        setState(() {
          _isProcessingPayment = false;
          _paymentFailed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment cancelled. Tap "Complete Payment" to retry.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on StripePaymentException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingPayment = false;
        _paymentFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.message}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessingPayment = false;
        _paymentFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Converts currency symbols to ISO codes for Stripe.
  String _getCurrencyIsoCode(String currency) {
    const currencyMap = {
      '€': 'eur',
      '\$': 'usd',
      '£': 'gbp',
      '¥': 'jpy',
      '₹': 'inr',
      'CHF': 'chf',
      'A\$': 'aud',
      'C\$': 'cad',
      'kr': 'sek',
      '₽': 'rub',
      '₩': 'krw',
      '฿': 'thb',
      '₪': 'ils',
      'R': 'zar',
      '₱': 'php',
      'RM': 'myr',
      'Rp': 'idr',
      '₫': 'vnd',
      '₺': 'try',
      'zł': 'pln',
      'Kč': 'czk',
      'Ft': 'huf',
      'lei': 'ron',
      'лв': 'bgn',
      'din': 'rsd',
      'DKK': 'dkk',
      'NOK': 'nok',
      'NZ\$': 'nzd',
      'S\$': 'sgd',
      'HK\$': 'hkd',
    };

    final lower = currency.toLowerCase();
    if (lower.length == 3 && RegExp(r'^[a-z]{3}$').hasMatch(lower)) {
      return lower;
    }
    return currencyMap[currency] ?? 'eur';
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
