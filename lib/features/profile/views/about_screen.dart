import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// About screen showing app info, version, team, and legal links.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.settingsAbout,
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
          children: [
            SizedBox(height: 24.h),

            // App logo and name
            Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sports_rounded,
                    size: 48.sp,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            SizedBox(height: 20.h),

            Text(
              'SportConnect',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 4.h),

            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
            ).animate().fadeIn(delay: 150.ms),

            SizedBox(height: 8.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Built with Flutter',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 32.h),

            // Description
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'SportConnect is a carpooling and rideshare platform designed '
                'for sports enthusiasts. Share rides to games, tournaments, '
                'and training sessions while saving money, reducing emissions, '
                'and connecting with fellow athletes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),

            SizedBox(height: 24.h),

            // Features
            Row(
              children: [
                _buildStatCard('Eco', 'Ride-Share', Icons.eco_rounded),
                SizedBox(width: 12.w),
                _buildStatCard('Live', 'Tracking', Icons.gps_fixed_rounded),
                SizedBox(width: 12.w),
                _buildStatCard('Sport', 'Community', Icons.sports_rounded),
              ],
            ).animate().fadeIn(delay: 400.ms),

            SizedBox(height: 28.h),

            // Links
            _buildLinkCard(
              icon: Icons.description_outlined,
              title: l10n.settingsTermsConditions,
              onTap: () => context.push(AppRoutes.terms.path),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05),

            SizedBox(height: 8.h),

            _buildLinkCard(
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacyPolicy,
              onTap: () => context.push(AppRoutes.privacy.path),
            ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.05),

            SizedBox(height: 8.h),

            _buildLinkCard(
              icon: Icons.code_rounded,
              title: 'Open Source Licenses',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'SportConnect',
                applicationVersion: '1.0.0',
              ),
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05),

            SizedBox(height: 8.h),

            _buildLinkCard(
              icon: Icons.help_center_outlined,
              title: l10n.settingsHelpCenter,
              onTap: () => context.push(AppRoutes.helpCenter.path),
            ).animate().fadeIn(delay: 650.ms).slideX(begin: 0.05),

            SizedBox(height: 24.h),

            // Social / Community
            Text(
              'Join the Community',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 700.ms),

            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  Icons.language_rounded,
                  'Website',
                  AppColors.primary,
                ),
                SizedBox(width: 16.w),
                _buildSocialButton(
                  Icons.email_outlined,
                  'Email',
                  const Color(0xFFEA4335),
                ),
                SizedBox(width: 16.w),
                _buildSocialButton(
                  Icons.group_rounded,
                  'Community',
                  const Color(0xFF1DA1F2),
                ),
              ],
            ).animate().fadeIn(delay: 750.ms),

            SizedBox(height: 32.h),

            // Copyright
            Text(
              '\u00a9 2025-2026 SportConnect. All rights reserved.',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ).animate().fadeIn(delay: 700.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22.sp, color: color),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
            Icon(icon, size: 22.sp, color: AppColors.primary),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
