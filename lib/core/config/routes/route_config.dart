import 'package:go_router/go_router.dart';

/// Base route configuration that all feature modules extend
abstract class RouteConfig {
  /// Get routes for this module
  List<RouteBase> getRoutes();

  /// Get module name for namespacing
  String get moduleName;

  /// Get initial route for this module (if any)
  /// Override in subclasses if the module has an initial route
  String? get initialRoute => null;
}

/// Route guard for authentication
class RouteGuard {
  final bool requiresAuth;
  final bool requiresRole;
  final List<String>? allowedRoles;

  const RouteGuard({
    this.requiresAuth = false,
    this.requiresRole = false,
    this.allowedRoles,
  });
}

/// Route metadata for better organization
class RouteMetadata {
  final String title;
  final String description;
  final RouteGuard guard;
  final bool showInBottomNav;

  const RouteMetadata({
    required this.title,
    this.description = '',
    this.guard = const RouteGuard(),
    this.showInBottomNav = false,
  });
}
