import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';

/// Screen for drivers to connect their Stripe account for payouts
class DriverStripeOnboardingScreen extends ConsumerStatefulWidget {
  const DriverStripeOnboardingScreen({super.key});

  @override
  ConsumerState<DriverStripeOnboardingScreen> createState() =>
      _DriverStripeOnboardingScreenState();
}

class _DriverStripeOnboardingScreenState
    extends ConsumerState<DriverStripeOnboardingScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _onboardingUrl;
  bool _showWebView = false;

  @override
  Widget build(BuildContext context) {
    if (_showWebView && _onboardingUrl != null) {
      return _buildWebView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Set Up Payouts',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Hero illustration
                      Container(
                        padding: EdgeInsets.all(30.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 80.sp,
                          color: AppColors.primary,
                        ),
                      ).animate().scale(
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),

                      SizedBox(height: 30.h),

                      Text(
                        'Get Paid for Your Rides',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: 12.h),

                      Text(
                        'Connect your bank account to receive payments directly from riders. Powered by Stripe for secure transactions.',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),

                      SizedBox(height: 40.h),

                      // Benefits
                      _buildBenefitItem(
                        icon: Icons.bolt_rounded,
                        title: 'Instant Payouts',
                        description: 'Get your money in minutes, not days',
                        delay: 400,
                      ),
                      _buildBenefitItem(
                        icon: Icons.security_rounded,
                        title: 'Secure & Protected',
                        description: 'Bank-level security with Stripe',
                        delay: 500,
                      ),
                      _buildBenefitItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'Clear Tracking',
                        description: 'See every ride payment in detail',
                        delay: 600,
                      ),
                      _buildBenefitItem(
                        icon: Icons.percent_rounded,
                        title: 'Low Fees',
                        description: 'Keep 85% of every ride payment',
                        delay: 700,
                      ),

                      if (_errorMessage != null) ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppColors.error),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // CTA Button
              SizedBox(height: 20.h),
              PremiumButton(
                text: 'Set Up Stripe Account',
                isLoading: _isLoading,
                onPressed: _startOnboarding,
                style: PremiumButtonStyle.primary,
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

              SizedBox(height: 12.h),

              Text(
                'You\'ll be redirected to Stripe to complete setup',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1);
  }

  Future<void> _startOnboarding() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please sign in to continue';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ref
          .read(paymentViewModelProvider.notifier)
          .createConnectedAccount(
            userId: user.uid,
            email: user.email,
            country: 'FR', // France
          );

      if (result != null && result['onboardingUrl'] != null) {
        setState(() {
          _onboardingUrl = result['onboardingUrl'];
          _showWebView = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to create Stripe account. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildWebView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connect Stripe',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _showWebView = false;
              _onboardingUrl = null;
            });
          },
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_onboardingUrl!)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useShouldOverrideUrlLoading: true,
        ),
        onLoadStop: (controller, url) {
          // Check if we've been redirected back from Stripe
          final urlStr = url?.toString() ?? '';
          if (urlStr.contains('stripe-refresh') ||
              urlStr.contains('stripe-return')) {
            // Onboarding complete - close and refresh
            context.pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stripe account connected successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onLoadError: (controller, url, code, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading page: $message')),
          );
        },
      ),
    );
  }
}
