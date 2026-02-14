import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/features/auth/views/login_screen.dart';
import 'package:sport_connect/features/auth/views/register_screen.dart';
import 'package:sport_connect/features/auth/views/signup_wizard_screen.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/features/auth/views/role_selection_screen.dart';
import 'package:sport_connect/features/auth/views/driver_onboarding_screen.dart';

/// Authentication module routes
class AuthRoutes implements RouteConfig {
  @override
  String get moduleName => 'auth';

  @override
  String? get initialRoute => AppRoutes.splash.path;

  @override
  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register.path,
        name: AppRoutes.register.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.signupWizard.path,
        name: AppRoutes.signupWizard.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignupWizardScreen()),
      ),
      GoRoute(
        path: AppRoutes.roleSelection.path,
        name: AppRoutes.roleSelection.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.driverOnboarding.path,
        name: AppRoutes.driverOnboarding.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DriverOnboardingScreen(),
        ),
      ),
    ];
  }
}
