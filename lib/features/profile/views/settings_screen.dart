import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/views/reauth_dialog.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/providers/settings_provider.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/features/profile/view_models/driver_settings_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _driverSectionExpanded = false;

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
    final l10n = AppLocalizations.of(context);
    final localeAsync = ref.watch(localeProviderProvider);
    final currentLocale = localeAsync.value ?? Localizations.localeOf(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final isDriver = currentUserAsync.value?.role == UserRole.driver;

    final notificationsEnabled =
        ref.watch(notificationsEnabledProviderProvider).value ?? true;
    final rideReminders =
        ref.watch(rideRemindersProviderProvider).value ?? true;
    final chatNotifications =
        ref.watch(chatNotificationsProviderProvider).value ?? true;
    final autoAcceptRides =
        ref.watch(autoAcceptRidesProviderProvider).value ?? false;
    final showLocation = ref.watch(showLocationProviderProvider).value ?? true;
    final publicProfile =
        ref.watch(publicProfileProviderProvider).value ?? true;
    final mapStyle = ref.watch(mapStyleProviderProvider).value ?? 'standard';

    final driverSettings = isDriver
        ? ref.watch(driverSettingsViewModelProvider)
        : null;
    final driverNotifier = isDriver
        ? ref.read(driverSettingsViewModelProvider.notifier)
        : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.borderLight,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          // ── Driver Settings (collapsible) ────────────────────
          if (isDriver && driverSettings != null && driverNotifier != null) ...[
            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.driverSettings,
              Icons.drive_eta_rounded,
              color: AppColors.secondary,
            ),
            SizedBox(height: 12.h),
            _buildDriverCard(
              l10n: l10n,
              driverSettings: driverSettings,
              driverNotifier: driverNotifier,
            ),
          ],

          // ── Notifications ────────────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(l10n.settingsNotifications, Icons.tune_rounded),
          SizedBox(height: 12.h),
          _buildCard([
            _buildSwitchTile(
              title: l10n.settingsPushNotifications,
              subtitle: l10n.settingsPushNotificationsDesc,
              value: notificationsEnabled,
              icon: Icons.notifications_outlined,
              onChanged: (v) => ref
                  .read(notificationsEnabledProviderProvider.notifier)
                  .setEnabled(v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsRideReminders,
              subtitle: l10n.settingsRideRemindersDesc,
              value: rideReminders,
              icon: Icons.alarm_outlined,
              enabled: notificationsEnabled,
              onChanged: (v) => ref
                  .read(rideRemindersProviderProvider.notifier)
                  .setEnabled(v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsChatMessages,
              subtitle: l10n.settingsChatMessagesDesc,
              value: chatNotifications,
              icon: Icons.chat_bubble_outline_rounded,
              enabled: notificationsEnabled,
              onChanged: (v) => ref
                  .read(chatNotificationsProviderProvider.notifier)
                  .setEnabled(v),
            ),
            _buildDivider(),
            _buildNavTile(
              title: 'Notification Permission',
              subtitle: 'Re-allow push notifications for this device',
              icon: Icons.notifications_none_rounded,
              onTap: _resetAndRequestNotificationPermission,
            ),
          ]),

          // ── Appearance ───────────────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(l10n.settingsAppearance, Icons.palette_outlined),
          SizedBox(height: 12.h),
          _buildCard([
            _buildMapStyleTile(
              currentStyle: mapStyle,
              onChanged: (style) => ref
                  .read(mapStyleProviderProvider.notifier)
                  .setMapStyle(style),
            ),
            _buildDivider(),
            _buildLanguageTile(
              l10n: l10n,
              currentLocale: currentLocale,
              onChanged: (code) async {
                if (code != null) {
                  await ref
                      .read(localeProviderProvider.notifier)
                      .setLanguage(code);
                }
              },
            ),
          ]),

          // ── Privacy & Security ───────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(
            l10n.settingsPrivacySafety,
            Icons.shield_outlined,
          ),
          SizedBox(height: 12.h),
          _buildCard([
            _buildSwitchTile(
              title: l10n.settingsPublicProfile,
              subtitle: l10n.settingsPublicProfileDesc,
              value: publicProfile,
              icon: Icons.person_outline_rounded,
              onChanged: (v) => ref
                  .read(publicProfileProviderProvider.notifier)
                  .setEnabled(v),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsShowLocation,
              subtitle: l10n.settingsShowLocationDesc,
              value: showLocation,
              icon: Icons.location_on_outlined,
              onChanged: (v) =>
                  ref.read(showLocationProviderProvider.notifier).setEnabled(v),
            ),
            if (isDriver) ...[
              _buildDivider(),
              _buildSwitchTile(
                title: l10n.settingsAutoAcceptRides,
                subtitle: l10n.settingsAutoAcceptRidesDesc,
                value: autoAcceptRides,
                icon: Icons.check_circle_outline_rounded,
                onChanged: (v) => ref
                    .read(autoAcceptRidesProviderProvider.notifier)
                    .setEnabled(v),
              ),
            ],
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsBlockedUsers,
              subtitle: l10n.settingsBlockedUsersDesc,
              icon: Icons.block_outlined,
              onTap: _openBlockedUsersScreen,
            ),
            _buildDivider(),
            _buildNavTile(
              title: 'Data Processing Notice',
              subtitle: 'How we collect, use, and protect your data',
              icon: Icons.info_outline_rounded,
              onTap: _showDataProcessingNotice,
            ),
            _buildDivider(),
            _buildNavTile(
              title: 'Withdraw Consent',
              subtitle: 'Manage or withdraw your data consent',
              icon: Icons.remove_circle_outline,
              onTap: _showWithdrawConsentDialog,
            ),
            _buildDivider(),
            _buildNavTile(
              title: 'Download My Data',
              subtitle: 'Export a copy of your personal data',
              icon: Icons.download_outlined,
              onTap: _showDataExportDialog,
            ),
          ]),

          // ── Account ──────────────────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(
            l10n.settingsAccount,
            Icons.account_circle_outlined,
          ),
          SizedBox(height: 12.h),
          _buildCard([
            _buildNavTile(
              title: l10n.settingsEditProfile,
              subtitle: l10n.settingsEditProfileDesc,
              icon: Icons.edit_outlined,
              onTap: () => context.push(AppRoutes.editProfile.path),
            ),
            if (isDriver) ...[
              _buildDivider(),
              _buildNavTile(
                title: l10n.vehicles,
                subtitle: 'Manage your vehicles',
                icon: Icons.directions_car_outlined,
                onTap: () => context.push(AppRoutes.driverVehicles.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.driverDocuments,
                subtitle: l10n.licenseInsuranceAndRegistration,
                icon: Icons.folder_outlined,
                onTap: () => context.push(AppRoutes.driverDocuments.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.backgroundCheck,
                subtitle: l10n.viewYourVerificationStatus,
                icon: Icons.verified_user_outlined,
                onTap: () => context.push(AppRoutes.backgroundCheck.path),
              ),
            ],
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsPaymentMethods,
              subtitle: l10n.settingsPaymentMethodsDesc,
              icon: Icons.payment_outlined,
              onTap: () => context.push(AppRoutes.paymentHistory.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.changePassword,
              subtitle: 'Update your account password',
              icon: Icons.lock_outline_rounded,
              onTap: () => context.push(AppRoutes.changePassword.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.twoFactorAuthentication,
              subtitle: l10n.addExtraSecurityToYour,
              icon: Icons.security_outlined,
              onTap: () => context.push(AppRoutes.twoFactorAuth.path),
            ),
          ]),

          // ── Support & Legal ──────────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(l10n.settingsSupport, Icons.help_outline_rounded),
          SizedBox(height: 12.h),
          _buildCard([
            _buildNavTile(
              title: l10n.settingsHelpCenter,
              subtitle: l10n.settingsHelpCenterDesc,
              icon: Icons.help_center_outlined,
              onTap: () => context.push(AppRoutes.helpCenter.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.contactSupport,
              subtitle: 'Get help from our team',
              icon: Icons.support_agent_outlined,
              onTap: () => context.push(AppRoutes.contactSupport.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsReportProblem,
              subtitle: l10n.settingsReportProblemDesc,
              icon: Icons.bug_report_outlined,
              onTap: () => context.push(AppRoutes.reportIssue.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsTermsConditions,
              icon: Icons.description_outlined,
              onTap: () => context.push(AppRoutes.terms.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsPrivacyPolicy,
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push(AppRoutes.privacy.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsAbout,
              subtitle: l10n.settingsAboutDesc,
              icon: Icons.article_outlined,
              onTap: () => context.push(AppRoutes.about.path),
            ),
          ]),

          // ── Danger Zone ──────────────────────────────────────
          SizedBox(height: 32.h),
          _buildSectionHeader(
            l10n.accountActions,
            Icons.warning_amber_rounded,
            color: AppColors.error,
          ),
          SizedBox(height: 12.h),
          _buildDangerCard([
            _buildNavTile(
              title: l10n.signOut,
              subtitle: l10n.logOutOfYourAccount,
              icon: Icons.logout_rounded,
              onTap: _showLogoutDialog,
              color: AppColors.warning,
            ),
            // Delete separated with a stronger visual break
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: _buildNavTile(
                  title: l10n.settingsDeleteAccount,
                  subtitle: l10n.permanentlyRemoveYourDriverProfile,
                  icon: Icons.delete_forever_rounded,
                  onTap: _showDeleteAccountDialog,
                  color: AppColors.error,
                ),
              ),
            ),
          ]),

          // ── Footer ───────────────────────────────────────────
          SizedBox(height: 48.h),
          _buildFooter(l10n),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  // ── Driver collapsible card ──────────────────────────────────────────────────

  Widget _buildDriverCard({
    required AppLocalizations l10n,
    required dynamic driverSettings,
    required dynamic driverNotifier,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(left: BorderSide(color: AppColors.secondary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _driverSectionExpanded = !_driverSectionExpanded);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Icon(
                    Icons.drive_eta_rounded,
                    color: AppColors.secondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Driver Preferences',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _driverSectionExpanded ? 0.5 : 0,
                    duration: 200.ms,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: 250.ms,
            crossFadeState: _driverSectionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDivider(),
                _buildSubSectionLabel(l10n.ridePreferences),
                _buildSwitchTile(
                  title: l10n.allowInstantBooking,
                  subtitle: l10n.letPassengersBookWithoutWaiting,
                  value: driverSettings.allowInstantBooking,
                  icon: Icons.bolt_outlined,
                  onChanged: driverNotifier.setAllowInstantBooking,
                ),
                _buildDivider(),
                _buildSliderTile(
                  title: l10n.maximumPickupDistance,
                  subtitle: l10n.onlyReceiveRequestsWithinThis,
                  icon: Icons.social_distance_outlined,
                  value: driverSettings.maxDistance,
                  onChanged: driverNotifier.setMaxDistance,
                  min: 5,
                  max: 50,
                  suffix: 'mi',
                ),
                _buildDivider(),
                _buildSubSectionLabel(l10n.paymentSettings),
                _buildNavTile(
                  title: l10n.payoutMethod,
                  subtitle: l10n.bankAccountEndingIn4532,
                  icon: Icons.account_balance_outlined,
                  onTap: () =>
                      context.push(AppRoutes.driverStripeOnboarding.path),
                ),
                _buildDivider(),
                _buildNavTile(
                  title: l10n.taxDocuments,
                  subtitle: l10n.viewAndDownloadTaxForms,
                  icon: Icons.description_outlined,
                  onTap: () => context.push(AppRoutes.taxDocuments.path),
                ),
                _buildDivider(),
                _buildSubSectionLabel(l10n.navigationMap),
                _buildSwitchTile(
                  title: l10n.showOnDriverMap,
                  subtitle: l10n.allowPassengersToSeeYour,
                  value: driverSettings.showOnMap,
                  icon: Icons.visibility_outlined,
                  onChanged: driverNotifier.setShowOnMap,
                ),
                _buildDivider(),
                _buildDropdownTile(
                  title: l10n.preferredNavigationApp,
                  icon: Icons.navigation_outlined,
                  value: driverSettings.navigationApp,
                  options: ['In-App', 'Google Maps', 'Waze', 'Apple Maps'],
                  onChanged: (v) {
                    if (v != null) driverNotifier.setNavigationApp(v);
                  },
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 2.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? AppColors.primary;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: c, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Cards ────────────────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDangerCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
    );
  }

  // ── Tiles ────────────────────────────────────────────────────────────────────

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: value ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: 14.w),
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
            Switch.adaptive(
              value: value && enabled,
              onChanged: enabled
                  ? (v) {
                      HapticFeedback.selectionClick();
                      onChanged(v);
                    }
                  : null,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: c),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: color ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 100,
    String suffix = '',
  }) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 14.w),
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${value.round()} $suffix',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          Slider.adaptive(
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

  Widget _buildDropdownTile({
    required String title,
    String? subtitle,
    required String value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: 14.w),
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
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18.sp,
                ),
                items: options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required AppLocalizations l10n,
    required Locale currentLocale,
    required ValueChanged<String?> onChanged,
  }) {
    final options = {'en': l10n.languageEnglish, 'fr': l10n.languageFrench};
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            Icons.language_outlined,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    fontSize: 14.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLocale.languageCode,
                isDense: true,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18.sp,
                ),
                items: options.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStyleTile({
    required String currentStyle,
    required ValueChanged<String> onChanged,
  }) {
    final styles = ['standard', 'dark', 'satellite'];
    final icons = {
      'standard': Icons.map_outlined,
      'dark': Icons.dark_mode_outlined,
      'satellite': Icons.satellite_alt_outlined,
    };
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(Icons.map_outlined, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Style',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Choose map appearance',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentStyle,
              borderRadius: BorderRadius.circular(12.r),
              isDense: true,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 18.sp,
              ),
              items: styles
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icons[s], size: 15.sp),
                          SizedBox(width: 5.w),
                          Text(s[0].toUpperCase() + s.substring(1)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────────

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: AppColors.primary,
            size: 28.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'SportConnect',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.sportconnectV100,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  // ── Notification permission ───────────────────────────────────────────────────

  Future<void> _resetAndRequestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_dialog_shown', false);

    final status = (await FirebaseMessaging.instance.getNotificationSettings())
        .authorizationStatus;

    if (status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).notificationsAlreadyEnabled,
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    if (status == AuthorizationStatus.denied) {
      final result = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (!context.mounted) return;
      final granted =
          result.authorizationStatus == AuthorizationStatus.authorized ||
          result.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Notifications are blocked. Please enable them in Settings > App > Notifications.',
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

    if (!context.mounted) return;
    final accepted = await PermissionDialogHelper.showNotificationRationale(
      context,
    );
    await prefs.setBool('notification_dialog_shown', true);
    if (!accepted) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).notificationPermissionRequested,
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _openBlockedUsersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _BlockedUsersScreen(),
        fullscreenDialog: true,
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
              AppLocalizations.of(context).downloadMyData,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).downloadMyDataDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            PremiumButton(
              text: AppLocalizations.of(context).requestDataExport,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dataExportRequestSubmitted,
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
                AppLocalizations.of(context).dataProcessingNotice,
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
                'We collect your name, email, phone number, and profile photo to create and manage your account.',
                Icons.person_outline,
              ),
              _buildConsentInfoItem(
                'Location Data',
                'We process your location to match rides, calculate routes, and show nearby destinations.',
                Icons.location_on_outlined,
              ),
              _buildConsentInfoItem(
                'Payment Data',
                'Payment information is processed securely by Stripe. We do not store your full card details.',
                Icons.payment_outlined,
              ),
              _buildConsentInfoItem(
                'Usage Data',
                'We collect crash reports and usage analytics. This data is anonymized.',
                Icons.analytics_outlined,
              ),
              _buildConsentInfoItem(
                'Your Rights',
                'You can access, export, correct, or delete your data at any time.',
                Icons.gavel_outlined,
              ),
              SizedBox(height: 16.h),
              Text(
                'By using SportConnect, you consent to the data processing described above and in our Privacy Policy.',
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
          Icon(icon, color: AppColors.primary, size: 20.sp),
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
      barrierLabel: AppLocalizations.of(context).withdrawConsent,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          AppLocalizations.of(context).withdrawConsent,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).withdrawConsentDescription,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _buildConsentInfoItem(
              'Disable Location',
              'Turn off location in Privacy & Safety settings.',
              Icons.location_off_outlined,
            ),
            _buildConsentInfoItem(
              'Export Data',
              'Request a copy of all your personal data.',
              Icons.download_outlined,
            ),
            _buildConsentInfoItem(
              'Delete Account',
              'Permanently delete your account and all data.',
              Icons.delete_forever_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).actionClose,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsLogout,
      builder: (context) => AlertDialog.adaptive(
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
    String confirmText = '';
    showDialog(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsDeleteAccount,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).settingsDeleteAccount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).typeDeleteToConfirm,
                    hintText: AppLocalizations.of(context).deleteKeyword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: (v) => setDialogState(() => confirmText = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: Text(AppLocalizations.of(context).actionCancel),
            ),
            ElevatedButton(
              onPressed:
                  confirmText == AppLocalizations.of(context).deleteKeyword
                  ? () async {
                      dialogContext.pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                      try {
                        await ref
                            .read(authActionsViewModelProvider)
                            .deleteAccount();
                        if (context.mounted) context.pop();
                      } on AuthException catch (e) {
                        if (context.mounted) {
                          context.pop();
                          if (e.code == 'requires-recent-login') {
                            final ok = await showReauthDialog(context, ref);
                            if (!ok || !context.mounted) return;
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                            try {
                              await ref
                                  .read(authActionsViewModelProvider)
                                  .deleteAccount();
                              if (context.mounted) context.pop();
                            } catch (retryErr) {
                              if (context.mounted) {
                                context.pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).failedToDeleteAccountValue(retryErr),
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                            return;
                          }
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
                      } catch (e) {
                        if (context.mounted) {
                          context.pop();
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
          Icon(Icons.close_rounded, color: AppColors.error, size: 15.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockedUsersScreen extends ConsumerStatefulWidget {
  const _BlockedUsersScreen();

  @override
  ConsumerState<_BlockedUsersScreen> createState() =>
      _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<_BlockedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.borderLight,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        title: Text(
          l10n.settingsBlockedUsers,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: blockedUsersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              l10n.failedToLoadChats,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block_outlined,
                      size: 56.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.noBlockedUsers,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.usersYouBlockWillAppear,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final normalizedQuery = _query.trim().toLowerCase();
          final filteredUsers = blockedUsers
              .where((user) {
                if (normalizedQuery.isEmpty) return true;
                return user.displayName.toLowerCase().contains(
                      normalizedQuery,
                    ) ||
                    user.email.toLowerCase().contains(normalizedQuery) ||
                    user.uid.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchUsers,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.clearSearchTooltip,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noResultsFound2,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: () async {
                          ref.invalidate(blockedUsersProvider);
                          ref.invalidate(currentUserProvider);
                          await Future<void>.delayed(
                            const Duration(milliseconds: 250),
                          );
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final displayName = user.displayName.isNotEmpty
                                ? user.displayName
                                : user.uid;

                            return Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  user.photoUrl != null
                                      ? CircleAvatar(
                                          radius: 20.r,
                                          backgroundImage: NetworkImage(
                                            user.photoUrl!,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: AppColors.primary
                                              .withValues(alpha: 0.14),
                                          child: Text(
                                            displayName[0].toUpperCase(),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (user.email.isNotEmpty)
                                          Text(
                                            user.email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final shouldUnblock =
                                          await showDialog<bool>(
                                            context: context,
                                            barrierLabel: l10n.unblockUser,
                                            builder: (dialogContext) =>
                                                AlertDialog.adaptive(
                                                  title: Text(l10n.unblockUser),
                                                  content: Text(
                                                    l10n.unblockUserDialogMessage(
                                                      displayName,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          dialogContext.pop(
                                                            false,
                                                          ),
                                                      child: Text(
                                                        l10n.actionCancel,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          dialogContext.pop(
                                                            true,
                                                          ),
                                                      child: Text(
                                                        l10n.actionUnblock,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ) ??
                                          false;

                                      if (!shouldUnblock) return;

                                      try {
                                        await ref
                                            .read(
                                              profileActionsViewModelProvider,
                                            )
                                            .unblockCurrentUser(user.uid);
                                        ref.invalidate(blockedUsersProvider);
                                        ref.invalidate(currentUserProvider);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.userUnblocked),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      } catch (_) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.couldNotUnblockUserTryAgain,
                                            ),
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(l10n.actionUnblock),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
