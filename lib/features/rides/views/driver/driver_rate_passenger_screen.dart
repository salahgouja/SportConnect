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
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_rate_passenger_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Post-ride screen where a driver rates their passenger(s).
///
/// Route: `/driver/rate-passenger/:rideId`
///
/// Navigated to from [RideCompletionScreen] when the authenticated user is
/// the driver of the completed ride.  The driver selects a passenger (if
/// multiple bookings), picks a 1–5 star rating, optionally adds a comment,
/// and submits via [ReviewRepository].
class DriverRatePassengerScreen extends ConsumerStatefulWidget {
  /// The completed ride ID.
  final String rideId;

  const DriverRatePassengerScreen({super.key, required this.rideId});

  @override
  ConsumerState<DriverRatePassengerScreen> createState() =>
      _DriverRatePassengerScreenState();
}

class _DriverRatePassengerScreenState
    extends ConsumerState<DriverRatePassengerScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(rideDetailViewModelProvider(widget.rideId));
    final formState = ref.watch(
      driverPassengerRatingViewModelProvider(widget.rideId),
    );

    final bookings = vmState.bookings
        .where(
          (b) =>
              b.status == BookingStatus.accepted ||
              b.status == BookingStatus.completed,
        )
        .toList();

    if (bookings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(
              driverPassengerRatingViewModelProvider(widget.rideId).notifier,
            )
            .syncBookings(bookings);
      });
    }

    ref.listen(driverPassengerRatingViewModelProvider(widget.rideId), (
      previous,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      if (next.isSubmitted &&
          previous?.isSubmitted != true &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(AppLocalizations.of(context).ratingSubmittedThankYou),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.go(AppRoutes.driverRides.path);
      }
    });

    return vmState.ride.when(
      data: (ride) {
        if (ride == null) {
          return _buildScaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).rideNotFound),
            ),
          );
        }
        return _buildContent(ride, bookings, formState);
      },
      loading: () => _buildScaffold(
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (e, _) => _buildScaffold(
        body: Center(child: Text(AppLocalizations.of(context).errorValue(e))),
      ),
    );
  }

  Scaffold _buildScaffold({required Widget body}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).ratePassenger),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _buildContent(
    RideModel ride,
    List<RideBooking> bookings,
    DriverPassengerRatingState formState,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).ratePassenger),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'How was your passenger?',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(),
            SizedBox(height: 6.h),
            Text(
              'Your honest feedback helps build a safer, more reliable community.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 28.h),

            if (bookings.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Text(
                    'No accepted passengers to rate for this ride.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              )
            else ...[
              // Passenger list (always shown, single-select)
              if (bookings.length > 1) ...[
                Text(
                  'Select passenger to rate',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              ...bookings.asMap().entries.map(
                (entry) => _buildPassengerTile(
                  entry.value,
                  isSelected: formState.selectedBookingId == entry.value.id,
                ).animate().slideY(delay: (entry.key * 80).ms),
              ),

              SizedBox(height: 28.h),

              // Star rating
              Text(
                'Rating',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starValue = (index + 1).toDouble();
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(
                              driverPassengerRatingViewModelProvider(
                                widget.rideId,
                              ).notifier,
                            )
                            .setRating(starValue);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child:
                            Icon(
                                  formState.rating >= starValue
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: formState.rating >= starValue
                                      ? AppColors.warning
                                      : AppColors.divider,
                                  size: 44.sp,
                                )
                                .animate(
                                  target: formState.rating >= starValue ? 1 : 0,
                                )
                                .scale(
                                  begin: const Offset(0.85, 0.85),
                                  end: const Offset(1, 1),
                                  duration: 200.ms,
                                  curve: Curves.easeOut,
                                ),
                      ),
                    );
                  }),
                ),
              ),

              if (formState.rating > 0) ...[
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    _getRatingLabel(formState.rating),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 200.ms),
                ),
              ],

              SizedBox(height: 24.h),

              // Comment field
              Text(
                'Comment (optional)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                onChanged: (v) => ref
                    .read(
                      driverPassengerRatingViewModelProvider(
                        widget.rideId,
                      ).notifier,
                    )
                    .setComment(v),
                controller: TextEditingController(text: formState.comment)
                  ..selection = TextSelection.collapsed(
                    offset: formState.comment.length,
                  ),
                maxLines: 4,
                maxLength: 300,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).ratePassengerCommentHint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  counterStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Submit button
              PremiumButton(
                text: AppLocalizations.of(context).submitRating,
                isLoading: formState.isSubmitting,
                isDisabled: !formState.canSubmit,
                onPressed: formState.canSubmit ? () => _submitRating() : null,
              ),
              SizedBox(height: 12.h),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.driverRides.path),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerTile(RideBooking booking, {required bool isSelected}) {
    final passengerAsync = ref.watch(userProfileProvider(booking.passengerId));

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref
            .read(
              driverPassengerRatingViewModelProvider(widget.rideId).notifier,
            )
            .selectBooking(booking);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            passengerAsync.when(
              data: (profile) => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withAlpha(30),
                backgroundImage: profile?.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: profile?.photoUrl == null
                    ? Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 22.sp,
                      )
                    : null,
              ),
              loading: () => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.surface,
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name & seats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  passengerAsync.when(
                    data: (profile) => Text(
                      profile?.displayName ?? 'Passenger',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    loading: () => Container(
                      height: 14.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    error: (_, __) => Text(
                      'Passenger',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    final l10n = AppLocalizations.of(context);
    if (rating >= 5) return l10n.ratingExcellent;
    if (rating >= 4) return l10n.ratingGood;
    if (rating >= 3) return l10n.ratingAverage;
    if (rating >= 2) return l10n.ratingBelowAverage;
    return l10n.ratingPoor;
  }

  Future<void> _submitRating() async {
    final formState = ref.read(
      driverPassengerRatingViewModelProvider(widget.rideId),
    );
    if (formState.selectedPassengerId == null || formState.rating <= 0) return;
    HapticFeedback.mediumImpact();

    try {
      final passengerProfile = ref
          .read(userProfileProvider(formState.selectedPassengerId!))
          .value;

      await ref
          .read(driverPassengerRatingViewModelProvider(widget.rideId).notifier)
          .submit(
            revieweeName: passengerProfile?.displayName ?? 'Passenger',
            revieweePhotoUrl: passengerProfile?.photoUrl,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToSubmitValue(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
