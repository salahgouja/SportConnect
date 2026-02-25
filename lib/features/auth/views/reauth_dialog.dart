import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
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
    builder: (ctx) => _ReauthBottomSheet(ref: ref),
  );
  return result ?? false;
}

class _ReauthBottomSheet extends StatefulWidget {
  final WidgetRef ref;

  const _ReauthBottomSheet({required this.ref});

  @override
  State<_ReauthBottomSheet> createState() => _ReauthBottomSheetState();
}

class _ReauthBottomSheetState extends State<_ReauthBottomSheet> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscure = true;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _reauthWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await widget.ref
          .read(authActionsViewModelProvider)
          .reauthenticateWithPassword(_passwordController.text);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isLoading = false;
          _errorText =
              (e is AuthException && e.code == 'wrong-password')
              ? l10n.reauthWrongPassword
              : l10n.reauthFailed;
        });
      }
    }
  }

  Future<void> _reauthWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await widget.ref
          .read(authActionsViewModelProvider)
          .reauthenticateWithGoogle();

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isLoading = false;
          _errorText = l10n.reauthGoogleFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        child: Form(
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
              PremiumTextField(
                controller: _passwordController,
                label: l10n.reauthPassword,
                hint: l10n.reauthPasswordHint,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.reauthPasswordRequired;
                  }
                  return null;
                },
                suffix: IconButton(
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

              if (_errorText != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _errorText!,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.error),
                ),
              ],

              SizedBox(height: 24.h),

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: l10n.reauthConfirm,
                  onPressed: _isLoading ? null : _reauthWithPassword,
                  isLoading: _isLoading,
                  icon: Icons.check_rounded,
                ),
              ),

              SizedBox(height: 12.h),

              // Google re-auth option
              SizedBox(
                width: double.infinity,
                child: PremiumButton(
                  text: l10n.reauthWithGoogle,
                  onPressed: _isLoading ? null : _reauthWithGoogle,
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
