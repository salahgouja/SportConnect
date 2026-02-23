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
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/passenger_info_widget.dart';

import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/distance_formatter.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';

/// Driver's dedicated screen for managing their ride and viewing booking requests
/// Features: ride stats, booking management, passenger list, ride controls
class DriverViewRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const DriverViewRideScreen({super.key, required this.rideId});

  @override
  ConsumerState<DriverViewRideScreen> createState() =>
      _DriverViewRideScreenState();
}

class _DriverViewRideScreenState extends ConsumerState<DriverViewRideScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideDetailViewModelProvider(widget.rideId));

    return rideAsync.when(
      data: (ride) => ride != null
          ? _buildContent(ride)
          : _buildErrorState(AppLocalizations.of(context).rideNotFound),
      loading: () => _buildLoadingState(),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).yourRide),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(AppLocalizations.of(context).yourRide),
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

  Widget _buildContent(RideModel ride) {
    final pendingBookings = ride.bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();
    final confirmedBookings = ride.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(ride),
            SliverToBoxAdapter(
              child: _buildStatsBar(ride, pendingBookings.length),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(text: 'Details'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context).requests),
                          if (pendingBookings.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).value2(pendingBookings.length),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.of(context).passengers),
                          if (confirmedBookings.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).value2(confirmedBookings.length),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(ride),
            _buildRequestsTab(ride, pendingBookings),
            _buildPassengersTab(ride, confirmedBookings),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(ride),
    );
  }

  Widget _buildSliverAppBar(RideModel ride) {
    return SliverAppBar(
      expandedHeight: 200.h,
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
          tooltip: 'Ride options',
          onPressed: () => _showRideOptions(ride),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Mini map
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
                    AppColors.primary.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
            // Info overlay
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(ride),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, MMM d',
                              ).format(ride.departureTime),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(ride.departureTime),
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).earnings,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '\$${_calculateEarnings(ride).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RideModel ride) {
    Color bgColor;
    String text;
    IconData icon;

    switch (ride.status) {
      case RideStatus.active:
        bgColor = AppColors.success;
        text = 'Active';
        icon = Icons.check_circle_rounded;
      case RideStatus.inProgress:
        bgColor = AppColors.info;
        text = 'In Progress';
        icon = Icons.directions_car_rounded;
      case RideStatus.completed:
        bgColor = AppColors.textSecondary;
        text = 'Completed';
        icon = Icons.done_all_rounded;
      case RideStatus.cancelled:
        bgColor = AppColors.error;
        text = 'Cancelled';
        icon = Icons.cancel_rounded;
      case RideStatus.draft:
        bgColor = AppColors.warning;
        text = 'Draft';
        icon = Icons.edit_note_rounded;
      case RideStatus.full:
        bgColor = AppColors.info;
        text = 'Full';
        icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(RideModel ride, int pendingCount) {
    final confirmedSeats = ride.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .fold(0, (sum, b) => sum + b.seatsBooked);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.event_seat_rounded,
              value: '$confirmedSeats/${ride.availableSeats}',
              label: AppLocalizations.of(context).seatsFilled,
            ),
          ),
          Container(width: 1.w, height: 40.h, color: Colors.white30),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending_actions_rounded,
              value: '$pendingCount',
              label: AppLocalizations.of(context).pending,
              highlight: pendingCount > 0,
            ),
          ),
          Container(width: 1.w, height: 40.h, color: Colors.white30),
          Expanded(
            child: _buildStatItem(
              icon: Icons.attach_money_rounded,
              value: '\$${ride.pricePerSeat.toStringAsFixed(0)}',
              label: AppLocalizations.of(context).perSeat,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: highlight ? AppColors.warning : Colors.white,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(RideModel ride) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildRouteCard(ride),
        SizedBox(height: 12.h),
        _buildVehicleCard(ride),
        SizedBox(height: 12.h),
        _buildPreferencesCard(ride),
        if (ride.notes != null && ride.notes!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildNotesCard(ride),
        ],
        SizedBox(height: 80.h),
      ],
    );
  }

  Widget _buildRouteCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
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
                AppLocalizations.of(context).route,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (ride.distanceKm != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    ref.watch(distanceFormatterProvider)(ride.distanceKm!),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
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
                        AppLocalizations.of(context).value10(
                          DateFormat('HH:mm').format(ride.arrivalTime!),
                        ),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
        ],
      ),
    );
  }

  Widget _buildVehicleCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              size: 28.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.vehicleInfo ?? 'Vehicle',
                  style: TextStyle(
                    fontSize: 15.sp,
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
    );
  }

  Widget _buildPreferencesCard(RideModel ride) {
    final prefs = <MapEntry<IconData, String>>[];
    if (ride.allowLuggage)
      prefs.add(MapEntry(Icons.luggage_rounded, 'Luggage OK'));
    if (ride.allowPets) prefs.add(MapEntry(Icons.pets_rounded, 'Pets OK'));
    if (!ride.allowSmoking)
      prefs.add(MapEntry(Icons.smoke_free_rounded, 'No smoking'));
    if (ride.isWomenOnly)
      prefs.add(MapEntry(Icons.female_rounded, 'Women only'));
    if (ride.allowChat) prefs.add(MapEntry(Icons.chat_rounded, 'Chat enabled'));
    if (ride.isPriceNegotiable)
      prefs.add(MapEntry(Icons.handshake_rounded, 'Price negotiable'));

    if (prefs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18.sp, color: AppColors.primary),
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
            children: prefs
                .map(
                  (p) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.key, size: 14.sp, color: AppColors.success),
                        SizedBox(width: 6.w),
                        Text(
                          p.value,
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
    );
  }

  Widget _buildNotesCard(RideModel ride) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).notes,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            ride.notes!,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(RideModel ride, List<RideBooking> pending) {
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noPendingRequests,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).newBookingRequestsWillAppear,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        return _buildBookingRequestCard(ride, pending[index])
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildBookingRequestCard(RideModel ride, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PassengerAvatarWidget(
                passengerId: booking.passengerId,
                radius: 25,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PassengerNameWidget(
                      passengerId: booking.passengerId,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat_rounded,
                          size: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${booking.seatsBooked} ${booking.seatsBooked == 1 ? AppLocalizations.of(context).seat : AppLocalizations.of(context).seats}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _timeAgo(booking.createdAt),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '\$${(ride.pricePerSeat * booking.seatsBooked).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),

          if (booking.note != null && booking.note!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.message_rounded,
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
                        fontStyle: FontStyle.italic,
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
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _rejectBooking(ride, booking),
                  icon: Icon(Icons.close_rounded, size: 18.sp),
                  label: Text(AppLocalizations.of(context).decline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _acceptBooking(ride, booking),
                  icon: Icon(
                    Icons.check_rounded,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(AppLocalizations.of(context).accept),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersTab(RideModel ride, List<RideBooking> confirmed) {
    if (confirmed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off_rounded,
              size: 64.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).noPassengersYet,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).acceptBookingRequestsToAdd,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: confirmed.length,
      itemBuilder: (context, index) {
        return _buildPassengerCard(ride, confirmed[index])
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildPassengerCard(RideModel ride, RideBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          PassengerAvatarWidget(passengerId: booking.passengerId, radius: 25),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: PassengerNameWidget(
                        passengerId: booking.passengerId,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.verified_rounded,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSurface,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${booking.seatsBooked} ${booking.seatsBooked == 1 ? AppLocalizations.of(context).seat : AppLocalizations.of(context).seats}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '\$${(ride.pricePerSeat * booking.seatsBooked).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Message passenger',
                onPressed: () => _openPassengerChat(booking),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                tooltip: 'Passenger options',
                onPressed: () => _showPassengerOptions(ride, booking),
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(RideModel ride) {
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
        child: Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: 'Edit Ride',
                onPressed: () => _editRide(ride),
                style: PremiumButtonStyle.secondary,
                icon: Icons.edit_rounded,
              ),
            ),
            SizedBox(width: 12.w),
            if (ride.status == RideStatus.active)
              Expanded(
                flex: 2,
                child: PremiumButton(
                  text: 'Start Ride',
                  onPressed: () => _startRide(ride),
                  style: PremiumButtonStyle.primary,
                  icon: Icons.play_arrow_rounded,
                ),
              )
            else if (ride.status == RideStatus.inProgress)
              Expanded(
                flex: 2,
                child: PremiumButton(
                  text: 'Complete Ride',
                  onPressed: () => _completeRide(ride),
                  style: PremiumButtonStyle.success,
                  icon: Icons.check_circle_rounded,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // === Actions ===

  double _calculateEarnings(RideModel ride) {
    return ride.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .fold(0.0, (sum, b) => sum + (ride.pricePerSeat * b.seatsBooked));
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return 'Unknown';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showRideOptions(RideModel ride) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.share_rounded, color: AppColors.primary),
              title: Text(AppLocalizations.of(context).shareRide),
              onTap: () {
                Navigator.pop(context);
                _shareRide(ride);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: AppColors.info),
              title: Text(AppLocalizations.of(context).duplicateRide),
              onTap: () {
                Navigator.pop(context);
                _duplicateRide(ride);
              },
            ),
            if (ride.status == RideStatus.active)
              ListTile(
                leading: Icon(Icons.cancel_rounded, color: AppColors.error),
                title: Text(
                  AppLocalizations.of(context).cancelRide2,
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _cancelRide(ride);
                },
              ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showPassengerOptions(RideModel ride, RideBooking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.person_rounded, color: AppColors.primary),
              title: Text(AppLocalizations.of(context).viewProfile),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '${AppRoutes.profile.path}/${booking.passengerId}',
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.call_rounded, color: AppColors.success),
              title: Text(AppLocalizations.of(context).callPassenger),
              onTap: () {
                Navigator.pop(context);
                _callPassenger(booking);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_rounded, color: AppColors.error),
              title: Text(
                AppLocalizations.of(context).removePassenger,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _removePassenger(ride, booking);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptBooking(RideModel ride, RideBooking booking) async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      // Fetch passenger profile for confirmation message
      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (!mounted) return;

      // Use fallback if profile is null
      final passengerName = passengerProfile?.displayName ?? 'Passenger';

      await ref
          .read(rideActionsViewModelProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: booking.id,
            newStatus: BookingStatus.accepted,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(
                    context,
                  ).bookingConfirmedForValue(passengerName),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not confirm booking. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectBooking(RideModel ride, RideBooking booking) async {
    // Fetch passenger profile for dialog message
    final passengerProfile = await ref.read(
      userProfileProvider(booking.passengerId).future,
    );

    if (!mounted) return;

    // Use fallback if profile is null
    final passengerName = passengerProfile?.displayName ?? 'Passenger';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).declineBooking),
        content: Text(
          AppLocalizations.of(
            context,
          ).declineBookingRequestFromValue(passengerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).decline,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(rideActionsViewModelProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: booking.id,
            newStatus: BookingStatus.rejected,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not decline booking. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Calls a passenger using the device phone dialer.
  Future<void> _callPassenger(RideBooking booking) async {
    try {
      final passenger = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );
      final phoneNumber = passenger?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).phoneNumberNotAvailable),
          ),
        );
        return;
      }

      final phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotMakePhoneCalls),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToLaunchDialer),
        ),
      );
    }
  }

  Future<void> _removePassenger(RideModel ride, RideBooking booking) async {
    // Fetch passenger profile for dialog message
    final passengerProfile = await ref.read(
      userProfileProvider(booking.passengerId).future,
    );

    if (!mounted) return;

    // Use fallback if profile is null
    final passengerName = passengerProfile?.displayName ?? 'Passenger';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).removePassenger),
        content: Text(
          AppLocalizations.of(context).removeValueFromThisRide(passengerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).remove,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(rideActionsViewModelProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: booking.id,
            newStatus: BookingStatus.cancelled,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not remove passenger. Please try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openPassengerChat(RideBooking booking) async {
    HapticFeedback.lightImpact();

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      // Fetch passenger profile for chat
      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (!mounted) return;

      // If profile doesn't exist, show error and return
      if (passengerProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passenger profile not found'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: booking.passengerId,
          userName1: currentUser.displayName,
          userName2: passengerProfile.displayName,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      final passengerUser = UserModel.rider(
        uid: booking.passengerId,
        email: '',
        displayName: passengerProfile.displayName,
        photoUrl: passengerProfile.photoUrl,
      );

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: passengerUser,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to open chat. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _editRide(RideModel ride) {
    HapticFeedback.lightImpact();
    context.push(AppRoutes.driverOfferRide.path, extra: ride);
  }

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
              '🔗 https://${DeepLinkService.hostingDomain}/ride/${ride.id}',
          subject: 'Carpool ride on SportConnect',
        ),
      );
    }
  }

  void _duplicateRide(RideModel ride) {
    HapticFeedback.lightImpact();
    context.push(AppRoutes.driverOfferRide.path, extra: ride);
  }

  Future<void> _startRide(RideModel ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).startRide),
        content: Text(AppLocalizations.of(context).markThisRideAsStarted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).start),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(rideActionsViewModelProvider).startRide(ride.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not start ride. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeRide(RideModel ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).completeRide),
        content: Text(AppLocalizations.of(context).markThisRideAsCompleted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).complete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(rideActionsViewModelProvider).completeRide(ride.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).rideCompleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not complete ride. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelRide(RideModel ride) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).cancelRide2),
        content: Text(AppLocalizations.of(context).areYouSureYouWant8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).keepRide),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context).cancelRide2,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(rideActionsViewModelProvider)
          .cancelRide(ride.id, 'Cancelled by driver');
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not cancel ride. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Tab bar delegate for sticky tabs
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
