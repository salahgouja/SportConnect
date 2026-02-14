import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

part 'active_ride_screen.g.dart';

/// Active Ride Screen  - shows real-time ride status from Firestore
class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const ActiveRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(activeRideStreamProvider(widget.rideId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        data: (ride) => ride == null
            ? _buildRideNotFound()
            : _buildActiveRideContent(context, ride),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).failedToLoadRide,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                e.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).rideNotFound,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).thisRideMayHaveBeen,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          PremiumButton(
            text: 'Go Home',
            onPressed: () => context.go(AppRoutes.splash.path),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideContent(BuildContext context, RideModel ride) {
    final driverAsync = ref.watch(userStreamProvider(ride.driverId));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ride)),
        SliverToBoxAdapter(
          child: _buildStatusSection(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: driverAsync
              .when(
                data: (driver) => _buildDriverInfo(context, driver, ride),
                loading: () => const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: _buildRouteDetails(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: _buildPassengersList(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(
          child: _buildActionButtons(context, ride)
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, RideModel ride) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.heroGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Spacer(),
                  _buildStatusBadge(ride.status),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).activeRide,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _formatDateTime(ride.departureTime),
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RideStatus status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case RideStatus.draft:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.2);
        textColor = AppColors.textSecondary;
        label = 'Draft';
        icon = Icons.edit_outlined;
        break;
      case RideStatus.active:
        bgColor = AppColors.info.withValues(alpha: 0.2);
        textColor = AppColors.info;
        label = 'Active';
        icon = Icons.check_circle_outline;
        break;
      case RideStatus.full:
        bgColor = AppColors.warning.withValues(alpha: 0.2);
        textColor = AppColors.warning;
        label = 'Full';
        icon = Icons.people;
        break;
      case RideStatus.inProgress:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'In Progress';
        icon = Icons.directions_car;
        break;
      case RideStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'Completed';
        icon = Icons.done_all;
        break;
      case RideStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.2);
        textColor = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusStep(
            AppLocalizations.of(context).rideConfirmed,
            ride.status.index >= RideStatus.active.index,
            Icons.check_circle,
          ),
          _buildStatusDivider(ride.status.index >= RideStatus.inProgress.index),
          _buildStatusStep(
            AppLocalizations.of(context).driverOnTheWay,
            ride.status.index >= RideStatus.inProgress.index,
            Icons.directions_car,
          ),
          _buildStatusDivider(ride.status == RideStatus.completed),
          _buildStatusStep(
            AppLocalizations.of(context).rideCompleted,
            ride.status == RideStatus.completed,
            Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isCompleted, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isCompleted ? Colors.white : AppColors.textTertiary,
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isCompleted
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          Icon(Icons.check, size: 20.sp, color: AppColors.success),
      ],
    );
  }

  Widget _buildStatusDivider(bool isActive) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24.h,
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(
    BuildContext context,
    UserModel? driver,
    RideModel ride,
  ) {
    if (driver == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundImage: driver.photoUrl != null
                ? NetworkImage(driver.photoUrl!)
                : null,
            child: driver.photoUrl == null
                ? Text(
                    driver.displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (driver.isIdVerified)
                      Icon(Icons.verified, size: 16.sp, color: Colors.blue),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      driver.rating.average.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).valueRides2(driver.rating.total),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _sendMessage(driver.uid),
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _callDriver(driver.phoneNumber),
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.phone, color: Colors.green, size: 20.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(BuildContext context, RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).routeDetails,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.my_location,
                  size: 18.sp,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).pickup,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.origin.address,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Dotted line
          Container(
            padding: EdgeInsets.only(left: 16.w),
            height: 24.h,
            width: 2,
            margin: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          // Destination
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).destination,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ride.destination.address,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          // Ride info row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoItem(
                icon: Icons.attach_money,
                value: AppLocalizations.of(
                  context,
                ).value5(ride.pricePerSeat.toStringAsFixed(0)),
                label: AppLocalizations.of(context).perSeat2,
              ),
              InfoItem(
                icon: Icons.event_seat,
                value: AppLocalizations.of(
                  context,
                ).valueValue(ride.remainingSeats, ride.availableSeats),
                label: AppLocalizations.of(context).seatsLeft,
              ),
              InfoItem(
                icon: Icons.access_time,
                value: _formatTime(ride.departureTime),
                label: AppLocalizations.of(context).departure,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersList(BuildContext context, RideModel ride) {
    final passengers = ride.acceptedBookings;

    if (passengers.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 40.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).noPassengersYet,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).passengersValue(passengers.length),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...passengers.map(
            (booking) => _buildPassengerItem(booking.passengerId),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(String passengerId) {
    final passengerAsync = ref.watch(userStreamProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        if (passenger == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: passenger.photoUrl != null
                    ? NetworkImage(passenger.photoUrl!)
                    : null,
                child: passenger.photoUrl == null
                    ? Text(passenger.displayName[0].toUpperCase())
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          passenger.rating.average.toStringAsFixed(1),
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
              IconButton(
                onPressed: () => _sendMessage(passenger.uid),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: const LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildActionButtons(BuildContext context, RideModel ride) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          if (ride.status == RideStatus.inProgress)
            PremiumButton(
              text: 'View on Map',
              icon: Icons.map_outlined,
              onPressed: () {
                // Open map view
              },
              style: PremiumButtonStyle.primary,
            ),
          SizedBox(height: 12.h),
          if (ride.status == RideStatus.draft ||
              ride.status == RideStatus.active)
            PremiumButton(
              text: 'Cancel Ride',
              icon: Icons.cancel_outlined,
              onPressed: () => _showCancelDialog(context, ride),
              style: PremiumButtonStyle.outline,
            ),
          if (ride.status == RideStatus.completed)
            PremiumButton(
              text: 'Rate & Review',
              icon: Icons.star_outline,
              onPressed: () => _showRatingDialog(context, ride),
              style: PremiumButtonStyle.primary,
            ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String recipientId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: recipientId,
          userName1: currentUser.displayName,
          userName2: 'Driver',
        ).future,
      );

      if (!mounted) return;

      final receiverUser = UserModel.driver(
        uid: recipientId,
        email: '',
        displayName: 'Driver',
      );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: receiverUser,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open chat: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _callDriver(String? phoneNumber) async {
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).phoneNumberNotAvailable),
        ),
      );
      return;
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).cannotMakePhoneCalls,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToLaunchDialer,
            ),
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, RideModel ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).cancelRide2),
        content: Text(AppLocalizations.of(context).areYouSureYouWant9),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppLocalizations.of(context).keepRide),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              _cancelRide(ride);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).cancelRide2),
          ),
        ],
      ),
    );
  }

  void _cancelRide(RideModel ride) async {
    try {
      await ref
          .read(rideActionsViewModelProvider)
          .cancelRide(ride.id, 'Cancelled by passenger');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).rideCancelledSuccessfully,
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToCancelRideValue(e),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showRatingDialog(BuildContext context, RideModel ride) async {
    // Fetch driver profile to get name for review screen
    final driverProfile = await ref.read(
      userProfileProvider(ride.driverId).future,
    );
    
    if (!mounted) return;

    // Navigate to the submit review screen for the driver
    context.push(
      '${AppRoutes.submitReview.path}'
      '?rideId=${ride.id}'
      '&revieweeId=${ride.driverId}'
      '&revieweeName=${Uri.encodeComponent(driverProfile?.displayName ?? 'Driver')}'
      '&reviewType=driverReview',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Stream provider for active ride - uses repository (MVVM pattern)
@riverpod
Stream<RideModel?> activeRideStream(Ref ref, String rideId) {
  return ref.watch(rideActionsViewModelProvider).streamRideById(rideId);
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: AppColors.primary),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
