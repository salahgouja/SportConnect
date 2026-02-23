import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';

/// Email Verification screen shown after registration.
///
/// Features:
/// - Real-time verification status polling
/// - Resend verification email with cooldown
/// - Auto-redirect on verification
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _isSending = false;
  int _resendCooldown = 0;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
    _startVerificationPolling();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationPolling() {
    _verificationTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser != null && refreshedUser.emailVerified && mounted) {
      setState(() => _isEmailVerified = true);
      _verificationTimer?.cancel();

      // Auto-redirect after brief delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go(AppRoutes.home.path);
      }
    }
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0 || _isSending) return;

    setState(() => _isSending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      if (mounted) {
        setState(() {
          _isSending = false;
          _resendCooldown = 60;
        });
        _startResendTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to send verification email. Please try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Verify Email',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated icon
              _isEmailVerified
                  ? _buildVerifiedState()
                  : _buildPendingState(user?.email ?? ''),

              const Spacer(flex: 3),

              // Actions
              if (!_isEmailVerified) ...[
                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: _resendCooldown > 0
                        ? 'Resend in ${_resendCooldown}s'
                        : 'Resend Verification Email',
                    onPressed: _resendCooldown > 0 || _isSending
                        ? null
                        : _resendVerification,
                    isLoading: _isSending,
                    icon: Icons.email_outlined,
                    style: PremiumButtonStyle.secondary,
                  ),
                ).animate().fadeIn(delay: 600.ms),

                SizedBox(height: 16.h),

                SizedBox(
                  width: double.infinity,
                  child: PremiumButton(
                    text: 'I\'ve Verified My Email',
                    onPressed: _checkEmailVerified,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ).animate().fadeIn(delay: 700.ms),

                SizedBox(height: 12.h),

                TextButton(
                  onPressed: () => context.go(AppRoutes.home.path),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingState(String email) {
    return Column(
      children: [
        Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_rounded,
                size: 56.sp,
                color: AppColors.primary,
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(
              duration: 2000.ms,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),

        SizedBox(height: 28.h),

        Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          'We\'ve sent a verification link to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 8.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            email,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 20.h),

        // Waiting indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Waiting for verification...',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ],
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildVerifiedState() {
    return Column(
      children: [
        Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                size: 56.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 28.h),

        Text(
          'Email Verified!',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          'Your email has been verified. Redirecting...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
