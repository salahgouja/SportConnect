import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/features/auth/models/models.dart';

/// Route guard service for centralized route protection logic
///
/// This service encapsulates all redirect logic for the app router,
/// following the Single Responsibility Principle (SRP).

class RouteGuardService {
  final bool isLoading;
  final UserModel? user;
  final bool isEmailVerified;

  const RouteGuardService({
    required this.isLoading,
    required this.user,
    this.isEmailVerified = false,
  });

  /// Factory to create from provider state
  factory RouteGuardService.fromAuthState(
    AsyncValue<UserModel?> userState, {
    bool isEmailVerified = false,
  }) {
    return RouteGuardService(
      isLoading: userState.isLoading,
      user: userState.value,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Get the current user if logged in
  bool get isLoggedIn => user != null;

  /// Check if user is a driver
  bool get isDriver => user is DriverModel;

  /// Check if driver has completed onboarding (has vehicles)
  bool get hasCompletedDriverOnboarding {
    if (!isDriver) return true;
    return (user as DriverModel).vehicleIds.isNotEmpty;
  }

  /// Determine redirect for the given path
  ///
  /// Returns null if no redirect is needed, otherwise returns the target path.
  String? getRedirect(String currentPath) {
    // 1. If auth is still loading, stay on current page
    if (isLoading) return null;

    // 2. Handle splash screen - redirect based on auth state
    if (currentPath == AppRoutes.splash.path) {
      return _getInitialRoute();
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
        AppRoutes.riderOnboarding.path,
        AppRoutes.emailVerification.path,
        AppRoutes.home.path,
        AppRoutes.driverHome.path,
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
        return _getDashboardRoute();
      }
      return null;
    }

    // 5. Protect private routes
    if (!isLoggedIn) {
      return AppRoutes.login.path;
    }

    // 5b. Enforce email verification before allowing app access
    if (!isEmailVerified && currentPath != AppRoutes.emailVerification.path) {
      return AppRoutes.emailVerification.path;
    }

    // 6. Driver-specific route protection
    if (_isDriverRoute(currentPath) && !_isDriverOnboardingRoute(currentPath)) {
      if (!hasCompletedDriverOnboarding) {
        return AppRoutes.driverOnboarding.path;
      }
    }

    return null;
  }

  /// Get the initial route after splash
  String _getInitialRoute() {
    if (!isLoggedIn) {
      return AppRoutes.login.path;
    }
    if (!isEmailVerified) {
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
          return AppRoutes.driverOnboarding.path;
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
        path == AppRoutes.forgotPassword.path ||
        path == AppRoutes.phoneOtp.path;
  }

  /// Check if route is a driver-specific route
  bool _isDriverRoute(String path) {
    return path.startsWith('/driver');
  }

  /// Check if route is driver onboarding
  bool _isDriverOnboardingRoute(String path) {
    return path == AppRoutes.driverOnboarding.path;
  }
}
