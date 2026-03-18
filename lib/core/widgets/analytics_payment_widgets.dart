import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Monthly ride summary card (#92)
class MonthlyRideSummary extends StatelessWidget {
  final int totalRides;
  final int asDriver;
  final int asPassenger;
  final double totalSpent;
  final double totalEarned;
  final double totalDistance;
  final String month;

  const MonthlyRideSummary({
    super.key,
    required this.totalRides,
    required this.asDriver,
    required this.asPassenger,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalDistance,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$totalRides rides',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _summaryTile('As Driver', '$asDriver', Icons.directions_car),
              SizedBox(width: 8.w),
              _summaryTile(
                'As Rider',
                '$asPassenger',
                Icons.airline_seat_recline_normal,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _summaryTile(
                'Spent',
                '\$${totalSpent.toStringAsFixed(2)}',
                Icons.arrow_upward_rounded,
              ),
              SizedBox(width: 8.w),
              _summaryTile(
                'Earned',
                '\$${totalEarned.toStringAsFixed(2)}',
                Icons.arrow_downward_rounded,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_rounded, size: 16.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Text(
                  '${totalDistance.toStringAsFixed(1)} km covered',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: Colors.white70),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ride cost history chart (#94) — simple bar chart
class RideCostHistoryChart extends StatelessWidget {
  final List<MonthlyCost> data;

  const RideCostHistoryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) return const SizedBox.shrink();

    final maxVal = data.map((e) => e.amount).reduce(math.max);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Cost History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 140.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final ratio = maxVal > 0 ? item.amount / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '\$${item.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: (110.h * ratio).clamp(4.0, 110.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyCost {
  final String label;
  final double amount;
  const MonthlyCost(this.label, this.amount);
}

/// Payment receipt PDF generator (#99)
class PaymentReceiptGenerator {
  static Future<Uint8List> generate({
    required String receiptId,
    required String riderName,
    required String driverName,
    required String origin,
    required String destination,
    required DateTime rideDate,
    required double baseFare,
    required double serviceFee,
    required double total,
    String currency = 'USD',
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('MMM dd, yyyy – hh:mm a').format(rideDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SportConnect',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Payment Receipt',
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Receipt #$receiptId',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),
              _pdfRow('Date', dateStr),
              _pdfRow('Rider', riderName),
              _pdfRow('Driver', driverName),
              pw.SizedBox(height: 12),
              _pdfRow('From', origin),
              _pdfRow('To', destination),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              _pdfRow(
                'Base Fare',
                '\$$currency ${baseFare.toStringAsFixed(2)}',
              ),
              _pdfRow(
                'Service Fee',
                '\$$currency ${serviceFee.toStringAsFixed(2)}',
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$$currency ${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'Thank you for riding with SportConnect!',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Flexible(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Show print/share dialog
  static Future<void> showReceipt(
    BuildContext context, {
    required String receiptId,
    required String riderName,
    required String driverName,
    required String origin,
    required String destination,
    required DateTime rideDate,
    required double baseFare,
    required double serviceFee,
    required double total,
  }) async {
    final bytes = await generate(
      receiptId: receiptId,
      riderName: riderName,
      driverName: driverName,
      origin: origin,
      destination: destination,
      rideDate: rideDate,
      baseFare: baseFare,
      serviceFee: serviceFee,
      total: total,
    );

    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}

/// Refund request flow (#100)
class RefundRequestSheet extends StatefulWidget {
  final String rideId;
  final double paidAmount;
  final ValueChanged<RefundRequest> onSubmit;

  const RefundRequestSheet({
    super.key,
    required this.rideId,
    required this.paidAmount,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String rideId,
    required double paidAmount,
    required ValueChanged<RefundRequest> onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierLabel: AppLocalizations.of(context).requestRefund,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RefundRequestSheet(
          rideId: rideId,
          paidAmount: paidAmount,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<RefundRequestSheet> createState() => _RefundRequestSheetState();
}

class _RefundRequestSheetState extends State<RefundRequestSheet> {
  RefundReason? _reason;
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).requestRefund,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AppLocalizations.of(
              context,
            ).amountPaid(widget.paidAmount.toStringAsFixed(2)),
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).reasonForRefund,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          ...RefundReason.values.map(
            (reason) => RadioListTile<RefundReason>(
              value: reason,
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v),
              title: Text(
                reason.localizedLabel(context),
                style: TextStyle(fontSize: 14.sp),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _detailsController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).additionalDetailsOptional,
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _reason == null
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onSubmit(
                        RefundRequest(
                          rideId: widget.rideId,
                          reason: _reason!,
                          details: _detailsController.text.trim(),
                          amount: widget.paidAmount,
                        ),
                      );
                      Navigator.pop(context);
                    },
              child: Text(AppLocalizations.of(context).submitRefundRequest),
            ),
          ),
        ],
      ),
    );
  }
}

enum RefundReason {
  driverNoShow,
  rideNotAsDescribed,
  unsafeExperience,
  overcharged,
  cancelledByDriver,
  other,
}

extension RefundReasonL10n on RefundReason {
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case RefundReason.driverNoShow:
        return l10n.refundReasonDriverNoShow;
      case RefundReason.rideNotAsDescribed:
        return l10n.refundReasonRideNotAsDescribed;
      case RefundReason.unsafeExperience:
        return l10n.refundReasonUnsafeExperience;
      case RefundReason.overcharged:
        return l10n.refundReasonOvercharged;
      case RefundReason.cancelledByDriver:
        return l10n.refundReasonCancelledByDriver;
      case RefundReason.other:
        return l10n.refundReasonOther;
    }
  }
}

class RefundRequest {
  final String rideId;
  final RefundReason reason;
  final String details;
  final double amount;

  const RefundRequest({
    required this.rideId,
    required this.reason,
    required this.details,
    required this.amount,
  });
}
