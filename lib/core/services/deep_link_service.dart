import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'deep_link_service.g.dart';

/// Route handler helper class.
class _RouteHandler {
  final RegExp pattern;
  final String routeName;
  final String? paramKey;

  const _RouteHandler({
    required this.pattern,
    required this.routeName,
    this.paramKey,
  });
}

/// Handles incoming deep links and routes them to the appropriate screen.
///
/// Supports:
/// - Custom URL schemes: `sportconnect://ride/abc123`, `sc://ride/abc123`
/// - App Links (HTTPS): `https://marathon-connect.web.app/ride/abc123`
///
/// Format: scheme://host/path
/// Examples:
/// - sportconnect://ride/abc123
/// - sportconnect://open/ride/abc123
/// - sc://ride/abc123
/// - https://marathon-connect.web.app/ride/abc123
class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  /// Singleton instance for convenient static access.
  static final DeepLinkService instance = DeepLinkService();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  /// Primary custom URL scheme
  static const String primaryScheme = 'sportconnect';

  /// Short custom URL scheme
  static const String shortScheme = 'sc';

  /// Firebase Hosting domain for HTTPS deep links.
  ///
  /// HTTPS links work in WhatsApp, Messenger, and other messaging platforms.
  static const String hostingDomain = 'marathon-connect.web.app';

  /// Supported schemes
  static const List<String> supportedSchemes = [primaryScheme, shortScheme];

  /// Generates a shareable deep link for a ride.
  ///
  /// Returns an HTTPS link using Firebase Hosting:
  /// `https://marathon-connect.web.app/ride/{rideId}`.
  ///
  /// HTTPS links work correctly in WhatsApp, Messenger, and other
  /// messaging platforms, unlike custom URL schemes.
  Future<String> generateRideLink({
    required String rideId,
    required String fromCity,
    required String toCity,
    required double price,
    required int seats,
    required DateTime departureTime,
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: hostingDomain,
      path: '/ride/$rideId',
      queryParameters: {
        'from': fromCity,
        'to': toCity,
        'price': price.toStringAsFixed(0),
        'seats': seats.toString(),
        'date': departureTime.toIso8601String(),
      },
    );
    return uri.toString();
  }

  /// Initializes deep link listening.
  ///
  /// Handles App Links / Custom URL schemes (app_links package).
  ///
  /// Call this once from the app's root widget after the router is ready.
  Future<void> initialize(BuildContext context) async {
    try {
      // Handle App Links / Custom URL schemes
      await _initializeAppLinks(context);

      TalkerService.info('✅ Deep link service initialized');
    } catch (e, stackTrace) {
      TalkerService.error('❌ Failed to initialize deep links', e, stackTrace);
    }
  }

  /// Initialize standard App Links (sportconnect://, sc://)
  Future<void> _initializeAppLinks(BuildContext context) async {
    // Handle the initial link (app opened via link while closed)
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      TalkerService.info('🔗 Initial App Link: $initialUri');
      _handleDeepLink(context, initialUri);
    }

    // Listen for subsequent links (app already running)
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        TalkerService.info('🔗 Incoming App Link: $uri');
        _handleDeepLink(context, uri);
      },
      onError: (error) {
        TalkerService.error('❌ App Link error', error);
      },
    );
  }

  /// Parses the URI and navigates to the appropriate screen.
  void _handleDeepLink(BuildContext context, Uri uri) {
    if (!context.mounted) return;

    final path = _extractPath(uri);
    if (path == null) {
      TalkerService.warning('⚠️ Unrecognized deep link: $uri');
      return;
    }

    TalkerService.info('🔗 Parsed path: $path');

    // Route patterns
    final handlers = [
      // Ride detail: /ride/{id}
      _RouteHandler(
        pattern: RegExp(r'^/ride/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.rideDetail.name,
        paramKey: 'id',
      ),
      // Chat detail: /chat/detail/{id}
      _RouteHandler(
        pattern: RegExp(r'^/chat/detail/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.chatDetail.name,
        paramKey: 'id',
      ),
      // Chat ride: /chat/ride/{id}
      _RouteHandler(
        pattern: RegExp(r'^/chat/ride/([a-zA-Z0-9_-]+)$'),
        routeName: AppRoutes.chatRide.name,
        paramKey: 'id',
      ),
      // Profile: /profile
      _RouteHandler(
        pattern: RegExp(r'^/profile$'),
        routeName: AppRoutes.profile.name,
      ),
      // Edit profile: /edit-profile
      _RouteHandler(
        pattern: RegExp(r'^/edit-profile$'),
        routeName: AppRoutes.editProfile.name,
      ),
      // Driver vehicles: /driver/vehicles
      _RouteHandler(
        pattern: RegExp(r'^/driver/vehicles$'),
        routeName: AppRoutes.driverVehicles.name,
      ),
      // Notifications: /notifications
      _RouteHandler(
        pattern: RegExp(r'^/notifications$'),
        routeName: AppRoutes.notifications.name,
      ),
    ];

    for (final handler in handlers) {
      final match = handler.pattern.firstMatch(path);
      if (match != null) {
        TalkerService.info('🔗 Matching route: ${handler.routeName}');
        if (handler.paramKey != null) {
          context.pushNamed(
            handler.routeName,
            pathParameters: {handler.paramKey!: match.group(1)!},
          );
        } else {
          context.pushNamed(handler.routeName);
        }
        return;
      }
    }

    TalkerService.warning('⚠️ No route matched for deep link path: $path');
  }

  /// Extracts the path from a deep link URI.
  ///
  /// Handles:
  /// - Custom URL schemes: sportconnect://ride/123, sc://ride/123
  /// - HTTPS App Links: https://marathon-connect.web.app/ride/123
  String? _extractPath(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();

    // Handle HTTPS App Links from Firebase Hosting
    if (scheme == 'https' && host == hostingDomain) {
      return uri.path;
    }

    // Handle custom URL schemes
    if (!supportedSchemes.contains(scheme)) {
      return null;
    }

    // For sportconnect://open/ride/123, the host is "open" and path is "/ride/123"
    // For sportconnect://ride/123, the host is "ride" and path is "/123"
    // For sc://ride/123, the host is "ride" and path is "/123"

    String path;
    if (host == 'open' || host.isEmpty) {
      // sportconnect://open/ride/123 or sc://ride/123 (host empty)
      path = uri.path;
    } else {
      // sportconnect://ride/123
      path = '/$host${uri.path}';
    }

    // Ensure path starts with /
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    return path;
  }

  /// Cleans up the link stream subscription.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Provides the [DeepLinkService] singleton.
@Riverpod(keepAlive: true)
DeepLinkService deepLinkService(Ref ref) {
  final service = DeepLinkService();
  ref.onDispose(service.dispose);
  return service;
}
