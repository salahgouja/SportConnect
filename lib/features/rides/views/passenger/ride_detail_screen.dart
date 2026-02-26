import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/gamification_widgets.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/distance_formatter.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/features/rides/views/widgets/ride_shared_widgets.dart';

/// Full ride detail screen with map, route visualization, and booking flow.
///
/// Navigated to from search results, notifications, and deep links.
/// For a rider's personal booking view, see [RiderViewRideScreen].
class RideDetailScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideDetailScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  int _selectedSeats = 1;
  bool _isBooking = false;

  // Map and route state
  final MapController _mapController = MapController();
  RouteInfo? _routeInfo;
  bool _isLoadingRoute = false;

  Future<void> _loadRoute(RideModel ride) async {
    if (_isLoadingRoute || _routeInfo != null) return;
    setState(() => _isLoadingRoute = true);

    try {
      final fromCoords = LatLng(ride.origin.latitude, ride.origin.longitude);
      final toCoords = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );

      final route = await RoutingService.getRoute(
        origin: fromCoords,
        destination: toCoords,
      );

      if (route != null && mounted) {
        setState(() {
          _routeInfo = route;
          _isLoadingRoute = false;
        });

        if (route.coordinates.length >= 2) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            final bounds = LatLngBounds.fromPoints(route.coordinates);
            _mapController.fitCamera(
              CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(30.w)),
            );
          }
        }
      } else {
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailViewModelProvider(widget.rideId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => _buildErrorState(error.toString()),
        data: (ride) {
          if (ride == null) {
            return _buildErrorState(AppLocalizations.of(context).rideNotFound);
          }

          // Load route when ride data is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadRoute(ride);
          });

          return _buildContent(ride);
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220.h,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: List.generate(
                4,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).errorLoadingRide,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RideModel ride) {
    // Check if current user is the driver
    final currentUser = ref.watch(currentUserProvider).value;
    final isDriver = currentUser?.uid == ride.driverId;

    return Stack(
      children: [
        // Scrollable content
        CustomScrollView(
          slivers: [
            // App bar with map
            _buildSliverAppBar(ride),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Route card with proper spacing
                  _buildRouteCard(ride)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Driver info - only show for passengers
                  if (!isDriver)
                    _buildDriverCard(ride)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideX(begin: 0.1, curve: Curves.easeOutCubic),

                  // Trip details
                  _buildTripDetails(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms)
                      .slideX(begin: -0.1, curve: Curves.easeOutCubic),

                  // Car info
                  _buildCarInfo(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: 0.1, curve: Curves.easeOutCubic),

                  // Amenities
                  _buildAmenities(ride)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms)
                      .slideX(begin: -0.1, curve: Curves.easeOutCubic),

                  // Passengers section - show for both but with different context
                  if (ride.bookings.isNotEmpty)
                    _buildPassengers(ride, isDriver: isDriver)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Pending requests - only show for drivers
                  if (isDriver &&
                      ride.bookings.any(
                        (b) => b.status == BookingStatus.pending,
                      ))
                    _buildPendingRequests(ride)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 350.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  // Bottom padding for booking sheet - increased to prevent content hiding
                  SizedBox(height: 200.h),
                ],
              ),
            ),
          ],
        ),

        // Fixed bottom sheet - different for driver vs passenger
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: isDriver
              ? _buildDriverActionSheet(ride)
              : _buildBookingSheet(ride),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(RideModel ride) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => context.pop(),
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: AppSpacing.shadowSm,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Share ride',
          onPressed: () async {
            try {
              // Generate shareable HTTPS link via app_links
              final dynamicLink = await DeepLinkService.instance
                  .generateRideLink(
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
                ShareParams(
                  text: shareText,
                  subject: 'Carpool ride on SportConnect',
                ),
              );
            } catch (e) {
              // Fallback
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
          },
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: AppSpacing.shadowSm,
            ),
            child: Icon(
              Icons.share_outlined,
              size: 18.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Real Map with route
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  ride.origin.latitude,
                  ride.origin.longitude,
                ),
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
                if (_routeInfo != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routeInfo!.coordinates,
                        color: Colors.white,
                        strokeWidth: 5,
                      ),
                      Polyline(
                        points: _routeInfo!.coordinates,
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        ride.origin.latitude,
                        ride.origin.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                    Marker(
                      point: LatLng(
                        ride.destination.latitude,
                        ride.destination.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Route info badge
            if (_routeInfo != null)
              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: AppSpacing.shadowSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          AppLocalizations.of(context).valueValue6(
                            _routeInfo!.formattedDistance,
                            _routeInfo!.formattedDuration,
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isLoadingRoute)
              Container(
                decoration: BoxDecoration(gradient: AppColors.heroGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: 32.w,
                        height: 32.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context).loadingRoute,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppSpacing.shadowLg,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.success, AppColors.error],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.error,
                    size: 20.sp,
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.origin.city ?? 'Origin',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ride.origin.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.destination.city ?? 'Destination',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          ride.destination.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Divider(color: AppColors.border),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RideInfoChip(
                icon: Icons.access_time_rounded,
                value: '${ride.durationMinutes ?? 0} min',
                label: AppLocalizations.of(context).duration,
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              RideInfoChip(
                icon: Icons.straighten_rounded,
                value: ride.distanceKm != null
                    ? ref.watch(distanceFormatterProvider)(ride.distanceKm!)
                    : '0 km',
                label: AppLocalizations.of(context).distance,
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              RideInfoChip(
                icon: Icons.event_seat_rounded,
                value: '${ride.remainingSeats}',
                label: AppLocalizations.of(context).seatsLeft2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(RideModel ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () => context.pushNamed(
          AppRoutes.profile.path,
          pathParameters: {'userId': ride.driverId},
        ),
        child: PremiumCard(
          child: DriverInfoWidget(
            driverId: ride.driverId,
            builder: (context, displayName, photoUrl, rating) {
              return Row(
                children: [
                  LevelAvatar(
                    name: displayName,
                    imageUrl: photoUrl,
                    level: 5,
                    size: 60,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.xpGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: DriverRatingWidget(
                                driverId: ride.driverId,
                                showIcon: true,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.xpGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            RideDriverBadge(
                              icon: Icons.verified_user_rounded,
                              label: AppLocalizations.of(context).verified,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chat with driver',
                    onPressed: () => context.pushNamed(
                      AppRoutes.chat.path,
                      pathParameters: {'userId': ride.driverId},
                    ),
                    icon: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetails(RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).tripDetails,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            RideDetailInfoRow(
              icon: Icons.calendar_today_rounded,
              label: AppLocalizations.of(context).departure2,
              value: DateFormat(
                'EEE, MMM d • h:mm a',
              ).format(ride.departureTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfo(RideModel ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: AppColors.primary,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.vehicleInfo ?? 'Vehicle',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueTotalSeats(ride.availableSeats),
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
      ),
    );
  }

  Widget _buildAmenities(RideModel ride) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).amenities,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                RideAmenityChip(
                  icon: Icons.pets_rounded,
                  label: AppLocalizations.of(context).pets,
                  isAllowed: ride.allowPets,
                ),
                RideAmenityChip(
                  icon: Icons.smoking_rooms_rounded,
                  label: AppLocalizations.of(context).smoking,
                  isAllowed: ride.allowSmoking,
                ),
                RideAmenityChip(
                  icon: Icons.luggage_rounded,
                  label: AppLocalizations.of(context).luggage,
                  isAllowed: ride.allowLuggage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengers(RideModel ride, {bool isDriver = false}) {
    final acceptedBookings = ride.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDriver
                      ? AppLocalizations.of(
                          context,
                        ).yourPassengersValue(acceptedBookings.length)
                      : AppLocalizations.of(
                          context,
                        ).passengersValue(acceptedBookings.length),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isDriver)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).valueValueSeats(ride.bookedSeats, ride.availableSeats),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            if (acceptedBookings.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    isDriver
                        ? AppLocalizations.of(context).noPassengersAcceptedYet
                        : AppLocalizations.of(context).noPassengersBookedYet,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else if (isDriver)
              // Show detailed passenger list for drivers
              ...acceptedBookings.map((booking) => _buildPassengerItem(booking))
            else
              // Show compact view for other passengers
              Row(
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 40.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      acceptedBookings.length == 1
                          ? AppLocalizations.of(
                              context,
                            ).valueHasBookedThisRide('A passenger')
                          : AppLocalizations.of(
                              context,
                            ).valuePassengersHaveBooked(
                              acceptedBookings.length,
                            ),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerItem(RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          PassengerAvatarWidget(passengerId: booking.passengerId, radius: 22),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PassengerNameWidget(
                  passengerId: booking.passengerId,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context).valueSeatValueBooked2(
                    booking.seatsBooked,
                    booking.seatsBooked > 1 ? 's' : '',
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Chat button
          IconButton(
            tooltip: 'Chat with passenger',
            onPressed: () => context.pushNamed(
              AppRoutes.chat.path,
              pathParameters: {'userId': booking.passengerId},
            ),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build pending requests section for drivers
  Widget _buildPendingRequests(RideModel ride) {
    final pendingBookings = ride.bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.pending_actions_rounded,
                    size: 20.sp,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(
                    context,
                  ).pendingRequestsValue(pendingBookings.length),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...pendingBookings.map(
              (booking) => _buildPendingRequestItem(ride.id, booking),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestItem(String rideId, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PassengerAvatarWidget(
                passengerId: booking.passengerId,
                radius: 22,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PassengerNameWidget(
                      passengerId: booking.passengerId,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      AppLocalizations.of(context).valueSeatValueRequested(
                        booking.seatsBooked,
                        booking.seatsBooked > 1 ? 's' : '',
                      ),
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
          if (booking.note != null && booking.note!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      booking.note!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: 'Decline',
                  onPressed: () => _handleDeclineRequest(rideId, booking.id),
                  style: PremiumButtonStyle.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: PremiumButton(
                  text: 'Accept',
                  onPressed: () => _handleAcceptRequest(rideId, booking.id),
                  style: PremiumButtonStyle.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleAcceptRequest(String rideId, String bookingId) async {
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(rideDetailViewModelProvider(rideId).notifier)
          .acceptBooking(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).requestAccepted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorValue(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeclineRequest(String rideId, String bookingId) async {
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(rideDetailViewModelProvider(rideId).notifier)
          .rejectBooking(bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).requestDeclined)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorValue(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build driver action sheet (instead of booking sheet)
  Widget _buildDriverActionSheet(RideModel ride) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final pendingCount = ride.bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;
    final acceptedCount = ride.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .length;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Ride stats row
          Row(
            children: [
              // Seats info
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_seat_rounded,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).valueValue(ride.bookedSeats, ride.availableSeats),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppLocalizations.of(context).seatsBooked,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Pending requests
              if (pendingCount > 0)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pending_actions_rounded,
                              size: 18.sp,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              AppLocalizations.of(context).value2(pendingCount),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context).pending,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(width: 12.w),
              // Earnings preview
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).value5(
                          (ride.pricePerSeat * acceptedCount).toStringAsFixed(
                            0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppLocalizations.of(context).earnings,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Action buttons
          Row(
            children: [
              // Edit ride button (only if no accepted bookings)
              if (acceptedCount == 0 && ride.status == RideStatus.draft) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.pushNamed(
                        AppRoutes.driverOfferRide.name,
                        extra: ride,
                      );
                    },
                    icon: Icon(Icons.edit_rounded, size: 20.sp),
                    label: Text('Edit Ride'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              // Start ride button (if ride is upcoming and has passengers)
              Expanded(
                child: PremiumButton(
                  text: ride.status == RideStatus.active
                      ? 'View Active'
                      : 'Start Ride',
                  onPressed: acceptedCount > 0
                      ? () => context.pushNamed(
                          AppRoutes.driverActiveRide.name,
                          queryParameters: {'rideId': ride.id},
                        )
                      : null,
                  style: PremiumButtonStyle.primary,
                  icon: ride.status == RideStatus.active
                      ? Icons.visibility_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSheet(RideModel ride) {
    final totalPrice = ride.pricePerSeat * _selectedSeats;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final currencySymbol = _getCurrencySymbol(ride.currency ?? 'eur');

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 5,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48.w,
            height: 5.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),

          // Trip summary row
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                // Route icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                // Route info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).value2(
                          ride.origin.city ??
                              ride.origin.address.split(',').first,
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).value2(
                                ride.destination.city ??
                                    ride.destination.address.split(',').first,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Time badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(ride.departureTime),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(ride.departureTime),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Seat selector with modern design
          Row(
            children: [
              Text(
                AppLocalizations.of(context).seats2,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).valueAvailable(ride.remainingSeats),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
              const Spacer(),
              // Modern seat counter
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove_rounded,
                      onPressed: _selectedSeats > 1
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSeats--);
                            }
                          : null,
                      isEnabled: _selectedSeats > 1,
                    ),
                    Container(
                      width: 48.w,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).value2(_selectedSeats),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      icon: Icons.add_rounded,
                      onPressed: _selectedSeats < ride.remainingSeats
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSeats++);
                            }
                          : null,
                      isEnabled: _selectedSeats < ride.remainingSeats,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Price breakdown
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                  AppLocalizations.of(context).pricePerSeat2,
                  AppLocalizations.of(context).valueValue5(
                    currencySymbol,
                    ride.pricePerSeat.toStringAsFixed(2),
                  ),
                ),
                if (_selectedSeats > 1) ...[
                  SizedBox(height: 8.h),
                  _buildPriceRow(
                    AppLocalizations.of(context).numberOfSeats,
                    AppLocalizations.of(context).value12(_selectedSeats),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(
                    color: AppColors.border.withValues(alpha: 0.3),
                    height: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).total,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).valueValue5(
                        currencySymbol,
                        totalPrice.toStringAsFixed(2),
                      ),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Book button - full width, prominent
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: ride.remainingSeats > 0 && !_isBooking
                  ? () => _bookRide(ride)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: _isBooking
                  ? SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          AppLocalizations.of(context).bookNow,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 12.h),

          // Secure payment badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 6.w),
              Text(
                AppLocalizations.of(context).securePaymentWithStripe,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          child: Icon(
            icon,
            color: isEnabled ? AppColors.primary : AppColors.textTertiary,
            size: 22.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Gets the currency symbol for display
  String _getCurrencySymbol(String currency) {
    const symbolMap = {
      'eur': '€',
      'usd': '\$',
      'gbp': '£',
      'jpy': '¥',
      'inr': '₹',
      'chf': 'CHF ',
      'aud': 'A\$',
      'cad': 'C\$',
    };
    return symbolMap[currency.toLowerCase()] ?? '€';
  }

  /// Book ride with Stripe payment
  /// Flow: Create Payment Intent → Show Payment Sheet → Confirm Booking
  void _bookRide(RideModel ride) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseLogInToBook)),
      );
      return;
    }

    // Check if driver has set up payments
    if (!ride.acceptsOnlinePayment) {
      // Show cash payment option or driver hasn't enabled payments
      _showPaymentMethodDialog(ride, user);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _isBooking = true);

    try {
      // Import payment providers
      final paymentViewModel = ref.read(paymentViewModelProvider.notifier);

      // Fetch driver profile to get Stripe account ID and name
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );

      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      // Verify driver has Stripe Connect account for destination charges
      // Cast to DriverModel to access stripeAccountId
      final driverModel = driverProfile.asDriver;
      if (driverModel == null) {
        throw Exception('Driver profile is not a driver account');
      }

      final driverStripeAccountId = driverModel.stripeAccountId;
      if (driverStripeAccountId == null || driverStripeAccountId.isEmpty) {
        throw StripePaymentException(
          'Driver has not set up payment processing yet. Please contact the driver or choose cash payment.',
        );
      }

      // Get or create Stripe customer for the rider
      final customerId = await paymentViewModel.getOrCreateCustomer(
        userId: user.uid,
        email: user.email,
        name: user.displayName,
        phone: user.phoneNumber,
      );

      // Calculate total amount in main currency unit (server converts to cents)
      final totalAmount = ride.pricePerSeat * _selectedSeats;

      // Convert currency symbol to ISO code (Stripe requires ISO codes)
      final currencyIso = _getCurrencyIsoCode(ride.currency ?? 'eur');

      // Create payment intent via Firebase Cloud Function with driver's Stripe account
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
        driverStripeAccountId:
            driverStripeAccountId, // Pass driver's Stripe account
        description: '${ride.origin.address} → ${ride.destination.address}',
      );

      // Show Stripe Payment Sheet
      final paymentSuccess = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentData['clientSecret'],
        customerId: customerId,
        ephemeralKeySecret: paymentData['ephemeralKey'],
      );

      if (paymentSuccess) {
        // Payment successful - create the booking
        final bookingSuccess = await ref
            .read(rideDetailViewModelProvider(widget.rideId).notifier)
            .bookRide(
              passengerId: user.uid,
              seats: _selectedSeats,
              note: 'Payment: ${paymentData['paymentIntentId']}',
            );

        if (!mounted) return;
        setState(() => _isBooking = false);

        if (bookingSuccess) {
          _showPaymentSuccessDialog(totalAmount, ride.currency ?? '€');
        } else {
          // Payment succeeded but booking failed - this shouldn't happen
          // Payment will be auto-refunded or can be manually refunded
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).paymentSucceededButBookingFailed,
              ),
            ),
          );
        }
      } else {
        // Payment cancelled by user
        if (!mounted) return;
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).paymentCancelled),
          ),
        );
      }
    } on StripePaymentException catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).paymentFailedValue(e.message),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorValue(e))),
      );
    }
  }

  /// Show dialog for cash payment option
  void _showPaymentMethodDialog(RideModel ride, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).paymentMethod),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).thisDriverAcceptsCashPayment,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _buildPaymentOption(
              icon: Icons.money_rounded,
              title: AppLocalizations.of(context).payWithCash,
              subtitle:
                  '${(ride.pricePerSeat * _selectedSeats).toStringAsFixed(0)} ${ride.currency ?? '€'}',
              onTap: () {
                context.pop();
                _bookWithCash(ride, user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Book ride with cash payment (no Stripe)
  void _bookWithCash(RideModel ride, user) async {
    HapticFeedback.heavyImpact();
    setState(() => _isBooking = true);

    try {
      final success = await ref
          .read(rideDetailViewModelProvider(widget.rideId).notifier)
          .bookRide(
            passengerId: user.uid,
            seats: _selectedSeats,
            note: 'Payment: Cash',
          );

      if (!mounted) return;
      setState(() => _isBooking = false);

      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToBookRidePlease),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorValue(e))),
      );
    }
  }

  /// Show payment success dialog with receipt info
  void _showPaymentSuccessDialog(double amount, String currency) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).paymentSuccessful,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(
                context,
              ).youPaidValueValue(amount.toStringAsFixed(2), currency),
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).yourRideHasBeenBooked,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            PointsBadge(points: 25),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).youEarned25Xp,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'View My Rides',
              onPressed: () {
                context.pop();
                context.go(AppRoutes.riderMyRides.path);
              },
              style: PremiumButtonStyle.primary,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: Text(
                AppLocalizations.of(context).backToSearch,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show success dialog for cash booking
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).bookingConfirmed,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).yourRideHasBeenBooked2,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            PointsBadge(points: 25),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).youEarned25Xp,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'View My Rides',
              onPressed: () {
                context.pop();
                context.go(AppRoutes.riderMyRides.path);
              },
              style: PremiumButtonStyle.primary,
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                context.pop();
                context.pop();
              },
              child: Text(
                AppLocalizations.of(context).backToSearch,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts currency symbols to ISO codes for Stripe
  String _getCurrencyIsoCode(String currency) {
    // Map of common currency symbols to ISO codes
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

    // Check if it's already an ISO code (3 letters lowercase)
    final lower = currency.toLowerCase();
    if (lower.length == 3 && RegExp(r'^[a-z]{3}$').hasMatch(lower)) {
      return lower;
    }

    // Look up symbol in map
    return currencyMap[currency] ?? 'eur'; // Default to EUR
  }
}
