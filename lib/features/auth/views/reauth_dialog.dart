import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/view_models/reauth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Shows a re-authentication dialog for sensitive operations.
///
/// Returns `true` if re-authentication succeeded, `false` otherwise.
/// Used before delete-account and change-password when Firebase
/// throws `requires-recent-login`.
Future<bool> showReauthDialog(BuildContext context, WidgetRef ref) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ReauthBottomSheet(),
  );
  return result ?? false;
}

class _ReauthBottomSheet extends ConsumerStatefulWidget {
  const _ReauthBottomSheet();

  @override
  ConsumerState<_ReauthBottomSheet> createState() => _ReauthBottomSheetState();
}

class _ReauthBottomSheetState extends ConsumerState<_ReauthBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vmState = ref.watch(reauthViewModelProvider);

    // Pop the dialog on successful re-auth.
    ref.listen(reauthViewModelProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        Navigator.of(context).pop(true);
      }
    });

    // Map error codes to localised messages.
    String? errorText;
    if (vmState.errorCode != null) {
      switch (vmState.errorCode) {
        case 'wrong-password':
          errorText = l10n.reauthWrongPassword;
        case 'google':
          errorText = l10n.reauthGoogleFailed;
        default:
          errorText = l10n.reauthFailed;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.all(24.w),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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

              SizedBox(height: 24.h),

              // Icon
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 28.sp,
                  color: AppColors.warning,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                l10n.reauthTitle,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                l10n.reauthSubtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Password field
              FormBuilderTextField(
                name: 'password',
                decoration: InputDecoration(
                  labelText: l10n.reauthPassword,
                  hintText: l10n.reauthPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                validator: FormBuilderValidators.required(
                  errorText: l10n.reauthPasswordRequired,
                ),
              ),

              if (errorText != null) ...[
                SizedBox(height: 8.h),
                Text(
                  errorText,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                ),
              ],

              SizedBox(height: 24.h),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: l10n.reauthConfirm,
                  onPressed: vmState.isLoading
                      ? null
                      : () {
                          if (!(_formKey.currentState?.saveAndValidate() ??
                              false)) {
                            return;
                          }
                          ref
                              .read(reauthViewModelProvider.notifier)
                              .reauthWithPassword(
                                _formKey.currentState!.fields['password']!.value
                                    as String,
                              );
                        },
                  isLoading: vmState.isLoading,
                  icon: Icons.check_rounded,
                ),
              ),

              SizedBox(height: 12.h),

              // Google re-auth option
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: l10n.reauthWithGoogle,
                  onPressed: vmState.isLoading
                      ? null
                      : () => ref
                            .read(reauthViewModelProvider.notifier)
                            .reauthWithGoogle(),
                  style: PremiumButtonStyle.secondary,
                  icon: Icons.g_mobiledata_rounded,
                ),
              ),

              SizedBox(height: 8.h),

              // Cancel
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    l10n.reauthCancel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
