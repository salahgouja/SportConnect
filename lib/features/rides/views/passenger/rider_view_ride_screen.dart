import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/features/reviews/repositories/review_repository.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/core/utils/distance_formatter.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';

/// Rider's dedicated screen for viewing ride details and booking
/// Clean, informative UI with easy booking flow
class RiderViewRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RiderViewRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<RiderViewRideScreen> createState() =>
      _RiderViewRideScreenState();
}

class _RiderViewRideScreenState extends ConsumerState<RiderViewRideScreen> {
  int _seatsToBook = 1;
  String _note = '';
  bool _isBooking = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailViewModelProvider(widget.rideId));

    return rideAsync.when(
      data: (ride) => _buildContent(ride),
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).rideDetails),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).rideDetails),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).couldnTLoadRide,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              PremiumButton(
                text: 'Go Back',
                onPressed: () => context.pop(),
                style: PremiumButtonStyle.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RideModel? ride) {
    if (ride == null) {
      return _buildErrorState(AppLocalizations.of(context).rideNotFound);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(ride),
          SliverToBoxAdapter(child: _buildDriverCard(ride)),
          SliverToBoxAdapter(child: _buildRouteCard(ride)),
          SliverToBoxAdapter(child: _buildDetailsCard(ride)),
          SliverToBoxAdapter(child: _buildPreferencesCard(ride)),
          if (ride.reviewCount > 0)
            SliverToBoxAdapter(child: _buildReviewsSection(ride)),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
      bottomSheet: _buildBookingBar(ride),
    );
  }

  Widget _buildSliverAppBar(RideModel ride) {
    return SliverAppBar(
      expandedHeight: 220.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: 'Go back',
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Share ride',
          onPressed: () => _shareRide(ride),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share_rounded, color: Colors.white, size: 18.sp),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Mini map preview
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  (ride.origin.latitude + ride.destination.latitude) / 2,
                  (ride.origin.longitude + ride.destination.longitude) / 2,
                ),
                initialZoom: 10,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        ride.origin.latitude,
                        ride.origin.longitude,
                      ),
                      width: 32.w,
                      height: 32.w,
                      child: Icon(
                        Icons.trip_origin_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    Marker(
                      point: LatLng(
                        ride.destination.latitude,
                        ride.destination.longitude,
                      ),
                      width: 32.w,
                      height: 32.w,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.error,
                        size: 28.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            // Date and Price overlay
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context).perSeat2,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(RideModel ride) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              DriverAvatarWidget(driverId: ride.driverId, radius: 28),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: DriverNameWidget(
                            driverId: ride.driverId,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.verified_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        DriverRatingWidget(
                          driverId: ride.driverId,
                          showIcon: true,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).valueRides(ride.bookings.length),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Message button
              IconButton(
                tooltip: 'Message driver',
                onPressed: () => _openChat(ride),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          if (ride.vehicleInfo != null) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    ride.vehicleInfo!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal_rounded,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).valueLeft(ride.remainingSeats),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).route,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Origin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primary, AppColors.error],
                          ),
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
                          DateFormat('HH:mm').format(ride.departureTime),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          ride.origin.address,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Destination
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.error,
                    size: 16.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ride.arrivalTime != null)
                          Text(
                            DateFormat('HH:mm').format(ride.arrivalTime!),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          )
                        else if (ride.durationMinutes != null)
                          Text(
                            AppLocalizations.of(
                              context,
                            ).valueMin2(ride.durationMinutes!),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        SizedBox(height: 4.h),
                        Text(
                          ride.destination.address,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (ride.distanceKm != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ecoGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco_rounded,
                        size: 16.sp,
                        color: AppColors.ecoGreen,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        AppLocalizations.of(context).valueKgCoSavedPer(
                          ride.co2SavedPerPassenger.toStringAsFixed(1),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ecoGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailsCard(RideModel ride) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).rideDetails,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Details grid
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (ride.distanceKm != null)
                    _buildDetailChip(
                      Icons.straighten_rounded,
                      ref.watch(distanceFormatterProvider)(ride.distanceKm!),
                    ),
                  if (ride.durationMinutes != null)
                    _buildDetailChip(
                      Icons.timer_outlined,
                      AppLocalizations.of(
                        context,
                      ).valueMin(ride.durationMinutes!),
                    ),
                  _buildDetailChip(
                    Icons.event_seat_rounded,
                    AppLocalizations.of(
                      context,
                    ).valueSeats(ride.remainingSeats),
                  ),
                  if (ride.isPriceNegotiable)
                    _buildDetailChip(
                      Icons.handshake_rounded,
                      AppLocalizations.of(context).negotiable,
                      highlight: true,
                    ),
                  if (ride.acceptsOnlinePayment)
                    _buildDetailChip(
                      Icons.credit_card_rounded,
                      AppLocalizations.of(context).onlinePay,
                    ),
                ],
              ),

              if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          ride.notes!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDetailChip(
    IconData icon,
    String label, {
    bool highlight = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primarySurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
        border: highlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: highlight ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(RideModel ride) {
    final preferences = <MapEntry<IconData, String>>[];

    if (ride.allowLuggage) {
      preferences.add(MapEntry(Icons.luggage_rounded, 'Luggage OK'));
    }
    if (ride.allowPets) {
      preferences.add(MapEntry(Icons.pets_rounded, 'Pets OK'));
    }
    if (!ride.allowSmoking) {
      preferences.add(MapEntry(Icons.smoke_free_rounded, 'No smoking'));
    }
    if (ride.isWomenOnly) {
      preferences.add(MapEntry(Icons.female_rounded, 'Women only'));
    }
    if (ride.allowChat) {
      preferences.add(MapEntry(Icons.chat_rounded, 'Chat enabled'));
    }

    if (preferences.isEmpty) return const SizedBox.shrink();

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).preferences,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: preferences
                    .map(
                      (pref) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pref.key,
                              size: 14.sp,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              pref.value,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildReviewsSection(RideModel ride) {
    if (ride.reviewCount == 0) return const SizedBox.shrink();

    final reviewsAsync = ref.watch(rideReviewsProvider(ride.id));

    return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.rate_review_rounded,
                    size: 18.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context).reviews,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    ride.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '(${ride.reviewCount} reviews)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Fetch and display individual reviews
              reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return Text(
                      AppLocalizations.of(context).noReviewsYet,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textTertiary,
                      ),
                    );
                  }
                  return Column(
                    children: reviews
                        .take(3)
                        .map((review) => _buildReviewItem(review))
                        .toList(),
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, _) => Text(
                  AppLocalizations.of(context).failedToLoadReviews,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }

  /// Builds a single review item card.
  Widget _buildReviewItem(ReviewModel review) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 10.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: review.reviewerPhotoUrl != null
                    ? NetworkImage(review.reviewerPhotoUrl!)
                    : null,
                child: review.reviewerPhotoUrl == null
                    ? Text(
                        review.reviewerName.isNotEmpty
                            ? review.reviewerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(fontSize: 14.sp),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14.sp,
                            color: AppColors.warning,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          DateFormat('MMM d, y').format(review.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.comment!,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (review.tags.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: review.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingBar(RideModel ride) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isOwnRide = currentUser?.uid == ride.driverId;
    final canBook = ride.isBookable && !isOwnRide;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seat selector
            if (canBook && ride.remainingSeats > 1) ...[
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).seats3,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          ride.remainingSeats,
                          (i) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _seatsToBook = i + 1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 8.w),
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: _seatsToBook == i + 1
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context).value2(i + 1),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _seatsToBook == i + 1
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '\$${(ride.pricePerSeat * _seatsToBook).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // Book button
            PremiumButton(
              text: isOwnRide
                  ? 'This is your ride'
                  : canBook
                  ? (_isBooking
                        ? 'Booking...'
                        : 'Book $_seatsToBook ${_seatsToBook == 1 ? 'Seat' : 'Seats'}')
                  : ride.isFull
                  ? 'Ride is full'
                  : 'Unavailable',
              onPressed: canBook ? () => _showBookingConfirmation(ride) : null,
              isLoading: _isBooking,
              style: canBook
                  ? PremiumButtonStyle.primary
                  : PremiumButtonStyle.ghost,
              icon: canBook ? Icons.check_circle_outline_rounded : null,
            ),
          ],
        ),
      ),
    );
  }

  // === Actions ===

  Future<void> _shareRide(RideModel ride) async {
    HapticFeedback.lightImpact();

    try {
      // Generate shareable HTTPS link via app_links
      final dynamicLink = await DeepLinkService.instance.generateRideLink(
        rideId: ride.id,
        fromCity: ride.origin.city ?? ride.origin.address,
        toCity: ride.destination.city ?? ride.destination.address,
        price: ride.pricePerSeat,
        seats: ride.remainingSeats,
        departureTime: ride.departureTime,
      );

      final shareText =
          '🚗 Check out this ride on SportConnect!\n\n'
          '📍 ${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}\n'
          '📅 ${DateFormat('MMM d, h:mm a').format(ride.departureTime)}\n'
          '💰 ${ride.pricePerSeat.toStringAsFixed(0)} € per seat\n'
          '🪑 ${ride.remainingSeats} seats available\n\n'
          'Join me for a comfortable ride! 🌱\n\n'
          '🔗 $dynamicLink';

      await SharePlus.instance.share(
        ShareParams(text: shareText, subject: 'Carpool ride on SportConnect'),
      );
    } catch (e) {
      // Fallback to basic share with HTTPS link
      await SharePlus.instance.share(
        ShareParams(
          text:
              '🚗 Check out this ride on SportConnect!\n\n'
              '📍 ${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}\n'
              '📅 ${DateFormat('MMM d, h:mm a').format(ride.departureTime)}\n'
              '💰 ${ride.pricePerSeat.toStringAsFixed(0)} € per seat\n'
              '🪑 ${ride.remainingSeats} seats available\n\n'
              'Join me for a comfortable ride! 🌱\n\n'
              '🔗 https://${DeepLinkService.hostingDomain}/ride/${widget.rideId}',
          subject: 'Carpool ride on SportConnect',
        ),
      );
    }
  }

  Future<void> _openChat(RideModel ride) async {
    HapticFeedback.lightImpact();

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch driver profile to get name and photo
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );

      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: ride.driverId,
          userName1: currentUser.displayName,
          userName2: driverProfile.displayName,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: driverProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: driverProfile,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to open chat. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBookingConfirmation(RideModel ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context).confirmBooking,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // Summary
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      AppLocalizations.of(context).seats2,
                      AppLocalizations.of(context).value2(_seatsToBook),
                    ),
                    SizedBox(height: 8.h),
                    _buildSummaryRow(
                      AppLocalizations.of(context).pricePerSeat2,
                      '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                    ),
                    SizedBox(height: 8.h),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 8.h),
                    _buildSummaryRow(
                      AppLocalizations.of(context).total,
                      '\$${(ride.pricePerSeat * _seatsToBook).toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Optional note
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).addANoteToThe,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                ),
                maxLines: 2,
                onChanged: (v) => _note = v,
              ),

              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      style: PremiumButtonStyle.secondary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: PremiumButton(
                      text: 'Confirm Booking',
                      onPressed: () {
                        Navigator.pop(context);
                        _bookRide(ride);
                      },
                      style: PremiumButtonStyle.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _bookRide(RideModel ride) async {
    HapticFeedback.mediumImpact();
    setState(() => _isBooking = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('Please sign in to book a ride');
      }

      final booking = RideBooking(
        id: '', // Will be set by repository
        rideId: widget.rideId,
        passengerId: currentUser.uid,
        seatsBooked: _seatsToBook,
        status: BookingStatus.pending,
        note: _note.isNotEmpty ? _note : null,
        createdAt: DateTime.now(),
      );

      await ref
          .read(rideActionsViewModelProvider)
          .bookRide(rideId: ride.id, booking: booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Text(AppLocalizations.of(context).bookingRequestSent),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        context.go(AppRoutes.riderMyRides.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking failed. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }
}
