import 'package:go_router/go_router.dart';

/// Base route configuration that all feature modules extend
abstract class RouteConfig {
  /// Get routes for this module
  List<RouteBase> getRoutes();
}
