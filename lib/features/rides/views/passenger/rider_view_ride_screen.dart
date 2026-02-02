import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/config/app_router.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

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
        title: const Text('Ride Details'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Ride Details'),
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
                'Couldn\'t load ride',
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
    if (ride == null) return _buildErrorState('Ride not found');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(ride),
          SliverToBoxAdapter(child: _buildDriverCard(ride)),
          SliverToBoxAdapter(child: _buildRouteCard(ride)),
          SliverToBoxAdapter(child: _buildDetailsCard(ride)),
          SliverToBoxAdapter(child: _buildPreferencesCard(ride)),
          if (ride.reviews.isNotEmpty)
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
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
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
          onPressed: () => _shareRide(ride),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
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
                    AppColors.primary.withOpacity(0.9),
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
                          'per seat',
                          style: TextStyle(
                            fontSize: 10.sp,
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
              PremiumAvatar(
                imageUrl: ride.driverPhotoUrl,
                name: ride.driverName,
                size: 56.w,
                hasBorder: true,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ride.driverName,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: AppColors.starFilled,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${(ride.driverRating ?? 0).toStringAsFixed(1)} • ',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${ride.bookings.length} rides',
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
                        '${ride.remainingSeats} left',
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
              Icon(Icons.route_rounded, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Route',
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
                        '~${ride.durationMinutes} min',
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.ecoGreen.withOpacity(0.1),
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
                    '${ride.co2SavedPerPassenger.toStringAsFixed(1)} kg CO₂ saved per person',
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
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
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
                    'Ride Details',
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
                      '${ride.distanceKm!.toStringAsFixed(1)} km',
                    ),
                  if (ride.durationMinutes != null)
                    _buildDetailChip(
                      Icons.timer_outlined,
                      '${ride.durationMinutes} min',
                    ),
                  _buildDetailChip(
                    Icons.event_seat_rounded,
                    '${ride.remainingSeats} seats',
                  ),
                  if (ride.isPriceNegotiable)
                    _buildDetailChip(
                      Icons.handshake_rounded,
                      'Negotiable',
                      highlight: true,
                    ),
                  if (ride.acceptsOnlinePayment)
                    _buildDetailChip(Icons.credit_card_rounded, 'Online Pay'),
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
            ? Border.all(color: AppColors.primary.withOpacity(0.3))
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

    if (ride.allowLuggage)
      preferences.add(MapEntry(Icons.luggage_rounded, 'Luggage OK'));
    if (ride.allowPets)
      preferences.add(MapEntry(Icons.pets_rounded, 'Pets OK'));
    if (!ride.allowSmoking)
      preferences.add(MapEntry(Icons.smoke_free_rounded, 'No smoking'));
    if (ride.isWomenOnly)
      preferences.add(MapEntry(Icons.female_rounded, 'Women only'));
    if (ride.allowChat)
      preferences.add(MapEntry(Icons.chat_rounded, 'Chat enabled'));

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
                    'Preferences',
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
    if (ride.reviews.isEmpty) return const SizedBox.shrink();

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
                    'Reviews',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {}, // TODO: Show all reviews
                    child: Text('See all', style: TextStyle(fontSize: 13.sp)),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Show first 2 reviews
              ...ride.reviews.take(2).map((review) => _buildReviewTile(review)),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildReviewTile(RideReview review) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: review.reviewerPhotoUrl != null
                ? NetworkImage(review.reviewerPhotoUrl!)
                : null,
            backgroundColor: AppColors.primarySurface,
            child: review.reviewerPhotoUrl == null
                ? Text(
                    review.reviewerName.isNotEmpty
                        ? review.reviewerName[0]
                        : '?',
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.reviewerName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 14.sp,
                        color: i < review.rating
                            ? AppColors.starFilled
                            : AppColors.starEmpty,
                      ),
                    ),
                  ],
                ),
                if (review.comment != null && review.comment!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      review.comment!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
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
            color: Colors.black.withOpacity(0.08),
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
                    'Seats:',
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
                                  '${i + 1}',
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

  void _shareRide(RideModel ride) {
    HapticFeedback.lightImpact();
    // TODO: Implement share functionality
  }

  void _openChat(RideModel ride) {
    HapticFeedback.lightImpact();
    context.push('${AppRouter.chat}/${ride.driverId}');
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
                'Confirm Booking',
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
                    _buildSummaryRow('Seats', '$_seatsToBook'),
                    SizedBox(height: 8.h),
                    _buildSummaryRow(
                      'Price per seat',
                      '\$${ride.pricePerSeat.toStringAsFixed(0)}',
                    ),
                    SizedBox(height: 8.h),
                    Divider(color: AppColors.divider),
                    SizedBox(height: 8.h),
                    _buildSummaryRow(
                      'Total',
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
                  hintText: 'Add a note to the driver (optional)',
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
        passengerId: currentUser.uid,
        passengerName: currentUser.displayName,
        passengerPhotoUrl: currentUser.photoUrl,
        seatsBooked: _seatsToBook,
        status: BookingStatus.pending,
        note: _note.isNotEmpty ? _note : null,
        createdAt: DateTime.now(),
      );

      await ref
          .read(rideRepositoryProvider)
          .bookRide(rideId: ride.id, booking: booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                const Text('Booking request sent!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        context.go(AppRouter.riderMyRides);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
