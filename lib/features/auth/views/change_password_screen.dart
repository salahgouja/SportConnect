import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/validators.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/views/reauth_dialog.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Change Password screen for authenticated users.
///
/// Allows users to update their password with validation.
/// Shows a re-authentication prompt if the session is too old.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updatePassword(_newPasswordController.text);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final l10n = AppLocalizations.of(context);

      if (e is AuthException && e.code == 'requires-recent-login') {
        // Show re-auth dialog and retry
        final success = await showReauthDialog(context, ref);
        if (success && mounted) {
          return _changePassword();
        }
        return;
      }

      final errorText = (e is AuthException && e.code == 'weak-password')
          ? l10n.changePasswordWeakError
          : l10n.changePasswordGenericError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorText),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
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
        title: Text(
          l10n.changePasswordTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _isSuccess ? _buildSuccessState() : _buildFormState(l10n),
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
                  Icons.lock_outline_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          SizedBox(height: 28.h),

          Text(
            l10n.changePasswordHeading,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

          SizedBox(height: 12.h),

          Text(
            l10n.changePasswordDesc,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

          SizedBox(height: 36.h),

          PremiumTextField(
            controller: _newPasswordController,
            label: l10n.changePasswordNew,
            hint: l10n.changePasswordNewHint,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureNew,
            validator: Validators.password,
            suffix: IconButton(
              tooltip: _obscureNew ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 20.h),

          PremiumTextField(
            controller: _confirmPasswordController,
            label: l10n.changePasswordConfirm,
            hint: l10n.changePasswordConfirmHint,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirm,
            validator: (value) =>
                Validators.confirmPassword(value, _newPasswordController.text),
            suffix: IconButton(
              tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiary,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.changePasswordUpdate,
              onPressed: _isLoading ? null : _changePassword,
              isLoading: _isLoading,
              icon: Icons.check_rounded,
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(height: 60.h),

        GlassPanel(
              padding: EdgeInsets.all(24.w),
              radius: 999,
              color: AppColors.success.withValues(alpha: 0.12),
              borderColor: AppColors.success.withValues(alpha: 0.25),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 32.h),

        Text(
          l10n.changePasswordSuccess,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          l10n.changePasswordSuccessDesc,
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
            text: l10n.changePasswordDone,
            onPressed: () => context.pop(),
            icon: Icons.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 32.h),
      ],
    );
  }
}
