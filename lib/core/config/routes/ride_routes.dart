import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/views/driver/active_ride_screen.dart'
    as driver_active;
import 'package:sport_connect/features/rides/views/driver/driver_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_offer_ride_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_rate_passenger_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_requests_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_view_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/active_ride_screen.dart'
    as passenger_active;
import 'package:sport_connect/features/rides/views/passenger/ride_booking_pending_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_booking_review_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_countdown_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_detail_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_search_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_view_ride_screen.dart';
import 'package:sport_connect/features/rides/views/shared/cancellation_reason_screen.dart';
import 'package:sport_connect/features/rides/views/shared/dispute_screen.dart';
import 'package:sport_connect/features/rides/views/shared/ride_completion_screen.dart';

/// Ride module routes with type-safe parameters
class RideRoutes {
  List<RouteBase> getRoutes() {
    return [
      // Search Rides
      GoRoute(
        path: AppRoutes.searchRides.path,
        name: AppRoutes.searchRides.name,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideSearchScreen(initialDestination: extra),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideSearchScreen(initialDestination: extra),
                );
        },
      ),

      // NOTE: riderMyRides is defined as a StatefulShellBranch
      // in app_router.dart for bottom navigation tabs. Don't duplicate here.

      // Rider: View Ride
      GoRoute(
        path: AppRoutes.riderViewRide.path,
        name: AppRoutes.riderViewRide.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RiderViewRideScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RiderViewRideScreen(rideId: rideId),
                );
        },
      ),

      // Rider: Active Ride
      GoRoute(
        path: AppRoutes.riderActiveRide.path,
        name: AppRoutes.riderActiveRide.name,
        pageBuilder: (context, state) {
          final params = state.params;
          // rideId is required — if absent the route was navigated to incorrectly
          final rideId = params.getQuery('rideId') ?? '';
          if (rideId.isEmpty) {
            return PlatformInfo.isIOS
                ? CupertinoPage(
                    key: state.pageKey,
                    child: const RiderMyRidesScreen(),
                  )
                : MaterialPage(
                    key: state.pageKey,
                    child: const RiderMyRidesScreen(),
                  );
          }
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: passenger_active.PassengerActiveRideScreen(
                    rideId: rideId,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: passenger_active.PassengerActiveRideScreen(
                    rideId: rideId,
                  ),
                );
        },
      ),

      // Ride Detail
      GoRoute(
        path: AppRoutes.rideDetail.path,
        name: AppRoutes.rideDetail.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideDetailScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideDetailScreen(rideId: rideId),
                );
        },
      ),

      // Driver: Offer Ride
      GoRoute(
        path: AppRoutes.driverOfferRide.path,
        name: AppRoutes.driverOfferRide.name,
        pageBuilder: (context, state) {
          // Safety: guard against wrong extra type (e.g. deep-link with no extra)
          final existingRide = state.extra is RideModel
              ? state.extra! as RideModel
              : null;
          final prefill = state.extra is DriverRidePrefill
              ? state.extra! as DriverRidePrefill
              : null;
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: DriverOfferRideScreen(
                    existingRide: existingRide,
                    prefill: prefill,
                    isEditMode: existingRide != null,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: DriverOfferRideScreen(
                    existingRide: existingRide,
                    prefill: prefill,
                    isEditMode: existingRide != null,
                  ),
                );
        },
      ),

      // NOTE: driverRides is defined as a StatefulShellBranch in app_router.dart
      // for bottom navigation tabs. Don't duplicate here.

      // Driver: View Ride
      GoRoute(
        path: AppRoutes.driverViewRide.path,
        name: AppRoutes.driverViewRide.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: DriverViewRideScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: DriverViewRideScreen(rideId: rideId),
                );
        },
      ),

      // Driver: Edit Ride (route-based; fetches ride by ID — no fragile state.extra)
      GoRoute(
        path: AppRoutes.driverEditRide.path,
        name: AppRoutes.driverEditRide.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: DriverOfferRideScreen(
                    existingRideId: rideId,
                    isEditMode: true,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: DriverOfferRideScreen(
                    existingRideId: rideId,
                    isEditMode: true,
                  ),
                );
        },
      ),

      // Driver: Active Ride
      GoRoute(
        path: AppRoutes.driverActiveRide.path,
        name: AppRoutes.driverActiveRide.name,
        pageBuilder: (context, state) {
          final params = state.params;
          // rideId is required — if absent the route was navigated to incorrectly
          final rideId = params.getQuery('rideId') ?? '';
          if (rideId.isEmpty) {
            return PlatformInfo.isIOS
                ? CupertinoPage(
                    key: state.pageKey,
                    child: const DriverMyRidesScreen(),
                  )
                : MaterialPage(
                    key: state.pageKey,
                    child: const DriverMyRidesScreen(),
                  );
          }
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: driver_active.DriverActiveRideScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: driver_active.DriverActiveRideScreen(rideId: rideId),
                );
        },
      ),

      // Driver: Requests
      GoRoute(
        path: AppRoutes.driverRequests.path,
        name: AppRoutes.driverRequests.name,
        pageBuilder: (context, state) {
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: const DriverRequestsScreen(),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: const DriverRequestsScreen(),
                );
        },
      ),

      // Ride Completion (shared)
      GoRoute(
        path: AppRoutes.rideCompletion.path,
        name: AppRoutes.rideCompletion.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideCompletionScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideCompletionScreen(rideId: rideId),
                );
        },
      ),

      // Cancellation Reason
      GoRoute(
        path: AppRoutes.cancellationReason.path,
        name: AppRoutes.cancellationReason.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');
          final isDriver = params.getQuery('isDriver') == 'true';

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: CancellationReasonScreen(
                    rideId: rideId,
                    isDriver: isDriver,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: CancellationReasonScreen(
                    rideId: rideId,
                    isDriver: isDriver,
                  ),
                );
        },
      ),

      // Dispute
      GoRoute(
        path: AppRoutes.dispute.path,
        name: AppRoutes.dispute.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('id');
          final rideSummary = params.getQuery('summary');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: DisputeScreen(
                    rideId: rideId,
                    rideSummary: rideSummary,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: DisputeScreen(
                    rideId: rideId,
                    rideSummary: rideSummary,
                  ),
                );
        },
      ),

      // Passenger: Booking Pending (awaiting driver confirmation)
      GoRoute(
        path: AppRoutes.rideBookingPending.path,
        name: AppRoutes.rideBookingPending.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('rideId');
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideBookingPendingScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideBookingPendingScreen(rideId: rideId),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.rideBookingReview.path,
        name: AppRoutes.rideBookingReview.name,
        pageBuilder: (context, state) {
          final rideId = state.pathParameters['rideId'] ?? '';

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideBookingReviewScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideBookingReviewScreen(rideId: rideId),
                );
        },
      ),
      // Passenger: Ride Countdown (booking accepted, departure approaching)
      GoRoute(
        path: AppRoutes.rideCountdown.path,
        name: AppRoutes.rideCountdown.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final bookingId = params.getStringOrThrow('bookingId');
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: RideCountdownScreen(bookingId: bookingId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: RideCountdownScreen(bookingId: bookingId),
                );
        },
      ),

      // Driver: Rate Passenger (post-ride)
      GoRoute(
        path: AppRoutes.driverRatePassenger.path,
        name: AppRoutes.driverRatePassenger.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getStringOrThrow('rideId');
          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: DriverRatePassengerScreen(rideId: rideId),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: DriverRatePassengerScreen(rideId: rideId),
                );
        },
      ),
    ];
  }
}
