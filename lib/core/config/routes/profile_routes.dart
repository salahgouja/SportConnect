import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/core/config/page_transitions.dart';
import 'package:sport_connect/features/profile/views/user_search_screen.dart';
import 'package:sport_connect/features/profile/views/profile_screen.dart';
import 'package:sport_connect/features/profile/views/settings_screen.dart';
import 'package:sport_connect/features/profile/views/edit_profile_screen.dart';
import 'package:sport_connect/features/profile/views/achievements_screen.dart';
import 'package:sport_connect/features/vehicles/views/vehicle_management_screen.dart';
import 'package:sport_connect/features/profile/views/driver_documents_screen.dart';
import 'package:sport_connect/features/profile/views/tax_documents_screen.dart';
import 'package:sport_connect/features/profile/views/background_check_screen.dart';
import 'package:sport_connect/features/profile/views/two_factor_auth_screen.dart';
import 'package:sport_connect/features/profile/views/help_center_screen.dart';
import 'package:sport_connect/features/profile/views/contact_support_screen.dart';
import 'package:sport_connect/features/profile/views/report_issue_screen.dart';
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
          child: const UserSearchScreen(),
        ),
      ),

      // View any user's public profile by ID
      GoRoute(
        path: AppRoutes.userProfile.path,
        name: AppRoutes.userProfile.name,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['id']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(userId: userId),
          );
        },
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
          child: const VehicleManagementScreen(),
        ),
      ),

      // Deep-link to another driver's public profile (uses ProfileScreen with userId)
      GoRoute(
        path: AppRoutes.driverProfile.path,
        name: AppRoutes.driverProfile.name,
        pageBuilder: (context, state) {
          final userId = state.pathParameters['id']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(userId: userId),
          );
        },
      ),

      // Driver Documents
      GoRoute(
        path: AppRoutes.driverDocuments.path,
        name: AppRoutes.driverDocuments.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverDocumentsScreen(),
        ),
      ),

      // Tax Documents
      GoRoute(
        path: AppRoutes.taxDocuments.path,
        name: AppRoutes.taxDocuments.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const TaxDocumentsScreen(),
        ),
      ),

      // Background Check
      GoRoute(
        path: AppRoutes.backgroundCheck.path,
        name: AppRoutes.backgroundCheck.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const BackgroundCheckScreen(),
        ),
      ),

      // Two-Factor Authentication
      GoRoute(
        path: AppRoutes.twoFactorAuth.path,
        name: AppRoutes.twoFactorAuth.name,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const TwoFactorAuthScreen(),
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
