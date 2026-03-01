import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Cancellation reason selection screen.
///
/// Shows selectable reasons for ride cancellation with:
/// - Pre-defined reason chips
/// - Optional comment field
/// - Cancellation policy warning
/// - Confirmation dialog
class CancellationReasonScreen extends ConsumerStatefulWidget {
  final String rideId;
  final bool isDriver;

  const CancellationReasonScreen({
    super.key,
    required this.rideId,
    this.isDriver = false,
  });

  @override
  ConsumerState<CancellationReasonScreen> createState() =>
      _CancellationReasonScreenState();
}

class _CancellationReasonScreenState
    extends ConsumerState<CancellationReasonScreen> {
  String? _selectedReason;
  String _commentText = '';
  bool _isSubmitting = false;

  List<_CancelReason> get _reasons =>
      widget.isDriver ? _driverReasons : _riderReasons;

  static const _riderReasons = [
    _CancelReason(
      'Change of plans',
      Icons.event_busy_rounded,
      'My schedule changed and I can no longer make this ride.',
    ),
    _CancelReason(
      'Found another ride',
      Icons.swap_horiz_rounded,
      'I found a more convenient ride option.',
    ),
    _CancelReason(
      'Price too high',
      Icons.money_off_rounded,
      'The ride cost is more than I expected.',
    ),
    _CancelReason(
      'Safety concern',
      Icons.shield_outlined,
      'I have concerns about the safety of this ride.',
    ),
    _CancelReason(
      'Driver not responding',
      Icons.chat_bubble_outline_rounded,
      'The driver is not responding to messages.',
    ),
    _CancelReason(
      'Incorrect details',
      Icons.error_outline_rounded,
      'The ride details are incorrect or have changed.',
    ),
    _CancelReason(
      'Emergency',
      Icons.emergency_rounded,
      'I have an unexpected emergency.',
    ),
    _CancelReason(
      'Other',
      Icons.more_horiz_rounded,
      'Another reason not listed above.',
    ),
  ];

  static const _driverReasons = [
    _CancelReason(
      'Vehicle issue',
      Icons.car_repair_rounded,
      'My vehicle has a mechanical problem or is unavailable.',
    ),
    _CancelReason(
      'Passenger not at pickup',
      Icons.person_off_rounded,
      'The passenger was not at the agreed pickup location.',
    ),
    _CancelReason(
      'Change of plans',
      Icons.event_busy_rounded,
      'My schedule changed and I can no longer make this ride.',
    ),
    _CancelReason(
      'Safety concern',
      Icons.shield_outlined,
      'I have concerns about the safety of this ride.',
    ),
    _CancelReason(
      'Passenger not responding',
      Icons.chat_bubble_outline_rounded,
      'The passenger is not responding to messages.',
    ),
    _CancelReason(
      'Route issue',
      Icons.wrong_location_rounded,
      'There is a road closure or route problem.',
    ),
    _CancelReason(
      'Emergency',
      Icons.emergency_rounded,
      'I have an unexpected emergency.',
    ),
    _CancelReason(
      'Other',
      Icons.more_horiz_rounded,
      'Another reason not listed above.',
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitCancellation() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a cancellation reason'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final comment = _commentText.trim();
      final reason = comment.isNotEmpty
          ? '$_selectedReason | $comment'
          : _selectedReason!;

      await ref
          .read(rideActionsViewModelProvider)
          .cancelRide(widget.rideId, reason);

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).rideCancelledSuccessfully,
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
        context.pop(true); // Return true to indicate cancellation
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to cancel ride. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).cancelRide2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this ride?',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18.sp,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Frequent cancellations may affect your account rating.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Ride'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).cancelRide2),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.cancelRide2,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // Warning banner
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Please let us know why you\'re cancelling so we can '
                      'improve our service.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.error.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: 24.h),

            Text(
              'Select a reason',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 16.h),

            // Reason cards
            ...List.generate(_reasons.length, (index) {
              final reason = _reasons[index];
              final isSelected = _selectedReason == reason.title;
              return _buildReasonCard(reason, isSelected)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 150 + (index * 50)))
                  .slideX(begin: 0.05);
            }),

            SizedBox(height: 20.h),

            // Additional comments
            Text(
              'Additional comments (optional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 600.ms),

            SizedBox(height: 8.h),

            TextField(
              onChanged: (v) => setState(() => _commentText = v),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us more about why you\'re cancelling...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ).animate().fadeIn(delay: 650.ms),

            SizedBox(height: 32.h),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: 'Cancel Ride',
                onPressed: _isSubmitting ? null : _submitCancellation,
                isLoading: _isSubmitting,
                icon: Icons.cancel_rounded,
                style: PremiumButtonStyle.danger,
              ),
            ).animate().fadeIn(delay: 700.ms),

            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: 'Keep My Ride',
                onPressed: () => context.pop(false),
                style: PremiumButtonStyle.ghost,
                icon: Icons.arrow_back_rounded,
              ),
            ).animate().fadeIn(delay: 750.ms),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard(_CancelReason reason, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedReason = reason.title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                reason.icon,
                size: 20.sp,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    reason.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelReason {
  final String title;
  final IconData icon;
  final String description;

  const _CancelReason(this.title, this.icon, this.description);
}
