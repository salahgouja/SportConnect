import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// In-app Terms of Service / Privacy Policy display screen.
///
/// Renders the legal documents inside the app using a scrollable
/// rich-text view, avoiding the need to open an external browser.
class TermsPrivacyScreen extends ConsumerWidget {
  /// Either 'terms' or 'privacy'
  final String type;

  const TermsPrivacyScreen({super.key, required this.type});

  bool get _isTerms => type == 'terms';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isTerms ? l10n.settingsTermsConditions : l10n.settingsPrivacyPolicy,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    _isTerms
                        ? Icons.description_outlined
                        : Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isTerms
                              ? l10n.settingsTermsConditions
                              : l10n.settingsPrivacyPolicy,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Last updated: February 1, 2026',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: 24.h),

            // Content sections
            ..._isTerms
                ? _buildTermsSections().asMap().entries.map(
                    (e) => e.value
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 350 + (e.key * 60)),
                        )
                        .slideY(begin: 0.03),
                  )
                : _buildPrivacySections().asMap().entries.map(
                    (e) => e.value
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 350 + (e.key * 60)),
                        )
                        .slideY(begin: 0.03),
                  ),

            SizedBox(height: 32.h),

            // Contact section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'If you have any questions about these '
                    '${_isTerms ? 'terms' : 'policies'}, '
                    'please contact us at legal@sportconnect.app',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTermsSections() {
    return [
      _section(
        '1. Acceptance of Terms',
        'By accessing or using SportConnect, you agree to be bound by these '
            'Terms of Service. If you disagree with any part, you may not access '
            'the service.',
      ),
      _section(
        '2. Description of Service',
        'SportConnect is a carpooling and rideshare platform that connects '
            'drivers offering rides with riders seeking transportation, '
            'particularly focused on sports events and activities.',
      ),
      _section(
        '3. User Accounts',
        'You must create an account to use our services. You are responsible '
            'for maintaining the confidentiality of your credentials and for all '
            'activities under your account. You must provide accurate information '
            'and keep it updated.',
      ),
      _section(
        '4. User Conduct',
        'Users must not: use the service for illegal purposes; harass, abuse, '
            'or harm other users; provide false or misleading information; '
            'interfere with or disrupt the service; or violate any applicable laws.',
      ),
      _section(
        '5. Rides & Bookings',
        'Drivers set their own prices and routes. Riders book based on '
            'available rides. Both parties agree to honor their commitments. '
            'Cancellations may incur fees and affect your rating.',
      ),
      _section(
        '6. Payments',
        'Payments are processed through our third-party payment processor '
            '(Stripe). SportConnect charges a service fee on each transaction. '
            'All prices are in the currency specified at booking time.',
      ),
      _section(
        '7. Liability',
        'SportConnect is a platform that connects riders and drivers. We are '
            'not a transportation provider. Users assume all risks associated '
            'with rides. We are not liable for the actions of any user.',
      ),
      _section(
        '8. Termination',
        'We reserve the right to suspend or terminate accounts that violate '
            'these terms, at our sole discretion, without prior notice.',
      ),
    ];
  }

  List<Widget> _buildPrivacySections() {
    return [
      _section(
        '1. Information We Collect',
        'We collect information you provide (name, email, phone, profile photo), '
            'usage data (ride history, app interactions), and location data '
            '(for ride matching and navigation). We may also collect device '
            'information and crash reports.',
      ),
      _section(
        '2. How We Use Your Information',
        'We use your information to: provide and improve our services; '
            'match riders with drivers; process payments; send notifications; '
            'ensure safety and prevent fraud; and comply with legal obligations.',
      ),
      _section(
        '3. Location Data',
        'We collect location data when you use the app to provide ride '
            'matching, live navigation, and safety features. You can disable '
            'location access in your device settings, but some features may '
            'not work properly.',
      ),
      _section(
        '4. Data Sharing',
        'We share your information with: other users (limited profile info '
            'for ride coordination); payment processors (Stripe); cloud service '
            'providers (Firebase/Google Cloud); and law enforcement when required.',
      ),
      _section(
        '5. Data Security',
        'We implement industry-standard security measures including '
            'encryption in transit (TLS) and at rest, secure authentication, '
            'and regular security audits to protect your data.',
      ),
      _section(
        '6. Data Retention',
        'We retain your data as long as your account is active. After '
            'account deletion, we retain minimal data for up to 90 days for '
            'legal compliance, after which it is permanently deleted.',
      ),
      _section(
        '7. Your Rights',
        'You have the right to: access your personal data; correct '
            'inaccurate data; delete your account and data; export your data; '
            'and opt out of marketing communications.',
      ),
      _section(
        '8. Contact Us',
        'For privacy inquiries, contact our Data Protection Officer at '
            'privacy@sportconnect.app or through the in-app support.',
      ),
    ];
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
