import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Screen for drivers to connect their Stripe account for payouts
///
/// IMPLEMENTATION NOTES:
/// - Uses InAppWebView for better UX (user stays in app)
/// - This is SAFE for Stripe Connect (not for payment collection!)
/// - Stripe handles all security and validation
/// - Verifies account status after onboarding
class DriverStripeOnboardingScreen extends ConsumerStatefulWidget {
  const DriverStripeOnboardingScreen({super.key});

  @override
  ConsumerState<DriverStripeOnboardingScreen> createState() =>
      _DriverStripeOnboardingScreenState();
}

class _DriverStripeOnboardingScreenState
    extends ConsumerState<DriverStripeOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(driverStripeOnboardingFlowViewModelProvider.notifier)
          .checkExistingAccount(ref.read(currentUserProvider).value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(
      driverStripeOnboardingFlowViewModelProvider,
    );

    ref.listen(driverStripeOnboardingFlowViewModelProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage &&
          context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (next.isConnected &&
          previous?.isConnected != true &&
          context.mounted) {
        context.go(AppRoutes.driverHome.path);
      }
    });

    if (onboardingState.showWebView && onboardingState.onboardingUrl != null) {
      return _buildWebView(onboardingState);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).setUpPayouts,
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
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.secondary.withValues(alpha: 0.1),
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
                        AppLocalizations.of(context).getPaidForYourRides,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: 12.h),

                      Text(
                        AppLocalizations.of(context).connectYourBankAccountTo,
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
                        title: AppLocalizations.of(context).instantPayouts,
                        description: AppLocalizations.of(
                          context,
                        ).benefitInstantPayoutsDesc,
                        delay: 400,
                      ),
                      _buildBenefitItem(
                        icon: Icons.security_rounded,
                        title: AppLocalizations.of(context).secureProtected,
                        description: AppLocalizations.of(
                          context,
                        ).benefitSecureDesc,
                        delay: 500,
                      ),
                      _buildBenefitItem(
                        icon: Icons.receipt_long_rounded,
                        title: AppLocalizations.of(context).clearTracking,
                        description: AppLocalizations.of(
                          context,
                        ).benefitTrackingDesc,
                        delay: 600,
                      ),
                      _buildBenefitItem(
                        icon: Icons.percent_rounded,
                        title: AppLocalizations.of(context).lowFees,
                        description: AppLocalizations.of(
                          context,
                        ).benefitLowFeesDesc,
                        delay: 700,
                      ),

                      if (onboardingState.errorMessage != null) ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: AppColors.error),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  onboardingState.errorMessage!,
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

                      if (onboardingState.isVerifying) ...[
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).stripeVerifyingAccount,
                                  style: TextStyle(
                                    color: AppColors.primary,
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
                text: AppLocalizations.of(context).connectStripeAccount,
                isLoading:
                    onboardingState.isLoading || onboardingState.isVerifying,
                onPressed:
                    onboardingState.isLoading || onboardingState.isVerifying
                    ? null
                    : _startOnboarding,
                style: PremiumButtonStyle.primary,
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

              SizedBox(height: 12.h),

              Text(
                AppLocalizations.of(context).poweredByStripe,
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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

  /// Start Stripe Connect onboarding process
  Future<void> _startOnboarding() async {
    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .startOnboarding(ref.read(currentUserProvider).value);
  }

  /// Build the WebView screen for Stripe onboarding
  Widget _buildWebView(DriverStripeOnboardingFlowState onboardingState) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).connectStripe,
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
            // Confirm before closing
            _showCancelConfirmation();
          },
        ),
        bottom: onboardingState.webViewProgress < 1.0
            ? PreferredSize(
                preferredSize: Size.fromHeight(3.h),
                child: LinearProgressIndicator(
                  value: onboardingState.webViewProgress,
                  backgroundColor: AppColors.border.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(onboardingState.onboardingUrl!),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useShouldOverrideUrlLoading: true,
              // Security settings
              allowFileAccessFromFileURLs: false,
              allowUniversalAccessFromFileURLs: false,
              // UX improvements
              supportZoom: false,
              builtInZoomControls: false,
              displayZoomControls: false,
            ),
            onWebViewCreated: (controller) {
              // Controller available for future use if needed
            },
            onProgressChanged: (controller, progress) {
              ref
                  .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                  .setWebViewProgress(progress / 100);
            },
            onLoadStart: (controller, url) {
              TalkerService.debug('Loading: $url');
            },
            onLoadStop: (controller, url) async {
              TalkerService.debug('Loaded: $url');

              final urlStr = url?.toString() ?? '';

              // Check for completion URLs
              if (urlStr.contains('stripe-refresh')) {
                // User clicked "Refresh" - reload the page
                await controller.reload();
              } else if (urlStr.contains('stripe-return') &&
                  !onboardingState.completionHandled) {
                // Fallback: page loaded before shouldOverrideUrlLoading fired
                ref
                    .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                    .markCompletionHandled();
                await _handleOnboardingComplete();
              }
            },
            onReceivedError: (controller, request, error) {
              TalkerService.error('Error loading: ${error.description}');
              ref
                  .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                  .failWebViewLoad(
                    AppLocalizations.of(context).stripePageLoadFailed,
                  );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';

              // 1. Stripe return URL — user finished the form and Stripe
              //    is redirecting back to our hosted page.
              //    Intercept here so we don't need the page to actually load.
              if (url.contains('stripe-return') &&
                  !onboardingState.completionHandled) {
                ref
                    .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                    .markCompletionHandled();
                await _handleOnboardingComplete();
                return NavigationActionPolicy.CANCEL;
              }

              // 2. Custom deep-link fired by stripe-return.html's JS redirect
              //    (fallback path if the page somehow loads before we intercept)
              if (url.startsWith('sportconnect://') &&
                  !onboardingState.completionHandled) {
                ref
                    .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                    .markCompletionHandled();
                await _handleOnboardingComplete();
                return NavigationActionPolicy.CANCEL;
              }

              // 3. Allow Stripe-owned and our own domains so the onboarding
              //    flow can navigate freely (identity checks, uploads, refresh)
              if (url.contains('stripe.com') ||
                  url.contains('connect.stripe.com') ||
                  url.contains('verify.stripe.com') ||
                  url.contains('uploads.stripe.com') ||
                  url.contains('hooks.stripe.com') ||
                  url.contains('sportaxitrip.com') ||
                  url.contains('stripe-refresh')) {
                return NavigationActionPolicy.ALLOW;
              }

              // 4. Block everything else (external links inside the WebView)
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // Loading overlay (only shown initially)
          if (onboardingState.webViewProgress < 1.0 &&
              onboardingState.webViewProgress == 0.0)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppLocalizations.of(context).stripeLoadingConnect,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Handle successful onboarding completion
  Future<void> _handleOnboardingComplete() async {
    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .handleOnboardingComplete(
          user: ref.read(currentUserProvider).value,
          successMessage: AppLocalizations.of(
            context,
          ).stripeAccountConnectedSuccessfully,
          additionalInfoMessage: AppLocalizations.of(
            context,
          ).stripeAdditionalInfoNeeded,
          verifyFailedMessage: AppLocalizations.of(context).stripeVerifyFailed,
        );
  }

  /// Show confirmation dialog before canceling onboarding
  Future<void> _showCancelConfirmation() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).cancelSetupTitle),
        content: Text(AppLocalizations.of(context).cancelSetupMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).continueSetup),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
        ],
      ),
    );

    if (shouldCancel == true && context.mounted) {
      ref
          .read(driverStripeOnboardingFlowViewModelProvider.notifier)
          .cancelOnboarding();
    }
  }
}
