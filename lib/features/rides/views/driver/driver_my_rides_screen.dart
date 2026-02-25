import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';

/// 🚀 **CREATIVE** Driver Rides - Unique Swipeable Card Deck + Timeline
/// One-of-a-kind experience with innovative interactions
class DriverMyRidesScreen extends ConsumerStatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  ConsumerState<DriverMyRidesScreen> createState() =>
      _DriverMyRidesScreenState();
}

class _DriverMyRidesScreenState extends ConsumerState<DriverMyRidesScreen>
    with TickerProviderStateMixin {
  int _currentRequestIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _shakeController;
  late AnimationController _acceptController;
  late AnimationController _declineController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _acceptController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _declineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _acceptController.dispose();
    _declineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequestsAsync = ref.watch(pendingRideRequestsProvider);
    final upcomingRidesAsync = ref.watch(upcomingDriverRidesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content with parallax background
            _buildParallaxBackground(),

            // Main scrollable content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Creative floating header
                SliverToBoxAdapter(child: _buildCreativeHeader(context)),

                // Swipeable pending requests card deck
                SliverToBoxAdapter(
                  child: pendingRequestsAsync.when(
                    data: (requests) => requests.isEmpty
                        ? _buildEmptyRequestsDeck()
                        : _buildSwipeableCardDeck(requests),
                    loading: () => _buildLoadingDeck(),
                    error: (e, _) => _buildErrorDeck(e),
                  ),
                ),

                SizedBox(height: 32.h).toSliver(),

                // Timeline view for upcoming rides
                SliverToBoxAdapter(child: _buildTimelineHeader()),

                upcomingRidesAsync.when(
                  data: (rides) => rides.isEmpty
                      ? _buildEmptyTimeline().toSliver()
                      : _buildRidesTimeline(rides),
                  loading: () => _buildLoadingTimeline().toSliver(),
                  error: (e, _) => _buildErrorTimeline(e).toSliver(),
                ),

                SizedBox(height: 100.h).toSliver(),
              ],
            ),

            // Floating action bubbles
            _buildFloatingActionBubbles(context),
          ],
        ),
      ),
    );
  }

  /// 🎨 Parallax animated background
  Widget _buildParallaxBackground() {
    return Positioned.fill(
      child:
          AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.03),
                      AppColors.scaffoldBg,
                      AppColors.accent.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _ParallaxPatternPainter(animation: _shakeController),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 3000.ms,
                color: AppColors.primary.withValues(alpha: 0.02),
              ),
    );
  }

  /// 🎯 Creative floating header
  Widget _buildCreativeHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Row(
        children: [
          // Time capsule
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('EEE, MMM d').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().scale(delay: 100.ms).fadeIn(),

          const Spacer(),

          // Profile bubble
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile.path),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ).animate().scale(delay: 200.ms).fadeIn(),
          ),
        ],
      ),
    );
  }

  /// 🎴 **UNIQUE** Swipeable card deck for pending requests (Tinder-style)
  Widget _buildSwipeableCardDeck(List<RideRequestModel> requests) {
    return Container(
      height: 460.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Stack(
        children: [
          // Instructions overlay (show initially)
          if (_currentRequestIndex == 0 && !_isDragging)
            Positioned.fill(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: 24.h),
                child:
                    Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swipe,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Swipe right to accept • Swipe left to decline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .fadeIn()
                        .fadeOut(delay: 2000.ms, duration: 500.ms),
              ),
            ),

          // Card stack (show 3 cards for depth effect)
          ...List.generate(
            math.min(3, requests.length - _currentRequestIndex),
            (index) {
              final actualIndex = _currentRequestIndex + index;
              if (actualIndex >= requests.length) {
                return const SizedBox.shrink();
              }

              final request = requests[actualIndex];
              final isTop = index == 0;

              return _buildStackedCard(
                request,
                index,
                isTop,
                requests.length - _currentRequestIndex,
              );
            },
          ).reversed,
        ],
      ),
    );
  }

  /// 🎯 Individual card in stack with 3D depth effect
  Widget _buildStackedCard(
    RideRequestModel request,
    int stackIndex,
    bool isTopCard,
    int totalCards,
  ) {
    final offset = stackIndex * 8.0;
    final scale = 1.0 - (stackIndex * 0.05);

    // Calculate rotation based on drag
    final rotation = isTopCard ? _dragOffset.dx / 1000 : 0.0;
    final opacity = isTopCard
        ? (1.0 - (_dragOffset.distance / 500).clamp(0.0, 1.0))
        : 1.0;

    return Positioned.fill(
      top: offset,
      bottom: -offset,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: rotation,
          child: Transform.translate(
            offset: isTopCard ? _dragOffset : Offset.zero,
            child: Opacity(
              opacity: opacity,
              child: GestureDetector(
                onPanStart: isTopCard
                    ? (_) => setState(() => _isDragging = true)
                    : null,
                onPanUpdate: isTopCard
                    ? (details) {
                        setState(() {
                          _dragOffset += details.delta;
                        });

                        // Haptic feedback at threshold
                        if (_dragOffset.dx.abs() > 100 &&
                            _dragOffset.dx.abs() < 110) {
                          // HapticFeedback.selectionClick();
                        }
                      }
                    : null,
                onPanEnd: isTopCard
                    ? (details) {
                        setState(() => _isDragging = false);

                        // Check if swiped far enough
                        if (_dragOffset.dx > 100) {
                          _acceptRequest(request);
                        } else if (_dragOffset.dx < -100) {
                          _declineRequest(request);
                        } else {
                          // Snap back
                          setState(() => _dragOffset = Offset.zero);
                          _shakeController.forward(from: 0);
                        }
                      }
                    : null,
                child: _buildRequestCard(request, isTopCard),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 Beautiful request card
  Widget _buildRequestCard(RideRequestModel request, bool isTopCard) {
    final showAcceptHint = isTopCard && _dragOffset.dx > 50;
    final showDeclineHint = isTopCard && _dragOffset.dx < -50;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isTopCard
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isTopCard ? 20 : 10,
            offset: Offset(0, isTopCard ? 8 : 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accept hint overlay
          if (showAcceptHint)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.3),
                      AppColors.success.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.success, width: 4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'ACCEPT',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Decline hint overlay
          if (showDeclineHint)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withValues(alpha: 0.3),
                      AppColors.error.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.error, width: 4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'DECLINE',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Card content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Ride Request',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            request.id,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${request.pricePerSeat.toStringAsFixed(0)} DT',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Route visualization
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.accent.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      _buildRoutePoint(
                        Icons.trip_origin_rounded,
                        'Pickup',
                        request.pickupLocation.address,
                        AppColors.primary,
                      ),
                      Container(
                        width: 2.w,
                        height: 32.h,
                        margin: EdgeInsets.only(left: 11.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                        ),
                      ),
                      _buildRoutePoint(
                        Icons.location_on_rounded,
                        'Dropoff',
                        request.dropoffLocation.address,
                        AppColors.accent,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Details chips
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildDetailChip(
                      Icons.people_outline_rounded,
                      '${request.requestedSeats} ${request.requestedSeats == 1 ? 'seat' : 'seats'}',
                    ),
                    _buildDetailChip(
                      Icons.access_time_rounded,
                      DateFormat('MMM d, HH:mm').format(request.createdAt),
                    ),
                  ],
                ),

                const Spacer(),

                // Swipe action buttons (alternative to swipe)
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Decline',
                        Icons.close_rounded,
                        AppColors.error,
                        () => _declineRequest(request),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildActionButton(
                        'Accept',
                        Icons.check_rounded,
                        AppColors.success,
                        () => _acceptRequest(request),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutePoint(
    IconData icon,
    String label,
    String address,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 14.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Accept request action
  void _acceptRequest(RideRequestModel request) {
    _acceptController.forward(from: 0).then((_) {
      setState(() {
        _currentRequestIndex++;
        _dragOffset = Offset.zero;
      });

      // Call API
      ref
          .read(driverViewModelProvider.notifier)
          .acceptRideRequest(request.rideId, request.id);
    });
  }

  /// Decline request action
  void _declineRequest(RideRequestModel request) {
    _declineController.forward(from: 0).then((_) {
      setState(() {
        _currentRequestIndex++;
        _dragOffset = Offset.zero;
      });

      // Call API
      ref
          .read(driverViewModelProvider.notifier)
          .declineRideRequest(request.rideId, request.id);
    });
  }

  Widget _buildEmptyRequestsDeck() {
    return Container(
      height: 460.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(
                    Icons.inbox_rounded,
                    size: 60.sp,
                    color: Colors.white,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                ),
            SizedBox(height: 24.h),
            Text(
              'No Pending Requests',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You\'re all caught up!',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDeck() {
    return Container(
      height: 460.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorDeck(Object error) {
    return Container(
      height: 460.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading requests',
              style: TextStyle(fontSize: 16.sp, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  /// 📍 **UNIQUE** Timeline header
  Widget _buildTimelineHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 32.h,
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Your Journey Timeline',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.3),
    );
  }

  /// 🛤️ **UNIQUE** Vertical timeline for upcoming rides
  Widget _buildRidesTimeline(List<RideModel> rides) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final ride = rides[index];
          final isLast = index == rides.length - 1;

          return Dismissible(
            key: ValueKey('driver_timeline_${ride.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              HapticFeedback.mediumImpact();
              if (!mounted) return false;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: AppColors.error,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      const Text('Cancel Ride'),
                    ],
                  ),
                  content: const Text(
                    'Are you sure you want to cancel this ride? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Keep Ride'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
              if ((confirmed ?? false) && mounted) {
                context.pushNamed(
                  AppRoutes.cancellationReason.name,
                  pathParameters: {'id': ride.id},
                );
              }
              return false; // stream manages list
            },
            background: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16.h, left: 48.w),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, color: Colors.white, size: 28.sp),
                  SizedBox(height: 4.h),
                  Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: _buildTimelineRideCard(ride, isLast, index),
          );
        }, childCount: rides.length),
      ),
    );
  }

  Widget _buildTimelineRideCard(RideModel ride, bool isLast, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 3.w,
                height: 80.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ).animate(delay: Duration(milliseconds: index * 100)).fadeIn().scale(),

        SizedBox(width: 16.w),

        // Ride card
        Expanded(
          child: GestureDetector(
            onTap: () =>
                context.push('${AppRoutes.riderViewRide.path}/${ride.id}'),
            child:
                Container(
                      margin: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  DateFormat(
                                    'MMM d • HH:mm',
                                  ).format(ride.departureTime),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_outline_rounded,
                                      size: 14.sp,
                                      color: AppColors.success,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${ride.acceptedBookings.length}/${ride.availableSeats}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(
                                Icons.trip_origin_rounded,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  ride.origin.address,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16.sp,
                                color: AppColors.accent,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  ride.destination.address,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate(delay: Duration(milliseconds: index * 100 + 50))
                    .fadeIn()
                    .slideX(begin: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTimeline() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 48.sp,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Upcoming Rides',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start planning your journey',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLoadingTimeline() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  Widget _buildErrorTimeline(Object error) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error loading rides',
            style: TextStyle(fontSize: 16.sp, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  /// 🎈 Floating action bubbles
  Widget _buildFloatingActionBubbles(BuildContext context) {
    return Positioned(
      right: 20.w,
      bottom: 32.h,
      child: Column(
        children: [
          _buildFloatingBubble(
            Icons.add_road_rounded,
            AppColors.heroGradient,
            () => context.push(AppRoutes.driverOfferRide.path),
          ).animate().scale(delay: 200.ms).fadeIn(),
          SizedBox(height: 12.h),
          _buildFloatingBubble(Icons.map_rounded, AppColors.accentGradient, () {
            // Navigate to map view
          }).animate().scale(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildFloatingBubble(
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28.sp),
      ),
    );
  }
}

/// Custom painter for parallax pattern background
class _ParallaxPatternPainter extends CustomPainter {
  final Animation<double> animation;

  _ParallaxPatternPainter({required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw animated circles
    for (var i = 0; i < 5; i++) {
      final radius = (size.width / 4) + (i * 40) + (animation.value * 20);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParallaxPatternPainter oldDelegate) => true;
}

/// Extension to convert widgets to slivers
extension WidgetToSliver on Widget {
  Widget toSliver() {
    return SliverToBoxAdapter(child: this);
  }
}

extension SizedBoxSliver on SizedBox {
  Widget toSliver() {
    return SliverToBoxAdapter(child: this);
  }
}
