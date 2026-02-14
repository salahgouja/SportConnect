import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Detailed view of a single driver payout with transaction breakdown.
class PayoutDetailScreen extends ConsumerStatefulWidget {
  const PayoutDetailScreen({required this.payoutId, super.key});

  final String payoutId;

  @override
  ConsumerState<PayoutDetailScreen> createState() => _PayoutDetailScreenState();
}

class _PayoutDetailScreenState extends ConsumerState<PayoutDetailScreen> {
  Map<String, dynamic>? _payoutData;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayoutDetails();
  }

  Future<void> _loadPayoutDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final payoutDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payouts')
          .doc(widget.payoutId)
          .get();

      if (mounted && !payoutDoc.exists) {
        setState(() {
          _error = 'Payout not found';
          _isLoading = false;
        });
        return;
      }

      final transactionsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payouts')
          .doc(widget.payoutId)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _payoutData = payoutDoc.data();
          _transactions = transactionsSnap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load payout details';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Payout Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildErrorView() {
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
            _error!,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadPayoutDetails();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _payoutData!;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final status = (data['status'] as String?) ?? 'pending';
    final createdAt = data['createdAt'] as Timestamp?;
    final completedAt = data['completedAt'] as Timestamp?;
    final ridesCount =
        (data['ridesCount'] as num?)?.toInt() ?? _transactions.length;
    final fees = (data['fees'] as num?)?.toDouble() ?? 0;
    final netAmount = amount - fees;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        SizedBox(height: 16.h),

        // Amount card
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total Payout',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '\$${netAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 12.h),
              _buildStatusBadge(status),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPayoutMeta('Rides', '$ridesCount'),
                  Container(
                    width: 1,
                    height: 30.h,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  _buildPayoutMeta(
                    'Date',
                    createdAt != null
                        ? DateFormat('MMM dd').format(createdAt.toDate())
                        : '--',
                  ),
                  Container(
                    width: 1,
                    height: 30.h,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  _buildPayoutMeta('Fees', '\$${fees.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),

        SizedBox(height: 24.h),

        // Breakdown
        Text(
          'Breakdown',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBreakdownRow(
                'Gross Earnings',
                '\$${amount.toStringAsFixed(2)}',
              ),
              Divider(height: 20.h, color: AppColors.border),
              _buildBreakdownRow(
                'Platform Fee',
                '-\$${fees.toStringAsFixed(2)}',
                isDeduction: true,
              ),
              Divider(height: 20.h, color: AppColors.border),
              _buildBreakdownRow(
                'Net Payout',
                '\$${netAmount.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 24.h),

        // Timeline
        Text(
          'Timeline',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 350.ms),
        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTimelineItem(
                'Payout Created',
                createdAt != null
                    ? DateFormat(
                        'MMM dd, yyyy • HH:mm',
                      ).format(createdAt.toDate())
                    : 'N/A',
                Icons.add_circle_outline_rounded,
                isComplete: true,
              ),
              _buildTimelineItem(
                'Processing',
                status == 'pending' ? 'In progress...' : 'Completed',
                Icons.sync_rounded,
                isComplete: status != 'pending',
              ),
              _buildTimelineItem(
                'Completed',
                completedAt != null
                    ? DateFormat(
                        'MMM dd, yyyy • HH:mm',
                      ).format(completedAt.toDate())
                    : status == 'completed'
                    ? 'Completed'
                    : 'Pending',
                Icons.check_circle_outline_rounded,
                isComplete: status == 'completed',
                isLast: true,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 24.h),

        // Transactions list
        if (_transactions.isNotEmpty) ...[
          Text(
            'Rides Included',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 450.ms),
          SizedBox(height: 12.h),
          ..._transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final txn = entry.value;
            final txnAmount = (txn['amount'] as num?)?.toDouble() ?? 0;
            final txnDate = txn['createdAt'] as Timestamp?;
            final from = txn['from'] as String? ?? 'Unknown';
            final to = txn['to'] as String? ?? 'Unknown';

            return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$from → $to',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              txnDate != null
                                  ? DateFormat(
                                      'MMM dd, HH:mm',
                                    ).format(txnDate.toDate())
                                  : '--',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+\$${txnAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (500 + index * 50).ms)
                .slideX(begin: 0.03);
          }),
        ],

        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final isCompleted = status == 'completed';
    final isPending = status == 'pending';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted
                ? Icons.check_circle_rounded
                : isPending
                ? Icons.hourglass_top_rounded
                : Icons.error_rounded,
            size: 14.sp,
            color: Colors.white,
          ),
          SizedBox(width: 6.w),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMeta(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    bool isBold = false,
    bool isDeduction = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isDeduction
                ? AppColors.error
                : isBold
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon, {
    required bool isComplete,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: isComplete
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isComplete
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
