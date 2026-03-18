import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Bottom sheet ride summary (#78)
class RideSummarySheet extends StatelessWidget {
  final String origin;
  final String destination;
  final String driverName;
  final double driverRating;
  final String departureTime;
  final String estimatedArrival;
  final String price;
  final String? vehicleInfo;
  final int seatsBooked;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const RideSummarySheet({
    super.key,
    required this.origin,
    required this.destination,
    required this.driverName,
    required this.driverRating,
    required this.departureTime,
    required this.estimatedArrival,
    required this.price,
    this.vehicleInfo,
    this.seatsBooked = 1,
    this.onConfirm,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required String origin,
    required String destination,
    required String driverName,
    required double driverRating,
    required String departureTime,
    required String estimatedArrival,
    required String price,
    String? vehicleInfo,
    int seatsBooked = 1,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierLabel: AppLocalizations.of(context).rideSummary,
      builder: (_) => RideSummarySheet(
        origin: origin,
        destination: destination,
        driverName: driverName,
        driverRating: driverRating,
        departureTime: departureTime,
        estimatedArrival: estimatedArrival,
        price: price,
        vehicleInfo: vehicleInfo,
        seatsBooked: seatsBooked,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          // Title
          Text(
            'Ride Summary',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          // Route
          _buildRouteRow(theme),
          SizedBox(height: 16.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 12.h),
          // Details grid
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  theme,
                  Icons.person_rounded,
                  'Driver',
                  driverName,
                ),
              ),
              Expanded(
                child: _infoTile(
                  theme,
                  Icons.star_rounded,
                  'Rating',
                  driverRating.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  theme,
                  Icons.schedule_rounded,
                  'Departure',
                  departureTime,
                ),
              ),
              Expanded(
                child: _infoTile(
                  theme,
                  Icons.flag_rounded,
                  'Arrival',
                  estimatedArrival,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  theme,
                  Icons.airline_seat_recline_normal_rounded,
                  'Seats',
                  '$seatsBooked',
                ),
              ),
              if (vehicleInfo != null)
                Expanded(
                  child: _infoTile(
                    theme,
                    Icons.directions_car_rounded,
                    'Vehicle',
                    vehicleInfo!,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 12.h),
          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Buttons
          Row(
            children: [
              if (onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      onCancel!();
                    },
                    child: Text(AppLocalizations.of(context).actionCancel),
                  ),
                ),
              if (onCancel != null) SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                  child: Text(AppLocalizations.of(context).confirmBooking),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(ThemeData theme) {
    return Row(
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: 10.sp, color: AppColors.mapPickup),
            Container(
              width: 2.w,
              height: 30.h,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            Icon(Icons.circle, size: 10.sp, color: AppColors.mapDropoff),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              Text(
                destination,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
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

  Widget _infoTile(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated status badge with transitions (#77)
class AnimatedStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const AnimatedStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(label),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe action wrapper for list items (#76)
class SwipeActionTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final IconData leftIcon;
  final IconData rightIcon;
  final Color leftColor;
  final Color rightColor;
  final String? leftLabel;
  final String? rightLabel;

  const SwipeActionTile({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftIcon = Icons.delete_rounded,
    this.rightIcon = Icons.archive_rounded,
    this.leftColor = const Color(0xFFC1666B),
    this.rightColor = const Color(0xFF4A7C88),
    this.leftLabel,
    this.rightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key ?? UniqueKey(),
      background: _buildBackground(
        alignment: Alignment.centerLeft,
        color: rightColor,
        icon: rightIcon,
        label: rightLabel,
      ),
      secondaryBackground: _buildBackground(
        alignment: Alignment.centerRight,
        color: leftColor,
        icon: leftIcon,
        label: leftLabel,
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          onSwipeRight?.call();
        } else {
          onSwipeLeft?.call();
        }
        return false; // Don't actually dismiss — caller handles state
      },
      child: child,
    );
  }

  Widget _buildBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    String? label,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerRight) ...[
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(width: 8.w),
          ],
          Icon(icon, color: Colors.white, size: 22.sp),
          if (alignment == Alignment.centerLeft) ...[
            SizedBox(width: 8.w),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Compact/Expanded list toggle (#81)
class ListViewToggle extends StatelessWidget {
  final bool isCompact;
  final ValueChanged<bool> onToggle;

  const ListViewToggle({
    super.key,
    required this.isCompact,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          icon: Icons.view_list_rounded,
          isSelected: !isCompact,
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(false);
          },
          tooltip: AppLocalizations.of(context).expandedView,
        ),
        SizedBox(width: 4.w),
        _ToggleButton(
          icon: Icons.view_module_rounded,
          isSelected: isCompact,
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(true);
          },
          tooltip: AppLocalizations.of(context).compactView,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _ToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isSelected ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
