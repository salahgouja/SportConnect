import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/legal/view_models/legal_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

enum LegalDocumentType { terms, privacy }

class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.type});

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(legalScreenUiViewModelProvider(type));
    final l10n = AppLocalizations.of(context);
    final title = type == LegalDocumentType.terms
        ? l10n.termsOfServiceTitle
        : l10n.privacyPolicyTitle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          leading: IconButton(
            tooltip: 'Back',
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () => context.pop(),
          ),
          centerTitle: true,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    l10n.legalVersionBadge,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _buildHtmlContent(title, type),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: false,
                disableContextMenu: true,
                supportZoom: true,
                useOnLoadResource: false,
                transparentBackground: false,
                disableHorizontalScroll: false,
              ),
              onLoadStop: (controller, url) {
                ref
                    .read(legalScreenUiViewModelProvider(type).notifier)
                    .setLoading(false);
              },
              onReceivedError: (controller, request, error) {
                ref
                    .read(legalScreenUiViewModelProvider(type).notifier)
                    .setLoading(false);
              },
            ),
            if (uiState.isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        type == LegalDocumentType.terms
                            ? l10n.loadingTermsOfService
                            : l10n.loadingPrivacyPolicy,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),
          ],
        ),
      ),
    );
  }

  String _buildHtmlContent(String title, LegalDocumentType type) {
    const lastUpdated = 'Last updated: February 23, 2026';
    final body = type == LegalDocumentType.terms ? _termsBody : _privacyBody;
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      font-size: 15px;
      line-height: 1.7;
      color: #1a1a1a;
      background: #ffffff;
      padding: 24px 20px 48px;
    }
    h1 { font-size: 22px; font-weight: 800; color: #2D6A4F; margin-bottom: 4px; }
    .subtitle { font-size: 12px; color: #888; margin-bottom: 28px; }
    h2 {
      font-size: 16px;
      font-weight: 700;
      color: #2D6A4F;
      margin-top: 28px;
      margin-bottom: 8px;
      padding-left: 12px;
      border-left: 3px solid #40916C;
    }
    p { margin-bottom: 12px; color: #333; }
    ul { padding-left: 20px; margin-bottom: 12px; }
    li { margin-bottom: 6px; color: #333; }
    a { color: #40916C; text-decoration: underline; }
    .highlight {
      background: #E8F5E9;
      border-radius: 10px;
      padding: 14px 16px;
      margin-bottom: 20px;
      font-size: 13px;
      color: #2D6A4F;
    }
  </style>
</head>
<body>
  <h1>$title</h1>
  <p class="subtitle">$lastUpdated · SportConnect</p>
  $body
</body>
</html>
''';
  }

  static const String _termsBody = '''
  <div class="highlight">
    Please read these Terms carefully before using SportConnect. By creating an account
    or using the app, you agree to be bound by these Terms.
  </div>

  <h2>1. Who We Are</h2>
  <p>SportConnect is a social carpooling platform that connects users for shared rides to sporting events, training sessions, and related activities.</p>

  <h2>2. Eligibility</h2>
  <p>You must meet applicable age and legal requirements to use the service. Drivers are responsible for holding a valid licence and complying with transport laws.</p>

  <h2>3. Your Account</h2>
  <ul>
    <li>You are responsible for your account credentials and activity.</li>
    <li>You must provide accurate registration information.</li>
    <li>You may not share your account or impersonate another person.</li>
  </ul>

  <h2>4. Rides and Payments</h2>
  <p>SportConnect facilitates ride coordination and cost sharing. Payments are processed through Stripe, and platform fees may apply.</p>

  <h2>5. Conduct</h2>
  <ul>
    <li>Do not harass, abuse, or endanger other users.</li>
    <li>Do not publish fraudulent or misleading information.</li>
    <li>Do not use the platform for unlawful or unauthorized commercial activity.</li>
  </ul>

  <h2>6. Termination</h2>
  <p>We may suspend or terminate accounts that violate these Terms or applicable law.</p>

  <h2>7. Contact</h2>
  <p>Questions? Contact <a href="mailto:legal@sportconnect.app">legal@sportconnect.app</a>.</p>
''';

  static const String _privacyBody = '''
  <div class="highlight">
    SportConnect is committed to protecting your privacy. This policy explains what data we collect,
    why we collect it, and how you can control it.
  </div>

  <h2>1. Data We Collect</h2>
  <p><strong>Account data:</strong> Name, email address, profile photo, and account role.</p>
  <p><strong>Vehicle data:</strong> Drivers may provide vehicle make, model, year, and registration details.</p>
  <p><strong>Location data:</strong> Approximate and precise location may be used to support trip and matching features.</p>
  <p><strong>Payment data:</strong> Payments are processed by Stripe. We store payment references and account identifiers, not full card numbers.</p>

  <h2>2. How We Use Your Data</h2>
  <ul>
    <li>To provide ride, booking, messaging, payment, and account features.</li>
    <li>To improve safety, detect fraud, and investigate abuse reports.</li>
    <li>To send important notifications about bookings, payments, and account activity.</li>
  </ul>

  <h2>3. Data Sharing</h2>
  <p>We do not sell personal data. We may share limited data with service providers such as Stripe, Firebase, and infrastructure vendors where necessary to operate SportConnect.</p>

  <h2>4. Data Retention</h2>
  <p>We retain account and trip records while your account is active and for limited periods afterward where required for legal, tax, fraud-prevention, or safety reasons.</p>

  <h2>5. Your Rights</h2>
  <p>Depending on your jurisdiction, you may have rights to access, correct, delete, or export your personal data and to withdraw consent for optional permissions.</p>

  <h2>6. Contact</h2>
  <p>For privacy questions or requests, contact <a href="mailto:privacy@sportconnect.app">privacy@sportconnect.app</a>.</p>
''';
}
