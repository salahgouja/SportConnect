import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/features/rides/models/ride_request_model.dart';

/// Driver Requests Screen - View and manage incoming ride requests
class DriverRequestsScreen extends ConsumerStatefulWidget {
  const DriverRequestsScreen({super.key});

  @override
  ConsumerState<DriverRequestsScreen> createState() =>
      _DriverRequestsScreenState();
}

class _DriverRequestsScreenState extends ConsumerState<DriverRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    // Watch the pending requests to drive the live badge count
    final pendingCount =
        ref
            .watch(pendingRideRequestsProvider)
            .whenOrNull(data: (list) => list.length) ??
        0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).rideRequests,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(52.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context).pending),
                      if (pendingCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '$pendingCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Accepted'),
                const Tab(text: 'Declined'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingRequests(),
          _buildAcceptedRequests(),
          _buildDeclinedRequests(),
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    final pendingRequests = ref.watch(pendingRideRequestsProvider);

    return pendingRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.sp,
                  color: AppColors.textTertiary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noPendingRequests,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).newRideRequestsWillAppear,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final formattedDate = DateFormat(
              'EEE, MMM d',
            ).format(request.requestedDate);

            return Dismissible(
              key: ValueKey('req_${request.id}_$index'),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                HapticFeedback.mediumImpact();
                if (direction == DismissDirection.startToEnd) {
                  _handleAccept(request);
                } else {
                  _handleDecline(request);
                }
                return false; // stream manages the list
              },
              background: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              child:
                  _PendingRequestCard(
                        request: request,
                        formattedDate: formattedDate,
                        onAccept: () => _handleAccept(request),
                        onDecline: () => _handleDecline(request),
                        onViewProfile: () => _handleViewProfile(request),
                      )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn()
                      .slideY(begin: 0.1),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadRequests,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => ref.invalidate(pendingRideRequestsProvider),
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedRequests() {
    final acceptedRequests = ref.watch(acceptedRideRequestsProvider);

    return acceptedRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64.sp,
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noAcceptedRequestsYet,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).acceptedRequestsWillAppearHere,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _AcceptedRequestCard(
                  request: request,
                  onMessage: () => _handleMessagePassenger(request),
                  onViewDetails: () => _handleViewRideDetails(request),
                )
                .animate(delay: Duration(milliseconds: 100 * index))
                .fadeIn()
                .slideY(begin: 0.1);
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadRequests,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclinedRequests() {
    final rejectedRequests = ref.watch(rejectedRideRequestsProvider);

    return rejectedRequests.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64.sp,
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noDeclinedRequests,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).youHavenTDeclinedAny,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _DeclinedRequestCard(request: request);
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadRequests,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(RideRequestModel request) {
    HapticFeedback.heavyImpact();
    final formattedDate = DateFormat(
      'EEE, MMM d',
    ).format(request.requestedDate);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: AppColors.success),
            ),
            SizedBox(width: 12.w),
            Text(AppLocalizations.of(context).acceptRequest),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).youAreAboutToAccept(
            request.passenger.displayName,
            formattedDate,
            request.requestedTime,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              final accepted = await ref
                  .read(driverViewModelProvider.notifier)
                  .acceptRideRequest(request.rideId, request.id);

              if (!mounted) {
                return;
              }

              if (accepted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).requestAcceptedValueHasBeen(
                        request.passenger.displayName,
                      ),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).failedToAcceptRequest,
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(AppLocalizations.of(context).accept),
          ),
        ],
      ),
    );
  }

  void _handleDecline(RideRequestModel request) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeclineReasonSheet(
        request: request,
        onDecline: (reason) async {
          context.pop();
          final declined = await ref
              .read(driverViewModelProvider.notifier)
              .declineRideRequest(request.rideId, request.id);

          if (!mounted) {
            return;
          }

          if (declined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).requestDeclined),
                backgroundColor: AppColors.textSecondary,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).failedToDeclineRequest,
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleViewProfile(RideRequestModel request) {
    // Navigate to passenger profile
  }

  /// Navigate to ride detail screen for the accepted request.
  void _handleViewRideDetails(RideRequestModel request) {
    context.pushNamed(
      AppRoutes.rideDetail.name,
      pathParameters: {'id': request.rideId},
    );
  }

  /// Start a chat with the passenger who made the request.
  Future<void> _handleMessagePassenger(RideRequestModel request) async {
    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null || !mounted) return;

      final passengerProfile = await ref.read(
        userProfileProvider(request.requesterId).future,
      );
      if (passengerProfile == null || !mounted) return;

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: request.requesterId,
          userName1: currentUser.displayName ?? '',
          userName2: passengerProfile.displayName,
          userPhoto1: currentUser.photoURL,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: passengerProfile,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToLaunchDialer),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _PendingRequestCard extends StatelessWidget {
  final RideRequestModel request;
  final String formattedDate;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewProfile;

  const _PendingRequestCard({
    required this.request,
    required this.formattedDate,
    required this.onAccept,
    required this.onDecline,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          // Header with time badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16.sp,
                  color: AppColors.warning,
                ),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context).requestedValue(formattedDate),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.warning,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    AppLocalizations.of(context).value5(
                      (request.pricePerSeat * request.seatsRequested)
                          .toStringAsFixed(0),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Passenger info
                GestureDetector(
                  onTap: onViewProfile,
                  child: Row(
                    children: [
                      PremiumAvatar(
                        imageUrl: request.passenger.photoUrl,
                        name: request.passenger.displayName,
                        size: 54.w,
                        hasBorder: true,
                        borderColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  request.passenger.displayName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.starFilled,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  request.passenger.rating.average
                                      .toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  AppLocalizations.of(context).valueSeatValue2(
                                    request.seatsRequested,
                                    request.seatsRequested > 1 ? 's' : '',
                                  ),
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
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Route info
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              request.fromLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Row(
                          children: [
                            Container(
                              width: 2,
                              height: 28.h,
                              color: AppColors.border,
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).valueSeatValueRequested(
                                request.seatsRequested,
                                request.seatsRequested > 1 ? 's' : '',
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.error,
                            size: 14.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              request.toLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Time and seats
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: '$formattedDate at ${request.requestedTime}',
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.airline_seat_recline_normal_rounded,
                      label:
                          '${request.seatsRequested} seat${request.seatsRequested > 1 ? 's' : ''}',
                    ),
                  ],
                ),

                // Message if exists
                if (request.message != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            request.message!,
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

                SizedBox(height: 16.h),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDecline,
                        icon: Icon(Icons.close_rounded, size: 18.sp),
                        label: Text(AppLocalizations.of(context).decline),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: Icon(Icons.check_rounded, size: 18.sp),
                        label: Text(
                          AppLocalizations.of(context).acceptRequest2,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
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
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AcceptedRequestCard extends StatelessWidget {
  final RideRequestModel request;
  final VoidCallback onMessage;
  final VoidCallback onViewDetails;

  const _AcceptedRequestCard({
    required this.request,
    required this.onMessage,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEE, MMM d',
    ).format(request.requestedDate);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passenger.displayName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (request.respondedAt != null)
                      Text(
                        AppLocalizations.of(context).acceptedValue(
                          DateFormat('MMM d').format(request.respondedAt!),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                AppLocalizations.of(context).value5(
                  (request.pricePerSeat * request.requestedSeats)
                      .toStringAsFixed(0),
                ),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(
              context,
            ).valueValue2(request.fromLocation, request.toLocation),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Text(
                AppLocalizations.of(
                  context,
                ).valueAtValue(formattedDate, request.requestedTime),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.people_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Text(
                AppLocalizations.of(context).valueSeats(request.requestedSeats),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onMessage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(AppLocalizations.of(context).message),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(AppLocalizations.of(context).viewDetails),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeclinedRequestCard extends StatelessWidget {
  final RideRequestModel request;

  const _DeclinedRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_rounded,
                  color: AppColors.error,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.passenger.displayName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (request.respondedAt != null)
                      Text(
                        AppLocalizations.of(context).declinedValue(
                          DateFormat('MMM d').format(request.respondedAt!),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.of(
              context,
            ).valueValue2(request.fromLocation, request.toLocation),
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          if (request.rejectionReason != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16.sp,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).reasonValue(request.rejectionReason!),
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
        ],
      ),
    );
  }
}

class _DeclineReasonSheet extends StatefulWidget {
  final RideRequestModel request;
  final Future<void> Function(String) onDecline;

  const _DeclineReasonSheet({required this.request, required this.onDecline});

  @override
  State<_DeclineReasonSheet> createState() => _DeclineReasonSheetState();
}

class _DeclineReasonSheetState extends State<_DeclineReasonSheet> {
  String? _selectedReason;
  final _otherController = TextEditingController();

  final _reasons = [
    'Schedule conflict',
    'Route not convenient',
    'Vehicle unavailable',
    'Personal emergency',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
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
            AppLocalizations.of(context).declineRequest,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(
              context,
            ).pleaseLetValueKnowWhy(widget.request.passenger.displayName),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 20.h),
          ..._reasons.map(
            (reason) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () => setState(() => _selectedReason = reason),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: _selectedReason == reason
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _selectedReason == reason
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedReason == reason
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedReason == reason
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        reason,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: _selectedReason == reason
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_selectedReason == 'Other') ...[
            SizedBox(height: 12.h),
            TextField(
              controller: _otherController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).pleaseSpecify,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
          ],
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(AppLocalizations.of(context).actionCancel),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _selectedReason != null &&
                          (_selectedReason != 'Other' ||
                              _otherController.text.trim().isNotEmpty)
                      ? () => widget.onDecline(
                          _selectedReason == 'Other'
                              ? _otherController.text.trim()
                              : _selectedReason!,
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(AppLocalizations.of(context).decline),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
