import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/settings_provider.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Premium Settings Screen with enterprise-grade UI
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // All settings are managed by providers

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeAsync = ref.watch(localeProviderProvider);
    final currentLocale = localeAsync.value ?? Localizations.localeOf(context);

    // Watch all settings providers
    final notificationsEnabled =
        ref.watch(notificationsEnabledProviderProvider).value ?? true;
    final rideReminders =
        ref.watch(rideRemindersProviderProvider).value ?? true;
    final chatNotifications =
        ref.watch(chatNotificationsProviderProvider).value ?? true;
    final marketingEmails =
        ref.watch(marketingEmailsProviderProvider).value ?? false;
    final autoAcceptRides =
        ref.watch(autoAcceptRidesProviderProvider).value ?? false;
    final showLocation = ref.watch(showLocationProviderProvider).value ?? true;
    final publicProfile =
        ref.watch(publicProfileProviderProvider).value ?? true;
    final distanceUnit = ref.watch(distanceUnitProviderProvider).value ?? 'km';
    // Only drivers have the auto-accept toggle — hide it for riders
    final isDriver = ref.watch(currentUserProvider).value is DriverModel;

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
              tooltip: 'Back',
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
                AppLocalizations.of(context).settingsTitle,
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
                  l10n.settingsNotifications,
                  Icons.notifications_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: l10n.settingsPushNotifications,
                    subtitle: l10n.settingsPushNotificationsDesc,
                    value: notificationsEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(notificationsEnabledProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.notifications_active_outlined,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: l10n.settingsRideReminders,
                    subtitle: l10n.settingsRideRemindersDesc,
                    value: rideReminders,
                    onChanged: (value) async {
                      await ref
                          .read(rideRemindersProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.alarm_outlined,
                    enabled: notificationsEnabled,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: l10n.settingsChatMessages,
                    subtitle: l10n.settingsChatMessagesDesc,
                    value: chatNotifications,
                    onChanged: (value) async {
                      await ref
                          .read(chatNotificationsProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.chat_bubble_outline_rounded,
                    enabled: notificationsEnabled,
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Notification Permission',
                    subtitle: 'Re-allow push notifications for this device',
                    icon: Icons.notifications_none_rounded,
                    onTap: _resetAndRequestNotificationPermission,
                  ),
                ]),

                SizedBox(height: 24.h),

                // Appearance Section
                _buildSectionHeader(
                  l10n.settingsAppearance,
                  Icons.palette_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildLanguageDropdownTile(
                    l10n: l10n,
                    currentLocale: currentLocale,
                    onLanguageChanged: (languageCode) async {
                      if (languageCode != null) {
                        await ref
                            .read(localeProviderProvider.notifier)
                            .setLanguage(languageCode);
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildDropdownTile(
                    title: l10n.settingsDistanceUnit,
                    subtitle: l10n.settingsDistanceUnitDesc,
                    value: distanceUnit,
                    options: ['km', 'miles'],
                    onChanged: (value) async {
                      await ref
                          .read(distanceUnitProviderProvider.notifier)
                          .setUnit(value ?? 'km');
                    },
                    icon: Icons.straighten_outlined,
                  ),
                ]),

                SizedBox(height: 24.h),

                // Privacy Section
                _buildSectionHeader(
                  l10n.settingsPrivacySafety,
                  Icons.shield_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildSwitchTile(
                    title: l10n.settingsPublicProfile,
                    subtitle: l10n.settingsPublicProfileDesc,
                    value: publicProfile,
                    onChanged: (value) async {
                      await ref
                          .read(publicProfileProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.person_outline_rounded,
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: l10n.settingsShowLocation,
                    subtitle: l10n.settingsShowLocationDesc,
                    value: showLocation,
                    onChanged: (value) async {
                      await ref
                          .read(showLocationProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.location_on_outlined,
                  ),
                  _buildDivider(),
                  // Auto-accept is a driver-only feature (drivers accept/reject
                  // ride requests). Hide the toggle entirely for riders.
                  if (isDriver) ...[
                    _buildSwitchTile(
                      title: l10n.settingsAutoAcceptRides,
                      subtitle: l10n.settingsAutoAcceptRidesDesc,
                      value: autoAcceptRides,
                      onChanged: (value) async {
                        await ref
                            .read(autoAcceptRidesProviderProvider.notifier)
                            .setEnabled(value);
                      },
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    _buildDivider(),
                  ],
                  _buildNavigationTile(
                    title: l10n.settingsBlockedUsers,
                    subtitle: l10n.settingsBlockedUsersDesc,
                    icon: Icons.block_outlined,
                    onTap: () => _showBlockedUsersDialog(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Download My Data',
                    subtitle: 'Export a copy of your personal data',
                    icon: Icons.download_outlined,
                    onTap: () => _showDataExportDialog(),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Data & Consent Section (GDPR / Store compliance)
                _buildSectionHeader(
                  'Data & Consent',
                  Icons.verified_user_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: 'Data Processing Notice',
                    subtitle: 'How we collect, use, and protect your data',
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showDataProcessingNotice(),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    title: 'Marketing Communications',
                    subtitle:
                        'Receive tips, offers, and product updates via email',
                    value: marketingEmails,
                    onChanged: (value) async {
                      await ref
                          .read(marketingEmailsProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.campaign_outlined,
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: 'Withdraw Consent',
                    subtitle: 'Manage or withdraw your data consent',
                    icon: Icons.remove_circle_outline,
                    onTap: () => _showWithdrawConsentDialog(),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Account Section
                _buildSectionHeader(
                  l10n.settingsAccount,
                  Icons.account_circle_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: l10n.settingsEditProfile,
                    subtitle: l10n.settingsEditProfileDesc,
                    icon: Icons.edit_outlined,
                    onTap: () => context.push(AppRoutes.editProfile.path),
                  ),
                  _buildDivider(),
                  // Vehicles management is driver-only — riders don't have vehicles
                  if (isDriver) ...[
                    _buildNavigationTile(
                      title: AppLocalizations.of(context).vehicles,
                      subtitle: 'Manage your vehicles',
                      icon: Icons.directions_car_outlined,
                      onTap: () => context.push(AppRoutes.vehicles.path),
                    ),
                    _buildDivider(),
                  ],
                  _buildNavigationTile(
                    title: l10n.settingsPaymentMethods,
                    subtitle: l10n.settingsPaymentMethodsDesc,
                    icon: Icons.payment_outlined,
                    onTap: () => context.push(AppRoutes.paymentHistory.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.changePassword,
                    subtitle: 'Update your account password',
                    icon: Icons.lock_outline_rounded,
                    onTap: () => context.push(AppRoutes.changePassword.path),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Support Section
                _buildSectionHeader(
                  l10n.settingsSupport,
                  Icons.help_outline_rounded,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: l10n.settingsHelpCenter,
                    subtitle: l10n.settingsHelpCenterDesc,
                    icon: Icons.help_center_outlined,
                    onTap: () => context.push(AppRoutes.helpCenter.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: AppLocalizations.of(context).contactSupport,
                    subtitle: 'Get help from our team',
                    icon: Icons.support_agent_outlined,
                    onTap: () => context.push(AppRoutes.contactSupport.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.settingsReportProblem,
                    subtitle: l10n.settingsReportProblemDesc,
                    icon: Icons.bug_report_outlined,
                    onTap: () => context.push(AppRoutes.reportIssue.path),
                  ),
                ]),

                SizedBox(height: 24.h),

                // Legal Section
                _buildSectionHeader(
                  AppLocalizations.of(context).legal,
                  Icons.gavel_outlined,
                ),
                SizedBox(height: 12.h),
                _buildSettingsCard([
                  _buildNavigationTile(
                    title: l10n.settingsTermsConditions,
                    subtitle: '', // No description in ARB
                    icon: Icons.description_outlined,
                    onTap: () => context.push(AppRoutes.terms.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.settingsPrivacyPolicy,
                    subtitle: '', // No description in ARB
                    icon: Icons.privacy_tip_outlined,
                    onTap: () => context.push(AppRoutes.privacy.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.settingsAbout,
                    subtitle: l10n.settingsAboutDesc,
                    icon: Icons.article_outlined,
                    onTap: () => context.push(AppRoutes.about.path),
                  ),
                ]),

                SizedBox(height: 32.h),

                // App Version
                Center(
                  child: Text(
                    AppLocalizations.of(context).sportconnectV100,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Logout Button
                PremiumButton(
                  text: l10n.settingsLogout,
                  onPressed: () => _showLogoutDialog(),
                  style: PremiumButtonStyle.outline,
                  icon: Icons.logout_rounded,
                ),

                SizedBox(height: 16.h),

                // Delete Account
                TextButton(
                  onPressed: () => _showDeleteAccountDialog(),
                  child: Text(
                    l10n.settingsDeleteAccount,
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

  /// Clears the `notification_dialog_shown` flag and re-runs the full
  /// rationale → OS permission flow, allowing the user to grant notifications
  /// even if they dismissed the dialog on first launch or the OS returned an
  /// unexpected `denied` status on a fresh install.
  Future<void> _resetAndRequestNotificationPermission() async {
    // Clear the flag so the logic treats this as a first-time ask.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_dialog_shown', false);

    final status = (await FirebaseMessaging.instance
            .getNotificationSettings())
        .authorizationStatus;

    // Already granted — just tell the user.
    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifications are already enabled.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    // For `deniedForever` on Android the only path is the system settings page.
    if (status == AuthorizationStatus.denied) {
      // Try requesting via OS — on Android 13+ this is a no-op when denied,
      // but on iOS it opens the system settings prompt.
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (!mounted) return;
      final granted =
          result.authorizationStatus == AuthorizationStatus.authorized ||
          result.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notifications are blocked. '
              'Please enable them in your device Settings > App > Notifications.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
      return;
    }

    // `notDetermined` — show our rationale dialog then request.
    if (!mounted) return;
    final accepted =
        await PermissionDialogHelper.showNotificationRationale(context);
    await prefs.setBool('notification_dialog_shown', true);
    if (!accepted) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification permission requested.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
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

  Widget _buildLanguageDropdownTile({
    required AppLocalizations l10n,
    required Locale currentLocale,
    required ValueChanged<String?> onLanguageChanged,
  }) {
    // Map locale to display name
    final Map<String, String> languageOptions = {
      'en': l10n.languageEnglish,
      'fr': l10n.languageFrench,
      'de': l10n.languageGerman,
      'es': l10n.languageSpanish,
    };

    final currentLanguageCode = currentLocale.languageCode;
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
            child: Icon(
              Icons.language_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.settingsLanguageDesc,
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
                value: currentLanguageCode,
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
                items: languageOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: onLanguageChanged,
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
              AppLocalizations.of(context).noBlockedUsers,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).usersYouBlockWillAppear,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _showDataExportDialog() {
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
              Icons.download_outlined,
              size: 48.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Download My Data',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We will prepare a copy of your personal data including '
              'your profile, ride history, and reviews. You will receive '
              'an email with a download link within 48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'Request Data Export',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data export request submitted. '
                      'You will receive an email shortly.',
                    ),
                  ),
                );
              },
              style: PremiumButtonStyle.gradient,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showDataProcessingNotice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Icon(
                Icons.verified_user_outlined,
                size: 48.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Data Processing Notice',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildConsentInfoItem(
                'Personal Information',
                'We collect your name, email, phone number, '
                    'and profile photo to create and manage your account.',
                Icons.person_outline,
              ),
              _buildConsentInfoItem(
                'Location Data',
                'We process your location to match rides, calculate '
                    'routes, and show nearby destinations. You can disable '
                    'location sharing in Privacy settings.',
                Icons.location_on_outlined,
              ),
              _buildConsentInfoItem(
                'Payment Data',
                'Payment information is processed securely by Stripe. '
                    'We do not store your full card details.',
                Icons.payment_outlined,
              ),
              _buildConsentInfoItem(
                'Usage Data',
                'We collect crash reports and usage analytics to improve '
                    'the app experience. This data is anonymized.',
                Icons.analytics_outlined,
              ),
              _buildConsentInfoItem(
                'Your Rights',
                'You can access, export, correct, or delete your data '
                    'at any time. Use "Download My Data" to export, or '
                    '"Delete Account" to erase all data.',
                Icons.gavel_outlined,
              ),
              SizedBox(height: 16.h),
              Text(
                'By using SportConnect, you consent to the data '
                'processing described above and in our Privacy Policy. '
                'You may withdraw consent at any time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentInfoItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
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
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawConsentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          'Withdraw Consent',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You can withdraw your consent for data processing in '
              'the following ways:',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _buildConsentOption(
              'Disable Location Sharing',
              'Turn off location in Privacy & Safety settings.',
              Icons.location_off_outlined,
            ),
            _buildConsentOption(
              'Stop Marketing',
              'Disable marketing communications in Notifications.',
              Icons.unsubscribe_outlined,
            ),
            _buildConsentOption(
              'Export Your Data',
              'Request a copy of all your personal data.',
              Icons.download_outlined,
            ),
            _buildConsentOption(
              'Delete Account',
              'Permanently delete your account and all data.',
              Icons.delete_forever_outlined,
            ),
            SizedBox(height: 8.h),
            Text(
              'Note: Withdrawing consent for core data processing '
              '(account, rides) requires account deletion, as these '
              'are essential for the service.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentOption(String title, String description, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          AppLocalizations.of(context).settingsLogout,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(context).areYouSureYouWant5,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              await ref.read(authActionsViewModelProvider).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).settingsLogout),
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
            borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).settingsDeleteAccount,
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
                AppLocalizations.of(context).thisActionCannotBeUndone2,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDeleteWarningItem(
                AppLocalizations.of(context).rideHistoryAndBookings,
              ),
              _buildDeleteWarningItem(
                AppLocalizations.of(context).profileAndAchievements,
              ),
              _buildDeleteWarningItem(
                AppLocalizations.of(context).messagesAndConnections,
              ),
              _buildDeleteWarningItem(
                AppLocalizations.of(context).paymentInformation,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).typeDeleteToConfirm,
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
              child: Text(AppLocalizations.of(context).actionCancel),
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
                        await ref
                            .read(authActionsViewModelProvider)
                            .deleteAccount();

                        if (mounted) {
                          context.pop(); // Remove loading
                        }
                      } catch (e) {
                        if (mounted) {
                          context.pop(); // Remove loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                ).failedToDeleteAccountValue(e),
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
              ),
              child: Text(AppLocalizations.of(context).settingsDeleteAccount),
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
