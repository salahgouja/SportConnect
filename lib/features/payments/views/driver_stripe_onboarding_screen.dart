import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/payment_error_handler.dart';
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
  bool _didNavigateAway = false;
  InAppWebViewController? _webViewController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(driverStripeOnboardingFlowViewModelProvider.notifier)
          .checkExistingAccount(ref.read(currentUserProvider).value);
    });
  }

  void _safeGoNamed(
    String routeName, {
    Map<String, String> queryParameters = const {},
  }) {
    if (_didNavigateAway || !mounted) return;

    _didNavigateAway = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.goNamed(
        routeName,
        queryParameters: queryParameters,
        extra: {'resetBranch': true},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(
      driverStripeOnboardingFlowViewModelProvider,
    );
    final mode = GoRouterState.of(context).uri.queryParameters['mode'];
    final returnTo = GoRouterState.of(context).uri.queryParameters['returnTo'];

    final isManageMode = mode == 'manage';

    ref.listen(currentUserProvider, (previous, next) {
      final previousUser = previous?.value;
      final user = next.value;
      if (user != null && previousUser?.uid != user.uid) {
        ref
            .read(driverStripeOnboardingFlowViewModelProvider.notifier)
            .checkExistingAccount(user);
      }
    });

    ref.listen(driverStripeOnboardingFlowViewModelProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: next.successMessage!,
          type: AdaptiveSnackBarType.success,
        );
      }

      if (next.isConnected &&
          previous?.isConnected != true &&
          context.mounted) {
        if (isManageMode) return;

        _safeGoNamed(returnTo ?? AppRoutes.driverHome.name);
      }
    });

    if (onboardingState.showWebView && onboardingState.onboardingUrl != null) {
      return _buildWebView(onboardingState);
    }

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: AppLocalizations.of(context).setUpPayouts,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Step progress indicator
              _buildStepProgress(context),
              SizedBox(height: 16.h),

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
                    ],
                  ),
                ),
              ),

              // Error / verifying banners — always visible above the CTA
              if (onboardingState.errorMessage != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          PaymentErrorHandler.humanize(
                            onboardingState.errorMessage!,
                          ),
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
              ],

              if (onboardingState.isVerifying) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).stripeVerifyingAccount,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // CTA Button
              SizedBox(height: 16.h),
              PremiumButton(
                text: AppLocalizations.of(context).connectStripeAccount,
                isLoading:
                    onboardingState.isLoading || onboardingState.isVerifying,
                onPressed:
                    onboardingState.isLoading || onboardingState.isVerifying
                    ? null
                    : _startOnboarding,
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

  Widget _buildStepProgress(BuildContext context) {
    const steps = ['Connect', 'Verify', 'Get Paid'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2.h,
              color: i == 1 ? AppColors.border : AppColors.border,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex == 0;
        final isDone = stepIndex < 0;
        return Column(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isDone
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.5),
              ),
              child: Center(
                child: isDone
                    ? Icon(
                        Icons.check_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      )
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Start Stripe Connect onboarding process
  Future<void> _startOnboarding() async {
    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .startOnboarding(ref.read(currentUserProvider).value);
  }

  /// Build the WebView screen for Stripe onboarding
  Widget _buildWebView(DriverStripeOnboardingFlowState onboardingState) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: AppLocalizations.of(context).connectStripe,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showCancelConfirmation,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(onboardingState.onboardingUrl!),
            ),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              // UX improvements
              supportZoom: false,
              builtInZoomControls: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onProgressChanged: (controller, progress) {
              ref
                  .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                  .setWebViewProgress(progress / 100);
            },
            onLoadStart: (controller, url) {},
            onLoadStop: (controller, url) async {
              final urlStr = url?.toString() ?? '';

              // Check for completion URLs
              if (urlStr.contains('stripe-refresh')) {
                // Onboarding link expired — fetch a fresh one and reload
                await ref
                    .read(driverStripeOnboardingFlowViewModelProvider.notifier)
                    .resumeOnboarding();
                final newUrl = ref
                    .read(driverStripeOnboardingFlowViewModelProvider)
                    .onboardingUrl;
                if (newUrl != null && newUrl.isNotEmpty) {
                  await controller.loadUrl(
                    urlRequest: URLRequest(url: WebUri(newUrl)),
                  );
                }
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
            ColoredBox(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator.adaptive(
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
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final uri = GoRouterState.of(context).uri;
    final returnTo = uri.queryParameters['returnTo'];

    await ref
        .read(driverStripeOnboardingFlowViewModelProvider.notifier)
        .handleOnboardingComplete(
          user: ref.read(currentUserProvider).value,
          successMessage: l10n.stripeAccountConnectedSuccessfully,
          additionalInfoMessage: l10n.stripeAdditionalInfoNeeded,
          verifyFailedMessage: l10n.stripeVerifyFailed,
        );

    if (!mounted) return;

    final state = ref.read(driverStripeOnboardingFlowViewModelProvider);

    if (state.isConnected) {
      _safeGoNamed(returnTo ?? AppRoutes.driverHome.name);
    }
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
