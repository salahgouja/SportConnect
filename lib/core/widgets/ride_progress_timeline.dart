import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

/// Visual step-by-step progress timeline for a ride journey.
///
/// Shows: Booked → Driver Left → Arriving → Riding → Arrived
/// Adapts based on [RideStatus] and [BookingStatus].
class RideProgressTimeline extends StatelessWidget {
  const RideProgressTimeline({
    super.key,
    required this.rideStatus,
    required this.bookingStatus,
    this.compact = false,
  });

  final RideStatus rideStatus;
  final BookingStatus bookingStatus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final currentIndex = _currentStepIndex();

    if (compact) {
      return _CompactTimeline(steps: steps, currentIndex: currentIndex);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Progress',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isActive = i == currentIndex;
            final isCompleted = i < currentIndex;
            final isLast = i == steps.length - 1;

            return _TimelineStep(
              icon: step.icon,
              label: step.label,
              subtitle: step.subtitle,
              isActive: isActive,
              isCompleted: isCompleted,
              isLast: isLast,
              animationDelay: Duration(milliseconds: i * 80),
            );
          }),
        ],
      ),
    );
  }

  int _currentStepIndex() {
    if (bookingStatus == BookingStatus.cancelled ||
        bookingStatus == BookingStatus.rejected) {
      return -1; // No active step
    }

    return switch (rideStatus) {
      RideStatus.draft ||
      RideStatus.active ||
      RideStatus.full => bookingStatus == BookingStatus.accepted ? 1 : 0,
      RideStatus.inProgress => 3,
      RideStatus.completed => 4,
      RideStatus.cancelled => -1,
    };
  }

  List<_StepData> _buildSteps() {
    return [
      _StepData(
        icon: Icons.check_circle_outline_rounded,
        label: 'Booked',
        subtitle: 'Ride confirmed',
      ),
      _StepData(
        icon: Icons.directions_car_rounded,
        label: 'Driver Left',
        subtitle: 'On the way to pickup',
      ),
      _StepData(
        icon: Icons.pin_drop_rounded,
        label: 'Arriving',
        subtitle: 'Almost at pickup point',
      ),
      _StepData(
        icon: Icons.moving_rounded,
        label: 'Riding',
        subtitle: 'En route to destination',
      ),
      _StepData(
        icon: Icons.flag_rounded,
        label: 'Arrived',
        subtitle: 'You\'ve reached your destination',
      ),
    ];
  }
}

class _StepData {
  const _StepData({
    required this.icon,
    required this.label,
    required this.subtitle,
  });
  final IconData icon;
  final String label;
  final String subtitle;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
    required this.animationDelay,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final Color stepColor;
    if (isCompleted) {
      stepColor = AppColors.success;
    } else if (isActive) {
      stepColor = AppColors.primary;
    } else {
      stepColor = AppColors.textTertiary.withValues(alpha: 0.4);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 32.w,
            child: Column(
              children: [
                // Step circle
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? stepColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stepColor,
                      width: isActive ? 2 : 1.5,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : icon,
                    size: 14.sp,
                    color: stepColor,
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive || isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isActive
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: animationDelay, duration: 250.ms);
  }
}

/// Compact horizontal progress indicator version.
class _CompactTimeline extends StatelessWidget {
  const _CompactTimeline({required this.steps, required this.currentIndex});

  final List<_StepData> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector
          final segmentIndex = i ~/ 2;
          final completed = segmentIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: completed ? AppColors.success : AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final step = steps[stepIndex];
        final isCompleted = stepIndex < currentIndex;
        final isActive = stepIndex == currentIndex;

        final Color dotColor;
        if (isCompleted) {
          dotColor = AppColors.success;
        } else if (isActive) {
          dotColor = AppColors.primary;
        } else {
          dotColor = AppColors.textTertiary.withValues(alpha: 0.3);
        }

        return Tooltip(
          message: step.label,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? dotColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: dotColor, width: isActive ? 2 : 1.5),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : step.icon,
              size: 12.sp,
              color: dotColor,
            ),
          ),
        );
      }),
    );
  }
}
