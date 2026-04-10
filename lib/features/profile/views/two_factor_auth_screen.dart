import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _isTfaEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.twoFactorAuthentication,
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
                'Protect your account',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Two-factor authentication adds an extra layer of security to your account. To log in, you\'ll need to provide your password and a verification code.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 48.h),
              Container(
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.message_outlined,
                        color: AppColors.primary,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMS Verification',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Receive codes via text message',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isTfaEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _isTfaEnabled = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? '2FA Enabled via SMS' : '2FA Disabled',
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
