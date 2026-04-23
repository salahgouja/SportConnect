import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Detailed view of a single driver payout with status, amountInCents, and timeline.
class PayoutDetailScreen extends ConsumerWidget {
  const PayoutDetailScreen({required this.payoutId, super.key});

  final String payoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payoutAsync = ref.watch(payoutDetailProvider(payoutId));

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.payoutDetails,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: payoutAsync.when(
        loading: () =>
            const SkeletonLoader(type: SkeletonType.compactTile, itemCount: 4),
        error: (_, _) => _buildErrorView(context, l10n, ref),
        data: (payout) => payout == null
            ? _buildNotFoundView(context, l10n)
            : _buildPayoutContent(context, l10n, ref, payout),
      ),
    );
  }

  Widget _buildPayoutContent(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    DriverPayout payout,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.invalidate(payoutDetailProvider(payoutId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            _buildAmountCard(context, l10n, payout),
            SizedBox(height: 20.h),

            // Status Card
            _buildStatusCard(context, l10n, payout),
            SizedBox(height: 20.h),

            // Details Section
            _buildDetailsSection(context, l10n, payout, dateFormat),
            SizedBox(height: 20.h),

            // Actions
            if (payout.isPending)
              _buildCancelButton(context, l10n, ref, payout),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(
    BuildContext context,
    AppLocalizations l10n,
    DriverPayout payout,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Text(
            l10n.payoutAmount,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '€${(payout.amountInCents / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (payout.isInstantPayout == true) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                l10n.instantPayout,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    DriverPayout payout,
  ) {
    final statusInfo = _getPayoutStatusInfo(l10n, payout.status);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusInfo.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusInfo.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(statusInfo.icon, color: statusInfo.color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusInfo.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    AppLocalizations l10n,
    DriverPayout payout,
    DateFormat dateFormat,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payoutDetailsSection,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          if (payout.createdAt != null)
            _buildDetailRow(l10n.date, dateFormat.format(payout.createdAt!)),
          if (payout.expectedArrivalDate != null)
            _buildDetailRow(
              l10n.expectedArrival,
              dateFormat.format(payout.expectedArrivalDate!),
            ),
          if (payout.arrivedAt != null)
            _buildDetailRow(
              l10n.arrivedAt,
              dateFormat.format(payout.arrivedAt!),
            ),
          if (payout.stripePayoutId != null)
            _buildDetailRow(
              l10n.transactionId,
              payout.stripePayoutId!.length > 20
                  ? '${payout.stripePayoutId!.substring(0, 20)}...'
                  : payout.stripePayoutId!,
            ),
          if (payout.failureReason != null)
            _buildDetailRow(l10n.failureReason, payout.failureReason!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    DriverPayout payout,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _confirmCancel(context, l10n, ref, payout),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          foregroundColor: AppColors.error,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(l10n.cancelPayout),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
    DriverPayout payout,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.cancelPayout),
        content: Text(l10n.cancelPayoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final success = await ref
        .read(driverPayoutViewModelProvider.notifier)
        .cancelPayout(payout.id);

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(payoutDetailProvider(payoutId));
      AdaptiveSnackBar.show(
        context,
        message: l10n.payoutCancelled,
        type: AdaptiveSnackBarType.success,
      );
    } else {
      AdaptiveSnackBar.show(
        context,
        message: l10n.payoutCancelFailed,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Widget _buildNotFoundView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.payoutNotFound,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.payoutNotFound,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () => ref.invalidate(payoutDetailProvider(payoutId)),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  _PayoutStatusInfo _getPayoutStatusInfo(
    AppLocalizations l10n,
    PayoutStatus status,
  ) {
    switch (status) {
      case PayoutStatus.pending:
        return _PayoutStatusInfo(
          label: l10n.statusPending,
          description: l10n.payoutPendingDesc,
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
        );
      case PayoutStatus.inTransit:
        return _PayoutStatusInfo(
          label: l10n.payoutInTransit,
          description: l10n.payoutInTransitDesc,
          icon: Icons.local_shipping_rounded,
          color: AppColors.info,
        );
      case PayoutStatus.paid:
        return _PayoutStatusInfo(
          label: l10n.payoutPaid,
          description: l10n.payoutPaidDesc,
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
        );
      case PayoutStatus.failed:
        return _PayoutStatusInfo(
          label: l10n.statusFailed,
          description: l10n.payoutFailedDesc,
          icon: Icons.error_rounded,
          color: AppColors.error,
        );
      case PayoutStatus.cancelled:
        return _PayoutStatusInfo(
          label: l10n.statusCancelled,
          description: l10n.payoutCancelledDesc,
          icon: Icons.cancel_rounded,
          color: AppColors.textSecondary,
        );
    }
  }
}

class _PayoutStatusInfo {
  const _PayoutStatusInfo({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String label;
  final String description;
  final IconData icon;
  final Color color;
}
