import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'deep_link_service.g.dart';

/// Handles incoming deep links and routes them to the appropriate screen.
///
/// Supports:
/// - `sportconnect://ride/{id}` → Ride detail screen (custom scheme)
/// - Deep links for Android and iOS platforms
class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  /// Custom URL scheme for deep linking.
  static const _scheme = 'sportconnect';

  /// Initializes deep link listening.
  ///
  /// Call this once from the app's root widget after the router is ready.
  Future<void> initialize(BuildContext context) async {
    try {
      // Handle the initial link (app opened via link while closed)
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        TalkerService.info('🔗 Initial deep link: $initialUri');
        _handleDeepLink(context, initialUri);
      }

      // Listen for subsequent links (app already running)
      _subscription = _appLinks.uriLinkStream.listen(
        (uri) {
          TalkerService.info('🔗 Incoming deep link: $uri');
          _handleDeepLink(context, uri);
        },
        onError: (error) {
          TalkerService.error('❌ Deep link error', error);
        },
      );

      TalkerService.info('✅ Deep link service initialized');
    } catch (e, stackTrace) {
      TalkerService.error('❌ Failed to initialize deep links', e, stackTrace);
    }
  }

  /// Parses the URI and navigates to the appropriate screen.
  void _handleDeepLink(BuildContext context, Uri uri) {
    if (!context.mounted) return;

    final path = _extractPath(uri);
    if (path == null) {
      TalkerService.warning('⚠️ Unrecognized deep link: $uri');
      return;
    }

    // Parse ride links: /ride/{id}
    final rideMatch = RegExp(r'^/ride/([a-zA-Z0-9_-]+)$').firstMatch(path);
    if (rideMatch != null) {
      final rideId = rideMatch.group(1)!;
      TalkerService.info('🔗 Navigating to ride detail: $rideId');
      context.pushNamed(
        AppRoutes.rideDetail.name,
        pathParameters: {'id': rideId},
      );
      return;
    }

    TalkerService.warning('⚠️ No route matched for deep link path: $path');
  }

  /// Extracts the path from a deep link URI.
  ///
  /// Handles custom scheme URLs (`sportconnect://ride/123`).
  String? _extractPath(Uri uri) {
    // Custom scheme: sportconnect://ride/123
    if (uri.scheme == _scheme) {
      // For custom scheme, the host is the first segment
      // sportconnect://ride/123 → host = "ride", path = "/123"
      return '/${uri.host}${uri.path}';
    }

    return null;
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
