import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/settings_provider.dart';

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
                  _buildSwitchTile(
                    title: l10n.settingsMarketingTips,
                    subtitle: l10n.settingsMarketingTipsDesc,
                    value: marketingEmails,
                    onChanged: (value) async {
                      await ref
                          .read(marketingEmailsProviderProvider.notifier)
                          .setEnabled(value);
                    },
                    icon: Icons.campaign_outlined,
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
                  _buildNavigationTile(
                    title: l10n.settingsBlockedUsers,
                    subtitle: l10n.settingsBlockedUsersDesc,
                    icon: Icons.block_outlined,
                    onTap: () => _showBlockedUsersDialog(),
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
                  _buildNavigationTile(
                    title: AppLocalizations.of(context).vehicles,
                    subtitle: 'Manage your vehicles',
                    icon: Icons.directions_car_outlined,
                    onTap: () => context.push(AppRoutes.vehicles.path),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.settingsPaymentMethods,
                    subtitle: l10n.settingsPaymentMethodsDesc,
                    icon: Icons.payment_outlined,
                    onTap: () => _showPaymentMethodsDialog(),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    title: l10n.settingsVerifyAccount,
                    subtitle: l10n.settingsVerifyAccountDesc,
                    icon: Icons.lock_outline_rounded,
                    onTap: () => _showChangePasswordDialog(),
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
              AppLocalizations.of(context).comingSoon,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).paymentIntegrationWillBeAvailable,
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
          AppLocalizations.of(context).changePassword,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).currentPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).newPassword,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).confirmNewPassword,
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
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).passwordUpdatedSuccessfully,
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(AppLocalizations.of(context).update),
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
          borderRadius: BorderRadius.circular(20.r),
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
            borderRadius: BorderRadius.circular(20.r),
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
