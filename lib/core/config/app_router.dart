import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/auth_routes.dart';
import 'package:sport_connect/core/config/routes/chat_routes.dart';
import 'package:sport_connect/core/config/routes/events_routes.dart';
import 'package:sport_connect/core/config/routes/legal_routes.dart';
import 'package:sport_connect/core/config/routes/premium_routes.dart';
import 'package:sport_connect/core/config/routes/profile_routes.dart';
import 'package:sport_connect/core/config/routes/reviews_routes.dart';
import 'package:sport_connect/core/config/routes/ride_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/analytics_service.dart';
import 'package:sport_connect/core/services/route_guard_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/main_wrapper.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/events/views/event_list_screen.dart';
import 'package:sport_connect/features/home/views/driver_home_screen.dart';
import 'package:sport_connect/features/home/views/rider_home_screen.dart';
import 'package:sport_connect/features/messaging/views/chat_list_screen.dart';
import 'package:sport_connect/features/onboarding/repositories/onboarding_repository.dart';
import 'package:sport_connect/features/payments/payments.dart';
import 'package:sport_connect/features/profile/views/profile_screen.dart';
import 'package:sport_connect/features/rides/views/driver/driver_my_rides_screen.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_my_rides_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

const _enableRouterDiagnostics = bool.fromEnvironment(
  'SPORT_CONNECT_DEBUG_INSTRUMENTATION',
);

/// Main router provider with centralized redirect logic.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Use ref.listen (NOT ref.watch) to avoid full router disposal/recreation
  // on every auth state change. The refreshListenable triggers redirect
  // re-evaluation without rebuilding the entire GoRouter instance.
  final routerListenable = _AuthChangeNotifier();

  ref.listen(currentUserProvider, (previous, next) {
    if (_routeUserStateKey(previous) != _routeUserStateKey(next)) {
      routerListenable.notify();
    }
  });

  ref.listen(currentDriverConnectedAccountProvider, (previous, next) {
    if (_routeConnectedAccountStateKey(previous) !=
        _routeConnectedAccountStateKey(next)) {
      routerListenable.notify();
    }
  });

  ref.listen(selectedRoleIntentProvider, (previous, next) {
    if (_routeRoleIntentStateKey(previous) != _routeRoleIntentStateKey(next)) {
      routerListenable.notify();
    }
  });

  // Also listen to raw Firebase Auth state so email-verification changes
  // (which don't affect the Firestore UserModel) still trigger a redirect.
  ref.listen(authStateProvider, (previous, next) {
    routerListenable.notify();
  });

  // Listen to onboarding completion so splash redirect can switch between
  // onboarding and login without recreating the router.
  ref.listen(isOnboardingCompleteProvider, (previous, next) {
    routerListenable.notify();
  });

  ref.onDispose(routerListenable.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: kDebugMode && _enableRouterDiagnostics,
    refreshListenable: routerListenable,
    requestFocus: false,
    observers: [
      if (AnalyticsService.instance.isInitialized)
        AnalyticsService.instance.navigatorObserver,
    ],
    redirect: (context, state) {
      final userState = ref.read(currentUserProvider);
      final onboardingState = ref.read(isOnboardingCompleteProvider);
      final firebaseUser = ref.read(authStateProvider).value;
      final connectedAccountState = ref.read(
        currentDriverConnectedAccountProvider,
      );
      final isFirestoreStillLoading =
          firebaseUser != null &&
          userState.value == null &&
          !userState.hasValue &&
          !userState.hasError;

      final needsRoleSelection = userState.value?.role == UserRole.pending;
      final selectedRoleIntent = needsRoleSelection
          ? ref.read(selectedRoleIntentProvider).value
          : null;

      return _handleRedirect(
        userState,
        onboardingState,
        connectedAccountState,
        state,
        isEmailVerified: firebaseUser?.emailVerified ?? false,
        needsRoleSelection: needsRoleSelection,
        hasVerifiableEmail: firebaseUser?.email?.isNotEmpty ?? false,
        isFirestoreStillLoading: isFirestoreStillLoading,
        selectedRoleIntent: selectedRoleIntent,
      );
    },
    routes: _buildRoutes(),
    errorBuilder: _buildErrorPage,
  );
}

/// Centralized redirect handler using [RouteGuardService].
String? _handleRedirect(
  AsyncValue<UserModel?> userState,
  AsyncValue<bool> onboardingState,
  AsyncValue<DriverConnectedAccount?> connectedAccountState,
  GoRouterState state, {
  bool isEmailVerified = false,
  bool needsRoleSelection = false,
  bool hasVerifiableEmail = false,
  bool isFirestoreStillLoading = false,
  UserRole? selectedRoleIntent,
}) {
  final guard = RouteGuardService.fromAuthState(
    userState,
    isOnboardingLoading: onboardingState.isLoading,
    isFirestoreStillLoading: isFirestoreStillLoading,
    isConnectedAccountLoading: connectedAccountState.isLoading,
    needsRoleSelection: needsRoleSelection,
    hasCompletedOnboarding: onboardingState.value ?? true,
    isEmailVerified: isEmailVerified,
    hasVerifiableEmail: hasVerifiableEmail,
    selectedRoleIntent: selectedRoleIntent,
    currentDriverConnectedAccount: connectedAccountState.value,
  );
  return guard.getRedirect(state.uri);
}

// ── Modular route configurations ─────────────────────────────────────────────

final _rideRoutes = RideRoutes();
final _profileRoutes = ProfileRoutes();
final _eventsRoutes = EventsRoutes();
final _legalRoutes = LegalRoutes();
final _chatRoutes = ChatRoutes();
final _authRoutes = AuthRoutes();
final _premiumRoutes = PremiumRoutes();
final _reviewsRoutes = ReviewsRoutes();

List<RouteBase> _buildRoutes() {
  return [
    ..._authRoutes.getRoutes().cast<GoRoute>(),
    ..._legalRoutes.getRoutes().cast<GoRoute>(),
    _buildMainShell(),
    ..._rideRoutes.getRoutes().cast<GoRoute>(),
    ..._chatRoutes.getRoutes().cast<GoRoute>(),
    ..._premiumRoutes.getRoutes().cast<GoRoute>(),
    ..._profileRoutes.getRoutes().cast<GoRoute>(),
    ..._eventsRoutes.getRoutes().cast<GoRoute>(),
    ..._reviewsRoutes.getRoutes().cast<GoRoute>(),
  ];
}

// ── Main app shell (Bottom Navigation) ───────────────────────────────────────

StatefulShellRoute _buildMainShell() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MainWrapper(navigationShell: navigationShell);
    },
    branches: [
      ..._buildRiderBranches(),
      ..._buildDriverBranches(),
    ],
  );
}

List<StatefulShellBranch> _buildRiderBranches() {
  return [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.home.path,
          name: AppRoutes.home.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.home.name,
            child: const RiderHomeScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.riderMyRides.path,
          name: AppRoutes.riderMyRides.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.riderMyRides.name,
            child: const RiderMyRidesScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.events.path,
          name: AppRoutes.events.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.events.name,
            child: const EventListScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.chat.path,
          name: AppRoutes.chat.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.chat.name,
            child: const ChatListScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.profile.path,
          name: AppRoutes.profile.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.profile.name,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
  ];
}

List<StatefulShellBranch> _buildDriverBranches() {
  return [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverHome.path,
          name: AppRoutes.driverHome.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.driverHome.name,
            child: const DriverHomeScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverRides.path,
          name: AppRoutes.driverRides.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.driverRides.name,
            child: const DriverMyRidesScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverEarnings.path,
          name: AppRoutes.driverEarnings.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.driverEarnings.name,
            child: const DriverEarningsScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverChat.path,
          name: AppRoutes.driverChat.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.driverChat.name,
            child: const ChatListScreen(),
          ),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutes.driverProfileTab.path,
          name: AppRoutes.driverProfileTab.name,
          pageBuilder: (context, state) => _shellPage(
            state: state,
            keyValue: AppRoutes.driverProfileTab.name,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
  ];
}

Page<void> _shellPage({
  required GoRouterState state,
  required String keyValue,
  required Widget child,
}) {
  final key = ValueKey<String>('shell-tab-$keyValue');

  if (PlatformInfo.isIOS) {
    return CupertinoPage<void>(
      key: key,
      child: child,
    );
  }

  return MaterialPage<void>(
    key: key,
    child: child,
  );
}

// ── Router refresh listenable ─────────────────────────────────────────────────

/// A simple ChangeNotifier that forwards auth/user state changes to GoRouter.
///
/// Using notifyListeners() is safer than a boolean toggle, which can silently
/// cancel out if two emissions arrive in the same frame (true→false→true
/// evaluates as no change in a ValueNotifier).
class _AuthChangeNotifier extends ChangeNotifier {
  var _disposed = false;
  var _notifyScheduled = false;

  void notify() {
    if (_notifyScheduled || _disposed) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

String _routeUserStateKey(AsyncValue<UserModel?>? state) {
  if (state == null) return 'none';
  return '${state.isLoading}:${state.hasError}:${_routeUserKey(state.value)}';
}

String _routeConnectedAccountStateKey(
  AsyncValue<DriverConnectedAccount?>? state,
) {
  if (state == null) return 'none';

  final account = state.value;
  if (account == null) {
    return '${state.isLoading}:${state.hasError}:null';
  }

  return [
    state.isLoading,
    state.hasError,
    account.stripeAccountId,
    account.chargesEnabled,
    account.payoutsEnabled,
    account.detailsSubmitted,
    account.onboardingCompleted,
    account.capabilities.transfers.name,
  ].join(':');
}

String _routeRoleIntentStateKey(AsyncValue<UserRole?>? state) {
  if (state == null) return 'none';
  return '${state.isLoading}:${state.hasError}:${state.value?.name ?? 'null'}';
}

String _routeUserKey(UserModel? user) {
  if (user == null) return 'signed-out';

  return user.map(
    rider: (rider) => 'rider:${rider.uid}',
    driver: (driver) =>
        'driver:${driver.uid}:${driver.vehicleIds.join(',')}:'
        '${driver.stripeAccountId ?? ''}',
    pending: (pending) => 'pending:${pending.uid}',
  );
}

// ── Error page ────────────────────────────────────────────────────────────────

Widget _buildErrorPage(BuildContext context, GoRouterState state) {
  return Center(
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
  );
}
