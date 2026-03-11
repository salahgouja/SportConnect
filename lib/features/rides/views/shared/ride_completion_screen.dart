import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_completion_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Ride Completion / Trip Summary screen shown after a ride finishes.
///
/// Displays:
/// - Success confetti-style header
/// - Route summary with origin/destination
/// - Trip duration, distance, and CO2 saved
/// - Fare breakdown (base, service fee, total)
/// - Driver/rider info with avatar and rating
/// - Share receipt
/// - Rating & review CTA
class RideCompletionScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideCompletionScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideCompletionScreen> createState() =>
      _RideCompletionScreenState();
}

class _RideCompletionScreenState extends ConsumerState<RideCompletionScreen> {
  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final uiState = ref.watch(rideCompletionUiViewModelProvider(widget.rideId));
    final bookings =
        ref.watch(bookingsByRideProvider(widget.rideId)).value ??
        const <RideBooking>[];
    final l10n = AppLocalizations.of(context);

    ref.listen<RideCompletionUiState>(
      rideCompletionUiViewModelProvider(widget.rideId),
      (previous, next) {
        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage &&
            context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
                SizedBox(height: 16.h),
                Text(
                  l10n.somethingWentWrong,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Unable to load ride completion details.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(rideStreamProvider(widget.rideId)),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (ride) {
          if (ride == null) {
            return Center(child: Text(l10n.rideNotFound));
          }
          return _buildContent(context, ref, ride, l10n, bookings, uiState);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
    List<RideBooking> bookings,
    RideCompletionUiState uiState,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Success header
            _buildSuccessHeader(context)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            SizedBox(height: 24.h),

            // Route map summary
            Builder(
              builder: (_) {
                if (uiState.osrmRouteRideId != ride.id) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(
                          rideCompletionUiViewModelProvider(
                            widget.rideId,
                          ).notifier,
                        )
                        .ensureRouteLoaded(ride);
                  });
                }
                return _buildCompletedRouteMap(ride, uiState);
              },
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 16.h),

            // Environmental impact card
            _buildImpactCard(
              context,
              ride,
              bookings,
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Trip summary card
            _buildTripSummaryCard(
              context,
              ride,
              dateFormat,
              timeFormat,
              l10n,
              bookings,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Fare breakdown card
            _buildFareBreakdownCard(
              context,
              ride,
              l10n,
              bookings,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Driver/Rider info card
            _buildParticipantCard(
              context,
              ref,
              ride,
              l10n,
            ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05),

            SizedBox(height: 32.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Show different rating CTA depending on the user's role
                  Builder(
                    builder: (ctx) {
                      final uid = ref.read(currentUserProvider).value?.uid;
                      final isDriver = uid == ride.driverId;

                      return SizedBox(
                        width: double.infinity,
                        child: isDriver
                            ? PremiumButton(
                                text: 'Rate Passenger',
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  context.push(
                                    AppRoutes.driverRatePassenger.path
                                        .replaceFirst(':rideId', widget.rideId),
                                  );
                                },
                                icon: Icons.star_rounded,
                              )
                            : PremiumButton(
                                text: 'Rate & Review',
                                onPressed: () async {
                                  HapticFeedback.mediumImpact();

                                  // Fetch driver profile to get name for review screen
                                  final driverProfile = await ref.read(
                                    userProfileProvider(ride.driverId).future,
                                  );

                                  if (!ctx.mounted) return;

                                  ctx.push(
                                    '${AppRoutes.submitReview.path}'
                                    '?rideId=${widget.rideId}'
                                    '&revieweeId=${ride.driverId}'
                                    '&revieweeName=${Uri.encodeComponent(driverProfile?.displayName ?? 'Driver')}'
                                    '&reviewType=driverReview',
                                  );
                                },
                                icon: Icons.star_rounded,
                              ),
                      );
                    },
                  ).animate().fadeIn(delay: 550.ms),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: uiState.isGeneratingPdf
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : PremiumButton(
                                text: 'Share Receipt',
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  await ref
                                      .read(
                                        rideCompletionUiViewModelProvider(
                                          widget.rideId,
                                        ).notifier,
                                      )
                                      .shareReceipt(ride);
                                },
                                style: PremiumButtonStyle.secondary,
                                icon: Icons.receipt_long_rounded,
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: PremiumButton(
                          text: 'Report Issue',
                          onPressed: () {
                            context.pushNamed(
                              AppRoutes.dispute.name,
                              pathParameters: {'id': widget.rideId},
                            );
                          },
                          style: PremiumButtonStyle.ghost,
                          icon: Icons.flag_outlined,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 650.ms),

                  SizedBox(height: 12.h),

                  // Quick Rebook button
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: 'Book This Route Again',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.pushNamed(
                          AppRoutes.searchRides.name,
                          extra: <String, dynamic>{
                            'address': ride.destination.address,
                            'latitude': ride.destination.latitude,
                            'longitude': ride.destination.longitude,
                          },
                        );
                      },
                      style: PremiumButtonStyle.secondary,
                      icon: Icons.replay_rounded,
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  SizedBox(height: 16.h),

                  TextButton(
                    onPressed: () => context.go(AppRoutes.home.path),
                    child: Text(
                      l10n.goHome,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 750.ms),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.15),
                AppColors.success.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 64.sp,
            color: AppColors.success,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Trip Completed!',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Thanks for riding with SportConnect',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    BuildContext context,
    RideModel ride,
    List<RideBooking> bookings,
  ) {
    // Estimate: carpooling saves ~120g CO2/km on average
    final riders = bookings.length.clamp(1, 10);
    final distanceKm = ride.route.distanceKm ?? 15.0;
    final co2SavedKg = (riders * 0.12 * distanceKm).toStringAsFixed(1);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF43A047).withValues(alpha: 0.12),
            const Color(0xFF66BB6A).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 24.sp,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You helped save $co2SavedKg kg CO₂',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'By sharing this ride with $riders other '
                  '${riders == 1 ? 'person' : 'people'}',
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
    );
  }

  Widget _buildCompletedRouteMap(
    RideModel ride,
    RideCompletionUiState uiState,
  ) {
    final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dest = LatLng(ride.destination.latitude, ride.destination.longitude);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    final routePoints = uiState.osrmRoutePoints ?? [origin, dest];

    return Container(
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sportconnect.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6.0,
                    color: Colors.white,
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.white,
                  ),
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.success,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: origin,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.success,
                      size: 22.sp,
                    ),
                  ),
                  Marker(
                    point: dest,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // "Completed" badge overlay
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Distance / duration overlay
          if (ride.route.distanceKm != null ||
              ride.route.durationMinutes != null)
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ride.route.distanceKm != null) ...[
                      Icon(
                        Icons.straighten_rounded,
                        size: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDistance,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    if (ride.route.distanceKm != null &&
                        ride.route.durationMinutes != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    if (ride.route.durationMinutes != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDuration,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(
    BuildContext context,
    RideModel ride,
    DateFormat dateFormat,
    DateFormat timeFormat,
    AppLocalizations l10n,
    List<RideBooking> bookings,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Route
          _buildRouteRow(
            Icons.trip_origin_rounded,
            AppColors.success,
            ride.origin.address,
          ),
          _buildRouteLine(),
          _buildRouteRow(
            Icons.location_on_rounded,
            AppColors.error,
            ride.destination.address,
          ),

          Divider(height: 28.h, color: AppColors.border),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.calendar_today_rounded,
                dateFormat.format(ride.departureTime),
                'Date',
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.access_time_rounded,
                timeFormat.format(ride.departureTime),
                'Time',
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.people_rounded,
                '${bookings.length}',
                'Riders',
              ),
            ],
          ),

          // Distance / Duration / Speed row
          if (ride.route.distanceKm != null ||
              ride.route.durationMinutes != null) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.border),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (ride.route.distanceKm != null)
                  _buildStatItem(
                    Icons.straighten_rounded,
                    ride.route.formattedDistance,
                    'Distance',
                  ),
                if (ride.route.distanceKm != null &&
                    ride.route.durationMinutes != null)
                  _buildStatDivider(),
                if (ride.route.durationMinutes != null)
                  _buildStatItem(
                    Icons.timer_outlined,
                    ride.route.formattedDuration,
                    'Duration',
                  ),
                if (ride.route.durationMinutes != null &&
                    ride.route.distanceKm != null) ...[
                  _buildStatDivider(),
                  _buildStatItem(
                    Icons.speed_rounded,
                    '${((ride.route.distanceKm! / (ride.route.durationMinutes! / 60))).round()} km/h',
                    'Avg Speed',
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Padding(
      padding: EdgeInsets.only(left: 9.w),
      child: Container(height: 24.h, width: 2, color: AppColors.border),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 32.h, width: 1, color: AppColors.border);
  }

  Widget _buildFareBreakdownCard(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
    List<RideBooking> bookings,
  ) {
    // Determine actual seats booked by the current user
    final currentUid = ref.read(currentUserProvider).value?.uid;
    final isDriver = currentUid == ride.driverId;
    final myBooking = bookings
        .where((b) => b.passengerId == currentUid)
        .firstOrNull;
    final seatsBooked = myBooking?.seatsBooked ?? 1;

    final pricePerSeat = ride.pricePerSeat;
    final baseFare = isDriver
        ? pricePerSeat * (ride.bookedSeats > 0 ? ride.bookedSeats : 1)
        : pricePerSeat * seatsBooked;
    final serviceFee = (baseFare * 0.10).roundToDouble();
    final total = baseFare + serviceFee;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
                'Fare Breakdown',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFareRow(
            isDriver
                ? 'Base Fare (${ride.bookedSeats > 0 ? ride.bookedSeats : 1} seat${(ride.bookedSeats > 1) ? 's' : ''})'
                : seatsBooked > 1
                ? 'Base Fare ($seatsBooked seats × ${pricePerSeat.toStringAsFixed(2)})'
                : 'Base Fare',
            '${baseFare.toStringAsFixed(2)} ${ride.currency ?? 'EUR'}',
          ),
          SizedBox(height: 8.h),
          _buildFareRow(
            'Service Fee (10%)',
            '${serviceFee.toStringAsFixed(2)} ${ride.currency ?? 'EUR'}',
          ),
          Divider(height: 24.h),
          _buildFareRow(
            'Total',
            '${total.toStringAsFixed(2)} ${ride.currency ?? 'EUR'}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Row(
            children: [
              PremiumAvatar(imageUrl: photoUrl, name: displayName, size: 48),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${rating.average.toStringAsFixed(1)} rating',
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
              IconButton(
                tooltip: 'Message driver',
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null) return;

                  try {
                    final chat = await ref.read(
                      getOrCreateChatProvider(
                        userId1: currentUser.uid,
                        userId2: ride.driverId,
                        userName1: currentUser.displayName,
                        userName2: displayName,
                        userPhoto1: currentUser.photoUrl,
                        userPhoto2: photoUrl,
                      ).future,
                    );

                    if (!context.mounted) return;

                    final driverUser = UserModel.driver(
                      uid: ride.driverId,
                      email: '',
                      displayName: displayName,
                      photoUrl: photoUrl,
                    );

                    context.pushNamed(
                      AppRoutes.chatDetail.name,
                      pathParameters: {'id': chat.id},
                      extra: driverUser,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to open chat. Please try again.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
