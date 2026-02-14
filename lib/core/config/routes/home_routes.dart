import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/page_transitions.dart';
import 'package:sport_connect/features/home/views/home_screen.dart';
import 'package:sport_connect/features/home/views/driver/driver_home_screen.dart';
import 'package:sport_connect/features/onboarding/views/onboarding_screen.dart';

/// Home module routes
class HomeRoutes implements RouteConfig {
  @override
  String get moduleName => 'home';

  @override
  String? get initialRoute => AppRoutes.home.path;

  @override
  List<RouteBase> getRoutes() {
    return [
      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding.path,
        name: AppRoutes.onboarding.name,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const OnboardingScreen()),
      ),

      // Rider Home
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        pageBuilder: (context, state) =>
            FadeTransitionPage(key: state.pageKey, child: const HomeScreen()),
      ),

      // Driver Home
      GoRoute(
        path: AppRoutes.driverHome.path,
        name: AppRoutes.driverHome.name,
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: const DriverHomeScreen(),
        ),
      ),
    ];
  }
}
