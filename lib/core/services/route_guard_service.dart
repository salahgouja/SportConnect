import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/features/auth/models/models.dart';

/// Route guard service for centralized route protection logic
///
/// This service encapsulates all redirect logic for the app router,
/// following the Single Responsibility Principle (SRP).

class RouteGuardService {
  final bool isLoading;
  final bool isOnboardingLoading;
  final bool hasCompletedOnboarding;
  final UserModel? user;
  final bool isEmailVerified;
  final bool hasVerifiableEmail;

  const RouteGuardService({
    required this.isLoading,
    this.isOnboardingLoading = false,
    this.hasCompletedOnboarding = false,
    required this.user,
    this.isEmailVerified = false,
    this.hasVerifiableEmail = false,
  });

  /// Factory to create from provider state
  factory RouteGuardService.fromAuthState(
    AsyncValue<UserModel?> userState, {
    bool isOnboardingLoading = false,
    bool hasCompletedOnboarding = false,
    bool isEmailVerified = false,
    bool hasVerifiableEmail = false,
  }) {
    return RouteGuardService(
      isLoading: userState.isLoading,
      isOnboardingLoading: isOnboardingLoading,
      hasCompletedOnboarding: hasCompletedOnboarding,
      user: userState.value,
      isEmailVerified: isEmailVerified,
      hasVerifiableEmail: hasVerifiableEmail,
    );
  }

  /// Get the current user if logged in
  bool get isLoggedIn => user != null;

  /// Check if user is a driver
  bool get isDriver => user!.role == UserRole.driver;

  /// Check if driver has completed onboarding (has vehicles)
  bool get hasCompletedDriverOnboarding {
    if (!isDriver) return true;
    return (user as DriverModel).vehicleIds.isNotEmpty;
  }

  /// Check if driver has completed Stripe payout onboarding
  bool get hasCompletedStripeOnboarding {
    if (!isDriver) return true;
    return (user as DriverModel).isStripeOnboarded;
  }

  bool get _driverHasPersistedProfileData {
    final driver = user is DriverModel ? user as DriverModel : null;
    if (driver == null) return false;

    return (driver.phoneNumber?.isNotEmpty ?? false) ||
        (driver.city?.isNotEmpty ?? false) ||
        driver.dateOfBirth != null ||
        (driver.gender?.isNotEmpty ?? false);
  }

  String get _driverOnboardingRedirectPath {
    if (_driverHasPersistedProfileData) {
      return '${AppRoutes.driverOnboarding.path}?skipProfile=true';
    }
    return AppRoutes.driverOnboarding.path;
  }

  /// Determine redirect for the given path
  ///
  /// Returns null if no redirect is needed, otherwise returns the target path.
  String? getRedirect(Uri currentUri) {
    final currentPath = currentUri.path;

    // 1. If auth is still loading, stay on current page
    if (isLoading || isOnboardingLoading) return null;

    // 2. Handle splash screen - redirect based on auth state
    if (currentPath == AppRoutes.splash.path) {
      return _getInitialRoute();
    }

    // 2b. Enforce first-launch onboarding for signed-out users.
    // Legal routes remain accessible before onboarding.
    if (!isLoggedIn && !hasCompletedOnboarding) {
      final isOnboardingRoute = currentPath == AppRoutes.onboarding.path;
      if (!isOnboardingRoute && !_isLegalRoute(currentPath)) {
        return AppRoutes.onboarding.path;
      }
    }

    // 3. Allow users to stay on role selection even when logged in
    if (currentPath == AppRoutes.roleSelection.path && isLoggedIn) {
      return null;
    }

    // 3b. If user needs role selection (persisted in Firestore), force it
    // But allow navigation to onboarding/home screens during setup flow
    if (isLoggedIn && user!.needsRoleSelection) {
      final allowedDuringSetup = [
        AppRoutes.roleSelection.path,
        AppRoutes.driverOnboarding.path,
        AppRoutes.driverStripeOnboarding.path,
        AppRoutes.riderOnboarding.path,
        AppRoutes.emailVerification.path,
      ];
      if (!allowedDuringSetup.contains(currentPath)) {
        return AppRoutes.roleSelection.path;
      }
      return null;
    }

    // 4a. Legal routes are always accessible regardless of auth state.
    //     Required by Apple App Store §5.1.1 and Google Play Developer Policy.
    if (_isLegalRoute(currentPath)) {
      return null;
    }

    // 4b. Handle other public routes
    if (_isPublicRoute(currentPath)) {
      // If logged in and on public route, redirect to dashboard
      if (isLoggedIn) {
        if (currentPath == AppRoutes.login.path) {
          final redirectTarget = _getValidatedRedirectTarget(currentUri);
          if (redirectTarget != null) {
            return redirectTarget;
          }
        }
        if (hasVerifiableEmail && !isEmailVerified) {
          return AppRoutes.emailVerification.path;
        }
        return _getDashboardRoute();
      }
      return null;
    }

    // 5. Protect private routes
    if (!isLoggedIn) {
      final encodedTarget = Uri.encodeComponent(currentUri.toString());
      return '${AppRoutes.login.path}?redirect=$encodedTarget';
    }

    // 5b. Enforce email verification before allowing app access
    if (hasVerifiableEmail &&
        !isEmailVerified &&
        currentPath != AppRoutes.emailVerification.path) {
      return AppRoutes.emailVerification.path;
    }

    // 6. Driver-specific route protection
    if (_isDriverRoute(currentPath) && !_isDriverOnboardingRoute(currentPath)) {
      if (!hasCompletedDriverOnboarding) {
        return _driverOnboardingRedirectPath;
      }
      if (!hasCompletedStripeOnboarding) {
        return AppRoutes.driverStripeOnboarding.path;
      }
    }

    return null;
  }

  /// Get the initial route after splash
  String _getInitialRoute() {
    if (!isLoggedIn) {
      if (!hasCompletedOnboarding) {
        return AppRoutes.onboarding.path;
      }
      return AppRoutes.login.path;
    }
    if (hasVerifiableEmail && !isEmailVerified) {
      return AppRoutes.emailVerification.path;
    }
    return _getDashboardRoute();
  }

  /// Get the appropriate dashboard route based on user role
  String _getDashboardRoute() {
    if (!isLoggedIn) return AppRoutes.login.path;

    return user!.map(
      rider: (_) => AppRoutes.home.path,
      driver: (driver) {
        if (driver.vehicleIds.isEmpty) {
          return _driverOnboardingRedirectPath;
        }
        if (!driver.isStripeOnboarded) {
          return AppRoutes.driverStripeOnboarding.path;
        }
        return AppRoutes.driverHome.path;
      },
    );
  }

  /// Legal routes are always accessible regardless of auth state.
  /// Required by Apple App Store §5.1.1 and Google Play Developer Policy.
  bool _isLegalRoute(String path) {
    return path == AppRoutes.terms.path ||
        path == AppRoutes.privacy.path ||
        path.startsWith('/legal');
  }

  /// Check if route is public (accessible without auth)
  bool _isPublicRoute(String path) {
    return path == AppRoutes.onboarding.path ||
        path == AppRoutes.login.path ||
        path == AppRoutes.signupWizard.path ||
        path == AppRoutes.forgotPassword.path;
  }

  /// Check if route is a driver-specific route
  bool _isDriverRoute(String path) {
    return path.startsWith('/driver');
  }

  /// Check if route is driver onboarding (profile/vehicle wizard or Stripe setup)
  bool _isDriverOnboardingRoute(String path) {
    return path == AppRoutes.driverOnboarding.path ||
        path == AppRoutes.driverStripeOnboarding.path;
  }

  /// Returns a safe in-app redirect target from `?redirect=` query param.
  ///
  /// Rejects external/invalid targets and auth bootstrap routes to avoid loops.
  String? _getValidatedRedirectTarget(Uri currentUri) {
    final raw = currentUri.queryParameters['redirect'];
    if (raw == null || raw.isEmpty) return null;

    final decoded = Uri.decodeComponent(raw);
    if (!decoded.startsWith('/')) return null;
    if (decoded.startsWith('//')) return null;

    final blockedTargets = {
      AppRoutes.splash.path,
      AppRoutes.login.path,
      AppRoutes.onboarding.path,
    };
    if (blockedTargets.contains(decoded)) return null;

    return decoded;
  }
}
