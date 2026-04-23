// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$typedLoginRoute];

RouteBase get $typedLoginRoute => GoRouteData.$route(
  path: '/login',
  name: 'login',
  factory: $TypedLoginRoute._fromState,
);

mixin $TypedLoginRoute on GoRouteData {
  static TypedLoginRoute _fromState(GoRouterState state) =>
      const TypedLoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
