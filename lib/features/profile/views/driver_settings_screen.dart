import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/driver_settings_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Settings Screen - Configure driver preferences and app settings
class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() =>
      _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
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
    final settingsState = ref.watch(driverSettingsViewModelProvider);
    final settingsNotifier = ref.read(driverSettingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Go back',
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
          AppLocalizations.of(context).driverSettings,
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
            _buildSectionHeader(
              AppLocalizations.of(context).ridePreferences,
              Icons.directions_car,
            ),
            _buildSettingsCard([
              _buildSwitchTile(
                AppLocalizations.of(context).autoAcceptRequests,
                AppLocalizations.of(
                  context,
                ).automaticallyAcceptRideRequestsThat,
                Icons.flash_on,
                settingsState.autoAcceptRequests,
                settingsNotifier.setAutoAcceptRequests,
              ),
              _buildDivider(),
              _buildSwitchTile(
                AppLocalizations.of(context).allowInstantBooking,
                AppLocalizations.of(context).letPassengersBookWithoutWaiting,
                Icons.bolt,
                settingsState.allowInstantBooking,
                settingsNotifier.setAllowInstantBooking,
              ),
              _buildDivider(),
              _buildSliderTile(
                AppLocalizations.of(context).maximumPickupDistance,
                AppLocalizations.of(context).onlyReceiveRequestsWithinThis,
                Icons.social_distance,
                settingsState.maxDistance,
                settingsNotifier.setMaxDistance,
                min: 5,
                max: 50,
                suffix: 'mi',
              ),
            ]).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Payment Settings
            _buildSectionHeader(
              AppLocalizations.of(context).paymentSettings,
              Icons.payment,
            ),
            _buildSettingsCard([
              _buildSwitchTile(
                AppLocalizations.of(context).acceptCashPayments,
                AppLocalizations.of(context).allowPassengersToPayWith,
                Icons.money,
                settingsState.acceptCashPayments,
                settingsNotifier.setAcceptCashPayments,
              ),
              _buildDivider(),
              _buildSwitchTile(
                AppLocalizations.of(context).acceptCardPayments,
                AppLocalizations.of(context).allowPassengersToPayWith2,
                Icons.credit_card,
                settingsState.acceptCardPayments,
                settingsNotifier.setAcceptCardPayments,
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).payoutMethod,
                AppLocalizations.of(context).bankAccountEndingIn4532,
                Icons.account_balance,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).taxDocuments,
                AppLocalizations.of(context).viewAndDownloadTaxForms,
                Icons.description,
                () {},
              ),
            ]).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Navigation & Map
            _buildSectionHeader(
              AppLocalizations.of(context).navigationMap,
              Icons.map,
            ),
            _buildSettingsCard([
              _buildSwitchTile(
                AppLocalizations.of(context).showOnDriverMap,
                AppLocalizations.of(context).allowPassengersToSeeYour,
                Icons.visibility,
                settingsState.showOnMap,
                settingsNotifier.setShowOnMap,
              ),
              _buildDivider(),
              _buildDropdownTile(
                AppLocalizations.of(context).preferredNavigationApp,
                Icons.navigation,
                settingsState.navigationApp,
                ['In-App', 'Google Maps', 'Waze', 'Apple Maps'],
                settingsNotifier.setNavigationApp,
              ),
            ]).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Notifications
            _buildSectionHeader(
              AppLocalizations.of(context).settingsNotifications,
              Icons.notifications,
            ),
            _buildSettingsCard([
              _buildSwitchTile(
                AppLocalizations.of(context).soundEffects,
                AppLocalizations.of(context).playSoundsForNewRequests,
                Icons.volume_up,
                settingsState.soundEffects,
                settingsNotifier.setSoundEffects,
              ),
              _buildDivider(),
              _buildSwitchTile(
                AppLocalizations.of(context).vibration,
                AppLocalizations.of(context).vibrateForImportantAlerts,
                Icons.vibration,
                settingsState.vibration,
                settingsNotifier.setVibration,
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).notificationPreferences,
                AppLocalizations.of(
                  context,
                ).customizeWhatNotificationsYouReceive,
                Icons.tune,
                () {},
              ),
            ]).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Appearance
            _buildSectionHeader(
              AppLocalizations.of(context).settingsAppearance,
              Icons.palette,
            ),
            _buildSettingsCard([
              _buildSwitchTile(
                AppLocalizations.of(context).nightMode,
                AppLocalizations.of(context).reduceEyeStrainInLow,
                Icons.dark_mode,
                settingsState.nightMode,
                settingsNotifier.setNightMode,
              ),
              _buildDivider(),
              _buildDropdownTile(
                AppLocalizations.of(context).settingsLanguage,
                Icons.language,
                settingsState.selectedLanguage,
                ['English', 'Spanish', 'French', 'German', 'Chinese'],
                settingsNotifier.setSelectedLanguage,
              ),
            ]).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Account & Security
            _buildSectionHeader(
              AppLocalizations.of(context).accountSecurity,
              Icons.security,
            ),
            _buildSettingsCard([
              _buildNavigationTile(
                AppLocalizations.of(context).driverDocuments,
                AppLocalizations.of(context).licenseInsuranceAndRegistration,
                Icons.folder,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).backgroundCheck,
                AppLocalizations.of(context).viewYourVerificationStatus,
                Icons.verified_user,
                () {},
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).changePassword,
                AppLocalizations.of(context).updateYourAccountPassword,
                Icons.lock,
                () => context.push(AppRoutes.changePassword.path),
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).twoFactorAuthentication,
                AppLocalizations.of(context).addExtraSecurityToYour,
                Icons.security,
                () {},
              ),
            ]).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Support
            _buildSectionHeader(
              AppLocalizations.of(context).support,
              Icons.help,
            ),
            _buildSettingsCard([
              _buildNavigationTile(
                AppLocalizations.of(context).driverHelpCenter,
                AppLocalizations.of(context).faqsAndTroubleshootingGuides,
                Icons.help_center,
                () => context.push(AppRoutes.helpCenter.path),
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).contactSupport,
                AppLocalizations.of(context).chatWithOurSupportTeam,
                Icons.chat,
                () => context.push(AppRoutes.contactSupport.path),
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).reportASafetyIssue,
                AppLocalizations.of(context).reportIncidentsOrConcerns,
                Icons.report,
                () => context.push(AppRoutes.reportIssue.path),
                isDestructive: true,
              ),
            ]).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

            SizedBox(height: 24.h),

            // Danger Zone
            _buildSectionHeader(
              AppLocalizations.of(context).accountActions,
              Icons.warning,
              isDestructive: true,
            ),
            _buildSettingsCard([
              _buildNavigationTile(
                AppLocalizations.of(context).switchToRiderMode,
                AppLocalizations.of(context).useTheAppAsA,
                Icons.swap_horiz,
                () => context.go(AppRoutes.home.path),
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).signOut,
                AppLocalizations.of(context).logOutOfYourAccount,
                Icons.logout,
                () => _showSignOutDialog(),
                isWarning: true,
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).pauseDriverAccount,
                AppLocalizations.of(context).temporarilyStopReceivingRequests,
                Icons.pause_circle,
                () => _showPauseAccountDialog(),
                isWarning: true,
              ),
              _buildDivider(),
              _buildNavigationTile(
                AppLocalizations.of(context).deleteDriverAccount,
                AppLocalizations.of(context).permanentlyRemoveYourDriverProfile,
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
                    AppLocalizations.of(context).sportconnectDriver,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context).version210,
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
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: AppColors.primary,
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
                  AppLocalizations.of(
                    context,
                  ).valueValue4(value.round(), suffix),
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
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
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
      barrierLabel: 'Sign out dialog',
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.warning),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).signOut),
          ],
        ),
        content: Text(AppLocalizations.of(context).areYouSureYouWant3),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              await ref.read(authActionsViewModelProvider).signOut();
              if (mounted) {
                context.go(AppRoutes.login.path);
              }
            },
            child: Text(
              AppLocalizations.of(context).signOut,
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierLabel: 'Delete account dialog',
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context).settingsDeleteAccount),
          ],
        ),
        content: Text(AppLocalizations.of(context).thisActionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _confirmAndDeleteAccount();
            },
            child: Text(
              AppLocalizations.of(context).actionDelete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDeleteAccount() async {
    try {
      await ref.read(authActionsViewModelProvider).deleteAccount();
      if (mounted) {
        context.go(AppRoutes.login.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToDeleteAccountValue(
                'Unable to delete account right now.',
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPauseAccountDialog() {
    showDialog(
      context: context,
      barrierLabel: 'Pause account dialog',
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pause_circle, color: AppColors.warning),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Pause Driver Account?',
                style: TextStyle(fontSize: 17.sp),
              ),
            ),
          ],
        ),
        content: const Text(
          'You will stop receiving ride requests until you resume. '
          'Your profile and reviews will remain visible.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () {
              ctx.pop();
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Driver account paused'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            },
            child: Text(
              'Pause Account',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
