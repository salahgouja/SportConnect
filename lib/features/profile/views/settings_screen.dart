import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_router.dart';

/// Premium Settings Screen with enterprise-grade UI
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _rideReminders = true;
  bool _chatNotifications = true;
  bool _marketingEmails = false;
  bool _darkMode = false;
  bool _autoAcceptRides = false;
  bool _showLocation = true;
  bool _publicProfile = true;
  String _distanceUnit = 'km';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 18.sp,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Settings Content
          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Notifications Section
                _buildSectionHeader(
                  'Notifications',
                  Icons.notifications_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Push Notifications',
                    subtitle:
                        'Receive push notifications for important updates',
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                    icon: Icons.notifications_active_outlined,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Ride Reminders',
                    subtitle: 'Get reminded about upcoming rides',
                    value: _rideReminders,
                    onChanged: (value) =>
                        setState(() => _rideReminders = value),
                    icon: Icons.alarm_outlined,
                    enabled: _notificationsEnabled,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Chat Messages',
                    subtitle: 'Notifications for new messages',
                    value: _chatNotifications,
                    onChanged: (value) =>
                        setState(() => _chatNotifications = value),
                    icon: Icons.chat_bubble_outline_rounded,
                    enabled: _notificationsEnabled,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Marketing & Tips',
                    subtitle: 'Receive tips and promotional offers',
                    value: _marketingEmails,
                    onChanged: (value) =>
                        setState(() => _marketingEmails = value),
                    icon: Icons.campaign_outlined,
                  ),
                ]),

                SizedBox(height: 24.h),

                // Appearance Section
                _buildSectionHeader('Appearance', Icons.palette_outlined),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: _darkMode,
                    onChanged: (value) => setState(() => _darkMode = value),
                    icon: Icons.dark_mode_outlined,
                  ),
                  _buildDivider(),
                  _buildDropdownTile(
                    title: 'Language',
                    subtitle: 'App display language',
                    value: _language,
                    options: [
                      'English',
                      'Spanish',
                      'French',
                      'German',
                      'Arabic',
                    ],
                    onChanged: (value) =>
                        setState(() => _language = value ?? 'English'),
                    icon: Icons.language_outlined,
                  ),
                  _buildDivider(),
                  _buildDropdownTile(
                    title: 'Distance Unit',
                    subtitle: 'Preferred distance measurement',
                    value: _distanceUnit,
                    options: ['km', 'miles'],
                    onChanged: (value) =>
                        setState(() => _distanceUnit = value ?? 'km'),
                    icon: Icons.straighten_outlined,
                  ),
                ]),

                SizedBox(height: 24.h),

                // Privacy Section
                _buildSectionHeader('Privacy & Safety', Icons.shield_outlined),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: 'Public Profile',
                    subtitle: 'Allow others to see your profile',
                    value: _publicProfile,
                    onChanged: (value) =>
                        setState(() => _publicProfile = value),
                    icon: Icons.person_outline_rounded,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Show Location',
                    subtitle: 'Share your live location during rides',
                    value: _showLocation,
                    onChanged: (value) => setState(() => _showLocation = value),
                    icon: Icons.location_on_outlined,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Auto-Accept Rides',
                    subtitle: 'Automatically accept ride requests',
                    value: _autoAcceptRides,
                    onChanged: (value) =>
                        setState(() => _autoAcceptRides = value),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Blocked Users',
                    subtitle: 'Manage blocked users',
                    icon: Icons.block_outlined,
                    onTap: () => _showBlockedUsersDialog(),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Account Section
                _buildSectionHeader('Account', Icons.account_circle_outlined),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    icon: Icons.edit_outlined,
                    onTap: () => context.push(AppRouter.editProfile),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Vehicles',
                    subtitle: 'Manage your vehicles',
                    icon: Icons.directions_car_outlined,
                    onTap: () => context.push(AppRouter.vehicles),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    icon: Icons.payment_outlined,
                    onTap: () => _showPaymentMethodsDialog(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    icon: Icons.lock_outline_rounded,
                    onTap: () => _showChangePasswordDialog(),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Support Section
                _buildSectionHeader('Support', Icons.help_outline_rounded),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: 'Help Center',
                    subtitle: 'FAQs and support articles',
                    icon: Icons.help_center_outlined,
                    onTap: () => _showHelpCenter(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Contact Support',
                    subtitle: 'Get help from our team',
                    icon: Icons.support_agent_outlined,
                    onTap: () => _showContactSupport(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Report a Problem',
                    subtitle: 'Let us know about issues',
                    icon: Icons.bug_report_outlined,
                    onTap: () => _showReportProblem(),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Legal Section
                _buildSectionHeader('Legal', Icons.gavel_outlined),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Licenses',
                    subtitle: 'Open source licenses',
                    icon: Icons.article_outlined,
                    onTap: () => showLicensePage(context: context),
                  ),
                ]),

                SizedBox(height: 32.h),

                // App Version
                Center(
                  child: Text(
                    'SportConnect v1.0.0',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Logout Button
                PremiumButton(
                  text: 'Log Out',
                  onPressed: () => _showLogoutDialog(),
                  style: PremiumButtonStyle.outline,
                  icon: Icons.logout_rounded,
                ),

                SizedBox(height: 16.h),

                // Delete Account
                TextButton(
                  onPressed: () => _showDeleteAccountDialog(),
                  child: Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: (value ? AppColors.primary : AppColors.textSecondary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: value ? AppColors.primary : AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value && enabled,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                items: options.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsersDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.block_outlined,
              size: 48.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Blocked Users',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Users you block will appear here',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(Icons.payment_outlined, size: 48.sp, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Payment integration will be available soon',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Help Center',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children: [
                  _buildHelpSection(
                    'Getting Started',
                    Icons.rocket_launch_rounded,
                    [
                      'How to create an account',
                      'Setting up your profile',
                      'Finding your first ride',
                      'Understanding the map',
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildHelpSection(
                    'Rides & Carpooling',
                    Icons.directions_car_rounded,
                    [
                      'How to create a ride',
                      'Joining an existing ride',
                      'Cancelling a ride',
                      'Payment and pricing',
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildHelpSection(
                    'Safety & Trust',
                    Icons.verified_user_rounded,
                    [
                      'Verifying your identity',
                      'Rating other users',
                      'Reporting issues',
                      'Emergency contacts',
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildHelpSection(
                    'Account & Settings',
                    Icons.settings_rounded,
                    [
                      'Changing your password',
                      'Managing notifications',
                      'Privacy settings',
                      'Deleting your account',
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, IconData icon, List<String> items) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening: $item'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: AppColors.textSecondary,
                      size: 16.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We\'re here to help! Choose how you\'d like to reach us.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            _buildContactOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@sportconnect.app',
              onTap: () async {
                context.pop();
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@sportconnect.app',
                  queryParameters: {'subject': 'SportConnect Support Request'},
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Could not open email app'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildContactOption(
              icon: Icons.chat_outlined,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Live chat will be available soon!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            _buildContactOption(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-4567',
              onTap: () async {
                context.pop();
                final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.divider),
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportProblem() {
    final TextEditingController problemController = TextEditingController();
    String selectedCategory = 'Bug Report';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.bug_report_rounded,
                        color: AppColors.warning,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Report a Problem',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items:
                        [
                              'Bug Report',
                              'App Crash',
                              'Payment Issue',
                              'Account Problem',
                              'Safety Concern',
                              'Other',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedCategory = value);
                      }
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Describe the problem',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: problemController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Please describe what happened...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Thank you! Your report has been submitted.',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to log out of SportConnect?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action cannot be undone. All your data, including:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDeleteWarningItem('Ride history and bookings'),
              _buildDeleteWarningItem('Profile and achievements'),
              _buildDeleteWarningItem('Messages and connections'),
              _buildDeleteWarningItem('Payment information'),
              SizedBox(height: 16.h),
              Text(
                'Type "DELETE" to confirm:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'DELETE'
                  ? () async {
                      dialogContext.pop();

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final authRepository = ref.read(authRepositoryProvider);
                        await authRepository.deleteAccount();

                        if (mounted) {
                          context.pop(); // Remove loading
                          context.go(AppRouter.login);
                        }
                      } catch (e) {
                        if (mounted) {
                          context.pop(); // Remove loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete account: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withOpacity(0.3),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(Icons.close, color: AppColors.error, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
