import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/glass_panel.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Role Selection Screen - Shown after social sign-in for new users
/// Allows users to choose between being a Rider or Driver
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;
  bool _isLoading = false;

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectARoleTo),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authActions = ref.read(authActionsViewModelProvider);
      final currentUser = authActions.currentUser;

      if (currentUser != null) {
        // Update the user's role in Firestore
        // needsRoleSelection stays true so user can go back during setup
        await authActions.updateUserRole(currentUser.uid, _selectedRole!);

        if (mounted) {
          if (_selectedRole == UserRole.driver) {
            context.go(AppRoutes.driverOnboarding.path);
          } else {
            // Rider setup continues in profile completion.
            // needsRoleSelection remains true until required info is saved.
            if (mounted) context.go(AppRoutes.riderOnboarding.path);
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).roleSelectionError,
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),

              // Header
              _buildHeader()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, curve: Curves.easeOutCubic),

              SizedBox(height: 32.h),

              // Role options
              _buildRoleCard(
                    role: UserRole.rider,
                    icon: Icons.person_rounded,
                    title: AppLocalizations.of(context).iMARider,
                    description:
                        'Find and book rides to sporting events. Save money and reduce your carbon footprint.',
                    features: [
                      'Search available rides',
                      'Book seats instantly',
                      'Chat with drivers',
                      'Track your ride',
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOutCubic),

              SizedBox(height: 16.h),

              _buildRoleCard(
                    role: UserRole.driver,
                    icon: Icons.directions_car_rounded,
                    title: AppLocalizations.of(context).iMADriver,
                    description:
                        'Offer rides and earn money while going to events. Help others get there safely.',
                    features: [
                      'Create ride offers',
                      'Set your own price',
                      'Accept ride requests',
                      'Earn with each trip',
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideX(begin: 0.2, curve: Curves.easeOutCubic),

              SizedBox(height: 32.h),

              // Info text
              Text(
                AppLocalizations.of(context).youCanChangeYourRole,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

              SizedBox(height: 16.h),

              // Continue button
              SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: 'Continue',
                      onPressed: _selectedRole == null || _isLoading
                          ? null
                          : _continueWithRole,
                      isLoading: _isLoading,
                      style: PremiumButtonStyle.gradient,
                      size: ButtonSize.large,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        GlassPanel(
          radius: 999,
          padding: EdgeInsets.all(20.w),
          color: AppColors.surface.withValues(alpha: 0.62),
          borderColor: AppColors.primary.withValues(alpha: 0.2),
          child: Icon(
            Icons.person_add_rounded,
            size: 48.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          AppLocalizations.of(context).howWillYouUseSportconnect,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          AppLocalizations.of(context).chooseYourRoleToGet,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.01 : 1,
        child: GlassPanel(
          padding: EdgeInsets.all(16.w),
          radius: 16,
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.72)
              : AppColors.surface.withValues(alpha: 0.62),
          borderColor: isSelected ? AppColors.primary : AppColors.border,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14.sp,
                                )
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: features.map((feature) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              size: 12.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              feature,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
