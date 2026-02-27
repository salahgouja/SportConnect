import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  String? _onboardingUrl;
  bool _showWebView = false;
  bool _isVerifying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkExistingAccount();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView && _onboardingUrl != null) {
      return _buildWebView();
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

                      if (_errorMessage != null) ...[
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

                      if (_isVerifying) ...[
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
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
                isLoading: _isLoading || _isVerifying,
                onPressed: _isLoading || _isVerifying ? null : _startOnboarding,
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

  /// Check if user already has a Stripe account connected
  Future<void> _checkExistingAccount() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      final status = await ref.read(driverStripeStatusProvider.future);
      if (status.isConnected) {
        // Already connected - return to previous screen
        if (mounted) {
          context.pop(true);
        }
      }
    } catch (e) {
      // Silent fail - user can proceed with onboarding
      TalkerService.error('Error checking existing account: $e');
    }
  }

  /// Start Stripe Connect onboarding process
  Future<void> _startOnboarding() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).pleaseSignInToContinue;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Detect user's country
      final country = await _detectUserCountry();

      // Split display name into first and last name for Stripe prefilling
      final nameParts = user.displayName.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : null;

      final result = await ref
          .read(driverOnboardingViewModelProvider.notifier)
          .createConnectedAccount(
            userId: user.uid,
            email: user.email,
            country: country,
            firstName: firstName,
            lastName: lastName,
            phone: user.phoneNumber,
            dateOfBirth: user.dateOfBirth,
            addressLine1: user.address,
            city: user.city,
          );

      if (result != null &&
          result.onboardingUrl != null &&
          result.stripeAccountId.isNotEmpty) {
        setState(() {
          _onboardingUrl = result.onboardingUrl;
          _showWebView = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(
            context,
          ).stripeAccountCreationFailed;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).stripeSetupFailed;
        _isLoading = false;
      });
    }
  }

  /// Build the WebView screen for Stripe onboarding
  Widget _buildWebView() {
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
        bottom: _progress < 1.0
            ? PreferredSize(
                preferredSize: Size.fromHeight(3.h),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.border.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_onboardingUrl!)),
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
              setState(() {
                _progress = progress / 100;
              });
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
              } else if (urlStr.contains('stripe-return')) {
                // User completed onboarding - verify and close
                await _handleOnboardingComplete();
              }
            },
            onReceivedError: (controller, request, error) {
              TalkerService.error('Error loading: ${error.description}');
              setState(() {
                _errorMessage = AppLocalizations.of(
                  context,
                ).stripePageLoadFailed;
                _showWebView = false;
                _onboardingUrl = null;
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';

              // Allow Stripe and related verification/onboarding domains
              if (url.contains('stripe.com') ||
                  url.contains('stripe-refresh') ||
                  url.contains('stripe-return') ||
                  url.contains('connect.stripe.com') ||
                  url.contains('verify.stripe.com') ||
                  url.contains('uploads.stripe.com') ||
                  url.contains('hooks.stripe.com') ||
                  url.contains('marathon-connect.web.app')) {
                return NavigationActionPolicy.ALLOW;
              }

              // Block external navigation
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // Loading overlay (only shown initially)
          if (_progress < 1.0 && _progress == 0.0)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
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
    setState(() {
      _isVerifying = true;
    });

    try {
      // Wait for Stripe webhook to process
      await Future.delayed(const Duration(seconds: 2));

      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      ref.invalidate(driverStripeStatusProvider);
      final status = await ref.read(driverStripeStatusProvider.future);

      if (status.isConnected) {
        // Success!
        if (mounted) {
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).stripeAccountConnectedSuccessfully,
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } else if (!status.isConnected) {
        // Incomplete - show message but don't close
        setState(() {
          _isVerifying = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).stripeAdditionalInfoNeeded,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Not connected yet - keep trying
        setState(() {
          _isVerifying = false;
        });
      }
    } catch (_) {
      setState(() {
        _isVerifying = false;
        _errorMessage = AppLocalizations.of(context).stripeVerifyFailed;
        _showWebView = false;
      });
    }
  }

  /// Show confirmation dialog before canceling onboarding
  Future<void> _showCancelConfirmation() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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

    if (shouldCancel == true && mounted) {
      setState(() {
        _showWebView = false;
        _onboardingUrl = null;
      });
    }
  }

  /// Detect user's country from profile or phone number
  Future<String> _detectUserCountry() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return 'FR';

    // Use explicit country from profile if available
    if (user.country != null && user.country!.isNotEmpty) {
      return user.country!.toUpperCase();
    }

    // Fall back to phone number country code detection
    if (user.phoneNumber != null) {
      final phone = user.phoneNumber!;
      const phoneCountryMap = {
        '+216': 'TN', // Tunisia
        '+33': 'FR', // France
        '+49': 'DE', // Germany
        '+34': 'ES', // Spain
        '+39': 'IT', // Italy
        '+44': 'GB', // United Kingdom
        '+1': 'US', // United States
        '+32': 'BE', // Belgium
        '+41': 'CH', // Switzerland
        '+352': 'LU', // Luxembourg
        '+31': 'NL', // Netherlands
        '+351': 'PT', // Portugal
        '+43': 'AT', // Austria
        '+212': 'MA', // Morocco
        '+213': 'DZ', // Algeria
      };

      for (final entry in phoneCountryMap.entries) {
        if (phone.startsWith(entry.key)) {
          return entry.value;
        }
      }
    }

    // Default to France
    return 'FR';
  }
}
