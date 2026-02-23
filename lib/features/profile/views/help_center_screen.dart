import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Help Center screen with FAQ sections and support access.
///
/// Features:
/// - Searchable FAQ categories
/// - Expandable Q&A sections
/// - Quick links to contact support and report issues
class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _faqCategories = [
    _FAQCategory(
      title: 'Getting Started',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF4CAF50),
      questions: [
        _FAQ(
          'How do I create an account?',
          'Download the app, tap "Sign Up", and follow the wizard. '
              'You can sign up with email, Google, or Apple ID.',
        ),
        _FAQ(
          'How do I switch between rider and driver?',
          'Go to Profile → Settings → Switch Role. If you haven\'t '
              'registered as a driver yet, you\'ll need to complete the '
              'driver onboarding process.',
        ),
        _FAQ(
          'Is SportConnect free to use?',
          'Creating an account is free. Riders pay per ride booked. '
              'Drivers earn money by offering rides minus a small service fee.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Rides & Booking',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF2196F3),
      questions: [
        _FAQ(
          'How do I book a ride?',
          'Search for rides from the Explore tab, select a ride that '
              'matches your route, review the details, and tap "Book Ride".',
        ),
        _FAQ(
          'Can I cancel a booked ride?',
          'Yes, go to Activity → select the ride → Cancel. Please note '
              'that frequent cancellations may affect your rating.',
        ),
        _FAQ(
          'How does ride matching work?',
          'Our algorithm matches riders with drivers based on route '
              'overlap, departure time, and user preferences. You can also '
              'request a ride and let drivers find you.',
        ),
        _FAQ(
          'What if my ride is late?',
          'You\'ll receive real-time updates on your ride status. If the '
              'driver is significantly late, you can contact them directly '
              'through the in-app chat.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Payments',
      icon: Icons.payment_rounded,
      color: Color(0xFFFF9800),
      questions: [
        _FAQ(
          'How do payments work?',
          'Payments are processed securely through Stripe. Riders pay '
              'when booking, and drivers receive earnings after ride completion.',
        ),
        _FAQ(
          'When do drivers get paid?',
          'Drivers receive payouts weekly to their linked Stripe account. '
              'You can track your earnings in the Earnings tab.',
        ),
        _FAQ(
          'What are the service fees?',
          'SportConnect charges a small service fee (typically 10%) to '
              'cover platform costs, payment processing, and insurance.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Safety & Trust',
      icon: Icons.shield_rounded,
      color: Color(0xFFF44336),
      questions: [
        _FAQ(
          'How is my safety ensured?',
          'All drivers undergo verification. Rides include live GPS '
              'tracking, in-app chat, emergency SOS button, and all trips '
              'are logged for safety.',
        ),
        _FAQ(
          'How do I report a safety issue?',
          'Tap the SOS button during a ride, or go to Settings → '
              'Report a Problem. Safety reports are prioritized and '
              'reviewed within 24 hours.',
        ),
        _FAQ(
          'Can I share my ride with someone?',
          'Yes, during an active ride you can share your live trip '
              'details with trusted contacts.',
        ),
      ],
    ),
    _FAQCategory(
      title: 'Account & Profile',
      icon: Icons.person_rounded,
      color: Color(0xFF9C27B0),
      questions: [
        _FAQ(
          'How do I verify my account?',
          'Go to Settings → Verify Account. You can verify your email, '
              'phone number, and provide government ID for full verification.',
        ),
        _FAQ(
          'How do I delete my account?',
          'Go to Settings → Account Actions → Delete Account. This action '
              'is permanent and cannot be undone.',
        ),
        _FAQ(
          'Can I change my email address?',
          'Currently, you can update your display name and profile info. '
              'For email changes, please contact support.',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FAQCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _faqCategories;
    return _faqCategories
        .map((cat) {
          final filteredQuestions = cat.questions
              .where(
                (q) =>
                    q.question.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    q.answer.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
          if (filteredQuestions.isEmpty) return null;
          return _FAQCategory(
            title: cat.title,
            icon: cat.icon,
            color: cat.color,
            questions: filteredQuestions,
          );
        })
        .whereType<_FAQCategory>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.settingsHelpCenter,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),

            // Search bar
            _buildSearchBar().animate().fadeIn(duration: 300.ms),

            SizedBox(height: 20.h),

            // Quick actions
            _buildQuickActions(
              context,
              l10n,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

            SizedBox(height: 28.h),

            // FAQ sections
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 16.h),

            ..._filteredCategories.asMap().entries.map((entry) {
              return _buildFAQSection(entry.value)
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 250 + (entry.key * 100)),
                  )
                  .slideY(begin: 0.03);
            }),

            if (_filteredCategories.isEmpty)
              _buildEmptySearch().animate().fadeIn(duration: 300.ms),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search help articles...',
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildQuickActionCard(
          icon: Icons.support_agent_rounded,
          label: l10n.contactSupport,
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.contactSupport.path),
        ),
        SizedBox(width: 12.w),
        _buildQuickActionCard(
          icon: Icons.bug_report_rounded,
          label: l10n.settingsReportProblem,
          color: AppColors.warning,
          onTap: () => context.push(AppRoutes.reportIssue.path),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 10.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(_FAQCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(category.icon, color: category.color, size: 22.sp),
          ),
          title: Text(
            category.title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${category.questions.length} articles',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
          children: category.questions.map((faq) {
            return _buildFAQItem(faq);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFAQItem(_FAQ faq) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Text(
              faq.answer,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Try different keywords or contact support',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_FAQ> questions;

  const _FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ(this.question, this.answer);
}
