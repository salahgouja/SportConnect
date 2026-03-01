import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/view_models/phone_auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Phone OTP verification screen.
///
/// Two-phase flow:
///   1. **Phone input** – user enters their phone number and taps "Send Code".
///   2. **Code input** – user enters the 6-digit SMS code and taps "Verify".
///
/// Uses [PhoneAuthViewModel] for state management, and the route guard
/// handles navigation once the user is authenticated.
class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _phoneFormKey = GlobalKey<FormBuilderState>();
  final _codeFormKey = GlobalKey<FormBuilderState>();

  String _sentPhone = '';

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _sendCode() async {
    if (!(_phoneFormKey.currentState?.saveAndValidate() ?? false)) return;
    final phone = (_phoneFormKey.currentState!.value['phone'] as String).trim();
    setState(() => _sentPhone = phone);
    await ref.read(phoneAuthViewModelProvider.notifier).sendCode(phone);
    _startResendCooldown();
  }

  Future<void> _verifyCode() async {
    if (!(_codeFormKey.currentState?.saveAndValidate() ?? false)) return;
    final code = (_codeFormKey.currentState!.value['code'] as String).trim();
    if (code.length != 6) return;
    await ref
        .read(phoneAuthViewModelProvider.notifier)
        .verifyCode(code, phoneNumber: _sentPhone);
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0) return;
    await ref.read(phoneAuthViewModelProvider.notifier).resendCode(_sentPhone);
    _startResendCooldown();
  }

  void _startResendCooldown() {
    if (!mounted) return;
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cooldownTimer?.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) _cooldownTimer?.cancel();
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phoneState = ref.watch(phoneAuthViewModelProvider);

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
          child: phoneState.map(
            idle: (_) => _buildPhoneInput(l10n),
            sending: (_) => _buildPhoneInput(l10n, isLoading: true),
            codeSent: (_) => _buildCodeInput(l10n),
            verifying: (_) => _buildCodeInput(l10n, isLoading: true),
            verified: (_) => _buildSuccessState(l10n),
            error: (errorState) => _buildErrorState(l10n, errorState.message),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Phase 1 – Phone number input
  // ---------------------------------------------------------------------------

  Widget _buildPhoneInput(AppLocalizations l10n, {bool isLoading = false}) {
    return FormBuilder(
      key: _phoneFormKey,
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
                  Icons.phone_android_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: 28.h),

          // Title
          Text(
            l10n.otpTitle,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          SizedBox(height: 12.h),

          Text(
            l10n.otpEnterPhone,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          SizedBox(height: 36.h),

          // Phone field
          FormBuilderTextField(
            name: 'phone',
            decoration: InputDecoration(
              labelText: l10n.otpPhoneHint,
              hintText: '+1 234 567 8900',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.otpPhoneRequired;
              }
              // Minimal validation: at least 8 digits
              final digits = value.replaceAll(RegExp(r'[^\d]'), '');
              if (digits.length < 8) {
                return l10n.otpInvalidPhone;
              }
              return null;
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          // Send code button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.otpSendCode,
              onPressed: isLoading ? null : _sendCode,
              isLoading: isLoading,
              icon: Icons.send_rounded,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 24.h),

          // Back to login
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, size: 18.sp),
              label: Text(
                l10n.otpBackToLogin,
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

  // ---------------------------------------------------------------------------
  // Phase 2 – OTP code input
  // ---------------------------------------------------------------------------

  Widget _buildCodeInput(AppLocalizations l10n, {bool isLoading = false}) {
    return FormBuilder(
      key: _codeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Icon
          GlassPanel(
                padding: EdgeInsets.all(20.w),
                radius: 20,
                color: AppColors.primarySurface.withValues(alpha: 0.8),
                borderColor: AppColors.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.sms_outlined,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: 28.h),

          Text(
            l10n.otpVerifyTitle,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          SizedBox(height: 12.h),

          Text(
            '${l10n.otpEnterCode} $_sentPhone',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          SizedBox(height: 36.h),

          // 6-digit code field
          FormBuilderTextField(
            name: 'code',
            decoration: InputDecoration(
              labelText: l10n.otpCodeLabel,
              hintText: '000000',
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onSubmitted: (_) => _verifyCode(),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          // Verify button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.otpVerify,
              onPressed: isLoading ? null : _verifyCode,
              isLoading: isLoading,
              icon: Icons.verified_user_outlined,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 20.h),

          // Resend code
          Center(
            child: _resendCooldown > 0
                ? Text(
                    l10n.otpResendIn(_resendCooldown),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                : TextButton.icon(
                    onPressed: _resendCode,
                    icon: Icon(Icons.refresh_rounded, size: 18.sp),
                    label: Text(
                      l10n.otpResendCode,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ).animate().fadeIn(delay: 500.ms),

          SizedBox(height: 16.h),

          // Change phone number
          Center(
            child: TextButton(
              onPressed: () {
                _codeFormKey.currentState?.reset();
                ref.read(phoneAuthViewModelProvider.notifier).reset();
              },
              child: Text(
                l10n.otpChangePhone,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
  // ---------------------------------------------------------------------------

  Widget _buildSuccessState(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: 60.h),

        GlassPanel(
              padding: EdgeInsets.all(24.w),
              radius: 20,
              color: AppColors.successSurface.withValues(alpha: 0.8),
              borderColor: AppColors.success.withValues(alpha: 0.3),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 28.h),

        Text(
          l10n.otpPhoneVerified,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.otpPhoneVerifiedDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 40.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: l10n.otpContinue,
            onPressed: () => context.go(AppRoutes.splash.path),
            icon: Icons.arrow_forward_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Error state – shows error message with retry button
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(AppLocalizations l10n, String message) {
    return Column(
      children: [
        SizedBox(height: 40.h),

        GlassPanel(
              padding: EdgeInsets.all(20.w),
              radius: 20,
              color: AppColors.errorSurface.withValues(alpha: 0.8),
              borderColor: AppColors.error.withValues(alpha: 0.3),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.8, 0.8)),

        SizedBox(height: 24.h),

        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.error,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 100.ms),

        SizedBox(height: 32.h),

        Row(
          children: [
            Expanded(
              child: PremiumButton(
                text: l10n.otpTryAgain,
                style: PremiumButtonStyle.secondary,
                onPressed: () {
                  _codeFormKey.currentState?.fields['code']?.didChange('');
                  ref.read(phoneAuthViewModelProvider.notifier).reset();
                },
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}
