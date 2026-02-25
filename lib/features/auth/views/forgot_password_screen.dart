import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Dedicated Forgot Password screen with email-based password reset.
/// Provides a full-screen experience with:
/// - Email input with validation
/// - Success confirmation with check-inbox guidance
/// - Resend timer to prevent spam
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authActions = ref.read(authActionsViewModelProvider);
      await authActions.sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
          _resendCooldown = 60;
        });
        _startResendTimer();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).forgotPasswordSendError,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _emailSent ? _buildSuccessState(l10n) : _buildFormState(l10n),
        ),
      ),
    );
  }

  Widget _buildFormState(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Icon
          GlassPanel(
                padding: EdgeInsets.all(20.w),
                radius: 20,
                color: AppColors.surface.withValues(alpha: 0.62),
                borderColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.lock_reset_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: 28.h),

          Text(
            l10n.authResetPassword,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          SizedBox(height: 12.h),

          Text(
            l10n.enterYourEmailAddressAnd,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          SizedBox(height: 36.h),

          PremiumTextField(
            controller: _emailController,
            label: l10n.authEmail,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.forgotPasswordEmailRequired;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return l10n.forgotPasswordInvalidEmail;
              }
              return null;
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.authResetPassword,
              onPressed: _isLoading ? null : _sendResetEmail,
              isLoading: _isLoading,
              icon: Icons.send_rounded,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 24.h),

          // Back to login link
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, size: 18.sp),
              label: Text(
                l10n.forgotPasswordBackToLogin,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        // Success icon
        GlassPanel(
              padding: EdgeInsets.all(24.w),
              radius: 999,
              color: AppColors.success.withValues(alpha: 0.12),
              borderColor: AppColors.success.withValues(alpha: 0.25),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 32.h),

        Text(
          l10n.forgotPasswordCheckEmail,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.passwordResetEmailSentCheck,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 16.h),

        // Show email sent to
        GlassPanel(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          radius: 12,
          color: AppColors.surface.withValues(alpha: 0.62),
          borderColor: AppColors.primary.withValues(alpha: 0.2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                _emailController.text.trim(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 40.h),

        // Resend button
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: _resendCooldown > 0
                ? l10n.forgotPasswordResendIn(_resendCooldown)
                : l10n.forgotPasswordResendEmail,
            onPressed: _resendCooldown > 0 || _isLoading
                ? null
                : _sendResetEmail,
            style: PremiumButtonStyle.secondary,
            icon: Icons.refresh_rounded,
          ),
        ).animate().fadeIn(delay: 500.ms),

        SizedBox(height: 16.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.forgotPasswordBackToLogin,
            onPressed: () => context.pop(),
            icon: Icons.login_rounded,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }
}
