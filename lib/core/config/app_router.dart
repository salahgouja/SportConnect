import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:sport_connect/core/config/page_transitions.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/auth/views/login_screen_firebase_ui.dart';
import 'package:sport_connect/features/auth/views/register_screen.dart';
import 'package:sport_connect/features/auth/views/signup_wizard_screen.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/features/auth/views/role_selection_screen.dart';
import 'package:sport_connect/features/profile/views/profile_search_screen.dart';
import 'package:sport_connect/features/home/views/home_screen.dart';
import 'package:sport_connect/features/profile/views/profile_screen.dart';
import 'package:sport_connect/features/profile/views/settings_screen.dart';
import 'package:sport_connect/features/profile/views/edit_profile_screen.dart';
import 'package:sport_connect/features/profile/views/achievements_screen.dart';
import 'package:sport_connect/features/profile/views/driver_vehicle_screen.dart';
import 'package:sport_connect/features/messaging/views/chat_list_screen.dart';
import 'package:sport_connect/features/messaging/views/chat_detail_screen.dart';
import 'package:sport_connect/features/messaging/views/voice_call_screen.dart';
import 'package:sport_connect/features/messaging/views/video_call_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_search_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_offer_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_detail_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/active_ride_screen.dart'
    as passenger_active;
import 'package:sport_connect/features/rides/views/driver/active_ride_screen.dart'
    as driver_active;
import 'package:sport_connect/features/rides/views/passenger/rider_request_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_view_ride_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_view_ride_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_my_rides_screen.dart';
import 'package:sport_connect/features/onboarding/views/onboarding_screen.dart';
import 'package:sport_connect/features/notifications/views/notifications_screen.dart';
import 'package:sport_connect/features/home/views/driver/driver_home_screen.dart';
import 'package:sport_connect/features/payments/views/driver_earnings_screen.dart';
import 'package:sport_connect/features/payments/views/payment_history_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_requests_screen.dart';
import 'package:sport_connect/features/profile/views/driver_profile_screen.dart';
import 'package:sport_connect/features/profile/views/driver_settings_screen.dart';
import 'package:sport_connect/features/payments/views/driver_stripe_onboarding_screen.dart';
import 'package:sport_connect/features/auth/views/driver_onboarding_screen.dart';

/// App router configuration
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String signupWizard = '/signup';
  static const String roleSelection = '/role-selection';
  static const String driverOnboarding = '/driver/onboarding';
  static const String profileSearch = '/profile/search';
  static const String home = '/home';
  static const String driverHome = '/driver';
  static const String driverRides = '/driver/rides';
  static const String driverEarnings = '/driver/earnings';
  static const String driverRequests = '/driver/requests';
  static const String driverProfile = '/driver/profile/:id';
  static const String driverVehicles = '/driver/vehicles';
  static const String driverSettings = '/driver/settings';
  static const String driverStripeOnboarding = '/driver/stripe-onboarding';
  static const String driverActiveRide = '/driver/active-ride';
  static const String riderActiveRide = '/rider/active-ride';
  static const String paymentHistory = '/payment-history';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/detail/:id';
  static const String chatGroup = '/chat/group/:id';
  static const String chatRide = '/chat/ride/:id';
  static const String voiceCall = '/call/voice';
  static const String videoCall = '/call/video';
  static const String incomingVoiceCall = '/call/incoming/voice';
  static const String incomingVideoCall = '/call/incoming/video';
  static const String createRide = '/ride/create';
  static const String rideDetail = '/ride/detail/:id';
  static const String searchRides = '/ride/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String achievements = '/achievements';
  static const String vehicles = '/vehicles';
  // static const String userProfile = '/profile/user';

  // New rider/driver specific routes
  static const String riderRequestRide = '/rider/request';
  static const String riderViewRide = '/rider/ride/:id';
  static const String riderMyRides = '/rider/my-rides';
  static const String driverOfferRide = '/driver/offer';
  static const String driverViewRide = '/driver/ride/:id';
  static const String driverMyRides = '/driver/my-rides';

  /// Helper to build ride detail path with ID
  static String rideDetailPath(String id) => '/ride/detail/$id';

  /// Helper to build chat path with ID
  static String chatPath(String id) => '/chat/$id';

  /// Helper to build user profile path with ID
  static String userProfilePath(String id) => '/profile/user/$id';
  static String driverProfilePath(String id) => '/driver/profile/$id';

  /// Helper to build driver active ride path with ID
  static String driverActiveRidePath(String rideId) =>
      '/driver/active-ride?rideId=$rideId';

  /// Helper to build rider active ride path with ID
  static String riderActiveRidePath(String rideId) =>
      '/rider/active-ride?rideId=$rideId';

  /// Helper to build rider view ride path with ID
  static String riderViewRidePath(String id) => '/rider/ride/$id';

  /// Helper to build driver view ride path with ID
  static String driverViewRidePath(String id) => '/driver/ride/$id';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const LoginScreen()),
      ),

      GoRoute(
        path: register,
        name: 'register',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),

      GoRoute(
        path: signupWizard,
        name: 'signup-wizard',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const SignupWizardScreen(),
        ),
      ),

      GoRoute(
        path: roleSelection,
        name: 'role-selection',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
        ),
      ),

      GoRoute(
        path: driverOnboarding,
        name: 'driver-onboarding',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const DriverOnboardingScreen(),
        ),
      ),

      GoRoute(
        path: profileSearch,
        name: 'profile-search',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const ProfileSearchScreen(),
        ),
      ),

      // Main app routes
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const HomeScreen()),
      ),

      // Driver routes
      GoRoute(
        path: driverHome,
        name: 'driver-home',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const DriverHomeScreen(),
        ),
      ),
      GoRoute(
        path: driverRides,
        name: 'driver-rides',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverMyRidesScreen(),
        ),
      ),
      GoRoute(
        path: driverEarnings,
        name: 'driver-earnings',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverEarningsScreen(),
        ),
      ),
      GoRoute(
        path: driverRequests,
        name: 'driver-requests',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverRequestsScreen(),
        ),
      ),
      GoRoute(
        path: driverProfile,
        name: 'driver-profile',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverProfileScreen(),
        ),
      ),
      GoRoute(
        path: driverVehicles,
        name: 'driver-vehicles',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverVehicleScreen(),
        ),
      ),
      GoRoute(
        path: driverSettings,
        name: 'driver-settings',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverSettingsScreen(),
        ),
      ),
      GoRoute(
        path: driverStripeOnboarding,
        name: 'driver-stripe-onboarding',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const DriverStripeOnboardingScreen(),
        ),
      ),
      // Driver active ride route
      GoRoute(
        path: driverActiveRide,
        name: 'driver-active-ride',
        pageBuilder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'] ?? '';
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: driver_active.ActiveRideScreen(rideId: rideId),
          );
        },
      ),

      // Rider active ride route
      GoRoute(
        path: riderActiveRide,
        name: 'rider-active-ride',
        pageBuilder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'] ?? '';
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: passenger_active.ActiveRideScreen(rideId: rideId),
          );
        },
      ),

      // Payment history route
      GoRoute(
        path: paymentHistory,
        name: 'payment-history',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const PaymentHistoryScreen(),
        ),
      ),

      // Profile routes
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/user/:id',
        name: 'user-profile',
        pageBuilder: (context, state) {
          final userId = state.pathParameters['id']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(userId: userId),
          );
        },
      ),

      // Chat routes
      GoRoute(
        path: chat,
        name: 'chat',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const ChatListScreen(),
        ),
      ),
      GoRoute(
        path: '/chat/detail/:id',
        name: 'chat-detail',
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['id']!;
          final userName = state.uri.queryParameters['name'];
          final userId = state.uri.queryParameters['userId'];
          final photoUrl = state.uri.queryParameters['photoUrl'];
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ChatDetailScreen(
              chatId: chatId,
              receiverName: userName ?? 'Chat',
              receiverId: userId ?? '',
              receiverPhotoUrl: photoUrl,
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat/group/:id',
        name: 'chat-group',
        pageBuilder: (context, state) {
          final groupId = state.pathParameters['id']!;
          final groupName = state.uri.queryParameters['name'];
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ChatDetailScreen(
              chatId: groupId,
              receiverName: groupName ?? 'Group',
              receiverId: '',
              isGroup: true,
            ),
          );
        },
      ),
      GoRoute(
        path: '/chat/ride/:id',
        name: 'chat-ride',
        pageBuilder: (context, state) {
          final rideId = state.pathParameters['id']!;
          final rideName = state.uri.queryParameters['name'];
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: ChatDetailScreen(
              chatId: rideId,
              receiverName: rideName ?? 'Ride',
              receiverId: '',
              isGroup: true,
            ),
          );
        },
      ),
      // Voice/Video call routes
      GoRoute(
        path: voiceCall,
        name: 'voice-call',
        pageBuilder: (context, state) {
          final callId = state.uri.queryParameters['callId']!;
          final chatId = state.uri.queryParameters['chatId']!;
          final receiverName = state.uri.queryParameters['name'] ?? 'User';
          final receiverPhotoUrl = state.uri.queryParameters['photoUrl'];
          final receiverId = state.uri.queryParameters['receiverId'] ?? '';
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: VoiceCallScreen(
              callId: callId,
              chatId: chatId,
              receiverName: receiverName,
              receiverPhotoUrl: receiverPhotoUrl,
              receiverId: receiverId,
            ),
          );
        },
      ),
      GoRoute(
        path: videoCall,
        name: 'video-call',
        pageBuilder: (context, state) {
          final callId = state.uri.queryParameters['callId']!;
          final chatId = state.uri.queryParameters['chatId']!;
          final receiverName = state.uri.queryParameters['name'] ?? 'User';
          final receiverPhotoUrl = state.uri.queryParameters['photoUrl'];
          final receiverId = state.uri.queryParameters['receiverId'] ?? '';
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: VideoCallScreen(
              callId: callId,
              chatId: chatId,
              receiverName: receiverName,
              receiverPhotoUrl: receiverPhotoUrl,
              receiverId: receiverId,
            ),
          );
        },
      ),
      // Incoming Voice Call
      GoRoute(
        path: incomingVoiceCall,
        name: 'incoming-voice-call',
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: IncomingVoiceCallScreen(
              callId: params['callId']!,
              chatId: params['chatId']!,
              callerName: params['callerName'] ?? 'Unknown',
              callerPhotoUrl: params['callerPhotoUrl'],
              callerId: params['callerId']!,
            ),
          );
        },
      ),

      // Incoming Video Call
      GoRoute(
        path: incomingVideoCall,
        name: 'incoming-video-call',
        pageBuilder: (context, state) {
          final params = state.uri.queryParameters;
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: IncomingVideoCallScreen(
              callId: params['callId']!,
              chatId: params['chatId']!,
              callerName: params['callerName'] ?? 'Unknown',
              callerPhotoUrl: params['callerPhotoUrl'],
              callerId: params['callerId']!,
            ),
          );
        },
      ),
      // Ride routes
      GoRoute(
        path: searchRides,
        name: 'search-rides',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const RideSearchScreen(),
        ),
      ),
      GoRoute(
        path: createRide,
        name: 'create-ride',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const DriverOfferRideScreen(),
        ),
      ),
      GoRoute(
        path: '/ride/detail/:id',
        name: 'ride-detail',
        pageBuilder: (context, state) {
          final rideId = state.pathParameters['id']!;
          return ScaleTransitionPage(
            key: state.pageKey,
            child: RideDetailScreen(rideId: rideId),
          );
        },
      ),

      // New rider routes
      GoRoute(
        path: riderRequestRide,
        name: 'rider-request-ride',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const RiderRequestRideScreen(),
        ),
      ),
      GoRoute(
        path: '/rider/ride/:id',
        name: 'rider-view-ride',
        pageBuilder: (context, state) {
          final rideId = state.pathParameters['id']!;
          return ScaleTransitionPage(
            key: state.pageKey,
            child: RiderViewRideScreen(rideId: rideId),
          );
        },
      ),

      // New driver routes
      GoRoute(
        path: driverOfferRide,
        name: 'driver-offer-ride',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const DriverOfferRideScreen(),
        ),
      ),
      GoRoute(
        path: '/driver/ride/:id',
        name: 'driver-view-ride',
        pageBuilder: (context, state) {
          final rideId = state.pathParameters['id']!;
          return ScaleTransitionPage(
            key: state.pageKey,
            child: DriverViewRideScreen(rideId: rideId),
          );
        },
      ),

      // Notifications route
      GoRoute(
        path: notifications,
        name: 'notifications',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // Settings routes
      GoRoute(
        path: settings,
        name: 'settings',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: editProfile,
        name: 'edit-profile',
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: achievements,
        name: 'achievements',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const AchievementsScreen(),
        ),
      ),
      GoRoute(
        path: vehicles,
        name: 'vehicles',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverVehicleScreen(),
        ),
      ),

      // New Rider My Rides route
      GoRoute(
        path: riderMyRides,
        name: 'rider-my-rides',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const RiderMyRidesScreen(),
        ),
      ),

      // New Driver My Rides route
      GoRoute(
        path: driverMyRides,
        name: 'driver-my-rides',
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: const DriverMyRidesScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
