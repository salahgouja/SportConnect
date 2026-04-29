import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/features/auth/views/change_password_screen.dart';
import 'package:sport_connect/features/auth/views/driver_onboarding_screen.dart';
import 'package:sport_connect/features/auth/views/email_verification_screen.dart';
import 'package:sport_connect/features/auth/views/forgot_password_screen.dart';
import 'package:sport_connect/features/auth/views/login_screen.dart';
import 'package:sport_connect/features/auth/views/rider_onboarding_screen.dart';
import 'package:sport_connect/features/auth/views/role_selection_screen.dart';
import 'package:sport_connect/features/auth/views/signup_wizard_screen.dart';
import 'package:sport_connect/features/auth/views/splash_screen.dart';
import 'package:sport_connect/features/onboarding/views/onboarding_screen.dart';

/// Auth module routes
class AuthRoutes implements RouteConfig {
  @override
  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AppRoutes.splash.path,
        name: AppRoutes.splash.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(key: state.pageKey, child: const SplashScreen())
            : MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(key: state.pageKey, child: const OnboardingScreen())
            : MaterialPage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(key: state.pageKey, child: const LoginScreen())
            : MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signupWizard.path,
        name: AppRoutes.signupWizard.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const SignupWizardScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const SignupWizardScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection.path,
        name: AppRoutes.roleSelection.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const RoleSelectionScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const RoleSelectionScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.driverOnboarding.path,
        name: AppRoutes.driverOnboarding.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const DriverOnboardingScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const DriverOnboardingScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.riderOnboarding.path,
        name: AppRoutes.riderOnboarding.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const RiderOnboardingScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const RiderOnboardingScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword.path,
        name: AppRoutes.forgotPassword.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const ForgotPasswordScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const ForgotPasswordScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.emailVerification.path,
        name: AppRoutes.emailVerification.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const EmailVerificationScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const EmailVerificationScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.changePassword.path,
        name: AppRoutes.changePassword.name,
        pageBuilder: (context, state) => PlatformInfo.isIOS
            ? CupertinoPage(
                key: state.pageKey,
                child: const ChangePasswordScreen(),
              )
            : MaterialPage(
                key: state.pageKey,
                child: const ChangePasswordScreen(),
              ),
      ),
    ];
  }
}
