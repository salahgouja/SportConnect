import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Monthly ride summary card (#92)
class MonthlyRideSummary extends StatelessWidget {
  const MonthlyRideSummary({
    required this.totalRides,
    required this.totalSpent,
    required this.totalEarned,
    required this.totalDistance,
    required this.month,
    super.key,
  });
  final int totalRides;
  final double totalSpent;
  final double totalEarned;
  final double totalDistance;
  final String month;

  @override
  Widget build(BuildContext context) {
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
          SizedBox(height: 8.h),
          Row(
            children: [
              _summaryTile(
                'Spent',
                '€${totalSpent.toStringAsFixed(2)}',
                Icons.arrow_upward_rounded,
              ),
              SizedBox(width: 8.w),
              _summaryTile(
                'Earned',
                '€${totalEarned.toStringAsFixed(2)}',
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

class MonthlyCost {
  const MonthlyCost(this.label, this.amountInCents);
  final String label;
  final int amountInCents;
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
    required int baseFare,
    required int serviceFeeInCents,
    required int totalInCents,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(rideDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
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
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Receipt #$receiptId',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
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
                '€${(baseFare / 100).toStringAsFixed(2)}',
              ),
              _pdfRow(
                'Service Fee',
                '€${(serviceFeeInCents / 100).toStringAsFixed(2)}',
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
                    '€${(totalInCents / 100).toStringAsFixed(2)}',
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
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
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
    required int baseFare,
    required int serviceFeeInCents,
    required int totalInCents,
  }) async {
    final bytes = await generate(
      receiptId: receiptId,
      riderName: riderName,
      driverName: driverName,
      origin: origin,
      destination: destination,
      rideDate: rideDate,
      baseFare: baseFare,
      serviceFeeInCents: serviceFeeInCents,
      totalInCents: totalInCents,
    );

    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}

/// Refund request flow (#100)
class RefundRequestSheet extends StatefulWidget {
  const RefundRequestSheet({
    required this.rideId,
    required this.paidAmount,
    required this.onSubmit,
    super.key,
  });
  final String rideId;
  final int paidAmount;
  final ValueChanged<RefundRequest> onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String rideId,
    required int paidAmount,
    required ValueChanged<RefundRequest> onSubmit,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).requestRefund,
      maxHeightFactor: 0.86,
      child: RefundRequestSheet(
        rideId: rideId,
        paidAmount: paidAmount,
        onSubmit: onSubmit,
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
            ).amountPaid((widget.paidAmount / 100).toStringAsFixed(2)),
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
          RadioGroup<RefundReason>(
            groupValue: _reason,
            onChanged: (v) => setState(() => _reason = v),
            child: Column(
              children: RefundReason.values
                  .map(
                    (reason) => RadioListTile<RefundReason>.adaptive(
                      value: reason,
                      title: Text(
                        reason.localizedLabel(context),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
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
                          amountInCents: widget.paidAmount,
                        ),
                      );
                      Navigator.of(context).pop();
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
  const RefundRequest({
    required this.rideId,
    required this.reason,
    required this.details,
    required this.amountInCents,
  });
  final String rideId;
  final RefundReason reason;
  final String details;
  final int amountInCents;
}
