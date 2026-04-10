import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class TaxDocumentsScreen extends StatelessWidget {
  const TaxDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.taxDocuments,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                'Available Forms',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              _buildTaxCard(
                icon: Icons.description_outlined,
                title: '2025 1099-K Form',
                status: 'Available',
                isAvailable: true,
                context: context,
              ),
              SizedBox(height: 12.h),
              _buildTaxCard(
                icon: Icons.description_outlined,
                title: '2024 1099-K Form',
                status: 'Available',
                isAvailable: true,
                context: context,
              ),
              SizedBox(height: 12.h),
              _buildTaxCard(
                icon: Icons.description_outlined,
                title: '2026 1099-K Form',
                status: 'Not available yet',
                isAvailable: false,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaxCard({
    required IconData icon,
    required String title,
    required String status,
    required bool isAvailable,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isAvailable ? AppColors.primary : AppColors.textSecondary,
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
                    color: isAvailable
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isAvailable)
            IconButton(
              icon: const Icon(Icons.download, color: AppColors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading document...')),
                );
              },
            ),
        ],
      ),
    );
  }
}
