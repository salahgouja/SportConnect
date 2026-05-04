import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_card.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';
import 'package:sport_connect/features/payments/view_models/premium_checkout_view_model.dart';

class PremiumCheckoutScreen extends ConsumerStatefulWidget {
  const PremiumCheckoutScreen({super.key});

  @override
  ConsumerState<PremiumCheckoutScreen> createState() =>
      _PremiumCheckoutScreenState();
}

class _PremiumCheckoutScreenState extends ConsumerState<PremiumCheckoutScreen> {
  bool _isLoadingPlans = true;
  String? _plansErrorMessage;
  Map<PremiumPlan, ProductDetails> _storeProducts = const {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _preselectPlanFromRoute();
      _loadStorePlans();
    });
  }

  void _preselectPlanFromRoute() {
    final extra = GoRouterState.of(context).extra;

    if (extra is Map<String, dynamic> && extra.containsKey('cycle')) {
      final cycleName = extra['cycle'] as String?;
      final plan = cycleName == 'yearly'
          ? PremiumPlan.yearly
          : PremiumPlan.monthly;

      ref.read(premiumCheckoutViewModelProvider.notifier).selectPlan(plan);
    }
  }

  Future<void> _loadStorePlans() async {
    setState(() {
      _isLoadingPlans = true;
      _plansErrorMessage = null;
    });

    try {
      final products = await ref
          .read(premiumIapServiceProvider.notifier)
          .fetchAvailablePlans();

      if (!mounted) return;

      setState(() {
        _storeProducts = products;
        _isLoadingPlans = false;
      });

      final selectedPlan = ref
          .read(premiumCheckoutViewModelProvider)
          .selectedPlan;

      if (!_storeProducts.containsKey(selectedPlan) &&
          _storeProducts.isNotEmpty) {
        ref
            .read(premiumCheckoutViewModelProvider.notifier)
            .selectPlan(_storeProducts.keys.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _storeProducts = const {};
        _isLoadingPlans = false;
        _plansErrorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(premiumCheckoutViewModelProvider);
    final selectedPlanAvailable =
        _storeProducts.isEmpty ||
        _storeProducts.containsKey(state.selectedPlan);

    return AdaptiveScaffold(
      appBar: const AdaptiveAppBar(
        title: 'Premium Checkout',
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

              if (_isLoadingPlans) ...[
                PremiumCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Loading subscription plans...',
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
                SizedBox(height: 18.h),
              ],

              _PlanTile(
                plan: PremiumPlan.monthly,
                product: _storeProducts[PremiumPlan.monthly],
                isSelected: state.selectedPlan == PremiumPlan.monthly,
                isAvailable: _isPlanAvailable(PremiumPlan.monthly),
                onTap: () => _selectPlan(PremiumPlan.monthly),
              ),
              SizedBox(height: 12.h),
              _PlanTile(
                plan: PremiumPlan.yearly,
                product: _storeProducts[PremiumPlan.yearly],
                isSelected: state.selectedPlan == PremiumPlan.yearly,
                isAvailable: _isPlanAvailable(PremiumPlan.yearly),
                onTap: () => _selectPlan(PremiumPlan.yearly),
              ),

              if (_plansErrorMessage != null) ...[
                SizedBox(height: 12.h),
                Text(
                  _cleanErrorMessage(_plansErrorMessage!),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _loadStorePlans,
                  child: Text(
                    'Retry loading plans',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

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
                onPressed: _isLoadingPlans || !selectedPlanAvailable
                    ? null
                    : _onSubscribePressed,
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  _priceLabelForPlan(
                    state.selectedPlan,
                    _storeProducts[state.selectedPlan],
                  ),
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

  bool _isPlanAvailable(PremiumPlan plan) {
    if (_isLoadingPlans) return false;

    if (_plansErrorMessage != null) {
      return true;
    }

    if (_storeProducts.isEmpty) {
      return true;
    }

    return _storeProducts.containsKey(plan);
  }

  void _selectPlan(PremiumPlan plan) {
    if (!_isPlanAvailable(plan)) return;

    ref.read(premiumCheckoutViewModelProvider.notifier).selectPlan(plan);
  }

  Future<void> _onSubscribePressed() async {
    final viewModel = ref.read(premiumCheckoutViewModelProvider.notifier);
    final success = await viewModel.completeCheckout();

    if (!mounted) return;

    if (!success) return;

    AdaptiveSnackBar.show(
      context,
      message: 'Premium activated successfully.',
      type: AdaptiveSnackBarType.success,
    );

    if (!mounted) return;

    final user = ref.read(currentUserProvider).value;
    final destination = user is DriverModel
        ? AppRoutes.driverHome.path
        : AppRoutes.home.path;

    context.go(destination);
  }

  String _priceLabelForPlan(PremiumPlan plan, ProductDetails? product) {
    if (product == null) {
      return plan.priceLabel;
    }

    return '${product.price} / ${plan.billingPeriodLabel}';
  }

  String _cleanErrorMessage(String message) {
    return message.replaceFirst('Bad state: ', '');
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.product,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
  });

  final PremiumPlan plan;
  final ProductDetails? product;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final opacity = isAvailable ? 1.0 : 0.48;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: isAvailable ? onTap : null,
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
                      isAvailable
                          ? plan.helperText
                          : 'This plan is not available from the store yet.',
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
                _priceLabelForPlan(plan, product),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priceLabelForPlan(PremiumPlan plan, ProductDetails? product) {
    if (product == null) {
      return plan.priceLabel;
    }

    return '${product.price} / ${plan.billingPeriodLabel}';
  }
}
