import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Enum defining which legal document to display.
enum LegalDocumentType { terms, privacy }

/// Full-page in-app viewer for Terms of Service and Privacy Policy.
///
/// Compliant with Apple App Store Review Guidelines (§5.1.1) and
/// Google Play Developer Policy Centre (User Data) requirements:
///   - Legal documents are readable in-app, no external browser required.
///   - Accessible before account creation (no auth guard on this route).
///   - Displayed in a human-readable format with a clear title.
class LegalScreen extends StatefulWidget {
  final LegalDocumentType type;

  const LegalScreen({super.key, required this.type});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool _isLoading = true;
  InAppWebViewController? _webViewController;

  // ─── Document metadata ───────────────────────────────────────────────────
  String get _title => widget.type == LegalDocumentType.terms
      ? 'Terms of Service'
      : 'Privacy Policy';

  String get _lastUpdated => 'Last updated: February 23, 2026';

  // ─── HTML content ────────────────────────────────────────────────────────

  String get _htmlContent {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$_title</title>
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
    .divider { border: none; border-top: 1px solid #E8F5E9; margin: 20px 0; }
  </style>
</head>
<body>
  <h1>$_title</h1>
  <p class="subtitle">$_lastUpdated · SportConnect</p>
  ${widget.type == LegalDocumentType.terms ? _termsBody : _privacyBody}
</body>
</html>
''';
  }

  // ─── Terms of Service HTML ───────────────────────────────────────────────

  static const String _termsBody = '''
  <div class="highlight">
    Please read these Terms carefully before using SportConnect. By creating an account
    or using the app, you agree to be bound by these Terms.
  </div>

  <h2>1. Who We Are</h2>
  <p>SportConnect ("we", "us", or "our") is a social carpooling platform that connects students
  and sports enthusiasts for shared rides to sporting events, training sessions, and other
  sports-related activities.</p>

  <h2>2. Eligibility</h2>
  <p>You must be at least 18 years old to use SportConnect as a Driver. Riders must be at least
  16 years old and, if under 18, must have parental or guardian consent. By using the app you
  confirm you meet these requirements.</p>

  <h2>3. Your Account</h2>
  <ul>
    <li>You are responsible for maintaining the confidentiality of your credentials.</li>
    <li>You must provide accurate, current, and complete registration information.</li>
    <li>You may not share your account or use another person's account.</li>
    <li>Notify us immediately at <a href="mailto:support@sportconnect.app">support@sportconnect.app</a> if you suspect unauthorised access.</li>
  </ul>

  <h2>4. Rides and Payments</h2>
  <p>SportConnect facilitates cost-sharing between Drivers and Riders. We are not a transportation
  or taxi service. Key points:</p>
  <ul>
    <li>Drivers set a cost-sharing price per seat for each ride.</li>
    <li>Payments are processed securely by Stripe. SportConnect retains a 15% platform fee.</li>
    <li>Refunds are subject to the cancellation policy displayed at time of booking.</li>
    <li>Drivers must hold a valid driving licence and comply with all applicable laws.</li>
  </ul>

  <h2>5. Conduct</h2>
  <p>You agree not to:</p>
  <ul>
    <li>Harass, abuse, or harm other users.</li>
    <li>Post false, misleading, or fraudulent information.</li>
    <li>Use the platform for any commercial or for-profit transportation purpose.</li>
    <li>Violate any applicable local, national, or international law or regulation.</li>
    <li>Attempt to gain unauthorised access to our systems.</li>
  </ul>

  <h2>6. Ratings and Reviews</h2>
  <p>Both Drivers and Riders can leave ratings and reviews after a completed ride. Reviews must
  be honest, respectful, and based on genuine experience. We reserve the right to remove content
  that violates our community guidelines.</p>

  <h2>7. Intellectual Property</h2>
  <p>SportConnect and its logos, designs, and content are protected by copyright and other
  intellectual property laws. You may not reproduce or distribute them without our written consent.</p>

  <h2>8. Disclaimer of Warranties</h2>
  <p>The app is provided "as is" without warranties of any kind. We do not guarantee uninterrupted
  or error-free operation of the service and are not responsible for the conduct of any user.</p>

  <h2>9. Limitation of Liability</h2>
  <p>To the fullest extent permitted by law, SportConnect shall not be liable for any indirect,
  incidental, or consequential damages arising from your use of the app, including personal
  injury, property damage, or disputes between users.</p>

  <h2>10. Termination</h2>
  <p>We may suspend or terminate your account at any time for violation of these Terms. You may
  delete your account at any time from Profile &gt; Settings &gt; Delete Account.</p>

  <h2>11. Changes to These Terms</h2>
  <p>We may update these Terms from time to time. We will notify you of significant changes via
  in-app notification or email. Continued use of the app constitutes acceptance of the revised Terms.</p>

  <h2>12. Governing Law</h2>
  <p>These Terms are governed by the laws of France. Any disputes shall be subject to the exclusive
  jurisdiction of the courts of Paris, France.</p>

  <h2>13. Contact</h2>
  <p>Questions? Contact us at <a href="mailto:legal@sportconnect.app">legal@sportconnect.app</a>.</p>
''';

  // ─── Privacy Policy HTML ─────────────────────────────────────────────────

  static const String _privacyBody = '''
  <div class="highlight">
    SportConnect is committed to protecting your privacy. This policy explains what data we
    collect, why we collect it, and how you can control it.
  </div>

  <h2>1. Data We Collect</h2>
  <p><strong>Account data:</strong> Name, email address, profile photo, and role (Rider or Driver).</p>
  <p><strong>Vehicle data (Drivers):</strong> Make, model, year, licence plate, and vehicle photos.</p>
  <p><strong>Location data:</strong> Approximate and precise location to show nearby rides and match
  Drivers with Riders. Location is only collected while the app is in use.</p>
  <p><strong>Payment data:</strong> Payment is handled by Stripe. We do not store full card numbers.
  We store Stripe customer and account IDs and payment transaction records.</p>
  <p><strong>Communications:</strong> Messages sent through the in-app chat are stored to deliver
  them and for safety moderation purposes.</p>
  <p><strong>Usage data:</strong> App interactions, crash reports, and performance data collected
  via Firebase Analytics to improve the service.</p>

  <h2>2. How We Use Your Data</h2>
  <ul>
    <li>To provide, maintain, and improve the SportConnect service.</li>
    <li>To match Drivers and Riders and process payments.</li>
    <li>To send push notifications about ride updates, messages, and account activity.</li>
    <li>To detect and prevent fraud, abuse, and security incidents.</li>
    <li>To comply with our legal obligations.</li>
  </ul>

  <h2>3. Legal Basis (GDPR)</h2>
  <p>We process your data on the following legal bases:</p>
  <ul>
    <li><strong>Contract performance</strong> – processing necessary to provide the service.</li>
    <li><strong>Legitimate interests</strong> – security, fraud prevention, product improvement.</li>
    <li><strong>Consent</strong> – for location access and push notifications (you can withdraw at any time).</li>
  </ul>

  <h2>4. Data Sharing</h2>
  <p>We do not sell your personal data. We share data only:</p>
  <ul>
    <li><strong>With other users</strong> – your name, photo, and rating are visible to matched Riders/Drivers.</li>
    <li><strong>With Stripe</strong> – to process payments securely.</li>
    <li><strong>With Firebase (Google)</strong> – for authentication, database, storage, and notifications.</li>
    <li><strong>When required by law</strong> – in response to valid legal process.</li>
  </ul>

  <h2>5. Data Retention</h2>
  <p>We retain your account data while your account is active. After deletion we retain anonymised
  transaction records for up to 5 years as required by financial regulations. Chat messages are
  deleted within 90 days of ride completion.</p>

  <h2>6. Your Rights</h2>
  <p>Under GDPR and applicable privacy laws you have the right to:</p>
  <ul>
    <li><strong>Access</strong> – request a copy of your data via Profile &gt; Settings &gt; Export Data.</li>
    <li><strong>Correction</strong> – update your profile at any time.</li>
    <li><strong>Deletion</strong> – delete your account via Profile &gt; Settings &gt; Delete Account.</li>
    <li><strong>Portability</strong> – request your data in a machine-readable format.</li>
    <li><strong>Objection / Restriction</strong> – contact us at <a href="mailto:privacy@sportconnect.app">privacy@sportconnect.app</a>.</li>
  </ul>

  <h2>7. Security</h2>
  <p>We use industry-standard security measures including TLS encryption in transit, Firebase
  Security Rules for data access control, and restricted access to production systems. No system
  is 100% secure; please keep your account credentials confidential.</p>

  <h2>8. Children's Privacy</h2>
  <p>SportConnect is not directed at children under 13. We do not knowingly collect personal data
  from children under 13. If you believe a child has provided us data, contact us immediately.</p>

  <h2>9. International Transfers</h2>
  <p>Your data may be processed in the United States or other countries by our service providers
  (Google, Stripe). These transfers are protected by Standard Contractual Clauses or other
  approved mechanisms under GDPR.</p>

  <h2>10. Changes to This Policy</h2>
  <p>We will notify you of material changes via in-app notification or email. The "Last updated"
  date at the top of this page reflects the latest revision.</p>

  <h2>11. Contact</h2>
  <p>For privacy-related requests, contact our Data Protection Officer at
  <a href="mailto:privacy@sportconnect.app">privacy@sportconnect.app</a>.</p>
''';

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              isIOS
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 22.sp,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          actions: [
            // Last updated badge
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
                    'Feb 2026',
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
              initialData: InAppWebViewInitialData(data: _htmlContent),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: false,
                disableContextMenu: true,
                supportZoom: true,
                useOnLoadResource: false,
                transparentBackground: false,
                disableHorizontalScroll: false,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStop: (controller, url) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
              onReceivedError: (controller, request, error) {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
            ),
            if (_isLoading)
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
                        'Loading $_title...',
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
}
