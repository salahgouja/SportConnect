import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';

/// Handles ride-specific notification routing.
///
/// Encapsulates the logic for navigating to the correct screen
/// based on the notification type and payload data.
class RideNotificationHandler {
  const RideNotificationHandler._();

  /// Navigate to the appropriate ride screen based on notification data.
  ///
  /// Returns `true` if the notification was handled, `false` otherwise.
  static bool handle(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final referenceId = data['referenceId'] as String?;

    if (type == null || referenceId == null) return false;

    switch (type) {
      case 'ride_booking_request':
        TalkerService.info('Navigating to driver requests from notification');
        context.push(AppRoutes.driverRequests.path);
        return true;

      case 'ride_booking_accepted':
      case 'ride_booking_rejected':
      case 'ride_booking_cancelled':
        TalkerService.info(
          'Navigating to rider view ride ($type) for ride $referenceId',
        );
        context.push(
          AppRoutes.riderViewRide.path.replaceFirst(':id', referenceId),
        );
        return true;

      case 'ride_starting_soon':
      case 'ride_started':
        TalkerService.info(
          'Navigating to active ride ($type) for ride $referenceId',
        );
        context.push('${AppRoutes.riderActiveRide.path}?rideId=$referenceId');
        return true;

      case 'ride_completed':
        TalkerService.info(
          'Navigating to ride completion for ride $referenceId',
        );
        context.push(
          AppRoutes.rideCompletion.path.replaceFirst(':id', referenceId),
        );
        return true;

      case 'ride_cancelled':
        TalkerService.info(
          'Navigating to ride detail (cancelled) for ride $referenceId',
        );
        context.push(
          AppRoutes.rideDetail.path.replaceFirst(':id', referenceId),
        );
        return true;

      default:
        return false;
    }
  }
}
