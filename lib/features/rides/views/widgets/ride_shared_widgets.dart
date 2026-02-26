import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Vertical timeline connecting origin to destination with a gradient line.
///
/// Used in route cards across ride detail, rider view, and search screens.
class RideRouteTimeline extends StatelessWidget {
  /// Height of the gradient connector line.
  final double lineHeight;

  /// Size of the origin dot.
  final double dotSize;

  /// Size of the destination icon.
  final double iconSize;

  const RideRouteTimeline({
    super.key,
    this.lineHeight = 40,
    this.dotSize = 12,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize.w,
          height: dotSize.w,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2.w,
          height: lineHeight.h,
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
          size: iconSize.sp,
        ),
      ],
    );
  }
}

/// A single info chip showing an icon, value, and label stacked vertically.
///
/// Used in route cards to display duration, distance, and seats.
class RideInfoChip extends StatelessWidget {
  /// Icon displayed at the top.
  final IconData icon;

  /// Main value text (e.g. "45 min").
  final String value;

  /// Descriptive label (e.g. "Duration").
  final String label;

  /// Icon color. Defaults to [AppColors.primary].
  final Color? iconColor;

  const RideInfoChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: 22.sp),
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
}

/// An icon + label + value row for displaying ride details.
///
/// Used for departure time, price, and other structured information.
class RideDetailInfoRow extends StatelessWidget {
  /// Leading icon.
  final IconData icon;

  /// Label text (e.g. "Departure").
  final String label;

  /// Value text (e.g. "Mon, Jun 3 • 9:00 AM").
  final String value;

  /// Background color for the icon container.
  final Color? iconBackground;

  /// Icon color. Defaults to [AppColors.primary].
  final Color? iconColor;

  const RideDetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconBackground,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color:
                iconBackground ??
                AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20.sp),
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
}

/// A chip showing an amenity's allowed/disallowed state.
///
/// Used in ride detail and driver view screens for pets, smoking, luggage, etc.
class RideAmenityChip extends StatelessWidget {
  /// Icon representing the amenity.
  final IconData icon;

  /// Amenity label text.
  final String label;

  /// Whether the amenity is allowed.
  final bool isAllowed;

  const RideAmenityChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isAllowed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isAllowed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
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
}

/// A small badge with icon and label used for driver profile info.
///
/// Shows verification, experience, and other badges.
class RideDriverBadge extends StatelessWidget {
  /// Badge icon.
  final IconData icon;

  /// Badge label text.
  final String label;

  /// Badge accent color.
  final Color color;

  const RideDriverBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A stat display widget with a value and label stacked vertically.
///
/// Used in ride summary cards and trip stat sections.
class RideTripStat extends StatelessWidget {
  /// The stat label (e.g. "Distance").
  final String label;

  /// The stat value (e.g. "45 km").
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// Color for the icon. Defaults to [AppColors.primary].
  final Color? iconColor;

  const RideTripStat({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24.sp, color: iconColor ?? AppColors.primary),
          SizedBox(height: 4.h),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
