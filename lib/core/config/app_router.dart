import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/page_transitions.dart'
    hide NoTransitionPage;
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/core/config/routes/ride_routes.dart';
import 'package:sport_connect/core/config/routes/profile_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/core/services/route_guard_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/main_wrapper.dart';
import 'package:sport_connect/features/auth/models/models.dart';

// Feature imports - Auth
import 'package:sport_connect/features/auth/views/login_screen.dart';
import 'package:sport_connect/features/auth/views/signup_wizard_screen.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/features/auth/views/role_selection_screen.dart';
import 'package:sport_connect/features/auth/views/driver_onboarding_screen.dart';
import 'package:sport_connect/features/auth/views/rider_onboarding_screen.dart';
import 'package:sport_connect/features/auth/views/forgot_password_screen.dart';
import 'package:sport_connect/features/auth/views/email_verification_screen.dart';
import 'package:sport_connect/features/auth/views/change_password_screen.dart';
import 'package:sport_connect/features/auth/views/phone_otp_screen.dart';
import 'package:sport_connect/features/events/views/create_event_screen.dart';

// Feature imports - Home
import 'package:sport_connect/features/home/views/home_screen.dart';
import 'package:sport_connect/features/home/views/driver/driver_home_screen.dart';

// Feature imports - Profile (used in StatefulShellRoute)
import 'package:sport_connect/features/profile/views/profile_screen.dart';

// Feature imports - Messaging
import 'package:sport_connect/features/messaging/views/chat_list_screen.dart';
import 'package:sport_connect/features/messaging/views/chat_detail_screen.dart';

// Feature imports - Rides (used in StatefulShellRoute)
import 'package:sport_connect/features/rides/views/passenger/rider_request_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_my_rides_screen.dart';

// Feature imports - Reviews
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/views/submit_review_screen.dart';
import 'package:sport_connect/features/reviews/views/reviews_list_screen.dart';

// Feature imports - Other
import 'package:sport_connect/features/legal/views/legal_screen.dart';
import 'package:sport_connect/features/onboarding/views/onboarding_screen.dart';
import 'package:sport_connect/features/payments/views/driver_earnings_screen.dart';

import 'package:sport_connect/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Main router provider with centralized redirect logic
@riverpod
GoRouter appRouter(Ref ref) {
  // Use ref.listen (NOT ref.watch) to avoid full router disposal/recreation
  // on every auth state change. The refreshListenable triggers redirect
  // re-evaluation without rebuilding the entire GoRouter instance.
  //
  // ChangeNotifier.notifyListeners() is used instead of a boolean toggle to
  // prevent rapid successive emissions from cancelling each other out.
  final routerListenable = _AuthChangeNotifier();
  ref.listen(currentUserProvider, (previous, next) {
    routerListenable.notify();
  });
  // Also listen to raw Firebase auth state so email-verification changes
  // (which don't affect the Firestore UserModel) still trigger a redirect.
  ref.listen(authStateProvider, (previous, next) {
    routerListenable.notify();
  });
  ref.onDispose(routerListenable.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    refreshListenable: routerListenable,
    observers: [AnalyticsService.instance.navigatorObserver],
    redirect: (context, state) {
      // Read current user state at redirect time
      final userState = ref.read(currentUserProvider);
      final firebaseUser = FirebaseAuth.instance.currentUser;
      return _handleRedirect(
        userState,
        state,
        isEmailVerified: firebaseUser?.emailVerified ?? false,
      );
    },
    routes: _buildRoutes(),
    errorBuilder: _buildErrorPage,
  );
}

/// Centralized redirect handler using RouteGuardService
String? _handleRedirect(
  AsyncValue<UserModel?> userState,
  GoRouterState state, {
  bool isEmailVerified = false,
}) {
  final guard = RouteGuardService.fromAuthState(
    userState,
    isEmailVerified: isEmailVerified,
  );
  return guard.getRedirect(state.uri.path);
}

/// Modular route configurations
final _rideRoutes = RideRoutes();
final _profileRoutes = ProfileRoutes();

/// Build all application routes using modular route configurations
List<RouteBase> _buildRoutes() {
  return [
    // Auth & Onboarding Routes (Full Screen)
    ..._buildAuthRoutes(),

    // Legal Routes (public – accessible without authentication)
    ..._buildLegalRoutes(),

    // Main App Shell with Bottom Navigation
    _buildMainShell(),

    // Modular Routes from routes/ folder
    ..._rideRoutes.getRoutes().cast<GoRoute>(),

    // Chat Routes (require complex extra parameters - keep inline)
    ..._buildChatRoutes(),

    // Profile Sub-Routes from modular config
    ..._profileRoutes.getRoutes().cast<GoRoute>(),

    // Review Routes
    ..._buildReviewRoutes(),

    GoRoute(
      path: '/events/create',
      name: 'createEvent',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const CreateEventScreen(),
      ),
    ),
  ];
}

// =============================================================================
// 🔐 AUTH & ONBOARDING ROUTES
// =============================================================================
List<GoRoute> _buildAuthRoutes() {
  return [
    GoRoute(
      path: AppRoutes.splash.path,
      name: AppRoutes.splash.name,
      pageBuilder: (context, state) =>
          FadeTransitionPage(key: state.pageKey, child: const SplashScreen()),
    ),
    GoRoute(
      path: AppRoutes.onboarding.path,
      name: AppRoutes.onboarding.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.login.path,
      name: AppRoutes.login.name,
      pageBuilder: (context, state) =>
          FadeTransitionPage(key: state.pageKey, child: const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.signupWizard.path,
      name: AppRoutes.signupWizard.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const SignupWizardScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.roleSelection.path,
      name: AppRoutes.roleSelection.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.driverOnboarding.path,
      name: AppRoutes.driverOnboarding.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const DriverOnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.riderOnboarding.path,
      name: AppRoutes.riderOnboarding.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const RiderOnboardingScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword.path,
      name: AppRoutes.forgotPassword.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.emailVerification.path,
      name: AppRoutes.emailVerification.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const EmailVerificationScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.changePassword.path,
      name: AppRoutes.changePassword.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const ChangePasswordScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.phoneOtp.path,
      name: AppRoutes.phoneOtp.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const PhoneOtpScreen(),
      ),
    ),
  ];
}

// =============================================================================
// ⚖️ LEGAL ROUTES (Terms of Service & Privacy Policy – no auth required)
// =============================================================================
List<GoRoute> _buildLegalRoutes() {
  return [
    GoRoute(
      path: AppRoutes.terms.path,
      name: AppRoutes.terms.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const LegalScreen(type: LegalDocumentType.terms),
      ),
    ),
    GoRoute(
      path: AppRoutes.privacy.path,
      name: AppRoutes.privacy.name,
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const LegalScreen(type: LegalDocumentType.privacy),
      ),
    ),
  ];
}

// =============================================================================
// 🏠 MAIN APP SHELL (Bottom Navigation)
// =============================================================================
StatefulShellRoute _buildMainShell() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MainWrapper(navigationShell: navigationShell);
    },
    branches: [
      // RIDER BRANCHES (Indices 0-4)
      ..._buildRiderBranches(),

      // DRIVER BRANCHES (Indices 5-9)
      ..._buildDriverBranches(),
    ],
  );
}

List<StatefulShellBranch> _buildRiderBranches() {
  return [
    // [0] Explore (Home)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.home.path,
          name: AppRoutes.home.name,
          pageBuilder: (context, state) =>
              FadeTransitionPage(key: state.pageKey, child: const HomeScreen()),
        ),
      ],
    ),

    // [1] Activity (My Rides)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.riderMyRides.path,
          name: AppRoutes.riderMyRides.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RiderMyRidesScreen()),
        ),
      ],
    ),

    // [2] Request (Middle Tab - Action)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.riderRequestRide.path,
          name: AppRoutes.riderRequestRide.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RiderRequestRideScreen()),
        ),
      ],
    ),

    // [3] Chat (Messages)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.chat.path,
          name: AppRoutes.chat.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChatListScreen()),
        ),
      ],
    ),

    // [4] Profile
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.profile.path,
          name: AppRoutes.profile.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ];
}

List<StatefulShellBranch> _buildDriverBranches() {
  return [
    // [5] Dashboard (Home)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverHome.path,
          name: AppRoutes.driverHome.name,
          pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey,
            child: const DriverHomeScreen(),
          ),
        ),
      ],
    ),

    // [6] Schedule (Rides)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverRides.path,
          name: AppRoutes.driverRides.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverMyRidesScreen()),
        ),
      ],
    ),

    // [7] Earnings
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverEarnings.path,
          name: AppRoutes.driverEarnings.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DriverEarningsScreen()),
        ),
      ],
    ),

    // [8] Inbox (Chat)
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverChat.path,
          name: AppRoutes.driverChat.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChatListScreen()),
        ),
      ],
    ),

    // [9] Profile
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverProfileTab.path,
          name: AppRoutes.driverProfileTab.name,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ];
}

// =============================================================================
// � CHAT ROUTES (Requires complex extra parameters - keep inline)
// =============================================================================
List<GoRoute> _buildChatRoutes() {
  return [
    GoRoute(
      path: AppRoutes.chatDetail.path,
      name: AppRoutes.chatDetail.name,
      pageBuilder: (context, state) {
        final chatId = state.params.getStringOrThrow('id');
        final receiver = state.params.getExtraOrThrow<UserModel>();
        return SlideRightTransitionPage(
          key: state.pageKey,
          child: ChatDetailScreen(chatId: chatId, receiver: receiver),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chatGroup.path,
      name: AppRoutes.chatGroup.name,
      pageBuilder: (context, state) {
        final groupId = state.params.getStringOrThrow('id');
        final receiver = state.params.getExtraOrThrow<UserModel>();
        return SlideRightTransitionPage(
          key: state.pageKey,
          child: ChatDetailScreen(
            chatId: groupId,
            receiver: receiver,
            isGroup: true,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.chatRide.path,
      name: AppRoutes.chatRide.name,
      pageBuilder: (context, state) {
        final rideId = state.params.getStringOrThrow('id');
        final receiver = state.params.getExtraOrThrow<UserModel>();
        return SlideRightTransitionPage(
          key: state.pageKey,
          child: ChatDetailScreen(
            chatId: rideId,
            receiver: receiver,
            isGroup: true,
          ),
        );
      },
    ),
  ];
}

// =============================================================================
// ⭐ REVIEW ROUTES
// =============================================================================
List<GoRoute> _buildReviewRoutes() {
  return [
    GoRoute(
      path: AppRoutes.submitReview.path,
      name: AppRoutes.submitReview.name,
      pageBuilder: (context, state) {
        final params = state.params;
        final rideId = params.getQueryOrDefault('rideId', '');
        final revieweeId = params.getQueryOrDefault('revieweeId', '');
        final revieweeName = params.getQueryOrDefault('revieweeName', 'User');
        final revieweePhotoUrl = params.getQuery('revieweePhotoUrl');
        final reviewTypeStr = params.getQueryOrDefault(
          'reviewType',
          'driverReview',
        );
        final reviewType = reviewTypeStr == 'passengerReview'
            ? ReviewType.rider
            : ReviewType.driver;

        return SlideUpTransitionPage(
          key: state.pageKey,
          child: SubmitReviewScreen(
            rideId: rideId,
            revieweeId: revieweeId,
            revieweeName: revieweeName,
            revieweePhotoUrl: revieweePhotoUrl,
            reviewType: reviewType,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reviewsList.path,
      name: AppRoutes.reviewsList.name,
      pageBuilder: (context, state) {
        final params = state.params;
        final userId = params.getStringOrThrow('userId');
        final userName = params.getQueryOrDefault('userName', 'User');
        final userPhotoUrl = params.getQuery('userPhotoUrl');

        return SlideRightTransitionPage(
          key: state.pageKey,
          child: ReviewsListScreen(
            userId: userId,
            userName: userName,
            userPhotoUrl: userPhotoUrl,
          ),
        );
      },
    ),
  ];
}

// �🔔 ROUTER REFRESH LISTENABLE
// =============================================================================

/// A simple ChangeNotifier that forwards auth state changes to the GoRouter
/// refresh listener. Using ChangeNotifier.notifyListeners() is safer than a
/// boolean toggle, which can silently cancel out if two emissions arrive in
/// the same frame (true → false → true evaluates as no change).
class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

// =============================================================================
// ❌ ERROR PAGE
// =============================================================================
Widget _buildErrorPage(BuildContext context, GoRouterState state) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).pageNotFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.error?.toString() ?? 'Unknown error',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home.path),
            child: Text(AppLocalizations.of(context).goHome),
          ),
        ],
      ),
    ),
  );
}
