import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/analytics_payment_widgets.dart';

/// Payment History Screen - View all payment transactions for a rider
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  static const _filterKeys = [
    'all',
    'completed',
    'pending',
    'refunded',
    'failed',
  ];

  String _filterLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'all':
        return l10n.filterAll;
      case 'completed':
        return l10n.filterCompleted;
      case 'pending':
        return l10n.filterPending;
      case 'refunded':
        return l10n.filterRefunded;
      case 'failed':
        return l10n.filterFailed;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedFilter = ref
        .watch(paymentHistoryFilterViewModelProvider)
        .selectedFilter;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).pleaseSignInToView2),
            ),
          );
        }

        final paymentsAsync = ref.watch(
          riderPaymentHistoryStreamProvider(user.uid),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(riderPaymentHistoryStreamProvider(user.uid));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120.h,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeader(context),
                  ),
                  title: Text(
                    AppLocalizations.of(context).paymentHistory,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: _buildFilterChips(context, ref, selectedFilter),
                ),

                // Payment List
                paymentsAsync.when(
                  data: (payments) {
                    final filteredPayments = ref.watch(
                      filteredRiderPaymentsProvider(payments),
                    );

                    if (filteredPayments.isEmpty) {
                      return SliverFillRemaining(
                        child: _buildEmptyState(context),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPaymentCard(
                          context,
                          ref,
                          filteredPayments[index],
                          index,
                        ),
                        childCount: filteredPayments.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).errorValue(error),
                      ),
                    ),
                  ),
                ),

                // Bottom Padding
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).errorValue(error)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).yourTransactions,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    String selectedFilter,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: _filterKeys.map((key) {
            final isSelected = selectedFilter == key;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: Text(_filterLabel(context, key)),
                selected: isSelected,
                onSelected: (_) => ref
                    .read(paymentHistoryFilterViewModelProvider.notifier)
                    .setFilter(key),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).noPaymentsFound,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).yourPaymentHistoryWillAppear,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref,
    PaymentTransaction payment,
    int index,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Dismissible(
      key: ValueKey('payment_${payment.id}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        _showPaymentDetails(context, ref, payment);
        return false;
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.info, AppColors.info.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).details,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child:
          Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _showPaymentDetails(context, ref, payment),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        // Status Icon
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              payment.status,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _getStatusIcon(payment.status),
                            color: _getStatusColor(payment.status),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Payment Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).ridePayment,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                payment.createdAt != null
                                    ? dateFormat.format(payment.createdAt!)
                                    : AppLocalizations.of(context).unknownDate,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    payment.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  _getStatusText(context, payment.status),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(payment.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppLocalizations.of(context).valueValue4(
                                payment.amount.toStringAsFixed(2),
                                payment.currency,
                              ),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (payment.seatsBooked != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                AppLocalizations.of(context).valueSeatValue(
                                  payment.seatsBooked!,
                                  payment.seatsBooked! > 1 ? 's' : '',
                                ),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index * 50))
              .slideX(begin: 0.1),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.succeeded:
        return AppColors.success;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return AppColors.warning;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return AppColors.error;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.succeeded:
        return Icons.check_circle_rounded;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return Icons.schedule_rounded;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        return Icons.cancel_rounded;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        return Icons.refresh_rounded;
    }
  }

  String _getStatusText(BuildContext context, PaymentStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case PaymentStatus.succeeded:
        return l10n.statusCompleted;
      case PaymentStatus.pending:
        return l10n.statusPending;
      case PaymentStatus.processing:
        return l10n.statusProcessing;
      case PaymentStatus.failed:
        return l10n.statusFailed;
      case PaymentStatus.cancelled:
        return l10n.statusCancelled;
      case PaymentStatus.refunded:
        return l10n.statusRefunded;
      case PaymentStatus.partiallyRefunded:
        return l10n.statusPartiallyRefunded;
    }
  }

  void _showPaymentDetails(
    BuildContext context,
    WidgetRef ref,
    PaymentTransaction payment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Title
                  Text(
                    AppLocalizations.of(context).paymentDetails,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Amount
                  _buildDetailRow(
                    AppLocalizations.of(context).amount,
                    AppLocalizations.of(context).valueValue4(
                      payment.amount.toStringAsFixed(2),
                      payment.currency,
                    ),
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context).status,
                    _getStatusText(context, payment.status),
                  ),
                  _buildDetailRow(
                    AppLocalizations.of(context).driver,
                    payment.driverName,
                  ),
                  if (payment.seatsBooked != null)
                    _buildDetailRow(
                      AppLocalizations.of(context).seats2,
                      AppLocalizations.of(context).value2(payment.seatsBooked!),
                    ),
                  _buildDetailRow(
                    AppLocalizations.of(context).platformFee,
                    AppLocalizations.of(context).valueValue4(
                      payment.platformFee.toStringAsFixed(2),
                      payment.currency,
                    ),
                  ),
                  if (payment.stripeFee > 0)
                    _buildDetailRow(
                      'Processing Fee',
                      '${payment.stripeFee.toStringAsFixed(2)} ${payment.currency}',
                    ),
                  _buildDetailRow(
                    'Driver Earnings',
                    '${payment.driverEarnings.toStringAsFixed(2)} ${payment.currency}',
                  ),
                  if (payment.paymentMethodLast4 != null)
                    _buildDetailRow(
                      AppLocalizations.of(context).card,
                      AppLocalizations.of(
                        context,
                      ).value7(payment.paymentMethodLast4!),
                    ),
                  if (payment.createdAt != null)
                    _buildDetailRow(
                      AppLocalizations.of(context).date,
                      DateFormat(
                        'MMM dd, yyyy HH:mm',
                      ).format(payment.createdAt!),
                    ),
                  if (payment.stripePaymentIntentId != null)
                    _buildDetailRow(
                      AppLocalizations.of(context).transactionId,
                      '${payment.stripePaymentIntentId!.substring(0, 20)}...',
                    ),
                  if (payment.failureReason != null &&
                      payment.failureReason!.isNotEmpty)
                    _buildDetailRow('Failure Reason', payment.failureReason!),
                  if (payment.refundReason != null &&
                      payment.refundReason!.isNotEmpty)
                    _buildDetailRow('Refund Reason', payment.refundReason!),

                  SizedBox(height: 24.h),

                  // Refund button (if applicable)
                  if (payment.canBeRefunded)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                          RefundRequestSheet.show(
                            context,
                            rideId: payment.rideId,
                            paidAmount: payment.amount,
                            onSubmit: (request) {
                              _requestRefund(context, ref, payment);
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: AppColors.error,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context).requestRefund),
                      ),
                    ),

                  // Receipt button (for completed payments)
                  if (payment.status == PaymentStatus.succeeded) ...[
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          PaymentReceiptGenerator.showReceipt(
                            context,
                            receiptId: payment.id,
                            riderName: 'Rider',
                            driverName: payment.driverName,
                            origin: payment.rideId,
                            destination: '',
                            rideDate: payment.createdAt ?? DateTime.now(),
                            baseFare: payment.amount - payment.platformFee,
                            serviceFee: payment.platformFee,
                            total: payment.amount,
                          );
                        },
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('Download Receipt'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _requestRefund(
  BuildContext context,
  WidgetRef ref,
  PaymentTransaction payment,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context).requestRefund),
      content: Text(
        AppLocalizations.of(context).areYouSureYouWant10(
          '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(AppLocalizations.of(context).actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            AppLocalizations.of(context).requestRefund,
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await ref
        .read(paymentViewModelProvider.notifier)
        .refundBookingPayment(
          paymentId: payment.id,
          reason: 'User requested refund',
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).refundRequestSubmitted),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).refundRequestFailed),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
