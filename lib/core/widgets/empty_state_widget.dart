import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Custom empty state widget with icon, title, subtitle, and optional action.
///
/// Used across all list screens when no data is available.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  // ── Preset factories ──

  factory EmptyStateWidget.noRides({VoidCallback? onSearch}) =>
      EmptyStateWidget(
        icon: Icons.directions_car_outlined,
        title: 'No rides found',
        subtitle: 'Try adjusting your filters or search for a different route',
        actionLabel: onSearch != null ? 'Search Rides' : null,
        onAction: onSearch,
      );

  factory EmptyStateWidget.noEvents({VoidCallback? onCreate}) =>
      EmptyStateWidget(
        icon: Icons.event_outlined,
        title: 'No events yet',
        subtitle: 'Create an event to bring your group together',
        actionLabel: onCreate != null ? 'Create Event' : null,
        onAction: onCreate,
      );

  factory EmptyStateWidget.noMessages() => const EmptyStateWidget(
    icon: Icons.chat_bubble_outline_rounded,
    title: 'No messages yet',
    subtitle: 'Start a conversation by booking a ride or joining an event',
  );

  factory EmptyStateWidget.noNotifications() => const EmptyStateWidget(
    icon: Icons.notifications_none_rounded,
    title: 'All caught up!',
    subtitle: "You'll see new notifications here",
  );

  factory EmptyStateWidget.noReviews() => const EmptyStateWidget(
    icon: Icons.star_outline_rounded,
    title: 'No reviews yet',
    subtitle: 'Reviews will appear after completed rides',
  );

  factory EmptyStateWidget.noVehicles({VoidCallback? onAdd}) =>
      EmptyStateWidget(
        icon: Icons.garage_outlined,
        title: 'No vehicles added',
        subtitle: 'Add a vehicle to start offering rides',
        actionLabel: onAdd != null ? 'Add Vehicle' : null,
        onAction: onAdd,
      );

  factory EmptyStateWidget.noBookings() => const EmptyStateWidget(
    icon: Icons.bookmark_outline_rounded,
    title: 'No bookings yet',
    subtitle: 'Your ride bookings will appear here',
  );

  factory EmptyStateWidget.noResults() => const EmptyStateWidget(
    icon: Icons.search_off_rounded,
    title: 'No results found',
    subtitle: 'Try different search terms or filters',
  );

  factory EmptyStateWidget.error({VoidCallback? onRetry}) => EmptyStateWidget(
    icon: Icons.error_outline_rounded,
    title: 'Something went wrong',
    subtitle: 'Please try again',
    actionLabel: onRetry != null ? 'Retry' : null,
    onAction: onRetry,
    iconColor: AppColors.error,
  );

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 48.sp : 64.sp;
    final titleSize = compact ? 15.sp : 18.sp;
    final subtitleSize = compact ? 12.sp : 13.sp;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 40.w,
          vertical: compact ? 24.h : 48.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative icon circle
            Container(
              width: (iconSize + 32).sp,
              height: (iconSize + 32).sp,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.6),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),

            SizedBox(height: compact ? 16.h : 24.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

            // Subtitle
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 20.h),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}
