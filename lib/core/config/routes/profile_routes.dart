import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/core/config/page_transitions.dart';
import 'package:sport_connect/features/profile/views/profile_search_screen.dart';
import 'package:sport_connect/features/profile/views/settings_screen.dart';
import 'package:sport_connect/features/profile/views/edit_profile_screen.dart';
import 'package:sport_connect/features/profile/views/achievements_screen.dart';
import 'package:sport_connect/features/profile/views/driver_vehicle_screen.dart';
import 'package:sport_connect/features/profile/views/driver_profile_screen.dart';
import 'package:sport_connect/features/profile/views/driver_settings_screen.dart';
import 'package:sport_connect/features/profile/views/help_center_screen.dart';
import 'package:sport_connect/features/profile/views/contact_support_screen.dart';
import 'package:sport_connect/features/profile/views/report_issue_screen.dart';
import 'package:sport_connect/features/profile/views/terms_privacy_screen.dart';
import 'package:sport_connect/features/profile/views/about_screen.dart';
import 'package:sport_connect/features/notifications/views/notifications_screen.dart';
import 'package:sport_connect/features/payments/views/payment_history_screen.dart';
import 'package:sport_connect/features/payments/views/driver_stripe_onboarding_screen.dart';
import 'package:sport_connect/features/payments/views/payout_detail_screen.dart';

/// Profile and related features module routes
class ProfileRoutes implements RouteConfig {
  @override
  String get moduleName => 'profile';

  @override
  String? get initialRoute => AppRoutes.profile.path;

  @override
  List<RouteBase> getRoutes() {
    return [
      // NOTE: Main profile route is defined as a StatefulShellBranch
      // in app_router.dart for bottom navigation tabs. Don't duplicate here.

      // Profile Search
      GoRoute(
        path: AppRoutes.profileSearch.path,
        name: AppRoutes.profileSearch.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const ProfileSearchScreen(),
        ),
      ),

      // Edit Profile
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings.path,
        name: AppRoutes.settings.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),

      // Achievements
      GoRoute(
        path: AppRoutes.achievements.path,
        name: AppRoutes.achievements.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const AchievementsScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications.path,
        name: AppRoutes.notifications.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // Payment History
      GoRoute(
        path: AppRoutes.paymentHistory.path,
        name: AppRoutes.paymentHistory.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const PaymentHistoryScreen(),
        ),
      ),

      // Driver Specific Routes
      GoRoute(
        path: AppRoutes.driverVehicles.path,
        name: AppRoutes.driverVehicles.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverVehicleScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.vehicles.path,
        name: AppRoutes.vehicles.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverVehicleScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.driverSettings.path,
        name: AppRoutes.driverSettings.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverSettingsScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.driverProfile.path,
        name: AppRoutes.driverProfile.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverProfileScreen(),
        ),
      ),

      // NOTE: driverEarnings is defined as a StatefulShellBranch in app_router.dart
      // for bottom navigation tabs. Don't duplicate here.
      GoRoute(
        path: AppRoutes.driverStripeOnboarding.path,
        name: AppRoutes.driverStripeOnboarding.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const DriverStripeOnboardingScreen(),
        ),
      ),

      // Help Center
      GoRoute(
        path: AppRoutes.helpCenter.path,
        name: AppRoutes.helpCenter.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const HelpCenterScreen(),
        ),
      ),

      // Contact Support
      GoRoute(
        path: AppRoutes.contactSupport.path,
        name: AppRoutes.contactSupport.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const ContactSupportScreen(),
        ),
      ),

      // Report Issue
      GoRoute(
        path: AppRoutes.reportIssue.path,
        name: AppRoutes.reportIssue.name,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const ReportIssueScreen(),
        ),
      ),

      // Terms & Privacy
      GoRoute(
        path: AppRoutes.termsPrivacy.path,
        name: AppRoutes.termsPrivacy.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final type = params.getStringOrThrow('type');
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: TermsPrivacyScreen(type: type),
          );
        },
      ),

      // About
      GoRoute(
        path: AppRoutes.about.path,
        name: AppRoutes.about.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const AboutScreen(),
        ),
      ),

      // Payout Detail
      GoRoute(
        path: AppRoutes.payoutDetail.path,
        name: AppRoutes.payoutDetail.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final payoutId = params.getStringOrThrow('id');
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: PayoutDetailScreen(payoutId: payoutId),
          );
        },
      ),
    ];
  }
}
