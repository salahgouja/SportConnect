import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/views/reauth_dialog.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _driverSectionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsViewModelProvider);
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);
    final currentLocale = settings.locale ?? Localizations.localeOf(context);

    final isDriver = ref.watch(
      currentUserProvider.select(
        (value) => value.value?.role == UserRole.driver,
      ),
    );
    final premiumMeta = ref.watch(premiumMetadataProvider);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        title: l10n.settingsTitle,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          if (isDriver) ...[
            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.driverSettings,
              Icons.drive_eta_rounded,
              color: AppColors.secondary,
            ),
            SizedBox(height: 12.h),
            _buildDriverCard(
              l10n: l10n,
              settings: settings,
              settingsViewModel: settingsViewModel,
            ),
          ],

          SizedBox(height: 32.h),
          _buildSectionHeader(
            'Premium',
            Icons.workspace_premium_rounded,
            color: AppColors.warning,
          ),
          SizedBox(height: 12.h),
          premiumMeta.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (meta) => meta.isPremium
                ? _buildActivePremiumCard(meta)
                : _buildCard([
                    _buildNavTile(
                      title: 'Upgrade to Premium',
                      subtitle: 'Unlock smart matching, priority rides & more',
                      icon: Icons.workspace_premium_rounded,
                      onTap: () => context.push(AppRoutes.premiumSubscribe.path),
                      color: AppColors.warning,
                    ),
                  ]),
          ),

          SizedBox(height: 32.h),
          _buildSectionHeader(l10n.settingsNotifications, Icons.tune_rounded),
          SizedBox(height: 12.h),
          _buildCard([
            _buildSwitchTile(
              title: l10n.settingsPushNotifications,
              subtitle: l10n.settingsPushNotificationsDesc,
              value: settings.notificationsEnabled,
              icon: Icons.notifications_outlined,
              onChanged: settingsViewModel.setNotificationsEnabled,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsRideReminders,
              subtitle: l10n.settingsRideRemindersDesc,
              value: settings.rideReminders,
              icon: Icons.alarm_outlined,
              enabled: settings.notificationsEnabled,
              onChanged: settingsViewModel.setRideReminders,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsChatMessages,
              subtitle: l10n.settingsChatMessagesDesc,
              value: settings.chatNotifications,
              icon: Icons.chat_bubble_outline_rounded,
              enabled: settings.notificationsEnabled,
              onChanged: settingsViewModel.setChatNotifications,
            ),
            _buildDivider(),
            _buildNavTile(
              title: 'Notification Permission',
              subtitle: 'Re-allow push notifications for this device',
              icon: Icons.notifications_none_rounded,
              onTap: () => _resetAndRequestNotificationPermission(context),
            ),
          ]),

          SizedBox(height: 32.h),
          _buildSectionHeader(l10n.settingsAppearance, Icons.palette_outlined),
          SizedBox(height: 12.h),
          _buildCard([
            _buildMapStyleTile(
              currentStyle: settings.mapStyle,
              onChanged: settingsViewModel.setMapStyle,
            ),
            _buildDivider(),
            _buildLanguageTile(
              l10n: l10n,
              currentLocale: currentLocale,
              onChanged: (code) async {
                if (code == null) return;

                await settingsViewModel.setLanguage(code);
              },
            ),
          ]),

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
              value: settings.publicProfile,
              icon: Icons.person_outline_rounded,
              onChanged: settingsViewModel.setPublicProfile,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsShowLocation,
              subtitle: l10n.settingsShowLocationDesc,
              value: settings.showLocation,
              icon: Icons.location_on_outlined,
              onChanged: settingsViewModel.setShowLocation,
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.settingsBlockedUsers,
              subtitle: l10n.settingsBlockedUsersDesc,
              icon: Icons.block_outlined,
              onTap: _openBlockedUsersScreen,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: 'Analytics & Crash Reports',
              subtitle: 'Allow anonymous usage data and crash reports',
              value: settings.analyticsEnabled,
              icon: Icons.analytics_outlined,
              onChanged: (v) =>
                  settingsViewModel.setAnalyticsEnabled(enabled: v),
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
              onTap: () => context.push(AppRoutes.managePaymentMethods.path),
            ),
            _buildDivider(),
            _buildNavTile(
              title: l10n.paymentHistory,
              subtitle: 'View your past rides and charges',
              icon: Icons.receipt_long_rounded,
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

          SizedBox(height: 48.h),
          _buildFooter(l10n),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildDriverCard({
    required AppLocalizations l10n,
    required SettingsState settings,
    required SettingsViewModel settingsViewModel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          Icons.local_taxi_rounded,
                          color: AppColors.secondary,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.driverSettings,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Manage booking, pickup radius, payout, and map visibility',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                height: 1.25,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: AnimatedRotation(
                          turns: _driverSectionExpanded ? 0.5 : 0,
                          duration: 200.ms,
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDriverStatusPill(
                          icon: Icons.bolt_rounded,
                          label: 'Booking',
                          value: settings.driverAllowInstantBooking
                              ? 'Instant'
                              : 'Manual',
                          active: settings.driverAllowInstantBooking,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildDriverStatusPill(
                          icon: Icons.social_distance_rounded,
                          label: 'Radius',
                          value: '${settings.driverMaxDistance.round()} mi',
                          active: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: 240.ms,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: _driverSectionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.55),
                  ),
                ),
                SizedBox(height: 8.h),

                _buildDriverPreferenceGroup(
                  title: l10n.ridePreferences,
                  icon: Icons.route_rounded,
                  children: [
                    _buildSwitchTile(
                      title: l10n.allowInstantBooking,
                      subtitle: l10n.letPassengersBookWithoutWaiting,
                      value: settings.driverAllowInstantBooking,
                      icon: Icons.bolt_outlined,
                      onChanged: settingsViewModel.setDriverAllowInstantBooking,
                    ),
                    _buildDivider(),
                    _buildSliderTile(
                      title: l10n.maximumPickupDistance,
                      subtitle: l10n.onlyReceiveRequestsWithinThis,
                      icon: Icons.social_distance_outlined,
                      value: settings.driverMaxDistance,
                      onChanged: settingsViewModel.setDriverMaxDistance,
                      min: 5,
                      max: 50,
                      suffix: 'mi',
                    ),
                  ],
                ),

                _buildDriverPreferenceGroup(
                  title: l10n.paymentSettings,
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _buildNavTile(
                      title: l10n.payoutMethod,
                      subtitle: l10n.bankAccountEndingIn4532,
                      icon: Icons.account_balance_outlined,
                      onTap: () => context.pushNamed(
                        AppRoutes.driverStripeOnboarding.name,
                        queryParameters: {
                          'mode': 'manage',
                          'returnTo': AppRoutes.driverEarnings.name,
                        },
                      ),
                    ),
                  ],
                ),

                _buildDriverPreferenceGroup(
                  title: l10n.navigationMap,
                  icon: Icons.map_outlined,
                  children: [
                    _buildSwitchTile(
                      title: l10n.showOnDriverMap,
                      subtitle: l10n.allowPassengersToSeeYour,
                      value: settings.driverShowOnMap,
                      icon: Icons.visibility_outlined,
                      onChanged: settingsViewModel.setDriverShowOnMap,
                    ),
                    _buildDivider(),
                    _buildDropdownTile(
                      title: l10n.preferredNavigationApp,
                      icon: Icons.navigation_outlined,
                      value: settings.driverNavigationApp,
                      options: const [
                        'In-App',
                        'Google Maps',
                        'Waze',
                        'Apple Maps',
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        settingsViewModel.setDriverNavigationApp(v);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusPill({
    required IconData icon,
    required String label,
    required String value,
    required bool active,
  }) {
    final color = active ? AppColors.secondary : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.10 : 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.18 : 0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverPreferenceGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

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
            AdaptiveSwitch(
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
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
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
          AdaptiveSlider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    String? subtitle,
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
                if (v == null) return;

                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Future<void> _resetAndRequestNotificationPermission(
    BuildContext context,
  ) async {
    final pns = ref.read(pushNotificationServiceProvider);
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);

    await settingsViewModel.setNotificationDialogShown(value: false);

    final hasPermission = await pns.hasPermission();

    if (!context.mounted) return;

    if (hasPermission) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).notificationsAlreadyEnabled,
        type: AdaptiveSnackBarType.success,
      );
      return;
    }

    final accepted = await PermissionDialogHelper.showNotificationRationale(
      context,
    );

    if (!context.mounted) return;

    await settingsViewModel.setNotificationDialogShown();

    if (!accepted) return;

    await pns.requestPermission();

    if (!context.mounted) return;

    AdaptiveSnackBar.show(
      context,
      message: AppLocalizations.of(context).notificationPermissionRequested,
      type: AdaptiveSnackBarType.success,
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
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).downloadMyData,
      maxHeightFactor: 0.72,
      child: Container(
        padding: EdgeInsets.all(24.w),
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
                AdaptiveSnackBar.show(
                  context,
                  message: AppLocalizations.of(
                    context,
                  ).dataExportRequestSubmitted,
                  type: AdaptiveSnackBarType.success,
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
    AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).dataProcessingNotice,
      forceMaxHeight: true,
      maxHeightFactor: 0.86,
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: ListView(
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
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).withdrawConsent,
      builder: (dialogContext) => AlertDialog.adaptive(
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
            onPressed: () => dialogContext.pop(),
            child: Text(
              AppLocalizations.of(dialogContext).actionClose,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsLogout,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          AppLocalizations.of(dialogContext).settingsLogout,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(dialogContext).areYouSureYouWant5,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(dialogContext).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();

              await ref.read(authActionsViewModelProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(dialogContext).settingsLogout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    var confirmText = '';

    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsDeleteAccount,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContentContext, setDialogState) => AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).settingsDeleteAccount,
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
                  AppLocalizations.of(
                    dialogContentContext,
                  ).thisActionCannotBeUndone2,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).rideHistoryAndBookings,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).profileAndAchievements,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).messagesAndConnections,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).paymentInformation,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).typeDeleteToConfirm,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      dialogContentContext,
                    ).typeDeleteToConfirm,
                    hintText: AppLocalizations.of(
                      dialogContentContext,
                    ).deleteKeyword,
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
              child: Text(
                AppLocalizations.of(dialogContentContext).actionCancel,
              ),
            ),
            ElevatedButton(
              onPressed:
                  confirmText ==
                      AppLocalizations.of(
                        dialogContentContext,
                      ).deleteKeyword
                  ? () async {
                      dialogContext.pop();

                      if (!context.mounted) return;

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );

                      try {
                        await ref
                            .read(authActionsViewModelProvider.notifier)
                            .deleteAccount();

                        if (!context.mounted) return;

                        context.pop();
                      } on AuthException catch (e) {
                        if (!context.mounted) return;

                        context.pop();

                        if (e.code == 'requires-recent-login') {
                          final ok = await showReauthDialog(context, ref);

                          if (!ok || !context.mounted) return;

                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );

                          try {
                            await ref
                                .read(
                                  authActionsViewModelProvider.notifier,
                                )
                                .deleteAccount();

                            if (!context.mounted) return;

                            context.pop();
                          } catch (error) {
                            if (!context.mounted) return;

                            context.pop();

                            AdaptiveSnackBar.show(
                              context,
                              message: AppLocalizations.of(
                                context,
                              ).failedToDeleteAccountValue(error),
                              type: AdaptiveSnackBarType.error,
                            );
                          }

                          return;
                        }

                        AdaptiveSnackBar.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          ).failedToDeleteAccountValue(e),
                          type: AdaptiveSnackBarType.error,
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        context.pop();

                        AdaptiveSnackBar.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          ).failedToDeleteAccountValue(e),
                          type: AdaptiveSnackBarType.error,
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
              ),
              child: Text(
                AppLocalizations.of(dialogContentContext).settingsDeleteAccount,
              ),
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

  Widget _buildActivePremiumCard(PremiumMetadata meta) {
    final planLabel = switch (meta.plan) {
      'monthly' => 'Monthly',
      'yearly' => 'Yearly',
      _ => 'Premium',
    };
    final dateLabel = meta.updatedAt != null
        ? DateFormat('MMM d, yyyy').format(meta.updatedAt!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.warning,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SportConnect Premium',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (dateLabel != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          'Active since $dateLabel',
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    planLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.warning.withValues(alpha: 0.2)),
          _buildNavTile(
            title: 'Manage Subscription',
            subtitle: 'Cancel or change your plan in the store',
            icon: Icons.subscriptions,
            onTap: _manageSubscription,
          ),
          _buildDivider(),
          _buildNavTile(
            title: 'Restore Purchases',
            subtitle: 'Re-apply your active subscription',
            icon: Icons.restore_rounded,
            onTap: _restorePurchases,
          ),
        ],
      ),
    );
  }

  Future<void> _manageSubscription() async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: 'Could not open subscription management.',
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _restorePurchases() async {
    final result =
        await ref.read(premiumIapServiceProvider.notifier).restorePurchases();
    if (!mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: result.isSuccess
          ? 'Purchases restored successfully.'
          : (result.errorMessage ?? 'Could not restore purchases.'),
      type: result.isSuccess
          ? AdaptiveSnackBarType.success
          : AdaptiveSnackBarType.error,
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

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        title: l10n.settingsBlockedUsers,
      ),
      body: blockedUsersAsync.when(
        loading: () =>
            const SkeletonLoader(type: SkeletonType.profileCard, itemCount: 4),
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

                return user.username.toLowerCase().contains(
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
                            final displayName = user.username.isNotEmpty
                                ? user.username
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
                                  if (user.photoUrl != null)
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundImage: NetworkImage(
                                        user.photoUrl!,
                                      ),
                                    )
                                  else
                                    CircleAvatar(
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

                                      if (!context.mounted) return;
                                      if (!shouldUnblock) return;

                                      try {
                                        await ref
                                            .read(
                                              profileActionsViewModelProvider
                                                  .notifier,
                                            )
                                            .unblockCurrentUser(user.uid);

                                        if (!context.mounted) return;

                                        ref.invalidate(blockedUsersProvider);
                                        ref.invalidate(currentUserProvider);

                                        AdaptiveSnackBar.show(
                                          context,
                                          message: l10n.userUnblocked,
                                          type: AdaptiveSnackBarType.success,
                                        );
                                      } catch (_) {
                                        if (!context.mounted) return;

                                        AdaptiveSnackBar.show(
                                          context,
                                          message:
                                              l10n.couldNotUnblockUserTryAgain,
                                          type: AdaptiveSnackBarType.error,
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
