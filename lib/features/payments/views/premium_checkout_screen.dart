import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/view_models/premium_checkout_view_model.dart';

class PremiumCheckoutScreen extends ConsumerStatefulWidget {
  const PremiumCheckoutScreen({super.key});

  @override
  ConsumerState<PremiumCheckoutScreen> createState() =>
      _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState extends ConsumerState<PremiumCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-select plan from the subscribe screen (passed via GoRouter extra).
    // Using initState + postFrameCallback avoids setState-during-build errors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic> && extra.containsKey('cycle')) {
        final cycleName = extra['cycle'] as String?;
        final plan = cycleName == 'yearly'
            ? PremiumPlan.yearly
            : PremiumPlan.monthly;
        ref.read(premiumCheckoutViewModelProvider.notifier).selectPlan(plan);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumCheckoutViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Premium Checkout'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your plan',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Upgrade your SportConnect account in seconds.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 18.h),
              _PlanTile(
                plan: PremiumPlan.monthly,
                isSelected: state.selectedPlan == PremiumPlan.monthly,
                onTap: () => ref
                    .read(premiumCheckoutViewModelProvider.notifier)
                    .selectPlan(PremiumPlan.monthly),
              ),
              SizedBox(height: 12.h),
              _PlanTile(
                plan: PremiumPlan.yearly,
                isSelected: state.selectedPlan == PremiumPlan.yearly,
                onTap: () => ref
                    .read(premiumCheckoutViewModelProvider.notifier)
                    .selectPlan(PremiumPlan.yearly),
              ),
              SizedBox(height: 18.h),
              PremiumCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.success,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Your payment details are encrypted and processed securely.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.errorMessage != null) ...[
                SizedBox(height: 12.h),
                Text(
                  state.errorMessage!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              PremiumButton(
                text: 'Subscribe Now',
                icon: Icons.lock_open_rounded,
                style: PremiumButtonStyle.gold,
                isLoading: state.isProcessing,
                fullWidth: true,
                onPressed: _onSubscribePressed,
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  state.selectedPlan.priceLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubscribePressed() async {
    final viewModel = ref.read(premiumCheckoutViewModelProvider.notifier);
    final success = await viewModel.completeCheckout();
    if (!mounted) return;

    if (!success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium activated successfully.'),
        backgroundColor: AppColors.success,
      ),
    );

    if (!mounted) return;
    final user = ref.read(currentUserProvider).value;
    final destination = user is DriverModel
        ? AppRoutes.driverHome.path
        : AppRoutes.home.path;
    context.go(destination);
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final PremiumPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PremiumCard(
        hasBorder: true,
        borderColor: isSelected ? AppColors.primary : AppColors.borderLight,
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
              size: 22.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    plan.helperText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              plan.priceLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
