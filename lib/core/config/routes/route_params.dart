import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

class DriverRidePrefill {
  const DriverRidePrefill({
    this.eventId,
    this.eventName,
    this.origin,
    this.destination,
  });

  final String? eventId;
  final String? eventName;
  final LocationPoint? origin;
  final LocationPoint? destination;
}

/// Type-safe parameter extractors for routes
class RouteParams {
  const RouteParams(this.state);
  final GoRouterState state;

  // String parameters
  String? getString(String key) => state.pathParameters[key];
  String getStringOrThrow(String key) {
    final value = getString(key);
    if (value == null) {
      throw ArgumentError('Missing required parameter: $key');
    }
    return value;
  }

  // Query parameters
  String? getQuery(String key) => state.uri.queryParameters[key];
  String getQueryOrDefault(String key, String defaultValue) {
    return getQuery(key) ?? defaultValue;
  }

  // Bool parameters
  bool getBool(String key, {bool defaultValue = false}) {
    final value = getQuery(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  // Int parameters
  int? getInt(String key) {
    final value = getString(key) ?? getQuery(key);
    return value != null ? int.tryParse(value) : null;
  }

  // Extra data (type-safe)
  T? getExtra<T>() => state.extra is T ? state.extra as T : null;
  T getExtraOrThrow<T>() {
    final extra = state.extra;
    if (extra is! T) {
      throw ArgumentError('Expected extra data of type $T');
    }
    return extra;
  }
}

/// Extension for convenient access
extension GoRouterStateX on GoRouterState {
  RouteParams get params => RouteParams(this);
}
