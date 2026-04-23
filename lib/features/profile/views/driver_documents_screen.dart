import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class DriverDocumentsScreen extends StatelessWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.driverDocuments,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action Required',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              _buildDocumentCard(
                icon: Icons.assignment_ind_outlined,
                title: 'Driver License',
                status: 'Approved',
                isApproved: true,
                context: context,
              ),
              SizedBox(height: 12.h),
              _buildDocumentCard(
                icon: Icons.directions_car_filled_outlined,
                title: 'Vehicle Registration',
                status: 'Approved',
                isApproved: true,
                context: context,
              ),
              SizedBox(height: 12.h),
              _buildDocumentCard(
                icon: Icons.health_and_safety_outlined,
                title: 'Vehicle Insurance',
                status: 'Expired',
                isApproved: false,
                actionText: 'Update',
                context: context,
                onAction: () {
                  AdaptiveSnackBar.show(
                    context,
                    message: 'Upload feature coming soon',
                    type: AdaptiveSnackBarType.info,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required String title,
    required String status,
    required bool isApproved,
    required BuildContext context,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isApproved
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isApproved
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isApproved ? AppColors.success : AppColors.error,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  status,
                  style: TextStyle(
                    color: isApproved ? AppColors.success : AppColors.error,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (isApproved)
            Icon(Icons.check_circle, color: AppColors.success, size: 24.w),
        ],
      ),
    );
  }
}
