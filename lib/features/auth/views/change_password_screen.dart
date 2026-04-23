import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/view_models/change_password_view_model.dart';
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
  final _form = FormGroup(
    {
      'new_password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.delegate((control) {
            final value = control.value as String?;
            if (value == null || value.isEmpty) return null;
            if (!RegExp('[A-Z]').hasMatch(value)) {
              return {'password': 'Include at least one uppercase letter'};
            }
            if (!RegExp('[a-z]').hasMatch(value)) {
              return {'password': 'Include at least one lowercase letter'};
            }
            if (!RegExp('[0-9]').hasMatch(value)) {
              return {'password': 'Include at least one number'};
            }
            return null;
          }),
        ],
      ),
      'confirm_password': FormControl<String>(
        validators: [Validators.required],
      ),
    },
    validators: [
      Validators.mustMatch('new_password', 'confirm_password'),
    ],
  );

  Future<void> _changePassword() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;
    await ref
        .read(changePasswordViewModelProvider.notifier)
        .submit(_form.control('new_password').value as String);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(changePasswordViewModelProvider);

    ref.listen(changePasswordViewModelProvider, (previous, next) async {
      if (next.requiresReauth && previous?.requiresReauth != true) {
        final success = await showReauthDialog(context, ref);
        if (!mounted) return;
        if (success) {
          await ref
              .read(changePasswordViewModelProvider.notifier)
              .retryAfterReauth();
          if (!mounted) return;
        } else {
          ref
              .read(changePasswordViewModelProvider.notifier)
              .dismissReauthRequest();
        }
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          context.mounted) {
        final errorText = next.errorMessage == 'weak-password'
            ? l10n.changePasswordWeakError
            : l10n.changePasswordGenericError;
        AdaptiveSnackBar.show(
          context,
          message: errorText,
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: IconButton(
          tooltip: l10n.goBack,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: l10n.changePasswordTitle,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              vmState.isSuccess
                  ? _buildSuccessState()
                  : _buildFormState(l10n, vmState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(AppLocalizations l10n, ChangePasswordState vmState) {
    return ReactiveForm(
      formGroup: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),

          // Icon
          GlassPanel(
                padding: EdgeInsets.all(20.w),
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

          ReactiveTextField<String>(
            formControlName: 'new_password',
            decoration: InputDecoration(
              labelText: l10n.changePasswordNew,
              hintText: l10n.changePasswordNewHint,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: vmState.obscureNewPassword
                    ? l10n.tooltipShowPassword
                    : l10n.tooltipHidePassword,
                icon: Icon(
                  vmState.obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                ),
                onPressed: () => ref
                    .read(changePasswordViewModelProvider.notifier)
                    .toggleNewPasswordVisibility(),
              ),
            ),
            obscureText: vmState.obscureNewPassword,
            validationMessages: {
              ValidationMessage.required: (_) => 'Password is required',
              ValidationMessage.minLength: (_) =>
                  'Password must be at least 8 characters',
              'password': (error) => error as String,
            },
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

          SizedBox(height: 20.h),

          ReactiveTextField<String>(
            formControlName: 'confirm_password',
            decoration: InputDecoration(
              labelText: l10n.changePasswordConfirm,
              hintText: l10n.changePasswordConfirmHint,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: vmState.obscureConfirmPassword
                    ? l10n.tooltipShowPassword
                    : l10n.tooltipHidePassword,
                icon: Icon(
                  vmState.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                ),
                onPressed: () => ref
                    .read(changePasswordViewModelProvider.notifier)
                    .toggleConfirmPasswordVisibility(),
              ),
            ),
            obscureText: vmState.obscureConfirmPassword,
            validationMessages: {
              ValidationMessage.required: (_) => 'Please confirm your password',
              ValidationMessage.mustMatch: (_) => 'Passwords do not match',
            },
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: l10n.changePasswordUpdate,
              onPressed: vmState.isLoading ? null : _changePassword,
              isLoading: vmState.isLoading,
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
            icon: Icons.adaptive.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 32.h),
      ],
    );
  }
}
