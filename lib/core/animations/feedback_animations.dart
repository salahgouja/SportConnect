import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Success/Error/Booking animation overlays (#84, #50)
class FeedbackAnimations {
  FeedbackAnimations._();

  /// Show success animation overlay
  static Future<void> showSuccess(
    BuildContext context, {
    String message = 'Success!',
    VoidCallback? onDismissed,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context).dismissSuccess,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _FeedbackOverlay(
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        message: message,
        onDismissed: onDismissed,
      ),
    );
  }

  /// Show error animation overlay
  static Future<void> showError(
    BuildContext context, {
    String message = 'Something went wrong',
    VoidCallback? onDismissed,
  }) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context).dismissError,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _FeedbackOverlay(
        icon: Icons.error_rounded,
        color: AppColors.error,
        message: message,
        onDismissed: onDismissed,
      ),
    );
  }

  /// Show booking confirmation animation (#50)
  static Future<void> showBookingConfirmation(
    BuildContext context, {
    required String rideInfo,
    required String dateTime,
    VoidCallback? onDismissed,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: AppLocalizations.of(context).bookingConfirmed,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => _BookingConfirmationOverlay(
        rideInfo: rideInfo,
        dateTime: dateTime,
        onDismissed: onDismissed,
      ),
    );
  }
}

class _FeedbackOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onDismissed;

  const _FeedbackOverlay({
    required this.icon,
    required this.color,
    required this.message,
    this.onDismissed,
  });

  @override
  State<_FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<_FeedbackOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDismissed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 32.h),
            margin: EdgeInsets.symmetric(horizontal: 48.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 64.sp,
                  color: widget.color,
                ).animate().scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
                SizedBox(height: 16.h),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _BookingConfirmationOverlay extends StatefulWidget {
  final String rideInfo;
  final String dateTime;
  final VoidCallback? onDismissed;

  const _BookingConfirmationOverlay({
    required this.rideInfo,
    required this.dateTime,
    this.onDismissed,
  });

  @override
  State<_BookingConfirmationOverlay> createState() =>
      _BookingConfirmationOverlayState();
}

class _BookingConfirmationOverlayState
    extends State<_BookingConfirmationOverlay> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child:
          Container(
            padding: EdgeInsets.all(32.w),
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                ).animate().scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
                SizedBox(height: 20.h),
                Text(
                  AppLocalizations.of(context).bookingConfirmedTitle,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                SizedBox(height: 8.h),
                Text(
                  widget.rideInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
                SizedBox(height: 4.h),
                Text(
                  widget.dateTime,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
                SizedBox(height: 24.h),
                SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismissed?.call();
                        },
                        child: Text(AppLocalizations.of(context).great),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 300.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 300.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
