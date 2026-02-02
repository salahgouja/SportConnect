import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/core/config/app_router.dart';

/// Driver Settings Screen - Configure driver preferences and app settings
class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() =>
      _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
  // Settings state
  bool _autoAcceptRequests = false;
  bool _acceptCashPayments = true;
  bool _acceptCardPayments = true;
  bool _showOnMap = true;
  bool _allowInstantBooking = true;
  bool _soundEffects = true;
  bool _vibration = true;
  bool _nightMode = false;
  double _maxDistance = 25.0;
  String _selectedLanguage = 'English';
  String _navigationApp = 'In-App';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20.w,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Driver Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ride Preferences
            _buildSectionHeader('Ride Preferences', Icons.directions_car),
            _buildSettingsCard([
              _buildSwitchTile(
                'Auto-Accept Requests',
                'Automatically accept ride requests that match your criteria',
                Icons.flash_on,
                _autoAcceptRequests,
                (value) => setState(() => _autoAcceptRequests = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Allow Instant Booking',
                'Let passengers book without waiting for approval',
                Icons.bolt,
                _allowInstantBooking,
                (value) => setState(() => _allowInstantBooking = value),
              ),
              _buildDivider(),
              _buildSliderTile(
                'Maximum Pickup Distance',
                'Only receive requests within this distance',
                Icons.social_distance,
                _maxDistance,
                (value) => setState(() => _maxDistance = value),
                min: 5,
                max: 50,
                suffix: 'mi',
              ),
            ]).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Payment Settings
            _buildSectionHeader('Payment Settings', Icons.payment),
            _buildSettingsCard([
              _buildSwitchTile(
                'Accept Cash Payments',
                'Allow passengers to pay with cash',
                Icons.money,
                _acceptCashPayments,
                (value) => setState(() => _acceptCashPayments = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Accept Card Payments',
                'Allow passengers to pay with card in-app',
                Icons.credit_card,
                _acceptCardPayments,
                (value) => setState(() => _acceptCardPayments = value),
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Payout Method',
                'Bank Account ending in 4532',
                Icons.account_balance,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Tax Documents',
                'View and download tax forms',
                Icons.description,
                () {},
              ),
            ]).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Navigation & Map
            _buildSectionHeader('Navigation & Map', Icons.map),
            _buildSettingsCard([
              _buildSwitchTile(
                'Show on Driver Map',
                'Allow passengers to see your location',
                Icons.visibility,
                _showOnMap,
                (value) => setState(() => _showOnMap = value),
              ),
              _buildDivider(),
              _buildDropdownTile(
                'Preferred Navigation App',
                Icons.navigation,
                _navigationApp,
                ['In-App', 'Google Maps', 'Waze', 'Apple Maps'],
                (value) => setState(() => _navigationApp = value),
              ),
            ]).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Notifications
            _buildSectionHeader('Notifications', Icons.notifications),
            _buildSettingsCard([
              _buildSwitchTile(
                'Sound Effects',
                'Play sounds for new requests and messages',
                Icons.volume_up,
                _soundEffects,
                (value) => setState(() => _soundEffects = value),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Vibration',
                'Vibrate for important alerts',
                Icons.vibration,
                _vibration,
                (value) => setState(() => _vibration = value),
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Notification Preferences',
                'Customize what notifications you receive',
                Icons.tune,
                () {},
              ),
            ]).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Appearance
            _buildSectionHeader('Appearance', Icons.palette),
            _buildSettingsCard([
              _buildSwitchTile(
                'Night Mode',
                'Reduce eye strain in low light',
                Icons.dark_mode,
                _nightMode,
                (value) => setState(() => _nightMode = value),
              ),
              _buildDivider(),
              _buildDropdownTile(
                'Language',
                Icons.language,
                _selectedLanguage,
                ['English', 'Spanish', 'French', 'German', 'Chinese'],
                (value) => setState(() => _selectedLanguage = value),
              ),
            ]).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Account & Security
            _buildSectionHeader('Account & Security', Icons.security),
            _buildSettingsCard([
              _buildNavigationTile(
                'Driver Documents',
                'License, insurance, and registration',
                Icons.folder,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Background Check',
                'View your verification status',
                Icons.verified_user,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Change Password',
                'Update your account password',
                Icons.lock,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Two-Factor Authentication',
                'Add extra security to your account',
                Icons.security,
                () {},
              ),
            ]).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Support
            _buildSectionHeader('Support', Icons.help),
            _buildSettingsCard([
              _buildNavigationTile(
                'Driver Help Center',
                'FAQs and troubleshooting guides',
                Icons.help_center,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Contact Support',
                'Chat with our support team',
                Icons.chat,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Report a Safety Issue',
                'Report incidents or concerns',
                Icons.report,
                () {},
                isDestructive: true,
              ),
            ]).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Danger Zone
            _buildSectionHeader(
              'Account Actions',
              Icons.warning,
              isDestructive: true,
            ),
            _buildSettingsCard([
              _buildNavigationTile(
                'Switch to Rider Mode',
                'Use the app as a passenger',
                Icons.swap_horiz,
                () => context.go(AppRouter.home),
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Sign Out',
                'Log out of your account',
                Icons.logout,
                () => _showSignOutDialog(),
                isWarning: true,
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Pause Driver Account',
                'Temporarily stop receiving requests',
                Icons.pause_circle,
                () {},
                isWarning: true,
              ),
              _buildDivider(),
              _buildNavigationTile(
                'Delete Driver Account',
                'Permanently remove your driver profile',
                Icons.delete_forever,
                () => _showDeleteAccountDialog(),
                isDestructive: true,
              ),
            ]).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),

            SizedBox(height: 40.h),

            // Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    'SportConnect Driver',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Version 2.1.0',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.w,
            color: isDestructive ? AppColors.error : AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.border, indent: 56.w);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool isWarning = false,
  }) {
    Color iconColor = isDestructive
        ? AppColors.error
        : isWarning
        ? AppColors.warning
        : AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
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
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    ValueChanged<double> onChanged, {
    double min = 0,
    double max = 100,
    String suffix = '',
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${value.round()} $suffix',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              isDense: true,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.warning),
            SizedBox(width: 8.w),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) {
                context.go(AppRouter.login);
              }
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8.w),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your driver data, earnings history, and ratings will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              // TODO: Implement account deletion
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
