import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Provides pre-permission rationale dialogs before requesting runtime
/// permissions.
///
/// Both Apple App Store and Google Play Store require showing a
/// user-friendly explanation *before* the system permission prompt.
class PermissionDialogHelper {
  PermissionDialogHelper._();

  /// Shows a rationale dialog for location permission.
  ///
  /// Returns `true` if the user accepts, `false` if they decline.
  static Future<bool> showLocationRationale(
    BuildContext context, {
    String? customMessage,
  }) {
    return _showRationale(
      context,
      icon: Icons.location_on_outlined,
      iconColor: AppColors.primary,
      title: 'Location Access',
      message:
          customMessage ??
          'SportConnect needs your location to show nearby rides, '
              'calculate distances, and provide accurate navigation '
              'during your trips.',
    );
  }

  /// Shows a rationale dialog for location sharing in chat.
  static Future<bool> showLocationSharingRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.share_location_outlined,
      iconColor: AppColors.primary,
      title: 'Share Your Location',
      message:
          'Your current location will be shared with this chat '
          'so other participants can see where you are. Your location '
          'is only shared when you choose to send it.',
    );
  }

  /// Shows a rationale dialog for location tracking during active rides.
  static Future<bool> showRideTrackingRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.navigation_outlined,
      iconColor: AppColors.primary,
      title: 'Ride Navigation',
      message:
          'Location access is needed to track your ride in real-time, '
          'provide turn-by-turn navigation, and share your progress '
          'with fellow riders for safety.',
    );
  }

  /// Shows a rationale dialog for camera/photo access.
  static Future<bool> showCameraRationale(
    BuildContext context, {
    String? customMessage,
  }) {
    return _showRationale(
      context,
      icon: Icons.camera_alt_outlined,
      iconColor: AppColors.secondary,
      title: 'Camera & Photos',
      message:
          customMessage ??
          'Access to your camera and photo library is needed to '
              'attach images. Your photos are only uploaded when you '
              'explicitly choose to share them.',
    );
  }

  /// Shows a rationale dialog for microphone access (voice recording).
  static Future<bool> showMicrophoneRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.mic_outlined,
      iconColor: AppColors.accent,
      title: 'Microphone Access',
      message:
          'Microphone access is needed to record voice messages. '
          'Audio is only recorded when you press and hold the '
          'record button.',
    );
  }

  /// Shows a rationale dialog for notification permission.
  static Future<bool> showNotificationRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.notifications_outlined,
      iconColor: AppColors.primary,
      title: 'Stay Updated',
      message:
          'Enable notifications to receive ride updates, messages '
          'from other riders, booking confirmations, and important '
          'safety alerts.',
    );
  }

  /// Core rationale dialog builder.
  static Future<bool> _showRationale(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            PlatformAdaptive.dialogRadius,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
                border: PlatformAdaptive.isApple
                    ? Border.all(
                        color: iconColor.withValues(alpha: 0.08),
                        width: 0.5,
                      )
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  PlatformAdaptive.buttonRadiusMd,
                ),
              ),
            ),
            child: Text(
              'Not Now',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  PlatformAdaptive.buttonRadiusMd,
                ),
              ),
            ),
            child: Text('Continue', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
