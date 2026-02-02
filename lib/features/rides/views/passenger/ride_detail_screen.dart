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
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/core/widgets/gamification_widgets.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/features/rides/models/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/core/config/app_router.dart';

/// Ride Detail Screen with booking functionality - Uses Firestore data
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
            return _buildErrorState('Ride not found');
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
            'Error loading ride',
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
            child: const Text('Go Back'),
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
          onPressed: () {
            Share.share(
              '🚗 Check out this ride on SportConnect!\n\n'
              '📍 ${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}\n'
              '📅 ${DateFormat('MMM d, h:mm a').format(ride.departureTime)}\n'
              '💰 ${ride.pricePerSeat.toStringAsFixed(0)} € per seat\n'
              '🪑 ${ride.remainingSeats} seats available\n\n'
              'Join me for a comfortable ride! 🌱\n\n'
              'Download SportConnect: https://sportconnect.app/ride/${widget.rideId}',
              subject: 'Carpool ride on SportConnect',
            );
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
                          border: Border.all(color: Colors.white, width: 2),
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
                          border: Border.all(color: Colors.white, width: 2),
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
                          '${_routeInfo!.formattedDistance} • ${_routeInfo!.formattedDuration}',
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
                        'Loading route...',
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
              _buildInfoChip(
                icon: Icons.access_time_rounded,
                value: '${ride.durationMinutes ?? 0} min',
                label: 'Duration',
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              _buildInfoChip(
                icon: Icons.straighten_rounded,
                value: '${ride.distanceKm?.toStringAsFixed(1) ?? '0'} km',
                label: 'Distance',
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              _buildInfoChip(
                icon: Icons.event_seat_rounded,
                value: '${ride.remainingSeats}',
                label: 'Seats left',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildDriverCard(RideModel ride) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: GestureDetector(
        onTap: () => context.push(AppRouter.userProfilePath(ride.driverId)),
        child: PremiumCard(
          child: Row(
            children: [
              LevelAvatar(
                name: ride.driverName,
                imageUrl: ride.driverPhotoUrl,
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
                            ride.driverName,
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
                            color: AppColors.xpGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.xpGold,
                                size: 14.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${ride.driverRating?.toStringAsFixed(1) ?? '5.0'}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.xpGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _buildDriverBadge(
                          icon: Icons.verified_user_rounded,
                          label: 'Verified',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    context.push(AppRouter.chatPath(ride.driverId)),
                icon: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
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
          ),
        ),
      ),
    );
  }

  Widget _buildDriverBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
              'Trip Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Departure',
              value: DateFormat(
                'EEE, MMM d • h:mm a',
              ).format(ride.departureTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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
                color: AppColors.surfaceVariant.withOpacity(0.5),
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
                    '${ride.availableSeats} total seats',
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
              'Amenities',
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
                _buildAmenityItem(
                  icon: Icons.pets_rounded,
                  label: 'Pets',
                  isAllowed: ride.allowPets,
                ),
                _buildAmenityItem(
                  icon: Icons.smoking_rooms_rounded,
                  label: 'Smoking',
                  isAllowed: ride.allowSmoking,
                ),
                _buildAmenityItem(
                  icon: Icons.luggage_rounded,
                  label: 'Luggage',
                  isAllowed: ride.allowLuggage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityItem({
    required IconData icon,
    required String label,
    required bool isAllowed,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isAllowed
            ? AppColors.success.withOpacity(0.1)
            : AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isAllowed ? AppColors.success : AppColors.textTertiary,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isAllowed ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          if (!isAllowed) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ],
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
                      ? 'Your Passengers (${acceptedBookings.length})'
                      : 'Passengers (${acceptedBookings.length})',
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
                      '${ride.bookedSeats}/${ride.availableSeats} seats',
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
                        ? 'No passengers accepted yet'
                        : 'No passengers booked yet',
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
                  AvatarGroup(
                    names: acceptedBookings
                        .map((b) => b.passengerName)
                        .toList(),
                    size: 40,
                    maxDisplay: 5,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      acceptedBookings.length == 1
                          ? '${acceptedBookings.first.passengerName} has booked this ride'
                          : '${acceptedBookings.length} passengers have booked',
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
          PremiumAvatar(
            name: booking.passengerName,
            imageUrl: booking.passengerPhotoUrl,
            size: 44,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.passengerName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''} booked',
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
            onPressed: () =>
                context.push(AppRouter.chatPath(booking.passengerId)),
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
                  'Pending Requests (${pendingBookings.length})',
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
              PremiumAvatar(
                name: booking.passengerName,
                imageUrl: booking.passengerPhotoUrl,
                size: 44,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.passengerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''} requested',
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
          const SnackBar(
            content: Text('Request accepted! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request declined')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                            '${ride.bookedSeats}/${ride.availableSeats}',
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
                        'Seats Booked',
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
                              '$pendingCount',
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
                          'Pending',
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
                        '${(ride.pricePerSeat * acceptedCount).toStringAsFixed(0)} €',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Earnings',
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
              // Edit ride button - TODO: Create proper edit ride screen
              Expanded(
                child: PremiumButton(
                  text: 'Edit Ride',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit ride feature coming soon!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: PremiumButtonStyle.secondary,
                  icon: Icons.edit_rounded,
                ),
              ),
              SizedBox(width: 12.w),
              // Start ride button (if ride is upcoming and has passengers)
              Expanded(
                child: PremiumButton(
                  text: ride.status == RideStatus.active
                      ? 'View Active'
                      : 'Start Ride',
                  onPressed: acceptedCount > 0
                      ? () => context.push(
                          AppRouter.driverActiveRidePath(ride.id),
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
            color: Colors.black.withOpacity(0.1),
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
          Row(
            children: [
              // Seat selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _selectedSeats > 1
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSeats--);
                            }
                          : null,
                      icon: Icon(
                        Icons.remove_rounded,
                        color: _selectedSeats > 1
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.all(8.w),
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$_selectedSeats',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: _selectedSeats < ride.remainingSeats
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSeats++);
                            }
                          : null,
                      icon: Icon(
                        Icons.add_rounded,
                        color: _selectedSeats < ride.remainingSeats
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.all(8.w),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              // Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totalPrice.toStringAsFixed(0)} €',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$_selectedSeats seat${_selectedSeats > 1 ? 's' : ''} × ${ride.pricePerSeat.toStringAsFixed(0)} €',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Book button
              PremiumButton(
                text: 'Book Now',
                onPressed: ride.remainingSeats > 0
                    ? () => _bookRide(ride)
                    : null,
                isLoading: _isBooking,
                style: PremiumButtonStyle.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Book ride with Stripe payment
  /// Flow: Create Payment Intent → Show Payment Sheet → Confirm Booking
  void _bookRide(RideModel ride) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book a ride')),
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

      // Get or create Stripe customer for the rider
      final customerId = await paymentViewModel.getOrCreateCustomer(
        userId: user.uid,
        email: user.email,
        name: user.displayName,
        phone: user.phoneNumber,
      );

      // Calculate total amount in smallest currency unit (cents/millimes)
      final totalAmount = ride.pricePerSeat * _selectedSeats;
      final amountInSmallestUnit = (totalAmount * 100)
          .round(); // Convert to cents

      // Create payment intent via Firebase Cloud Function
      final paymentData = await StripeService().createPaymentIntent(
        rideId: ride.id,
        riderId: user.uid,
        riderName: user.displayName,
        driverId: ride.driverId,
        driverName: ride.driverName,
        amount: amountInSmallestUnit.toDouble(),
        currency: ride.currency ?? '€',
        customerId: customerId,
        description: '${ride.origin.address} → ${ride.destination.address}',
      );

      // Show Stripe Payment Sheet
      final paymentSuccess = await StripeService().processPaymentWithSheet(
        paymentIntentClientSecret: paymentData['clientSecret'],
        customerId: customerId,
      );

      if (paymentSuccess) {
        // Payment successful - create the booking
        final bookingSuccess = await ref
            .read(rideDetailViewModelProvider(widget.rideId).notifier)
            .bookRide(
              passengerId: user.uid,
              passengerName: user.displayName,
              passengerPhotoUrl: user.photoUrl,
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
            const SnackBar(
              content: Text(
                'Payment succeeded but booking failed. Please contact support.',
              ),
            ),
          );
        }
      } else {
        // Payment cancelled by user
        if (!mounted) return;
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
      }
    } on StripePaymentException catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: ${e.message}')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Show dialog for cash payment option
  void _showPaymentMethodDialog(RideModel ride, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Text('Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This driver accepts cash payment only.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _buildPaymentOption(
              icon: Icons.money_rounded,
              title: 'Pay with Cash',
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
                color: AppColors.primary.withOpacity(0.1),
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
            passengerName: user.displayName ?? 'Rider',
            passengerPhotoUrl: user.photoUrl,
            seats: _selectedSeats,
            note: 'Payment: Cash',
          );

      if (!mounted) return;
      setState(() => _isBooking = false);

      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to book ride. Please try again.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBooking = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Show payment success dialog with receipt info
  void _showPaymentSuccessDialog(double amount, String currency) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
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
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You paid ${amount.toStringAsFixed(2)} $currency',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your ride has been booked.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            PointsBadge(points: 25),
            SizedBox(height: 8.h),
            Text(
              'You earned 25 XP!',
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
                context.go(AppRouter.riderMyRides);
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
                'Back to Search',
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
          borderRadius: BorderRadius.circular(24.r),
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
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your ride has been booked. Pay the driver in cash.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            PointsBadge(points: 25),
            SizedBox(height: 8.h),
            Text(
              'You earned 25 XP!',
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
                context.go(AppRouter.riderMyRides);
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
                'Back to Search',
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
}
